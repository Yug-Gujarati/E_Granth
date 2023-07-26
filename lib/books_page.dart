import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'pdf_viewer_screen.dart';

class BookPage extends StatefulWidget {
  const BookPage({Key? key}) : super(key: key);

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> pdfData = [];
  List<Map<String, dynamic>> imageUrls = [];
  List<Map<String, dynamic>> filteredPdfData = [];
  List<Map<String, dynamic>> filteredimgData = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getAppPdf();
    getImages();
  }

  Future<void> getImages() async {
    final snapshot =
        await _firestore.collection("files").orderBy('timestamp', descending: true).get();
    imageUrls = snapshot.docs.map((e) => e.data() as Map<String, dynamic>).toList();
    setState(() {});
  }

  Future<void> getAppPdf() async {
    final results =
        await _firestore.collection("pdfs").orderBy('timestamp', descending: true).get();
    pdfData = results.docs.map((e) => e.data() as Map<String, dynamic>).toList();
    setState(() {});
  }

  void filterPdfData(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredPdfData = pdfData;
        filteredimgData = imageUrls;
      } else {
        filteredPdfData = pdfData
            .where((pdf) => pdf['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
        filteredimgData = imageUrls.where((imag) {
          int index =
              pdfData.indexWhere((pdf) => pdf['name'].toLowerCase().contains(query.toLowerCase()));
          return index >= 0 && index < imageUrls.length;
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Granthsagar'),
        centerTitle: true,
        backgroundColor: Colors.orange[300],
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: filterPdfData,
              decoration: const InputDecoration(
                labelText: 'Search Books',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredPdfData.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                    onTap: () {
                      // Navigate to the PDF viewer screen passing the URL
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PdfViewerPage(
                            pdfUrl: filteredPdfData[index]['url'],
                          ),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          height: 250,
                          width: 220,
                          child: Image.network(
                            filteredimgData[index]['url'],
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 5.0),
                        Text(
                          filteredPdfData[index]['name'],
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}