import 'package:flutter/material.dart';
import '../../../../model/new_item_model.dart';
import '../../detail/detail.dart';

class Recall_Item extends StatelessWidget {
  final Recall_ItemModel newsItemModel;

  Color _getColorForClassification(String classification) {
    switch (classification) {
      case 'CLASS I':
        return Colors.red; // Most serious
      case 'CLASS II':
        return Colors.orange; // Moderate danger
      case 'CLASS III':
        return Colors.yellow; // Least serious
      default:
        return Colors.black; // Default color
    }
  }
  const Recall_Item({Key? key, required this.newsItemModel}) : super(key: key);

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
        padding: EdgeInsets.all(5.0), // Content padding
        decoration: BoxDecoration( // Subtle decoration
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.4), blurRadius: 5.0)
          ],
        ),
        child: Column( // Adjusted spacing within the column
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              newsItemModel.product_description,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: TextStyle(
                fontSize: 16.5, // Increased title size
                fontWeight: FontWeight.w700,
                fontFamily: 'SanFrancisco'
              ),
            ),
            SizedBox(height: 5), // More vertical space
            Text(
              'Reason: ${newsItemModel.reason_for_recall}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'SanFrancisco'

              ),

            ),
            SizedBox(height: 5),
            Text(
              'Classification: ${newsItemModel.classification}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w200,
                fontFamily: 'SanFrancisco',
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
