import 'package:flutter/material.dart';

import '../../../../model/new_item_model.dart';
import '../../detail/detail.dart';

class NewsItem extends StatelessWidget {
  final NewsItemModel newsItemModel;

  const NewsItem({super.key, required this.newsItemModel});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          Detail.path,
          arguments: newsItemModel.detailDataModel,
        );
      },
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          // Add an Image or other widget here if needed.
        ),
        title: Text(
          newsItemModel.product_description,
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              newsItemModel.reason_for_recall,
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              newsItemModel.status,
              overflow: TextOverflow.fade,
              maxLines: 1,
              softWrap: false,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
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
