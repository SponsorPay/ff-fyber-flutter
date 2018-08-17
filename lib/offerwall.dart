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
    _restClient = OfferwallRestApiClient(
        widget.apiKey,
        widget.appId,
        widget.userId,
        lang,
        widget.osVersion,
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
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              "Error receiving offers",
              style: Theme
                  .of(context)
                  .textTheme
                  .title
                  .copyWith(color: Colors.red.shade300),
            ),
            SizedBox(
              height: 12.0,
            ),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
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

  Widget _buildOfferItemWidget(BuildContext context, OfferData offer) {
    final theme = Theme.of(context);
    final thumbnail = offer.thumbnail;
    final payout = offer.payout;
    final iconBorderSize = 80.0;
    final types = offer.types;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          new OfferIcon(
            iconBorderSize: iconBorderSize,
            thumbnail: thumbnail,
            payout: payout,
          ),
          SizedBox(
            width: 8.0,
          ),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    offer.title,
                    style: theme.textTheme.title
                        .copyWith(fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    offer.requiredActions,
                    style: theme.textTheme.body2,
                  ),
                  SizedBox(height: 2.0),
                  new TypeTags(types: types)
                ]),
          )
        ],
      ),
    );
  }
}

class TypeTags extends StatelessWidget {
  const TypeTags({Key key, @required this.types}) : super(key: key);

  final List<OfferType> types;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Wrap(
      spacing: 4.0,
      runSpacing: 2.0,
      children: types
          .map((type) => DecoratedBox(
                decoration: ShapeDecoration(
                  //fancy color calculation
                  color: Color.fromRGBO(type.id % 255, type.id * 31 % 255,
                      type.id * 17 % 255, 1.0),
                  shape: StadiumBorder(),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 2.0),
                  child: Text(
                    type.readable.toUpperCase(),
                    style: theme.textTheme.body1
                        .copyWith(color: Colors.white, fontSize: 8.0),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class OfferIcon extends StatelessWidget {
  const OfferIcon({
    Key key,
    @required this.thumbnail,
    @required this.payout,
    this.iconBorderSize = 80.0,
  }) : super(key: key);

  final double iconBorderSize;
  final String thumbnail;
  final int payout;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return SizedBox(
      width: iconBorderSize,
      height: iconBorderSize,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(12.0)),
            child: Image.network(
              thumbnail,
            ),
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
                      Colors.black.withOpacity(0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(12.0)),
                ),
                child: Center(
                  child: Text(
                    "$payout",
                    style: theme.textTheme.body1.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ))
        ],
        alignment: AlignmentDirectional.center,
      ),
    );
  }
}
