import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
import 'package:flutter/material.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;

   PdfViewerPage({super.key , required this.pdfUrl});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  late Future<PDFDocument> _futureDocument;

  @override
  void initState() {
    super.initState();
    _futureDocument = initialisepdf();
  }

  Future<PDFDocument> initialisepdf() async {
    final document = await PDFDocument.fromURL(widget.pdfUrl);
    return document;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<PDFDocument>(
        future: _futureDocument,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('Error loading PDF'),
            );
          } else {
            return PDFViewer(
              enableSwipeNavigation: true,
              scrollDirection: Axis.vertical,
              document: snapshot.data!,
            );
          }
        },
      ),
    );
  }
}
