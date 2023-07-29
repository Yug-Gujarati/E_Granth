import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:egranth/admin/admin_page.dart';
import 'package:egranth/pdf_viewer_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'admin/componet/drawer.dart';
import 'admin/login_page.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  // ignore: non_constant_identifier_names
  final FirebaseFirestore _FirebaseFirestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> pdfData = [];
  List<String> imageUrls = [];
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> filteredPdfData = [];
  List<String> filteredImageUrls = [];

  @override
  void initState() {
    super.initState();
    getAppPdf();
    getImages();
  }

  void getAppPdf() async {
    final results =  await _FirebaseFirestore.collection("pdfs").orderBy('timestamp', descending: true).get();
    pdfData = results.docs.map((e) => e.data()).toList();
    filteredPdfData = List.from(pdfData);
    setState(() {});
  }

  void getImages() async {
    final snapshot =  await _FirebaseFirestore.collection("files").orderBy('timestamp', descending: true).get();
    imageUrls = snapshot.docs.map((doc) => doc['url'] as String).toList();
    filteredImageUrls = List.from(imageUrls);
    setState(() {});
  }

  void searchBooks(String query) {
  setState(() {
    filteredPdfData = [];
    filteredImageUrls = [];

    for (var book in pdfData) {
      if (book['name'].toLowerCase().contains(query.toLowerCase())) {
        filteredPdfData.add(book);
        final index = pdfData.indexOf(book);
        if (index >= 0 && index < imageUrls.length) {
          filteredImageUrls.add(imageUrls[index]);
        }
      }
    }
  });
}




  void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }

  void goToProfilePage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminPage(),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GranthSagar'),
        centerTitle: true,
        backgroundColor: Colors.orange[300],
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signOut,
        onHomeTap: () {
          Navigator.pop(context);
        },
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: searchBooks,
              decoration: const InputDecoration(
                hintText: 'Search books...',
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10.0),
              child: GridView.builder(
                itemCount: filteredPdfData.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.6,
                ),
                itemBuilder: (context, index) {
                  if (index >= filteredPdfData.length || index >= filteredImageUrls.length) {
                    return Container(); // Handle cases where the index is out of range due to empty lists.
                  }
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: InkWell(
                      onTap: () {
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
                          // ignore: sized_box_for_whitespace
                          Container(
                            height: 200,
                            width: 150,
                            child: Image.network(
                              filteredImageUrls[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 0.1),
                          Expanded(
                            child: Text(
                              filteredPdfData[index]['name'],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[900],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
