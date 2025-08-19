// lib/screens/shipments_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin_dashboard_rajshree/providers/shipment_provider.dart';
import 'package:admin_dashboard_rajshree/models/shipment.dart';

class ShipmentsScreen extends StatefulWidget {
  const ShipmentsScreen({super.key});

  @override
  _ShipmentsScreenState createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends State<ShipmentsScreen> {
  // State for pagination
  int _currentPage = 0;
  final int _rowsPerPage = 10;

  // State for selected shipments
  final Set<Shipment> _selectedShipments = {};

  @override
  void initState() {
    super.initState();
    // Fetch the shipments when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ShipmentProvider>(context, listen: false).fetchShipments();
    });
  }

  void _onSelectAll(bool? selected, List<Shipment> shipments) {
    setState(() {
      if (selected == true) {
        _selectedShipments.addAll(shipments);
      } else {
        _selectedShipments.clear();
      }
    });
  }

  void _onSelectChanged(bool? selected, Shipment shipment) {
    setState(() {
      if (selected == true) {
        _selectedShipments.add(shipment);
      } else {
        _selectedShipments.remove(shipment);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipments'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Consumer<ShipmentProvider>(
        builder: (context, shipmentProvider, child) {
          if (shipmentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (shipmentProvider.shipments.isEmpty) {
            return const Center(
              child: Text('No shipments found or an error occurred.',
                  style: TextStyle(color: Colors.grey)),
            );
          }

          // Pagination logic
          final int start = _currentPage * _rowsPerPage;
          final int end = (_currentPage + 1) * _rowsPerPage > shipmentProvider.shipments.length
              ? shipmentProvider.shipments.length
              : (_currentPage + 1) * _rowsPerPage;
          final List<Shipment> visibleShipments = shipmentProvider.shipments.sublist(start, end);
          final int totalPages = (shipmentProvider.shipments.length / _rowsPerPage).ceil();

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(Theme.of(context).colorScheme.primary.withOpacity(0.08)),
                      columns: [
                        DataColumn(
                          label: Checkbox(
                            value: _selectedShipments.containsAll(visibleShipments),
                            onChanged: (bool? selected) => _onSelectAll(selected, visibleShipments),
                            tristate: false,
                          ),
                        ),
                        const DataColumn(label: Text('Order')),
                        const DataColumn(label: Text('Shipped date')),
                        const DataColumn(label: Text('Updated at')),
                        const DataColumn(label: Text('Tracking Number')),
                        const DataColumn(label: Text('Shipping carrier')),
                        const DataColumn(label: Text('Shipment status')),
                        const DataColumn(label: Text('Actions')),
                      ],
                      rows: visibleShipments.map((shipment) {
                        final isSelected = _selectedShipments.contains(shipment);
                        return DataRow(
                          selected: isSelected,
                          onSelectChanged: (bool? selected) => _onSelectChanged(selected, shipment),
                          cells: [
                            DataCell(Checkbox(
                              value: isSelected,
                              onChanged: (bool? selected) => _onSelectChanged(selected, shipment),
                            )),
                            DataCell(Text(shipment.orderId)),
                            DataCell(Text('${shipment.shippedDate.month}/${shipment.shippedDate.day}/${shipment.shippedDate.year}')),
                            DataCell(Text('${shipment.updatedAt.month}/${shipment.updatedAt.day}/${shipment.updatedAt.year}')),
                            DataCell(Text(shipment.trackingNumber)),
                            DataCell(Text(shipment.shippingProvider)),
                            DataCell(Text(shipment.shippingStatus)),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () {
                                      // TODO: Implement edit functionality
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, size: 20),
                                    onPressed: () {
                                      // TODO: Implement delete functionality
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              // Pagination controls
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left),
                      onPressed: _currentPage > 0
                          ? () => setState(() => _currentPage--)
                          : null,
                    ),
                    Text('Page ${_currentPage + 1} of $totalPages'),
                    IconButton(
                      icon: const Icon(Icons.arrow_right),
                      onPressed: _currentPage < totalPages - 1
                          ? () => setState(() => _currentPage++)
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
