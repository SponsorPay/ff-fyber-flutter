import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

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

  OfferwallResponse.error(this.code, this.message);

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
  final List<OfferType> types;

  OfferData.fromJson(Map<String, dynamic> json)
      : title = json["title"],
        offerId = json["offer_id"],
        teaser = json["teaser"],
        requiredActions = json["required_actions"],
        link = json["link"],
        payout = json["payout"],
        timeToPayout =
            (json["time_to_payout"] as Map<String, dynamic>)["amount"],
        thumbnail = (json["thumbnail"] as Map<String, dynamic>)["hires"],
        types = (json["offer_types"] as List<dynamic>)
            .map((ot) => ot as Map<String, dynamic>)
            .map((typeJson) => OfferType.fromJson(typeJson))
            .toList(growable: false);
}

class OfferType {
  final int id;
  final String readable;

  OfferType.fromJson(Map<String, dynamic> json)
      : id = json["offer_type_id"],
        readable = json["readable"];

  @override
  String toString() => "OfferType[$readable]";
}

class OfferwallRestApiClient {
  final http.Client httpClient = http.Client();

  final String apiKey;
  final String appId;
  final String userId;
  final String locale;
  final String osVersion;
  final String googleAdId;
  final bool googleAdIdLimitedTrackingEnabled;

  OfferwallRestApiClient(this.apiKey, this.appId, this.userId, this.locale,
      this.osVersion, this.googleAdId, this.googleAdIdLimitedTrackingEnabled);

  Future<OfferwallResponse> getOffers({int page = 0}) {
    final int timestamp =
        (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    final params = {
      "appid": appId,
      "uid": userId,
      "locale": locale,
      "os_version": osVersion,
      "timestamp": "$timestamp",
      "google_ad_id": googleAdId,
      "google_ad_id_limited_tracking_enabled":
          "$googleAdIdLimitedTrackingEnabled",
    };
    if (page != 0) {
      params["page"] = "$page";
    }
    final hashcodeString = hashcode(params: params, apiKey: apiKey);
    params["hashkey"] = hashcodeString;

    return httpClient
        .get(Uri.https("api.fyber.com", "/feed/v1/offers.json", params))
        .then((response) {
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return OfferwallResponse.fromJson(jsonResponse);
      } else {
        return OfferwallResponse.error(
            "${response.statusCode}", response.reasonPhrase);
      }
    }, onError: (error) => OfferwallResponse.error("-1", error.toString()));
  }
}
