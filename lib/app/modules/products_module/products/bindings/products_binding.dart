import 'package:get/get.dart';

import '../../../../data/repository/product/products_repo.dart';
import '../controllers/products_controller.dart';

class ProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductsController>(
      () => ProductsController(productsRepo: ProductsRepo()),
    );
  }
}
