import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../model/detail_data_model.dart';
import '../../shared/common_appbar.dart';
import 'package:google_generative_ai/google_generative_ai.dart';



class Detail extends StatelessWidget {
  static const String path = '/detail';

  final DetailDataModel detailDataModel;

  const Detail({
    Key? key,
    required this.detailDataModel,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(18),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: CommonAppBar(
                onTabCallback: () => Navigator.of(context).pop(),
                darkAssetLocation: 'assets/icons/arrow.svg',
                lightAssetLocation: 'assets/icons/light_arrow.svg',
                title: 'Product Recall Details',
                tooltip: 'Back to dashboard',
              ),
            ),
            Container(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Product Description:'),
                  _buildSectionContent(detailDataModel.product_description),
                  _buildSectionDivider(),
                  _buildSectionTitle('Reason for Recall:'),
                  _buildSectionContent(detailDataModel.reason_for_recall),
                  _buildSectionDivider(),
                  _buildSectionTitle('Status:'),
                  _buildSectionContent(detailDataModel.status),
                  _buildSectionDivider(),
                  _buildSectionTitle('Classification:'),
                  _buildSectionContent(detailDataModel.classification),
                  _buildSectionDivider(),
                  _buildSectionTitle('Recalling Firm:'),
                  _buildSectionContent(detailDataModel.recalling_firm),
                  _buildSectionDivider(),
                  _buildSectionTitle('Who Initiated Recall:'),
                  _buildSectionContent(detailDataModel.voluntary_mandated),
                  _buildSectionDivider(),
                  _buildSectionTitle('Generated Information:'),
                  _buildGeneratedContent(context, detailDataModel.reason_for_recall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.5,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          wordSpacing: 2,
          fontFamily: 'SanFrancisco',
        ),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(
        fontSize: 16.5,
        fontWeight: FontWeight.w300,
        color: Colors.black,
        decoration: TextDecoration.none,
        fontFamily: 'SanFrancisco',
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

  Widget _buildGeneratedContent(BuildContext context, String reason) {
    return FutureBuilder<GenerateContentResponse>(
      future: fetchAdditionalInfo(reason),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final generatedText = snapshot.data?.text ?? '';
          return _buildRichTextWithLinks(context, generatedText);
        }
      },
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


  static const apiKey = 'AIzaSyAM-TzFrKzmQ_roOrqG_UwPqp27QigCzfw';
  Future<GenerateContentResponse> fetchAdditionalInfo(
      String reasonForRecall) async {
    final model = await GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    final prompt =
        'Give responses for the effects of consuming a product that has been recalled for: $reasonForRecall '
        'and next steps if you have consumed such a product';
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    return response;
  }
}