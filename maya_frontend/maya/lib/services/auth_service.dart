import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        await storeToken(googleAuth.idToken);
        // Send user credentials to the backend
        print(userCredential);
        await sendUserCredentialsToBackend(userCredential.user, googleAuth.idToken, googleAuth.accessToken);

        return userCredential.user;
      }
      return null;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> sendUserCredentialsToBackend(User? user, String? idToken,String? accessToken) async {
    if (user != null && idToken != null) {
      // Replace with your backend endpoint
      final String backendUrl = 'https://hqonrzuh2j.execute-api.ap-south-1.amazonaws.com/default/login';
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoURL': user.photoURL,
          'idToken': idToken,
          'accessToken':accessToken,
        }),
      );
      if (response.statusCode == 200) {
        print('User authenticated successfully with backend.');
      } else {
        print('Failed to authenticate user with backend.');
      }
    }
  }
  Future<void> sendUserCredentialsToBackendEP(String email ,String password,String uid ) async {
    if (email != "" && password != "") {
      // Replace with your backend endpoint
      const String backendUrl = 'https://hqonrzuh2j.execute-api.ap-south-1.amazonaws.com/default/login';
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'uid':uid,
        }),
      );
      if (response.statusCode == 200) {
        print('User authenticated successfully with backend.');
      } else {
        print('Failed to authenticate user with backend.');
      }
    }
  }
    Future<void> storeToken(String? idToken) async {
    if (idToken != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('idToken', idToken);
    }
  }

  Future<String?> getTokenFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('idToken');
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();

    // Clear the token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('idToken');
  }
   Future<User?> signInWithEmailAndPassword(String email, String password) async {
     
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(userCredential);
      sendUserCredentialsToBackendEP(email,password,userCredential.user!.uid);
      return userCredential.user;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future<User?> signUpWithEmailAndPassword(BuildContext context,String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print(userCredential);
      sendUserCredentialsToBackendEP(email,password,userCredential.user!.uid);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The password provided is too weak.'),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('The account already exists for that email.'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-up failed. Please try again later.'),
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign-up failed. Please try again later.'),
        ),
      );
    }
    return null;
  }
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print(e);
    }
  }

  Future<String?> getToken() async {
    User? user = _auth.currentUser;
    return user != null ? await user.getIdToken() : null;
  }
  Future<String?> getCurrentUserUid() async {
    User? user = _auth.currentUser;
    return user?.uid;
  }

 Future<User?> getCurrentUser() async {
  User? user = _auth.currentUser;
  return user;
}
}
