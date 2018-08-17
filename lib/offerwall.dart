import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fyber_4_flutter/offerwall_utils.dart';

export 'offerwall_utils.dart';

class Offerwall extends StatefulWidget {
  final String apiKey;
  final String appId;
  final String userId;
  final String googleAdId;
  final bool googleAdIdLimitedTrackingEnabled;
  final String osVersion;

  const Offerwall(
      {Key key,
      this.apiKey,
      this.appId,
      this.userId,
      this.googleAdId,
      this.googleAdIdLimitedTrackingEnabled,
      this.osVersion})
      : super(key: key);

  @override
  _OfferwallState createState() => _OfferwallState();
}

class _OfferwallState extends State<Offerwall> {
  OfferwallRestApiClient _restClient;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prepareRestClient();
  }

  @override
  Widget build(BuildContext context) {
    return _OfferwallLoader(client: _restClient);
  }

  void _prepareRestClient() {
    var locale = Localizations.localeOf(context);
    var lang = locale?.languageCode ?? "en";
    var osVersion = Platform.operatingSystemVersion;
    _restClient = OfferwallRestApiClient(
        widget.apiKey,
        widget.appId,
        widget.userId,
        lang,
        osVersion,
        widget.googleAdId,
        widget.googleAdIdLimitedTrackingEnabled);
  }
}

class _OfferwallLoader extends StatelessWidget {
  final OfferwallRestApiClient client;

  const _OfferwallLoader({Key key, this.client}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      builder: _buildOfferwallFromResponse,
      future: client.getOffers(),
    );
  }

  Widget _buildOfferwallFromResponse(
      BuildContext context, AsyncSnapshot<OfferwallResponse> snapshot) {
    Widget result;
    if (snapshot.hasData) {
      OfferwallResponse data = snapshot.data;
      if (data.code != "OK") {
        result = _buildOfferwallError(context, data.message);
      } else {
        result = _buildOfferwallOffers(context, data);
      }
    } else if (snapshot.hasError) {
      result = _buildOfferwallError(context, "${snapshot.error}");
    } else {
      result = Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(child: result);
  }

  Widget _buildOfferwallError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            "Error receiving offers",
            style: Theme
                .of(context)
                .textTheme
                .subhead
                .copyWith(color: Colors.red.shade300),
          ),
          Text(
            message,
          ),
        ],
      ),
    );
  }

  Widget _buildOfferwallOffers(BuildContext context, OfferwallResponse data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // title
        Container(
          height: 80.0,
          child: Center(
            child: Text(
              "Win ${data.currency}",
              style: Theme.of(context).textTheme.title,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: data.offers.length,
              itemBuilder: (BuildContext context, int index) =>
                  _buildOfferItemWidget(context, data.offers[index])),
        ),
      ],
    );
  }

  Widget _buildOfferItemWidget(BuildContext context, OfferData offer) =>
      ListTile(
        leading: Stack(
          children: [
            Image.network(
              offer.thumbnail,
              height: 80.0,
            ),
            Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black12,
                        Colors.black54,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      "${offer.payout}",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ))
          ],
          alignment: AlignmentDirectional.center,
        ),
        title: Text(offer.title),
        subtitle: Text("${offer.teaser}"),
        isThreeLine: true,
      );
}
