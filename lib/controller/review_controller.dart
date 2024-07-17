import 'package:login_app/helper/DatabaseHelper.dart';
import 'package:login_app/model/review.dart';

class ReviewController {
  static final ReviewController _instance = ReviewController._internal();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  factory ReviewController() => _instance;

  ReviewController._internal();

  Future<int> insertReview(Review review) async {
    return await _dbHelper.insertReview(review);
  }

  Future<List<Review>> getReviews() async {
    List<Map<String, dynamic>> maps = await _dbHelper.getReviews();
    return maps.map((map) => Review.fromMap(map)).toList();
  }

  Future<int> updateReview(Review review) async {
    return await _dbHelper.updateReview(review);
  }

  Future<int> deleteReview(int id) async {
    return await _dbHelper.deleteReview(id);
  }
}
