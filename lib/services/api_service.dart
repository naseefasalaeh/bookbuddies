import 'dart:async';
import 'dart:convert';

import 'package:final032/models/book.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost/final032/api';

  // ==========================
  // Register
  // ==========================
  Future<Map<String, dynamic>> register(
      String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'username': username,
          'email': email,
          'password': password,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {'message': 'Server Error'};
    } catch (e) {
      return {'message': e.toString()};
    }
  }

  // ==========================
  // Login
  // ==========================
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'email': email,
          'password': password,
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {'message': 'Invalid email or password'};
    } catch (e) {
      return {'message': e.toString()};
    }
  }

  // ==========================
  // Get All Books
  // ==========================
  Future<List<Book>> fetchBooks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/getall_book.php'),
      );

      if (response.statusCode != 200) {
        throw Exception("HTTP ${response.statusCode}");
      }

      final body = utf8.decode(response.bodyBytes);

      final List data = jsonDecode(body);

      return data.map((e) => Book.fromJson(e)).toList();
    } catch (_) {
      rethrow;
    }
  }

  // ==========================
  // Get Categories
  // ==========================
  Future<List<dynamic>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_category.php'),
      );

      if (response.statusCode != 200) {
        throw Exception("HTTP ${response.statusCode}");
      }

      final body = utf8.decode(response.bodyBytes);

      return jsonDecode(body);
    } catch (_) {
      rethrow;
    }
  }

  Future<bool> addCategory(String name) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_category.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );
    return response.statusCode == 200;
  }

  Future<bool> updateCategory(int id, String name) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update_category.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'name': name}),
    );
    return response.statusCode == 200;
  }

  Future<Map<String, dynamic>> deleteCategory(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete_category.php?id=$id'),
    );

    try {
      final data = Map<String, dynamic>.from(jsonDecode(response.body));
      data['success'] = response.statusCode == 200;
      return data;
    } catch (_) {
      return {'success': false, 'message': 'Unable to delete category'};
    }
  }

  Future<List<Map<String, dynamic>>> fetchUsers(int adminId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_users.php'),
      body: {'admin_id': adminId.toString()},
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to load users');
    }

    final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
    return data.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  Future<Map<String, dynamic>> updateUserRole({
    required int adminId,
    required int userId,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update_user_role.php'),
      body: {
        'admin_id': adminId.toString(),
        'user_id': userId.toString(),
        'role': role,
      },
    );

    final data = Map<String, dynamic>.from(jsonDecode(response.body));
    data['success'] = response.statusCode == 200 && data['status'] == 'success';
    return data;
  }

  // ==========================
  // Favorite
  // ==========================
  Future<bool> addToFavorite(
    String userId,
    String bookId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_favorite.php'),
      body: {
        "user_id": userId,
        "book_id": bookId,
      },
    );

    if (response.statusCode != 200) {
      return false;
    }

    try {
      final result = jsonDecode(response.body);

      return result["status"] == "success";
    } catch (_) {
      return false;
    }
  }

  Future<void> removeFavorite(
    int userId,
    int bookId,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/remove_favorite.php'),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: {
        "user_id": userId.toString(),
        "book_id": bookId.toString(),
      },
    );

  }

  Future<bool> isFavorite(
    int userId,
    int bookId,
  ) async {
    final books = await fetchFavoriteBooks(userId.toString());

    return books.any((book) => book.id == bookId);
  }

  Future<List<Book>> fetchFavoriteBooks(
    String userId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/get_favorite.php'),
        body: {
          'user_id': userId,
        },
      );

      if (response.statusCode != 200) {
        return [];
      }

      final body = utf8.decode(response.bodyBytes);

      final List data = jsonDecode(body);

      return data.map((e) => Book.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  // ==========================
  // Add Book
  // ==========================
  Future<bool> addBook(Book book) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add_book.php'),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "title": book.title,
        "author": book.author,
        "publisher": book.publisher,
        "price": book.price,
        "description": book.description,
        "imageUrl": book.imageUrl,
        "category_id": book.category,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  // ==========================
  // Update Book
  // ==========================
  Future<bool> updateBook(Book book) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update_book.php'),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "id": book.id,
        "title": book.title,
        "author": book.author,
        "publisher": book.publisher,
        "price": book.price,
        "description": book.description,
        "imageUrl": book.imageUrl,
        "category_id": book.category,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }

  // ==========================
  // Delete Book
  // ==========================
  Future<bool> deleteBook(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/delete_book.php?id=$id'),
    );

    return response.statusCode == 200 || response.statusCode == 204;
  }
}
