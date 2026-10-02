import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class ClientListScreen extends StatelessWidget {
  const ClientListScreen({super.key});

  void _showAddClientDialog(BuildContext context) {
    final nameController = TextEditingController();
    final industryController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Client'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: industryController,
                decoration: const InputDecoration(labelText: 'Industry'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final db = Provider.of<DatabaseService>(context, listen: false);
                db.addClient(Client(
                  id: const Uuid().v4(),
                  name: nameController.text,
                  industry: industryController.text,
                  phone: phoneController.text,
                ));
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients'),
      ),
      body: db.clients.isEmpty
          ? const Center(child: Text('No clients found.'))
          : ListView.builder(
              itemCount: db.clients.length,
              itemBuilder: (context, index) {
                final client = db.clients[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(client.name),
                  subtitle: Text('${client.industry} - ${client.phone}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      db.deleteClient(client.id);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddClientDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
