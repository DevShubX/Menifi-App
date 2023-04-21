import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:menifi/pages/Homescreen/HomeScreen.dart';
import 'package:menifi/pages/Signinscreen/SignInScreen.dart';

Future<User?> CreateUserAccount(
    String name, String email, String password, File? image) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  FirebaseStorage _storage = FirebaseStorage.instance;

  if (name.isNotEmpty &&
      email.isNotEmpty &&
      password.isNotEmpty &&
      image != null) {
    try {
      User? user = (await _auth.createUserWithEmailAndPassword(
              email: email, password: password))
          .user;
      popupToast('Creating your account');
      Reference storageref = _storage.ref();
      Reference ref = storageref.child(email);
      UploadTask uploadTask = ref.putFile(image);
      popupToast('Profile Pic uploaded');
      String downloadUrl =
          await uploadTask.then((snapshot) => snapshot.ref.getDownloadURL());
      if (user != null) {
        await user.updateDisplayName(name);
        await user.updatePhotoURL(downloadUrl);
        popupToast('Account creation done, \n redirecting to home');
        return user;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        popupToast(
            'The password provided is too weak. \nShould be more than 8 characters');
      } else if (e.code == 'email-already-in-use') {
        popupToast('The account already exists for that email');
      }
    }
  }
}

Future<User?> LogInUser(String email, String password) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  try {
    User? user = (await _auth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;

    if (user != null) {
      return user;
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      popupToast("No user found for that email");
    } else if (e.code == 'wrong-password') {
      popupToast("Wrong password provided for that user");
    }
  }
}

Future LogOutUser(BuildContext context) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn();
  try {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => SignInScreen()),
    );

    if (await googleSignIn.isSignedIn()) {
      googleSignIn.signOut();
    }
    await _auth.signOut();
  } catch (e) {
    //Nothing
  }
}

Future<User?> SignInWithGoogle(BuildContext context) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  final GoogleSignIn googleSignIn = GoogleSignIn();

  final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
  try {
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential authCredential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      User? user = (await _auth.signInWithCredential(authCredential)).user;

      if (user != null) {
        return user;
      }
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      popupToast("No user found for that email");
    } else if (e.code == 'wrong-password') {
      popupToast("Wrong password provided for that user");
    } else {
      popupToast("Something went wrong.");
    }
  }
}

Future<bool?> popupToast(String message) {
  return Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}
