import 'package:flutter/material.dart';

class CostCalculatorScreen extends StatelessWidget {
  const CostCalculatorScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cost Calculator'),
      ),
      body: const Center(
        child: Text('Cost Calculator Screen'),
      ),
    );
  }
}
