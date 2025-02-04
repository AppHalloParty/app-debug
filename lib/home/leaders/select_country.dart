import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trace/helpers/quick_actions.dart';
import 'package:trace/helpers/quick_help.dart';
import 'package:trace/ui/container_with_corner.dart';
import 'package:trace/ui/text_with_tap.dart';
import 'package:trace/utils/colors.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class SelectCountryScreen extends StatefulWidget {
  SelectCountryScreen({Key? key}) : super(key: key);
  static String route = "/CountriesSelector";

  @override
  _SelectCountryScreenState createState() => _SelectCountryScreenState();
}

List countrySelectedList = [];

Future<List> getCountries(String countryName) async {
  final request = "https://restcountries.com/v3.1/all";
  final searchRequest = "https://restcountries.com/v3.1/name/$countryName";
  http.Response? response;

  if(countryName.isNotEmpty) {
    response = await http.get(Uri.parse(searchRequest));
  }else{
    response = await http.get(Uri.parse(request));
  }
  return json.decode(response.body);
}

TextEditingController countryController = TextEditingController();
String nameOfCountry = "";



class _SelectCountryScreenState extends State<SelectCountryScreen> {

  Stream<FileResponse>? fileStream;

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: (){
        FocusScopeNode focusScopeNode = FocusScope.of(context);
        if (!focusScopeNode.hasPrimaryFocus &&
            focusScopeNode.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: QuickHelp.isDarkMode(context) ? kContentColorLightTheme : kContentColorDarkTheme,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: TextButton(onPressed: ()=> QuickHelp.goBackToPreviousPage(context),
          child: TextWithTap("done".tr(), color: QuickHelp.isDarkMode(context) ? kContentColorDarkTheme : kContentColorLightTheme,),
          ),
          actions: [
            TextWithTap(
              "leaders.menu_clear_all".tr(),
              color: QuickHelp.isDarkMode(context) ? kContentColorDarkTheme : kContentColorLightTheme,
              marginTop: 20,
              marginRight: 15,
              onTap: (){
                setState(() {
                  countrySelectedList = [];
                });
              },
            )
          ],
          backgroundColor: kTransparentColor,
          centerTitle: true,
          title: TextWithTap(
            "leaders.title_select_county".tr(),
            color: QuickHelp.isDarkMode(context) ? kContentColorDarkTheme : kContentColorLightTheme,
            fontSize: 17,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              ContainerCorner(
                borderColor: kGrayColor,
                borderRadius: 50,
                marginLeft: 20,
                marginRight: 20,
                marginBottom: 30,
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: TextField(
                    autocorrect: false,
                    maxLines: null,
                    controller: countryController,
                    decoration: InputDecoration(
                      hintText: "leaders.search_country".tr(),
                      hintStyle: TextStyle(
                        color: kGrayColor
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: (text){
                      setState(() {
                        if(countryController.text.isNotEmpty){
                          nameOfCountry = countryController.text;
                        }else{
                          nameOfCountry = "";
                        }

                      });
                    },
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List>(
                  future: getCountries(nameOfCountry),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      default:
                        if (snapshot.hasError) {
                          return QuickActions.noContentFound(context);
                        } else {
                          return Center(
                            child: ReorderableListView.builder(
                              onReorder: (int , int1){},
                              itemCount: (snapshot.data as List).length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  key: Key(index.toString()),
                                  onTap: (){
                                    setState(() {
                                      countrySelectedList.add(snapshot.data![index]["cca2"]);
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      ContainerCorner(
                                        color: countrySelectedList.contains(snapshot.data![index]["cca2"]) ? kGreenColor: kTransparentColor,
                                        borderColor: kGreenColor,
                                        height: 15,
                                        width: 15,
                                        borderRadius: 50,
                                        marginBottom: 10,
                                        marginLeft: 10,
                                      ),
                                      ContainerCorner(
                                        width: 25,
                                        height: 25,
                                        marginBottom: 10,
                                        marginLeft: 10,
                                        child: SvgPicture.network(
                                          snapshot.data![index]["flags"]
                                          ["svg"],
                                        ),
                                      ),
                                      Expanded(
                                        child: TextWithTap(
                                          snapshot.data![index]["name"]
                                          ["common"]
                                              .toString(),
                                          color: QuickHelp.isDarkMode(context) ? kContentColorDarkTheme : kContentColorLightTheme,
                                          marginLeft: 10,
                                          marginBottom: 10,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
