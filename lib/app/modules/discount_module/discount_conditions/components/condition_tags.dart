import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:medusa_admin/app/data/models/store/index.dart';
import 'package:medusa_admin/app/data/repository/product_tag/product_tag_repo.dart';
import 'package:medusa_admin/app/modules/discount_module/discount_conditions/components/condition_tag_list_tile.dart';
import '../../../components/adaptive_back_button.dart';
import '../../../components/adaptive_button.dart';
import '../controllers/discount_conditions_controller.dart';
import 'condition_operator_card.dart';

class ConditionTagView extends StatelessWidget {
  const ConditionTagView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const space = SizedBox(height: 12.0);
    return GetBuilder<ConditionTagController>(
      init: ConditionTagController(tagRepo: ProductTagRepo()),
      builder: (controller) {
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                leading: const AdaptiveBackButton(),
                title: const Text('Choose tags'),
                actions: [
                  AdaptiveButton(
                      onPressed: controller.selectedTags.isNotEmpty
                          ? () {
                              final res = DiscountConditionRes(
                                  operator: controller.discountConditionOperator,
                                  productTags: controller.selectedTags,
                                  conditionType: DiscountConditionType.productTags);
                              Get.back(result: res);
                            }
                          : null,
                      child: const Text('Save')),
                ],
                bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(kToolbarHeight),
                    child: Container(
                      alignment: Alignment.center,
                      height: kToolbarHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: const CupertinoSearchTextField(),
                    )),
              ),
              if (!controller.updateMode)
                SliverToBoxAdapter(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                  child: Column(
                    children: [
                      ConditionOperatorCard(
                        conditionOperator: DiscountConditionOperator.inn,
                        groupValue: controller.discountConditionOperator,
                        onTap: (val) {
                          controller.discountConditionOperator = val;
                          controller.update();
                        },
                      ),
                      space,
                      ConditionOperatorCard(
                        conditionOperator: DiscountConditionOperator.notIn,
                        groupValue: controller.discountConditionOperator,
                        onTap: (val) {
                          controller.discountConditionOperator = val;
                          controller.update();
                        },
                      ),
                    ],
                  ),
                )),
              SliverSafeArea(
                top: false,
                sliver: PagedSliverList.separated(
                  separatorBuilder: (_, __) => const Divider(height: 0, indent: 16),
                  pagingController: controller.pagingController,
                  builderDelegate: PagedChildBuilderDelegate<ProductTag>(
                    itemBuilder: (context, tag, index) => ConditionTagListTile(
                        tag: tag,
                        value: controller.selectedTags.map((e) => e.id!).toList().contains(tag.id),
                        enabled: !controller.disabledTags.map((e) => e.id!).toList().contains(tag.id),
                        onChanged: (val) {
                          if (val == null) return;
                          if (val) {
                            controller.selectedTags.add(tag);
                          } else {
                            controller.selectedTags.removeWhere((e) => e.id == tag.id);
                          }
                          controller.update();
                        }),
                    firstPageProgressIndicatorBuilder: (context) =>
                        const Center(child: CircularProgressIndicator.adaptive()),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ConditionTagController extends GetxController {
  ConditionTagController({required this.tagRepo});
  final ProductTagRepo tagRepo;
  List<ProductTag> selectedTags = <ProductTag>[];
  DiscountConditionOperator discountConditionOperator = DiscountConditionOperator.inn;
  final PagingController<int, ProductTag> pagingController =
      PagingController(firstPageKey: 0, invisibleItemsThreshold: 6);
  final int _pageSize = 20;
  final List<ProductTag> disabledTags = Get.arguments ?? [];
  bool get updateMode => disabledTags.isNotEmpty;
  @override
  void onInit() {
    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.onInit();
  }

  Future<void> _fetchPage(int pageKey) async {
    final result = await tagRepo.retrieveProductTags(
      queryParameters: {
        'offset': pagingController.itemList?.length ?? 0,
        'limit': _pageSize,
      },
    );

    result.when((success) {
      final isLastPage = success.tags!.length < _pageSize;
      update([5]);
      if (isLastPage) {
        pagingController.appendLastPage(success.tags!);
      } else {
        final nextPageKey = pageKey + success.tags!.length;
        pagingController.appendPage(success.tags!, nextPageKey);
      }
    }, (error) {
      pagingController.error = error.message;
    });
  }
}
