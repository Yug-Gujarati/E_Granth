import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:egranth/admin/admin_page.dart';
import 'package:egranth/books_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'componet/drawer.dart';


class DeleteBookPage extends StatefulWidget {
  const DeleteBookPage({super.key});

  @override
  State<DeleteBookPage> createState() => _DeleteBookPageState();
}

class _DeleteBookPageState extends State<DeleteBookPage> {
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
    pdfData = results.docs.map((e) => {...e.data(), 'id': e.id}).toList();
    filteredPdfData = List.from(pdfData);
    setState(() {});
  }

  void getImages() async {
    final snapshot =  await _FirebaseFirestore.collection("files").orderBy('timestamp', descending: true).get();
    imageUrls = snapshot.docs.map((doc) => doc['url'] as String).toList();
    filteredImageUrls = List.from(imageUrls);
    setState(() {});
  }

//..................................................................................................................................................................................

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


void deleteBook(int index) async {
  try {
    final pdfId = filteredPdfData[index]['id'];
    final imageUrl = filteredImageUrls[index];

    
    await _FirebaseFirestore.collection('pdfs').doc(pdfId).delete();


    final snapshot = await _FirebaseFirestore.collection('files').where('url', isEqualTo: imageUrl).get();
    if (snapshot.docs.isNotEmpty) {
      final imageId = snapshot.docs.first.id;
     
      await _FirebaseFirestore.collection('files').doc(imageId).delete();
    }

    getAppPdf();
    getImages();
  } catch (e) {
    if (kDebugMode) {
      print("Error deleting book: $e");
    }
  }
}







//..........................................................................................................................................
void signOut() {
    FirebaseAuth.instance.signOut();
    Navigator.pop(context);
  }

  void goToProfilePage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remove Book'),
        centerTitle: true,
        backgroundColor: Colors.orange[300],
      ),
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signOut,
        onHomeTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BookPage(),
            ),
          );
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
                      onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Book'),
                              content: const Text('Are you sure you want to delete?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                   deleteBook(index); 
                                   Navigator.pop(context);
                                      
                                  },
                                  child: const Text('Delete'),
                                ),
                              ],
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
                            child: CachedNetworkImage(
                                imageUrl: filteredImageUrls[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const CircularProgressIndicator(), // Placeholder widget while the image is loading.
                                errorWidget: (context, url, error) => const Icon(Icons.error), // Widget to display when an error occurs during loading.
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
