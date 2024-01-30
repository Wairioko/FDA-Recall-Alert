import 'package:daily_news/data/models/top_headlines_query_params.dart';
import '../../core/service_locator.dart';
// import 'package:daily_news/ui/screens/home/widgets/query_widget.dart';
import '../../model/request_query.dart';
import '../api_provider/news_api_provider.dart';
import '../models/base_model/base_model.dart';
import '../models/error_response.dart';
import '../models/top_headlines_response.dart';
import 'base_api/base_api.dart';

class TopHeadlinesApi extends BaseApi<TopHeadlinesQueryParams, TopHeadlinesResponse, ErrorResponse> {


  TopHeadlinesApi()
      : super(NewsApiProvider.topHeadlines, sl<NewsApiProvider>());

  @override
  BaseModel mapErrorResponse(Map<String, dynamic>? errorJson) {
    print("Error Response: $errorJson");
    return ErrorResponse.fromJson(errorJson!);
  }
  @override
  BaseModel mapSuccessResponse(Map<String, dynamic>? responseJson) {
    // Filter items based on the 'status' field
    List<dynamic> ongoingItems = responseJson?['results']
        .where((item) => item['status'] == "Ongoing")
        .toList();

    // If state is present in requestQuery, filter by 'distribution_pattern'

    if (.state.isNotEmpty) {
      print("Searching for results in the following state: ${.state}");

      ongoingItems = ongoingItems
          .where((item) =>
      item['distribution_pattern'].toLowerCase().contains(.state.toLowerCase()) ||
          item['distribution_pattern'].toLowerCase().contains(getStateInitials(.state.toLowerCase())))
          .toList();
    } else {
      print("No state selected");
    }

    // Create a new response JSON with only filtered items
    Map<String, dynamic> filteredResponseJson = {
      ...responseJson!,
      'results': ongoingItems,
    };

    print("Success Response: $filteredResponseJson");
    return TopHeadlinesResponse.fromJson(filteredResponseJson);
  }

  String getStateInitials(String state) {
    // Map full state names to their respective initials
    Map<String, String> stateMappings = {
      'alabama': 'AL',
      'alaska': 'AK',
      'arizona': 'AZ',
      'arkansas': 'AR',
      'california': 'CA',
      'colorado': 'CO',
      'connecticut': 'CT',
      'delaware': 'DE',
      'florida': 'FL',
      'georgia': 'GA',
      'hawaii': 'HI',
      'idaho': 'ID',
      'illinois': 'IL',
      'indiana': 'IN',
      'iowa': 'IA',
      'kansas': 'KS',
      'kentucky': 'KY',
      'louisiana': 'LA',
      'maine': 'ME',
      'maryland': 'MD',
      'massachusetts': 'MA',
      'michigan': 'MI',
      'minnesota': 'MN',
      'mississippi': 'MS',
      'missouri': 'MO',
      'montana': 'MT',
      'nebraska': 'NE',
      'nevada': 'NV',
      'new hampshire': 'NH',
      'new jersey': 'NJ',
      'new mexico': 'NM',
      'new york': 'NY',
      'north carolina': 'NC',
      'north dakota': 'ND',
      'ohio': 'OH',
      'oklahoma': 'OK',
      'oregon': 'OR',
      'pennsylvania': 'PA',
      'rhode island': 'RI',
      'south carolina': 'SC',
      'south dakota': 'SD',
      'tennessee': 'TN',
      'texas': 'TX',
      'utah': 'UT',
      'vermont': 'VT',
      'virginia': 'VA',
      'washington': 'WA',
      'west virginia': 'WV',
      'wisconsin': 'WI',
      'wyoming': 'WY',
    };

    return stateMappings[state] ?? state;
  }
}


// import 'package:daily_news/data/models/top_headlines_query_params.dart';
// import 'package:dartz/dartz.dart';
// import 'package:dio/dio.dart';
// import '../../core/service_locator.dart';
// import '../../model/request_query.dart';
// import '../api_provider/news_api_provider.dart';
// import '../models/base_model/base_model.dart';
// import '../models/error_response.dart';
// import '../models/top_headlines_response.dart';
// import 'base_api/base_api.dart';
//
//
// class TopHeadlinesApi extends BaseApi<
//     TopHeadlinesQueryParams,
//     TopHeadlinesResponse,
//     ErrorResponse> {
//
//   TopHeadlinesApi()
//       : super(NewsApiProvider.topHeadlines, sl<NewsApiProvider>()) {
//     // requestQuery = requestQuery("", "", ""); // or initialize with the required parameters
//   }
//   RequestQuery requestQuery = RequestQuery('', '', '');
//
//   @override
//   BaseModel mapErrorResponse(Map<String, dynamic>? errorJson) {
//     print("Error Response: $errorJson");
//     return ErrorResponse.fromJson(errorJson!);
//   }
//
//   @override
//   BaseModel mapSuccessResponse(Map<String, dynamic>? responseJson) {
//     // Filter items based on the 'status' field
//     List<dynamic> ongoingItems = responseJson?['results']
//         .where((item) => item['status'] == "Ongoing")
//         .toList();
//
//
//
//     // If state is present in requestQuery, filter by 'distribution_pattern'
//     if (requestQuery != null) {
//       if (requestQuery.state.isNotEmpty) {
//         print("Searching for results in the following state: ${requestQuery.state}");
//
//         ongoingItems = ongoingItems
//             .where((item) =>
//         item['distribution_pattern']
//             .toLowerCase()
//             .contains(requestQuery.state.toLowerCase()) ||
//             item['distribution_pattern']
//                 .toLowerCase()
//                 .contains(getStateInitials(requestQuery.state.toLowerCase())))
//             .toList();
//       }
//   }
//     else{
//
//       print("No state selected");
//     }
//
//     // Create a new response JSON with only filtered items
//     Map<String, dynamic> filteredResponseJson = {
//       ...responseJson!,
//       'results': ongoingItems,
//     };
//
//     print("Success Response: $filteredResponseJson");
//     return TopHeadlinesResponse.fromJson(filteredResponseJson);
//   }
//
//   String getStateInitials(String state) {
//     // Map full state names to their respective initials
//     Map<String, String> stateMappings = {
//       'alabama': 'AL',
//       'alaska': 'AK',
//       'arizona': 'AZ',
//       'arkansas': 'AR',
//       'california': 'CA',
//       'colorado': 'CO',
//       'connecticut': 'CT',
//       'delaware': 'DE',
//       'florida': 'FL',
//       'georgia': 'GA',
//       'hawaii': 'HI',
//       'idaho': 'ID',
//       'illinois': 'IL',
//       'indiana': 'IN',
//       'iowa': 'IA',
//       'kansas': 'KS',
//       'kentucky': 'KY',
//       'louisiana': 'LA',
//       'maine': 'ME',
//       'maryland': 'MD',
//       'massachusetts': 'MA',
//       'michigan': 'MI',
//       'minnesota': 'MN',
//       'mississippi': 'MS',
//       'missouri': 'MO',
//       'montana': 'MT',
//       'nebraska': 'NE',
//       'nevada': 'NV',
//       'new hampshire': 'NH',
//       'new jersey': 'NJ',
//       'new mexico': 'NM',
//       'new york': 'NY',
//       'north carolina': 'NC',
//       'north dakota': 'ND',
//       'ohio': 'OH',
//       'oklahoma': 'OK',
//       'oregon': 'OR',
//       'pennsylvania': 'PA',
//       'rhode island': 'RI',
//       'south carolina': 'SC',
//       'south dakota': 'SD',
//       'tennessee': 'TN',
//       'texas': 'TX',
//       'utah': 'UT',
//       'vermont': 'VT',
//       'virginia': 'VA',
//       'washington': 'WA',
//       'west virginia': 'WV',
//       'wisconsin': 'WI',
//       'wyoming': 'WY',
//     };
//
//     return stateMappings[state] ?? state;
//   }
// }



//
//
// class TopHeadlinesApi extends BaseApi<
//     TopHeadlinesQueryParams,
//     TopHeadlinesResponse,
//     ErrorResponse> {
//   TopHeadlinesApi()
//       : super(NewsApiProvider.topHeadlines, sl<NewsApiProvider>());
//
//   @override
//   BaseModel mapErrorResponse(Map<String, dynamic>? errorJson) {
//     return ErrorResponse.fromJson(errorJson!);
//   }
//
//   @override
//   BaseModel mapSuccessResponse(Map<String, dynamic>? responseJson) {
//     return TopHeadlinesResponse.fromJson(responseJson!);
//   }
//
//   @override
//   BaseOptions createBaseOptions(TopHeadlinesQueryParams? queryParams) {
//     String baseUrl = 'https://api.fda.gov/food/enforcement.json?';
//
//     // Use default report_date if queryParams is null
//     DateTime now = DateTime.now();
//     String formattedNow =
//         "${now.year}${now.month.toString().padLeft(2, '0')}"
//         "${now.day.toString().padLeft(2, '0')}";
//
//     baseUrl += 'search=report_date:[20231201+TO+$formattedNow]&limit=1000';
//
//     if (queryParams != null) {
//       // Append state parameter if not empty
//       if (queryParams.state.isNotEmpty) {
//         baseUrl += '&state=${queryParams.state}';
//       }
//       // Append category parameter if not empty
//       else if (queryParams.category.isNotEmpty) {
//         baseUrl += '&category=${queryParams.category}';
//       }
//     }
//
//     BaseOptions options = BaseOptions(
//       baseUrl: baseUrl,
//     );
//     return options;
//   }
// }
//

