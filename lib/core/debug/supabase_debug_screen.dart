import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDebugScreen extends StatefulWidget {
  const SupabaseDebugScreen({super.key});

  @override
  State<SupabaseDebugScreen> createState() => _SupabaseDebugScreenState();
}

class _SupabaseDebugScreenState extends State<SupabaseDebugScreen> {
  final List<_TestResult> _results = [];
  bool _running = false;

  @override
  void initState() {
    super.initState();

    // ── تست فوری بدون هیچ فیلتری (قبل از _runTests) ──
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final test = await Supabase.instance.client
            .from('categories')
            .select();
        print('RAW CATEGORIES: $test');
      } catch (e) {
        print('ERROR in RAW CATEGORIES: $e');
      }
    });

    _runTests();
  }

  Future<void> _runTests() async {
    setState(() {
      _results.clear();
      _running = true;
    });

    final client = Supabase.instance.client;

    // ── تست ۱: اتصال پایه ──
    await _test('اتصال به Supabase', () async {
      final url = client.rest.url;
      return 'URL: $url';
    });

    // ── تست ۲: Auth state ──
    await _test('وضعیت Auth', () async {
      final user = client.auth.currentUser;
      return user == null
          ? 'کاربر لاگین نیست (anonymous)'
          : 'لاگین: ${user.id}';
    });

    // ── تست ۳: categories ──
    await _test('جدول categories', () async {
      final res = await client.from('categories').select('id, name').limit(5);
      final list = res as List;
      if (list.isEmpty) return '⚠️ جدول خالیه!';
      return '✅ ${list.length} ردیف — ${list.map((r) => r['name']).join(', ')}';
    });

    // ── تست ۴: categories با فیلتر is_active ──
    await _test('categories (is_active=true)', () async {
      final res = await client
          .from('categories')
          .select('id, name')
          .eq('is_active', true);
      final list = res as List;
      return '${list.length} کتگوری فعال';
    });

    // ── تست ۵: products ──
    await _test('جدول products', () async {
      final res = await client.from('products').select('id, name').limit(5);
      final list = res as List;
      if (list.isEmpty) return '⚠️ جدول خالیه!';
      return '✅ ${list.length} محصول — ${list.map((r) => r['name']).join(', ')}';
    });

    // ── تست ۶: products با فیلتر is_active ──
    await _test('products (is_active=true)', () async {
      final res = await client
          .from('products')
          .select('id, name')
          .eq('is_active', true);
      final list = res as List;
      return '${list.length} محصول فعال';
    });

    // ── تست ۷: banners ──
    await _test('جدول banners', () async {
      final res = await client.from('banners').select('id, title').limit(5);
      final list = res as List;
      if (list.isEmpty) return '⚠️ جدول خالیه یا policy نداره!';
      return '✅ ${list.length} بنر';
    });

    // ── تست ۸: ستون‌های categories ──
    await _test('ستون‌های categories', () async {
      final res = await client.from('categories').select().limit(1);
      final list = res as List;
      if (list.isEmpty) return '⚠️ خالی';
      final keys = (list[0] as Map).keys.toList();
      return 'ستون‌ها: ${keys.join(', ')}';
    });

    // ── تست ۹: ستون‌های products ──
    await _test('ستون‌های products', () async {
      final res = await client.from('products').select().limit(1);
      final list = res as List;
      if (list.isEmpty) return '⚠️ خالی';
      final keys = (list[0] as Map).keys.toList();
      return 'ستون‌ها: ${keys.join(', ')}';
    });

    setState(() => _running = false);
  }

  Future<void> _test(String name, Future<String> Function() fn) async {
    try {
      final result = await fn();
      setState(() => _results.add(_TestResult(name, result, true)));
    } on PostgrestException catch (e) {
      setState(() => _results.add(
            _TestResult(name, 'PostgrestError: ${e.message} (${e.code})', false),
          ));
    } catch (e) {
      setState(() => _results.add(_TestResult(name, 'Error: $e', false)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Debug'),
        actions: [
          if (!_running)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _runTests,
            ),
        ],
      ),
      body: _running && _results.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_running)
                  const LinearProgressIndicator(),
                const SizedBox(height: 8),
                ..._results.map((r) => Card(
                      color: r.success
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Text(r.success ? '✅' : '❌'),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(r.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ),
                            ]),
                            const SizedBox(height: 4),
                            Text(r.message,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: r.success
                                        ? Colors.green.shade800
                                        : Colors.red.shade800)),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
    );
  }
}

class _TestResult {
  final String name, message;
  final bool success;
  _TestResult(this.name, this.message, this.success);
}