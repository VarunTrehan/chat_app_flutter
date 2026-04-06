import 'package:flutter/material.dart';

/// Shows a one-time warning when running on a suspicious emulator environment.
class SecurityBootstrapShell extends StatefulWidget {
  const SecurityBootstrapShell({
    super.key,
    required this.child,
    required this.showEmulatorWarning,
  });

  final Widget child;
  final bool showEmulatorWarning;

  @override
  State<SecurityBootstrapShell> createState() => _SecurityBootstrapShellState();
}

class _SecurityBootstrapShellState extends State<SecurityBootstrapShell> {
  bool _dialogScheduled = false;

  @override
  void initState() {
    super.initState();
    if (widget.showEmulatorWarning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _dialogScheduled) {
          return;
        }
        _dialogScheduled = true;
        _showWarning(context);
      });
    }
  }

  void _showWarning(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Security notice'),
        content: const Text(
          'This device appears to be an emulator or virtual environment. '
          'Voice and video calling are disabled to reduce abuse risk.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
