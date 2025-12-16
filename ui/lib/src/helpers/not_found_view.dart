import 'package:flutter/material.dart';

class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Not Found'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(50.0),
          child: Column(
            children: [
              Text('404', style: TextStyle(fontSize: 50)),
              Text('Not Found'),
            ],
          ),
        ),
      ),
    );
  }
}
