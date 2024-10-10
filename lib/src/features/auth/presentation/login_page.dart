import 'dart:developer';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tredo/src/core/extension/extensions.dart';
import 'package:tredo/src/core/resources/resources.dart';
import 'package:tredo/src/features/app/bloc/app_bloc.dart';
import 'package:tredo/src/features/app/widgets/custom/common_button.dart';
import 'package:tredo/src/features/app/widgets/custom/common_input.dart';
import 'package:tredo/src/features/auth/bloc/login_cubit.dart';
import 'package:tredo/src/features/auth/widgets/validators.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoginButtonDisabled = true;

  void loginButtonActive(bool value) {
    setState(() {
      isLoginButtonDisabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        state.whenOrNull(
          initialState: () {},
          loadingState: () {},
          loadedState: (user) {
            log('Success - $user');
            context.appBloc.add(const AppEvent.logining());
          },
          errorState: (message) {
            log('error - $message');
          },
        );
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: false,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                SizedBox(
                  height: context.screenSize.height,
                  width: context.screenSize.width,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: context.screenSize.height * 0.20,
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/vectors.svg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  height: context.screenSize.height,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 35),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 200,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonInput(
                            'Email',
                            controller: _emailController,
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              if (_emailController.text.isNotEmpty &&
                                  _passwordController.text.length >= 6) {
                                loginButtonActive(false);
                              } else {
                                loginButtonActive(true);
                              }
                            },
                          ),
                          CommonInput(
                            'Password',
                            margin: const EdgeInsets.only(top: 30, bottom: 50),
                            type: InputType.PASSWORD,
                            controller: _passwordController,
                            textInputAction: TextInputAction.next,
                            validator: (String? value) =>
                                passwordValidator(context, value),
                            onChanged: (value) {
                              if (_passwordController.text.length >= 6 &&
                                  _emailController.text.isNotEmpty) {
                                loginButtonActive(false);
                              } else {
                                loginButtonActive(true);
                              }
                            },
                          ),
                          CommonButton(
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              BlocProvider.of<LoginCubit>(context).login(
                                login: _emailController.text,
                                password: _passwordController.text,
                              );
                            },
                            margin: const EdgeInsets.only(bottom: 12),
                            disabled: isLoginButtonDisabled,
                            child: const Text('Login'),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: AppTextStyles.os12w400.copyWith(
                                  color: AppColors.kTextSecondary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  context.appBloc
                                      .add(const AppEvent.registration());
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppColors.kMainGreen,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'Sign in',
                                    style: AppTextStyles.os12w600Green,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
