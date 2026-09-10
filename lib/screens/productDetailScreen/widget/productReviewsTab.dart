import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

class ProductReviewsTab extends StatefulWidget {
  final String productId;

  const ProductReviewsTab({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  State<ProductReviewsTab> createState() => _ProductReviewsTabState();
}

class _ProductReviewsTabState extends State<ProductReviewsTab> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    Future.delayed(Duration.zero, () => _callApi(true));
  }

  void _scrollListener() {
    final trigger = 0.7 * _scrollController.position.maxScrollExtent;
    if (_scrollController.position.pixels > trigger) {
      if (mounted && context.read<RatingListProvider>().hasMoreData) {
        _callApi(false);
      }
    }
  }

  Future<void> _callApi(bool reset) async {
    if (reset) {
      context.read<RatingListProvider>().offset = 0;
      context.read<RatingListProvider>().ratings = [];
    }
    await context.read<RatingListProvider>().getRatingApiProvider(
      params: {ApiAndParams.productId: widget.productId},
      context: context,
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RatingListProvider>(
      builder: (context, provider, _) {
        if (provider.ratingState == RatingState.initial ||
            provider.ratingState == RatingState.loading) {
          return ListView(
            children: List.generate(
              5,
              (_) => CustomShimmer(
                width: context.width,
                height: 120,
                margin: EdgeInsetsDirectional.only(top: 10, start: 10, end: 10),
                borderRadius: 10,
              ),
            ),
          );
        }

        if (provider.ratingState == RatingState.empty ||
            provider.ratingState == RatingState.error) {
          return Center(
            child: CustomTextLabel(
              text: provider.ratingState == RatingState.error
                  ? provider.message
                  : getTranslatedValue(context, noReviewsYetLabel),
              style: TextStyle(color: ColorsRes.subTitleTextColor, fontSize: 14),
            ),
          );
        }

        // Only reach here when state is loaded or loadingMore
        // (productRatingData is guaranteed to be initialized)
        if (provider.ratingState != RatingState.loaded &&
            provider.ratingState != RatingState.loadingMore) {
          return const SizedBox.shrink();
        }

        final allReviews = provider.ratings;
        final filtered = _searchQuery.isEmpty
            ? allReviews
            : allReviews
                .where((r) =>
                    (r.review ?? '').toLowerCase().contains(_searchQuery) ||
                    (r.user?.name ?? '').toLowerCase().contains(_searchQuery))
                .toList();

        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (provider.ratings.isNotEmpty) ? _buildRatingSummary(context, provider) : const SizedBox.shrink(),
             (provider.ratings.isNotEmpty) ? const SizedBox(height: 12): const SizedBox.shrink(),
              // _buildSearchBar(context),
              // const SizedBox(height: 12),
              (provider.ratings.isNotEmpty) ? _buildReviewsList(context, filtered) : Center(
                      child: Padding(
                        padding: EdgeInsetsDirectional.only(top: MediaQuery.of(context).size.height * 0.1),
                        child: DefaultBlankItemMessageScreen(
                          image: "no_order_icon",
                          title: noDataLabel,
                          description: noReviewsYetLabel,
                          buttonTitle: tryAgainLabel,
                          callback: (){_callApi(true);},
                        ),
                      ),
                    ),
              if (provider.ratingState == RatingState.loadingMore)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: CircularProgressIndicator(color: ColorsRes.appColor),
                  ),
                ),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRatingSummary(BuildContext context, RatingListProvider provider) {
    final data = provider.productRatingData;
    final avg = double.tryParse(data.averageRating ?? '0') ?? 0;
    final fiveStar = int.tryParse(data.fiveStarRating ?? '0') ?? 0;
    final fourStar = int.tryParse(data.fourStarRating ?? '0') ?? 0;
    final threeStar = int.tryParse(data.threeStarRating ?? '0') ?? 0;
    final twoStar = int.tryParse(data.twoStarRating ?? '0') ?? 0;
    final oneStar = int.tryParse(data.oneStarRating ?? '0') ?? 0;
    final total = fiveStar + fourStar + threeStar + twoStar + oneStar;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextLabel(
            jsonKey: customerRatingLabel,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ColorsRes.mainTextColor,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: ColorsRes.appColorAmber, size: 24),
                        const SizedBox(width: 4),
                        CustomTextLabel(
                          text: avg.toStringAsFixed(1),
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ColorsRes.mainTextColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CustomTextLabel(
                      jsonKey: totalReviewsLabel,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: ColorsRes.subTitleTextColor),
                    ),
                    const SizedBox(height: 4),
                    CustomTextLabel(
                      text: _formatCount(provider.totalData),
                      style: TextStyle(
                        fontSize: 14,
                        color: ColorsRes.mainTextColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _buildRatingBar(context, 5, fiveStar, total),
                      _buildRatingBar(context, 4, fourStar, total),
                      _buildRatingBar(context, 3, threeStar, total),
                      _buildRatingBar(context, 2, twoStar, total),
                      _buildRatingBar(context, 1, oneStar, total),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(BuildContext context, int star, int count, int total) {
    final fraction = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          CustomTextLabel(
            text: '$star',
            style: TextStyle(fontSize: 12, color: ColorsRes.subTitleTextColor),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                minHeight: 6,
                backgroundColor: Theme.of(context).dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(ColorsRes.appColor),
              ),
            ),
          ),
          const SizedBox(width: 6),
          SizedBox(
            width: 30,
            child: CustomTextLabel(
              text: _formatCount(count),
              style: TextStyle(fontSize: 11, color: ColorsRes.subTitleTextColor),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList(BuildContext context, List<ProductRatingList> reviews) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextLabel(
            jsonKey: allWrittenReviewsLabel,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ColorsRes.mainTextColor,
            ),
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: CustomTextLabel(
                  jsonKey: noReviewsYetLabel,
                  style: TextStyle(color: ColorsRes.subTitleTextColor, fontSize: 14),
                ),
              ),
            )
          else
            ...reviews.map((r) => _buildReviewCard(context, r)).toList(),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, ProductRatingList review) {
    final rate = int.tryParse(review.rate ?? '0') ?? 0;
    final name = review.user?.name?.isNotEmpty == true ? review.user!.name! : getTranslatedValue(context, anonymousLabel);
    final reviewText = review.review ?? '';
    final date = _formatDate(review.updatedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildRatingBadge(rate),
              const SizedBox(width: 10),
              Expanded(
                child: CustomTextLabel(
                  text: name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ColorsRes.mainTextColor,
                  ),
                ),
              ),
              CustomTextLabel(
                text: date,
                style: TextStyle(fontSize: 12, color: ColorsRes.subTitleTextColor),
              ),
            ],
          ),
          if (reviewText.isNotEmpty) ...[
            const SizedBox(height: 8),
            _ExpandableText(text: reviewText),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingBadge(int rate) {
    Color bg;
    if (rate >= 4) {
      bg = ColorsRes.appColor;
    } else if (rate == 3) {
      bg = ColorsRes.appColorOrange;
    } else {
      bg = ColorsRes.appColorRed;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, color: ColorsRes.appColorWhite, size: 12),
          const SizedBox(width: 3),
          CustomTextLabel(
            text: '$rate',
            style: TextStyle(
              color: ColorsRes.appColorWhite,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty || raw == 'null') return '';
    try {
      final dt = DateTime.parse(raw);
      const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month]} ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return '$count';
  }
}

class _ExpandableText extends StatefulWidget {
  final String text;

  const _ExpandableText({required this.text});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: _expanded || widget.text.length <= 120
                ? widget.text
                : '${widget.text.substring(0, 120)}... ',
            style: TextStyle(
              fontSize: 13,
              color: ColorsRes.subTitleTextColor,
              height: 1.5,
            ),
          ),
          if (widget.text.length > 120)
            WidgetSpan(
              child: GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: CustomTextLabel(
                  text: _expanded ? ' ${getTranslatedValue(context, viewLessLabel)}' : getTranslatedValue(context, viewMoreLabel),
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorsRes.appColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
