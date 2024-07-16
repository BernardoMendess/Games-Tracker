import 'package:flutter/material.dart';
import 'view/login.dart';
import 'view/register.dart';
import 'view/guest.dart';
import 'view/initial.dart';

final routes = {
  "/": (context) => Initial(),
  "/login": (context) => Login(),
  "/register": (context) => Register(),
  "/guest": (context) => Guest(),
};

void main() {
  runApp(MaterialApp(
    title: "Games Tracker",
    debugShowCheckedModeBanner: false,
    initialRoute: "/",
    routes: routes,
  ));
}
