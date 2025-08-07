// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../shared/subscription_provider.dart';
import 'signup_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  static final TextEditingController emailController = TextEditingController();
  static final TextEditingController passwordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static void clearFields() {
    emailController.clear();
    passwordController.clear();
  }

  void _login(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      // Initialize subscription provider with user ID
      final subscriptionProvider = Provider.of<SubscriptionProvider>(
        context,
        listen: false,
      );
      subscriptionProvider.initializeSubscription(emailController.text);

      Navigator.pushReplacementNamed(
        context,
        '/home',
        arguments: {
          'userEmail': emailController.text,
          'userName': null,
          'showWelcome': true,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Allow UI to resize when keyboard opens
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Center vertically
                      children: [
                        Image.network(
                          'https://i.postimg.cc/KvpdmxD1/Logo.png',
                          height: 160,
                          width: 160,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: "Email",
                                  ),
                                  validator: (val) =>
                                      val!.isEmpty ? "Enter your email" : null,
                                ),
                                SizedBox(height: 20),
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: true,
                                  decoration: InputDecoration(
                                    labelText: "Password",
                                  ),
                                  validator: (val) => val!.isEmpty
                                      ? "Enter your password"
                                      : null,
                                ),
                                SizedBox(height: 40),
                                ElevatedButton(
                                  onPressed: () => _login(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF1C989C),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14,
                                      horizontal: 40,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 20),
                                TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => SignupScreen(),
                                      ),
                                    );
                                  },
                                  child: Text("Don't have an account? Sign Up"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
