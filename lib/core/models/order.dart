class Order {
  final int id;
  final String number;
  final String status;
  final String statusLabel;
  final String dateCreated;
  final String? dateCreatedJalali;
  final double total;
  final String currency;
  final String? paymentMethod;
  final OrderCustomer customer;
  final int itemCount;
  final List<OrderItem>? lineItems;
  final double? shippingTotal;
  final double? discountTotal;
  final Map<String, dynamic>? billing;
  final Map<String, dynamic>? shipping;
  final String? customerNote;
  final List<OrderNote>? notes;

  Order({
    required this.id,
    required this.number,
    required this.status,
    required this.statusLabel,
    required this.dateCreated,
    this.dateCreatedJalali,
    required this.total,
    required this.currency,
    this.paymentMethod,
    required this.customer,
    required this.itemCount,
    this.lineItems,
    this.shippingTotal,
    this.discountTotal,
    this.billing,
    this.shipping,
    this.customerNote,
    this.notes,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] ?? 0,
      number: json['number']?.toString() ?? '',
      status: json['status'] ?? '',
      statusLabel: json['status_label'] ?? json['status'] ?? '',
      dateCreated: json['date_created'] ?? '',
      dateCreatedJalali: json['date_created_jalali'],
      total: (json['total'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'IRT',
      paymentMethod: json['payment_method'],
      customer: OrderCustomer.fromJson(json['customer'] ?? {}),
      itemCount: json['item_count'] ?? 0,
      lineItems: json['line_items'] != null
          ? (json['line_items'] as List).map((e) => OrderItem.fromJson(e)).toList()
          : null,
      shippingTotal: json['shipping_total']?.toDouble(),
      discountTotal: json['discount_total']?.toDouble(),
      billing: json['billing'],
      shipping: json['shipping'],
      customerNote: json['customer_note'],
      notes: json['notes'] != null
          ? (json['notes'] as List).map((e) => OrderNote.fromJson(e)).toList()
          : null,
    );
  }

  String get formattedTotal {
    final t = total.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return '$t تومان';
  }

  ColorStatus get statusColor {
    switch (status) {
      case 'completed':
        return ColorStatus.success;
      case 'processing':
        return ColorStatus.info;
      case 'on-hold':
        return ColorStatus.warning;
      case 'pending':
        return ColorStatus.warning;
      case 'cancelled':
      case 'failed':
      case 'refunded':
        return ColorStatus.error;
      default:
        return ColorStatus.neutral;
    }
  }
}

enum ColorStatus { success, info, warning, error, neutral }

class OrderCustomer {
  final int id;
  final String name;
  final String phone;
  final String email;

  OrderCustomer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
  });

  factory OrderCustomer.fromJson(Map<String, dynamic> json) {
    return OrderCustomer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

class OrderItem {
  final int id;
  final int productId;
  final String name;
  final int quantity;
  final double total;
  final String? sku;
  final String? image;

  OrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.total,
    this.sku,
    this.image,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      productId: json['product_id'] ?? 0,
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      total: (json['total'] ?? 0).toDouble(),
      sku: json['sku'],
      image: json['image'],
    );
  }
}

class OrderNote {
  final int id;
  final String content;
  final String date;
  final String? author;

  OrderNote({
    required this.id,
    required this.content,
    required this.date,
    this.author,
  });

  factory OrderNote.fromJson(Map<String, dynamic> json) {
    return OrderNote(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      date: json['date'] ?? '',
      author: json['author'],
    );
  }
}
