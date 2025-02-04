import 'package:parse_server_sdk/parse_server_sdk.dart';

class DietPlanModel extends ParseObject implements ParseCloneable {

  static final String keyTableName = "DietPlan";

  DietPlanModel() : super(keyTableName);
  DietPlanModel.clone() : this();

  @override
  DietPlanModel clone(Map<String, dynamic> map) => DietPlanModel.clone()..fromJson(map);

  static String keyCreatedAt = "createdAt";
  static String keyObjectId = "objectId";

  static String keyName = "name";
  static String keyAge = "age";
  static String keyHeight = "height";

  String? get getNome => get(keyName);
  set setName(String name) => set<String>(keyName, name);

  int? get getAge => get(keyAge);
  set setAge(int age) => set<int>(keyAge, age);

  double? get getHeight => get(keyHeight);
  set setHeight(double height) => set<double>(keyAge, height);

}