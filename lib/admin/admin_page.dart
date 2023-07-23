import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:egranth/admin/add_book_page.dart';
import 'package:egranth/admin/delete_book_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import '../books_page.dart';
import 'componet/drawer.dart';
import 'package:percent_indicator/percent_indicator.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // ignore: non_constant_identifier_names
  final FirebaseFirestore _FirebaseFirestore = FirebaseFirestore.instance;
  PlatformFile? pickedFiles;
  UploadTask? uploadTask;


  void _showProgressBarDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearPercentIndicator(
              width: 200.0,
              lineHeight: 15.0,
              animation: true,
              animationDuration: 1000,
              percent: 0.0, // Start at 0%.
              center: Text(message),
              linearStrokeCap: LinearStrokeCap.roundAll,
              progressColor: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }


  void _updateProgress(double progress) {
    Navigator.pop(context); // Pop the previous dialog to update the percentage value.
    _showProgressBarDialog('${(progress * 100).toStringAsFixed(2)}% Uploaded');
  }


  Future selectBook() async {
    final result = await FilePicker.platform.pickFiles();

    if(result != null){
      String fileName = result.files[0].name;
      File file = File(result.files[0].path!);

      _showProgressBarDialog('Uploading Image...');
       Navigator.pop(context);

      final downloadLink = await uploadBook(fileName, file);

      await _FirebaseFirestore.collection('files').add({
        'name': fileName,
        'url': downloadLink,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // ignore: avoid_print
      print("Image Successfully Uploaded");
    }
  }

  Future<String> uploadBook(String fileName , File file) async {
    final ref = FirebaseStorage.instance.ref().child("files/$fileName");
    final uploadTask = ref.putFile(file);
    await uploadTask.whenComplete(() {});
    final downloadLink = await ref.getDownloadURL();

    return downloadLink;
}
//...............................................................................................................................

  void pickFiles() async {
    final pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if(pickedFile != null){
      String fileName = pickedFile.files[0].name;
      File file = File(pickedFile.files[0].path!);

      _showProgressBarDialog('Uploading PDF...');

      final downloadLink = await uploadpdf(fileName, file);

      await _FirebaseFirestore.collection('pdfs').add({
        'name': fileName,
        'url': downloadLink,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
      // ignore: avoid_print
      print("Pdf Successfully Uploaded");
    }
  }


  Future<String> uploadpdf(String fileName , File file) async {
  final ref = FirebaseStorage.instance.ref().child("pdfs/$fileName");
  final uploadTask = ref.putFile(file);
  await uploadTask.whenComplete(() {});
  final downloadLink = await ref.getDownloadURL();

  return downloadLink;
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
                  color: Colors.blue[400],
                ),
                child: InkWell(
                  onTap: (){
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddBookPage(),
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

              // SizedBox(height: 20),
              // ElevatedButton(
              //   onPressed: pickFiles,
              //   child: const Text('Select a Pdf'),
              //   ),

              const SizedBox(height: 20),
              Container(
                height: 100,
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.blue[400],
                ),
                child: InkWell(
                  onTap: (){
                    Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DeleteBookPage(),
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

//   Widget buildProgress() => StreamBuilder<TaskSnapshot>(
//       stream: uploadTask!.snapshotEvents,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.active) {
//           final data = snapshot.data!;
//           double progress = data.bytesTransferred / data.totalBytes;
//           if (data.state == TaskState.success) {
//             // File upload completed successfully, show success message
//             return Container(
//               height: 50,
//               color: Colors.green, // Customize the color of the success message container
//               child: Center(
//                 child: Text(
//                   'File uploaded successfully!',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20,
//                   ),
//                 ),
//               ),
//             );
//           } else {
//             // File upload is in progress, show the progress indicator
//             return SizedBox(
//               height: 50,
//               child: Stack(
//                 children: [
//                   LinearProgressIndicator(
//                     value: progress,
//                     backgroundColor: Colors.grey,
//                     color: Colors.blue,
//                   ),
//                   Center(
//                     child: Text(
//                       '${(progress * 100).round()}%', // Use 'round()' instead of 'roundToDouble()'
//                       style: const TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 20,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//         } else {
//           return Container();
//         }
//       },
//     );
// }
}