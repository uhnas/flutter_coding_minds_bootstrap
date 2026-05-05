import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../main.dart';
import '../services/firestore_service.dart';
import 'log_workout_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final FirestoreService firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym Tracker'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: Text(
                user?.email ?? 'GymTracker',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Start New Workout'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LogWorkoutScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Workout History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HistoryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign Out'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AuthScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hey, ${user?.email ?? 'there'}!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('Ready to train?', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            const Text('Recent Workouts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: firestore.getWorkouts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text('No workouts yet.', style: TextStyle(color: Colors.grey));
                }

                // only show last 3
                final workouts = snapshot.data!.docs.take(3).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final w = workouts[index].data() as Map<String, dynamic>;
                    final exerciseList = (w['exercises'] as List);
                    final date = w['date'] != null
                        ? (w['date'] as Timestamp).toDate()
                        : DateTime.now();
                    final dateStr = '${date.month}/${date.day}/${date.year}';

                    return ListTile(
                      title: Text(w['muscleGroup'] ?? ''),
                      subtitle: Text('${exerciseList.length} exercises · $dateStr'),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}