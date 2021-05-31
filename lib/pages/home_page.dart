import 'package:firebase_app/database/database_helper.dart';
import 'package:firebase_app/model/data_model.dart';
import 'package:firebase_app/pages/data_insert_page.dart';
import 'package:firebase_app/pages/update_data_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = true;
  DatabaseHelper _databaseHelper = DatabaseHelper();
  List<DataModel> _dataList = [];

  @override
  void initState() {
    super.initState();
    _getDataFromDatabase();
  }

  Future<void> _getDataFromDatabase()async{
    await _databaseHelper.fetchData().then((result){
      if(result.isNotEmpty){
        setState(() {
          _dataList.clear();
          _dataList=result;
          _isLoading=false;
          _databaseHelper.showSnackBar('Data fetched successful', context);
        });
      }else{
        setState(() {
          _dataList.clear();
          _isLoading=false;
          _databaseHelper.showSnackBar('Failed to fetch data', context);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase App'),
        elevation: 0,
      ),
      body: _isLoading? Center(child: CircularProgressIndicator()):_bodyUI(),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=>DataInsertPage()));
        },
        child: Icon(Icons.add,color: Colors.white),
        tooltip: 'Insert Data',
      ),
    );
  }

  Widget _bodyUI(){
    return Container(
      child: RefreshIndicator(
        backgroundColor: Colors.white,
        onRefresh: ()async{
          await _getDataFromDatabase();
        },
        child: ListView.builder(
          itemCount: _dataList.length,
          itemBuilder: (context, index){
            return GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>
                    UpdateDataPage(
                      name: _dataList[index].name,
                      phone: _dataList[index].phone,
                      email: _dataList[index].email,
                      address: _dataList[index].address,
                      profileImage: _dataList[index].profileImage,
                    )));
                print(_dataList[index].profileImage);
              },
              child: Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(_dataList[index].name),
                          Text(_dataList[index].phone),
                          Text(_dataList[index].email),
                          Text(_dataList[index].address),
                        ],
                      ),
                      IconButton(
                          onPressed: (){
                            setState(()=> _isLoading=true);
                            _databaseHelper.deleteData(_dataList[index].phone, context).then((value){
                              if(value==true){
                                _getDataFromDatabase();
                                setState(()=> _isLoading=false);
                                _databaseHelper.showSnackBar('Data deleted successful', context);
                              }else{
                                setState(()=> _isLoading=false);
                                _databaseHelper.showSnackBar('Data delete unsuccessful', context);
                              }
                            });
                          },
                          icon: Icon(Icons.delete,color: Colors.red,)
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
