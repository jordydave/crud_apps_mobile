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
    var fields = json['fields'];
    return InventoryModel(
      id: json['id'],
      title: fields['Title'],
      description: fields['Description'],
      price: (fields['Price'] ?? 0).toDouble(),
      quantity: fields['Quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fields': {
        'Title': title,
        'Description': description,
        'Price': price,
        'Quantity': quantity,
      },
    };
  }
}
