import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:tredo/src/features/app/presentation/launcher.dart';
import 'package:tredo/src/features/auth/presentation/registration_page.dart';
import 'package:tredo/src/features/client/fourth_page/presentation/chat_page.dart';
import 'package:tredo/src/features/client/main_page/main_page.dart';
import 'package:tredo/src/features/client/second_page/second_page.dart';
import 'package:tredo/src/features/auth/presentation/login_page.dart';

part 'app_router.gr.dart';

// @MaterialAutoRouter(
//   replaceInRouteName: 'Page,Route',
//   routes: [
//     AutoRoute<void>(
//       page: Launcher,
//       initial: true,P
//       name: 'LauncherRoute',
//       children: [
//         CustomRoute<void>(
//           page: MainPage,
//           // transitionsBuilder: TransitionsBuilders.slideTop,
//           // SlideTransition(
//           //   position: Tween<Offset>(
//           //     begin: Offset(0.0, -1.0),
//           //     end: Offset.zero,
//           //   ).animate(animation),
//           //   child: child,
//           // ),
//         ),
//         AutoRoute<void>(page: PolicesPage),
//         AutoRoute<void>(page: InsurancePage),
//         CustomRoute<void>(
//           page: EmptyRouterPage,
//           name: 'BaseProfileRoute',
//           // transitionsBuilder: TransitionsBuilders.slideTop,
//           children: [
//             AutoRoute<void>(page: ProfilePage, initial: true),
//             AutoRoute<void>(page: EditprofilePage),
//             AutoRoute<void>(page: CreditCardPage),
//             AutoRoute<void>(page: EditAddresPage),
//           ],
//         ),
//         // AutoRoute<void>(
//         //   page: ProfilePage,
//         //   initial: true,
//         //   children: [
//         //     AutoRoute<void>(page: EditprofilePage),
//         //   ],
//         // ),
//       ],
//     ),

//     // auth pages
//     AutoRoute<void>(page: AuthPage),
//     AutoRoute<void>(page: LoginPage),
//     AutoRoute<void>(page: PincodePage),
//     AutoRoute<void>(page: CreatePinCodePage),
//     AutoRoute<void>(page: SetBiometricsPage),
//     AutoRoute<void>(page: RegistrationPage),
//     AutoRoute<void>(page: PhoneInputPage),
//     AutoRoute<void>(page: CreatePasswordPage),
//     AutoRoute<void>(page: ForgotPassordPage),
//     AutoRoute<void>(page: EgovBusinessPage),
//     AutoRoute<void>(page: AituPassportPage),

//     /// profile pages
//     AutoRoute<void>(page: ChangePinCodePage),
//     AutoRoute<void>(page: ConfirmPinCodePage),
//     AutoRoute<void>(page: PasswordChangePage),
//     AutoRoute<void>(page: AddNewCardPage),

//     /// main pages
//     AutoRoute<void>(page: NotificationPage),
//     AutoRoute<void>(page: DetailNotificationPage),
//   ],
// )

@AutoRouterConfig()
class AppRouter extends _$AppRouter {
  @override
  RouteType get defaultRouteType => const RouteType.cupertino();
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: LauncherRoute.page,
          path: '/',
          initial: true,
          children: [
            AutoRoute(page: MainRoute.page),
            AutoRoute(page: SecondRoute.page),
            AutoRoute(page: LoginRoute.page),
            AutoRoute(page: RegistrationRoute.page),

            // AutoRoute<void>(
            //   page: ProfilePage,
            //   initial: true,
            //   children: [
            //     AutoRoute<void>(page: EditprofilePage),
            //   ],
            // ),
          ],
        ),
        AutoRoute(page: ChatRoute.page),
      ];
}

@RoutePage(name: 'BaseProfileTab')
class BaseProfilePage extends AutoRouter {
  const BaseProfilePage({super.key});
}
