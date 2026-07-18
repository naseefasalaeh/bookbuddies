import 'package:final032/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                Text('Contact us', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                const Text('หากมีคำถามหรือข้อเสนอแนะ สามารถติดต่อเราได้ผ่านช่องทางด้านล่าง', textAlign: TextAlign.center, style: TextStyle(fontSize: 17, color: Color(0xFF64748B))),
                const SizedBox(height: 28),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(28),
                    child: Column(
                      children: [
                        _ContactRow(icon: Icons.phone_outlined, label: 'Phone', value: '062-9812-952'),
                        Divider(height: 32),
                        _ContactRow(icon: Icons.email_outlined, label: 'Email', value: 'info@bookbuddies.com'),
                        Divider(height: 32),
                        _ContactRow(icon: Icons.public_outlined, label: 'Facebook', value: 'BookBuddies'),
                        Divider(height: 32),
                        _ContactRow(icon: Icons.location_on_outlined, label: 'Address', value: '123 Book Street, Thailand'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(children: [CircleAvatar(backgroundColor: const Color(0xFFDBEAFE), child: Icon(icon, color: const Color(0xFF2563EB))), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Color(0xFF64748B))), const SizedBox(height: 3), Text(value, style: const TextStyle(fontWeight: FontWeight.w700))]))]);
  }
}
