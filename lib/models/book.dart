class Book {
  final int id;
  final String title;
  final String author;
  final String publisher;
  final String imageUrl;
  final double price;
  final String description;
  final String category;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.imageUrl,
    required this.price,
    required this.description,
    required this.category,
    int? categoryId,
  });

  // แปลงจาก JSON เป็น Object ของ Book
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      publisher: json['publisher']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      price: double.tryParse(json['price']?.toString() ?? '0.0') ?? 0.0,
      description: json['description']?.toString() ?? '',
      category: json['category_id']?.toString() ?? '',
    );
  }
}
