class GearItem {
  final String id;
  final String name;
  final String category;
  final int pricePerDay;
  final String imageUrl;
  final String description;
  final Map<String, String> specifications;
  final int stock;
  final bool isAvailable;

  GearItem({
    required this.id,
    required this.name,
    required this.category,
    required this.pricePerDay,
    required this.imageUrl,
    required this.description,
    required this.specifications,
    this.stock = 5,
    this.isAvailable = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'pricePerDay': pricePerDay,
      'imageUrl': imageUrl,
      'description': description,
      'specifications': specifications,
      'stock': stock,
      'isAvailable': isAvailable,
    };
  }

  factory GearItem.fromMap(Map<String, dynamic> map, String docId) {
    Map<String, String> parsedSpecs = {};
    if (map['specifications'] != null) {
      if (map['specifications'] is Map) {
        (map['specifications'] as Map).forEach((key, value) {
          parsedSpecs[key.toString()] = value.toString();
        });
      }
    }

    return GearItem(
      id: docId,
      name: map['name'] ?? '',
      category: map['category'] ?? 'Lainnya',
      pricePerDay: (map['pricePerDay'] as num?)?.toInt() ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      specifications: parsedSpecs,
      stock: (map['stock'] as num?)?.toInt() ?? 5,
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  GearItem copyWith({
    String? id,
    String? name,
    String? category,
    int? pricePerDay,
    String? imageUrl,
    String? description,
    Map<String, String>? specifications,
    int? stock,
    bool? isAvailable,
  }) {
    return GearItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      specifications: specifications ?? this.specifications,
      stock: stock ?? this.stock,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
