import 'package:flutter/material.dart';

class CircularIndicator extends StatefulWidget {
  const CircularIndicator({
    Key? key,
  }) : super(key: key);

  @override
  State<CircularIndicator> createState() => _CircularIndicatorState();
}

class _CircularIndicatorState extends State<CircularIndicator> {
  late ThemeData themeData;
  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            child: const CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.blue,
            ),
            width: 15,
            height: 15,
          ),
        ]);
  }
}
