import 'package:daily_news/data/models/top_headlines_query_params.dart';
import '../../core/service_locator.dart';
import '../../model/request_query.dart';
import '../api_provider/news_api_provider.dart';
import '../models/base_model/base_model.dart';
import '../models/error_response.dart';
import '../models/top_headlines_response.dart';
import 'base_api/base_api.dart';


class ApiData {
  static List<dynamic>? responseJson;

  // Option 1: Make responseJson public
  static List<dynamic>? getResponseJson() => responseJson;

}


class TopHeadlinesApi extends BaseApi<TopHeadlinesQueryParams,
    TopHeadlinesResponse, ErrorResponse> {

  TopHeadlinesApi({required this.requestQuery})
      : super(NewsApiProvider.topHeadlines, sl<NewsApiProvider>());

  RequestQuery requestQuery;

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

    ApiData.responseJson = ongoingItems;
    var data = ApiData.responseJson;
    print("getting my data: $data");

    if (requestQuery.query.trim().isNotEmpty) {
      print("Searching for results");

      ongoingItems = ongoingItems.where((item) {
        // Check if the "product_description" contains the search query
        return item['product_description'].toLowerCase().contains(requestQuery.query.toLowerCase());
      }).toList();
    } else {
      print("No search query entered");
    }

    if (requestQuery.state.trim().isNotEmpty || requestQuery.category.trim().isNotEmpty) {
      print("Searching for results");

      ongoingItems = ongoingItems.where((item) {
        bool stateMatch = true; // Default to true
        bool categoryMatch = true; // Default to true

        // Check if the state matches
        if (requestQuery.state.trim().isNotEmpty) {
          stateMatch = item['distribution_pattern'].toLowerCase().contains(requestQuery.state.toLowerCase()) ||
              item['distribution_pattern'].toLowerCase().contains(getStateInitials(requestQuery.state.toLowerCase()));
        }

        // Check if distribution_pattern contains "nation" or "country"
        bool nationOrCountryMatch = item['distribution_pattern'].toLowerCase().contains('nation') ||
            item['distribution_pattern'].toLowerCase().contains('country');

        // Check if any state condition is met or nationOrCountryMatch is true
        bool stateCondition = stateMatch || nationOrCountryMatch;

        // Check if the category matches
        if (requestQuery.classification.trim().isNotEmpty) {
          categoryMatch = item['classification'].toLowerCase().contains(requestQuery.classification.toLowerCase());
        }

        // Return true only if both conditions (state and category) are met
        return stateCondition && (categoryMatch || !requestQuery.classification.trim().isNotEmpty);
      }).toList();
    } else {
      print("No state or category selected");
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
//     // Map full state names to their respective initials
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


// Check if state and/or category are not empty or consist only of whitespaces
// Check if state and/or category are not empty or consist only of whitespaces
// if (requestQuery.state.trim().isNotEmpty || requestQuery.category.trim().isNotEmpty) {
//   print("Searching for results");
//
//   ongoingItems = ongoingItems.where((item) {
//     bool stateMatch = true; // Default to true
//     bool categoryMatch = true; // Default to true
//
//     // Check if the state matches
//     if (requestQuery.state.trim().isNotEmpty) {
//       String normalizedState = requestQuery.state.toLowerCase();
//
//       stateMatch = item['distribution_pattern'].toLowerCase().contains(normalizedState) ||
//           item['distribution_pattern'].toLowerCase().contains(getStateInitials(normalizedState)) ||
//           item['distribution_pattern'].toLowerCase().contains('nation') ||
//           item['distribution_pattern'].toLowerCase().contains('country') ||
//           (item['distribution_pattern'].toLowerCase().contains('nationwide') && normalizedState == 'nation') ||
//           (item['distribution_pattern'].toLowerCase().contains('countrywide') && normalizedState == 'country');
//     }
//
//     // Check if the category matches
//     if (requestQuery.category.trim().isNotEmpty) {
//       categoryMatch = item['classification'].toLowerCase().contains(requestQuery.category.toLowerCase());
//     }
//
//     // Return true if both state and category conditions are met
//     return stateMatch && categoryMatch;
//   }).toList();
//
//   print("Results for state ${requestQuery.state} and category ${requestQuery.category}: $ongoingItems");
// } else {
//   print("No state or category selected");
// }



// class TopHeadlinesApi extends BaseApi<
//     TopHeadlinesQueryParams,
//     TopHeadlinesResponse,
//     ErrorResponse> {
//
//   TopHeadlinesApi()
//       : super(NewsApiProvider.topHeadlines, sl<NewsApiProvider>()) {
//     // requestQuery = requestQuery("", "", ""); // or initialize with the required parameters
//   }
//
//   TopHeadlinesQueryParams queryParams = TopHeadlinesQueryParams('', '', '');
//
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
//     if (queryParams != null) {
//       if (queryParams.state.isNotEmpty) {
//         print("Searching for results in the following state: ${queryParams.state}");
//
//         ongoingItems = ongoingItems
//             .where((item) =>
//         item['distribution_pattern']
//             .toLowerCase()
//             .contains(queryParams.state.toLowerCase()) ||
//             item['distribution_pattern']
//                 .toLowerCase()
//                 .contains(getStateInitials(queryParams.state.toLowerCase())))
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


// class TopHeadlinesApi extends BaseApi<TopHeadlinesQueryParams, TopHeadlinesResponse, ErrorResponse> {
//   // final RequestQueryProvider requestQueryProvider;
//
//   RequestQuery requestQuery;
//   TopHeadlinesApi(this.requestQuery)
//       : super(NewsApiProvider.topHeadlines, sl<NewsApiProvider>());
  // TopHeadlinesQueryParams queryParams;


// if (requestQuery.state != null) {
//   print(
//       "Searching for results in the following state: ${requestQuery?.state}");
//
//   ongoingItems = ongoingItems
//       .where((item) =>
//   item['distribution_pattern'].toLowerCase().contains(requestQuery?.state.toLowerCase()) ||
//       item['distribution_pattern'].toLowerCase().contains(getStateInitials(requestQuery!.state.toLowerCase())))
//       .toList();
// } else {
//   print("No state selected");
// }


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