import 'package:flutter/material.dart';

class RecentOrdersScreen extends StatelessWidget {
  const RecentOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('سفارشات اخیر', style: TextStyle(fontSize: 22))),
    );
  }
}