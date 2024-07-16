import 'package:flutter/material.dart';
import 'view/login.dart';

final routes = {
  "/": (context) => Login(),
  "/login": (context) => Login()
};

void main() {
  runApp(MaterialApp(
    title: "Games Tracker",
    debugShowCheckedModeBanner: false,
    routes: routes
  ));
}