import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:password_manager/Pages/home.dart';
import 'package:password_manager/Pages/search.dart';
import 'package:password_manager/Pages/settings.dart';
import 'package:password_manager/data/local/db_helper.dart';

import 'package:intl/intl.dart';

class SuperSecureDashboard extends StatefulWidget {
  const SuperSecureDashboard({super.key});

  @override
  State<SuperSecureDashboard> createState() => _SuperSecureDashboardState();
}

class _SuperSecureDashboardState extends State<SuperSecureDashboard> {
  List<Map<String, dynamic>> allData = [];

  DbHelper? dbRef;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    dbRef = DbHelper.getInstance;
    getData();
  }


  void getData() async {
    allData = await dbRef!.getSecureData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'Super Secure Accounts',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 1.1,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
              ),
            ),
            child: allData.isNotEmpty
                ? ListView.builder(
                    itemCount: allData.length,
                    itemBuilder: (_, index) {
                      final entry = allData[index];
                      return GestureDetector(
                        onLongPress: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20)),
                            ),
                            builder: (context) => Container(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.edit,
                                        color: Color(0xFF1565C0)),
                                    title: const Text('Edit'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _handleEdit(entry);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.note_outlined,
                                        color: Color(0xFF1565C0)),
                                    title: const Text('View Note'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      // Show note in a dialog
                                      if (entry[DbHelper.users_note_data]
                                              ?.isNotEmpty ??
                                          false) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(entry[
                                                DbHelper.users_title_data]),
                                            content: Text(entry[
                                                    DbHelper.users_note_data] ??
                                                'No note available'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Close'),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('No note available'),
                                            backgroundColor: Colors.grey,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.lock_outline,
                                        color: Color(0xFF1565C0)),
                                    title: const Text('Un-Secure'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      _handleSecure(entry);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.delete,
                                        color: Colors.red),
                                    title: const Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                    onTap: () {
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Entry'),
                                          content: const Text(
                                              'Are you sure you want to delete this entry?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                                _handleDelete(
                                                    entry[DbHelper.S_no]);
                                              },
                                              child: const Text('Delete',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        entry[DbHelper.users_title_data],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2D375B),
                                        ),
                                      ),
                                      _CategoryChip(
                                        category:
                                            entry[DbHelper.users_category_data],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _InfoRow(
                                    icon: Icons.person_outline,
                                    text: entry[DbHelper.users_username_data],
                                  ),
                                  const SizedBox(height: 8),
                                  _PasswordRow(
                                    password:
                                        entry[DbHelper.users_password_data],
                                  ),
                                  const SizedBox(height: 8),
                                  _InfoRow(
                                    icon: Icons.calendar_today,
                                    text: _formatDate(
                                        entry[DbHelper.users_date_data]),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    })
                : const Center(
                    child: Text(
                      'No Data Found',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D375B),
                      ),
                    ),
                  )),
        bottomNavigationBar: _buildBottomNavBar());
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        // Handle navigation based on index
        switch (index) {
          case 0:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PasswordDashboard(),
              ),
            );
            break;
          case 1:
            // Navigate to Analysis
            break;
          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SearchDashboard(),
              ),
            );
            // Navigate to Search
            break;
          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Settings(),
              ),
            );
            // Navigate to Settings
            break;
        }
      },
      backgroundColor: Colors.white,
      selectedItemColor: index_color(_currentIndex),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.security_rounded),
          label: 'Super Secure',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }

  Color index_color(index1) {
    if (index1 == 1) {
      return Color(0xFF1565C0);
    } else {
      return Color(0xFF2E7D32);
    }
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('MMM dd, yyyy - HH:mm').format(date);
  }

  void _handleEdit(Map<String, dynamic> entry) {
    _showEditBottomSheet(entry);
  }

  void _handleDelete(int id) async {
    await dbRef!.deleteData(id);
    getData();
  }

  void _showEditBottomSheet(Map<String, dynamic> entry) {
    final titleController =
        TextEditingController(text: entry[DbHelper.users_title_data]);
    final usernameController =
        TextEditingController(text: entry[DbHelper.users_username_data]);
    final passwordController =
        TextEditingController(text: entry[DbHelper.users_password_data]);
    final categoryController =
        TextEditingController(text: entry[DbHelper.users_category_data]);
    final noteController =
        TextEditingController(text: entry[DbHelper.users_note_data]);
    bool obscurePassword = true;

    // Create a flag to track if we've already disposed the controllers
    bool controllersDisposed = false;

    void safeDisposeControllers() {
      if (!controllersDisposed) {
        titleController.dispose();
        usernameController.dispose();
        passwordController.dispose();
        categoryController.dispose();
        noteController.dispose();
        controllersDisposed = true;
      }
    }

    Future<void> handleSave() async {
      try {
        final success = await dbRef!.updateData(
          id: entry[DbHelper.S_no],
          title: titleController.text,
          username: usernameController.text,
          password: passwordController.text,
          category: categoryController.text,
          note: noteController.text,
          secure: entry[DbHelper.users_secure_data],
          date: DateTime.now().toString(),
        );
        // Close bottom sheet first
        Navigator.pop(context);

        if (success) {
          // Update the list and show success message
          getData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Entry updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('Update error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to update entry'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edit Entry',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D375B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: noteController,
                    maxLines: 3, // Allow multiple lines for notes
                    decoration: const InputDecoration(
                      labelText: 'Note',
                      prefixIcon: Icon(Icons.note_outlined),
                      alignLabelWithHint: true, // Aligns label with first line
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                          ),
                          child: const Text('Save'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ).whenComplete(safeDisposeControllers);
    }
  }

  void _handleSecure(Map<String, dynamic> entry) async {
    final success = await dbRef!.updateSecureData(
      id: entry[DbHelper.S_no],
      secure: entry[DbHelper.users_secure_data] == 1 ? 0 : 1,
    );
    if (success) {
      getData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account un-secured successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 201, 229, 252),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category,
        style: const TextStyle(
          color: Color(0xFF1565C0),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF1565C0)),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF455A64),
          ),
        ),
      ],
    );
  }
}

class _PasswordRow extends StatefulWidget {
  final String password;

  const _PasswordRow({required this.password});

  @override
  __PasswordRowState createState() => __PasswordRowState();
}

class __PasswordRowState extends State<_PasswordRow> {
  bool _obscureText = true;

  LocalAuthentication auth = LocalAuthentication();

  Future<void> _authenticateAndToggleVisibility() async {
    if (_obscureText) {
      // Access the static variable from _PasswordDashboardState
      if (PasswordDashboardState.isAuthenticating) return;

      setState(() {
        // Modify the static variable
        PasswordDashboardState.isAuthenticating = true;
      });

      try {
        bool result = await auth.authenticate(
          localizedReason: "Authenticate to view password",
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: true,
          ),
        );

        if (result && mounted) {
          setState(() {
            _obscureText = !_obscureText;
          });
        }
      } catch (e) {
        debugPrint('Authentication error: $e');
      } finally {
        if (mounted) {
          setState(() {
            PasswordDashboardState.isAuthenticating = false;
          });
        }
      }
    } else {
      setState(() {
        _obscureText = !_obscureText;
      });
    }
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.lock_outline, size: 20, color: Color(0xFF1565C0)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _obscureText ? '•' * widget.password.length : widget.password,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF455A64),
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF1565C0),
          ),
          onPressed: () {
            _authenticateAndToggleVisibility();
          },
        ),
      ],
    );
  }
}
