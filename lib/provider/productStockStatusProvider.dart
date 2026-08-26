import 'package:flutter/material.dart';
import 'package:project/helper/utils/labelKeys.dart';

class ProductStockStatusProvider extends ChangeNotifier {
  List<String> productStockStatus = [availableLabel, soldOutLabel];
}
