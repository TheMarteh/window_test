import 'package:flutter/material.dart';

class ControlPad extends StatefulWidget {
  final Function pressMoveForward;
  final Function pressMoveBackward;
  final Function pressStrafeLeft;
  final Function pressStrafeRight;
  final Function pressMoveUpward;
  final Function pressMoveDownward;
  final Function pressTurnLeft;
  final Function pressTurnRight;
  final Function pressTurnUpward;
  final Function pressTurnDownward;

  final Function depressMoveForward;
  final Function depressMoveBackward;
  final Function depressStrafeLeft;
  final Function depressStrafeRight;
  final Function depressMoveUpward;
  final Function depressMoveDownward;
  final Function depressTurnLeft;
  final Function depressTurnRight;
  final Function depressTurnUpward;
  final Function depressTurnDownward;

  ControlPad({
    Key? key,
    required this.pressMoveForward,
    required this.pressMoveBackward,
    required this.pressStrafeLeft,
    required this.pressStrafeRight,
    required this.pressMoveUpward,
    required this.pressMoveDownward,
    required this.pressTurnLeft,
    required this.pressTurnRight,
    required this.pressTurnUpward,
    required this.pressTurnDownward,
    required this.depressMoveForward,
    required this.depressMoveBackward,
    required this.depressStrafeLeft,
    required this.depressStrafeRight,
    required this.depressMoveUpward,
    required this.depressMoveDownward,
    required this.depressTurnLeft,
    required this.depressTurnRight,
    required this.depressTurnUpward,
    required this.depressTurnDownward,
  }) : super(key: key);

  @override
  State<ControlPad> createState() => _ControlPadState();
}

class _ControlPadState extends State<ControlPad> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 282,
      height: 115,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ControlPadButton(
                onPressed: widget.pressMoveUpward,
                onRelease: widget.depressMoveUpward,
                color: Colors.green,
                icon: Icons.keyboard_double_arrow_up_outlined,
              ),
              const SizedBox(
                width: 60,
              ),
              ControlPadButton(
                onPressed: widget.pressTurnUpward,
                onRelease: widget.depressTurnUpward,
                color: Colors.red,
                icon: Icons.north_outlined,
              ),
              const SizedBox(
                width: 60,
              ),
              ControlPadButton(
                onPressed: widget.pressMoveForward,
                onRelease: widget.depressMoveForward,
                color: Colors.blue,
                icon: Icons.fast_forward_outlined,
              ),
            ],
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ControlPadButton(
                  onPressed: widget.pressMoveDownward,
                  onRelease: widget.depressMoveDownward,
                  color: Colors.green,
                  icon: Icons.keyboard_double_arrow_down_outlined,
                ),
                ControlPadButton(
                  onPressed: widget.pressTurnLeft,
                  onRelease: widget.depressTurnLeft,
                  color: Colors.red,
                  icon: Icons.turn_slight_left_outlined,
                ),
                ControlPadButton(
                  onPressed: widget.pressTurnDownward,
                  onRelease: widget.depressTurnDownward,
                  color: Colors.red,
                  icon: Icons.south_outlined,
                ),
                ControlPadButton(
                    onPressed: widget.pressTurnRight,
                    onRelease: widget.depressTurnRight,
                    color: Colors.red,
                    icon: Icons.turn_slight_right_outlined),
                ControlPadButton(
                    onPressed: widget.pressMoveBackward,
                    onRelease: widget.depressMoveBackward,
                    color: Colors.blue,
                    icon: Icons.fast_rewind_outlined),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// I think this could be stateless..
class ControlPadButton extends StatefulWidget {
  final Function onPressed;
  final Function onRelease;
  Color color;
  final IconData icon;
  ControlPadButton(
      {required this.onPressed,
      required this.onRelease,
      required this.color,
      required this.icon,
      Key? key})
      : super(key: key);
  @override
  State<ControlPadButton> createState() => _ControlPadButtonState();
}

class _ControlPadButtonState extends State<ControlPadButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapCancel: () {
        widget.onRelease();
      },
      onTapDown: (details) {
        widget.onPressed();
      },
      onTapUp: (details) {
        widget.onRelease();
      },
      child: Container(
        // width: 20,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
          // borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Icon(widget.icon),
        ),
      ),
    );
  }
}

class ControlPadInputs {
  ControlPadInputs();

  // all possible buttons in this controller
  int turnUpButton = 0; // pitch over Y axis
  int turnDownButton = 0; // pitch over Y axis
  int turnLeftButton = 0; // pitch over X axis
  int turnRightButton = 0; // pitch over X axis
  int strafeLeftButton = 0; // move over X axis
  int strafeRightButton = 0; // move over X axis
  int moveForwardButton = 0; // move over Z axis
  int moveBackwardButton = 0; // move over Z axis
  int moveDownwardButton = 0; // move over Y axis
  int moveUpwardButton = 0; // move over Y axis

  Widget widget() {
    return ControlPad(
      pressMoveForward: () {
        moveForwardButton = 1;
      },
      pressMoveBackward: () {
        moveBackwardButton = 1;
      },
      pressStrafeLeft: () {
        strafeLeftButton = 1;
      },
      pressStrafeRight: () {
        strafeRightButton = 1;
      },
      depressMoveForward: () {
        moveForwardButton = 0;
      },
      depressMoveBackward: () {
        moveBackwardButton = 0;
      },
      depressStrafeLeft: () {
        strafeLeftButton = 0;
      },
      depressStrafeRight: () {
        strafeRightButton = 0;
      },
      pressMoveDownward: () {
        moveDownwardButton = 1;
      },
      depressMoveDownward: () {
        moveDownwardButton = 0;
      },
      pressMoveUpward: () {
        moveUpwardButton = 1;
      },
      depressMoveUpward: () {
        moveUpwardButton = 0;
      },
      pressTurnDownward: () {
        turnDownButton = 1;
      },
      depressTurnDownward: () {
        turnDownButton = 0;
      },
      pressTurnLeft: () {
        turnLeftButton = 1;
      },
      depressTurnLeft: () {
        turnLeftButton = 0;
      },
      pressTurnRight: () {
        turnRightButton = 1;
      },
      depressTurnRight: () {
        turnRightButton = 0;
      },
      pressTurnUpward: () {
        turnUpButton = 1;
      },
      depressTurnUpward: () {
        turnUpButton = 0;
      },
    );
  }
}
