import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      const Icon(Icons.cloud, size: 200),
      Padding(
        padding: const EdgeInsets.only(top: 55.0, left: 50.0),
        child: Icon(Icons.calculate,
            size: 100, color: Theme.of(context).canvasColor),
      ),
    ]);
  }
}
