import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_service.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Workout History')),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.getWorkouts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No workouts yet.', style: TextStyle(color: Colors.grey)),
            );
          }

          final workouts = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: workouts.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final w = workouts[index].data() as Map<String, dynamic>;
              final exerciseList = (w['exercises'] as List);
              final date = w['date'] != null
                  ? (w['date'] as Timestamp).toDate()
                  : DateTime.now();
              final dateStr = '${date.month}/${date.day}/${date.year}';

              return ExpansionTile(
                title: Text(w['muscleGroup'] ?? ''),
                subtitle: Text('${exerciseList.length} exercises · $dateStr'),
                children: exerciseList.map((e) {
                  final exercise = e as Map<String, dynamic>;
                  return ListTile(
                    dense: true,
                    title: Text(exercise['name'] ?? ''),
                    subtitle: Text('${exercise['sets']} sets · ${exercise['reps']} reps · ${exercise['weight']}lbs'),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}