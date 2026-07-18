import 'package:final032/models/book.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Book.fromJson converts API values safely', () {
    final book = Book.fromJson({
      'id': '1',
      'title': 'Clean Code',
      'author': 'Robert C. Martin',
      'publisher': 'Prentice Hall',
      'imageUrl': 'https://example.com/book.jpg',
      'price': '10.50',
      'description': 'A software development book',
      'category_id': '2',
    });

    expect(book.id, 1);
    expect(book.title, 'Clean Code');
    expect(book.price, 10.5);
    expect(book.category, '2');
  });
}
