import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/models.dart';
import 'database_service.dart';

class PdfService {
  static Future<void> generateAndPrintProjectSummary(
      Project project, DatabaseService db) async {
    final client = db.clients.firstWhere((c) => c.id == project.clientId, 
        orElse: () => Client(id: '', name: 'Unknown', industry: '', phone: ''));
        
    final projectRequirements = 
        db.requirements.where((r) => r.projectId == project.id).toList();
        
    final projectChecklists = 
        db.checklists.where((c) => c.projectId == project.id).toList();

    final pdfBytes = await compute(_generatePdfIsolate, {
      'project': project,
      'client': client,
      'requirements': projectRequirements,
      'checklists': projectChecklists,
    });

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes);
  }

  static Future<Uint8List> _generatePdfIsolate(Map<String, dynamic> data) async {
    final project = data['project'] as Project;
    final client = data['client'] as Client;
    final projectRequirements = data['requirements'] as List<Requirement>;
    final projectChecklists = data['checklists'] as List<ChecklistItem>;

    final pdf = pw.Document();

    List<pw.Widget> photoWidgets = [];
    for (String photoPath in project.photos) {
      final file = File(photoPath);
      if (file.existsSync()) {
        final image = pw.MemoryImage(file.readAsBytesSync());
        photoWidgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.all(4.0),
            child: pw.Image(image, width: 150, height: 150, fit: pw.BoxFit.cover),
          ),
        );
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text('Project Summary: ${project.title}',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 10),
            pw.Text('Date: ${project.date.toLocal().toString().split(' ')[0]}'),
            pw.SizedBox(height: 20),
            pw.Text('Client Details', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text('Name: ${client.name}'),
            pw.Text('Industry: ${client.industry}'),
            pw.Text('Phone: ${client.phone}'),
            pw.SizedBox(height: 20),
            pw.Text('Requirements', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ...projectRequirements.map((r) => pw.Bullet(
                  text: '${r.description} ${r.isUrgent ? "(URGENT)" : ""}',
                )),
            pw.SizedBox(height: 20),
            pw.Text('Checklist', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ...projectChecklists.map((c) => pw.Row(children: [
                  pw.Container(
                    width: 10,
                    height: 10,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(),
                      color: c.isChecked ? PdfColors.black : PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Text(c.text),
                ])),
            if (photoWidgets.isNotEmpty) ...[
              pw.SizedBox(height: 20),
              pw.Text('Photos', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Wrap(children: photoWidgets),
            ],
          ];
        },
      ),
    );

    return pdf.save();
  }
}
