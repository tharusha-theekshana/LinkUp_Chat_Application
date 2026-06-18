import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:link_up/core/widgets/scaffold/app_scaffold.dart';
import 'package:link_up/features/auth/core/controllers/auth_controller.dart';

class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> {
  late Size _deviceSize;

  final _controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    _deviceSize = MediaQuery.of(context).size;

    return AppScaffold(
      body: Column(children: [
        Text("Landing"),
        Text("${_controller.user!.displayName}")
      ]),
      deviceSize: _deviceSize,
    );
  }
}
