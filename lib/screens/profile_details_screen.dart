import 'package:flutter/material.dart';
import 'edit_profile_screen.dart';

class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    this.phoneNumber,
    this.company,
    this.role,
    this.userId,
    this.address,
  });

  final String userName;
  final String userEmail;
  final String? phoneNumber;
  final String? company;
  final String? role;
  final String? userId;
  final String? address;

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  bool _showPasswordFields = false;
  bool _showPersonalDetails = false;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _canSubmitPassword = false;

  late String userName;
  late String userEmail;
  String? phoneNumber;
  String? company;
  String? role;
  String? userId;
  String? address;

  @override
  void initState() {
    super.initState();
    userName = widget.userName;
    userEmail = widget.userEmail;
    phoneNumber = widget.phoneNumber;
    company = widget.company;
    role = widget.role;
    userId = widget.userId;
    address = widget.address;
    _newPasswordController.addListener(_validatePasswordFields);
    _confirmPasswordController.addListener(_validatePasswordFields);
  }

  void _validatePasswordFields() {
    if (!mounted) return;
    final newPass = _newPasswordController.text.trim();
    final confirmPass = _confirmPasswordController.text.trim();
    final valid =
        newPass.isNotEmpty && confirmPass.isNotEmpty && newPass == confirmPass;
    if (_canSubmitPassword != valid && mounted) {
      setState(() {
        _canSubmitPassword = valid;
      });
    }
  }

  @override
  void dispose() {
    _newPasswordController.removeListener(_validatePasswordFields);
    _confirmPasswordController.removeListener(_validatePasswordFields);
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _infoRow(String label, String? value) {
    final displayValue = (value == null || value.trim().isEmpty)
        ? 'Not provided'
        : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  displayValue,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use state variable for expansion
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Profile Details'),
        backgroundColor: const Color(0xFF1C989C),
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Personal Information Card with expand/collapse and edit icon
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      leading: const Icon(
                        Icons.person,
                        color: Color(0xFF1C989C),
                      ),
                      title: const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF222828),
                        ),
                      ),
                      subtitle: const Text(
                        'See or Edit your information',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_showPersonalDetails)
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Color(0xFF1C989C),
                              ),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(
                                      userName: userName,
                                      userEmail: userEmail,
                                      phoneNumber: phoneNumber,
                                      company: company,
                                      role: role,
                                      userId: userId,
                                      address: address,
                                    ),
                                  ),
                                );
                                if (result is Map<String, String>) {
                                  setState(() {
                                    userName = result['userName'] ?? userName;
                                    userEmail =
                                        result['userEmail'] ?? userEmail;
                                    phoneNumber =
                                        result['phoneNumber'] ?? phoneNumber;
                                    company = result['company'] ?? company;
                                    role = result['role'] ?? role;
                                    userId = result['userId'] ?? userId;
                                    address = result['address'] ?? address;
                                    _showPersonalDetails = true;
                                  });
                                }
                              },
                            ),
                          const SizedBox(width: 4),
                          Icon(
                            _showPersonalDetails
                                ? Icons.expand_less
                                : Icons.arrow_forward_ios,
                            color: Colors.black,
                            size: 16,
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          _showPersonalDetails = !_showPersonalDetails;
                        });
                      },
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _infoRow('Full Name', userName),
                            _infoRow('Email Address', userEmail),
                            _infoRow('Phone Number', phoneNumber),
                            _infoRow('Company', company),
                            _infoRow('Role', role),
                          ],
                        ),
                      ),
                      crossFadeState: _showPersonalDetails
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 400),
                      firstCurve: Curves.easeInOut,
                      secondCurve: Curves.easeInOut,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock, color: Color(0xFF1C989C)),
                      title: const Text('Change Password'),
                      subtitle: const Text('Update your account password'),
                      trailing: Icon(
                        _showPasswordFields
                            ? Icons.expand_less
                            : Icons.arrow_forward_ios,
                        size: 16,
                      ),
                      onTap: () {
                        setState(() {
                          _showPasswordFields = !_showPasswordFields;
                        });
                      },
                    ),
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        child: Column(
                          children: [
                            TextField(
                              controller: _newPasswordController,
                              obscureText: !_showNewPassword,
                              enableInteractiveSelection: false,
                              decoration: InputDecoration(
                                labelText: 'New Password',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showNewPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showNewPassword = !_showNewPassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: !_showConfirmPassword,
                              enableInteractiveSelection: false,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _showConfirmPassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _showConfirmPassword =
                                          !_showConfirmPassword;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1C989C),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: _canSubmitPassword
                                    ? () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Color(0xFF1C989C),
                                                  size: 60,
                                                ),
                                                const SizedBox(height: 18),
                                                const Text(
                                                  'Password changed successfully!',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (mounted) {
                                          setState(() {
                                            _showPasswordFields = false;
                                            _newPasswordController.clear();
                                            _confirmPasswordController.clear();
                                            _canSubmitPassword = false;
                                          });
                                        }
                                      }
                                    : null,
                                child: const Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      crossFadeState: _showPasswordFields
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 400),
                      firstCurve: Curves.easeInOut,
                      secondCurve: Curves.easeInOut,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
