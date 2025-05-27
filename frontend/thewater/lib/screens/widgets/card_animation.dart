//카드 빙글빙글 날아오는 애니메이션

import 'package:flutter/material.dart';

class FlyingCardAnimationWidget extends StatefulWidget {
  final VoidCallback onComplete;

  const FlyingCardAnimationWidget({required this.onComplete, super.key});

  @override
  State<FlyingCardAnimationWidget> createState() => _FlyingCardAnimationWidgetState();
}

class _FlyingCardAnimationWidgetState extends State<FlyingCardAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _position;
  late Animation<double> _rotation;
  late Animation<double> _scale;

  bool _showConfirmButton=false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _position = Tween<Offset>(
      begin: const Offset(0.0, -3.5),
      end: Offset.zero,
      ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    ));


    _rotation = Tween<double>(
      begin: 0.0,
      end: 6 * 3.141592, // 3바퀴
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));


    _scale = Tween<double>(
      begin: 0.1,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
    ));

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState((){
          _showConfirmButton=true;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCard() {
    return Column(
       mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 220,
          height: 320,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 12)],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Image.asset(
              "assets/image/빙글카드예시.png",
              width: 200,
              height: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              "예시입니다",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          ),
        ),
        const SizedBox(height: 24),
        if (_showConfirmButton)
          ElevatedButton(
            onPressed: widget.onComplete,
            child: const Text("도감에 저장하기"),//
          ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SlideTransition(
            position: _position,
            child: Transform.rotate(
              angle: _rotation.value, 
              child: ScaleTransition(
                scale: _scale,
                child: _buildCard(),
              ),
            ),
          );
        },
      ),
    );
  }
}