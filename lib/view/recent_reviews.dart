import 'package:flutter/material.dart';
import 'package:login_app/controller/game_controller.dart';
import 'package:login_app/controller/review_controller.dart';
import 'package:login_app/model/review.dart';

class RecentReviews extends StatefulWidget {
  const RecentReviews({Key? key}) : super(key: key);

  @override
  _RecentReviewsState createState() => _RecentReviewsState();
}

class _RecentReviewsState extends State<RecentReviews> {
  List<Review> reviewList = [];
  TextEditingController reviewController = TextEditingController();
  var _db = GameController();
  var _rc = ReviewController();
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    loadReviews();
  }

  void loadReviews() async {
    List<Review> reviews = await _rc.getReviews();

    setState(() {
      reviewList = reviews;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalhes do Jogo'),
        backgroundColor: const Color.fromARGB(255, 214, 82, 82),
      ),
      body: reviewList.isEmpty
        ? Center(
            child: CircularProgressIndicator(),
          )
        : ListView.builder(
            itemCount: reviewList.length,
            itemBuilder: (context, index) {
              Review review = reviewList[index];
              return ListTile(
                title: Text(review.userId!.toString()),
                subtitle: Text(review.description!),
              );
            },
          ),
    );
  }
}
