import 'package:egranth/admin/add_book_page.dart';
import 'package:egranth/admin/delete_book_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../books_page.dart';
import 'componet/drawer.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
void signOut() {
    FirebaseAuth.instance.signOut(); 
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BookPage(),
        ),
      );
  }

 void goToProfilePage() {
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const BookPage(),
          ),
      );
    }

//...................................................................................................

  @override
  Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(
        title: const Text('Add Book Hear'),
        centerTitle: true,
        backgroundColor: Colors.orange[300],
      ),
      drawer: MyDrawer(
        onHomeTap: goToProfilePage,
        onProfileTap: (){ Navigator.pop(context);},
        onSignOut: signOut,
      ),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

              Container(
                height: 100,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blueAccent,
                ),
                child: InkWell(
                  onTap: (){
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddBookPage(),
                          ),
                      );
                  },
                  child: const Center(
                    child: Text(
                      'Add Book' ,
                     style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      ) 
                    ),
                ),
              ),

              const SizedBox(height: 20),
              Container(
                height: 100,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blueAccent,
                ),
                child: InkWell(
                  onTap: (){
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DeleteBookPage(),
                          ),
                      );
                  },
                  child: const Center(
                    child: Text(
                      'Remove Book' ,
                     style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      ) 
                    ),
                ),
              ), 
          ],
        ),
      ),
    );
  }
}

