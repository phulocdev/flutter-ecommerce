import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/apis/review_api_service.dart';
import 'package:flutter_ecommerce/models/review.dart';
import 'package:flutter_ecommerce/providers/auth_providers.dart';
// import 'package:flutter_ecommerce/services/auth_service.dart';
// import 'package:flutter_ecommerce/services/review_service.dart';
import 'package:flutter_ecommerce/widgets/star_rating.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class ReviewSection extends ConsumerStatefulWidget {
  final String productId;

  const ReviewSection({
    Key? key,
    required this.productId,
  }) : super(key: key);

  @override
  ConsumerState<ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends ConsumerState<ReviewSection> {
  final ReviewService _reviewService = ReviewService();
  final TextEditingController _commentController = TextEditingController();
  double _userRating = 0;
  bool _isAnonymous = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Add mock reviews for demonstration
    _reviewService.addMockReviews(widget.productId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a comment')),
      );
      return;
    }

    // Check if user is trying to rate without being logged in
    final isLoggedIn = false;
    if (_userRating > 0 && !isLoggedIn) {
      _showLoginDialog();
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _reviewService.addReview(
        productId: widget.productId,
        comment: _commentController.text.trim(),
        rating: _userRating,
        isAnonymous: _isAnonymous,
      );

      // Clear form
      _commentController.clear();
      setState(() {
        _userRating = 0;
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text(
          'You need to be logged in to rate products. You can still leave a comment as an anonymous user.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Navigate to login page or show login dialog
              // For demo, we'll just simulate a login
              _simulateLogin();
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  void _simulateLogin() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text('Logging in...'),
          ],
        ),
      ),
    );

    // Simulate login
    // await _authService.login('user@example.com', 'password');

    // Close dialog and update UI
    if (mounted) {
      Navigator.of(context).pop();
      setState(() {
        _isAnonymous = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 40),
        Text(
          'Reviews & Ratings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 20),
        _buildReviewForm(),
        const SizedBox(height: 30),
        _buildReviewsList(),
      ],
    );
  }

  Widget _buildReviewForm() {
    // final isLoggedIn = _authService.isLoggedIn;
    final isLoggedIn = ref.read(authProvider) != null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Write a Review',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Your Rating: ',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(width: 8),
                StarRating(
                  rating: _userRating,
                  onRatingChanged: (rating) {
                    setState(() {
                      _userRating = rating;
                    });
                    if (rating > 0 && !isLoggedIn) {
                      _showLoginDialog();
                    }
                  },
                  size: 28,
                ),
              ],
            ),
            if (!isLoggedIn)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'You must be logged in to rate products',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Share your thoughts about this product...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (!isLoggedIn)
                  Row(
                    children: [
                      Checkbox(
                        value: _isAnonymous,
                        onChanged: (value) {
                          setState(() {
                            _isAnonymous = value ?? true;
                          });
                        },
                      ),
                      const Text('Post as Anonymous'),
                      const SizedBox(width: 16),
                    ],
                  ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Submit Review'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsList() {
    return StreamBuilder<List<Review>>(
      stream: _reviewService.getReviewsStreamForProduct(widget.productId),
      initialData: _reviewService.getReviewsForProduct(widget.productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final reviews = snapshot.data ?? [];

        if (reviews.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No reviews yet. Be the first to review!'),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return _buildReviewItem(review);
          },
        );
      },
    );
  }

  Widget _buildReviewItem(Review review) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: Text(
                  review.userName?.substring(0, 1).toUpperCase() ?? 'A',
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName ?? 'Anonymous',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      dateFormat.format(review.createdAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (review.rating > 0)
                StarRating(
                  rating: review.rating,
                  size: 16,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(review.comment),
        ],
      ),
    );
  }
}
