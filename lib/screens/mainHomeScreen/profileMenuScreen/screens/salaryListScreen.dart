import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/salary.dart';

class SalaryListScreen extends StatefulWidget {
  const SalaryListScreen({Key? key}) : super(key: key);

  @override
  State<SalaryListScreen> createState() => _SalaryListScreenState();
}

class _SalaryListScreenState extends State<SalaryListScreen> {
  ScrollController scrollController = ScrollController();

  scrollListener() {
    var nextPageTrigger = 0.7 * scrollController.position.maxScrollExtent;
    if (scrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        if (context.read<SalaryProvider>().hasMoreData) {
          callApi();
        }
      }
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    Future.delayed(Duration.zero).then((value) async {
      scrollController.addListener(scrollListener);
      callApi(reset: true);
    });
    super.initState();
  }

  callApi({bool? reset}) async {
    if (reset == true) {
      context.read<SalaryProvider>().offset = 0;
      context.read<SalaryProvider>().mySalaries = [];
    }

    Map<String, String> params = {};

    context.read<SalaryProvider>().getSalaryProvider(
          params: params,
          context: context,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(
        context: context,
        title: CustomTextLabel(
          jsonKey: salaryLabel,
          style: TextStyle(color: ColorsRes.mainTextColor),
        ),
      ),
      body: setRefreshIndicator(
        refreshCallback: () {
          return callApi(reset: true);
        },
        child: Consumer<SalaryProvider>(
          builder: (context, salaryDataProvider, _) {
            if (salaryDataProvider.salaryState == SalaryState.initial || salaryDataProvider.salaryState == SalaryState.loading) {
              return _getSalaryListShimmer();
            } else if (salaryDataProvider.salaryState == SalaryState.loaded ||
                salaryDataProvider.salaryState == SalaryState.loadingMore) {
              return Column(
                children: List.generate(
                  salaryDataProvider.mySalaries.length,
                  (index) => _getSalaryItemWidget(salaryDataProvider.mySalaries[index]),
                ),
              );
            } else {
              return Center(
                child: DefaultBlankItemMessageScreen(
                  image: "no_transaction",
                  title: getTranslatedValue(context, emptySalaryMessageLabel),
                  description: getTranslatedValue(context, emptySalaryDescriptionLabel),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _getSalaryItemWidget(SalaryData salaryData) {
    return Container(
      padding: EdgeInsets.all(Constant.paddingOrMargin10),
      margin: EdgeInsets.symmetric(
        vertical: Constant.paddingOrMargin5,
        horizontal: Constant.paddingOrMargin10,
      ),
      decoration: DesignConfig.boxDecoration(
        Theme.of(context).cardColor,
        10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: CustomTextLabel(
                  text: "${getTranslatedValue(context, idLabel)} #${salaryData.id}",
                  softWrap: true,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: ColorsRes.mainTextColor,
                  ),
                ),
              ),
              SizedBox(width: Constant.paddingOrMargin5),
              CustomTextLabel(
                text: salaryData.paidOn?.isNotEmpty == true ? salaryData.paidOn! : "-",
                style: TextStyle(fontWeight: FontWeight.w500, color: ColorsRes.mainTextColor),
              ),
            ],
          ),
          SizedBox(height: Constant.paddingOrMargin5),
          Divider(height: 1, color: ColorsRes.grey, thickness: 0),
          SizedBox(height: Constant.paddingOrMargin5),
          CustomTextLabel(
            jsonKey: nameLabel,
            style: TextStyle(color: ColorsRes.grey),
            softWrap: true,
          ),
          SizedBox(height: Constant.paddingOrMargin2),
          CustomTextLabel(
            text: salaryData.deliveryBoyName?.isNotEmpty == true ? salaryData.deliveryBoyName! : "-",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: ColorsRes.mainTextColor,
            ),
            softWrap: true,
          ),
          if (salaryData.message != null && salaryData.message!.isNotEmpty) ...[
            SizedBox(height: Constant.paddingOrMargin10),
            CustomTextLabel(
              jsonKey: messageLabel,
              style: TextStyle(color: ColorsRes.grey),
              softWrap: true,
            ),
            SizedBox(height: Constant.paddingOrMargin2),
            CustomTextLabel(
              text: salaryData.message!,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: ColorsRes.mainTextColor,
              ),
              softWrap: true,
            ),
          ],
          SizedBox(height: Constant.paddingOrMargin10),
          Divider(height: 1, color: ColorsRes.grey, thickness: 0),
          SizedBox(height: Constant.paddingOrMargin5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomTextLabel(
                jsonKey: amountLabel,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: ColorsRes.mainTextColor,
                ),
                softWrap: true,
              ),
              CustomTextLabel(
                text: salaryData.amount?.isNotEmpty == true ? salaryData.amount!.currency : "-",
                style: TextStyle(fontWeight: FontWeight.bold, color: ColorsRes.appColor),
                softWrap: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _getSalaryListShimmer() {
    return SingleChildScrollView(
      child: Column(
        children: List.generate(10, (index) => _salaryItemShimmer()),
      ),
    );
  }

  Widget _salaryItemShimmer() {
    return CustomShimmer(
      margin: EdgeInsets.symmetric(
        vertical: Constant.paddingOrMargin10,
        horizontal: Constant.paddingOrMargin10,
      ),
      height: 180,
      width: context.width,
    );
  }
}
