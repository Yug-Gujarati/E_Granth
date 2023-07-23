import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:egranth/admin/admin_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../books_page.dart';
import 'componet/drawer.dart';
import 'package:percent_indicator/percent_indicator.dart';

class AddBookPage extends StatefulWidget {
  const AddBookPage({super.key});

  @override
  State<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends State<AddBookPage> {
  // ignore: non_constant_identifier_names
  final FirebaseFirestore _FirebaseFirestore = FirebaseFirestore.instance;
  PlatformFile? pickedFiles;
  UploadTask? uploadTask;
  double _imageUploadProgress = 0.0;
  double _pdfUploadProgress = 0.0;


 void _showProgressBarDialog(String message, double progress) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LinearPercentIndicator(
            width: 200.0,
            lineHeight: 15.0,
            animation: true,
            animationDuration: 1000,
            percent: progress, // Use the progress parameter to update the percentage value.
            center: Text(message),
            linearStrokeCap: LinearStrokeCap.roundAll,
            progressColor: Colors.blue,
            ),
        ],
      ),
    ),
  );
}


  void _updateProgress(double progress, String type) {
  setState(() {
    // Update the corresponding variable based on the type parameter
    if (type == 'image') {
      _imageUploadProgress = progress;
    } else if (type == 'pdf') {
      _pdfUploadProgress = progress;
    }
  });
}



  Future selectImage() async {
    final result = await FilePicker.platform.pickFiles();

    if(result != null){
      String fileName = result.files[0].name;
      File file = File(result.files[0].path!);

     _showProgressBarDialog('Uploading Image...', _imageUploadProgress);

      final downloadLink = await uploadImage(fileName, file);

      await _FirebaseFirestore.collection('files').add({
        'name': fileName,
        'url': downloadLink,
        'timestamp': FieldValue.serverTimestamp(),
      });
        Navigator.pop(context);
      // ignore: avoid_print
     _showUploadSuccessSnackBar();
    }
  }

  Future<String> uploadImage(String fileName , File file) async {
    final ref = FirebaseStorage.instance.ref().child("files/$fileName");
    final uploadTask = ref.putFile(file);
    
    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress = snapshot.bytesTransferred / snapshot.totalBytes;
       _updateProgress(progress, 'image');
    });
    await uploadTask.whenComplete(() {
    // Pass the 'image' type to the _updateProgress() method
    _updateProgress(1.0, 'image');
  });
    final downloadLink = await ref.getDownloadURL();

    return downloadLink;
}
//...............................................................................................................................

  Future pickFiles() async {
    final pickedFile = await FilePicker.platform.pickFiles();

    if(pickedFile != null){
      String fileName = pickedFile.files[0].name;
      File file = File(pickedFile.files[0].path!);

      _showProgressBarDialog('Uploading PDF...', _pdfUploadProgress);

      final downloadLink = await uploadpdf(fileName, file);

      await _FirebaseFirestore.collection('pdfs').add({
        'name': fileName,
        'url': downloadLink,
        'timestamp': FieldValue.serverTimestamp(),
      });
       Navigator.pop(context);
     _showUploadSuccessSnackBar();
    }
  }


  Future<String> uploadpdf(String fileName , File file) async {
  final ref = FirebaseStorage.instance.ref().child("pdfs/$fileName");
  final uploadTask = ref.putFile(file);
  uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress = snapshot.bytesTransferred / snapshot.totalBytes;
      _updateProgress(progress, 'pdf');
    });
  await uploadTask.whenComplete(() {
    // Pass the 'pdf' type to the _updateProgress() method
    _updateProgress(1.0, 'pdf');
  });
  final downloadLink = await ref.getDownloadURL();

  return downloadLink;
}


void _showUploadSuccessSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Successfully Uploaded'),
      backgroundColor: Colors.green,
    ));
  }
//...............................................................................................................................



void signOut() {
    FirebaseAuth.instance.signOut(); 
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookPage(),
        ),
      );
  }

 void goToProfilePage() {
  Navigator.pop(context);
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => BookPage(),
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
        onProfileTap: (){
        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminPage(),
              ),
          );
        },
        onSignOut: signOut,
      ),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

              const SizedBox(height: 20),
              Container(
                height: 100,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blue[400],
                ),
                child: InkWell(
                  onTap: selectImage,
                  child: const Center(
                    child: Text(
                      'Select a image' ,
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
                  color: Colors.blue[400],
                ),
                child: InkWell(
                  onTap: pickFiles,
                  child: const Center(
                    child: Text(
                      'Select a Pdf' ,
                     style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      ) 
                    ),
                ),
              ),

              // SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: pickFiles,
              //   child: const Text('Select a Pdf'),
              //   ),
          ],
        ),
      ),
    );
  }
}