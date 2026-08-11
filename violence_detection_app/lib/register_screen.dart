import 'package:flutter/material.dart';
import 'services/register_api.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final mobileController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RegisterApi registerApi = RegisterApi();
  bool hidePassword = true;
  bool hideConfirmPassword = true;

  bool isValidEmail(String email) {
    return RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email);
  }

  String selectedCountryCode = "+91";

  final List<Map<String, String>> countries = [
    {
      "name": "India",
      "code": "+91",
      "flag": "🇮🇳"
    },
    {
      "name": "USA",
      "code": "+1",
      "flag": "🇺🇸"
    },
    {
      "name": "UK",
      "code": "+44",
      "flag": "🇬🇧"
    },
    {
      "name": "Australia",
      "code": "+61",
      "flag": "🇦🇺"
    },
  ];

  bool isValidMobile(String mobile) {

    switch (selectedCountryCode) {

      case "+91":
        return RegExp(
          r'^[6-9][0-9]{9}$',
        ).hasMatch(mobile);

      case "+1":
        return RegExp(
          r'^[0-9]{10}$',
        ).hasMatch(mobile);

      case "+44":
        return RegExp(
          r'^[0-9]{10,11}$',
        ).hasMatch(mobile);

      case "+61":
        return RegExp(
          r'^[0-9]{9}$',
        ).hasMatch(mobile);

      default:
        return false;
    }
  }

  bool isValidName(String name) {
    return RegExp(r'^[A-Z]').hasMatch(name);
  }

  bool isStrongPassword(String password) {
    return RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[@#$%^&+=!]).{8,}$',
    ).hasMatch(password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            const Icon(
              Icons.security,
              size: 80,
              color: Colors.red,
            ),

            const SizedBox(height: 10),

            const Text(
              "Create Account",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              "Violence Detection System",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Full Name",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            DropdownButtonFormField<String>(
              value: selectedCountryCode,
              decoration: const InputDecoration(
                labelText: "Country",
                border: OutlineInputBorder(),
              ),
              items: countries.map((country) {
                return DropdownMenuItem(
                  value: country["code"],
                  child: Text(
                    "${country["flag"]} ${country["name"]} (${country["code"]})",
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCountryCode = value!;
                });
              },
            ),

            TextField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText:
                "Mobile Number ($selectedCountryCode)",
                prefixIcon: const Icon(Icons.phone),
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
                prefixIcon: Icon(Icons.account_circle),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: passwordController,
              obscureText: hidePassword,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    hidePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      hidePassword =
                      !hidePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: confirmPasswordController,
              obscureText: hideConfirmPassword,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    hideConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      hideConfirmPassword =
                      !hideConfirmPassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(
                  double.infinity,
                  50,
                ),
              ),
              onPressed: () async {

                if (nameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    mobileController.text.isEmpty ||
                    usernameController.text.isEmpty ||
                    passwordController.text.isEmpty ||
                    confirmPasswordController.text.isEmpty) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Please fill all fields",
                      ),
                    ),
                  );
                  return;
                }

                if (!isValidEmail(emailController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Enter valid email address",
                      ),
                    ),
                  );
                  return;
                }

                if (!isValidMobile(mobileController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Mobile number must be 10 digits",
                      ),
                    ),
                  );
                  return;
                }

                if (!isValidName(nameController.text)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Name must start with a capital letter",
                      ),
                    ),
                  );
                  return;
                }

                if (!isStrongPassword(
                    passwordController.text)) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Password must contain uppercase, lowercase, number and special character",
                      ),
                    ),
                  );
                  return;
                }

                if (passwordController.text !=
                    confirmPasswordController.text) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Passwords do not match",
                      ),
                    ),
                  );
                  return;
                }

                String result =
                await registerApi.registerUser(
                  nameController.text,
                  emailController.text,
                  mobileController.text,
                  usernameController.text,
                  passwordController.text,
                );

                if (result == "REGISTER_SUCCESS") {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Registration Successful",
                      ),
                    ),
                  );

                  Navigator.pop(context);

                } else if (result == "EMAIL_EXISTS") {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Email already exists",
                      ),
                    ),
                  );

                } else if (result == "USERNAME_EXISTS") {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Username already exists",
                      ),
                    ),
                  );

                } else if (result == "MOBILE_EXISTS") {

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Mobile number already exists",
                      ),
                    ),
                  );

                }
                else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Registration Failed",
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                "Register",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}