import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:final032/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _api = ApiService();

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _publisherController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Map<String, dynamic>> _categories = [];

  Uint8List? _imageBytes;
  String? _fileName;
  int? _categoryId;

  bool _isLoadingCategories = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await _api.fetchCategories();

      if (!mounted) return;

      final categories =
          data.map((item) => Map<String, dynamic>.from(item as Map)).toList();

      setState(() {
        _categories = categories;
        _isLoadingCategories = false;

        if (categories.isNotEmpty) {
          _categoryId = int.tryParse(
            categories.first['category_id'].toString(),
          );
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoadingCategories = false;
      });

      _showMessage('ไม่สามารถโหลดหมวดหมู่ได้');
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null) return;

    final file = result.files.first;

    if (file.bytes == null) {
      _showMessage('ไม่สามารถอ่านไฟล์รูปภาพได้');
      return;
    }

    setState(() {
      _imageBytes = file.bytes;
      _fileName = file.name;
    });
  }

  Future<String?> _uploadImage() async {
    if (_imageBytes == null || _fileName == null) return null;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiService.baseUrl}/upload_image.php'),
    );

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        _imageBytes!,
        filename: _fileName,
      ),
    );

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final data = jsonDecode(body);

    if (response.statusCode == 200 && data['status'] == 'success') {
      return data['imageUrl']?.toString();
    }

    return null;
  }

  Future<void> _saveBook() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (_imageBytes == null) {
      _showMessage('กรุณาเลือกรูปหนังสือ');
      return;
    }

    if (_categoryId == null) {
      _showMessage('กรุณาเลือกหมวดหมู่');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final imageUrl = await _uploadImage();

      if (imageUrl == null) {
        throw Exception('Upload failed');
      }

      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/add_book.php'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'title': _titleController.text.trim(),
          'author': _authorController.text.trim(),
          'publisher': _publisherController.text.trim(),
          'price': double.parse(_priceController.text.trim()),
          'description': _descriptionController.text.trim(),
          'imageUrl': imageUrl,
          'category_id': _categoryId,
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        _showMessage('เพิ่มหนังสือไม่สำเร็จ');
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage('เกิดข้อผิดพลาด กรุณาลองใหม่');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกข้อมูล';
    }

    return null;
  }

  String? _priceValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกราคา';
    }

    final price = double.tryParse(value.trim());

    if (price == null || price < 0) {
      return 'กรุณากรอกราคาให้ถูกต้อง';
    }

    return null;
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator ?? _requiredValidator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1 ? Icon(icon) : null,
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  Widget _buildImagePicker() {
    return Container(
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: _imageBytes == null
          ? InkWell(
              onTap: _pickImage,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Color(0xFFDBEAFE),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 34,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Choose book cover',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'PNG, JPG or WEBP',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(
                  _imageBytes!,
                  fit: BoxFit.contain,
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: FilledButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Change'),
                  ),
                ),
              ],
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Book'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book information',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'กรอกข้อมูลหนังสือและเลือกรูปหน้าปก',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 28),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 800;

                          final informationForm = Column(
                            children: [
                              _buildField(
                                controller: _titleController,
                                label: 'Title',
                                icon: Icons.title,
                              ),
                              const SizedBox(height: 16),
                              _buildField(
                                controller: _authorController,
                                label: 'Author',
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 16),
                              _buildField(
                                controller: _publisherController,
                                label: 'Publisher',
                                icon: Icons.business_outlined,
                              ),
                              const SizedBox(height: 16),
                              _buildField(
                                controller: _priceController,
                                label: 'Price (฿)',
                                icon: Icons.payments_outlined,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                validator: _priceValidator,
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<int>(
                                value: _categoryId,
                                decoration: const InputDecoration(
                                  labelText: 'Category',
                                  prefixIcon: Icon(Icons.category_outlined),
                                ),
                                items: _categories.map((category) {
                                  return DropdownMenuItem<int>(
                                    value: int.tryParse(
                                      category['category_id'].toString(),
                                    ),
                                    child: Text(
                                      category['category_name']?.toString() ??
                                          'Unnamed',
                                    ),
                                  );
                                }).toList(),
                                onChanged: _isLoadingCategories
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _categoryId = value;
                                        });
                                      },
                                validator: (value) {
                                  if (value == null) {
                                    return 'กรุณาเลือกหมวดหมู่';
                                  }

                                  return null;
                                },
                              ),
                            ],
                          );

                          if (!isWide) {
                            return Column(
                              children: [
                                _buildImagePicker(),
                                const SizedBox(height: 24),
                                informationForm,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 350,
                                child: _buildImagePicker(),
                              ),
                              const SizedBox(width: 28),
                              Expanded(child: informationForm),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildField(
                        controller: _descriptionController,
                        label: 'Description',
                        icon: Icons.description_outlined,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _isSaving
                                ? null
                                : () {
                                    Navigator.pop(context);
                                  },
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: _isSaving ? null : _saveBook,
                            icon: _isSaving
                                ? const SizedBox.square(
                                    dimension: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.add),
                            label: Text(
                              _isSaving ? 'Saving...' : 'Add Book',
                            ),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _publisherController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
