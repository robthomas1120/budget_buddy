// lib/screens/home_page.dart

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'dashboard_page.dart';
import 'income_page.dart';
import 'expense_page.dart';
import 'budget_page.dart';
import 'savings_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Create a list of page widgets
  late List<Widget> _pages;
  final _tabController = CupertinoTabController(initialIndex: 0);
  final _savingsPageKey = GlobalKey<SavingsPageState>();
  
  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardPage(
        onSettingsPressed: _showSettings,
      ),
      IncomePage(),
      ExpensePage(),
      BudgetPage(),
      SavingsPage(
        key: _savingsPageKey,
        onRefresh: () {
          print('DEBUG: [HomePage] Refreshing SavingsPage from HomePage');
        },
      ),
    ];
  }

  void _showSettings() {
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => SettingsPage()),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        controller: _tabController,
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
              icon: Icon(CupertinoIcons.chart_bar_fill),
              label: 'Budget',
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.money_dollar_circle), 
              label: 'Savings',
            ),
          ],
        ),
        tabBuilder: (context, index) {
          // When the tab changes, trigger a refresh for the savings page
          if (_tabController.index == index && index == 4) {
            // Delay the refresh slightly to ensure the tab has rendered
            Future.delayed(Duration(milliseconds: 100), () {
              // Use the properly initialized GlobalKey
              _savingsPageKey.currentState?.refreshData();
            });
          }
          
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