import 'package:flutter/material.dart';

class ConnectivityBanner extends StatelessWidget {
  final bool isOnline;

  const ConnectivityBanner({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: isOnline ? Colors.green : Colors.grey,
      padding: const EdgeInsets.all(8),
      child: Text(
        isOnline ? '🟢 Online' : '🔴 Offline',
        style: const TextStyle(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }
}
