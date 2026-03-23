import 'package:chat_app_flutter/core/localization/app_localizations.dart';
import 'package:chat_app_flutter/models/user_model.dart';
import 'package:chat_app_flutter/screens/auth/login_screen.dart';
import 'package:chat_app_flutter/screens/profile/profile_screen.dart';
import 'package:chat_app_flutter/services/auth_services.dart';
import 'package:chat_app_flutter/utils/constants.dart';
import 'package:chat_app_flutter/widgets/custom_text_field.dart';
import 'package:chat_app_flutter/widgets/user_title.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final AuthServices _authServices = AuthServices();
  final TextEditingController _searchController = TextEditingController();

  int _currentIndex = 0;
  String _searchQuery = '';
  UserModel? _currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadCurrentUser();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final userId = _authServices.currentUserId;
    if (userId != null) {
      if (state == AppLifecycleState.resumed) {
        _authServices.updateUserOnlineStatus(userId, true);
      } else if (state == AppLifecycleState.resumed) {
        _authServices.updateUserOnlineStatus(userId, false);
      }
    }
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authServices.getCurrentUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: AppConstants.primaryColor,
              title: Text(
                _currentIndex == 0 ? context.tr('users') : context.tr('chats'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              actions: [
                if (_currentIndex == 0)
                  IconButton(
                    onPressed: () {
                      _navigateToProfile(context);
                    },
                    icon: Icon(Icons.person, color: Colors.white),
                  ),
                IconButton(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  icon: Icon(Icons.logout, color: Colors.white),
                ),
              ],
            ),
            body: _currentIndex == 0
                ? _buildUsersTab()
                : ZIMKitConversationListView(),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              selectedItemColor: AppConstants.primaryColor,
              unselectedItemColor: AppConstants.textSecondaryColor,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.people),
                  label: context.tr('users'),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.chat),
                  label: context.tr('chats'),
                ),
              ],
            ),
          ),
          ZegoUIKitPrebuiltCallMiniOverlayPage(contextQuery: () => context),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(AppConstants.paddingMedium),
          color: AppConstants.primaryColor,
          child: SearchTextField(
            controller: _searchController,
            hintText: context.tr('search_users'),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
            onClear: () {
              setState(() {
                _searchQuery = '';
              });
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<List<UserModel>>(
            stream: _authServices.getAllUsers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    color: AppConstants.primaryColor,
                  ),
                );
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return EmptyUserList(
                  message: context.tr('no_users_found'),
                  icon: Icons.people_outline,
                );
              }

              List<UserModel> users = snapshot.data!;

              if (_searchQuery.isNotEmpty) {
                users = users.where((user) {
                  return user.name.toLowerCase().contains(_searchQuery) ||
                      user.email.toLowerCase().contains(_searchQuery);
                }).toList();
              }

              if (users.isEmpty) {
                return EmptyUserList(
                  message: context.tr('no_users_match_search'),
                  icon: Icons.search_off,
                );
              }

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return UserTitle(
                    user: user,
                    onTap: () => _openChatWithUser(user),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ZegoSendCallInvitationButton(
                          invitees: [
                            ZegoUIKitUser(id: user.uid, name: user.name),
                          ],
                          isVideoCall: false,
                          iconSize: Size(40, 40),
                          buttonSize: Size(50, 50),
                          onPressed: onSendCallInvitationFinished,
                        ),
                        SizedBox(width: 8),
                        ZegoSendCallInvitationButton(
                          invitees: [
                            ZegoUIKitUser(id: user.uid, name: user.name),
                          ],
                          isVideoCall: true,
                          iconSize: Size(40, 40),
                          buttonSize: Size(50, 50),
                          onPressed: onSendCallInvitationFinished,
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _openChatWithUser(UserModel user) async {
    await ZIMKit()
        .connectUser(id: _currentUser!.uid, name: _currentUser!.name)
        .then((v) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ZIMKitMessageListPage(
                conversationID: user.uid,
                conversationType: ZIMConversationType.peer,
                appBarActions: [
                  ZegoSendCallInvitationButton(
                    invitees: [ZegoUIKitUser(id: user.uid, name: user.name)],
                    isVideoCall: false,
                    iconSize: Size(40, 40),
                    buttonSize: Size(50, 50),
                    onPressed: onSendCallInvitationFinished,
                  ),
                  SizedBox(width: 8),
                  ZegoSendCallInvitationButton(
                    invitees: [ZegoUIKitUser(id: user.uid, name: user.name)],
                    isVideoCall: true,
                    iconSize: Size(40, 40),
                    buttonSize: Size(50, 50),
                    onPressed: onSendCallInvitationFinished,
                  ),
                ],
              ),
            ),
          );
        });
  }

  void onSendCallInvitationFinished(
    String code,
    String message,
    List<String> errorInvites,
  ) {
    if (errorInvites.isNotEmpty) {
      var userIDs = '';
      for (var index = 0; index < errorInvites.length; index++) {
        if (index >= 5) {
          userIDs += '...';
          break;
        }

        final userID = errorInvites.elementAt(index);
        userIDs += '$userID';
      }
      if (userIDs.isNotEmpty) {
        userIDs = userIDs.substring(0, userIDs.length - 1);
      }
      var message = context.tr('users_offline_or_missing');

      if (code.isNotEmpty) {
        message += ', code: $code, message: $message';
      }
      Fluttertoast.showToast(msg: message);
    } else if (code.isNotEmpty) {
      print(message);
    }
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfileScreen()),
    );
  }
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.tr('logout')),
        content: Text(context.tr('logout_confirm')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(context.tr('cancel')),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _logout(context);
            },
            child: Text(context.tr('logout')),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      showDialog(
        context: context,
        builder: (context) => Center(
          child: CircularProgressIndicator(color: AppConstants.primaryColor),
        ),
        barrierDismissible: false,
      );

      await ZIMKit().disconnectUser();
      await FirebaseAuth.instance.signOut();
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(
        msg: '${context.tr('error_logging_out')}: $e',
        backgroundColor: AppConstants.accentColor,
      );
    }
  }
}
