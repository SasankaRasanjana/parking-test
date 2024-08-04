import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:parkme/models/booking.model.dart';
import 'package:parkme/models/feedback.model.dart';
import 'package:parkme/services/feedback.service.dart';
import 'package:parkme/utils/index.dart';
import 'package:parkme/widgets/custom.filled.button.dart';

class GiveFeedbackView extends StatefulWidget {
  final Booking booking;
  const GiveFeedbackView({Key? key, required this.booking}) : super(key: key);

  @override
  State<GiveFeedbackView> createState() => _GiveFeedbackViewState();
}

class _GiveFeedbackViewState extends State<GiveFeedbackView> {
  final _controller = TextEditingController();
  bool clicked = false;
  void onClicked() {
    setState(() {
      clicked = !clicked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Review your experience',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _FeedbackButton(
                  title: 'Positive',
                  isPositive: true,
                  clicked: clicked,
                  onClicked: onClicked,
                ),
                _FeedbackButton(
                  title: 'Negative',
                  isPositive: false,
                  clicked: !clicked,
                  onClicked: onClicked,
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            const Text('Add a comment:'),
            const SizedBox(height: 10.0),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter your comment here',
                ),
                maxLines: null,
                minLines: 10,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            CustomButton(
              text: "Review",
              onPressed: () async {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                final feedback = FeedbackModel(
                    reviewedBy: uid ?? "",
                    reviewedAt: widget.booking.id ?? "",
                    isPositive: clicked,
                    comment: _controller.text);
                await FeedbackService()
                    .addFeedback(feedback)
                    .then((value) => Navigator.pop(context))
                    .catchError((error) =>
                        context.showSnackBar("Error while adding feedback"));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedbackButton extends StatelessWidget {
  final String title;
  final bool isPositive;
  final bool clicked;
  final VoidCallback onClicked;
  const _FeedbackButton(
      {required this.title,
      required this.isPositive,
      required this.clicked,
      required this.onClicked});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(
            isPositive ? Icons.thumb_up : Icons.thumb_down,
            color: clicked ? Colors.green : Colors.grey,
          ),
          onPressed: onClicked,
        ),
        Text(title),
      ],
    );
  }
}
