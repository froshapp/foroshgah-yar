class Product {
  final int id;
  final String name;
  final String slug;
  final String type;
  final String status;
  final String? sku;
  final double price;
  final double regularPrice;
  final double? salePrice;
  final bool onSale;
  final String stockStatus;
  final int? stockQuantity;
  final bool manageStock;
  final String? image;
  final String? permalink;
  final String? description;
  final String? shortDescription;
  final List<int>? categories;
  final String? dateCreated;
  final int? totalSales;
  final List<String>? gallery;

  Product({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
    required this.status,
    this.sku,
    required this.price,
    required this.regularPrice,
    this.salePrice,
    required this.onSale,
    required this.stockStatus,
    this.stockQuantity,
    required this.manageStock,
    this.image,
    this.permalink,
    this.description,
    this.shortDescription,
    this.categories,
    this.dateCreated,
    this.totalSales,
    this.gallery,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      type: json['type'] ?? 'simple',
      status: json['status'] ?? 'publish',
      sku: json['sku'],
      price: (json['price'] ?? 0).toDouble(),
      regularPrice: (json['regular_price'] ?? 0).toDouble(),
      salePrice: json['sale_price'] != null ? (json['sale_price'] as num).toDouble() : null,
      onSale: json['on_sale'] ?? false,
      stockStatus: json['stock_status'] ?? 'instock',
      stockQuantity: json['stock_quantity'],
      manageStock: json['manage_stock'] ?? false,
      image: json['image'],
      permalink: json['permalink'],
      description: json['description'],
      shortDescription: json['short_description'],
      categories: json['categories'] != null ? List<int>.from(json['categories']) : null,
      dateCreated: json['date_created'],
      totalSales: json['total_sales'],
      gallery: json['gallery'] != null ? List<String>.from(json['gallery']) : null,
    );
  }

  String get formattedPrice {
    final p = price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$p تومان';
  }

  String get stockLabel {
    if (!manageStock) {
      return stockStatus == 'instock' ? 'موجود' : 'ناموجود';
    }
    if (stockQuantity == null || stockQuantity! <= 0) return 'ناموجود';
    if (stockQuantity! <= 5) return 'کم‌موجود ($stockQuantity)';
    return 'موجود ($stockQuantity)';
  }

  bool get isLowStock => manageStock && stockQuantity != null && stockQuantity! <= 5;
}
