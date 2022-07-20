import 'package:flutter/material.dart';

class ControlPad extends StatefulWidget {
  final Function pressForward;
  final Function pressBackward;
  final Function pressLeft;
  final Function pressRight;
  final Function depressForward;
  final Function depressBackward;
  final Function depressLeft;
  final Function depressRight;
  ControlPad(
      {Key? key,
      required this.pressForward,
      required this.pressBackward,
      required this.pressLeft,
      required this.pressRight,
      required this.depressForward,
      required this.depressBackward,
      required this.depressLeft,
      required this.depressRight})
      : super(key: key);

  @override
  State<ControlPad> createState() => _ControlPadState();
}

class _ControlPadState extends State<ControlPad> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 175,
      height: 115,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ControlPadButton(
            onPressed: widget.pressForward,
            onRelease: widget.depressForward,
            color: Colors.red,
            icon: Icons.north_outlined,
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ControlPadButton(
                  onPressed: widget.pressLeft,
                  onRelease: widget.depressLeft,
                  color: Colors.red,
                  icon: Icons.west_outlined,
                ),
                ControlPadButton(
                  onPressed: widget.pressBackward,
                  onRelease: widget.depressBackward,
                  color: Colors.red,
                  icon: Icons.south_outlined,
                ),
                ControlPadButton(
                    onPressed: widget.pressRight,
                    onRelease: widget.depressRight,
                    color: Colors.red,
                    icon: Icons.east_outlined),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ControlPadButton extends GestureDetector {
  final Function onPressed;
  final Function onRelease;
  final Color color;
  final IconData icon;
  ControlPadButton(
      {required this.onPressed,
      required this.onRelease,
      required this.color,
      required this.icon,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapCancel: () {
        onRelease();
      },
      onTapDown: (details) {
        onPressed();
      },
      onTapUp: (details) {
        onRelease();
      },
      child: Container(
        // width: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          // borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Icon(icon),
        ),
      ),
    );
  }
}

class ControlPadInputs {
  ControlPadInputs();

  // all possible buttons in this controller
  int forwardButton = 0;
  int backwardButton = 0;
  int leftButton = 0;
  int rightButton = 0;

  Widget widget() {
    return ControlPad(
      pressForward: () {
        forwardButton = 1;
      },
      pressBackward: () {
        backwardButton = 1;
      },
      pressLeft: () {
        leftButton = 1;
      },
      pressRight: () {
        rightButton = 1;
      },
      depressForward: () {
        forwardButton = 0;
      },
      depressBackward: () {
        backwardButton = 0;
      },
      depressLeft: () {
        leftButton = 0;
      },
      depressRight: () {
        rightButton = 0;
      },
    );
  }
}
