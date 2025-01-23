class InventoryModel {
  final String? id;
  final String? title;
  final String? description;
  final double? price;
  final int? quantity;

  InventoryModel({
    this.id = '',
    this.title = '',
    this.description = '',
    this.price = 0.0,
    this.quantity = 0,
  });

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'],
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'quantity': quantity,
    };
  }
}
