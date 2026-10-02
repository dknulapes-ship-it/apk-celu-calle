class Client {
  final String id;
  final String name;
  final String industry;
  final String phone;

  Client({
    required this.id,
    required this.name,
    required this.industry,
    required this.phone,
  });

  factory Client.fromJson(Map<dynamic, dynamic> json) {
    return Client(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      industry: json['industry']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'industry': industry,
      'phone': phone,
    };
  }
}

class Project {
  final String id;
  final String clientId;
  final String title;
  final DateTime date;
  final List<String> photos;

  Project({
    required this.id,
    required this.clientId,
    required this.title,
    required this.date,
    this.photos = const [],
  });

  factory Project.fromJson(Map<dynamic, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = json['date'] != null ? DateTime.parse(json['date'].toString()) : DateTime.now();
    } catch (e) {
      parsedDate = DateTime.now();
    }
    List<String> parsedPhotos = [];
    if (json['photos'] != null) {
      parsedPhotos = List<String>.from(json['photos']);
    }
    return Project(
      id: json['id']?.toString() ?? '',
      clientId: json['clientId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      date: parsedDate,
      photos: parsedPhotos,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'title': title,
      'date': date.toIso8601String(),
      'photos': photos,
    };
  }
  
  Project copyWith({
    String? id,
    String? clientId,
    String? title,
    DateTime? date,
    List<String>? photos,
  }) {
    return Project(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      title: title ?? this.title,
      date: date ?? this.date,
      photos: photos ?? this.photos,
    );
  }
}

class Requirement {
  final String id;
  final String projectId;
  final String description;
  final bool isUrgent;

  Requirement({
    required this.id,
    required this.projectId,
    required this.description,
    required this.isUrgent,
  });

  factory Requirement.fromJson(Map<dynamic, dynamic> json) {
    return Requirement(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      isUrgent: json['isUrgent'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'description': description,
      'isUrgent': isUrgent,
    };
  }
}

class ChecklistItem {
  final String id;
  final String projectId;
  final String text;
  final bool isChecked;

  ChecklistItem({
    required this.id,
    required this.projectId,
    required this.text,
    required this.isChecked,
  });

  factory ChecklistItem.fromJson(Map<dynamic, dynamic> json) {
    return ChecklistItem(
      id: json['id']?.toString() ?? '',
      projectId: json['projectId']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      isChecked: json['isChecked'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'text': text,
      'isChecked': isChecked,
    };
  }
}
