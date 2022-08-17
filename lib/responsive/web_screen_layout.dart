import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:instagram_clone/utils/global_variables.dart';

import '../utils/colors.dart';

class WebScreenLayout extends StatefulWidget{
  const WebScreenLayout({Key? key}) : super(key: key);

  @override
  State<WebScreenLayout> createState() => _WebScreenLayoutState();
}

class _WebScreenLayoutState extends State<WebScreenLayout> {
  late PageController pageController;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void navigationTap(int page){
    pageController.jumpToPage(page);
    setState((){
      _page = page;
    });
  }

  void onPageChanged(int page){
    setState((){
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: SvgPicture.asset(
          'assets/images/ic_instagram.svg',
          color: primaryColor,
          height: 32,
        ),
        actions: [
          IconButton(
            onPressed: () => navigationTap(0),
            icon:  Icon(Icons.home, color: _page == 0? primaryColor: secondaryColor,),
          ),
          IconButton(
            onPressed: () => navigationTap(1),
            icon: Icon(Icons.search, color: _page == 1? primaryColor: secondaryColor,),
          ),
          IconButton(
            onPressed: () => navigationTap(2),
            icon: Icon(Icons.add_a_photo_outlined, color: _page == 2? primaryColor: secondaryColor,),
          ),
          IconButton(
            onPressed: () => navigationTap(3),
            icon: Icon(Icons.favorite, color: _page == 3? primaryColor: secondaryColor,),
          ),
          IconButton(
            onPressed: () => navigationTap(4),
            icon: Icon(Icons.person_outline, color: _page == 4? primaryColor: secondaryColor,),
          ),
        ],
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: onPageChanged,
        children: homeScreenItems,
      ),
    );
  }
}