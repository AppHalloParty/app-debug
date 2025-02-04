class CountryModel {
  String dialCode = "";
  String isoCode = "";
  List<String> languagesIso = [];

  CountryModel({
    required this.dialCode,
    required this.isoCode,
    required this.languagesIso,
  });


  String setDialCode(String dial) {
    return this.dialCode = dial;
  }

  String getDialCode() {
    return dialCode;
  }

  String setIsoCode(String iso) {
    return this.isoCode = iso;
  }

  String getIsoCode() {
    return this.isoCode;
  }
}