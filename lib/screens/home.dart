import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:shane_store/models/product.dart';
import 'package:http/http.dart' as http;
import 'package:shane_store/widgets/product.dart';

class HomeScreenController extends GetxController {
  var products = <ProductModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();

    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.toggle();
      final url = Uri.https('fakestoreapi.com', '/products');
      final response = await http.get(url);
      isLoading.toggle();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List<dynamic> body = jsonDecode(response.body);

        for (var product in body) {
          products.add(ProductModel.fromJson(product));
        }
      }
    } catch (e) {
      log("error occurred: ${e.toString()}");
    }
  }
}

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.put(HomeScreenController());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final products = controller.products;

      return Scaffold(
          appBar: AppBar(
            title: const Text('Products'),
            backgroundColor: Colors.grey.shade100,
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10,
              ),
              child: isLoading
                  ? showLoading()
                  : RefreshIndicator(
                      onRefresh: controller.fetchProducts,
                      child: MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        itemCount: products.length,
                        itemBuilder: (context, index) => ProductTile(
                          products[index],
                        ),
                      ),
                    ),
            ),
          ));
    });
  }

  Widget showLoading() => const Center(
        child: CircularProgressIndicator(),
      );
}
