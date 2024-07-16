import 'package:flutter/material.dart';

class RecentReviews extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews Recentes'),
      ),
      body: Center(
        child: Text('Lista de reviews recentes aqui'),
      ),
    );
  }
}
