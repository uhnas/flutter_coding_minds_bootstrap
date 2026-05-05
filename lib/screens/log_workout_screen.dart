import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class LogWorkoutScreen extends StatefulWidget {
  const LogWorkoutScreen({super.key});

  @override
  State<LogWorkoutScreen> createState() => _LogWorkoutScreenState();
}

class _LogWorkoutScreenState extends State<LogWorkoutScreen> {
  String? selectedMuscleGroup;
  final List<Map<String, String>> exercises = [];
  final FirestoreService _firestore = FirestoreService();

  final muscleGroups = ['Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core'];

  final nameController = TextEditingController();
  final setsController = TextEditingController();
  final repsController = TextEditingController();
  final weightController = TextEditingController();

  void addExercise() {
    if (nameController.text.isEmpty) return;
    setState(() {
      exercises.add({
        'name': nameController.text,
        'sets': setsController.text,
        'reps': repsController.text,
        'weight': weightController.text,
      });
      nameController.clear();
      setsController.clear();
      repsController.clear();
      weightController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log Workout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Muscle Group'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedMuscleGroup,
              hint: const Text('Select muscle group'),
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: muscleGroups
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (val) => setState(() => selectedMuscleGroup = val),
            ),
            const SizedBox(height: 24),
            const Text('Add Exercise'),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Exercise name (e.g. Bench Press)',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: setsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Sets'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Reps'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'lbs'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: addExercise,
                child: const Text('Add Exercise'),
              ),
            ),
            const SizedBox(height: 24),
            if (exercises.isNotEmpty) ...[
              const Text('Exercises', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final e = exercises[index];
                  return ListTile(
                    title: Text(e['name'] ?? ''),
                    subtitle: Text('${e['sets']} sets · ${e['reps']} reps · ${e['weight']}lbs'),
                  );
                },
              ),
            ] else
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text('No exercises added yet', style: TextStyle(color: Colors.grey)),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                    onPressed: () async {
                      if (selectedMuscleGroup == null || exercises.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please select a muscle group and add at least one exercise')),
                        );
                        return;
                      }
                      try {
                        await _firestore.saveWorkout(selectedMuscleGroup!, exercises);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Workout saved!')),
                        );
                        Navigator.pop(context);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    },
                child: const Text('Finish Workout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}