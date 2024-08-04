class Penalty {
  final String id;
  final String parkId;
  final double price;
  final String reason;

  Penalty(
      {required this.id,
      required this.parkId,
      required this.price,
      required this.reason});

  factory Penalty.fromMap(Map<String, dynamic> data, String id) {
    return Penalty(
      id: id,
      parkId: data['parkId'],
      price: data['price'] * 1.0,
      reason: data['reason'],
    );
  }
}
