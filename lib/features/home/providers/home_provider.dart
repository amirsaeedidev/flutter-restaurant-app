import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/model/banner_model.dart';
import '../../../core/model/product_model.dart';
import '../../../core/services/banner_service.dart';
import '../../../core/services/category_service.dart';
import '../../../core/services/product_service.dart';
import '../../../core/services/supabase_service.dart';

class HomeProvider extends ChangeNotifier {
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  List<BannerModel> _banners = [];
  String? _selectedCategoryId;
  String _searchQuery = '';
  bool _loading = false;
  bool _disposed = false;
  String? _error;
  RealtimeChannel? _realtimeChannel;
  Timer? _refreshDebounce;

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<ProductModel> get products => List.unmodifiable(_products);
  List<BannerModel> get banners => List.unmodifiable(_banners);
  bool get loading => _loading;
  String? get error => _error;
  String? get selectedCategoryId => _selectedCategoryId;
  bool get isSearching => _searchQuery.isNotEmpty;

  List<ProductModel> get filteredProducts {
    Iterable<ProductModel> result = _products;
    if (_selectedCategoryId != null) {
      result = result.where((product) => product.categoryId == _selectedCategoryId);
    }
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      result = result.where((product) => product.name.toLowerCase().contains(query));
    }
    return result.toList(growable: false);
  }

  List<ProductModel> get popularProducts =>
      _products.where((product) => product.isPopular).toList(growable: false);

  HomeProvider() {
    _subscribeToChanges();
    unawaited(refresh());
  }

  void _subscribeToChanges() {
    final client = SupabaseService.client;
    _realtimeChannel = client.channel('restaurant-home-live')
      ..onPostgresChanges(event: PostgresChangeEvent.all, schema: 'public', table: 'banners', callback: (_) => _scheduleRefresh())
      ..onPostgresChanges(event: PostgresChangeEvent.all, schema: 'public', table: 'products', callback: (_) => _scheduleRefresh())
      ..onPostgresChanges(event: PostgresChangeEvent.all, schema: 'public', table: 'categories', callback: (_) => _scheduleRefresh())
      ..subscribe();
  }

  void _scheduleRefresh() {
    _refreshDebounce?.cancel();
    _refreshDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!_disposed) unawaited(refresh());
    });
  }

  Future<void> refresh() async {
    if (_disposed) return;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait<Object>([
        CategoryService.getCategories(),
        ProductService.getProducts(),
        BannerService.getBanners(),
      ]);
      if (_disposed) return;
      _categories = results[0] as List<CategoryModel>;
      _products = results[1] as List<ProductModel>;
      _banners = results[2] as List<BannerModel>;
    } catch (error) {
      if (_disposed) return;
      _error = error.toString().replaceFirst('Exception: ', '');
    } finally {
      if (!_disposed) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  void selectCategory(String? id) {
    _selectedCategoryId = _selectedCategoryId == id ? null : id;
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

  @override
  void dispose() {
    _disposed = true;
    _refreshDebounce?.cancel();
    final channel = _realtimeChannel;
    if (channel != null) unawaited(SupabaseService.client.removeChannel(channel));
    super.dispose();
  }
}
