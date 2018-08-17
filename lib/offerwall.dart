import 'dart:convert';

import 'package:crypto/crypto.dart';

String hashcode({Map<String, String> params, String apiKey}) {
  // sort param names
  final sortedParams = params.keys.toList()..sort();
  // concatenated sorted params
  final concatenatedParams = sortedParams
      .map((paramName) => "$paramName=${params[paramName]}")
      .join("&");
  // concatenated with apiKey
  final paramsWithApiKey = "$concatenatedParams&$apiKey";

  // creating sha1
  final paramsWithApiKeyBytes = utf8.encode(paramsWithApiKey);
  final sha1Value = sha1.convert(paramsWithApiKeyBytes);
  final hash = sha1Value.toString();
  return hash;
}

class OfferwallResponse {
  final String code;
  final String message;
  final int pages;
  final int count;
  final List<OfferData> offers;

  OfferwallResponse.fromJson(Map<String, dynamic> json)
      : code = json["code"],
        message = json["message"],
        pages = json["pages"],
        count = json["count"],
        offers = (json["offers"] as List<dynamic>)
            .map((element) => element as Map<String, dynamic>)
            .map((offerJson) => OfferData.fromJson(offerJson))
            .toList();
}

class OfferData {
  final String title;
  final int offerId;
  final String teaser;
  final String requiredActions;
  final String link;
  final int payout;
  final int timeToPayout;
  final String thumbnail;

  OfferData.fromJson(Map<String, dynamic> json)
      : title = json["title"],
        offerId = json["offer_id"],
        teaser = json["teaser"],
        requiredActions = json["required_actions"],
        link = json["link"],
        payout = json["payout"],
        timeToPayout =
            (json["time_to_payout"] as Map<String, dynamic>)["amount"],
        thumbnail = (json["thumbnail"] as Map<String, dynamic>)["hires"];
}
