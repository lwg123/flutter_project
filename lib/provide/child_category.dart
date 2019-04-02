import 'package:flutter/material.dart';
import '../model/category.dart';

class ChildCategory with ChangeNotifier {
  List<BxMallSubDto> childCategoryList = [];
  int childIndex = 0;
  
  //点击大类时更换
  getChildCategory(List<BxMallSubDto> list){
    // 点击大类时清零
    childIndex = 0;
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
  changeChildIndex(index){
    childIndex = index;
    notifyListeners();
  }
}