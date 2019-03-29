import 'package:flutter/material.dart';
import '../service/service_metnod.dart';
import 'dart:convert';
import '../model/category.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';
import '../provide/child_category.dart';


class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('商品分类'),),
      body: Container(
        child: Row(
          children: <Widget>[
            LeftCategoryNav(),
            Column(
              children: <Widget>[
                RightCategoryNav(),
              ],
            )
          ],
        ),
      ),
    );
  }

}

// 左侧导航菜单
class LeftCategoryNav extends StatefulWidget {
  @override
  _LeftCategoryNavState createState() => _LeftCategoryNavState();
}

class _LeftCategoryNavState extends State<LeftCategoryNav> {
  List list = [];
  var listIndex = 0; //索引

  @override
  void initState() {
    _getCategory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScreenUtil().setWidth(180),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(width: 1,color: Colors.black12)
        )
      ),
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context,index){
          return _leftInkWell(index);
        },
      ),
    );
  }

  Widget _leftInkWell(int index){
    bool isClick =false;
    isClick = (index == listIndex)?true :false;

    return InkWell(
      onTap: (){
        setState(() {
          listIndex =index;
        });
        var childList =list[index].bxMallSubDto;
        Provide.value<ChildCategory>(context).getChildCategory(childList);
      },
      child: Container(
        height: ScreenUtil().setHeight(100),
        padding: EdgeInsets.only(left: 10,top: 20),
        decoration: BoxDecoration(
          color: isClick? Color.fromRGBO(236, 236, 236, 1.0) : Colors.white,
          border: Border(
            bottom: BorderSide(width: 1,color: Colors.black12)
          )
        ),
        child: Text(list[index].mallCategoryName,style: TextStyle(fontSize: ScreenUtil().setSp(28)),),
      ),
    );
  }


// 获取后台数据
  void _getCategory() async{
    await request('getCategory').then((val){
      var data =json.decode(val.toString());
      CategoryModel category =CategoryModel.fromJson(data);
      
      setState(() {
        list = category.data;
      });
      Provide.value<ChildCategory>(context).getChildCategory(list[0].bxMallSubDto);
      
    });
  }

  
}


// 右侧小类类别
class RightCategoryNav extends StatefulWidget {
  @override
  _RightCategoryNavState createState() => _RightCategoryNavState();
}

class _RightCategoryNavState extends State<RightCategoryNav> {

 
  @override
  Widget build(BuildContext context) {
    return Container(

        child: Provide<ChildCategory>(
        builder: (context,child,childCategory){
          return Container(
            child: Container(
              height: ScreenUtil().setHeight(80),
              width: ScreenUtil().setWidth(570),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(width: 1,color: Colors.black12)
                )
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: childCategory.childCategoryList.length,
                itemBuilder: (context,index){
                  return _rightInkWell(childCategory.childCategoryList[index]);
                },
              )
            ),
          );
        },
      ),
    );
  }

  Widget _rightInkWell(BxMallSubDto item){
    return InkWell(
      onTap: (){},
      child: Container(
        padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
        child: Text(
          item.mallSubName,
          style:TextStyle(fontSize:ScreenUtil().setSp(28)),
        ),
      ),
    );
  }

}