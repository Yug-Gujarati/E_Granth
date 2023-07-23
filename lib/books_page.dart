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
  List <Map<String, dynamic>> pdfData = [];
  List<String> imageUrls = [];
  List<Map<String, dynamic>> filteredPdfData = [];
  final TextEditingController _searchController = TextEditingController();


  @override
void initState() {
  super.initState();
  getAppPdf();
  getImages();
  filteredPdfData;
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
      builder: (context) => LoginPage(onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminPage(),
                  ),
                );
              },
            )
          ),
      );
    }
//...............................................................................................................................


Future getImages() async {
    final snapshot = await _FirebaseFirestore.collection("files").orderBy('timestamp', descending: true).get();
    imageUrls = snapshot.docs.map((doc) => doc['url'] as String).toList();
    setState(() {});
  }



Future getAppPdf() async {
  final results = await _FirebaseFirestore.collection("pdfs").orderBy('timestamp', descending: true).get();
  pdfData = results.docs.map((e) => e.data()).toList();

  setState(() {
    
  });
}


//...............................................................................................................................


void filterPdfData(String query) {
      setState(() {
        filteredPdfData = pdfData.where((pdf) =>
            pdf['name'].toLowerCase().contains(query.toLowerCase())).toList();
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
      drawer: MyDrawer(
        onProfileTap: goToProfilePage,
        onSignOut: signOut,
        onHomeTap: (){ Navigator.pop(context);},
      ),
      backgroundColor: Colors.grey[100],

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
             child: TextField(
                controller: _searchController,
                onChanged: (query) => filterPdfData(query),
                decoration: const InputDecoration(
                labelText: 'Search Books',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
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
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index){
                  return Padding(
                    padding:const EdgeInsets.all(10.0),
                    child:InkWell(
                      onTap: (){
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PdfViewerPage(
                              pdfUrl: filteredPdfData[index]['url'],
                            ),
                          ),
                        );
                      },
                        child:Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                              Container(
                                height: 150,
                                width: 120,
                                child: Image.network(
                                imageUrls[index],
                                fit:BoxFit.cover,
                              ),
                              ),
                            SizedBox(height: 5.0), 
                            
                               Expanded( // Wrap the Text widget with Expanded
                              child: Text(
                                filteredPdfData[index]['name'],
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )
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

