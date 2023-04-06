import 'package:firebase_database/firebase_database.dart';

class Users {
  String? id;
  String? email;
  String? name;
  String? number;
  String? cnic;
  String? univesity;
  String? profile;

  Users(
      {this.id,
      this.email,
      this.name,
      this.number,
      this.univesity,
      this.cnic,
      this.profile});

  Users.fromSnapshot(DataSnapshot dataSnapshot) {
    id = dataSnapshot.key;
    email = (dataSnapshot.child("email").value.toString());
    name = (dataSnapshot.child("name").value.toString());
    number = (dataSnapshot.child("number").value.toString());
    cnic = (dataSnapshot.child("cnic").value.toString());
    univesity = (dataSnapshot.child("university").value.toString());
    profile = (dataSnapshot.child("profile").value.toString());
  }
}
