import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:otp_manager/bloc/home/home_bloc.dart';
import 'package:otp_manager/bloc/home/home_event.dart';
import 'package:otp_manager/bloc/home/home_state.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_bloc.dart';
import 'package:otp_manager/utils/show_snackbar.dart';
import 'package:upgrader/upgrader.dart';

import '../bloc/otp_manager/otp_manager_state.dart';
import "../routing/constants.dart";
import '../routing/navigation_service.dart';
import '../utils/custom_painter.dart';
import '../utils/delete_modal.dart';
import '../utils/toast.dart';
import '../utils/tooltip.dart';

class Home extends HookWidget {
  Home({Key? key}) : super(key: key);

  final NavigationService _navigationService = NavigationService();
  final FocusNode _searchBarNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final textFieldSearchBarController = useTextEditingController();
    final countDownAnimationController = useAnimationController(
        duration:
            Duration(seconds: context.read<HomeBloc>().state.refreshTime));

    final showSearchBar = useState(false);
    final searchBarAnimationEnd = useState(true);

    useEffect(() {
      context.read<HomeBloc>().add(NextcloudSync());
      return null;
    }, []);

    return UpgradeAlert(
      upgrader: Upgrader(
        debugLogging: true,
        showIgnore: false,
        showLater: false,
        durationUntilAlertAgain: const Duration(seconds: 1),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              if (!showSearchBar.value && searchBarAnimationEnd.value) ...[
                const Text("OTP Manager"),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: BlocBuilder<HomeBloc, HomeState>(
                    builder: (context, state) {
                      return (state.syncStatus == -1)
                          ? const Icon(
                              Icons.cloud_off,
                              color: Colors.redAccent,
                            )
                          : (state.syncStatus == 0)
                              ? const Icon(
                                  Icons.cloud_done,
                                  color: Colors.greenAccent,
                                )
                              : const Icon(
                                  Icons.cloud_sync,
                                  color: Colors.yellow,
                                );
                    },
                  ),
                ),
              ]
            ],
          ),
          actions: <Widget>[
            AnimatedContainer(
              onEnd: () {
                searchBarAnimationEnd.value = true;
                _searchBarNode.requestFocus();
              },
              duration: const Duration(milliseconds: 150),
              width: showSearchBar.value
                  ? MediaQuery.of(context).size.width - 140
                  : 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                    focusNode: _searchBarNode,
                    enabled: showSearchBar.value,
                    controller: textFieldSearchBarController,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(
                        //Style of hintText
                        color: Colors.white60,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1),
                      ),
                      disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1),
                      ),
                    ),
                    onChanged: (value) {
                      context
                          .read<HomeBloc>()
                          .add(SearchBarValueChanged(value: value));
                      context.read<HomeBloc>().add(GetAccounts());
                    }),
              ),
            ),
            BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state.accounts.isNotEmpty &&
                    !showSearchBar.value &&
                    searchBarAnimationEnd.value) {
                  return Center(
                    child: CustomPaint(
                      size: const Size(10, 10),
                      painter: CustomTimerPainter(
                        animation: countDownAnimationController,
                        backgroundColor: Colors.blue,
                        color: Colors.white,
                        strokeWidth: 15.0,
                      ),
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: AnimatedIconButton(
                size: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                duration: const Duration(milliseconds: 150),
                onPressed: () {
                  if (searchBarAnimationEnd.value) {
                    searchBarAnimationEnd.value = false;
                    showSearchBar.value = !showSearchBar.value;
                    if (!showSearchBar.value) {
                      context
                          .read<HomeBloc>()
                          .add(const SearchBarValueChanged(value: ""));
                      context.read<HomeBloc>().add(GetAccounts());
                      textFieldSearchBarController.clear();
                    }
                  }
                },
                icons: const [
                  AnimatedIconItem(
                    icon: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                  ),
                  AnimatedIconItem(
                    icon: Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
              return PopupMenuButton(
                //padding: const EdgeInsets.all(0.0),
                itemBuilder: (context) {
                  return [
                    PopupMenuItem<Function>(
                      value: () => context.read<HomeBloc>().add(SortByName()),
                      child: Row(
                        children: [
                          const Text("By Name"),
                          Text(
                            state.sortedByNameDesc ? " (A -> Z)" : " (Z -> A)",
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<Function>(
                      value: () => context.read<HomeBloc>().add(SortByIssuer()),
                      child: Row(
                        children: [
                          const Text("By Issuer"),
                          Text(
                            state.sortedByIssuerDesc
                                ? " (A -> Z)"
                                : " (Z -> A)",
                          ),
                        ],
                      ),
                    ),
                    PopupMenuItem<Function>(
                      value: () => context.read<HomeBloc>().add(SortById()),
                      child: Row(
                        children: [
                          const Text("By Date"),
                          Text(
                            state.sortedByIdDesc
                                ? " (most recent)"
                                : " (most remote)",
                          ),
                        ],
                      ),
                    ),
                  ];
                },
                onSelected: (Function value) => value(),
                icon: const Icon(
                  Icons.sort,
                  size: 25.0,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(3.0)),
                ),
              );
            }),
          ],
        ),
        body: BlocConsumer<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state.accounts.isEmpty) {
              countDownAnimationController.reset();
            } else {
              var duration = state.refreshTime -
                  (((DateTime.now().millisecondsSinceEpoch ~/ 1000).round()) %
                      state.refreshTime);

              countDownAnimationController
                  .forward(from: 1.0 - (duration / state.refreshTime))
                  .whenComplete(() {
                context.read<HomeBloc>().add(GetAccounts());
                countDownAnimationController.repeat();
              });
            }
            if (state.syncError != "") {
              showSnackBar(context: context, msg: state.syncError);
            }
            if (state.accountDeleted != "") {
              showSnackBar(context: context, msg: state.accountDeleted);
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                if (state.isGuest) ...[
                  Container(
                    width: double.infinity,
                    height: 35,
                    color: Theme.of(context).brightness == Brightness.light
                        ? const Color.fromRGBO(0, 185, 255, 1)
                        : Theme.of(context).secondaryHeaderColor,
                    child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.warning_amber,
                                color: Colors.amber),
                            Text(
                              "You are are using the test (offline) mode",
                              style: TextStyle(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.white
                                    : Colors.white70,
                              ),
                            ),
                            const Icon(Icons.warning_amber,
                                color: Colors.amber),
                          ],
                        )),
                  ),
                ] else if (state.pin == "") ...[
                  GestureDetector(
                    onTap: () {
                      _navigationService.navigateTo(
                        pinRoute,
                        arguments: {"toEdit": false},
                      );
                    },
                    child: Container(
                      width: double.infinity,
                      height: 35,
                      color: Theme.of(context).brightness == Brightness.light
                          ? const Color.fromRGBO(0, 185, 255, 1)
                          : Theme.of(context).secondaryHeaderColor,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Please set a pin to protect your OTP codes",
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.white
                                    : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                Padding(
                  padding: EdgeInsets.fromLTRB(
                      0, state.pin == "" || state.isGuest ? 35 : 0, 0, 0),
                  child: RefreshIndicator(
                    onRefresh: () async =>
                        context.read<HomeBloc>().add(NextcloudSync()),
                    child: ReorderableListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: state.accounts.keys.length,
                      padding: state.accounts.keys.length <= 1
                          ? const EdgeInsets.fromLTRB(0, 0, 0, 150)
                          : null,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        var account = state.accounts.keys.elementAt(index);
                        String? otpCode = state.accounts[account];

                        return BlocBuilder<OtpManagerBloc, OtpManagerState>(
                          key: ValueKey(account.id),
                          builder: (appContext, appState) {
                            return Slidable(
                              endActionPane: ActionPane(
                                motion: const DrawerMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) => showDeleteModal(
                                        context,
                                        account,
                                        () => context.read<HomeBloc>().add(
                                            DeleteAccount(id: account.id))),
                                    backgroundColor: Colors.red,
                                    icon: Icons.delete,
                                    label: "Delete",
                                  ),
                                  SlidableAction(
                                    onPressed: (_) {
                                      if (state.pin == "") {
                                        showSnackBar(
                                          context: context,
                                          msg:
                                              "To edit an account you have to set a pin before",
                                        );
                                      } else {
                                        _navigationService.navigateTo(
                                          manualRoute,
                                          arguments: {"account": account},
                                        );
                                      }
                                    },
                                    backgroundColor: Colors.blue,
                                    icon: Icons.edit,
                                    label: "Edit",
                                  ),
                                ],
                              ),
                              child: ListTile(
                                title: account.issuer != null &&
                                        account.issuer != ""
                                    ? Text(
                                        "${account.issuer} (${account.name})")
                                    : Text(account.name),
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 0, 0),
                                        child: ReorderableDragStartListener(
                                          key: ValueKey(index),
                                          index: index,
                                          enabled: false,
                                          child: const Icon(Icons.drag_handle),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (account.toUpdate == true ||
                                        account.isNew)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 8, 0),
                                        child: tooltip(
                                          "Have to be synchronised",
                                          const Icon(
                                            Icons.sync,
                                            size: 16,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                      ),
                                    if (account.period != 30)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            0, 0, 8, 0),
                                        child: tooltip(
                                          "The TOTP's period is: ${account.period}s",
                                          const Icon(
                                            Icons.more_time_rounded,
                                            size: 16,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    if (account.type == "hotp")
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(Icons.refresh),
                                        onPressed: () => context
                                            .read<HomeBloc>()
                                            .add(IncrementCounter(
                                                account: account)),
                                      ),
                                    if (appState.copyWithTap)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 0, 0, 0),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(Icons.more_vert),
                                          onPressed: () =>
                                              _navigationService.navigateTo(
                                            accountDetailsRoute,
                                            arguments: account,
                                          ),
                                        ),
                                      )
                                    else if (otpCode != null)
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 0, 0, 0),
                                        child: IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(Icons.copy),
                                          onPressed: () {
                                            Clipboard.setData(
                                                ClipboardData(text: otpCode));
                                            showToast(
                                                "${account.type == "totp" ? "TOTP" : "HOTP"} code copied");
                                          },
                                        ),
                                      )
                                  ],
                                ),
                                subtitle: Text(
                                  otpCode ?? "Click to generate code",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.blue,
                                  ),
                                ),
                                onTap: () {
                                  if (otpCode == null) {
                                    context.read<HomeBloc>().add(
                                        IncrementCounter(account: account));
                                  } else if (appState.copyWithTap) {
                                    Clipboard.setData(
                                        ClipboardData(text: otpCode));
                                    showSnackBar(
                                        context: context,
                                        msg:
                                            "${account.type == "totp" ? "TOTP" : "HOTP"} code copied");
                                  } else {
                                    _navigationService.navigateTo(
                                      accountDetailsRoute,
                                      arguments: account,
                                    );
                                  }
                                },
                              ),
                            );
                          },
                        );
                      },
                      onReorder: (oldIndex, newIndex) => context
                          .read<HomeBloc>()
                          .add(Reorder(oldIndex: oldIndex, newIndex: newIndex)),
                    ),
                  ),
                )
              ],
            );
          },
        ),
        floatingActionButton: SpeedDial(
          backgroundColor: Theme.of(context).primaryColor,
          animatedIcon: AnimatedIcons.menu_close,
          foregroundColor: Colors.white,
          overlayColor: Colors.grey,
          overlayOpacity: 0.2,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.keyboard),
              label: "Type configuration manually",
              onTap: () =>
                  _navigationService.navigateTo(manualRoute, arguments: {}),
            ),
            SpeedDialChild(
              child: const Icon(Icons.qr_code_scanner),
              label: "Scan QR code",
              onTap: () => _navigationService.navigateTo(qrCodeScannerRoute),
            ),
            SpeedDialChild(
              child: const Icon(Icons.library_add_outlined),
              label: "Import OTP",
              onTap: () => _navigationService.navigateTo(importRoute),
            ),
            SpeedDialChild(
              child: const Icon(Icons.settings),
              label: "Settings",
              onTap: () => _navigationService.navigateTo(settingsRoute),
            ),
            SpeedDialChild(
              child: const Icon(Icons.logout),
              label: "Logout",
              onTap: () => context.read<HomeBloc>().add(Logout()),
            ),
          ],
          spaceBetweenChildren: 10,
          spacing: 10,
        ),
      ),
    );
  }
}
