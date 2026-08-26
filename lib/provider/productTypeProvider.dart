import 'package:flutter/material.dart';
import 'package:project/helper/utils/labelKeys.dart';

class ProductTypeProvider extends ChangeNotifier {
  List<String> productTypes = [noneLabel, vegLabel, nonVegLabel];
}
