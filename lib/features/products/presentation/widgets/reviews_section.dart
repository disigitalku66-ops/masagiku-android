/// Reviews Section Widget
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../data/models/product_detail_model.dart';

class ReviewsSection extends StatelessWidget {
  final ReviewSummary? summary;
  final List<ProductReview> reviews;
  final bool isLoading;
  final VoidCallback? onViewAll;
  final int? filterRating;
  final Function(int?)? onFilterChanged;
  final int maxPreviewCount;

  const ReviewsSection({
    super.key,
    this.summary,
    this.reviews = const [],
    this.isLoading = false,
    this.onViewAll,
    this.filterRating,
    this.onFilterChanged,
    this.maxPreviewCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ulasan Produk',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (onViewAll != null && reviews.isNotEmpty)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('Lihat Semua'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Summary Card
        if (summary != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ReviewSummaryCard(summary: summary!),
          ),
        // Filter chips
        if (onFilterChanged != null &&
            summary != null &&
            summary!.totalReviews > 0) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _FilterChip(
                  label: 'Semua',
                  isSelected: filterRating == null,
                  onTap: () => onFilterChanged!(null),
                ),
                for (int i = 5; i >= 1; i--)
                  _FilterChip(
                    label: '$i ★',
                    isSelected: filterRating == i,
                    onTap: () => onFilterChanged!(i),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        // Reviews List
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(32),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Belum ada ulasan',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          ...reviews
              .take(maxPreviewCount)
              .map(
                (review) => Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ReviewCard(review: review),
                ),
              ),
        // View more button
        if (reviews.length > maxPreviewCount && onViewAll != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onViewAll,
                child: Text(
                  'Lihat ${reviews.length - maxPreviewCount} ulasan lainnya',
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).primaryColor : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[300]!,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

/// Review Summary Card
class ReviewSummaryCard extends StatelessWidget {
  final ReviewSummary summary;

  const ReviewSummaryCard({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Average rating
          Column(
            children: [
              Text(
                summary.averageRating.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              _StarRating(rating: summary.averageRating),
              const SizedBox(height: 4),
              Text(
                '${summary.totalReviews} ulasan',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // Rating distribution
          Expanded(
            child: Column(
              children: List.generate(5, (index) {
                final star = 5 - index;
                final percentage = summary.getPercentage(star);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Text('$star', style: const TextStyle(fontSize: 12)),
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${summary.ratingDistribution[star] ?? 0}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarRating extends StatelessWidget {
  final double rating;
  final double size;

  const _StarRating({required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        IconData icon;

        if (rating >= starValue) {
          icon = Icons.star;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half;
        } else {
          icon = Icons.star_border;
        }

        return Icon(icon, size: size, color: Colors.amber);
      }),
    );
  }
}

/// Review Card
class ReviewCard extends StatelessWidget {
  final ProductReview review;
  final bool showFull;

  const ReviewCard({super.key, required this.review, this.showFull = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info row
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[200],
                backgroundImage: review.userAvatar != null
                    ? CachedNetworkImageProvider(review.userAvatar!)
                    : null,
                child: review.userAvatar == null
                    ? Text(
                        review.userName.isNotEmpty
                            ? review.userName[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              // Name and rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _StarRating(rating: review.rating, size: 14),
                        const SizedBox(width: 8),
                        if (review.createdAt != null)
                          Text(
                            _formatDate(review.createdAt!),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[500]),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Review comment
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              maxLines: showFull ? null : 3,
              overflow: showFull ? null : TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          // Review images
          if (review.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 72,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.images.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          _openReviewImage(context, review.images, index),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: review.images[index],
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 72,
                            height: 72,
                            color: Colors.grey[200],
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 72,
                            height: 72,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          // Seller reply
          if (review.reply != null && review.reply!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.store, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Balasan Penjual',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    review.reply!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hari ini';
    } else if (diff.inDays == 1) {
      return 'Kemarin';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} hari lalu';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()} minggu lalu';
    } else {
      return DateFormat('d MMM y', 'id').format(date);
    }
  }

  void _openReviewImage(BuildContext context, List<String> images, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            _ReviewImageViewer(images: images, initialIndex: index),
      ),
    );
  }
}

/// Review Image Full Screen Viewer
class _ReviewImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _ReviewImageViewer({required this.images, this.initialIndex = 0});

  @override
  State<_ReviewImageViewer> createState() => _ReviewImageViewerState();
}

class _ReviewImageViewerState extends State<_ReviewImageViewer> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentPage + 1}/${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.images[index],
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.broken_image,
                  size: 80,
                  color: Colors.white54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
