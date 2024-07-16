import 'package:flutter/material.dart';
import 'package:login_app/view/home.dart';
import 'view/login.dart';
import 'view/register.dart';
import 'view/initial.dart';

final routes = {
  "/": (context) => Initial(),
  "/login": (context) => Login(),
  "/register": (context) => Register(),
  "/guest": (context) => Home(username: '',),
};

void main() {
  runApp(MaterialApp(
    title: "Games Tracker",
    debugShowCheckedModeBanner: false,
    initialRoute: "/",
    routes: routes,
  ));
}
