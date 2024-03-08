import 'package:flutter/material.dart';
import '../../../../model/new_item_model.dart';
import '../../detail/detail.dart';

class RecallItem extends StatelessWidget {
  final RecallItemModel newsItemModel;

  const RecallItem({Key? key, required this.newsItemModel}) : super(key: key);

  Color _getColorForClassification(String classification) {
    switch (classification.toUpperCase()) { // Normalize for comparison
      case 'CLASS I':
        return Colors.redAccent;
      case 'CLASS II':
        return Colors.orangeAccent;
      case 'CLASS III':
        return Colors.yellowAccent;
      default:
        return Colors.grey; // Neutral color for unknown classification
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          Detail.path,
          arguments: newsItemModel.detailDataModel,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12.0), // Increased padding
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0), // Softer border-radius
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 5.0)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              newsItemModel.product_description,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: const TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.w600, // Medium weight for readability
                fontFamily: 'San Francisco',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Reason: ${newsItemModel.reason_for_recall}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                fontFamily: 'San Francisco',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Classification: ${newsItemModel.classification}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15.0, // Slightly larger for emphasis
                fontWeight: FontWeight.w500, // Slightly bolder for emphasis
                fontFamily: 'San Francisco',
                color: _getColorForClassification(newsItemModel.classification),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





// import 'package:flutter/material.dart';
//
// import '../../../../model/new_item_model.dart';
// import '../../detail/detail.dart';
//
// class NewsItem extends StatelessWidget {
//   final NewsItemModel newsItemModel;
//
//   const NewsItem({super.key, required this.newsItemModel});
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () {
//         Navigator.of(context).pushNamed(
//             Detail.path,
//             arguments: newsItemModel.detailDataModel,
//         );
//       },
//       child: ListTile(
//         leading: ClipRRect(
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         title: Text(
//           newsItemModel.product_description,
//           overflow: TextOverflow.ellipsis,
//           maxLines: 3,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         subtitle: Text(
//           newsItemModel.reason_for_recall,
//           overflow: TextOverflow.fade,
//           maxLines: 1,
//           softWrap: false,
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w300,
//           ),
//         ),
//         subtitle: Text(
//           newsItemModel.status,
//           overflow: TextOverflow.fade,
//           maxLines: 1,
//           softWrap: false,
//           style: const TextStyle(
//             fontSize: 12,
//             fontWeight: FontWeight.w300,
//           ),
//         ),
//       ),
//     );
//   }
// }
