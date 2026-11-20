import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ptsmmmobile/models/product.dart';
import 'package:ptsmmmobile/providers/cart_provider.dart';
import 'package:ptsmmmobile/widgets/product_card.dart';
import 'package:ptsmmmobile/widgets/smartphone_frame.dart';
import 'package:ptsmmmobile/screens/company_profile_screen.dart';

void main() {
  test('Product demo model contains products from database pt-smm', () {
    final products = Product.demoProducts;
    expect(products.isNotEmpty, true);
    expect(products.length, 5);

    final categories = products.map((p) => p.category).toSet();
    expect(categories.isNotEmpty, true);
    expect(categories.contains('Vitamin Anak'), true);
    expect(categories.contains('Produk Perikanan'), true);
  });

  test('CartProvider calculates total quantity and subtotal correctly', () {
    final cart = CartProvider();
    final sample = Product.demoProducts.first;

    cart.addToCart(sample);
    expect(cart.itemCount, 1);
    expect(cart.totalPrice, sample.price);

    cart.addToCart(sample);
    expect(cart.itemCount, 2);
    expect(cart.totalPrice, sample.price * 2);

    cart.removeFromCart(sample.id);
    expect(cart.itemCount, 0);
    expect(cart.totalPrice, 0.0);
  });

  testWidgets('ProductCard renders name, category, and price', (tester) async {
    final product = Product.demoProducts.first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductCard(
            product: product,
            onTap: () {},
            onAddToCart: () {},
          ),
        ),
      ),
    );

    expect(find.text(product.name), findsOneWidget);
    expect(find.text(product.category), findsOneWidget);
    expect(find.text('Detail'), findsOneWidget);
  });

  testWidgets('SmartphoneFrame renders desktop frame simulation when screen is wide', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: SmartphoneFrame(
          child: Text('Konten Mobile SMM'),
        ),
      ),
    );

    expect(find.text('PT Shafa Marwa Multiguna'), findsOneWidget);
    expect(find.text('Konten Mobile SMM'), findsOneWidget);
    expect(find.text(' • Mobile App Simulation'), findsOneWidget);
  });

  testWidgets('SmartphoneFrame renders direct edge-to-edge content on mobile screen', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: SmartphoneFrame(
          child: Text('Konten Layar HP Asli'),
        ),
      ),
    );

    expect(find.text('Konten Layar HP Asli'), findsOneWidget);
    expect(find.text(' • Mobile App Simulation'), findsNothing);
  });

  testWidgets('CompanyProfileScreen renders company details and vision mission', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CompanyProfileScreen(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Profil Perusahaan'), findsOneWidget);
    expect(find.text('Visi & Misi'), findsOneWidget);
    expect(find.text('Tentang Perusahaan'), findsOneWidget);
    expect(find.text('5 Lini Kategori Produk'), findsOneWidget);
  });
}
