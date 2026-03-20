import 'package:flutter_test/flutter_test.dart';
import 'package:swap/features/product/domain/usecases/add_product.dart';
import 'package:swap/features/product/domain/usecases/delete_product.dart';
import 'package:swap/features/product/domain/usecases/fetch_products_page.dart';
import 'package:swap/features/product/domain/usecases/get_products.dart';
import 'package:swap/features/product/domain/usecases/update_product.dart';
import 'package:swap/features/shared/domain/models/product.dart';

import '../../../helpers/fake_product_repository.dart';

void main() {
  Product buildProduct({
    required String id,
    required DateTime createdAt,
    String ownerId = 'owner',
  }) {
    return Product(
      id: id,
      ownerId: ownerId,
      title: 'Item $id',
      description: 'Desc $id',
      price: 100,
      category: 'Electronics',
      imageUrls: const ['https://example.com/img.png'],
      createdAt: createdAt,
      likesCount: 0,
      isAvailable: true,
      isForSwap: false,
    );
  }

  test('get products returns first page', () async {
    final now = DateTime.now();
    final repo = FakeProductRepository(
      seed: [
        buildProduct(id: 'p1', createdAt: now.subtract(const Duration(days: 1))),
        buildProduct(id: 'p2', createdAt: now),
      ],
    );
    final usecase = GetProducts(repo);
    final page = await usecase(limit: 1).first;
    expect(page.items.length, 1);
    expect(page.items.first.id, 'p2');
  });

  test('fetch products page paginates', () async {
    final now = DateTime.now();
    final repo = FakeProductRepository(
      seed: [
        buildProduct(id: 'p1', createdAt: now.subtract(const Duration(days: 2))),
        buildProduct(id: 'p2', createdAt: now.subtract(const Duration(days: 1))),
        buildProduct(id: 'p3', createdAt: now),
      ],
    );
    final fetch = FetchProductsPage(repo);
    final first = await fetch(limit: 2);
    expect(first.items.length, 2);
    final second = await fetch(limit: 2, startAfter: first.nextCursor);
    expect(second.items.length, 1);
    expect(second.items.first.id, 'p1');
  });

  test('add product inserts new item', () async {
    final repo = FakeProductRepository();
    final add = AddProduct(repo);
    await add.call(
      product: buildProduct(id: '', createdAt: DateTime.now()),
    );
    final page = await repo.fetchProductsPage();
    expect(page.items.length, 1);
  });

  test('update product replaces item', () async {
    final repo = FakeProductRepository(
      seed: [buildProduct(id: 'p1', createdAt: DateTime.now())],
    );
    final update = UpdateProduct(repo);
    final updated = buildProduct(id: 'p1', createdAt: DateTime.now()).copyWith(title: 'Updated');
    await update(updated);
    final fetched = await repo.getProduct('p1');
    expect(fetched.title, 'Updated');
  });

  test('delete product removes item', () async {
    final repo = FakeProductRepository(
      seed: [buildProduct(id: 'p1', createdAt: DateTime.now())],
    );
    final del = DeleteProduct(repo);
    await del('p1');
    final page = await repo.fetchProductsPage();
    expect(page.items.isEmpty, true);
  });
}
