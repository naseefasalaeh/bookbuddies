import 'package:final032/models/book.dart';
import 'package:final032/services/api_service.dart';
import 'package:final032/services/session_service.dart';
import 'package:final032/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  final ApiService _api = ApiService();
  final TextEditingController _searchController = TextEditingController();

  List<Book> _books = [];
  List<Book> _filteredBooks = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final books = await _api.fetchBooks();

      if (!mounted) return;

      setState(() {
        _books = books;
        _filteredBooks = books;
        _isLoading = false;
      });

      _filterBooks(_searchController.text);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'ไม่สามารถโหลดข้อมูลหนังสือได้';
      });
    }
  }

  void _filterBooks(String query) {
    final searchText = query.trim().toLowerCase();

    setState(() {
      if (searchText.isEmpty) {
        _filteredBooks = List<Book>.from(_books);
        return;
      }

      _filteredBooks = _books.where((book) {
        final title = book.title.toLowerCase();
        final author = book.author.toLowerCase();
        final publisher = book.publisher.toLowerCase();

        return title.contains(searchText) ||
            author.contains(searchText) ||
            publisher.contains(searchText);
      }).toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterBooks('');
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

  int _getColumnCount(double width) {
    if (width >= 1600) return 5;
    if (width >= 1200) return 4;
    if (width >= 850) return 3;
    if (width >= 560) return 2;

    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadBooks,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _MessageState(
                  icon: Icons.cloud_off_outlined,
                  title: 'โหลดข้อมูลไม่สำเร็จ',
                  message: _errorMessage!,
                  buttonLabel: 'ลองอีกครั้ง',
                  onPressed: _loadBooks,
                ),
              )
            else if (_filteredBooks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _MessageState(
                  icon: Icons.search_off_rounded,
                  title: 'ไม่พบหนังสือ',
                  message: _searchController.text.isEmpty
                      ? 'ขณะนี้ยังไม่มีหนังสือในระบบ'
                      : 'ลองค้นหาด้วยชื่อหนังสือหรือชื่อผู้เขียนอื่น',
                  buttonLabel:
                      _searchController.text.isEmpty ? null : 'ล้างการค้นหา',
                  onPressed:
                      _searchController.text.isEmpty ? null : _clearSearch,
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 48),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final columns = _getColumnCount(
                      constraints.crossAxisExtent,
                    );

                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        mainAxisExtent: 470,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final book = _filteredBooks[index];

                          return _BookCard(
                            book: book,
                            onDetail: () {
                              _openDetail(book);
                            },
                          );
                        },
                        childCount: _filteredBooks.length,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 38, 30, 28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 800;

          final titleSection = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore Books',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_filteredBooks.length} books available',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 16,
                ),
              ),
            ],
          );

          final searchField = SizedBox(
            width: isWide ? 420 : double.infinity,
            child: TextField(
              controller: _searchController,
              onChanged: _filterBooks,
              decoration: InputDecoration(
                hintText: 'Search by title, author or publisher',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
          );

          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titleSection,
                const SizedBox(height: 20),
                searchField,
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: titleSection),
              searchField,
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({
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
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '฿${book.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 17,
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
            size: 48,
            color: Color(0xFF94A3B8),
          ),
          SizedBox(height: 10),
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

class _MessageState extends StatelessWidget {
  const _MessageState({
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
              radius: 38,
              backgroundColor: const Color(0xFFDBEAFE),
              child: Icon(
                icon,
                size: 38,
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
            if (onPressed != null && buttonLabel != null) ...[
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
