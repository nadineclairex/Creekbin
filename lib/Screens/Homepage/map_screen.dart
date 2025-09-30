import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LatLng initialCenter = LatLng(14.6760, 121.0437);

    final sampleBins = [
      {'id': 'b1', 'pos': LatLng(14.6770, 121.0430), 'isFull': true},
      {'id': 'b2', 'pos': LatLng(14.6780, 121.0450), 'isFull': true},
      {'id': 'b3', 'pos': LatLng(14.6755, 121.0465), 'isFull': false},
      {'id': 'b4', 'pos': LatLng(14.6745, 121.0425), 'isFull': false},
    ];

    return Scaffold(
      body: Stack(
        children: [
          // --- MAP ---
          FlutterMap(
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.yourapp',
              ),
              MarkerLayer(
                markers: sampleBins.map((bin) {
                  final LatLng p = bin['pos'] as LatLng;
                  final bool isFull = bin['isFull'] as bool;

                  return Marker(
                    width: 40,
                    height: 40,
                    point: p,
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (BuildContext context) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Bin ID: ${bin['id']}",
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.delete, size: 20),
                                      const SizedBox(width: 6),
                                      Text(
                                        isFull
                                            ? "Status: Full"
                                            : "Status: Empty",
                                        style: TextStyle(
                                          color: isFull
                                              ? Colors.red
                                              : Colors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  const Text("Last Collected: Sept 25, 2025",
                                      style: TextStyle(color: Colors.black54)),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(context); // close the sheet
                                    },
                                    icon: const Icon(Icons.close),
                                    label: const Text("Close"),
                                  )
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Icon(
                        Icons.delete,
                        size: 30,
                        color: isFull ? Colors.red : Colors.white,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // --- TOP STATS BAR ---
          Positioned(
            top: 40,
            left: 20,
            right: 70, // leave space for logout
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Total RiverBin: 10",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20),
                      SizedBox(width: 6),
                      Text("4"),
                      SizedBox(width: 14),
                      Icon(Icons.delete, color: Colors.red, size: 20),
                      SizedBox(width: 6),
                      Text("4"),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- LOGOUT BUTTON ---
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (BuildContext context) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Are you sure you want to log out?",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "It’s better to stay signed in so you can monitor the riverbins.",
                            style: TextStyle(color: Colors.black54),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color(0xFF648DDB), // highlight blue
                                  foregroundColor: Colors.white, // white text
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 20),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("No, stay signed in"),
                              ),
                              const SizedBox(width: 20),
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 20),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  // 👇 Navigate to welcome screen
                                  Navigator.pushReplacementNamed(
                                      context, '/welcome');
                                },
                                child: const Text("Yes, log me out"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.logout, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
