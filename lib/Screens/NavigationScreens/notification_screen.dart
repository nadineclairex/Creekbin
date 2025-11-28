import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sampleNotifications = [
      {
        "id": "WB1057",
        "status": "is now full",
        "location": "Phase 2, near bridge",
        "date": "09/29/25",
        "time": "9:18pm",
      },
      {
        "id": "WB123452",
        "status": "is now full",
        "location": "Phase 3, near School",
        "date": "09/28/25",
        "time": "9:18pm",
      },
      {
        "id": "WB34545",
        "status": "is now full",
        "location": "IDP 24, near bakery",
        "date": "09/17/25",
        "time": "9:18pm",
      },
      {
        "id": "WB56756",
        "status": "is now full",
        "location": "Phase 7, near Mexican store",
        "date": "09/13/25",
        "time": "9:18pm",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,

      endDrawer: _buildDrawer(context),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 64.0,

        // REMOVE actions completely — we will put the menu in bottom
        actions: const [],

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(10),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: Colors.black,
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

      // REMOVED the Stack and Positioned widget, keeping only the main content
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: sampleNotifications.length,
                  itemBuilder: (context, index) {
                    final notif = sampleNotifications[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.delete, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${notif['id']} ${notif['status']}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text("Location: ${notif['location']}"),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("${notif['date']}"),
                                Text(
                                  "${notif['time']}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- DRAWER (BURGER MENU) CONTENT ---
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
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
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              // Close the drawer before showing the modal
              Navigator.pop(context);
              _showLogoutModal(context);
            },
          ),
        ],
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
}
