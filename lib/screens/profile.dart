import 'package:final032/services/session_service.dart';
import 'package:final032/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await SessionService.clear();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/index', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: SessionService.getUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('ไม่พบข้อมูลผู้ใช้'));
          }

          final username = user['username']?.toString() ?? 'User';
          final email = user['email']?.toString() ?? '-';
          final role = user['role']?.toString() ?? 'user';

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text(username.isEmpty ? 'U' : username[0].toUpperCase(), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800)),
                        ),
                        const SizedBox(height: 18),
                        Text(username, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Text(email, style: const TextStyle(color: Color(0xFF64748B))),
                        const SizedBox(height: 12),
                        Chip(avatar: const Icon(Icons.verified_user_outlined, size: 18), label: Text(role.toUpperCase())),
                        const SizedBox(height: 28),
                        const Divider(),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _logout(context),
                            icon: const Icon(Icons.logout),
                            label: const Text('Log out'),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 16)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
