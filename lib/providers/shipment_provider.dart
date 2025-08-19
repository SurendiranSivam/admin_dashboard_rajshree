// lib/providers/shipment_provider.dart

import 'package:flutter/foundation.dart';
import 'package:admin_dashboard_rajshree/models/shipment.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShipmentProvider with ChangeNotifier {
  List<Shipment> _shipments = [];
  bool _isLoading = false;

  List<Shipment> get shipments => _shipments;
  bool get isLoading => _isLoading;

  Future<void> fetchShipments() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Access the environment variables here, after they have been loaded.
      // Use null-aware operators to provide a default value if the key is not found.
      final String? apiUrlBase = dotenv.env['SUPABASE_URL'];
      final String? authKey = dotenv.env['SUPABASE_ANON_KEY'];

      // Check if environment variables were successfully loaded
      if (apiUrlBase == null || authKey == null) {
        throw Exception("SUPABASE_URL or SUPABASE_ANON_KEY not found in .env file.");
      }

      final String apiUrl = apiUrlBase + '/rest/v1/shipment_tracking?select=*';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $authKey',
          'apikey': authKey,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        _shipments = responseData.map((json) {
          return Shipment(
            orderId: json['order_id'].toString(),
            trackingNumber: json['tracking_number'],
            shippingProvider: json['shipping_provider'],
            shippingStatus: json['shipping_status'],
            shippedDate: DateTime.parse(json['shipped_date']),
            updatedAt: DateTime.parse(json['updated_at']),
          );
        }).toList();
      } else {
        // Handle error response
        if (kDebugMode) {
          print('Failed to load shipments: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
        _shipments = [];
      }
    } catch (e) {
      // Handle network or other errors
      if (kDebugMode) {
        print('An error occurred while fetching shipments: $e');
      }
      _shipments = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
