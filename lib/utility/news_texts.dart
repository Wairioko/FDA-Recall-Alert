class NewsTexts {
  static Map<String, dynamic> get() => {
        "noOrSlowInternetConnection": "Showing data from local storage, no stable internet connection available",
        "networkConnectivityError": "Showing data from local storage, no internet connection available",
        "anErrorOccurred": "An error occurred. Please try again",
        "noLocalData": "Please pull to refresh, Can't fetch data from internet and no local cache available",
        "refreshCTA": "Refresh",
        "search": "Apply Search",
        "emptyQuery": "No data found for your query",
      };

  static List<String> shoppingFrequencyList() => <String>[
        'Multiple times each week',
        'Every 2 weeks',
        'After 3 weeks',
  ];

  static List<String> itemList() => <String>[
    'FOOD',
    'DRUGS',
    'DEVICE',
  ];

  static List<String> stateList() => <String>[
        "Alabama", "Alaska", "Arizona", "Arkansas",
        "California", "Colorado", "Connecticut",
        "Delaware", "Florida", "Georgia", "Hawaii",
        "Idaho", "Illinois", "Indiana", "Iowa",
        "Kansas", "Kentucky",
        "Louisiana",
        "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana",
        "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota",
        "Ohio", "Oklahoma", "Oregon", "Pennsylvania",
        "Rhode Island",
        "South Carolina", "South Dakota",
        "Tennessee", "Texas",
        "Utah",
        "Vermont", "Virginia",
        "Washington", "West Virginia", "Wisconsin", "Wyoming"
      ];

  static List<String> classificationList() => <String>[
        'Class I',
        'Class II',
        'Class III'
      ];
}
