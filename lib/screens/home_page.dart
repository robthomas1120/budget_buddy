// lib/screens/home_page.dart
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final themeData = themeProvider.currentThemeData;
    
    // Define a base text style for the home page
    final baseTextStyle = TextStyle(
      color: themeData.textColor,
      fontFamily: '.SF Pro Text',
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
    );
    
    return DefaultTextStyle(
      style: baseTextStyle,
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          activeColor: themeData.primaryColor,
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
              return DefaultTextStyle(
                style: baseTextStyle,
                child: _pages[index],
              );
            },
          );
        },
      ),
    );
  }
}