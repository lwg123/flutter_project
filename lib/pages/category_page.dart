import 'package:flutter/material.dart';
import '../service/service_metnod.dart';
import 'dart:convert';


class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  @override
  Widget build(BuildContext context) {
    _getData();
    return Container(
      child: Center(
        child: Text('分类页面'),
      ),
    );
  }

  void _getData() async{
    await request('getCategory').then((val){
      var data =json.decode(val);
      print(data);
    });
  }

}

