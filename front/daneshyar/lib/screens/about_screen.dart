import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text('درباره')), body: Center(child: Text('سیستم تحلیل هوشمند مقالات')));
}