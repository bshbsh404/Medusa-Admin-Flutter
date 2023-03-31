import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:medusa_admin/app/modules/orders_module/orders/controllers/orders_controller.dart';
import 'package:medusa_admin/app/routes/app_pages.dart';
import 'dart:io' show Platform;
import '../../../../../core/utils/colors.dart';
import '../../../components/adaptive_button.dart';
import '../../../components/adaptive_icon.dart';
import '../../../draft_orders_module/draft_orders/controllers/draft_orders_controller.dart';

class OrdersAppBar extends StatefulWidget implements PreferredSizeWidget {
  const OrdersAppBar({
    super.key,
    required this.tabController,
    required this.topViewPadding,
  });

  final TabController tabController;
  final double topViewPadding;

  @override
  State<OrdersAppBar> createState() => _OrdersAppBarState();
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight * 2 + topViewPadding);
}

class _OrdersAppBarState extends State<OrdersAppBar> {
  bool collectionSearch = false;
  bool productSearch = false;
  final OrdersController controller = Get.find<OrdersController>();
  final searchCtrl = TextEditingController();
  final searchNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final largeTextStyle = Theme.of(context).textTheme.titleLarge;
    final displayLargeTextStyle = Theme.of(context).textTheme.displayLarge;
    Color lightWhite = Get.isDarkMode ? Colors.white54 : Colors.black54;
    const kDuration = Duration(milliseconds: 200);
    final topViewPadding = MediaQuery.of(context).viewPadding.top;
    final productsText = Obx(() {
      final count = OrdersController.instance.ordersCount.value;
      return Text(count != 0 ? 'Orders ($count)' : 'Orders', overflow: TextOverflow.ellipsis);
    });
    final collectionText = Obx(() {
      final count = DraftOrdersController.instance.draftOrdersCount.value;
      return Text(count != 0 ? 'Drafts ($count)' : 'Drafts', overflow: TextOverflow.ellipsis);
    });

    final androidTabBar = TabBar(
      controller: widget.tabController,
      tabs: [
        Tab(child: productsText),
        Tab(child: collectionText),
      ],
    );

    final iosTabBar = Container(
      height: kToolbarHeight,
      padding: const EdgeInsets.only(left: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              children: [
                Flexible(
                  child: CupertinoButton(
                      padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
                      onPressed: () {
                        widget.tabController.index = 0;
                        setState(() {});
                      },
                      alignment: Alignment.bottomCenter,
                      child: AnimatedDefaultTextStyle(
                          style: widget.tabController.index == 0
                              ? displayLargeTextStyle!
                              : largeTextStyle!.copyWith(color: lightWhite),
                          duration: const Duration(milliseconds: 200),
                          child: productsText)),
                ),
                Flexible(
                  child: CupertinoButton(
                    padding: const EdgeInsets.only(right: 16.0, bottom: 8.0),
                    onPressed: () {
                      widget.tabController.index = 1;
                      setState(() {});
                    },
                    alignment: Alignment.bottomCenter,
                    child: AnimatedDefaultTextStyle(
                        style: widget.tabController.index == 1
                            ? displayLargeTextStyle!
                            : largeTextStyle!.copyWith(color: lightWhite),
                        duration: const Duration(milliseconds: 200),
                        child: collectionText),
                  ),
                ),
              ],
            ),
          ),
          if (widget.tabController.index == 0)
            AdaptiveButton(
                onPressed: () {}, padding: const EdgeInsets.symmetric(horizontal: 16.0), child: const Text('Export')),
        ],
      ),
    );

    final draftsAppBar = AnimatedCrossFade(
        key: const ValueKey(1),
        firstChild: SizedBox(
          height: kToolbarHeight,
          child: Row(
            children: [
              const SizedBox(width: 12.0),
              if (GetPlatform.isIOS)
                Expanded(
                    child: CupertinoSearchTextField(
                  focusNode: searchNode,
                  controller: searchCtrl,
                  placeholder: 'Search for product name, variant title ...',
                  onChanged: (val) {
                    // controller.searchTerm = val;
                    // controller.pagingController.refresh();
                  },
                )),
              if (GetPlatform.isAndroid)
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: TextFormField(
                    style: Theme.of(context).textTheme.titleSmall,
                    focusNode: searchNode,
                    controller: searchCtrl,
                    onChanged: (val) {
                      // controller.searchTerm = val;
                      // controller.pagingController.refresh();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search for product name, variant title ...',
                    ),
                  ),
                )),
              AdaptiveButton(
                  child: const Text('Cancel'),
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    // await Future.delayed(Duration(milliseconds: 150));
                    setState(() {
                      collectionSearch = false;
                      // if (controller.searchTerm.isNotEmpty) {
                      //   controller.searchTerm = '';
                      //   controller.pagingController.refresh();
                      // }
                      searchCtrl.clear();
                    });
                  }),
            ],
          ),
        ),
        secondChild: SizedBox(
          height: kToolbarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AdaptiveIcon(
                  onPressed: () async {
                    setState(() {
                      collectionSearch = true;
                    });
                    await Future.delayed(kDuration);
                    searchNode.requestFocus();
                  },
                  icon: const Icon(CupertinoIcons.search)),
              const SizedBox(width: 6.0),
              AdaptiveIcon(
                  onPressed: () async => await Get.toNamed(Routes.CREATE_DRAFT_ORDER),
                  icon: Platform.isIOS ? const Icon(CupertinoIcons.add) : const Icon(Icons.add)),
            ],
          ),
        ),
        crossFadeState: collectionSearch ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: kDuration);

    final ordersAppBar = AnimatedCrossFade(
        key: const ValueKey(0),
        firstChild: SizedBox(
          height: kToolbarHeight,
          child: Row(
            children: [
              const SizedBox(width: 12.0),
              if (GetPlatform.isIOS)
                Expanded(
                    child: CupertinoSearchTextField(
                  focusNode: searchNode,
                  controller: searchCtrl,
                  placeholder: 'Search for product name, variant title ...',
                  onChanged: (val) {
                    // controller.searchTerm = val;
                    // controller.pagingController.refresh();
                  },
                )),
              if (GetPlatform.isAndroid)
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: TextFormField(
                    style: Theme.of(context).textTheme.titleSmall,
                    focusNode: searchNode,
                    controller: searchCtrl,
                    onChanged: (val) {
                      // controller.searchTerm = val;
                      // controller.pagingController.refresh();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search for product name, variant title ...',
                    ),
                  ),
                )),
              AdaptiveButton(
                  child: const Text('Cancel'),
                  onPressed: () async {
                    FocusScope.of(context).unfocus();
                    // await Future.delayed(Duration(milliseconds: 150));
                    setState(() {
                      productSearch = false;
                      // if (controller.searchTerm.isNotEmpty) {
                      //   controller.searchTerm = '';
                      //   controller.pagingController.refresh();
                      // }
                      searchCtrl.clear();
                    });
                  }),
            ],
          ),
        ),
        secondChild: SizedBox(
          height: kToolbarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AdaptiveIcon(
                      onPressed: () async {
                        setState(() => productSearch = true);
                        await Future.delayed(kDuration);
                        searchNode.requestFocus();
                      },
                      icon: const Icon(CupertinoIcons.search)),
                  const SizedBox(width: 6.0),
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
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(color: ColorManager.primary)),
                        ],
                      ),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (Platform.isAndroid)
                    AdaptiveButton(
                        onPressed: () {},
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: const Text('Export')),
                ],
              ),
            ],
          ),
        ),
        crossFadeState: productSearch ? CrossFadeState.showFirst : CrossFadeState.showSecond,
        duration: kDuration);

    widget.tabController.addListener(() {
      setState(() {
        collectionSearch = false;
        productSearch = false;
      });
    });
    return Container(
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(height: topViewPadding),
          if (Platform.isAndroid) androidTabBar,
          if (Platform.isIOS) iosTabBar,
          if (widget.tabController.index == 0) ordersAppBar,
          if (widget.tabController.index == 1) draftsAppBar,
        ],
      ),
    );
  }
}