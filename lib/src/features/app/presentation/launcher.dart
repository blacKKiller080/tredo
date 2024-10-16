// ignore: unused_import

import 'dart:async';
import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tredo/src/core/extension/extensions.dart';
import 'package:tredo/src/core/resources/resources.dart';
import 'package:tredo/src/features/app/bloc/app_bloc.dart';
import 'package:tredo/src/features/app/widgets/custom/custom_loading_widget.dart';
import 'package:tredo/src/features/auth/presentation/login_page.dart';
import 'package:tredo/src/features/auth/presentation/registration_page.dart';
import 'package:tredo/src/features/client/main_page/main_page.dart';

// ignore: unused_element
const _tag = 'Launcher';

@RoutePage(name: 'LauncherRoute')
class Launcher extends StatefulWidget {
  const Launcher({super.key});

  @override
  State<Launcher> createState() => _LauncherState();
}

class _LauncherState extends State<Launcher> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    BlocProvider.of<AppBLoC>(context)
        .add(AppEvent.checkAuth(version: context.packageInfo.version));
    super.initState();
  }

  @override
  void dispose() {
    // _listener.dispose();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    log('MyApp state = $state');
    if (state == AppLifecycleState.inactive) {
    } else if (state == AppLifecycleState.paused) {
    } else if (state == AppLifecycleState.detached) {
      log('User terminated app');
    } else if (state == AppLifecycleState.resumed) {
      // final appBloc = context.appBloc;
      // final bool canCheckBiometric = await auth.canCheckBiometrics;
      // if (canCheckBio) {
      // appBloc.add(AppEvent.isActiveBiometrics(canCheckBiometric));
      // }

      // canCheckBio = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AppBLoC, AppState>(
          listener: (context, state) {
            state.whenOrNull(
              notAuthorizedState: () async {
                await FirebaseAuth.instance.signOut();
              },
              inAppState: () {},
              errorState: (message) {},
            );
          },
        ),
      ],
      child: BlocBuilder<AppBLoC, AppState>(
        builder: (context, state) {
          return state.maybeWhen(
            loadingState: () => const _Scaffold(
              child: CustomLoadingWidget(
                child: Text(''),
              ),
            ),
            errorState: (String message) => const _Scaffold(
              child: CustomLoadingWidget(
                isError: true,
                child: Text(''),
              ),
            ),
            registrationState: () {
              return const CustomLoadingWidget(child: RegistrationPage());
            },
            notAuthorizedState: () {
              return const CustomLoadingWidget(child: LoginPage());
            },
            orElse: () {
              return const CustomLoadingWidget(child: MainPage());
            },
          );
        },
      ),
    );
  }
}

class _Scaffold extends StatelessWidget {
  final Widget child;
  const _Scaffold({
    required this.child,
    // super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kGlobalBackground,
      body: SafeArea(child: child),
    );
  }
}
