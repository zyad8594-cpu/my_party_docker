import 'package:equatable/equatable.dart';

class Income extends Equatable {
  final int id;
  final int eventId;
  final double amount;
  final String? paymentMethod;
  final String paymentDate;
  final String? urlImage;
  final String? description;
  final String? createdAt;
  String? eventName;

  Income({
    required this.id,
    required this.eventId,
    required this.amount,
    required this.paymentDate,
    this.paymentMethod,
    this.urlImage,
    this.description,
    this.createdAt,
    this.eventName,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['income_id'] ?? json['id'] ?? 0,
      eventId: json['event_id'] ?? 0,
      amount: double.tryParse(json['amount'] ?? '0') ?? 0.0,
      paymentMethod: json['payment_method'],
      paymentDate: json['payment_date'] ?? '',
      urlImage: json['url_image'],
      description: json['description'],
      createdAt: json['created_at'],
      eventName: json['event_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_date': paymentDate,
      'url_image': urlImage,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [
        id,
        eventId,
        amount,
        paymentMethod,
        paymentDate,
        urlImage,
        description,
        createdAt,
        eventName,
      ];
}