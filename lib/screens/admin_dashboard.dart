import 'package:final032/models/book.dart';
import 'package:final032/screens/add_book.dart';
import 'package:final032/services/api_service.dart';
import 'package:final032/services/session_service.dart';
import 'package:final032/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final ApiService _api = ApiService();
  List<Book> _books = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _users = [];
  int? _adminId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final isAdmin = await SessionService.isAdmin();
    final adminId = await SessionService.getUserId();
    if (!mounted) return;

    if (!isAdmin || adminId == null) {
      Navigator.pushReplacementNamed(context, '/home');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('หน้านี้สำหรับผู้ดูแลระบบเท่านั้น')),
      );
      return;
    }

    _adminId = adminId;
    await _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _api.fetchBooks(),
        _api.fetchCategories(),
        _api.fetchUsers(_adminId!),
      ]);
      if (!mounted) return;
      setState(() {
        _books = results[0] as List<Book>;
        _categories = (results[1] as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        _users = (results[2] as List)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('โหลดข้อมูลสำหรับผู้ดูแลไม่สำเร็จ')),
      );
    }
  }

  Future<void> _addBook() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddBookScreen()),
    );
    if (changed == true) await _loadData();
  }

  Future<void> _editBook(Book book) async {
    final changed = await Navigator.pushNamed(context, '/edit', arguments: book);
    if (changed == true) await _loadData();
  }

  Future<void> _deleteBook(Book book) async {
    final confirmed = await _confirm(
      title: 'Delete book?',
      message: 'ต้องการลบ “${book.title}” ใช่หรือไม่?',
    );
    if (!confirmed) return;

    final success = await _api.deleteBook(book.id);
    if (!mounted) return;
    _showMessage(success ? 'ลบหนังสือแล้ว' : 'ลบหนังสือไม่สำเร็จ');
    if (success) await _loadData();
  }

  Future<void> _saveCategory({Map<String, dynamic>? category}) async {
    final controller = TextEditingController(
      text: category?['category_name']?.toString() ?? '',
    );
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(category == null ? 'Add category' : 'Edit category'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Category name'),
          onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;

    final success = category == null
        ? await _api.addCategory(name)
        : await _api.updateCategory(
            int.parse(category['category_id'].toString()),
            name,
          );
    if (!mounted) return;
    _showMessage(success ? 'บันทึกหมวดหมู่แล้ว' : 'บันทึกหมวดหมู่ไม่สำเร็จ');
    if (success) await _loadData();
  }

  Future<void> _deleteCategory(Map<String, dynamic> category) async {
    final confirmed = await _confirm(
      title: 'Delete category?',
      message: 'ต้องการลบ “${category['category_name']}” ใช่หรือไม่?',
    );
    if (!confirmed) return;

    final result = await _api.deleteCategory(
      int.parse(category['category_id'].toString()),
    );
    if (!mounted) return;
    _showMessage(
      result['success'] == true
          ? 'ลบหมวดหมู่แล้ว'
          : result['message']?.toString() ?? 'ลบหมวดหมู่ไม่สำเร็จ',
    );
    if (result['success'] == true) await _loadData();
  }

  Future<void> _changeRole(Map<String, dynamic> user) async {
    final userId = int.parse(user['id'].toString());
    if (userId == _adminId) {
      _showMessage('ไม่สามารถเปลี่ยนสิทธิ์ของบัญชีที่กำลังใช้งานได้');
      return;
    }

    final currentRole = user['role']?.toString() ?? 'user';
    final newRole = currentRole == 'admin' ? 'user' : 'admin';
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Change user role?'),
            content: Text('เปลี่ยน ${user['username']} จาก $currentRole เป็น $newRole ใช่หรือไม่?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Confirm')),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    final result = await _api.updateUserRole(
      adminId: _adminId!,
      userId: userId,
      role: newRole,
    );
    if (!mounted) return;
    _showMessage(
      result['success'] == true
          ? 'เปลี่ยนสิทธิ์ผู้ใช้แล้ว'
          : result['message']?.toString() ?? 'เปลี่ยนสิทธิ์ไม่สำเร็จ',
    );
    if (result['success'] == true) await _loadData();
  }

  Future<bool> _confirm({required String title, required String message}) async {
    return await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Content Management', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                              const SizedBox(height: 6),
                              const Text('จัดการหนังสือและหมวดหมู่จากพื้นที่เดียว', style: TextStyle(color: Color(0xFF64748B))),
                            ],
                          ),
                        ),
                        FilledButton.icon(onPressed: _addBook, icon: const Icon(Icons.add), label: const Text('Add book')),
                      ],
                    ),
                  ),
                  const TabBar(
                    tabs: [
                      Tab(icon: Icon(Icons.menu_book_outlined), text: 'Books'),
                      Tab(icon: Icon(Icons.category_outlined), text: 'Categories'),
                      Tab(icon: Icon(Icons.people_outline), text: 'Users'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _BooksAdminList(books: _books, onEdit: _editBook, onDelete: _deleteBook),
                        _CategoriesAdminList(categories: _categories, onAdd: () => _saveCategory(), onEdit: (item) => _saveCategory(category: item), onDelete: _deleteCategory),
                        _UsersAdminList(users: _users, currentAdminId: _adminId!, onChangeRole: _changeRole),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _UsersAdminList extends StatelessWidget {
  const _UsersAdminList({required this.users, required this.currentAdminId, required this.onChangeRole});

  final List<Map<String, dynamic>> users;
  final int currentAdminId;
  final ValueChanged<Map<String, dynamic>> onChangeRole;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final user = users[index];
        final id = int.parse(user['id'].toString());
        final role = user['role']?.toString() ?? 'user';
        final isCurrent = id == currentAdminId;

        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: Text((user['username']?.toString() ?? 'U')[0].toUpperCase()),
            ),
            title: Text(user['username']?.toString() ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(user['email']?.toString() ?? '-'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  avatar: Icon(role == 'admin' ? Icons.admin_panel_settings_outlined : Icons.person_outline, size: 17),
                  label: Text(role.toUpperCase()),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: isCurrent ? null : () => onChangeRole(user),
                  child: Text(role == 'admin' ? 'Make user' : 'Make admin'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BooksAdminList extends StatelessWidget {
  const _BooksAdminList({required this.books, required this.onEdit, required this.onDelete});
  final List<Book> books;
  final ValueChanged<Book> onEdit;
  final ValueChanged<Book> onDelete;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: books.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) {
        final book = books[index];
        return Card(
          child: ListTile(
            leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(book.imageUrl, width: 48, height: 62, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox(width: 48, child: Icon(Icons.book_outlined)))),
            title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('${book.author} • \$${book.price.toStringAsFixed(2)}'),
            trailing: Wrap(
              children: [
                IconButton(tooltip: 'Edit', onPressed: () => onEdit(book), icon: const Icon(Icons.edit_outlined)),
                IconButton(tooltip: 'Delete', onPressed: () => onDelete(book), icon: const Icon(Icons.delete_outline, color: Colors.red)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoriesAdminList extends StatelessWidget {
  const _CategoriesAdminList({required this.categories, required this.onAdd, required this.onEdit, required this.onDelete});
  final List<Map<String, dynamic>> categories;
  final VoidCallback onAdd;
  final ValueChanged<Map<String, dynamic>> onEdit;
  final ValueChanged<Map<String, dynamic>> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Align(alignment: Alignment.centerRight, child: OutlinedButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Add category'))),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final category = categories[index];
              final books = category['books'] as List? ?? [];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.category_outlined)),
                  title: Text(category['category_name']?.toString() ?? 'Unnamed', style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${books.length} books'),
                  trailing: Wrap(
                    children: [
                      IconButton(tooltip: 'Edit', onPressed: () => onEdit(category), icon: const Icon(Icons.edit_outlined)),
                      IconButton(tooltip: 'Delete', onPressed: () => onDelete(category), icon: const Icon(Icons.delete_outline, color: Colors.red)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
