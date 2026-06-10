
import '../model/product_model.dart';
class MockData {
  static const List<CategoryModel> categories = [
    CategoryModel(id: '1', name: 'کباب‌ها', imageUrl: 'assets/images/cafe.png'),
    CategoryModel(id: '2', name: 'پیش غذا', imageUrl: 'assets/images/cafe.png'),
    CategoryModel(id: '3', name: 'نوشیدنی', imageUrl: 'assets/images/cafe.png'),
  ];

  static const List<ProductModel> products = [
    ProductModel(
      id: '101',
      name: 'چلو کباب کوبیده مخصوص',
      description: 'دو سیخ کباب کوبیده گوسفندی ۱۲۰ گرمی به همراه برنج صدری ایرانی، گوجه کبابی و کره محلی',
      price: 250000,
      imageUrl: 'assets/images/food.jpg',
      rating: 4.8,
      reviewCount: 124,
      isPopular: true,
      categoryId: '1',
    ),
    ProductModel(
      id: '102',
      name: 'چلو جوجه کباب زعفرانی',
      description: '۳۰۰ گرم سینه مرغ تازه مزه‌دار شده با زعفران خالص، آبلیمو و پیاز',
      price: 220000,
      imageUrl: 'assets/images/food.jpg',
      rating: 4.5,
      reviewCount: 89,
      isPopular: true,
      categoryId: '1',
    ),
    ProductModel(
      id: '103',
      name: 'کباب شیشلیک شاندیز',
      description: '۵۰۰ گرم دنده گوسفندی طعم‌دار شده با سس مخصوص کباب‌سرا',
      price: 650000,
      imageUrl: 'assets/images/food.jpg',
      rating: 4.9,
      reviewCount: 210,
      isPopular: false,
      categoryId: '1',
    ),
    ProductModel(
      id: '104',
      name: 'زیتون پرورده رودبار',
      description: 'زیتون بدون هسته، رب انار، گردو و سبزیجات معطر محلی',
      price: 85000,
      imageUrl: 'assets/images/food.jpg',
      rating: 4.7,
      reviewCount: 56,
      isPopular: false,
      categoryId: '2',
    ),
    ProductModel(
      id: '105',
      name: 'دوغ آبعلی شیشه‌ای',
      description: 'دوغ محلی گازدار با طعم نعناع',
      price: 25000,
      imageUrl: 'assets/images/food.jpg',
      rating: 4.6,
      reviewCount: 340,
      isPopular: true,
      categoryId: '3',
    ),
  ];
}