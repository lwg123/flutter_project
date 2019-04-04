import 'package:flutter/material.dart';
import '../service/service_metnod.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'dart:convert';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import '../routers/application.dart';

class HomePage extends StatefulWidget {
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AutomaticKeepAliveClientMixin {

  int page = 1;
  List<Map> hotGoodsList = [];

  GlobalKey<RefreshFooterState> _footerkey = new GlobalKey<RefreshFooterState>();

  @override
  bool get wantKeepAlive =>true;

  @override
  void initState() {
    super.initState();
    print('11111111');
    
  }

  @override
  Widget build(BuildContext context) {
    var formData = {'lon':'104.10194','lat':'30.65984'};
    return Container(
       child: Scaffold(
         appBar: AppBar(title: Text('百姓生活+'),),
         body: FutureBuilder(
           future: request('homePageContent', formData: formData),
           builder: (context,snapshot){
             if (snapshot.hasData) {
               var data =json.decode(snapshot.data.toString());
               List<Map> swiper = (data['data']['slides'] as List).cast();//顶部轮播组件数
               List<Map> navigatorList = (data['data']['category'] as List).cast();
               String advertisePicture =data['data']['advertesPicture']['PICTURE_ADDRESS'];
               String leaderImage = data['data']['shopInfo']['leaderImage'];// 店长图片
               String leaderPhone = data['data']['shopInfo']['leaderPhone']; //店长电话 
               List<Map> recommondList = (data['data']['recommend'] as List).cast();//商品推荐
               
              String floor1Title =data['data']['floor1Pic']['PICTURE_ADDRESS'];
              String floor2Title =data['data']['floor2Pic']['PICTURE_ADDRESS'];
              String floor3Title =data['data']['floor3Pic']['PICTURE_ADDRESS'];
              List<Map> floor1 = (data['data']['floor1'] as List).cast(); //楼层1商品和图片 
              List<Map> floor2 = (data['data']['floor2'] as List).cast(); //楼层1商品和图片 
              List<Map> floor3 = (data['data']['floor3'] as List).cast();

               return EasyRefresh(
                    refreshFooter: ClassicsFooter(
                      key:_footerkey, //需要添加一个key
                      bgColor: Colors.white,
                      textColor: Colors.pink,
                      moreInfoColor: Colors.pink,
                      showMore: true,
                      noMoreText: '',
                      moreInfo: '加载中',
                      loadReadyText: '上拉加载',
                    ),

                    child: ListView( // 使用EasyRefresh刷新控件要求必须用ListView
                      children: <Widget>[
                        SwiperDiy(swiperDataList: swiper),//页面顶部轮播图
                        TopNavigator(navigatorList: navigatorList),
                        AdBanner(advertisePicture: advertisePicture),
                        LeaderPhone(leaderImage: leaderImage,leaderPhone: leaderPhone), //广告组件
                        Recommond(recommondList: recommondList),

                        FloorTitle(pictureAddress: floor1Title),
                        FloorContent(floorGoodsList: floor1),
                        FloorTitle(pictureAddress: floor2Title),
                        FloorContent(floorGoodsList: floor2),
                        FloorTitle(pictureAddress: floor3Title),
                        FloorContent(floorGoodsList: floor3),
                        _hotGoods(),

                      ],
                ),

                  loadMore:()async{
                    print('开始加载更多');
                    var formPage = {'page':page};
                    await request('homePageBelowConten',formData: formPage).then((val){
                      var data =json.decode(val.toString());
                      List<Map> newGoodsList = (data['data'] as List).cast();
                      setState(() {
                        hotGoodsList.addAll(newGoodsList);
                        page++;
                      });
                    });
                }


               );

             } else {
               return Center(
                 child: Text('加载中'),
               );
             }
           },
         )
       ),
    );
  }

  // 火爆专区标题
  Widget hotTitle =Container(
    margin: EdgeInsets.only(top: 10.0),
    padding: EdgeInsets.all(5.0),
    alignment: Alignment.center,
    color: Colors.transparent,
    child: Text('火爆专区'),
  );

  // 火爆专区子项
  Widget _wrapList(){

    if (hotGoodsList.length != 0) {
      List<Widget> listWidget = hotGoodsList.map((val){
        return InkWell(
          onTap: (){
              Application.router.navigateTo(context, '/detail?id=${val['goodsId']}');
            },
          child: Container(
            width: ScreenUtil().setWidth(372),
            color: Colors.white,
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.only(bottom: 3.0),
            child: Column(
              children: <Widget>[
                Image.network(val['image'], width:ScreenUtil().setWidth(370),),
                Text(
                  val['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.pink, fontSize: ScreenUtil().setSp(26)),
                ),
                Row(
                  children: <Widget>[
                    Text('￥${val['mallPrice']}'),
                    Text(
                      '￥${val['price']}',
                      style: TextStyle(color: Colors.black26,decoration: TextDecoration.lineThrough),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList();

      return Wrap(
        spacing: 2,
        children: listWidget,
      );
    } else {
      return Text(' ');
    }
  }

  // 火爆专区组合
  Widget _hotGoods(){
    return Container(
      child: Column(
        children: <Widget>[
          hotTitle,
          _wrapList(),
        ],
      ),
    );
  }

}

// 首页轮播组件编写
class SwiperDiy extends StatelessWidget {
  final List swiperDataList;

  //SwiperDiy({Key key, this.swiperDataList}) : super(key: key);
  SwiperDiy({this.swiperDataList}); // 可以简写

  @override
  Widget build(BuildContext context) {
    
    return Container(
      height: ScreenUtil().setHeight(333),
      width: ScreenUtil().setWidth(750),
      child: Swiper(
        itemBuilder: (BuildContext context, int index){
          return Image.network("${swiperDataList[index]['image']}", fit: BoxFit.fill);
        },
        itemCount: swiperDataList.length,
        pagination: SwiperPagination(),
        autoplay: true,
      ),
    );
  }
}


// 顶部导航
class TopNavigator extends StatelessWidget {
  final List navigatorList;

  TopNavigator({Key key, this.navigatorList}) : super(key: key);

  Widget _gridViewItemUI(BuildContext context,item){
    return InkWell(
      onTap: (){print('点击了导航');},
      child: Column(
        children: <Widget>[
          Image.network(item['image'], width:ScreenUtil().setWidth(95)),
          Text(item['mallCategoryName'])
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (this.navigatorList.length > 10) {
      this.navigatorList.removeRange(10, navigatorList.length);
    }

    return Container(
      height: ScreenUtil().setHeight(320),
      padding: EdgeInsets.all(3.0),
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 5,
        padding: EdgeInsets.all(5.0),
        children: navigatorList.map((item){
          return _gridViewItemUI(context, item);
        }).toList(),
      ),
    );
  }
}

// 广告图片
class AdBanner extends StatelessWidget {
  final String advertisePicture;

  AdBanner({Key key, this.advertisePicture}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.network(advertisePicture),
    );
  }
}

// 店长电话模块
class LeaderPhone extends StatelessWidget {
  final String leaderImage;
  final String leaderPhone;

  LeaderPhone({Key key, this.leaderImage, this.leaderPhone}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        onTap: _launchURL,
        child: Image.network(leaderImage),
      ),
    );
  }

  void _launchURL() async {
    String url = 'tel:'+leaderPhone;
    
    if (await canLaunch(url)) {
      await launch(url);
    }else {
      throw 'url不能访问，异常';
    }
  }
}

// 商品推荐
class Recommond extends StatelessWidget {
  final List recommondList;

  Recommond({Key key, this.recommondList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: ScreenUtil().setHeight(390),
      margin: EdgeInsets.only(top: 10.0),
      child: Column(
        children: <Widget>[
          _titleWidget(),
          _recommondList()
        ],
      ),
    );
  }

  // 推荐标题
  Widget _titleWidget(){
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.fromLTRB(10.0, 2.0, 0, 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(width: 0.5,color: Colors.black12)
        )
      ),
      child: Text(
        '商品推荐',
         style:TextStyle(color:Colors.pink)
        ),
    );
  }

  Widget _item(index){
    return InkWell(
      onTap: (){},
      child: Container(
        height: ScreenUtil().setHeight(330),
        width: ScreenUtil().setWidth(250),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            left: BorderSide(width: 0.5,color: Colors.black12)
          )
        ),
        child: Column(
          children: <Widget>[
            Image.network(recommondList[index]['image']),
            Text('￥${recommondList[index]['mallPrice']}'),
            Text(
              '￥${recommondList[index]['price']}',
              style: TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recommondList(){
    return Container(
      height: ScreenUtil().setHeight(330),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context,index){
          return _item(index);
        },
      ),
    );
  }
}

// 楼层标题
class FloorTitle extends StatelessWidget {
  final String pictureAddress;

  FloorTitle({Key key, this.pictureAddress}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Image.network(pictureAddress),
    );
  }
}

// 楼层商品组件
class FloorContent extends StatelessWidget {
  final List floorGoodsList;

  FloorContent({Key key, this.floorGoodsList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          _firstRow(),
          _otherGoods()
        ],
      ),
    );
  }

Widget _firstRow(){
  return Row(
    children: <Widget>[
      _goodsItem(floorGoodsList[0]),
      Column(
        children: <Widget>[
          _goodsItem(floorGoodsList[1]),
          _goodsItem(floorGoodsList[2]),
        ],
      )
    ],
  ); 
}

Widget _otherGoods(){
  return Row(
    children: <Widget>[
      _goodsItem(floorGoodsList[3]),
      _goodsItem(floorGoodsList[4])
    ],
  );
}


Widget _goodsItem(Map goods){
  return Container(
    width: ScreenUtil().setWidth(375),
    child: InkWell(
      onTap: (){print('点击了楼层商品');},
      child: Image.network(goods['image']),
    ),
  );
}


}



