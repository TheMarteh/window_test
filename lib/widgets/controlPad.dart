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
    return Container(
      width: 175,
      height: 115,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTapCancel: () {
              widget.depressForward();
            },
            onTapDown: (details) {
              widget.pressForward();
            },
            onTapUp: (details) {
              widget.depressForward();
            },
            child: Container(
              // width: 20,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
                // borderRadius: BorderRadius.circular(20),
              ),
              child: const Padding(
                padding: EdgeInsets.all(15.0),
                child: Icon(Icons.north_outlined),
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTapCancel: () {
                    widget.depressLeft();
                  },
                  onTapDown: (details) {
                    widget.pressLeft();
                  },
                  onTapUp: (details) {
                    widget.depressLeft();
                  },
                  child: Container(
                    // width: 20,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      // borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Icon(Icons.west_outlined),
                    ),
                  ),
                ),
                GestureDetector(
                  onTapCancel: () {
                    widget.depressBackward();
                  },
                  onTapDown: (details) {
                    widget.pressBackward();
                  },
                  onTapUp: (details) {
                    widget.depressBackward();
                  },
                  child: Container(
                    // width: 20,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      // borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Icon(Icons.south_outlined),
                    ),
                  ),
                ),
                GestureDetector(
                  onTapCancel: () {
                    widget.depressRight();
                  },
                  onTapDown: (details) {
                    widget.pressRight();
                  },
                  onTapUp: (details) {
                    widget.depressRight();
                  },
                  child: Container(
                    // width: 20,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      // borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Icon(Icons.east_outlined),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
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
        // print("depressedL");
        leftButton = 0;
      },
      depressRight: () {
        // print("depressedR");

        rightButton = 0;
      },
    );
  }
}
