import 'package:firebase_app/database/database_helper.dart';
import 'package:flutter/material.dart';

class DataInsertPage extends StatefulWidget {

  @override
  _DataInsertPageState createState() => _DataInsertPageState();
}

class _DataInsertPageState extends State<DataInsertPage> {
  TextEditingController _name = TextEditingController();
  TextEditingController _phone = TextEditingController();
  TextEditingController _email = TextEditingController();
  TextEditingController _address = TextEditingController();
  final _formKey= GlobalKey<FormState>();
  bool _isLoading =false;

  DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Insert Page'),
        elevation: 0.0,
      ),
      body: _bodyUI(),
    );
  }

  Widget _bodyUI(){
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _textFormBuilder('Full Name'),
              SizedBox(height: 20),
              _textFormBuilder('Phone Number'),
              SizedBox(height: 20),
              _textFormBuilder('Email Address'),
              SizedBox(height: 20),
              _textFormBuilder('Address'),
              SizedBox(height: 20),

              _isLoading? CircularProgressIndicator()
                  : ElevatedButton(
                  onPressed: ()async{
                    if(_formKey.currentState!.validate()){
                      setState(()=>_isLoading=true);
                       await _databaseHelper.insertData(_name.text, _phone.text,
                          _email.text, _address.text).then((value){
                            if(value==true){
                              setState(()=>_isLoading=false);
                              _databaseHelper.showSnackBar('Data Inserted Successfully',context);
                            }else{
                              setState(()=>_isLoading=false);
                              _databaseHelper.showSnackBar('Insert Failed!',context);
                            }
                       });
                    }
                  },
                  child: Text('Insert Data',style: TextStyle(color: Colors.white,fontSize: 17),))
            ],
          ),
        ),
      ),
    );
  }

  Widget _textFormBuilder(String hint){
    return TextFormField(
      controller:
           hint=='Full Name'? _name
          :hint=='Phone Number'?_phone
          :hint=='Email Address'? _email
          :_address,
      validator: (value){
        if(value!.isEmpty) return 'Enter $hint';
        else return null;
      },
      decoration: InputDecoration(
        hintText: hint
      ),
    );
  }
}
