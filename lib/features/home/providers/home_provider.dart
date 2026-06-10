import 'package:flutter/material.dart';
import '../../../core/constants/mock_data.dart';
import '../../../core/model/product_model.dart';

class HomeProvider extends ChangeNotifier {
  String? _selectedCategoryId;
  String _searchQuery = '';

  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool get isSearching => _searchQuery.isNotEmpty;

  List<CategoryModel> get categories => MockData.categories;

  List<ProductModel> get filteredProducts {
    var products = MockData.products;

    // فیلتر کتگوری
    if (_selectedCategoryId != null) {
      products = products
          .where((p) => p.categoryId == _selectedCategoryId)
          .toList();
    }

    // فیلتر سرچ
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      products = products
          .where((p) => p.name.toLowerCase().contains(q))
          .toList();
    }

    return products;
  }

  List<ProductModel> get popularProducts =>
      MockData.products.where((p) => p.isPopular).toList();

  void selectCategory(String? categoryId) {
    _selectedCategoryId =
        (_selectedCategoryId == categoryId) ? null : categoryId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}