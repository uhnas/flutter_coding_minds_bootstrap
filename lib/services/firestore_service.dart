import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // get current user id
  String get uid => FirebaseAuth.instance.currentUser!.uid;

  // save a workout
  Future<void> saveWorkout(String muscleGroup, List<Map<String, String>> exercises) async {
    await _db.collection('users').doc(uid).collection('workouts').add({
      'muscleGroup': muscleGroup,
      'exercises': exercises,
      'date': FieldValue.serverTimestamp(),
    });
  }

  // get all workouts for current user
  Stream<QuerySnapshot> getWorkouts() {
    return _db
        .collection('users')
        .doc(uid)
        .collection('workouts')
        .orderBy('date', descending: true)
        .snapshots();
  }
}