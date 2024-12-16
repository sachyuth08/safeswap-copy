//product.dart

import 'package:hive/hive.dart';
// This is required for Hive adapter generation

@HiveType(typeId: 0)
class Product {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  double price;

  @HiveField(4)
  String? imageUrl;

  @HiveField(5)
  DateTime? createdAt;

  @HiveField(6)
  int duration;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
    this.createdAt,
    required this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'created_at': createdAt?.toIso8601String(),
      'duration': duration,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price:
          json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      imageUrl: json['image_url'], // Correct field mapping
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      duration:
          json['duration'] != null ? int.parse(json['duration'].toString()) : 0,
    );
  }
}
