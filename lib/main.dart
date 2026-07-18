import 'package:flutter/material.dart';
import 'package:final032/login_register/login.dart';
import 'package:final032/login_register/register.dart';
import 'package:final032/login_register/index.dart';
import 'package:final032/screens/home.dart';
import 'package:final032/screens/book.dart';
import 'package:final032/screens/categories.dart';
import 'package:final032/screens/about.dart';
import 'package:final032/screens/profile.dart';
import 'package:final032/screens/contact.dart';
import 'package:final032/screens/favorite.dart';
import 'package:final032/screens/detail.dart';
import 'package:final032/screens/edit_book.dart';
import 'package:final032/screens/admin_dashboard.dart';
import 'package:final032/models/book.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F172A),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
          ),
        ),
      ),
      initialRoute: '/index',
      routes: {
        '/index': (context) => const IndexPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/book': (context) => const BookPage(),
        '/categories': (context) => const BookCategoryPage(),
        '/about': (context) => const AboutUsPage(),
        '/profile': (context) => const ProfilePage(),
        '/contact': (context) => const ContactPage(),
        '/favorite': (context) => const FavoritePage(),
        '/admin': (context) => const AdminDashboardPage(),

        // ===== Edit Book =====
        '/edit': (context) {
          final book = ModalRoute.of(context)!.settings.arguments as Book;
          return EditBookScreen(book: book);
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder: (context) => BookDetailPage(
              book: args['book'] as Book,
              userId: args['userId'] as int,
            ),
          );
        }

        return null;
      },
    );
  }
}
