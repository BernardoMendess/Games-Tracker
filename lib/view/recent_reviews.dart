import 'package:flutter/material.dart';
import 'package:login_app/controller/game_controller.dart';
import 'package:login_app/controller/login_controller.dart';
import 'package:login_app/controller/review_controller.dart';
import 'package:login_app/model/review.dart';

class RecentReviews extends StatefulWidget {
  const RecentReviews({Key? key}) : super(key: key);

  @override
  _RecentReviewsState createState() => _RecentReviewsState();
}

class _RecentReviewsState extends State<RecentReviews> {
  List<Map<String, dynamic>> reviewList = [];
  TextEditingController reviewController = TextEditingController();
  var _db = GameController();
  var _rc = ReviewController();
  var _lc = LoginController();
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    loadReviews();
  }

  void loadReviews() async {
    List<Review> reviews = await _rc.getReviews();

    for (Review review in reviews) {
      var game = await _db.getGameById(review.gameId!);
      var user = await _lc.getUserById(review.userId!);

      reviewList.add({
        'review': review,
        'gameName': game.name!,
        'userName': user['username'],
      });
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Reviews Recentes',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Color.fromARGB(255, 99, 179, 99)),
      body: reviewList.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ListView.builder(
                itemCount: reviewList.length,
                itemBuilder: (context, index) {
                  var reviewData = reviewList[index];
                  var review = reviewData['review'] as Review;
                  var gameName = reviewData['gameName'];
                  var userName = reviewData['userName'];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$gameName - ${review.score}/10',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Escrito por: $userName',
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(review.description ?? ''),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
