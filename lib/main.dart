import 'package:flutter/material.dart';
import './pages/index_page.dart';
import 'package:provide/provide.dart';
import './provide/counter.dart';
import './provide/child_category.dart';
import './provide/category_goods_list.dart';
import 'package:fluro/fluro.dart';
import './routers/routes.dart';
import './routers/application.dart';

void main() {
  var childCategory =ChildCategory();
  var categoryCoodsListProvide = CategoryGoodsListProvide();
  var counter =Counter();
  //router注入整个程序
  final router = Router();
  Routes.configureRoutes(router);
  Application.router = router;
  
  var providers = Providers();
  providers
  ..provide(Provider<Counter>.value(counter))
  ..provide(Provider<CategoryGoodsListProvide>.value(categoryCoodsListProvide))
  ..provide(Provider<ChildCategory>.value(childCategory));
  
  runApp(ProviderNode(child:MyApp(),providers:providers));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: MaterialApp(
        title: '百姓生活+',
        onGenerateRoute: Application.router.generator, 
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: Colors.pink,
        ),
        home: IndexPage(),
      ),
    );
  }
}