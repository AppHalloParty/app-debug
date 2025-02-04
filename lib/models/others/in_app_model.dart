import 'package:purchases_flutter/purchases_flutter.dart';

class InAppPurchaseModel {
  static final String typePopular = "popular";
  static final String typeHot = "hot";
  static final String typeNormal = "normal";

  String? id;
  String? price;
  int? coins;
  DateTime? period;
  String? discount;
  String? type;
  String? image;
  String? currencySymbol;
  String? currency;
  StoreProduct? storeProduct;
  Package? package;

  InAppPurchaseModel({
    this.id,
    this.price,
    this.coins,
    this.period,
    this.discount,
    this.type,
    this.image,
    this.currency,
    this.currencySymbol,
    this.storeProduct,
    this.package,
  });

  String? getId() {
    return id;
  }

  void setId(String id) {
    this.id = id;
  }

  String? getPrice() {
    return price;
  }

  void setPrice(String price) {
    this.price = price;
  }

  int? getCoins() {
    return coins;
  }

  void setCoins(int coins) {
    this.coins = coins;
  }

  DateTime? getPeriod() {
    return period;
  }

  void setPeriod(DateTime time) {
    this.period = time;
  }

  String? getDiscount() {
    return discount;
  }

  void setDiscount(String discount) {
    this.discount = discount;
  }

  String? getType() {
    return type;
  }

  void setType(String type) {
    this.type = type;
  }

  String? getImage() {
    return image;
  }

  void setImage(String image) {
    this.image = image;
  }

  String? getCurrency() {
    return currency;
  }

  void setCurrency(String currency) {
    this.currency = currency;
  }

  String? getCurrencySymbol() {
    return currencySymbol;
  }

  void setCurrencySymbol(String currencySymbol) {
    this.currencySymbol = currencySymbol;
  }

  StoreProduct? getStoreProduct() {
    return storeProduct;
  }

  void setStoreProduct(StoreProduct storeProduct) {
    this.storeProduct = storeProduct;
  }

  Package? getPackage() {
    return package;
  }

  void setPackage(Package package) {
    this.package = package;
  }
}
