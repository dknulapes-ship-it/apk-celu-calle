import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import 'project_detail_screen.dart';

class ProjectListScreen extends StatelessWidget {
  const ProjectListScreen({super.key});

  void _showAddProjectDialog(BuildContext context) {
    final titleController = TextEditingController();
    String? selectedClientId;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final db = Provider.of<DatabaseService>(context, listen: false);
            return AlertDialog(
              title: const Text('Add Project'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Client'),
                    initialValue: selectedClientId,
                    items: db.clients
                        .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedClientId = val),
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
                    if (titleController.text.isNotEmpty && selectedClientId != null) {
                      db.addProject(Project(
                        id: const Uuid().v4(),
                        clientId: selectedClientId!,
                        title: titleController.text,
                        date: DateTime.now(),
                      ));
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
      ),
      body: db.projects.isEmpty
          ? const Center(child: Text('No projects found.'))
          : ListView.builder(
              itemCount: db.projects.length,
              itemBuilder: (context, index) {
                final project = db.projects[index];
                final client = db.clients.firstWhere(
                    (c) => c.id == project.clientId,
                    orElse: () => Client(id: '', name: 'Unknown', industry: '', phone: ''));
                
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.business_center)),
                  title: Text(project.title),
                  subtitle: Text('Client: ${client.name}\nDate: ${project.date.toLocal().toString().split(' ')[0]}'),
                  isThreeLine: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProjectDetailScreen(projectId: project.id),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => db.deleteProject(project.id),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProjectDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
