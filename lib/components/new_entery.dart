import 'package:flutter/material.dart';
import 'package:password_manager/data/local/db_helper.dart';

class NewEntry extends StatefulWidget {
  final Map<String, dynamic>? entry;

  const NewEntry({super.key, this.entry});

  @override
  State<NewEntry> createState() => _NewEntryState();
}

class _NewEntryState extends State<NewEntry> {
  bool _obscureText = true;
  final FocusNode _focusNode = FocusNode();
  DbHelper? dbRef;

  // Add TextEditingControllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    // Dispose all controllers
    _focusNode.dispose();
    _titleController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    dbRef = DbHelper.getInstance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'New Account',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // Dismiss the keyboard
        },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF1F8E9), Color(0xFFE8F5E9)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: ListView(
              children: [
                // App Title
                _buildInputField(
                  label: 'Title',
                  hint: 'Enter title',
                  icon: Icons.title,
                  controller: _titleController,
                ),
                const SizedBox(height: 16),
                // App Username
                _buildInputField(
                  label: 'Email/Username',
                  hint: 'Enter email/username',
                  icon: Icons.email,
                  controller: _usernameController,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildPasswordField(),
                const SizedBox(height: 16),
                _buildInputField(
                  label: 'Category',
                  hint: 'Enter category',
                  icon: Icons.category,
                  controller: _categoryController,
                ),
                const SizedBox(height: 16),
                _buildInputField(
                  label: 'Note',
                  hint: 'Enter note',
                  icon: Icons.note,
                  controller: _noteController,
                  maxLines: 4,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    var Title = _titleController.text;
                    var Username = _usernameController.text;
                    var Password = _passwordController.text;
                    var Category = _categoryController.text;
                    var Note = _noteController.text;
                    //var Date = DateTime.now().toString();

                    // Check if any field is empty
                    var isEmpty = Title.isEmpty ||
                        Username.isEmpty ||
                        Password.isEmpty ||
                        Category.isEmpty ||
                        Note.isEmpty;

                    if (isEmpty) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    } else if (Password.length < 8) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Password must be at least 8 characters'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    } else {
                      bool check = await dbRef!.addData(
                        title: _titleController.text,
                        username: _usernameController.text,
                        password: _passwordController.text,
                        category: _categoryController.text,
                        note: _noteController.text,
                        secure: 0,
                        date: DateTime.now().toString(),
                      );
                      if (check) {
                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Entry saved successfully!'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        // Navigate back to home page
                        Navigator.pop(context,
                            true); // Pass true to indicate refresh needed
                      } else {
                        // Show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to save entry'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }

                      // Clear the text fields
                      _titleController.clear();
                      _usernameController.clear();
                      _passwordController.clear();
                      _categoryController.clear();
                      _noteController.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'SAVE ENTRY',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D375B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller, // Add controller
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 150, 216, 152),
                width: 2,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4CAF50),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D375B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController, // Add controller
          obscureText: _obscureText,
          decoration: InputDecoration(
            hintText: 'Enter password',
            hintStyle: const TextStyle(color: Color(0xFFB0BEC5)),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(Icons.lock, color: Color(0xFF4CAF50)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: const Color(0xFFB0BEC5),
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 150, 216, 152),
                width: 2,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF4CAF50),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
