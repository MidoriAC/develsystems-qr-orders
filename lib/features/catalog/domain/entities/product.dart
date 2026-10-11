import 'dart:convert';

/// Producto del catálogo
/// Campos mínimos persistidos siempre: id, title, price, updatedAt.
/// Campos enriquecidos (DummyJSON) para búsqueda por nombre/etiquetas y
/// pantalla de detalle; también persistidos para funcionar offline.
/// Estos `fromDummyJson`/`fromMap` son los mappers: no hay archivos
/// separados porque entidad == modelo (alcance acotado del examen).
class Product {
  final int id;
  final String title;
  final double price;
  final String? thumbnail;
  final DateTime updatedAt;
  final String? description;
  final String? category;
  final String? brand;
  final String? sku;
  final int? stock;
  final double? rating;
  final double? discountPercentage;
  final String? availabilityStatus;
  final List<String> tags;
  final List<String> images;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    this.thumbnail,
    required this.updatedAt,
    this.description,
    this.category,
    this.brand,
    this.sku,
    this.stock,
    this.rating,
    this.discountPercentage,
    this.availabilityStatus,
    this.tags = const [],
    this.images = const [],
  });

  static List<String> _strList(dynamic v) =>
      v is List ? v.map((e) => e.toString()).toList() : const [];

  static List<String> _decodeList(Object? v) {
    if (v == null) return const [];
    if (v is String) {
      try {
        return _strList(jsonDecode(v));
      } catch (_) {
        return const [];
      }
    }
    return _strList(v);
  }

  factory Product.fromDummyJson(Map<String, dynamic> json) => Product(
        id: (json['id'] as num).toInt(),
        title: (json['title'] ?? '').toString(),
        price: (json['price'] as num).toDouble(),
        thumbnail: json['thumbnail']?.toString(),
        updatedAt: DateTime.now(),
        description: json['description']?.toString(),
        category: json['category']?.toString(),
        brand: json['brand']?.toString(),
        sku: json['sku']?.toString(),
        stock: (json['stock'] as num?)?.toInt(),
        rating: (json['rating'] as num?)?.toDouble(),
        discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
        availabilityStatus: json['availabilityStatus']?.toString(),
        tags: _strList(json['tags']),
        images: _strList(json['images']),
      );

  factory Product.fromMap(Map<String, Object?> map) => Product(
        id: (map['id'] as num).toInt(),
        title: (map['title'] as String?) ?? '',
        price: (map['price'] as num).toDouble(),
        thumbnail: map['thumbnail'] as String?,
        updatedAt: DateTime.parse(map['updatedAt'] as String),
        description: map['description'] as String?,
        category: map['category'] as String?,
        brand: map['brand'] as String?,
        sku: map['sku'] as String?,
        stock: (map['stock'] as num?)?.toInt(),
        rating: (map['rating'] as num?)?.toDouble(),
        discountPercentage: (map['discountPercentage'] as num?)?.toDouble(),
        availabilityStatus: map['availabilityStatus'] as String?,
        tags: _decodeList(map['tags']),
        images: _decodeList(map['images']),
      );

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'price': price,
        'thumbnail': thumbnail,
        'updatedAt': updatedAt.toIso8601String(),
        'description': description,
        'category': category,
        'brand': brand,
        'sku': sku,
        'stock': stock,
        'rating': rating,
        'discountPercentage': discountPercentage,
        'availabilityStatus': availabilityStatus,
        'tags': jsonEncode(tags),
        'images': jsonEncode(images),
      };
}
