import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens [url] in an external browser / store. Returns `false` if launch failed.
Future<bool> openPlayStore(String url) async {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !(uri.isScheme('https') || uri.isScheme('http'))) {
    return false;
  }
  try {
    if (!await canLaunchUrl(uri)) return false;
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

/// Non-dismissible when [isForceUpdate] is true.
Future<void> showUpdateDialog({
  required BuildContext context,
  required String title,
  required String description,
  required bool isForceUpdate,
  required String updateUrl,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: !isForceUpdate,
    builder: (ctx) {
      return PopScope(
        canPop: !isForceUpdate,
        child: AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(description),
          ),
          actions: [
            if (!isForceUpdate)
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Later'),
              ),
            ElevatedButton(
              onPressed: () async {
                await openPlayStore(updateUrl);
                if (!ctx.mounted) return;
                if (!isForceUpdate) {
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      );
    },
  );
}
