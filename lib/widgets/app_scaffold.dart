import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.showBackButton = true,
    this.actions,
    this.floatingActionButton,
  });

  final Widget body;
  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title != null
          ? AppBar(
              title: Text(title!),
              automaticallyImplyLeading: showBackButton,
              actions: actions,
            )
          : null,
      body: SafeArea(child: body),
      floatingActionButton: floatingActionButton,
    );
  }
}
