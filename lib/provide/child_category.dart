import 'package:flutter/material.dart';
import '../model/category.dart';

class ChildCategory with ChangeNotifier {
  List<BxMallSubDto> childCategoryList = [];
  int childIndex = 0;
  String categoryId = '4'; //默认大类id
  String subId = ''; //小类id
  
  //点击大类时更换
  getChildCategory(List<BxMallSubDto> list, String id){
    // 点击大类时清零
    childIndex = 0;
    categoryId = id;
    subId = ''; //点击大类时，把子类ID清空
    BxMallSubDto all =BxMallSubDto();
    all.mallCategoryId = '00';
    all.mallSubId = '00';
    all.mallSubName = '全部';
    all.comments = 'null';
    childCategoryList = [all];
    childCategoryList.addAll(list);
    notifyListeners();
  }

  // 改变子类索引
  changeChildIndex(int index, String id){
    childIndex = index;
    subId = id;
    notifyListeners();
  }
}