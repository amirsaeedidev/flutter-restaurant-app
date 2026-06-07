import 'package:flutter/material.dart';
import '../../../core/constants/mock_data.dart';
import '../../../core/model/product_model.dart';

class HomeProvider extends ChangeNotifier {
  // کتگوری انتخاب‌شده — null یعنی «همه»
  String? _selectedCategoryId;

  String? get selectedCategoryId => _selectedCategoryId;

  List<CategoryModel> get categories => MockData.categories;

  // محصولات فیلترشده بر اساس کتگوری
  List<ProductModel> get filteredProducts {
    if (_selectedCategoryId == null) return MockData.products;
    return MockData.products
        .where((p) => p.categoryId == _selectedCategoryId)
        .toList();
  }

  // محصولات پرطرفدار (برای اسلایدر)
  List<ProductModel> get popularProducts =>
      MockData.products.where((p) => p.isPopular).toList();

  void selectCategory(String? categoryId) {
    // اگه همون کتگوری رو دوباره بزنه، deselect میشه (همه نشون داده میشه)
    _selectedCategoryId =
        (_selectedCategoryId == categoryId) ? null : categoryId;
    notifyListeners();
  }
}