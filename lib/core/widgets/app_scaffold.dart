import 'package:flutter/material.dart';
import '../theme/app_gradient.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? leading; 

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.leading, 
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: leading,
      ),

      extendBodyBehindAppBar: true,

      body: Container(
        decoration: const BoxDecoration(gradient: AppGradient.background),

        child: Center(
          child: Padding(padding: const EdgeInsets.all(24), child: child),
        ),
      ),
    );
  }
}
