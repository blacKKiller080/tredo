import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:tredo/src/core/common/constants.dart';
import 'package:tredo/src/core/extension/extensions.dart';
import 'package:tredo/src/core/resources/resources.dart';
import 'package:tredo/src/features/app/bloc/app_bloc.dart';
import 'package:tredo/src/features/app/router/app_router.dart';
import 'package:tredo/src/features/app/widgets/app_bar_with_title.dart';
import 'package:tredo/src/features/app/widgets/custom/custom_loading_widget.dart';
import 'package:tredo/src/features/auth/bloc/login_cubit.dart';

@RoutePage()
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String? userEmail;
  List<String> userListt = [];
  // List<GuideTopicsDTO> guideTopicsDTO = [];

  final ScrollController scrollController = ScrollController();
  final RefreshController refreshController = RefreshController();
  @override
  void initState() {
    super.initState();
    BlocProvider.of<LoginCubit>(context).fetchAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return CustomLoadingWidget(
      child: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          state.whenOrNull(
            initialState: () {
              context.loaderOverlay.hide();
            },
            loadingState: () {
              context.loaderOverlay.show();
            },
            loadedState: (user, userList) {
              context.loaderOverlay.hide();
              refreshController.refreshCompleted();

              setState(() {
                userEmail = user;
                userListt = userList!;
              });
            },
            errorState: (message) {
              context.loaderOverlay.hide();
            },
          );
        },
        child: BlocBuilder<LoginCubit, LoginState>(
          builder: (context, state) {
            return Scaffold(
              body: SafeArea(
                child: Column(
                  children: [
                    const AppBarWithTitle(title: 'Main Page'),
                    const SizedBox(height: 21),
                    Expanded(
                      child: SmartRefresher(
                        // enablePullUp: true,
                        header: refreshClassicHeader(context),
                        footer: refreshClassicFooter(context),
                        controller: refreshController,
                        // enablePullDown: context.appBloc.isAuthenticated,
                        onRefresh: () {
                          BlocProvider.of<LoginCubit>(context).fetchAllUsers();
                        },
                        scrollController: scrollController,
                        child: CustomScrollView(
                          cacheExtent: 10000,
                          physics: const BouncingScrollPhysics(),
                          controller: scrollController,
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          slivers: [
                            SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                  Padding(
                                    padding: const EdgeInsets.all(16.0)
                                        .copyWith(right: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          userEmail ?? '',
                                          style: AppTextStyles.os18w500,
                                        ),
                                        IconButton(
                                          icon: SvgPicture.asset(
                                            'assets/icons/exit.svg',
                                          ),
                                          onPressed: () {
                                            context.appBloc.add(
                                              const AppEvent.exiting(),
                                            );
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Container(
                                  //   // height: 500,
                                  //   width: double.infinity,
                                  //   margin: const EdgeInsets.symmetric(
                                  //     horizontal: 16,
                                  //   ),
                                  //   padding: const EdgeInsets.all(1)
                                  //       .copyWith(bottom: 21),
                                  //   decoration: BoxDecoration(
                                  //     color: AppColors.kWhite,
                                  //     borderRadius: BorderRadius.circular(20),
                                  //     boxShadow: AppDecorations.dropShadow,
                                  //   ),
                                  //   child:
                                  const Padding(
                                    padding: EdgeInsets.only(left: 16.0),
                                    child: Text(
                                      'Send message to:',
                                      style: AppTextStyles.os16w500Neutral,
                                    ),
                                  ),
                                  state.maybeWhen(
                                    loadedState: (user, userList) {
                                      if (userList == null ||
                                          userList.isEmpty) {
                                        return const Center(
                                          child: Text(
                                            'No users available',
                                          ),
                                        );
                                      }
                                      return ListView.builder(
                                        itemCount: userList.length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Text(userList[index]),
                                            trailing: const Icon(Icons.send),
                                            onTap: () {
                                              context.router.push(
                                                ChatRoute(
                                                  recipientEmail:
                                                      userList[index],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      );
                                    },
                                    orElse: () {
                                      return ListView.builder(
                                        itemCount: userListt.length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            title: Text(userListt[index]),
                                            trailing: const Icon(Icons.send),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  // ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        //  Scaffold(
        //   body: SafeArea(
        //     child: Column(
        //       children: [
        //         Padding(
        //           padding:
        //               const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        //           child: Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             children: [
        //               Text(
        //                 userEmail ?? '',
        //                 style: AppTextStyles.os18w500,
        //               ),
        //               IconButton(
        //                 icon: SvgPicture.asset(
        //                   'assets/icons/exit.svg',
        //                 ),
        //                 onPressed: () {
        //                   context.appBloc.add(
        //                     const AppEvent.exiting(),
        //                   );
        //                 },
        //                 padding: EdgeInsets.zero,
        //                 constraints: const BoxConstraints(),
        //               ),
        //             ],
        //           ),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
      ),
    );
  }
}
