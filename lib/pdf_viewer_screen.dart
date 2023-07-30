import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;

  const PdfViewerPage({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  bool _isDownloading = false;
  String _downloadMessage = 'Opening a Book...';

  String _getFileNameFromUrl(String url) {
    // Extract the file name from the URL
    Uri uri = Uri.parse(url);
    String fileName = uri.pathSegments.last;
    return fileName;
  }

  void _checkIfBookDownloaded() async {
    final dir = await getExternalStorageDirectory();
    final fileSavePath = "${dir?.path}/${_getFileNameFromUrl(widget.pdfUrl)}"; // File path with the book name

    if (await File(fileSavePath).exists()) {
      // Book is already downloaded, so open the downloaded PDF directly
      _openDownloadedPdf(fileSavePath);
    } else {
      // Book is not downloaded, start downloading
      _downloadPdf();
    }
  }

  void _downloadPdf() async {
    setState(() {
      _isDownloading = true;
      _downloadMessage = 'Downloading...';
    });

    try {
      Dio dio = Dio();
      final dir = await getExternalStorageDirectory();
      final fileSavePath = "${dir?.path}/${_getFileNameFromUrl(widget.pdfUrl)}"; // File path with the book name

      await dio.download(widget.pdfUrl, fileSavePath);

      setState(() {
        _isDownloading = false;
        _downloadMessage = 'Download Completed';
      });

      _openDownloadedPdf(fileSavePath);
    } catch (e) {
      if (kDebugMode) {
        print("Error downloading PDF: $e");
      }
      setState(() {
        _isDownloading = false;
        _downloadMessage = 'Download Failed';
      });
    }
  }

  void _openDownloadedPdf(String filePath) {
    OpenFile.open(filePath);
  }

  @override
  void initState() {
    super.initState();
    _checkIfBookDownloaded(); // Check if the book is already downloaded when the page loads
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
      ),
      body: Center(
        child: _isDownloading
            ? const CircularProgressIndicator()
            : Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blue[700],
                ),
                child: Text(
                  _downloadMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
      ),
    );
  }
}
