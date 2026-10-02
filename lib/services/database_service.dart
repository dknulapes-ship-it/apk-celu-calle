import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

class DatabaseService extends ChangeNotifier {
  late Box _clientsBox;
  late Box _projectsBox;
  late Box _requirementsBox;
  late Box _checklistsBox;

  List<Client> clients = [];
  List<Project> projects = [];
  List<Requirement> requirements = [];
  List<ChecklistItem> checklists = [];

  bool _initialized = false;
  bool get initialized => _initialized;

  Future<void> init() async {
    await Hive.initFlutter();
    _clientsBox = await Hive.openBox('clients');
    _projectsBox = await Hive.openBox('projects');
    _requirementsBox = await Hive.openBox('requirements');
    _checklistsBox = await Hive.openBox('checklists');
    
    _loadData();
    _initialized = true;
    notifyListeners();
  }

  void _loadData() {
    clients = _clientsBox.values.map((e) => Client.fromJson(Map<dynamic, dynamic>.from(e))).toList();
    projects = _projectsBox.values.map((e) => Project.fromJson(Map<dynamic, dynamic>.from(e))).toList();
    requirements = _requirementsBox.values.map((e) => Requirement.fromJson(Map<dynamic, dynamic>.from(e))).toList();
    checklists = _checklistsBox.values.map((e) => ChecklistItem.fromJson(Map<dynamic, dynamic>.from(e))).toList();
  }

  void addClient(Client client) {
    clients.add(client);
    _clientsBox.put(client.id, client.toJson());
    notifyListeners();
  }

  void updateClient(Client client) {
    final index = clients.indexWhere((c) => c.id == client.id);
    if (index != -1) {
      clients[index] = client;
      _clientsBox.put(client.id, client.toJson());
      notifyListeners();
    }
  }

  void deleteClient(String id) {
    clients.removeWhere((c) => c.id == id);
    _clientsBox.delete(id);
    notifyListeners();
  }

  void addProject(Project project) {
    projects.add(project);
    _projectsBox.put(project.id, project.toJson());
    notifyListeners();
  }

  void updateProject(Project project) {
    final index = projects.indexWhere((p) => p.id == project.id);
    if (index != -1) {
      projects[index] = project;
      _projectsBox.put(project.id, project.toJson());
      notifyListeners();
    }
  }

  void deleteProject(String id) {
    projects.removeWhere((p) => p.id == id);
    _projectsBox.delete(id);
    notifyListeners();
  }

  void addRequirement(Requirement requirement) {
    requirements.add(requirement);
    _requirementsBox.put(requirement.id, requirement.toJson());
    notifyListeners();
  }

  void updateRequirement(Requirement requirement) {
    final index = requirements.indexWhere((r) => r.id == requirement.id);
    if (index != -1) {
      requirements[index] = requirement;
      _requirementsBox.put(requirement.id, requirement.toJson());
      notifyListeners();
    }
  }

  void deleteRequirement(String id) {
    requirements.removeWhere((r) => r.id == id);
    _requirementsBox.delete(id);
    notifyListeners();
  }

  void addChecklistItem(ChecklistItem item) {
    checklists.add(item);
    _checklistsBox.put(item.id, item.toJson());
    notifyListeners();
  }

  void updateChecklistItem(ChecklistItem item) {
    final index = checklists.indexWhere((c) => c.id == item.id);
    if (index != -1) {
      checklists[index] = item;
      _checklistsBox.put(item.id, item.toJson());
      notifyListeners();
    }
  }

  void deleteChecklistItem(String id) {
    checklists.removeWhere((c) => c.id == id);
    _checklistsBox.delete(id);
    notifyListeners();
  }
}
