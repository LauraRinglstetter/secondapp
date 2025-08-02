import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityBanner extends StatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  State<ConnectivityBanner> createState() => _ConnectivityBannerState();
}

class _ConnectivityBannerState extends State<ConnectivityBanner> {
  late Stream<ConnectivityResult> _connectivityStream;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _connectivityStream = Connectivity().onConnectivityChanged;
    Connectivity().checkConnectivity().then(_updateStatus);
  }

  void _updateStatus(ConnectivityResult result) {
    final online = result != ConnectivityResult.none;
    if (_isOnline != online) {
      setState(() {
        _isOnline = online;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
      stream: _connectivityStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _updateStatus(snapshot.data!);
        }

        return Container(
          width: double.infinity,
          color: _isOnline ? Colors.green : Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Center(
            child: Text(
              _isOnline ? '🟢 Online' : '🔴 Offline',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}
