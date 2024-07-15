import 'dart:ui';

import 'package:flutter/material.dart';

class FrostedContainer extends StatefulWidget {
  @override
  _FrostedContainerState createState() => _FrostedContainerState();
}

class _FrostedContainerState extends State<FrostedContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<Alignment>(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Background image
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  'assets/backgrounds/dollars.jpg'), // Change this to your background image
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Frosted glass container with animated gradient
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Container(
                    width: 300.0,
                    height: 200.0,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent.withOpacity(0.4),
                          Colors.purpleAccent.withOpacity(0.4),
                          Colors.blueAccent.withOpacity(0.4),
                        ],
                        stops: [0.0, 0.5, 1.0],
                        begin: _animation.value,
                        end:
                            Alignment(-_animation.value.x, -_animation.value.y),
                      ),
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Animated Frosted Glass',
                        style: TextStyle(
                          fontSize: 24.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
