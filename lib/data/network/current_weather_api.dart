import 'package:safe_scan/data/models/top_headlines_query_params.dart';
import '../../core/service_locator.dart';
import '../../model/request_query.dart';
import '../api_provider/news_api_provider.dart';
import '../models/base_model/base_model.dart';
import '../models/error_response.dart';
import '../models/top_headlines_response.dart';
import 'package:safe_scan/ui/screens/home/widgets/query_widget.dart';
import 'base_api/base_api.dart';


class ApiData {
  static List<dynamic>? responseJson;
  // Option 1: Make responseJson public
  static List<dynamic>? getResponseJson() => responseJson;
}

class StateApiData{
  static List<dynamic>? stateresponseJson;
  // Option 1: Make responseJson public
  static List<dynamic>? getstateResponseJson() => stateresponseJson;


}

class AllApiData {
  static Map<String, List<dynamic>> _allResponseJson = {};

  static void addResponseJson(String category, List<dynamic> responseJson) {
    _allResponseJson[category] = responseJson;
  }

  static Map<String, List<dynamic>> getAllResponseJson() => _allResponseJson;
}



class RecallApi extends BaseApi<TopHeadlinesQueryParams,
    RecallsResponse, ErrorResponse> {


  RecallApi({required this.requestQuery})

      // : super(NewsApiProvider.topHeadlines,
      // sl<NewsApiProvider>());
      : super(CategoryData.category == 'DRUG' ? RecallDataApiProvider.drugsRecalls :
              CategoryData.category == 'DEVICE' ? RecallDataApiProvider.deviceRecalls
      : RecallDataApiProvider.topHeadlines,
      sl<RecallDataApiProvider>());


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

    // Filter items based on the 'status' field
    List<dynamic> stateFilteredItems = ongoingItems;

    if (requestQuery.query.trim().isNotEmpty) {
      stateFilteredItems = stateFilteredItems.where((item) {
        // Check if the "product_description" contains the search query
        return item['product_description'].toLowerCase().contains(requestQuery.query.toLowerCase());
      }).toList();
    }

    if (requestQuery.state.trim().isNotEmpty || requestQuery.classification.trim().isNotEmpty) {
      stateFilteredItems = stateFilteredItems.where((item) {
        bool stateMatch = true; // Default to true
        bool classificationMatch = true; // Default to true

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

        // Check if the classification matches exactly
        if (requestQuery.classification.trim().isNotEmpty) {
          classificationMatch = item['classification'].toLowerCase() ==
              requestQuery.classification.toLowerCase();
        }

        // Return true only if both conditions (state and category) are met
        return stateCondition && (classificationMatch || !requestQuery.classification.trim().isNotEmpty);
      }).toList();
    }

    // Store filtered data according to the state in StateApiData.stateresponseJson
    StateApiData.stateresponseJson = stateFilteredItems;

    // Store the response JSON in AllApiData
    AllApiData.addResponseJson(CategoryData.category ?? '', stateFilteredItems);

    // Sort the ongoingItems list by 'report_date' in descending order
    stateFilteredItems.sort((a, b) {
      DateTime dateA = DateTime.parse(a['report_date']);
      DateTime dateB = DateTime.parse(b['report_date']);
      return dateB.compareTo(dateA);
    });

    // Create a new response JSON with only filtered items
    Map<String, dynamic> filteredResponseJson = {
      ...responseJson!,
      'results': stateFilteredItems,
    };

    print("Success Response: $filteredResponseJson");
    return RecallsResponse.fromJson(filteredResponseJson);
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
