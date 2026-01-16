
import 'package:flutter/material.dart';

class OngoingWorkScreen extends StatelessWidget {
  const OngoingWorkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ongoing Work')),
      body: const Center(child: Text('No active tasks')),
    );
  }
}
