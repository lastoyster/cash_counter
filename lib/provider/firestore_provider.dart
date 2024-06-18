import 'dart:async';
import 'package:cash_counter/model/firestore_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

enum Menu { atoz, debit, credit, time }

class Database {
  var uuid = const Uuid();
  num sum = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create an instance of Firebase Firestore.
  late CollectionReference
      _movies; // this holds a refernece to the Movie collection in our firestore.

  Stream get allMovies => _firestore
      .collection("users")
      .doc()
      .snapshots(); // a stream that is continuously listening for changes happening in the database
  Stream<DocumentSnapshot<Map<String, dynamic>>> get getUserDetail =>
      _firestore.collection("users").doc(_auth.currentUser?.uid).snapshots();
  Stream<QuerySnapshot<Map<String, dynamic>>> udharDetail(
      String selectedMenu) async* {
    if (selectedMenu == Menu.time.name) {
      yield* _firestore
          .collection("users")
          .doc(_auth.currentUser?.uid)
          .collection("udhar")
          .orderBy("date", descending: true)
          .snapshots();
    } else if (selectedMenu == Menu.atoz.name) {
      yield* _firestore
          .collection("users")
          .doc(_auth.currentUser?.uid)
          .collection("udhar")
          .orderBy("name")
          .snapshots();
    } else if (selectedMenu == Menu.debit.name) {
      yield* _firestore
          .collection("users")
          .doc(_auth.currentUser?.uid)
          .collection("udhar")
          .orderBy("debit", descending: false)
          .snapshots();
    } else if (selectedMenu == Menu.credit.name) {
      yield* _firestore
          .collection("users")
          .doc(_auth.currentUser?.uid)
          .collection("udhar")
          .orderBy("credit", descending: true)
          .snapshots();
    }
  }

  //create setter for  reference
  Stream<QuerySnapshot<Map<String, dynamic>>> creditndDebita(
      String? uid) async* {
    yield* _firestore
        .collection("users")
        .doc(_auth.currentUser?.uid)
        .collection("udhar")
        .doc(uid)
        .collection("creditanddebit")
        .where('date',
            isLessThanOrEqualTo:
                DateTime.now().add(const Duration(days: 10000)))
        .snapshots();
  }

  // A method that will add a new Movie m to our Movies collection and return true if its successful.
  // Future<bool> addNewMovie(Movie m) async {
  //   _movies =
  //       _firestore.collection('movies'); // referencing the movie collection .
  //   try {
  //     await _movies.add({
  //       'name': m.movieName,
  //       'poster': m.posterURL,
  //       'length': m.length
  //     }); // Adding a new document to our movies collection
  //     return true; // finally return true
  //   } catch (e) {
  //     return Future.error(e); // return error
  //   }
  // }
  setSearchParam(String caseNumber) {
    List<String> caseSearchList = [];
    String temp = "";
    for (int i = 0; i < caseNumber.length; i++) {
      temp = temp + caseNumber[i];
      caseSearchList.add(temp.toLowerCase());
    }
    return caseSearchList;
  }

  Future<bool> removeMovie(String movieId) async {
    _movies = _firestore.collection('movies');
    try {
      await _movies
          .doc(movieId)
          .delete(); // deletes the document with id of movieId from our movies collection
      return true; // return true after successful deletion .
    } catch (e) {
      print(e);
      return Future.error(e); // return error
    }
  }

  Future<bool> createUser(Userdata m) async {
    _movies = _firestore.collection('users');
    try {
      await _movies.doc(_auth.currentUser?.uid).set({
        'name': m.name,
        "email": m.email,
        "gstminus": {"3": "3", "5": "5", "12": "12", "18": "18", "28": "28"},
        "gstplus": {"3": "3", "5": "5", "12": "12", "18": "18", "28": "28"}
      });
      print("Done");
      // update the document with id of movieId from our movies collection
      return true; // return true after successful update .
    } catch (e) {
      print(e);
      return Future.error(e); // return error
    }
  }

  Future updateGst(Map<String, Object?> gst) async {
    var _gst = _firestore.collection('users');
    try {
      await _gst.doc(_auth.currentUser?.uid).update(gst);
      Fluttertoast.showToast(msg: "Updated");
      // update the document with id of movieId from our movies collection
      return true; // return true after successful update .
    } catch (e) {
      print(e);
      return Future.error(e); // return error
    }
  }

  //create udhar account for user
  Future createUdharAccount(number, name) async {
    var v1 = uuid.v1();

    var udhar = _firestore.collection('users');
    try {
      await udhar.doc(_auth.currentUser?.uid).collection("udhar").doc(v1).set({
        "credit": 0,
        "debit": 0,
        "date": DateTime.now(),
        "closebalance": 0,
        "name": name,
        "number": number,
        "useruid": _auth.currentUser?.uid,
        "uuid": v1,
        'caseNumber': setSearchParam(name)
      });
      Fluttertoast.showToast(msg: "Udhar Account Created");
      // update the document with id of movieId from our movies collection
      return true; // return true after successful update .
    } catch (e) {
      print(e);
      return Future.error(e); // return error
    }
  }

  Future<bool> checkDrCrBalance(String? uid, cr, dr) async {
    var _gst = _firestore.collection('users');
    try {
      var doc = await _gst
          .doc(_auth.currentUser?.uid)
          .collection("udhar")
          .doc(uid)
          .get();
      if (doc.data()!["debit"] == dr && doc.data()!["credit"] == cr) {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      print(e);
      return Future.error(e); // return error
    }
  }

  // create credit and debit account for user
  Future createCreditDebitAccount(
      {required String number,
      required String name,
      required String? currentUid,
      required DateTime dateTime,
      required int closebalance,
      required int amount,
      required String remark,
      required String type}) async {
    var v1 = uuid.v1();
    var udhar = _firestore.collection('users');
    try {
      await udhar
          .doc(_auth.currentUser?.uid)
          .collection("udhar")
          .doc(currentUid)
          .collection("creditanddebit")
          .get()
          .then((value) async {
        if (value.docs.isEmpty) {
          await udhar
              .doc(_auth.currentUser?.uid)
              .collection("udhar")
              .doc(currentUid)
              .collection("creditanddebit")
              .doc(v1)
              .set({
            "credit": 0,
            "debit": 0,
            "date": dateTime,
            "closebalance": amount,
            "name": name,
            "number": number,
            "amount": amount,
            "remark": remark,
            "useruid": _auth.currentUser?.uid,
            "uuid": v1,
            "type": type,
          });
          Fluttertoast.showToast(msg: "Credit/Debit Account Created");
          // update the document with id of movieId from our movies collection
          return true; // return true after successful update .

        } else if (value.docs.isNotEmpty) {
          await udhar
              .doc(_auth.currentUser?.uid)
              .collection("udhar")
              .doc(currentUid)
              .collection("creditanddebit")
              .doc(v1)
              .set({
            "credit": 0,
            "debit": 0,
            "date": dateTime,
            "closebalance": closebalance,
            "name": name,
            "number": number,
            "amount": amount,
            "remark": remark,
            "type": type,
            "useruid": _auth.currentUser?.uid,
            "uuid": v1
          });
          Fluttertoast.showToast(msg: "Credit/Debit Account Created");
          // update the document with id of movieId from our movies collection
          return true; // return true after successful update .
        }
      });
    } catch (e) {
      print(e);
      return Future.error(e); // return error
    }
  }

  //updateCreditDebitAccount for user
  Future updateCreditDebitAccount(
      {required String number,
      required String name,
      required String? currentUid,
      required DateTime dateTime,
      required int closebalance,
      required int amount,
      required String remark,
      required String type,
      required String docuid}) async {
    var v1 = uuid.v1();
    var udhar = _firestore.collection('users');

    try {
      await udhar
          .doc(_auth.currentUser?.uid)
          .collection("udhar")
          .doc(currentUid)
          .collection("creditanddebit")
          .doc(docuid)
          .update({
        "credit": 0,
        "debit": 0,
        "date": dateTime,
        "closebalance": closebalance,
        "name": name,
        "number": number,
        "amount": amount,
        "remark": remark,
        "type": type,
        "useruid": _auth.currentUser?.uid,
        "uuid": v1
      });
      Fluttertoast.showToast(msg: "Credit/Debit Account Updated");
    } catch (e) {
      print(e);
      return Future.error(e); // return error
    }
  }

  // delete updateCreditDebitAccount for user
  Future deleteCreditDebitAccount(
      {required String? currentUid, required String docuid}) async {
    var udhar = _firestore.collection('users');

    try {
      await udhar
          .doc(_auth.currentUser?.uid)
          .collection("udhar")
          .doc(currentUid)
          .collection("creditanddebit")
          .doc(docuid)
          .delete();
      Fluttertoast.showToast(msg: "Credit/Debit Account Deleted");
    } catch (e) {
      print(e);
      return Future.error(e); // return error
    }
  }

  //convert debit to credit and vice versa
  Future convertDebitToCredit(
      {required String? currentUid,
      required String docuid,
      required String type,
      required int amount,
      required int closebalance}) async {
    var udhar = _firestore.collection('users');

    try {
      await udhar
          .doc(_auth.currentUser?.uid)
          .collection("udhar")
          .doc(currentUid)
          .collection("creditanddebit")
          .doc(docuid)
          .update({
        "type": type,
        "amount": type == "debit" ? -amount : amount.abs(),
        "closebalance": type == "debit" ? -closebalance : closebalance.abs()
      });
      Fluttertoast.showToast(msg: "Debit to Credit");
    } catch (e) {
      print(e);
      return Future.error(e); // return error
    }
  }

// create firebase auth otp

  // Update a Movie
  // A method that will update a Movie m to our Movies collection and return true if its successful.
  // Future<bool> updateMovie(Movie m) async {
  //   _movies =
  //       _firestore.collection('movies'); // referencing the movie collection .
  //   try {
  //     await _movies.doc(m.id).update({
  //       'name': m.movieName,
  //       'poster': m.posterURL,
  //       'length': m.length
  //     }); // updating the document with id of movieId from our movies collection
  //     return true; // finally return true
  //   } catch (e) {
  //     return Future.error(e); // return error
  //   }
  // }
}
// Edit a Movie
// Future<bool> editMovie(Movie m, String movieId) async {
//   _movies = _firestore.collection('movies');
//   try {
//     await _movies
//         .doc(movieId)
//         .update(// updates the movie document having id of moviedId
//             {'name': m.movieName, 'poster': m.posterURL, 'length': m.length});
//     return true; //// return true after successful updation .
//   } catch (e) {
//     print(e);
//     return Future.error(e); //return error
//   }
// }

// Creating a simple Riverpod provider that provides an instance of our Database class so that it can be used from our UI(by calling Database class methods)
final databaseProvider = Provider((ref) => Database());
//create dispose of provider to avoid memory leaks
