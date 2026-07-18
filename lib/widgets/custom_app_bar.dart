import 'package:final032/services/session_service.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  static const _titles = {
    '/book': 'Books',
    '/categories': 'Categories',
    '/about': 'About Us',
    '/favorite': 'Favorites',
    '/contact': 'Contact Us',
    '/profile': 'Profile',
    '/admin': 'Admin Dashboard',
  };

  void _open(BuildContext context, String route) {
    if (ModalRoute.of(context)?.settings.name == route) return;
    Navigator.pushReplacementNamed(context, route);
  }

  Future<void> _logout(BuildContext context) async {
    await SessionService.clear();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/index', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context)?.settings.name;
    final title = _titles[route] ?? 'BookBuddies';
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 72,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_stories_rounded, color: Color(0xFF60A5FA)),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
      actions: [
        if (isWide) ...[
          _NavButton(label: 'Home', onTap: () => _open(context, '/home')),
          _NavButton(label: 'Books', onTap: () => _open(context, '/book')),
          _NavButton(
            label: 'Categories',
            onTap: () => _open(context, '/categories'),
          ),
          _NavButton(label: 'About', onTap: () => _open(context, '/about')),
        ],
        FutureBuilder<bool>(
          future: SessionService.isAdmin(),
          builder: (context, snapshot) {
            final isAdmin = snapshot.data ?? false;

            return PopupMenuButton<String>(
              tooltip: 'Menu',
              icon: const Icon(Icons.menu_rounded),
              onSelected: (value) {
                if (value == 'logout') {
                  _logout(context);
                } else {
                  _open(context, value);
                }
              },
              itemBuilder: (_) => [
                if (!isWide) ...[
                  const PopupMenuItem(value: '/home', child: Text('Home')),
                  const PopupMenuItem(value: '/book', child: Text('Books')),
                  const PopupMenuItem(
                    value: '/categories',
                    child: Text('Categories'),
                  ),
                ],
                const PopupMenuItem(
                  value: '/favorite',
                  child: ListTile(
                    leading: Icon(Icons.favorite_outline),
                    title: Text('Favorites'),
                  ),
                ),
                const PopupMenuItem(
                  value: '/profile',
                  child: ListTile(
                    leading: Icon(Icons.person_outline),
                    title: Text('Profile'),
                  ),
                ),
                if (isAdmin)
                  const PopupMenuItem(
                    value: '/admin',
                    child: ListTile(
                      leading: Icon(Icons.admin_panel_settings_outlined),
                      title: Text('Admin Dashboard'),
                    ),
                  ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red),
                    title: Text('Log out'),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(72);
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(foregroundColor: Colors.white),
      child: Text(label),
    );
  }
}
