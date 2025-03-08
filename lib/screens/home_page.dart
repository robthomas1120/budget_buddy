import 'package:flutter/cupertino.dart';
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
  int _selectedIndex = 0;
  
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
    return CupertinoTabScaffold(
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
        return CupertinoTabView(
          builder: (context) {
            return _pages[index];
          },
        );
      },
    );
  }
}