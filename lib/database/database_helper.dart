import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/model/data_model.dart';
import 'package:flutter/material.dart';

class DatabaseHelper{

  Future<bool> insertData(String name, String phone, String email,
      String address)async{
    try{
      await FirebaseFirestore.instance.collection('User').doc(phone).set({
        'phone': phone,
        'name': name,
        'email': email,
        'address': address,
        'profileImage': ''
      });
      return true;
    }catch(error){
      return false;
    }
  }

  Future<List<DataModel>> fetchData()async{
    List<DataModel> dataList = [];
    try{
      await FirebaseFirestore.instance.collection('User').get().then((snapshot){
        snapshot.docChanges.forEach((element) {
          DataModel dataModel = DataModel(
              phone: element.doc['phone'],
              name: element.doc['name'],
              email: element.doc['email'],
              address: element.doc['address'],
              profileImage: element.doc['profileImage']
          );
          dataList.add(dataModel);
        });
      });
      return dataList;
    }catch(error){
      return [];
    }
  }
  
  Future<bool> deleteData(String phone, BuildContext context)async{
    try{
      await FirebaseFirestore.instance.collection('User').doc(phone).delete();
      return true;
    }catch(error){
      showSnackBar(error.toString(), context);
      return false;
    }
  }

  Future<bool> updateData(Map<String, String> mapData, BuildContext context)async{
    try{
      await FirebaseFirestore.instance.
      collection('User').doc(mapData['phone']).update(mapData);
      return true;
    }catch(error){
      showSnackBar(error.toString(), context);
      return false;
    }
  }

  void showSnackBar(String message, BuildContext context){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.grey[800],
            content: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ))
    );
  }

}


//
// Future<void> _getImageFromGallery()async{
//   final picker = ImagePicker();
//   final pickedFile = await picker.getImage(source: ImageSource.gallery,maxWidth: 300,maxHeight: 300);
//   if(pickedFile!=null){
//     final File _image = File(pickedFile.path);
//   }else {}
//
// }