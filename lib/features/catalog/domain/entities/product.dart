class Product {
  final int id;
  final String title;
  final double price;
  final String? thumbnail;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    this.thumbnail,
    required this.updatedAt,
  });

  factory Product.fromDummyJson(Map<String, dynamic> json) => Product(
        id: (json['id'] as num).toInt(),
        title: (json['title'] ?? '').toString(),
        price: (json['price'] as num).toDouble(),
        thumbnail: json['thumbnail']?.toString(),
        updatedAt: DateTime.now(),
      );

  factory Product.fromMap(Map<String, Object?> map) => Product(
        id: (map['id'] as num).toInt(),
        title: (map['title'] as String?) ?? '',
        price: (map['price'] as num).toDouble(),
        thumbnail: map['thumbnail'] as String?,
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'price': price,
        'thumbnail': thumbnail,
        'updatedAt': updatedAt.toIso8601String(),
      };
}
