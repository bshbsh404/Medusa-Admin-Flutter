import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:medusa_admin/app/modules/components/adaptive_back_button.dart';
import 'package:medusa_admin/app/modules/components/adaptive_filled_button.dart';
import 'package:medusa_admin/app/modules/components/adaptive_icon.dart';
import 'package:medusa_admin/app/modules/components/pick_products/controllers/pick_products_controller.dart';
import 'package:medusa_admin/app/routes/app_pages.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../../../../../../core/utils/colors.dart';
import '../../../../../../data/models/store/product.dart';
import '../../../../../../data/models/store/sales_channel.dart';
import '../../../../../components/pick_products/views/pick_products_view.dart';
import '../../sales_channels/controllers/sales_channels_controller.dart';
import '../components/index.dart';
import '../controllers/sales_channel_details_controller.dart';

class SalesChannelDetailsView extends GetView<SalesChannelDetailsController> {
  const SalesChannelDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediumTextStyle = Theme.of(context).textTheme.titleMedium;
    final disabled = controller.salesChannel.isDisabled != null && controller.salesChannel.isDisabled! ? true : false;
    return GetBuilder<SalesChannelDetailsController>(
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            leading: const AdaptiveBackButton(),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SalesChannelActiveDot(disabled),
                Text(controller.salesChannel.name ?? ''),
              ],
            ),
            bottom: controller.pagingController.itemList?.isEmpty ?? true
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(kToolbarHeight),
                    child: SizedBox(
                      height: kToolbarHeight,
                      child: Row(
                        children: [
                          const SizedBox(width: 4.0),
                          Checkbox(
                              value: controller.selectAll,
                              onChanged: (val) {
                                if (val == null) return;
                                if (val) {
                                  controller.selectedProducts
                                      .addAll(controller.pagingController.itemList?.map((e) => e.id!) ?? []);
                                  controller.selectAll = true;
                                } else {
                                  controller.selectedProducts.clear();
                                  controller.selectAll = false;
                                }
                                controller.update();
                              }),
                          InkWell(
                            onTap: () {},
                            child: Chip(
                              side: const BorderSide(color: Colors.transparent),
                              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(6.0))),
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Filters', style: Theme.of(context).textTheme.titleSmall),
                                  Text(' 0',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(color: ColorManager.primary)),
                                ],
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
            actions: [
              AdaptiveIcon(
                  onPressed: () async {
                    await showModalActionSheet<int>(
                        title: 'Manage Sales Channel',
                        message: controller.salesChannel.name ?? '',
                        context: context,
                        actions: <SheetAction<int>>[
                          const SheetAction(label: 'Edit General Info', key: 0),
                          const SheetAction(label: 'Add Products', key: 1),
                          if (controller.pagingController.itemList?.isEmpty ?? false)
                            const SheetAction(label: 'Delete', isDestructiveAction: true, key: 2),
                        ]).then((value) async {
                      switch (value) {
                        case 0:
                          final result =
                              await Get.toNamed(Routes.ADD_UPDATE_SALES_CHANNEL, arguments: controller.salesChannel);
                          if (result is SalesChannel) {
                            controller.salesChannel = result;
                            controller.update();
                            SalesChannelsController.instance.pagingController.refresh();
                          }
                          break;
                        case 1:
                          final result = await showBarModalBottomSheet(
                            context: context,
                            builder: (context) => PickProductsView(
                              pickProductsReq: PickProductsReq(
                                disabledProducts: controller.pagingController.itemList,
                              ),
                            ),
                          );
                          if (result is PickProductsRes) {
                            final ids = result.selectedProducts.map((e) => e.id!).toList();
                            await controller.addProducts(ids);
                          }
                          break;
                        case 2:
                          await controller.deleteChannel();
                          break;
                      }
                    });
                  },
                  icon: const Icon(Icons.more_horiz))
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: controller.selectedProducts.isNotEmpty ? SalesChannelFAB(controller) : null,
          body: SafeArea(
            child: SlidableAutoCloseBehavior(
              child: PagedListView.separated(
                separatorBuilder: (_, __) => const Divider(height: 0, indent: 16),
                padding: const EdgeInsets.only(bottom: kToolbarHeight * 1.4),
                pagingController: controller.pagingController,
                builderDelegate: PagedChildBuilderDelegate<Product>(
                  itemBuilder: (context, product, index) => ProductCheckboxListTile(product),
                  firstPageProgressIndicatorBuilder: (_) => const Center(child: CircularProgressIndicator.adaptive()),
                  noItemsFoundIndicatorBuilder: (_) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('Start building your channels setup...'),
                      const SizedBox(height: 12.0),
                      Text(
                        'You haven’t added any products to this channels yet,\nbut once you do they will live here.',
                        style: mediumTextStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12.0),
                      AdaptiveFilledButton(
                          onPressed: () async {
                            final result = await showBarModalBottomSheet(
                                context: context,
                                builder: (context) => PickProductsView(
                                        pickProductsReq: PickProductsReq(
                                      disabledProducts: controller.pagingController.itemList,
                                    )));
                            if (result is PickProductsRes) {
                              final ids = result.selectedProducts.map((e) => e.id!).toList();

                              await controller.addProducts(ids);
                            }
                          },
                          child: const Text('Add products'))
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
