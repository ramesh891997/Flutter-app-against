import 'package:flutter_demo_app/features/products/domain/entities/paginated_products.dart';
import 'package:flutter_demo_app/features/products/domain/entities/product.dart';

/// Data transfer model for a single product.
class ProductModel {
  const ProductModel({
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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPercentage:
          (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] as int? ?? 0,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          const [],
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      thumbnail: json['thumbnail'] as String? ?? '',
      brand: json['brand'] as String?,
      sku: json['sku'] as String?,
      warrantyInformation: json['warrantyInformation'] as String?,
      shippingInformation: json['shippingInformation'] as String?,
      availabilityStatus: json['availabilityStatus'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'price': price,
      'discountPercentage': discountPercentage,
      'rating': rating,
      'stock': stock,
      'tags': tags,
      'images': images,
      'thumbnail': thumbnail,
      if (brand != null) 'brand': brand,
      if (sku != null) 'sku': sku,
      if (warrantyInformation != null)
        'warrantyInformation': warrantyInformation,
      if (shippingInformation != null)
        'shippingInformation': shippingInformation,
      if (availabilityStatus != null) 'availabilityStatus': availabilityStatus,
    };
  }

  Product toEntity() {
    return Product(
      id: id,
      title: title,
      description: description,
      category: category,
      price: price,
      discountPercentage: discountPercentage,
      rating: rating,
      stock: stock,
      tags: tags,
      images: images,
      thumbnail: thumbnail,
      brand: brand,
      sku: sku,
      warrantyInformation: warrantyInformation,
      shippingInformation: shippingInformation,
      availabilityStatus: availabilityStatus,
    );
  }
}

/// Data transfer model for the paginated products list response.
class PaginatedProductsResponseModel {
  const PaginatedProductsResponseModel({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  final List<ProductModel> products;
  final int total;
  final int skip;
  final int limit;

  factory PaginatedProductsResponseModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['products'] as List<dynamic>? ?? const [];
    final products = rawList
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();

    return PaginatedProductsResponseModel(
      products: products,
      total: json['total'] as int? ?? 0,
      skip: json['skip'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
    );
  }

  PaginatedProducts toEntity() {
    return PaginatedProducts(
      products: products.map((m) => m.toEntity()).toList(),
      total: total,
      skip: skip,
      limit: limit,
    );
  }
}
