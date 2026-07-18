import 'package:final032/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('About BookBuddies', style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                const Text('พื้นที่สำหรับค้นพบหนังสือใหม่จากหลากหลายหมวดหมู่ และจัดเก็บหนังสือที่คุณสนใจไว้ในบัญชีส่วนตัว', style: TextStyle(fontSize: 18, height: 1.7, color: Color(0xFF475569))),
                const SizedBox(height: 32),
                const _InfoCard(icon: Icons.flag_outlined, title: 'Our mission', text: 'ช่วยให้ทุกคนค้นหาหนังสือที่ตรงกับความสนใจได้ง่ายขึ้น ผ่านประสบการณ์ที่เรียบง่าย เป็นระเบียบ และใช้งานได้จากทุกอุปกรณ์'),
                const SizedBox(height: 16),
                const _InfoCard(icon: Icons.auto_awesome_outlined, title: 'What you can do', text: 'เลือกดูหนังสือจากรายการหรือหมวดหมู่ เปิดอ่านรายละเอียด และบันทึกหนังสือโปรดแยกตามบัญชีของคุณ'),
                const SizedBox(height: 16),
                const _InfoCard(icon: Icons.security_outlined, title: 'Managed with care', text: 'ผู้ดูแลระบบจัดการหนังสือ หมวดหมู่ และสิทธิ์ผู้ใช้งานจาก Dashboard โดยแยกจากหน้าสำหรับผู้อ่านอย่างชัดเจน'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(backgroundColor: const Color(0xFFDBEAFE), child: Icon(icon, color: const Color(0xFF2563EB))),
            const SizedBox(width: 18),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)), const SizedBox(height: 8), Text(text, style: const TextStyle(height: 1.6, color: Color(0xFF64748B)))])),
          ],
        ),
      ),
    );
  }
}
