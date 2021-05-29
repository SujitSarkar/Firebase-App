import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/model/data_model.dart';
import 'package:firebase_app/pages/data_insert_page.dart';
import 'package:flutter/material.dart';

class DatabaseHelper{

  Future<bool> insertData(String name, String phone, String email,
      String address)async{
    try{
      await FirebaseFirestore.instance.collection('User').doc(phone).set({
        'phone': phone,
        'name': name,
        'email': email,
        'address': address
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
              address: element.doc['address']
          );
          dataList.add(dataModel);
        });
      });
      return dataList;
    }catch(error){
      return [];
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