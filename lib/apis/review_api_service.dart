import 'dart:async';
import 'package:flutter_ecommerce/models/review.dart';
import 'package:uuid/uuid.dart';

class ReviewService {
  // Singleton pattern
  static final ReviewService _instance = ReviewService._internal();
  factory ReviewService() => _instance;
  ReviewService._internal();

  // In-memory storage for reviews (replace with actual API calls in production)
  final List<Review> _reviews = [];

  // Stream controller for real-time updates
  final _reviewsStreamController = StreamController<List<Review>>.broadcast();
  Stream<List<Review>> get reviewsStream => _reviewsStreamController.stream;

  // Get reviews for a specific product
  List<Review> getReviewsForProduct(String productId) {
    return _reviews.where((review) => review.productId == productId).toList();
  }

  // Get reviews stream for a specific product
  Stream<List<Review>> getReviewsStreamForProduct(String productId) {
    return reviewsStream.map((reviews) =>
        reviews.where((review) => review.productId == productId).toList());
  }

  // Add a review
  Future<Review> addReview({
    required String productId,
    required String comment,
    required double rating,
    required bool isAnonymous,
  }) async {
    // final authService = AuthService();
    final currentUser = null;

    // Check if user is logged in for rating
    if (rating > 0 && currentUser == null) {
      throw Exception('You must be logged in to rate products');
    }

    final review = Review(
      id: const Uuid().v4(),
      userId: isAnonymous ? null : currentUser?.id,
      userName: isAnonymous ? 'Anonymous' : currentUser?.displayName,
      productId: productId,
      comment: comment,
      rating: rating,
      createdAt: DateTime.now(),
      isAnonymous: isAnonymous,
    );

    // Add to in-memory storage
    _reviews.add(review);

    // Notify listeners
    _reviewsStreamController.add(_reviews);

    return review;
  }

  // Mock method to add some initial reviews
  void addMockReviews(String productId) {
    if (_reviews.any((review) => review.productId == productId)) {
      return; // Already has reviews
    }

    final mockReviews = [
      Review(
        id: '1',
        userId: 'user1',
        userName: 'John Doe',
        productId: productId,
        comment: 'Great product! I love the quality and design.',
        rating: 5.0,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Review(
        id: '2',
        userId: 'user2',
        userName: 'Jane Smith',
        productId: productId,
        comment: 'Good product but shipping took longer than expected.',
        rating: 4.0,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      Review(
        id: '3',
        userId: null,
        userName: 'Anonymous',
        productId: productId,
        comment: 'Nice product, would recommend to others!',
        rating: 0.0, // Anonymous users can't rate
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isAnonymous: true,
      ),
    ];

    _reviews.addAll(mockReviews);
    _reviewsStreamController.add(_reviews);
  }

  // Dispose resources
  void dispose() {
    _reviewsStreamController.close();
  }
}
