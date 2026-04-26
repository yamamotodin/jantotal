import 'package:flutter/material.dart';
import 'players_screen.dart';
import 'games_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const GamesScreen(),
    const PlayersScreen(),
    const StatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: '対局',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'プレイヤー',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '統計',
          ),
        ],
      ),
    );
  }
}
