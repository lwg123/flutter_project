import 'package:flutter/material.dart';
import '../model/category.dart';

class ChildCategory with ChangeNotifier {
  List<BxMallSubDto> childCategoryList = [];
  int childIndex = 0;
  String categoryId = '4'; //默认大类id
  String subId = ''; //小类id
  int page = 1; // 列表页
  String noMoreText = ''; //显示更多的标识
  
  //点击大类时更换
  getChildCategory(List<BxMallSubDto> list, String id){
    // 点击大类时清零
    childIndex = 0;
    categoryId = id;
    subId = ''; //点击大类时，把子类ID清空
    page = 1; // 列表页
    noMoreText = '';

    BxMallSubDto all =BxMallSubDto();
    all.mallCategoryId = '00';
    all.mallSubId = '';
    all.mallSubName = '全部';
    all.comments = 'null';
    childCategoryList = [all];
    childCategoryList.addAll(list);
    notifyListeners();
  }

  // 改变子类索引
  changeChildIndex(int index, String id){
    page = 1; // 列表页
    noMoreText = '';
    childIndex = index;
    subId = id;
    notifyListeners();
  }

//增加Page的方法
  addPage(){
    page++;
  }

  // 改变noMoreText数据 
  changeNoMore(String text){
    noMoreText = text;
    notifyListeners();
  }

}