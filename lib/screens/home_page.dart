import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show DefaultTextStyle, TextStyle;
import 'package:provider/provider.dart';
import '../database/database_helper.dart';
import '../models/account.dart';
import '../models/transaction.dart' as model;
import 'dashboard_page.dart';
import 'income_page.dart';
import 'expense_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Create a list of page widgets
  late List<Widget> _pages;
  
  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardPage(),
      IncomePage(),
      ExpensePage(),
      SettingsPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Wrap with DefaultTextStyle to provide text styling for the entire app
    return DefaultTextStyle(
      style: TextStyle(
        color: CupertinoColors.black,
        fontSize: 16.0,
        fontWeight: FontWeight.normal,
        fontFamily: '.SF Pro Text', // Default iOS font
      ),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          activeColor: CupertinoColors.activeGreen,
          items: [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.home),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.arrow_down_circle),
              label: 'Income',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.arrow_up_circle),
              label: 'Expenses',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.settings),
              label: 'Settings',
            ),
          ],
        ),
        tabBuilder: (context, index) {
          // Provide proper text styling for each tab view
          return CupertinoTabView(
            builder: (context) {
              return CupertinoPageScaffold(
                child: _pages[index],
              );
            },
          );
        },
      ),
    );
  }
}