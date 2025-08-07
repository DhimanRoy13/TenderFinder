import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String? phoneNumber;
  final String? company;
  final String? role;
  final String? userId;
  final String? address;

  const EditProfileScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    this.phoneNumber,
    this.company,
    this.role,
    this.userId,
    this.address,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _profileImage;
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController companyController;
  late TextEditingController roleController;
  late TextEditingController userIdController;
  late TextEditingController addressController;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: const Text('Gallery'),
          ),
        ],
      ),
    );
    if (source == null) return;
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final savedImage = await _saveImage(File(pickedFile.path));
      setState(() {
        _profileImage = savedImage;
      });
    }
  }

  Future<File> _saveImage(File image) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.png';
    final savedImage = await image.copy('$path/$fileName');
    return savedImage;
  }

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userName);
    emailController = TextEditingController(text: widget.userEmail);
    phoneController = TextEditingController(text: widget.phoneNumber ?? '');
    companyController = TextEditingController(text: widget.company ?? '');
    roleController = TextEditingController(text: widget.role ?? '');
    userIdController = TextEditingController(text: widget.userId ?? '');
    addressController = TextEditingController(text: widget.address ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    companyController.dispose();
    roleController.dispose();
    userIdController.dispose();
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color(0xFF007074),
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.white,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(
                              Icons.person,
                              size: 48,
                              color: Color(0xFF007074),
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white,
                          child: const Icon(
                            Icons.edit,
                            color: Color(0xFF007074),
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField('Full Name', nameController),
              _buildTextField('Email Address', emailController),
              _buildTextField('Phone Number', phoneController),
              _buildTextField('Company', companyController),
              _buildTextField('Role', roleController),
              _buildTextField('User ID', userIdController, enabled: false),
              _buildTextField('Address', addressController),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'userName': nameController.text.trim(),
                      'userEmail': emailController.text.trim(),
                      'phoneNumber': phoneController.text.trim(),
                      'company': companyController.text.trim(),
                      'role': roleController.text.trim(),
                      'userId': userIdController.text.trim(),
                      'address': addressController.text.trim(),
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007074),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: enabled ? Colors.white : Colors.grey[100],
        ),
      ),
    );
  }
}
