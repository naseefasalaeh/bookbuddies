import 'package:final032/models/book.dart';
import 'package:final032/services/api_service.dart';
import 'package:final032/services/session_service.dart';
import 'package:final032/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class BookCategoryPage extends StatefulWidget {
  const BookCategoryPage({super.key});

  @override
  State<BookCategoryPage> createState() => _BookCategoryPageState();
}

class _BookCategoryPageState extends State<BookCategoryPage> {
  final ApiService _api = ApiService();

  List<Map<String, dynamic>> _categories = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _api.fetchCategories();

      final categories = data
          .map(
            (item) => Map<String, dynamic>.from(item as Map),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'ไม่สามารถโหลดข้อมูลหมวดหมู่ได้';
      });
    }
  }

  Book _createBook(
    Map<String, dynamic> bookData,
    Map<String, dynamic> category,
  ) {
    final data = Map<String, dynamic>.from(bookData);

    data['category_id'] ??= category['category_id']?.toString() ?? '';

    return Book.fromJson(data);
  }

  Future<void> _openDetail(Book book) async {
    final userId = await SessionService.getUserId();

    if (!mounted) return;

    if (userId == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    await Navigator.pushNamed(
      context,
      '/detail',
      arguments: {
        'book': book,
        'userId': userId,
      },
    );
  }

  int get _totalBooks {
    var total = 0;

    for (final category in _categories) {
      final books = category['books'];

      if (books is List) {
        total += books.length;
      }
    }

    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadCategories,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }

    if (_errorMessage != null) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: _PageState(
              icon: Icons.cloud_off_outlined,
              title: 'โหลดข้อมูลไม่สำเร็จ',
              message: _errorMessage!,
              buttonLabel: 'ลองอีกครั้ง',
              onPressed: _loadCategories,
            ),
          ),
        ],
      );
    }

    if (_categories.isEmpty) {
      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: _PageState(
              icon: Icons.category_outlined,
              title: 'ยังไม่มีหมวดหมู่',
              message: 'ขณะนี้ยังไม่มีข้อมูลหมวดหมู่หนังสือ',
              buttonLabel: 'โหลดใหม่',
              onPressed: _loadCategories,
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(30, 38, 30, 50),
      children: [
        _buildHeader(),
        const SizedBox(height: 38),
        ..._categories.map(
          (category) => _CategorySection(
            category: category,
            createBook: _createBook,
            onDetail: _openDetail,
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 32,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 650;

          final titleSection = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFF2563EB),
                child: Icon(
                  Icons.category_rounded,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 18),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Book Categories',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'ค้นหาหนังสือจากหมวดหมู่ที่คุณสนใจ',
                      style: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );

          final information = Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _InformationChip(
                icon: Icons.folder_outlined,
                label: '${_categories.length} categories',
              ),
              _InformationChip(
                icon: Icons.menu_book_outlined,
                label: '$_totalBooks books',
              ),
            ],
          );

          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleSection,
                const SizedBox(height: 22),
                information,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: titleSection),
              information,
            ],
          );
        },
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.category,
    required this.createBook,
    required this.onDetail,
  });

  final Map<String, dynamic> category;

  final Book Function(
    Map<String, dynamic>,
    Map<String, dynamic>,
  ) createBook;

  final Future<void> Function(Book) onDetail;

  @override
  Widget build(BuildContext context) {
    final categoryName = category['category_name']?.toString() ?? 'Unnamed';

    final rawBooks = category['books'];

    final books = rawBooks is List
        ? rawBooks
            .whereType<Map>()
            .map(
              (item) => createBook(
                Map<String, dynamic>.from(item),
                category,
              ),
            )
            .toList()
        : <Book>[];

    return Padding(
      padding: const EdgeInsets.only(bottom: 42),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 5,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  categoryName,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDBEAFE),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '${books.length} books',
                  style: const TextStyle(
                    color: Color(0xFF1D4ED8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (books.isEmpty)
            const _EmptyCategory()
          else
            LayoutBuilder(
              builder: (context, constraints) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: books.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 290,
                    mainAxisExtent: 440,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                  ),
                  itemBuilder: (context, index) {
                    final book = books[index];

                    return _CategoryBookCard(
                      book: book,
                      onDetail: () {
                        onDetail(book);
                      },
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _CategoryBookCard extends StatelessWidget {
  const _CategoryBookCard({
    required this.book,
    required this.onDetail,
  });

  final Book book;
  final VoidCallback onDetail;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onDetail,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color(0xFFF1F5F9),
                child: Image.network(
                  book.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (
                    context,
                    child,
                    loadingProgress,
                  ) {
                    if (loadingProgress == null) return child;

                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const _ImagePlaceholder();
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 16,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '฿${book.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: onDetail,
                        icon: const Icon(
                          Icons.visibility_outlined,
                          size: 18,
                        ),
                        label: const Text('Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InformationChip extends StatelessWidget {
  const _InformationChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF334155),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF93C5FD),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 45,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 8),
          Text(
            'Image unavailable',
            style: TextStyle(
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCategory extends StatelessWidget {
  const _EmptyCategory();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFFF1F5F9),
            child: Icon(
              Icons.menu_book_outlined,
              color: Color(0xFF64748B),
            ),
          ),
          SizedBox(width: 14),
          Text(
            'ยังไม่มีหนังสือในหมวดหมู่นี้',
            style: TextStyle(
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageState extends StatelessWidget {
  const _PageState({
    required this.icon,
    required this.title,
    required this.message,
    this.buttonLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? buttonLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFDBEAFE),
              child: Icon(
                icon,
                size: 40,
                color: const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
              ),
            ),
            if (buttonLabel != null && onPressed != null) ...[
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onPressed,
                child: Text(buttonLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
