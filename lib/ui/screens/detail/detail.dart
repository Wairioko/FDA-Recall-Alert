import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../model/detail_data_model.dart';
import '../../shared/common_appbar.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:url_launcher/url_launcher.dart';


class Detail extends StatelessWidget {
  static const String path = '/detail';

  final DetailDataModel detailDataModel;

  const Detail({
    Key? key,
    required this.detailDataModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: CommonAppBar(
                onTabCallback: () => Navigator.of(context).pop(),
                darkAssetLocation: 'assets/icons/arrow.svg',
                lightAssetLocation: 'assets/icons/light_arrow.svg',
                title: 'Product Recall Details',
                tooltip: 'Back to dashboard',
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ListTile(
                    title: Text(
                      'Product Description:',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      detailDataModel.product_description,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Reason for Recall:',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      detailDataModel.reason_for_recall,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Status:',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      detailDataModel.status,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Classification:',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      detailDataModel.classification,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Recalling Firm:',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      detailDataModel.recalling_firm,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Who Initiated Recall:',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      detailDataModel.voluntary_mandated,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Generated Information:',
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: FutureBuilder<GenerateContentResponse>(
                      future: fetchAdditionalInfo(detailDataModel.reason_for_recall),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          final generatedText = snapshot.data?.text ?? '';
                          return _buildRichTextWithLinks(context, generatedText);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            fontSize: 16.0,
            fontWeight: FontWeight.w300,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ));
      }

      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.black,
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

      if (matchStart > start) {
        final nonLinkText = text.substring(start, matchStart);
        spans.add(TextSpan(
          text: nonLinkText,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w300,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ));
      }

      spans.add(
        TextSpan(
          text: match.group(0),
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w300,
            color: Colors.blue, // Make links blue
            decoration: TextDecoration.underline, // Underline links
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _launchURL(match.group(0)!);
            },
        ),
      );

      start = matchEnd;
    }

    if (start < text.length) {
      final nonLinkText = text.substring(start);
      print("Non-link text segment: $nonLinkText");
      spans.add(TextSpan(
        text: nonLinkText,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w300,
          color: Colors.black,
          decoration: TextDecoration.none,
        ),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }



  void _launchURL(String url) async {
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static const apiKey = 'AIzaSyAM-TzFrKzmQ_roOrqG_UwPqp27QigCzfw';
  Future<GenerateContentResponse> fetchAdditionalInfo(
      String reasonForRecall) async {
    final model = await GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    final prompt =
        'Give responses for the effects of consuming a product that has been recalled for: $reasonForRecall '
        'and any additional resources you might have regarding this case';
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    return response;
  }
}