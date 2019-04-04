import 'package:flutter/material.dart';
import '../service/service_metnod.dart';
import 'dart:convert';
import '../model/category.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provide/provide.dart';
import '../provide/child_category.dart';
import '../model/categoryGoodsList.dart';
import '../provide/category_goods_list.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';


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
                CategoryGoodsList()
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
    _getGoodsList();
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
        var categoryId = list[index].mallCategoryId;
        Provide.value<ChildCategory>(context).getChildCategory(childList,categoryId);
        _getGoodsList(categoryId:categoryId); // 可选参数必须带key值
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
      Provide.value<ChildCategory>(context).getChildCategory(list[0].bxMallSubDto,list[0].mallCategoryId);
      
    });
  }

  void _getGoodsList({String categoryId}) async {
    var data = {
      'categoryId':categoryId==null?'4':categoryId,
      'categorySubId':"",
      'page':1
    };
    await request('getMallGoods',formData:data).then((val){
        var data = json.decode(val.toString());
        CategoryGoodsListModel goodsList =CategoryGoodsListModel.fromJson(data);
        Provide.value<CategoryGoodsListProvide>(context).getGoodsList(goodsList.data);
    
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
                  return _rightInkWell(index,childCategory.childCategoryList[index]);
                },
              )
            ),
          );
        },
      ),
    );
  }

  Widget _rightInkWell(int index,BxMallSubDto item){
    bool isClick = false;
    isClick = (index == Provide.value<ChildCategory>(context).childIndex)?true:false;
    return InkWell(
      onTap: (){
        Provide.value<ChildCategory>(context).changeChildIndex(index,item.mallSubId);
        _getGoodsList(item.mallSubId);
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
        child: Text(
          item.mallSubName,
          style:TextStyle(
            fontSize:ScreenUtil().setSp(28),
            color: isClick?Colors.pink:Colors.black
            ),
        ),
      ),
    );
  }

  void _getGoodsList(String categorySubId) {
    var data = {
      'categoryId':Provide.value<ChildCategory>(context).categoryId,
      'categorySubId':categorySubId,
      'page':1
    };
    request('getMallGoods',formData:data).then((val){
        var data = json.decode(val.toString());
        CategoryGoodsListModel goodsList =CategoryGoodsListModel.fromJson(data);
        if (goodsList.data == null) {
          Provide.value<CategoryGoodsListProvide>(context).getGoodsList([]);
        } else {
          Provide.value<CategoryGoodsListProvide>(context).getGoodsList(goodsList.data);
        }
        
    
    });
  }

}


class CategoryGoodsList extends StatefulWidget {
  @override
  _CategoryGoodsListState createState() => _CategoryGoodsListState();
}

class _CategoryGoodsListState extends State<CategoryGoodsList> {
  
  GlobalKey<RefreshFooterState> _footerkey = new GlobalKey<RefreshFooterState>();
  var scrollController = new ScrollController();

  @override
  void initState() {
    
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Provide<CategoryGoodsListProvide>(
      builder: (context,child,data){
      try{
          if (Provide.value<ChildCategory>(context).page == 1) {
            // 列表位置置顶
            scrollController.jumpTo(0.0);
          } 
        } catch(e){
          print('进入页面第一次初始化:${e}');
      }
        if (data.goodsList.length>0) {
            return Expanded(
              child: Container(
              width: ScreenUtil().setWidth(570),
            // height: ScreenUtil().setHeight(1000), 会溢出，不用高度加一个Expanded
              child: EasyRefresh(
                refreshFooter: ClassicsFooter(
                  key: _footerkey,
                  bgColor: Colors.white,
                  textColor: Colors.pink,
                  moreInfoColor: Colors.pink,
                  showMore: true,
                  noMoreText: Provide.value<ChildCategory>(context).noMoreText,
                  moreInfo: '加载中',
                  loadReadyText: '上拉加载',
                ),
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: data.goodsList.length,
                  itemBuilder: (context,index){
                    return _listWidget(data.goodsList,index);
                  },
                ),
                loadMore: () async{
                  print('没有更多了。。。。');
                  _getMoreList();
                },
              ),
 
            ),
          );
        } else {
          return Text('暂时没有数据');
        } 
      },
    );
  }


  void _getMoreList() {
      Provide.value<ChildCategory>(context).addPage();
      var data = {
        'categoryId':Provide.value<ChildCategory>(context).categoryId,
        'categorySubId':Provide.value<ChildCategory>(context).subId,
        'page':Provide.value<ChildCategory>(context).page
      };
      request('getMallGoods',formData:data).then((val){
          var data = json.decode(val.toString());
          CategoryGoodsListModel goodsList =CategoryGoodsListModel.fromJson(data);
          if (goodsList.data == null) {
            Provide.value<ChildCategory>(context).changeNoMore('没有更多数据了');
          } else {
            Provide.value<CategoryGoodsListProvide>(context).getMoreList(goodsList.data);
          }
      });
    }

  Widget _goodsImage(List newList,index){
    return Container(
      width: ScreenUtil().setWidth(200),
      child: Image.network(newList[index].image),
    );
  }

  Widget _goodsName(List newList,index){
    return Container(
     // padding: EdgeInsets.all(5.0),
      width: ScreenUtil().setWidth(370),
      child: Text(
        newList[index].goodsName,
        maxLines:2,
        overflow:TextOverflow.ellipsis,
        style:TextStyle(fontSize: ScreenUtil().setSp(28)),
      ),
    );
  }

  Widget _goodsPrice(List newList,index){
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      width: ScreenUtil().setWidth(370),
      child: Row(
        children: <Widget>[
          Text(
            '价格:￥${newList[index].presentPrice}',
            style: TextStyle(color: Colors.pink,fontSize: ScreenUtil().setSp(28)),
          ),

          Text(
            '￥${newList[index].oriPrice}',
            style: TextStyle(
              color: Colors.black26,
              decoration: TextDecoration.lineThrough
            ),
          ),
        ],
      ),
    );
  }

  // 把3个方法组合起来
  Widget _listWidget(List newList,int index){
    return InkWell(
      onTap: (){},
      child: Container(
        padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(width: 1.0,color: Colors.black12)
          )
        ),

        child: Row(
          children: <Widget>[
            _goodsImage(newList,index),

            Column(
              children: <Widget>[
                _goodsName(newList,index),
                _goodsPrice(newList,index)
              ],
            )
          ],
        ),
      ),
    );
  }

}