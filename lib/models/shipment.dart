import 'package:flutter/foundation.dart';

class Shipment {
  final String orderId;
  final String trackingNumber;
  final String shippingProvider;
  final String shippingStatus;
  final DateTime shippedDate;
  final DateTime updatedAt;

  Shipment({
    required this.orderId,
    required this.trackingNumber,
    required this.shippingProvider,
    required this.shippingStatus,
    required this.shippedDate,
    required this.updatedAt,
  });
}