import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Editor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PDFEditorScreen(),
    );
  }
}

class PDFEditorScreen extends StatefulWidget {
  @override
  _PDFEditorScreenState createState() => _PDFEditorScreenState();
}

class _PDFEditorScreenState extends State<PDFEditorScreen> {
  List<pw.Page> pages = [];
  File? pdfFile;
  String pdfPath = '';

  Future<void> pickPDF() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        pdfFile = File(result.files.single.path!);
        pdfPath = pdfFile!.path;
      });
      OpenFile.open(pdfPath); // Open picked file
    }
  }

  Future<void> removePage(int pageIndex) async {
    if (pageIndex < pages.length) {
      setState(() {
        pages.removeAt(pageIndex);
      });
      await saveEditedPDF();
    }
  }

  Future<void> addPage() async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(build: (context) => pw.Center(child: pw.Text('New Page'))));
    setState(() {
      pages.add(pdf.pages.first);
    });
    await saveEditedPDF();
  }

  Future<void> reorderPages(int oldIndex, int newIndex) async {
    if (oldIndex < pages.length && newIndex < pages.length) {
      setState(() {
        final page = pages.removeAt(oldIndex);
        pages.insert(newIndex, page);
      });
      await saveEditedPDF();
    }
  }

  Future<void> saveEditedPDF() async {
    final pdf = pw.Document();
    pdf.pages.addAll(pages);

    final output = await getTemporaryDirectory();
    final outputFile = File("${output.path}/edited_pdf.pdf");
    await outputFile.writeAsBytes(await pdf.save());

    setState(() {
      pdfPath = outputFile.path;
    });
    OpenFile.open(pdfPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PDF Editor")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: pickPDF,
              child: Text("Pick PDF"),
            ),
            ElevatedButton(
              onPressed: addPage,
              child: Text("Add Page"),
            ),
            ElevatedButton(
              onPressed: () => removePage(pages.length - 1),
              child: Text("Remove Last Page"),
            ),
            ElevatedButton(
              onPressed: () => reorderPages(0, pages.length - 1),
              child: Text("Reorder Pages"),
            ),
          ],
        ),
      ),
    );
  }
}
