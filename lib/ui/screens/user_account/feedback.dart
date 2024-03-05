import 'package:flutter/material.dart';


class FeedbackForm extends StatefulWidget {
  @override
  _FeedbackFormState createState() => _FeedbackFormState();
  static const String path = '/feedback';
}

class _FeedbackFormState extends State<FeedbackForm> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Scaffold provides structure and app bar options
      appBar: AppBar(
        title: Text('Feedback'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView( // Allow scrolling if content exceeds screen height
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Align label to the left
            children: <Widget>[
              Text(
                'Subject:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Enter a brief subject',
                  border: OutlineInputBorder(),
                ),
                // Add subject-specific validator if needed
              ),
              SizedBox(height: 16.0), // Increased spacing for readability
              Text(
                'Feedback:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.0),
              TextFormField(
                controller: _feedbackController,
                decoration: InputDecoration(
                  hintText: 'Enter your feedback here',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter your feedback';
                  }
                  return null;
                },
                maxLines: 5,
                minLines: 3, // Ensure some vertical space initially
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(40), backgroundColor: Colors.green), // Make submit button taller
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // ... your feedback submission logic here ...
                  }
                },
                child: Text('Submit', style: TextStyle(
                  fontFamily: 'SF Pro Text',
                  color: Colors.white,
                  fontWeight: FontWeight.bold
                ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
