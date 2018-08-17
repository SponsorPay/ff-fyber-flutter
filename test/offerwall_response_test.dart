import 'package:fyber_4_flutter/offerwall.dart';
import 'package:test/test.dart';
import 'dart:convert';

void main() {
  test("Response should be correctly parsed", () {
    final responseAsText = """
      {
	"code": "OK",
	"message": "Ok",
	"count": 1,
	"pages": 1,
	"information": {
		"app_name": "REST API DEMO",
		"appid": 47403,
		"virtual_currency": "Coins",
		"virtual_currency_sale_enabled": false,
		"country": "DE",
		"language": "EN",
		"support_url": "http://offer.fyber.com/mobile/support?appid=47403&client=api&uid=player%401"
	},
	"offers": [
		{
			"title": "REST API Demo Offer",
			"offer_id": 1036531,
			"teaser": "Download and START",
			"required_actions": "Download and START",
			"link": "http://offer.fyber.com/mobile?impression=true&appid=47403&uid=player%401&client=api&platform=android&appname=REST+API+DEMO&traffic_source=offer_api&country_code=DE&pubid=84206&ip=212.45.111.17&google_ad_id=a0b0c0d0a0b0c0d0e0f0a0b0c0d0e0f0&ad_id=1036531&os_version=6.0&ad_format=offer&group=Fyber&sig=69104a9fac790d8f1b352f5e549c0f88021676cb",
			"offer_types": [
				{
					"offer_type_id": 101,
					"readable": "Download"
				},
				{
					"offer_type_id": 112,
					"readable": "Free"
				}
			],
			"payout": 10,
			"time_to_payout": {
				"amount": 1800,
				"readable": "30 minutes"
			},
			"thumbnail": {
				"lowres": "http://cdn2.sponsorpay.com/assets/45288/Fyber_Logo_square_60.png",
				"hires": "http://cdn2.sponsorpay.com/assets/45288/Fyber_Logo_square_175.png"
			}
		}
	]
}
    """;
    Map<String, dynamic> responseAsJson = json.decode(responseAsText);

    final offerwallResponse = OfferwallResponse.fromJson(responseAsJson);
    expect(offerwallResponse.code, "OK");
    expect(offerwallResponse.count, 1);
    expect(offerwallResponse.offers.length, 1);
    expect(offerwallResponse.offers[0].offerId, 1036531);
    expect(offerwallResponse.offers[0].timeToPayout, 1800);
    expect(offerwallResponse.offers[0].title, "REST API Demo Offer");
    expect(offerwallResponse.offers[0].thumbnail,
        "http://cdn2.sponsorpay.com/assets/45288/Fyber_Logo_square_175.png");
    expect(offerwallResponse.offers[0].types.length, 2);
    expect(offerwallResponse.offers[0].types[0].id, 101);
    expect(offerwallResponse.offers[0].types[1].id, 112);
    expect(offerwallResponse.offers[0].types[0].readable, "Download");
    expect(offerwallResponse.offers[0].types[1].readable, "Free");
  });
}
