import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app_flutter/models/user_model.dart';
import 'package:chat_app_flutter/utils/constants.dart';
import 'package:flutter/material.dart';

class UserTitle extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showOnlineStatus;
  final bool showLastSeen;
  const UserTitle({
    super.key,
    required this.user,
    required this.onTap,
    this.trailing,
    this.showOnlineStatus = true,
    this.showLastSeen = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
        vertical: AppConstants.paddingSmall / 2,
      ),
      elevation: 0,
      color: AppConstants.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(
          AppConstants.borderRadiusMedium,
        ),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
        leading: _buildAvatar(),
        title: Text(
          user.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: _buildSubtitle(),
        trailing:
            trailing ??
            Icon(Icons.chevron_right, color: AppConstants.textSecondaryColor),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
          backgroundImage: user.photoUrl != null
              ? CachedNetworkImageProvider(user.photoUrl!)
              : null,
          child: user.photoUrl == null
              ? Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                )
              : null,
        ),
        if (showOnlineStatus)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: user.isOnline ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget? _buildSubtitle() {
    if (user.bio != null && user.bio!.isNotEmpty) {
      return Text(
        user.bio!,
        style: TextStyle(fontSize: 14, color: AppConstants.textSecondaryColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    if (showLastSeen && !user.isOnline && user.lastSeen != null) {
      return Text(
        'Last seen: ${AppConstants().formatTimestamp(user.lastSeen!)}',
        style: TextStyle(fontSize: 12, color: AppConstants.textSecondaryColor),
      );
    }

    if (user.isOnline) {
      return Text(
        'Online',
        style: TextStyle(
          color: Colors.green,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return Text(
      user.email,
      style: TextStyle(fontSize: 12, color: AppConstants.textSecondaryColor),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class EmptyUserList extends StatelessWidget {
  final String message;
  final IconData icon;
  const EmptyUserList({
    super.key,
    this.message = 'No user found',
    this.icon = Icons.people_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppConstants.textSecondaryColor.withOpacity(0.5),
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: AppConstants.textSecondaryColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
