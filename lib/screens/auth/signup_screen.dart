import 'package:chat_app_flutter/core/localization/app_localizations.dart';
import 'package:chat_app_flutter/screens/auth/login_screen.dart';
import 'package:chat_app_flutter/screens/home/home_screen.dart';
import 'package:chat_app_flutter/services/auth_services.dart';
import 'package:chat_app_flutter/utils/constants.dart';
import 'package:chat_app_flutter/widgets/custom_buttons.dart';
import 'package:chat_app_flutter/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmpasswordController = TextEditingController();
  final AuthServices _authServices = AuthServices();

  bool _isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmpasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userModel = await _authServices.signUp(
        name: _nameController.text,
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (userModel != null) {
        await ZIMKit().connectUser(id: userModel.uid, name: userModel.name);
        await ZegoUIKitPrebuiltCallInvitationService().init(
          appID: AppConstants.zegoAppID,
          appSign: AppConstants.zegoAppSign,
          userID: userModel.uid,
          userName: userModel.name,
          plugins: [ZegoUIKitSignalingPlugin()],
        );

        Fluttertoast.showToast(
          msg: AppConstants.signupSuccessMessage,
          backgroundColor: AppConstants.secondaryColor,
        );

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        }
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: e.toString(),
        backgroundColor: AppConstants.accentColor,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppConstants.primaryGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(AppConstants.paddingLarge),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.chat_bubble_outline,
                        size: 50,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      context.tr('create_account'),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      context.tr('sign_up_to_get_started'),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    SizedBox(height: 40),
                    Container(
                      padding: EdgeInsets.all(AppConstants.paddingLarge),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusLarge,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _nameController,
                            hintText: context.tr('name'),
                            prefixIcon: Icons.person_outline,
                            textCapitalization: TextCapitalization.words,
                            validator: (value) =>
                                TextFieldValidators.name(context, value),
                          ),
                          SizedBox(height: 16),
                          CustomTextField(
                            controller: _emailController,
                            hintText: context.tr('email'),
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) =>
                                TextFieldValidators.email(context, value),
                          ),
                          SizedBox(height: 16),
                          CustomTextField(
                            controller: _passwordController,
                            hintText: context.tr('password'),
                            prefixIcon: Icons.lock_outlined,
                            isPassword: true,
                            validator: (value) =>
                                TextFieldValidators.password(context, value),
                          ),
                          SizedBox(height: 16),
                          CustomTextField(
                            controller: _confirmpasswordController,
                            hintText: context.tr('confirm_password'),
                            prefixIcon: Icons.lock_outlined,
                            isPassword: true,
                            validator: (value) =>
                                TextFieldValidators.confirmPassword(
                                  context,
                                  value,
                                  _passwordController.text,
                                ),
                          ),
                          SizedBox(height: 24),
                          CustomButton(
                            text: context.tr('sign_up'),
                            onPressed: _signUp,
                            isLoading: _isLoading,
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                context.tr('already_have_account'),
                                style: TextStyle(
                                  color: AppConstants.textSecondaryColor,
                                ),
                              ),
                              CustomTextButton(
                                text: context.tr('log_in'),
                                onPressed: _navigateToLogin,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(
                        horizontal: AppConstants.paddingMedium,
                      ),
                      child: Text(
                        context.tr('terms_and_privacy'),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
