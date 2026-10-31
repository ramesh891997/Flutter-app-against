/// Domain entity representing a product in the catalog.
class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.discountPercentage,
    required this.rating,
    required this.stock,
    required this.tags,
    required this.images,
    required this.thumbnail,
    this.brand,
    this.sku,
    this.warrantyInformation,
    this.shippingInformation,
    this.availabilityStatus,
  });

  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double discountPercentage;
  final double rating;
  final int stock;
  final List<String> tags;
  final List<String> images;
  final String thumbnail;
  final String? brand;
  final String? sku;
  final String? warrantyInformation;
  final String? shippingInformation;
  final String? availabilityStatus;

  /// Returns true if stock is greater than 0.
  bool get isInStock => stock > 0;

  /// Returns the primary hero image URL (thumbnail or first image).
  String get primaryImageUrl {
    if (thumbnail.isNotEmpty) return thumbnail;
    if (images.isNotEmpty) return images.first;
    return '';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
