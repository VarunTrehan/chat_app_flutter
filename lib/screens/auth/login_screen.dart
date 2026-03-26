import 'package:chat_app_flutter/core/localization/app_localizations.dart';
import 'package:chat_app_flutter/screens/auth/signup_screen.dart';
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthServices _authServices = AuthServices();

  bool _isLoading = false;

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userModel = await _authServices.signIn(
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
          msg: context.trSafe('auth_toast_login_success'),
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
        msg: (e is AuthError)
            ? context.trSafe(
                'auth_error_${e.code}',
                args: <String, Object>{'error': e.details ?? e.toString()},
              )
            : context.trSafe(
                'auth_error_unexpected_error',
                args: <String, Object>{'error': e.toString()},
              ),
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

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen()),
    );
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          context.trSafe('login_dialog_reset_password_title'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.trSafe('login_dialog_reset_password_message'),
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: emailController,
              hintText: context.trSafe('login_input_email_hint'),
              prefixIcon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.trSafe('common_button_cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              if (emailController.text.trim().isEmpty) {
                Fluttertoast.showToast(
                  msg: context.trSafe(
                    'login_dialog_reset_password_please_enter_email',
                  ),
                  backgroundColor: AppConstants.accentColor,
                );
                return;
              }
              try {
                await _authServices.resetPassword(emailController.text.trim());
                Navigator.pop(context);
                Fluttertoast.showToast(
                  msg: context.trSafe('login_dialog_reset_password_sent'),
                  backgroundColor: AppConstants.secondaryColor,
                );
              } catch (e) {
                Fluttertoast.showToast(
                  msg: (e is AuthError)
                      ? context.trSafe(
                          'auth_error_${e.code}',
                          args: <String, Object>{
                            'error': e.details ?? e.toString(),
                          },
                        )
                      : context.trSafe(
                          'auth_error_unexpected_error',
                          args: <String, Object>{'error': e.toString()},
                        ),
                  backgroundColor: AppConstants.accentColor,
                );
              }
            },
            child: Text(context.trSafe('common_button_send')),
          ),
        ],
      ),
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
                      context.trSafe('login_title_welcome_back'),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 2,
                    ),
                    SizedBox(height: 8),
                    Text(
                      context.trSafe('login_subtitle_sign_in_to_continue'),
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                      softWrap: true,
                      maxLines: 3,
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
                            controller: _emailController,
                            hintText: context.trSafe('login_input_email_hint'),
                            prefixIcon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) =>
                                TextFieldValidators.email(context, value),
                          ),
                          SizedBox(height: 16),
                          CustomTextField(
                            controller: _passwordController,
                            hintText: context.trSafe('login_input_password_hint'),
                            prefixIcon: Icons.lock_outlined,
                            isPassword: true,
                            validator: (value) =>
                                TextFieldValidators.password(context, value),
                          ),
                          SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: CustomTextButton(
                              text: context.trSafe(
                                'login_link_forgot_password',
                              ),
                              onPressed: _showForgotPasswordDialog,
                            ),
                          ),
                          SizedBox(height: 24),
                          CustomButton(
                            text: context.trSafe('login_button_submit'),
                            onPressed: _login,
                            isLoading: _isLoading,
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  context.trSafe('login_link_no_account_prompt'),
                                  style: TextStyle(
                                    color: AppConstants.textSecondaryColor,
                                  ),
                                  softWrap: true,
                                  maxLines: 2,
                                ),
                              ),
                              CustomTextButton(
                                text: context.trSafe('signup_button_submit'),
                                onPressed: _navigateToSignUp,
                              ),
                            ],
                          ),
                        ],
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
