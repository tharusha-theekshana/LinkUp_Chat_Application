import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final EdgeInsetsGeometry? padding;
  final Size deviceSize;
  final bool avoidBottomInsets;
  final bool extendBody;

  const AppScaffold({
    super.key,
    required this.body,
    required this.deviceSize,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.padding,
    this.avoidBottomInsets = false,
    this.extendBody = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: appBar,
        extendBody: extendBody,
        resizeToAvoidBottomInset: avoidBottomInsets,
        body: SafeArea(
          child: Padding(
            padding: padding ??
                EdgeInsets.only(
                  left: deviceSize.width * 0.03,
                  right: deviceSize.width * 0.03,
                  bottom: deviceSize.height * 0.02
                ),
            child: body,
          ),
        ),
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}