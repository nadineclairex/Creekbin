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
      body: Stack(
        children: [
          // --- MAIN CONTENT ---
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "Notifications",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 50),
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
                                  backgroundColor: const Color(0xFF648DDB),
                                  foregroundColor: Colors.white,
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
                                  // 👇 for demo purposes: go to welcome screen
                                  Navigator.pushReplacementNamed(
                                      context, "/welcome");
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
