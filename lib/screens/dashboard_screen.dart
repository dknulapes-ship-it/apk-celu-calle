import 'package:flutter/material.dart';
import 'client_list_screen.dart';
import 'project_list_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HomeFix Dashboard'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.home_repair_service, size: 100, color: Colors.teal),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.people),
                label: const Text('Manage Clients'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ClientListScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.business_center),
                label: const Text('Manage Projects'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 50),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProjectListScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
