import 'package:flutter/material.dart';
import '../../../../model/new_item_model.dart';
import '../../detail/detail.dart';

class Recall_Item extends StatelessWidget {
  final Recall_ItemModel newsItemModel;

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
        // Added Container to provide a fixed width for the ListTile
        width: double.infinity, // Adjust width as needed
        child: ListTile(
          title: Text(
            newsItemModel.product_description,
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
            style: TextStyle(
              fontSize: 16, // Increased font size for better readability
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4), // Adding spacing between title and subtitle
              Text(
                'Reason: ${newsItemModel.reason_for_recall}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: 2), // Adding spacing between subtitle items
              Text(
                'Status: ${newsItemModel.status}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
              SizedBox(height: 2), // Adding spacing between subtitle items
              Text(
                'Classification: ${newsItemModel.classification}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
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
