class User {
  int uid; //reference to user uid

  bool isSpeaking; // reference to whether the user is speaking

  User(this.uid, this.isSpeaking);

  @override
  String toString() {
    return 'User{uid: $uid, isSpeaking: $isSpeaking}';
  }
}