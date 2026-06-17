import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry? padding;
  final Size deviceSize;
  final bool? avoidBottomInsets;

  const AppScaffold({
    super.key,
    required this.body,
    required this.deviceSize,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.padding,
    this.avoidBottomInsets
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: appBar,
        resizeToAvoidBottomInset: avoidBottomInsets ?? false,
        body: SafeArea(
          child: Padding(
            padding: padding ?? EdgeInsets.symmetric(
                vertical: deviceSize.height * 0.02,
                horizontal: deviceSize.width * 0.03),
            child: body,
          ),
        ),
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}