import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../model/detail_data_model.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class Detail extends StatefulWidget {
  static const String path = '/detail';
  final DetailDataModel detailDataModel;

  const Detail({
    Key? key,
    required this.detailDataModel,
  }) : super(key: key);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  bool _showGeneratedContent = false;
  bool _isButtonClicked = false;
  late Future<GenerateContentResponse> _generatedContentFuture;

  @override
  void initState() {
    super.initState();
    // // Initialize the future for generating content
    // _generatedContentFuture = fetchAdditionalInfo(widget.detailDataModel.reason_for_recall);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Product Details",
          style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'SanFrancisco'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white60.withOpacity(0.4),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.1),
                    blurRadius: 3,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Product Recalled:', widget.detailDataModel.product_description),
                  _buildDetailRow('Status:', widget.detailDataModel.status),
                  _buildDetailRow('Classification:', widget.detailDataModel.classification),
                  _buildDetailRow('Recalling Company:', widget.detailDataModel.recalling_firm),
                  _buildDetailRow('FDA Recall Tracking Number:', widget.detailDataModel.recall_number),

                ],
              ),
            ),
            if (_showGeneratedContent)
              FutureBuilder<GenerateContentResponse>(
                future: _generatedContentFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text("Generating insights..."),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {

                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, color: Colors.red),
                          SizedBox(height: 10),
                          Text("Couldn't generate insights. Please try again."),
                        ],
                      ),
                    );
                  } else {
                    final generatedText = snapshot.data?.text ?? '';
                    return Container(
                      padding: EdgeInsets.all(12),
                      margin: EdgeInsets.only(top: 16),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade100,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Generated AI Insights:",
                            style: TextStyle(fontWeight: FontWeight.w500, fontFamily: 'SanFrancisco'),
                          ),
                          SizedBox(height: 8),
                          _buildRichTextWithLinks(context, generatedText),
                        ],
                      ),
                    );
                  }
                },
              ),
            _buildGenerateInsightsButton(widget.detailDataModel.product_description,widget.detailDataModel.reason_for_recall),
          ],
        ),
      ),
    );
  }


// Helper function
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Column( // No need for the extra container here
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: 'SanFrancisco',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'SanFrancisco',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 17, // Slightly larger
          fontWeight: FontWeight.w600, // Slightly bolder
          color: Colors.black87, // Slightly darker
          wordSpacing: 2,
          fontFamily: 'SanFrancisco',
        ),
      ),
    );
  }



  Widget _buildGeneratedContent(BuildContext context, String product, String reason) {
    return FutureBuilder<GenerateContentResponse>(
      future: fetchAdditionalInfo(product,reason),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column( // For better loading indication
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text("Generating insights..."),
              ],
            ),
          );
        } else if (snapshot.hasError) {

          return Center( // More robust error handling
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(height: 10),
                Text("Couldn't generate insights. Please try again."),

              ],
            ),
          );
        } else {
          final generatedText = snapshot.data?.text ?? '';
          return Container( // Visual separation
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.only(top: 16), // Spacing
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade100,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Generated AI Insights:", style: TextStyle(fontWeight: FontWeight.w500, fontFamily: 'SanFrancisco',)),
                SizedBox(height: 8),
                _buildRichTextWithLinks(context, generatedText),
              ],
            ),
          );
        }
      },
    );
  }



  Widget _buildSectionContent(String content) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12), // Add margin
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        content,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400, // Regular weight
          fontFamily: 'SanFrancisco', // Example secondary font
          // ...
        ),
      ),
    );
  }


  Widget _buildSectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Divider(
        color: Colors.grey.shade300,
        thickness: 1,
      ),
    );
  }


  Widget _buildRichTextWithLinks(BuildContext context, String text) {
    final headlinePattern = RegExp(r'\*\*(.*?)\*\*');
    final linkPattern = RegExp(r'http(s)?://\S+');

    final spans = <InlineSpan>[];
    int start = 0;

    // Match headlines
    for (final match in headlinePattern.allMatches(text)) {
      final matchStart = match.start;
      final matchEnd = match.end;

      if (matchStart > start) {
        final nonLinkText = text.substring(start, matchStart);
        spans.add(TextSpan(
          text: nonLinkText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w300,
            color: Colors.black,
            decoration: TextDecoration.none,
            fontFamily: 'SanFrancisco',
          ),
        ));
      }

      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          fontFamily: 'SanFrancisco',
          wordSpacing: 2,
          decoration: TextDecoration.none,
        ),
      ));

      start = matchEnd;
    }

    // Match links
    for (final match in linkPattern.allMatches(text)) {
      final matchStart = match.start;
      final matchEnd = match.end;

      spans.add(
        TextSpan(
          text: match.group(0),
          style: const TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w300,
            fontFamily: 'SanFrancisco',
            color: Colors.blue, // Make links blue
            decoration: TextDecoration.underline, // Underline links
            wordSpacing: 2,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _launchURL(match.group(0)!);
            },
        ),
      );

      start = matchEnd;
    }

    return RichText(text: TextSpan(children: spans));
  }



  void _launchURL(String url) async {
    final Uri _url = Uri.parse(url);
    if (await canLaunchUrlString(_url.toString())) {
      await launchUrlString(_url.toString());
    } else {
      throw 'Could not launch $_url';
    }
  }

  Widget _buildGenerateInsightsButton(String product, String reason) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: _isButtonClicked
              ? null // Disable the button if it has already been clicked
              : () {
            setState(() {
              // Set the future only when the button is pressed
              _generatedContentFuture = fetchAdditionalInfo(
                  widget.detailDataModel.product_description,
                  widget.detailDataModel.reason_for_recall);
              _showGeneratedContent = true;
              _isButtonClicked = true; // Set the flag to true after clicking the button
            });
          },
          child: const Text('Generate Additional Insights'),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.blue),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
          ),
        ),
      ],
    );
  }


  Future<GenerateContentResponse> fetchAdditionalInfo(String product,
    String reasonForRecall) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    final model = await GenerativeModel(model: "gemini-1.5-flash", apiKey: apiKey!);
    final prompt =
        'Give responses for the effects of consuming $product that has been recalled for: $reasonForRecall '
        'and next steps if you have consumed such a products';
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    return response;
  }
}

