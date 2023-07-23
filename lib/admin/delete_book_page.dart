import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:egranth/books_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'admin_page.dart';
import 'componet/drawer.dart';

class DeleteBookPage extends StatefulWidget {
  const DeleteBookPage({super.key});

  @override
  State<DeleteBookPage> createState() => _DeleteBookPageState();
}

class _DeleteBookPageState extends State<DeleteBookPage> {
 final FirebaseFirestore _FirebaseFirestore = FirebaseFirestore.instance;
  //final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  List <Map<String, dynamic>> pdfData = [];
  List<String> imageUrls = [];
  TextEditingController _searchController = TextEditingController();
  List <Map<String, dynamic>> filteredPdfData = [];
  
  void signOut() {
    FirebaseAuth.instance.signOut();  
    Navigator.pop(context);
  }

 void goToProfilePage() {
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>  const AdminPage(),
                  ),
                );
              }
//...............................................................................................................................


// void getImages() async {
//     final ref = _firebaseStorage.ref().child('files');

//     final ListResult result = await ref.listAll();

//     final List<Reference> allFiles = result.items;
//     final List<String> urls = await Future.wait(allFiles.map((file) => file.getDownloadURL()));

//     setState(() {
//       imageUrls = urls;
//     });
//   }

void getImages() async {
    final snapshot = await _FirebaseFirestore.collection("files").orderBy('timestamp', descending: true).get();
    imageUrls = snapshot.docs.map((doc) => doc['url'] as String).toList();
    setState(() {});
  }



void getAppPdf() async {
  final results = await _FirebaseFirestore.collection("pdfs").orderBy('timestamp', descending: true).get();
  pdfData = results.docs.map((e) => e.data()).toList();

  setState(() {
    
  });
}

//...............................................................................................................................


void filterPdfData(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredPdfData = pdfData;
      });
    } else {
      setState(() {
        filteredPdfData = pdfData.where((pdf) =>
            pdf['name'].toLowerCase().contains(query.toLowerCase())).toList();
      });
    }
  }


@override
void initState() {
  getAppPdf();
  getImages();
  filteredPdfData = pdfData;
  super.initState();
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
        onHomeTap: (){Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookPage(),
                  ),
              );
          },
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
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                ),
                itemBuilder: (context, index){
                  return Padding(
                    padding:const EdgeInsets.all(10.0),
                    child:InkWell(
                      onLongPress: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Confirm Delete'),
                                content: Text('Are you sure you want to delete this book?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(); // Close the dialog
                                  },
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    // Delete from Firebase Storage
                                    // Delete from Firestore collection 'files'

                                    await _FirebaseFirestore
                                        .collection('files')
                                        .doc()
                                        .delete();

                                    // Delete from Firestore collection 'pdfs'
                                    await _FirebaseFirestore
                                        .collection('pdfs')
                                        .doc()
                                        .delete();

                                    // Remove the deleted item from the lists
                                   setState(() {
                                      imageUrls.removeAt(index);
                                      pdfData.removeAt(index);
                                      filteredPdfData.removeAt(index);
                                    });

                                   Navigator.of(context).pop(); // Close the dialog
                                  },
                                  child: Text('Delete'),
                                ),
                              ],
                            );
                          },
                        );
                      },

                      // child: Container(
                      //   height: 800,
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(10),
                      //     border: Border.all()
                      //   ),
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
                  //);
                },
              ),
            ),
          ),
        ],
      ),
    );
  } 
}

