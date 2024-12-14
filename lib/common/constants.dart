// lib/constants.dart
import 'dart:ui';

import 'package:flutter/material.dart';

const Color _textFieldBorderColor = Color(0xFF3DA9FC);
const double _textFieldBorderWidth = 2.0;
const double _textFieldBorderRadius = 10;

class Constants {
  static const String apiUrl = 'http://10.0.2.2:8080';
  static const String apiKey = 'your_api_key_here';
  static const String appName = 'My Flutter App';
  // Global input decoration constants
  static final InputDecoration customInputDecoration = InputDecoration(
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_textFieldBorderRadius),
      borderSide: BorderSide(color: _textFieldBorderColor, width: _textFieldBorderWidth),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_textFieldBorderRadius),
      borderSide: BorderSide(color: _textFieldBorderColor, width: _textFieldBorderWidth),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_textFieldBorderRadius),
    ),
    labelStyle: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500),
  );
}