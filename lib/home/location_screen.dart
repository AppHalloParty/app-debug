// ignore_for_file: deprecated_member_use

import 'package:trace/app/setup.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/models/UserModel.dart';
import 'package:trace/ui/app_bar.dart';
import 'package:trace/ui/rounded_gradient_button.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:location/location.dart' as LocationForAll;
import 'package:parse_server_sdk/parse_server_sdk.dart';

// ignore: must_be_immutable
class LocationScreen extends StatefulWidget {
  static const String route = '/location';

  LocationScreen({this.currentUser});

  UserModel? currentUser;

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Future<void> _determinePosition() async {
    print("Location: _determinePosition clicked");

    LocationForAll.Location location = LocationForAll.Location();

    bool _serviceEnabled;
    LocationForAll.PermissionStatus _permissionGranted;
    LocationForAll.LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        QuickHelp.showAppNotificationAdvanced(
            title: "permissions.location_not_supported".tr(),
            message: "permissions.add_location_manually"
                .tr(namedArgs: {"app_name": Setup.appName}),
            context: context);

        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == LocationForAll.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();

      if (_permissionGranted == LocationForAll.PermissionStatus.granted ||
          _permissionGranted ==
              LocationForAll.PermissionStatus.grantedLimited) {
        QuickHelp.showLoadingDialog(context);

        _locationData = await location.getLocation();
        goHome(_locationData);
      } else if (_permissionGranted == LocationForAll.PermissionStatus.denied) {
        QuickHelp.showAppNotificationAdvanced(
            title: "permissions.location_access_denied".tr(),
            message: "permissions.location_explain"
                .tr(namedArgs: {"app_name": Setup.appName}),
            context: context);
      } else if (_permissionGranted ==
          LocationForAll.PermissionStatus.deniedForever) {
        QuickHelp.showAppNotificationAdvanced(
            title: "permissions.enable_location".tr(),
            message: "permissions.location_access_denied_explain"
                .tr(namedArgs: {"app_name": Setup.appName}),
            context: context);
      }
    } else if (_permissionGranted ==
        LocationForAll.PermissionStatus.deniedForever) {
      _permissionDeniedForEver();
    } else if (_permissionGranted == LocationForAll.PermissionStatus.granted ||
        _permissionGranted == LocationForAll.PermissionStatus.grantedLimited) {
      QuickHelp.showLoadingDialog(context);

      _locationData = await location.getLocation();
      goHome(_locationData);
    }
  }

  _permissionDeniedForEver() {
    QuickHelp.showDialogPermission(
        context: context,
        title: "permissions.location_access_denied".tr(),
        confirmButtonText: "permissions.okay_settings".tr().toUpperCase(),
        message: "permissions.location_access_denied_explain"
            .tr(namedArgs: {"app_name": Setup.appName}),
        onPressed: () async {
          QuickHelp.hideLoadingDialog(context);

          QuickHelp.showAppNotificationAdvanced(
              title: "permissions.enable_location".tr(),
              message: "permissions.location_access_denied_explain"
                  .tr(namedArgs: {"app_name": Setup.appName}),
              context: context);
        });
  }

  goHome(LocationForAll.LocationData locationData) async {
    print("Location ${locationData.latitude}, ${locationData.longitude}");

    if (!widget.currentUser!.getLocationTypeNearBy!) {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.goBackToPreviousPage(context, result: widget.currentUser);

      /* QuickHelp.goToNavigatorScreen(
          context,
          HomeScreen(
            currentUser: widget.currentUser,
          ), back: false,
        finish: true
      );*/
      //return;

    } else {
      print("Location getAddressFromLatLong");

      getAddressFromLatLong(locationData);
    }
  }

  Future<void> getAddressFromLatLong(
      LocationForAll.LocationData position) async {
    ParseGeoPoint parseGeoPoint = new ParseGeoPoint();
    parseGeoPoint.latitude = position.latitude!;
    parseGeoPoint.longitude = position.longitude!;

    widget.currentUser!.setHasGeoPoint = true;
    widget.currentUser!.setGeoPoint = parseGeoPoint;

    /*if(QuickHelp.isMobile()){

      List<Placemark>? placements;
      placements = await placemarkFromCoordinates(position.latitude!, position.longitude!);
      print(placements);

      Placemark place = placements[0];
      //Address = '${place.street}, ${place.subLocality}, ${place.locality}, ${place.postalCode}, ${place.country}';

      widget.currentUser!.setLocation = "${place.locality}, ${place.country}";
      widget.currentUser!.setCity = "${place.locality}";
    }*/

    ParseResponse parseResponse = await widget.currentUser!.save();

    if (parseResponse.success) {
      widget.currentUser = parseResponse.results!.first as UserModel;

      QuickHelp.hideLoadingDialog(context);
      QuickHelp.goBackToPreviousPage(context, result: widget.currentUser);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        user: widget.currentUser,
        title: "permissions.location_updated".tr(),
        message: "permissions.location_updated_explain".tr(),
        isError: false,
      );

      /* QuickHelp.goToNavigatorScreen(
          context,
          HomeScreen(
            currentUser: widget.currentUser,
          ), back: false, finish: true);*/

    } else {
      QuickHelp.hideLoadingDialog(context);
      QuickHelp.goBackToPreviousPage(context);

      QuickHelp.showAppNotificationAdvanced(
        context: context,
        user: widget.currentUser,
        title: "permissions.location_updated_null".tr(),
        message: "permissions.location_updated_null_explain".tr(),
        isError: true,
      );
    }
  }

  Future<bool> _onBackPressed() async {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    //QuickHelp.setWebPageTitle(context, "page_title.location_title".tr());

    return new PopScope(
      onPopInvoked: (pop) => _onBackPressed,
      child: ToolBar(
        leftButtonIcon:
            QuickHelp.isIOSPlatform() ? Icons.arrow_back_ios : Icons.arrow_back,
        onLeftButtonTap: () => QuickHelp.goBackToPreviousPage(context),
        child: SafeArea(
          child: body(),
        ),
      ),
    );
  }

  Widget body() {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Container(),
            ],
          ),
          Container(
            child: Icon(
              Icons.location_on_outlined,
              color: kPrimaryColor,
              size: 200,
            ),
          ),
          Column(
            children: [
              TextWithTap(
                "permissions.enable_location".tr(),
                marginTop: 20,
                fontSize: 25,
                marginBottom: 5,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
              TextWithTap(
                "permissions.location_explain"
                    .tr(namedArgs: {"app_name": Setup.appName}),
                textAlign: TextAlign.center,
                marginTop: 0,
                fontSize: 14,
                marginBottom: 5,
                marginLeft: 50,
                marginRight: 50,
                color: kPrimacyGrayColor,
              ),
              RoundedGradientButton(
                height: 48,
                marginLeft: 30,
                marginRight: 30,
                marginBottom: 30,
                borderRadius: 60,
                borderRadiusBottomLeft: 15,
                marginTop: 50,
                fontSize: 17,
                colors: [kPrimaryColor, kSecondaryColor],
                textColor: Colors.white,
                text: "permissions.allow_location".tr().toUpperCase(),
                fontWeight: FontWeight.normal,
                onTap: () {
                  _determinePosition();
                },
              ),
              TextWithTap(
                "permissions.location_tell_more".tr(),
                textAlign: TextAlign.center,
                marginTop: 0,
                fontSize: 14,
                marginBottom: 10,
                marginLeft: 50,
                marginRight: 50,
                color: kPrimacyGrayColor,
                onTap: () {
                  QuickHelp.showDialogPermission(
                      context: context,
                      confirmButtonText:
                          "permissions.allow_location".tr().toUpperCase(),
                      title: "permissions.meet_people".tr(),
                      message: "permissions.meet_people_explain".tr(),
                      onPressed: () async {
                        QuickHelp.hideLoadingDialog(context);

                        _determinePosition();
                      });
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}
