import 'dart:ffi';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_button/animated_button.dart';

import 'package:words/const/images_name.dart';
import 'package:words/const/screen_size.dart';
import 'package:words/view_model/main_page_model.dart';

import 'package:words/view/help_page.dart';
import 'package:words/view/start_page.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  MainPageModel _viewModel = Get.put(MainPageModel());

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Function wp = Screen(MediaQuery.of(context).size).wp;
    Function hp = Screen(MediaQuery.of(context).size).hp;
    return new Scaffold(
      body: new Stack(
        children: <Widget>[
          Container(
            height: hp(100),
            width: wp(100),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: ExactAssetImage(ImagesName.mainBackImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Center(
                //   child: Image.asset(
                //     ImagesName.logoImage,
                //     width: wp(40),
                //     height: hp(10),
                //     fit: BoxFit.cover,
                //   ),
                // ),
                // SizedBox(height: hp(30)),
                Center(
                  child: _drawerButton(
                      Icons.sports_esports_rounded, 'Play', Colors.green, 200),
                ),
                SizedBox(height: hp(5)),
                Center(
                  child: _drawerButton(Icons.contact_support_rounded,
                      'How to play', Colors.purple, 300),
                ),
                SizedBox(height: hp(5)),
                Center(
                  child: _drawerButton(
                      Icons.exit_to_app, 'Quit', Colors.pink, 200),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerButton(
      IconData iconsData, String title, Color color, double _wp) {
    return AnimatedButton(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(width: 3),
            Icon(
              iconsData,
              color: Colors.white,
              size: 45,
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 3),
          ],
        ),
      ),
      onPressed: () {
        if (title == 'How to play') {
          Get.offAll(
            () => HelpPage(),
          );
        }
        if (title == 'Play') {
          Get.offAll(
            () => StartPage(),
          );
        }
        if (title == 'Quit') {
          exit(0);
        }
      },
      shadowDegree: ShadowDegree.light,
      color: color,
      width: _wp,
    );
  }
}
