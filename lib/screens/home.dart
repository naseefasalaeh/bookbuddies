import 'package:final032/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  bool _showBackToTop = false;

  static const _libraryImages = [
    _LibraryImage(
      imageUrl:
          'https://static01.nyt.com/images/2017/05/11/t-magazine/bookstore-slide-2MCD/bookstore-slide-2MCD-superJumbo.jpg',
      title: 'Discover',
      subtitle: 'ค้นพบหนังสือใหม่',
      icon: Icons.search_rounded,
    ),
    _LibraryImage(
      imageUrl:
          'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=1200',
      title: 'Read',
      subtitle: 'เริ่มต้นการอ่าน',
      icon: Icons.menu_book_rounded,
    ),
    _LibraryImage(
      imageUrl: 'https://www.thekommon.co/pyramid/2023/07/4-4-1160x773.jpg',
      title: 'Grow',
      subtitle: 'เติบโตจากทุกเรื่องราว',
      icon: Icons.auto_awesome_rounded,
    ),
  ];

  static const _categories = [
    _CategoryItem(
      title: 'Computer',
      subtitle: 'Programming & Technology',
      icon: Icons.computer_rounded,
      color: Color(0xFF2563EB),
      backgroundColor: Color(0xFFDBEAFE),
    ),
    _CategoryItem(
      title: 'English',
      subtitle: 'Language & Communication',
      icon: Icons.translate_rounded,
      color: Color(0xFF7C3AED),
      backgroundColor: Color(0xFFEDE9FE),
    ),
    _CategoryItem(
      title: 'Finance',
      subtitle: 'Money & Investment',
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF059669),
      backgroundColor: Color(0xFFD1FAE5),
    ),
    _CategoryItem(
      title: 'Self-development',
      subtitle: 'Mindset & Personal Growth',
      icon: Icons.psychology_rounded,
      color: Color(0xFFEA580C),
      backgroundColor: Color(0xFFFFEDD5),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    final shouldShow = _scrollController.offset > 500;

    if (shouldShow == _showBackToTop) return;

    setState(() {
      _showBackToTop = shouldShow;
    });
  }

  Future<void> _scrollToTop() async {
    await _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
  }

  void _openBooks() {
    Navigator.pushNamed(context, '/book');
  }

  void _openCategories() {
    Navigator.pushNamed(context, '/categories');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              tooltip: 'Back to top',
              onPressed: _scrollToTop,
              child: const Icon(Icons.keyboard_arrow_up_rounded),
            )
          : null,
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Column(
              children: [
                _buildHero(context),
                const SizedBox(height: 48),
                _buildLibrarySection(context),
                const SizedBox(height: 72),
                _buildCategorySection(context),
                const SizedBox(height: 72),
                _buildBenefitsSection(context),
                const SizedBox(height: 72),
                _buildCallToAction(context),
                const SizedBox(height: 56),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 32,
        vertical: 70,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A0F172A),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 38,
            backgroundColor: Color(0xFF1E293B),
            child: Icon(
              Icons.auto_stories_rounded,
              size: 42,
              color: Color(0xFF60A5FA),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Find your next great read',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: const Text(
              'สำรวจหนังสือหลากหลายหมวดหมู่ '
              'เก็บเล่มที่ชอบไว้ในรายการโปรด '
              'และเริ่มต้นการอ่านในแบบของคุณ',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFCBD5E1),
                fontSize: 18,
                height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 30),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: _openBooks,
                icon: const Icon(Icons.explore_outlined),
                label: const Text('Explore books'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 17,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: _openCategories,
                icon: const Icon(Icons.category_outlined),
                label: const Text('View categories'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(
                    color: Color(0xFF475569),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 17,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLibrarySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'A space made for readers',
          subtitle: 'Every book has something new waiting for you.',
          actionLabel: null,
          onAction: null,
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth < 720
                ? constraints.maxWidth
                : (constraints.maxWidth - 32) / 3;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _libraryImages.map((item) {
                return SizedBox(
                  width: cardWidth,
                  height: 250,
                  child: _LibraryImageCard(item: item),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Browse by category',
          subtitle: 'เลือกดูหนังสือตามหมวดหมู่ที่คุณสนใจ',
          actionLabel: 'View all',
          onAction: _openCategories,
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            double cardWidth;

            if (constraints.maxWidth >= 950) {
              cardWidth = (constraints.maxWidth - 48) / 4;
            } else if (constraints.maxWidth >= 600) {
              cardWidth = (constraints.maxWidth - 16) / 2;
            } else {
              cardWidth = constraints.maxWidth;
            }

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _categories.map((category) {
                return SizedBox(
                  width: cardWidth,
                  child: _CategoryCard(
                    category: category,
                    onTap: _openCategories,
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBenefitsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(
          title: 'Why readers choose us',
          subtitle: 'ทุกอย่างที่คุณต้องการสำหรับการค้นหาหนังสือเล่มถัดไป',
          actionLabel: null,
          onAction: null,
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth < 760
                ? constraints.maxWidth
                : (constraints.maxWidth - 32) / 3;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: const _BenefitCard(
                    number: '01',
                    icon: Icons.travel_explore_rounded,
                    title: 'Explore curated books',
                    description:
                        'ค้นหาหนังสือจากรายการที่จัดไว้อย่างเป็นระเบียบและเข้าถึงง่าย',
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: const _BenefitCard(
                    number: '02',
                    icon: Icons.favorite_rounded,
                    title: 'Save your favorites',
                    description:
                        'บันทึกหนังสือที่สนใจไว้ในบัญชีส่วนตัวและกลับมาดูได้ทุกเวลา',
                  ),
                ),
                SizedBox(
                  width: cardWidth,
                  child: const _BenefitCard(
                    number: '03',
                    icon: Icons.category_rounded,
                    title: 'Browse by categories',
                    description:
                        'เลือกดูหนังสือตามหมวดหมู่เพื่อค้นหาเรื่องที่ตรงกับความสนใจ',
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildCallToAction(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
        vertical: 52,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1D4ED8),
            Color(0xFF2563EB),
            Color(0xFF3B82F6),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.local_library_rounded,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 18),
          Text(
            'Ready to find your next book?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Start exploring our book collection today.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFDBEAFE),
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _openBooks,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Browse all books'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1D4ED8),
              padding: const EdgeInsets.symmetric(
                horizontal: 26,
                vertical: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 28,
      ),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: const Wrap(
        alignment: WrapAlignment.spaceBetween,
        runAlignment: WrapAlignment.center,
        spacing: 20,
        runSpacing: 12,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_stories_rounded,
                color: Color(0xFF2563EB),
              ),
              SizedBox(width: 9),
              Text(
                'BookBuddies',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Text(
            '© 2026 BookBuddies. Made for readers.',
            style: TextStyle(
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 7),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          TextButton.icon(
            onPressed: onAction,
            label: Text(actionLabel!),
            icon: const Icon(
              Icons.arrow_forward_rounded,
              size: 18,
            ),
          ),
      ],
    );
  }
}

class _LibraryImageCard extends StatefulWidget {
  const _LibraryImageCard({
    required this.item,
  });

  final _LibraryImage item;

  @override
  State<_LibraryImageCard> createState() => _LibraryImageCardState();
}

class _LibraryImageCardState extends State<_LibraryImageCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: AnimatedScale(
        scale: _isHovered ? 1.025 : 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.item.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return const ColoredBox(
                    color: Color(0xFFE2E8F0),
                    child: Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  );
                },
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0xCC0F172A),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 18,
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xE6FFFFFF),
                      child: Icon(
                        widget.item.icon,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            widget.item.subtitle,
                            style: const TextStyle(
                              color: Color(0xFFCBD5E1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({
    required this.category,
    required this.onTap,
  });

  final _CategoryItem category;
  final VoidCallback onTap;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _isHovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(
          0,
          _isHovered ? -5 : 0,
          0,
        ),
        child: Card(
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: widget.category.backgroundColor,
                    child: Icon(
                      widget.category.icon,
                      color: widget.category.color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.category.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.description,
  });

  final String number;
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: const Color(0xFFDBEAFE),
                  child: Icon(
                    icon,
                    color: const Color(0xFF2563EB),
                  ),
                ),
                const Spacer(),
                Text(
                  number,
                  style: const TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 9),
            Text(
              description,
              style: const TextStyle(
                color: Color(0xFF64748B),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryImage {
  const _LibraryImage({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String imageUrl;
  final String title;
  final String subtitle;
  final IconData icon;
}

class _CategoryItem {
  const _CategoryItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
}
