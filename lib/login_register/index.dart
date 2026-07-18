import 'package:flutter/material.dart';

class IndexPage extends StatelessWidget {
  const IndexPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://c1.wallpaperflare.com/preview/127/366/443/library-book-bookshelf-read.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0xFF0F172A)),
          ),
          const ColoredBox(color: Color(0x990F172A)),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
                  decoration: BoxDecoration(
                    color: const Color(0xF2FFFFFF),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        radius: 34,
                        backgroundColor: Color(0xFFDBEAFE),
                        child: Icon(Icons.auto_stories_rounded, size: 38, color: Color(0xFF2563EB)),
                      ),
                      const SizedBox(height: 22),
                      Text('Welcome to BookBuddies', textAlign: TextAlign.center, style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                      const SizedBox(height: 14),
                      const Text('Discover books, explore categories, and keep your own collection of favorites.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18, height: 1.6, color: Color(0xFF64748B))),
                      const SizedBox(height: 32),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton(onPressed: () => Navigator.pushNamed(context, '/login'), style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16)), child: const Text('Log in')),
                          OutlinedButton(onPressed: () => Navigator.pushNamed(context, '/register'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16)), child: const Text('Create account')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
