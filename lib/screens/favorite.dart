import 'package:final032/models/book.dart';
import 'package:final032/services/api_service.dart';
import 'package:final032/services/session_service.dart';
import 'package:final032/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final ApiService _api = ApiService();

  List<Book> _favoriteBooks = [];

  int? _userId;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final userId = await SessionService.getUserId();

    if (!mounted) return;

    if (userId == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final books = await _api.fetchFavoriteBooks(
        userId.toString(),
      );

      if (!mounted) return;

      setState(() {
        _userId = userId;
        _favoriteBooks = books;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'ไม่สามารถโหลดรายการโปรดได้';
      });
    }
  }

  Future<void> _removeFavorite(Book book) async {
    final userId = _userId;

    if (userId == null) return;

    final oldIndex = _favoriteBooks.indexWhere(
      (item) => item.id == book.id,
    );

    setState(() {
      _favoriteBooks.removeWhere(
        (item) => item.id == book.id,
      );
    });

    try {
      await _api.removeFavorite(userId, book.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'นำ “${book.title}” ออกจากรายการโปรดแล้ว',
          ),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              _restoreFavorite(book, oldIndex);
            },
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        final insertIndex =
            oldIndex >= 0 && oldIndex <= _favoriteBooks.length ? oldIndex : 0;

        _favoriteBooks.insert(insertIndex, book);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ไม่สามารถลบรายการโปรดได้'),
        ),
      );
    }
  }

  Future<void> _restoreFavorite(
    Book book,
    int oldIndex,
  ) async {
    final userId = _userId;

    if (userId == null) return;

    final success = await _api.addToFavorite(
      userId.toString(),
      book.id.toString(),
    );

    if (!mounted || !success) return;

    setState(() {
      final alreadyExists = _favoriteBooks.any(
        (item) => item.id == book.id,
      );

      if (alreadyExists) return;

      final insertIndex =
          oldIndex >= 0 && oldIndex <= _favoriteBooks.length ? oldIndex : 0;

      _favoriteBooks.insert(insertIndex, book);
    });
  }

  void _openDetail(Book book) {
    final userId = _userId;

    if (userId == null) return;

    Navigator.pushNamed(
      context,
      '/detail',
      arguments: {
        'book': book,
        'userId': userId,
      },
    );
  }

  int _getColumnCount(double width) {
    if (width >= 1500) return 4;
    if (width >= 1050) return 3;
    if (width >= 700) return 2;

    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(context),
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
                child: _FavoriteState(
                  icon: Icons.cloud_off_outlined,
                  title: 'โหลดข้อมูลไม่สำเร็จ',
                  message: _errorMessage!,
                  buttonLabel: 'ลองอีกครั้ง',
                  onPressed: _loadFavorites,
                ),
              )
            else if (_favoriteBooks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _FavoriteState(
                  icon: Icons.favorite_border_rounded,
                  title: 'ยังไม่มีหนังสือโปรด',
                  message: 'เลือกหนังสือที่คุณชอบ แล้วกดเพิ่มไว้ในรายการโปรด',
                  buttonLabel: 'Explore books',
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      '/book',
                    );
                  },
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  30,
                  0,
                  30,
                  48,
                ),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final columns = _getColumnCount(
                      constraints.crossAxisExtent,
                    );

                    return SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                        mainAxisExtent: 230,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final book = _favoriteBooks[index];

                          return _FavoriteBookCard(
                            book: book,
                            onDetail: () {
                              _openDetail(book);
                            },
                            onRemove: () {
                              _removeFavorite(book);
                            },
                          );
                        },
                        childCount: _favoriteBooks.length,
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        30,
        38,
        30,
        28,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Favorites',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_favoriteBooks.length} saved books',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          if (_favoriteBooks.isNotEmpty)
            FilledButton.tonalIcon(
              onPressed: () {
                Navigator.pushReplacementNamed(
                  context,
                  '/book',
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add more'),
            ),
        ],
      ),
    );
  }
}

class _FavoriteBookCard extends StatelessWidget {
  const _FavoriteBookCard({
    required this.book,
    required this.onDetail,
    required this.onRemove,
  });

  final Book book;
  final VoidCallback onDetail;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onDetail,
        child: Row(
          children: [
            SizedBox(
              width: 135,
              height: double.infinity,
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
                  return const ColoredBox(
                    color: Color(0xFFF1F5F9),
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 42,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            book.title,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              height: 1.35,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Remove from favorites',
                          onPressed: onRemove,
                          icon: const Icon(
                            Icons.favorite_rounded,
                            color: Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const Spacer(),
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
                        FilledButton.tonal(
                          onPressed: onDetail,
                          child: const Text('Details'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteState extends StatelessWidget {
  const _FavoriteState({
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
              radius: 42,
              backgroundColor: const Color(0xFFDBEAFE),
              child: Icon(
                icon,
                size: 42,
                color: const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
              ),
            ),
            if (onPressed != null && buttonLabel != null) ...[
              const SizedBox(height: 20),
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
