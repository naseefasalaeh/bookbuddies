import 'package:final032/models/book.dart';
import 'package:final032/services/api_service.dart';
import 'package:flutter/material.dart';

class BookDetailPage extends StatefulWidget {
  const BookDetailPage({super.key, required this.book, required this.userId});

  final Book book;
  final int userId;

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  final ApiService _api = ApiService();
  bool _isFavorite = false;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    final favorite = await _api.isFavorite(widget.userId, widget.book.id);
    if (!mounted) return;
    setState(() => _isFavorite = favorite);
  }

  Future<void> _toggleFavorite() async {
    if (_isUpdating) return;
    setState(() => _isUpdating = true);

    if (_isFavorite) {
      await _api.removeFavorite(widget.userId, widget.book.id);
      if (!mounted) return;
      setState(() => _isFavorite = false);
    } else {
      final success = await _api.addToFavorite(widget.userId.toString(), widget.book.id.toString());
      if (!mounted) return;
      if (success) setState(() => _isFavorite = true);
    }

    if (mounted) setState(() => _isUpdating = false);
  }

  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    return Scaffold(
      appBar: AppBar(title: const Text('Book details')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 720;
                  final cover = Image.network(
                    book.imageUrl,
                    width: compact ? double.infinity : 360,
                    height: compact ? 430 : 540,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Color(0xFFE2E8F0),
                      child: SizedBox(width: 360, height: 430, child: Icon(Icons.broken_image_outlined, size: 64)),
                    ),
                  );
                  final information = Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(book.title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        Text(book.author, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: const Color(0xFF64748B))),
                        const SizedBox(height: 22),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(label: Text('Publisher: ${book.publisher}')),
                            Chip(label: Text('Category: ${book.category}')),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text('\$${book.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF2563EB))),
                        const SizedBox(height: 28),
                        Text('Description', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        Text(book.description, style: const TextStyle(height: 1.7, color: Color(0xFF475569))),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _isUpdating ? null : _toggleFavorite,
                            icon: _isUpdating
                                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                : Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
                            label: Text(_isFavorite ? 'Remove from favorites' : 'Add to favorites'),
                            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          ),
                        ),
                      ],
                    ),
                  );
                  return compact
                      ? Column(children: [cover, information])
                      : Row(crossAxisAlignment: CrossAxisAlignment.start, children: [cover, Expanded(child: information)]);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
