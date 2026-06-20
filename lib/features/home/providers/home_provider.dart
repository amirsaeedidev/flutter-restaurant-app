import 'package:flutter/material.dart';
// import حذف شد: '../../../core/constants/mock_data.dart';
import '../../../core/model/product_model.dart';
import '../../../core/services/category_service.dart'; // اضافه شد
import '../../../core/services/product_service.dart'; // اضافه شد

class HomeProvider extends ChangeNotifier {
  String? _selectedCategoryId;
  String _searchQuery = '';

  List<CategoryModel> _categories = []; // به جای MockData.categories
  List<ProductModel> _products = [];     // به جای MockData.products
  bool _isLoading = false;
  String? _error;

  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool get isSearching => _searchQuery.isNotEmpty;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  HomeProvider() {
    fetchAllData(); // بارگذاری اولیه
  }

  Future<void> fetchAllData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        CategoryService.getCategories(),
        ProductService.getProducts(),
      ]);
      _categories = results[0] as List<CategoryModel>;
      _products = results[1] as List<ProductModel>;
    } catch (e) {
      _error = 'خطا در دریافت اطلاعات: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => fetchAllData();

  // ----- منطق فیلتر و جستجو (دست‌نخورده، فقط مرجع محصولات تغییر کرده) -----
  List<ProductModel> get filteredProducts {
    var products = _products; // قبلاً MockData.products بود

    if (_selectedCategoryId != null) {
      products = products
          .where((p) => p.categoryId == _selectedCategoryId)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      products = products
          .where((p) => p.name.toLowerCase().contains(q))
          .toList();
    }

    return products;
  }

  List<ProductModel> get popularProducts =>
      _products.where((p) => p.isPopular).toList();

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