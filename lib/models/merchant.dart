class Merchant {
  final String id;
  final String name;
  final String upiId;
  final String category;
  final bool isVerified;

  const Merchant({
    required this.id,
    required this.name,
    required this.upiId,
    this.category = 'Retail',
    this.isVerified = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'upiId': upiId,
    'category': category,
    'isVerified': isVerified,
  };

  factory Merchant.fromJson(Map<String, dynamic> json) => Merchant(
    id: json['id'] as String? ?? 'MERCH_DEFAULT',
    name: json['name'] as String? ?? 'Campus Store',
    upiId: json['upiId'] as String? ?? 'store@upi',
    category: json['category'] as String? ?? 'Retail',
    isVerified: json['isVerified'] as bool? ?? true,
  );
}
