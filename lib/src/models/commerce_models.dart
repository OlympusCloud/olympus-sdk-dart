/// Models for the Olympus Commerce service.
library;

/// An order in the commerce system.
class Order {
  const Order({
    required this.id,
    required this.status,
    this.items,
    this.source,
    this.tableId,
    this.customerId,
    this.subtotal,
    this.tax,
    this.total,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String status;
  final List<OrderItem>? items;
  final String? source;
  final String? tableId;
  final String? customerId;
  final int? subtotal;
  final int? tax;
  final int? total;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        status: json['status'] as String? ?? 'pending',
        items: (json['items'] as List<dynamic>?)
            ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        source: json['source'] as String?,
        tableId: json['table_id'] as String?,
        customerId: json['customer_id'] as String?,
        subtotal: json['subtotal'] as int?,
        tax: json['tax'] as int?,
        total: json['total'] as int?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'status': status,
        if (items != null) 'items': items!.map((e) => e.toJson()).toList(),
        if (source != null) 'source': source,
        if (tableId != null) 'table_id': tableId,
        if (customerId != null) 'customer_id': customerId,
        if (subtotal != null) 'subtotal': subtotal,
        if (tax != null) 'tax': tax,
        if (total != null) 'total': total,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };
}

/// A single line item within an order.
class OrderItem {
  const OrderItem({
    required this.catalogId,
    required this.qty,
    required this.price,
    this.id,
    this.name,
    this.modifiers,
    this.notes,
  });

  final String catalogId;
  final int qty;

  /// Price in cents.
  final int price;
  final String? id;
  final String? name;
  final List<OrderModifier>? modifiers;
  final String? notes;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        catalogId: json['catalog_id'] as String? ?? json['menu_item_id'] as String? ?? '',
        qty: json['qty'] as int? ?? json['quantity'] as int? ?? 1,
        price: json['price'] as int? ?? 0,
        id: json['id'] as String?,
        name: json['name'] as String?,
        modifiers: (json['modifiers'] as List<dynamic>?)
            ?.map((e) => OrderModifier.fromJson(e as Map<String, dynamic>))
            .toList(),
        notes: json['notes'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'catalog_id': catalogId,
        'qty': qty,
        'price': price,
        if (id != null) 'id': id,
        if (name != null) 'name': name,
        if (modifiers != null)
          'modifiers': modifiers!.map((e) => e.toJson()).toList(),
        if (notes != null) 'notes': notes,
      };
}

/// A modifier applied to an order item.
class OrderModifier {
  const OrderModifier({
    required this.id,
    required this.name,
    this.price,
  });

  final String id;
  final String name;
  final int? price;

  factory OrderModifier.fromJson(Map<String, dynamic> json) => OrderModifier(
        id: json['id'] as String,
        name: json['name'] as String,
        price: json['price'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (price != null) 'price': price,
      };
}

/// A catalog item (menu item, product, etc.).
class CatalogItem {
  const CatalogItem({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.category,
    this.categoryId,
    this.imageUrl,
    this.modifiers,
    this.available,
    this.tags = const [],
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;

  /// Price in cents.
  final int price;
  final String? description;
  final String? category;
  final String? categoryId;
  final String? imageUrl;
  final List<CatalogModifier>? modifiers;
  final bool? available;

  /// Tags for filtering (e.g., dietary: "vegetarian", "vegan", "gluten_free").
  final List<String> tags;

  /// Arbitrary metadata (e.g., calories, allergens).
  final Map<String, dynamic>? metadata;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Alias for [price] used by screens expecting `priceCents`.
  int get priceCents => price;

  factory CatalogItem.fromJson(Map<String, dynamic> json) => CatalogItem(
        id: json['id'] as String,
        name: json['name'] as String,
        price: json['price'] as int? ?? 0,
        description: json['description'] as String?,
        category: json['category'] as String?,
        categoryId: json['category_id'] as String?,
        imageUrl: json['image_url'] as String?,
        modifiers: (json['modifiers'] as List<dynamic>?)
            ?.map((e) => CatalogModifier.fromJson(e as Map<String, dynamic>))
            .toList(),
        available: json['available'] as bool?,
        tags: (json['tags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        metadata: json['metadata'] as Map<String, dynamic>?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        if (description != null) 'description': description,
        if (category != null) 'category': category,
        if (categoryId != null) 'category_id': categoryId,
        if (imageUrl != null) 'image_url': imageUrl,
        if (modifiers != null)
          'modifiers': modifiers!.map((e) => e.toJson()).toList(),
        if (available != null) 'available': available,
        if (tags.isNotEmpty) 'tags': tags,
        if (metadata != null) 'metadata': metadata,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };
}

/// A modifier definition within a catalog item.
class CatalogModifier {
  const CatalogModifier({
    required this.id,
    required this.name,
    this.price,
    this.required,
    this.options,
  });

  final String id;
  final String name;
  final int? price;
  final bool? required;
  final List<CatalogModifierOption>? options;

  factory CatalogModifier.fromJson(Map<String, dynamic> json) =>
      CatalogModifier(
        id: json['id'] as String,
        name: json['name'] as String,
        price: json['price'] as int?,
        required: json['required'] as bool?,
        options: (json['options'] as List<dynamic>?)
            ?.map(
                (e) => CatalogModifierOption.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (price != null) 'price': price,
        if (required != null) 'required': required,
        if (options != null)
          'options': options!.map((e) => e.toJson()).toList(),
      };
}

/// An individual option within a catalog modifier group.
class CatalogModifierOption {
  const CatalogModifierOption({
    required this.id,
    required this.name,
    this.price,
  });

  final String id;
  final String name;
  final int? price;

  factory CatalogModifierOption.fromJson(Map<String, dynamic> json) =>
      CatalogModifierOption(
        id: json['id'] as String,
        name: json['name'] as String,
        price: json['price'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (price != null) 'price': price,
      };
}
