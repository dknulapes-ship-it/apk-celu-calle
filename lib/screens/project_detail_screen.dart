import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../services/pdf_service.dart';

import 'package:path_provider/path_provider.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;
  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  final ImagePicker _picker = ImagePicker();

  void _addRequirement(BuildContext context, DatabaseService db) {
    final descController = TextEditingController();
    bool isUrgent = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Requirement'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  CheckboxListTile(
                    title: const Text('Is Urgent?'),
                    value: isUrgent,
                    onChanged: (val) => setState(() => isUrgent = val ?? false),
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
                    db.addRequirement(Requirement(
                      id: const Uuid().v4(),
                      projectId: widget.projectId,
                      description: descController.text,
                      isUrgent: isUrgent,
                    ));
                    Navigator.pop(context);
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

  void _addChecklistItem(BuildContext context, DatabaseService db) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Checklist Item'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(labelText: 'Task'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                db.addChecklistItem(ChecklistItem(
                  id: const Uuid().v4(),
                  projectId: widget.projectId,
                  text: textController.text,
                  isChecked: false,
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

  Future<void> _pickImage(DatabaseService db, Project project) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${const Uuid().v4()}_${image.name}';
      final savedImage = await File(image.path).copy('${appDir.path}/$fileName');

      final updatedPhotos = List<String>.from(project.photos)..add(savedImage.path);
      final updatedProject = project.copyWith(photos: updatedPhotos);
      db.updateProject(updatedProject);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);
    final project = db.projects.firstWhere((p) => p.id == widget.projectId);
    final requirements = db.requirements.where((r) => r.projectId == widget.projectId).toList();
    final checklists = db.checklists.where((c) => c.projectId == widget.projectId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(project.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () async {
              await PdfService.generateAndPrintProjectSummary(project, db);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Requirements Section
            ListTile(
              title: const Text('Requirements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _addRequirement(context, db),
              ),
            ),
            if (requirements.isEmpty)
              const Padding(padding: EdgeInsets.all(16.0), child: Text('No requirements.'))
            else
              ...requirements.map((r) => ListTile(
                    title: Text(r.description),
                    subtitle: r.isUrgent ? const Text('URGENT', style: TextStyle(color: Colors.red)) : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () => db.deleteRequirement(r.id),
                    ),
                  )),
            
            const Divider(),

            // Checklist Section
            ListTile(
              title: const Text('Checklist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _addChecklistItem(context, db),
              ),
            ),
            if (checklists.isEmpty)
              const Padding(padding: EdgeInsets.all(16.0), child: Text('No checklist items.'))
            else
              ...checklists.map((c) => CheckboxListTile(
                    title: Text(c.text, style: TextStyle(decoration: c.isChecked ? TextDecoration.lineThrough : null)),
                    value: c.isChecked,
                    onChanged: (val) {
                      db.updateChecklistItem(ChecklistItem(
                        id: c.id,
                        projectId: c.projectId,
                        text: c.text,
                        isChecked: val ?? false,
                      ));
                    },
                    secondary: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.grey),
                      onPressed: () => db.deleteChecklistItem(c.id),
                    ),
                  )),
            
            const Divider(),

            // Photos Section
            ListTile(
              title: const Text('Photos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              trailing: IconButton(
                icon: const Icon(Icons.add_a_photo),
                onPressed: () => _pickImage(db, project),
              ),
            ),
            if (project.photos.isEmpty)
              const Padding(padding: EdgeInsets.all(16.0), child: Text('No photos attached.'))
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: project.photos.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Stack(
                        children: [
                          Image.file(File(project.photos[index]), width: 100, height: 100, fit: BoxFit.cover),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                final updatedPhotos = List<String>.from(project.photos)..removeAt(index);
                                db.updateProject(project.copyWith(photos: updatedPhotos));
                              },
                              child: Container(
                                color: Colors.black54,
                                child: const Icon(Icons.close, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
