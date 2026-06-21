import 'package:flutter/material.dart';
import '../../../core/model/banner_model.dart';
import '../../../core/model/product_model.dart';
import '../../../core/services/banner_service.dart';
import '../../../core/services/category_service.dart';
import '../../../core/services/product_service.dart';

class HomeProvider extends ChangeNotifier {
  // ── State ──
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  List<BannerModel> _banners = [];
  String? _selectedCategoryId;
  String _searchQuery = '';
  bool _loading = false;
  String? _error;

  // ── Getters ──
  List<CategoryModel> get categories => _categories;
  List<BannerModel> get banners => _banners;
  bool get loading => _loading;
  String? get error => _error;
  String? get selectedCategoryId => _selectedCategoryId;
  bool get isSearching => _searchQuery.isNotEmpty;

  List<ProductModel> get filteredProducts {
    var list = _products;
    if (_selectedCategoryId != null) {
      list = list.where((p) => p.categoryId == _selectedCategoryId).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  List<ProductModel> get popularProducts =>
      _products.where((p) => p.isPopular).toList();

  HomeProvider() {
    _init();
  }

  // ── بارگذاری همزمان همه داده‌ها ──
  Future<void> _init() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // همه درخواست‌ها موازی اجرا میشن
      final results = await Future.wait([
        CategoryService.getCategories(),
        ProductService.getProducts(),
        BannerService.getBanners(),
      ]);

      _categories = results[0] as List<CategoryModel>;
      _products = results[1] as List<ProductModel>;
      _banners = results[2] as List<BannerModel>;
      print('✅ Categories: ${_categories.length}');
      print('✅ Products: ${_products.length}');
      print('✅ Banners: ${_banners.length}');
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ── Refresh دستی ──
  Future<void> refresh() => _init();

  // ── تغییر کتگوری ──
  void selectCategory(String? id) {
    _selectedCategoryId = (_selectedCategoryId == id) ? null : id;
    notifyListeners();
  }

  // ── جستجو ──
  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
