import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GymTracker',
      debugShowCheckedModeBanner: false,
      home: const AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final AuthService _auth = AuthService();
  String? errorMessage;
  bool isLoading = false;

  void submit() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    String? error;

    if (isLogin) {
      error = await _auth.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    } else {
      error = await _auth.register(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    }

    setState(() => isLoading = false);

    if (error != null) {
      setState(() => errorMessage = error);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Register')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if (!isLogin) ...[
              const Text('Name'),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Your name'),
              ),
              const SizedBox(height: 16),
            ],

            const Text('Email'),
            const SizedBox(height: 6),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'you@example.com'),
            ),
            const SizedBox(height: 16),

            const Text('Password'),
            const SizedBox(height: 6),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '••••••••'),
            ),
            const SizedBox(height: 16),

            // Error message
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : submit,
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Text(isLogin ? 'Login' : 'Register'),
              ),
            ),
            const SizedBox(height: 12),

            Center(
              child: GestureDetector(
                onTap: () => setState(() => isLogin = !isLogin),
                child: Text(
                  isLogin ? "Don't have an account? Register" : "Already have an account? Login",
                  style: const TextStyle(color: Colors.blue),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}