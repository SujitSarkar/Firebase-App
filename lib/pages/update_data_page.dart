import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app/database/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class UpdateDataPage extends StatefulWidget {
  String phone;
  String name;
  String email;
  String address;
  String profileImage;
  UpdateDataPage({required this.phone, required this.name,
    required this.email, required this.address,required this.profileImage});

  @override
  _UpdateDataPageState createState() => _UpdateDataPageState();
}

class _UpdateDataPageState extends State<UpdateDataPage> {
  TextEditingController _name = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _address = TextEditingController();
  bool _isLoading =false;
  DatabaseHelper _databaseHelper = DatabaseHelper();
  var _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _name.text = widget.name;
    _email.text = widget.email;
    _address.text = widget.address;
    // print(widget.profileImage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Update Page'),
        elevation: 0.0,
      ),
      body: _isLoading?Center(child: CircularProgressIndicator()): _bodyUI(),
    );
  }

  Widget _bodyUI(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
      child: SingleChildScrollView(
        child: Form(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey,
                    child: widget.profileImage.isNotEmpty
                        ?Image.network(widget.profileImage)
                        :Icon(Icons.person)

                  ),
                  IconButton(
                      onPressed: ()=> _getImage(),
                      icon: Icon(Icons.camera_alt,color: Colors.black54))
                ],
              ),
              SizedBox(height: 20),
              _textFormBuilder('Full Name'),
              SizedBox(height: 20),
              _textFormBuilder('Email Address'),
              SizedBox(height: 20),
              _textFormBuilder('Address'),
              SizedBox(height: 20),

              _isLoading? CircularProgressIndicator()
                  : ElevatedButton(
                  onPressed: ()async{
                      setState(()=>_isLoading=true);
                      Map<String, String> mapData= {
                        'phone': widget.phone,
                        'name': _name.text,
                        'email': _email.text,
                        'address': _address.text
                      };
                      await _databaseHelper.updateData(mapData, context).then((value){
                        if(value){
                          setState(()=>_isLoading=false);
                          _databaseHelper.showSnackBar('Data updated successful', context);
                        }
                        else{
                          setState(()=>_isLoading=false);
                          _databaseHelper.showSnackBar('Data update failed!', context);
                        }
                      });
                  },
                  child: Text('Update Data',style: TextStyle(color: Colors.white,fontSize: 17),))
            ],
          ),
        ),
      ),
    );
  }

  Future _getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera,maxHeight: 500,maxWidth: 500);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
          _isLoading =true;
        });
       await uploadPhoto();
      } else {
        _databaseHelper.showSnackBar('No image selected', context);
      }

  }

  Future<void> uploadPhoto()async{
    firebase_storage.Reference storageReference =
    firebase_storage.FirebaseStorage.instance.ref().child('User Photo').child(widget.phone);
    firebase_storage.UploadTask storageUploadTask = storageReference.putFile(_image);
    firebase_storage.TaskSnapshot taskSnapshot;
    storageUploadTask.then((value) {
      taskSnapshot = value;
      taskSnapshot.ref.getDownloadURL().then((newImageDownloadUrl){
        final imageUrl = newImageDownloadUrl;
        FirebaseFirestore.instance.collection('User').doc(widget.phone).update({
          'profileImage':imageUrl,
        }).then((value){
          setState((){
            widget.profileImage=newImageDownloadUrl;
            _isLoading=false;
          });
          _databaseHelper.showSnackBar('Photo updated successful', context);
        },onError: (error){
          setState(()=>_isLoading=false);
          _databaseHelper.showSnackBar('Photo update failed!', context);
        });
      });
    });
  }

  Widget _textFormBuilder(String hint){
    return TextFormField(
      controller:
      hint=='Full Name'? _name
          :hint=='Email Address'? _email
          :_address,
      validator: (value){
        if(value!.isEmpty) return 'Enter $hint';
        else return null;
      },
      decoration: InputDecoration(
          hintText: hint,
        labelText: hint
      ),
    );
  }
}


