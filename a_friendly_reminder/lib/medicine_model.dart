import 'package:flutter/material.dart';

class Medicine{
  final String _name;
  final Duration _interval;
  final BigInt _id;

  Medicine(this._name, this._interval, this._id);

  String get name => _name;
  Duration get interval => _interval;
  BigInt get id => _id;
}