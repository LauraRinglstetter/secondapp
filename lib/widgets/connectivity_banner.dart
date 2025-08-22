import 'package:flutter/material.dart';

class ConnectivityBanner extends StatefulWidget {
  final bool isOnline;
  final Future<bool> Function()? internetCheck;
  final Duration checkTimeout;

  const ConnectivityBanner({
    super.key,
    required this.isOnline,
    this.internetCheck,
    this.checkTimeout = const Duration(seconds: 5),
  });

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  bool? _hasInternet; 

  @override
  void initState() {
    super.initState();
    _maybeCheckInternet();
  }

  @override
  void didUpdateWidget(covariant ConnectivityBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isOnline) {
      _setHasInternet(false);
    } else if (oldWidget.isOnline != widget.isOnline ||
        oldWidget.internetCheck != widget.internetCheck) {
      _maybeCheckInternet();
    }
  }

  void _setHasInternet(bool? value) {
    if (!mounted) return;
    setState(() => _hasInternet = value);
  }

  Future<void> _maybeCheckInternet() async {
    if (!widget.isOnline) {
      _setHasInternet(false);
      return;
    }
    final checker = widget.internetCheck;
    if (checker == null) {
      _setHasInternet(true);
      return;
    }
    _setHasInternet(null);
    try {
      final ok = await checker().timeout(widget.checkTimeout, onTimeout: () => false);
      _setHasInternet(ok);
    } catch (_) {
      _setHasInternet(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOnline) {
      return _banner('🔴 Offline', Colors.grey);
    }
    if (_hasInternet == null) {
      return _banner('🟡 Verbindung wird geprüft…', Colors.amber);
    }
    return _hasInternet == true
        ? _banner('🟢 Online', Colors.green)
        : _banner('🔴 Offline', Colors.grey);
  }

  Widget _banner(String text, Color color) {
    return Container(
      width: double.infinity,
      color: color,
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
