import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_flutter/models/user_model.dart';
import 'package:chat_app_flutter/services/auth_services.dart';
import 'package:chat_app_flutter/utils/constants.dart';
import 'package:chat_app_flutter/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chat_app_flutter/widgets/custom_buttons.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthServices _authServices = AuthServices();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isEditMode = false;

  File? _selectedImage;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authServices.getCurrentUserData();
      if (user != null && mounted) {
        setState(() {
          _currentUser = user;
          _nameController.text = user.name;
          _bioController.text = user.bio ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(
          msg: 'Error loading profile $e',
          backgroundColor: AppConstants.accentColor,
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error loading image: $e',
        backgroundColor: AppConstants.accentColor,
      );
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null) return null;

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${_authServices.currentUserId}.jpg');

      await storageRef.putFile(_selectedImage!);
      final downloadUrl = await storageRef.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error loading image: $e',
        backgroundColor: AppConstants.accentColor,
      );
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      String? photoUrl;

      if (_selectedImage != null) {
        photoUrl = await _uploadImage();
      }
      await _authServices.updateUserProfile(
        name: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        photoUrl: photoUrl,
      );

      Fluttertoast.showToast(
        msg: 'Profile updated successfully',
        backgroundColor: AppConstants.secondaryColor,
      );

      await _loadUserData();

      setState(() {
        _isEditMode = false;
        _selectedImage = null;
      });
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: 'Error updating profile: $e',
          backgroundColor: AppConstants.accentColor,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
      _selectedImage = null;
      if (_currentUser != null) {
        _nameController.text = _currentUser!.name;
        _bioController.text = _currentUser!.bio ?? '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Profile"),
          backgroundColor: AppConstants.primaryColor,
        ),
        body: Center(
          child: CircularProgressIndicator(color: AppConstants.primaryColor),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppConstants.primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          if (!_isEditMode)
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditMode = true;
                });
              },
              icon: Icon(Icons.edit),
            ),
        ],
      ),
      body: _currentUser == null
          ? Center(child: Text('User Not Found'))
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppConstants.primaryGradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    padding: EdgeInsets.only(
                      top: AppConstants.paddingLarge,
                      bottom: AppConstants.paddingExtraLarge,
                    ),
                    child: Column(
                      children: [
                        _buildProfilePicture(),
                        if (_isEditMode) ...[
                          SizedBox(height: 12),
                          CusomSmallButtom(
                            text: 'Change Photo',
                            onPressed: _pickImage,
                            icon: Icons.camera_alt,
                            backgroundColor: Colors.white.withOpacity(0.3),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.all(AppConstants.paddingLarge),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            controller: _nameController,
                            labelText: 'Name',
                            hintText: "Enter Your Name",
                            prefixIcon: Icons.person,
                            readOnly: !_isEditMode,
                            validator: TextFieldValidators.name,
                          ),
                          SizedBox(height: 20),
                          CustomTextField(
                            controller: _bioController,
                            labelText: 'Bio',
                            hintText: "Tell use about yourself",
                            prefixIcon: Icons.info_outline,
                            readOnly: !_isEditMode,
                            maxlines: 3,
                            maxLength: 150,
                          ),
                          SizedBox(height: 20),
                          CustomTextField(
                            controller: TextEditingController(
                              text: _currentUser!.email,
                            ),
                            labelText: 'Email',
                            hintText: "Email",
                            prefixIcon: Icons.email,
                            readOnly: true,
                            enabled: false,
                          ),
                          SizedBox(height: 20),
                          _buildInfoCard(),
                          SizedBox(height: 24),
                          if (_isEditMode) ...[
                            CustomButton(
                              text: 'Save Changes',
                              onPressed: _updateProfile,
                              isLoading: _isLoading,
                            ),
                            SizedBox(height: 12),
                            CustomButton(
                              text: "Cancel",
                              onPressed: _cancelEdit,
                              isOutlined: true,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfilePicture() {
    Widget imageWidget;

    if (_selectedImage != null) {
      imageWidget = Image.file(_selectedImage!, fit: BoxFit.cover);
    } else if (_currentUser!.photoUrl != null) {
      imageWidget = CachedNetworkImage(
        imageUrl: _currentUser!.photoUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            CircularProgressIndicator(color: Colors.white),
        errorWidget: (context, url, error) => _buildInitialAvatar(),
      );
    } else {
      imageWidget = _buildInitialAvatar();
    }

    return Container(
      height: 120,
      width: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: ClipOval(child: imageWidget),
    );
  }

  Widget _buildInitialAvatar() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          _currentUser!.name.isNotEmpty
              ? _currentUser!.name[0].toLowerCase()
              : '?',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Account Information",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            Icons.calendar_today,
            'Joined',
            _formatDate(_currentUser!.createdAt),
          ),
          Divider(height: 24),
          _buildInfoRow(
            Icons.verified_user,
            'User ID',
            _currentUser!.uid.substring(0, 12) + '...',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppConstants.textSecondaryColor),
        SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            color: AppConstants.textSecondaryColor,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppConstants.textPrimaryColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
