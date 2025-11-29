import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final LatLng _initialCenter = LatLng(14.6760, 121.0437);
  double _zoom = 15.0;
  LatLng _center = LatLng(14.6760, 121.0437);
  int _reload = 0;
  LatLng? _remoteBin;

  Future<void> _loadRemoteBin() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('bin')
          .doc('xzGCiqXR5kG6U3KJMf3B')
          .get();
      if (!doc.exists) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Remote bin document not found')));
        return;
      }

      final data = doc.data();
      if (data == null || data['location'] == null) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Remote location field not found')));
        return;
      }

      final dynamic raw = data['location'];
      // Expecting a GeoPoint stored in Firestore
      if (raw is GeoPoint) {
        final gp = raw;
        setState(() {
          _remoteBin = LatLng(gp.latitude, gp.longitude);
          _center = _remoteBin!;
          _zoom = 16.0;
        });
      } else if (raw is Map) {
        // Fallback: if stored as map with lat/lng
        final lat = (raw['latitude'] ?? raw['lat'] ?? raw['0']) as double?;
        final lng = (raw['longitude'] ?? raw['lng'] ?? raw['1']) as double?;
        if (lat != null && lng != null) {
          setState(() {
            _remoteBin = LatLng(lat, lng);
          });
        }
      } else {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Remote bin has unsupported format')));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading remote bin: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    _center = _initialCenter;
    _loadRemoteBin();
  }

  @override
  Widget build(BuildContext context) {
    // If a remote bin was loaded from Firestore use only that one marker,
    // otherwise show the local sample bins.
    // Show only the remote bin if available; otherwise show no markers.
    final sampleBins = _remoteBin != null
        ? [
            {'id': 'remote', 'pos': _remoteBin!, 'isFull': false}
          ]
        : <Map<String, Object>>[];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      endDrawer: _buildDrawer(context),

      appBar: AppBar(
        backgroundColor: Color(0xFF4A70A9),
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Map',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                // MENU BUTTON MOVED HERE
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black, size: 28),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      body: Stack(
        children: [
          FlutterMap(
            key: ValueKey(_reload),
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: _zoom,
              onPositionChanged: (mapPosition, _) {
                setState(() {
                  _center = mapPosition.center;
                  _zoom = mapPosition.zoom;
                });
              },
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
                    width: 48,
                    height: 48,
                    point: p,
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (_) => Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Bin ID: ${bin['id']}',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Row(children: [
                                  Icon(Icons.delete,
                                      size: 20,
                                      color: isFull ? Colors.red : Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(
                                      isFull ? 'Status: Full' : 'Status: Empty',
                                      style: TextStyle(
                                          color: isFull
                                              ? Colors.red
                                              : Colors.green)),
                                ]),
                                const SizedBox(height: 8),
                                const Text('Last Collected: Sept 25, 2025',
                                    style: TextStyle(color: Colors.black54)),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Close')),
                              ],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isFull ? Colors.red : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 4)
                          ],
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Icon(Icons.delete,
                            color: isFull ? Colors.white : Colors.black54,
                            size: 22),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          Positioned(
            bottom: 24,
            right: 12,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  onPressed: () {
                    // Pinpoint the bin if loaded; otherwise center to initial
                    final target = _remoteBin ?? _initialCenter;
                    setState(() {
                      _center = target;
                      // prefer a closer zoom when jumping to the bin
                      _zoom = (_remoteBin != null) ? 17.0 : _zoom;
                    });
                    _mapController.move(target, _zoom);
                  },
                  heroTag: 'dot',
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.fiber_manual_record,
                      color: Colors.black),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.small(
                  onPressed: () async {
                    // show quick feedback and reload remote bin from Firestore
                    if (mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Refreshing...')));
                    await _loadRemoteBin();
                    if (_remoteBin != null) {
                      // automatically locate the bin on the map after reload
                      final target = _remoteBin!;
                      setState(() {
                        _center = target;
                        _zoom = 17.0;
                      });
                      _mapController.move(target, _zoom);
                    } else {
                      if (mounted)
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bin not found')));
                    }
                    if (mounted) setState(() => _reload++);
                  },
                  heroTag: 'refresh',
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.refresh, color: Colors.black),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.small(
                  onPressed: () {
                    setState(() {
                      _zoom = (_zoom + 1).clamp(1.0, 20.0);
                    });
                    _mapController.move(_center, _zoom);
                  },
                  heroTag: 'zoom_in',
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.zoom_in, color: Colors.black),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  onPressed: () {
                    setState(() {
                      _zoom = (_zoom - 1).clamp(1.0, 20.0);
                    });
                    _mapController.move(_center, _zoom);
                  },
                  heroTag: 'zoom_out',
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.zoom_out, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
      // Info button removed per request
    );
  }
}

// --- DRAWER (BURGER MENU) CONTENT ---
Widget _buildDrawer(BuildContext context) {
  return SizedBox(
    width: 250, // reduced width — adjust this value as needed (e.g. 200)
    child: Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Drawer Header for branding/user info
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF648DDB),
            ),
            child: Text(
              'User Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),

          // Example Menu Item
          //ListTile(
          //leading: const Icon(Icons.settings),
          //title: const Text('Settings'),
          //onTap: () {
          // Handle settings navigation
          //Navigator.pop(context);
          //},
          //), huwag muna tanggalin ito

          // LOGOUT OPTION
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.black),
            title: const Text('Logout', style: TextStyle(color: Colors.black)),
            onTap: () {
              // Close the drawer before showing the modal
              Navigator.pop(context);
              _showLogoutModal(context);
            },
          ),
        ],
      ),
    ),
  );
}

// --- MODAL FUNCTION (Moved outside build for clean access) ---
void _showLogoutModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Are you sure you want to log out?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "It’s better to stay signed in so you can monitor the creekbins.",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF648DDB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 20),
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close modal
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
                    Navigator.pop(context); // Close modal
                    // 👇 for demo purposes: go to welcome screen
                    // In a real app, this would trigger an authentication service logout
                    Navigator.pushReplacementNamed(context, "/welcome");
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
}
