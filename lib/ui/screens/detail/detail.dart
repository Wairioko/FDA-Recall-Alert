import 'package:flutter/material.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
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
                  _buildDetailTile(
                    label: 'Product Description:',
                    value: detailDataModel.product_description,
                  ),
                  _buildDetailTile(
                    label: 'Reason for Recall:',
                    value: detailDataModel.reason_for_recall,
                  ),
                  _buildDetailTile(
                    label: 'Status:',
                    value: detailDataModel.status,
                  ),
                  _buildDetailTile(
                    label: 'Classification:',
                    value: detailDataModel.classification,
                  ),
                  _buildDetailTile(
                    label: 'Recalling Firm:',
                    value: detailDataModel.recalling_firm,
                  ),
                  _buildDetailTile(
                    label: 'Who Initiated Recall:',
                    value: detailDataModel.voluntary_mandated,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile({required String label, required String value}) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: value == detailDataModel.voluntary_mandated
          ? FutureBuilder<GenerateContentResponse>(
        future: fetchAdditionalInfo(detailDataModel.reason_for_recall),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            final generatedText = snapshot.data?.text ?? '';
            return Text(
              generatedText,
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w300,
              ),
            );
          }
        },
      )
          : Text(
        value,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  static const apiKey = 'AIzaSyAM-TzFrKzmQ_roOrqG_UwPqp27QigCzfw';
  Future<GenerateContentResponse> fetchAdditionalInfo(
      String reasonForRecall) async {
    final model = await GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
    final prompt =
        'Give responses for the effects of consuming a product that has been recalled for: $reasonForRecall and any additional resources you might have regarding this case';
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    return response;
  }
}

