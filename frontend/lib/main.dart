import 'package:flutter/material.dart';
import 'package:frontend/pages/welcome.dart';

void main() => runApp(MaterialApp(
  initialRoute: '/',
  routes:  {
    '/': (context) => Welcome(),
  },
));