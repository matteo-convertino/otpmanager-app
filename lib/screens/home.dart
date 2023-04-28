import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:otp/otp.dart';
import 'package:provider/provider.dart';
import 'package:simple_animated_icon/simple_animated_icon.dart';

import '../main.dart' show DarkThemeProvider, objectBox;
import '../models/account.dart';
import '../models/user.dart';
import '../object_box/objectbox.g.dart';
import "../routing/constants.dart";
import '../routing/navigation_service.dart';
import '../utils/custom_painter.dart';
import '../utils/delete_modal.dart';
import '../utils/nextcloud.dart';
import '../utils/toast.dart';
import '../utils/tooltip.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final NavigationService _navigationService = NavigationService();
  AnimationController? _countDownAnimationController;
  late AnimationController _animationSearchBarController;
  late Animation<double> _searchBarProgress;
  final TextEditingController _textFieldSearchBarController =
      TextEditingController();

  final FocusNode _searchBarNode = FocusNode();

  final Box<Account> _accountBox = objectBox.store.box<Account>();
  final Box<User> _userBox = objectBox.store.box<User>();
  late User _user;

  late final Nextcloud _nextcloud;

  bool _searchBarAnimationEnd = true;
  bool _showSearchBar = false;
  final int _refreshTime = 30;
  String _accountFilter = "";

  void _setAnimation() {
    var duration = _refreshTime -
        (((DateTime.now().millisecondsSinceEpoch ~/ 1000).round()) %
            _refreshTime);

    _countDownAnimationController
        ?.forward(from: 1.0 - (duration / _refreshTime))
        .whenComplete(() {
      _countDownAnimationController?.reset();
      _setAnimation();
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();

    _user = _userBox.getAll()[0];

    _nextcloud = Nextcloud(user: _user, callback: refresh)..sync();

    _animationSearchBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(() => setState(() {}));

    _searchBarProgress = Tween<double>(begin: 0.0, end: 1.0)
        .animate(_animationSearchBarController);
  }

  @override
  void dispose() {
    _searchBarNode.dispose();
    _animationSearchBarController.dispose();
    _countDownAnimationController?.dispose();
    super.dispose();
  }

  void refresh() => setState(() => _user = _userBox.getAll()[0]);

  List<Account> _getAccounts() {
    if (_accountFilter == "") {
      return (_accountBox.query(Account_.deleted.equals(false))
            ..order(Account_.position))
          .build()
          .find();
    } else {
      List<Account> accounts = (_accountBox.query(Account_.deleted
                  .equals(false) &
              (Account_.name.contains(_accountFilter, caseSensitive: false) |
                  Account_.issuer
                      .contains(_accountFilter, caseSensitive: false)))
            ..order(Account_.position))
          .build()
          .find();
      return accounts;
    }
  }

  String? _getOtp(Account account) {
    if (account.type == "totp") {
      return OTP.generateTOTPCodeString(
        account.secret,
        DateTime.now().millisecondsSinceEpoch,
        algorithm: account.algorithm,
        interval: account.period as int,
        length: account.digits as int,
        isGoogle: true,
      );
    } else if (account.counter! > 0) {
      return OTP.generateHOTPCodeString(account.secret, account.counter!,
          algorithm: account.algorithm,
          length: account.digits as int,
          isGoogle: true);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);

    var accounts = _getAccounts();
    bool isAccountListEmpty = _accountBox
        .query(Account_.deleted.equals(false))
        .build()
        .find()
        .isEmpty;

    if (!isAccountListEmpty) {
      if (_countDownAnimationController == null) {
        _countDownAnimationController = AnimationController(
          vsync: this,
          duration: Duration(seconds: _refreshTime),
        );

        _setAnimation();
      }
    } else {
      _countDownAnimationController?.reset();
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (!_showSearchBar && _searchBarAnimationEnd) ...[
              const Text("OTP Manager"),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                child: (_nextcloud.error == -1)
                    ? const Icon(
                        Icons.cloud_off,
                        color: Colors.redAccent,
                      )
                    : (_nextcloud.error == 0)
                        ? const Icon(
                            Icons.cloud_done,
                            color: Colors.greenAccent,
                          )
                        : const Icon(Icons.cloud_sync, color: Colors.yellow),
              ),
            ]
          ],
        ),
        actions: <Widget>[
          AnimatedContainer(
            onEnd: () => setState(() {
              _searchBarAnimationEnd = true;
              _searchBarNode.requestFocus();
            }),
            duration: const Duration(milliseconds: 150),
            width: _showSearchBar ? MediaQuery.of(context).size.width - 125 : 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                focusNode: _searchBarNode,
                enabled: _showSearchBar,
                controller: _textFieldSearchBarController,
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
                onChanged: (value) => setState(() => _accountFilter = value),
              ),
            ),
          ),
          if (!isAccountListEmpty && !_showSearchBar && _searchBarAnimationEnd)
            Center(
              child: CustomPaint(
                size: const Size(10, 10),
                painter: CustomTimerPainter(
                  animation:
                      _countDownAnimationController as AnimationController,
                  backgroundColor: Colors.blue,
                  color: Colors.white,
                  strokeWidth: 15.0,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 5, 0),
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                if (_searchBarAnimationEnd) {
                  setState(() {
                    _searchBarAnimationEnd = false;
                    _showSearchBar = !_showSearchBar;
                    if (_showSearchBar) {
                      _animationSearchBarController.forward();
                    } else {
                      _animationSearchBarController.reverse();
                      _accountFilter = "";
                      _textFieldSearchBarController.clear();
                    }
                  });
                }
              },
              icon: SimpleAnimatedIcon(
                startIcon: Icons.search,
                endIcon: Icons.close,
                progress: _searchBarProgress,
              ),
            ),
          ),
          PopupMenuButton(
            padding: const EdgeInsets.all(0.0),
            itemBuilder: (context) {
              return [
                PopupMenuItem<Function>(
                  value: () => _navigationService.navigateTo(
                    settingsRoute,
                    arguments: refresh,
                  ),
                  child: const Text("Settings"),
                ),
                PopupMenuItem<Function>(
                  value: () => _navigationService.navigateTo(importRoute),
                  child: const Text("Import OTP"),
                ),
                PopupMenuItem<Function>(
                  value: () => _nextcloud.sync(),
                  child: const Text("Sync now"),
                ),
                PopupMenuItem<Function>(
                  value: () {
                    themeChange.darkTheme = false;
                    _userBox.removeAll();
                    _accountBox.removeAll();
                    _navigationService.resetToScreen(loginRoute);
                  },
                  child: const Text("Logout"),
                ),
              ];
            },
            onSelected: (Function value) => value(),
            icon: const Icon(
              Icons.settings,
              size: 25.0,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(3.0)),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_user.isGuest) ...[
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
                      const Icon(Icons.warning_amber, color: Colors.amber),
                      Text(
                        "You are are using the test (offline) mode",
                        style: TextStyle(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? Colors.white
                                  : Colors.white70,
                        ),
                      ),
                      const Icon(Icons.warning_amber, color: Colors.amber),
                    ],
                  )),
            ),
          ] else if (_user.pin == null) ...[
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
                      color: Theme.of(context).brightness == Brightness.light
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
                0, _user.pin == null || _user.isGuest ? 35 : 0, 0, 0),
            child: RefreshIndicator(
              onRefresh: () async => _nextcloud.sync(),
              child: ReorderableListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: accounts.length,
                  padding: accounts.length <= 1
                      ? const EdgeInsets.fromLTRB(0, 0, 0, 150)
                      : null,
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    var account = accounts[index];
                    String? otpCode = _getOtp(account);

                    return ListTile(
                      key: ValueKey(account),
                      title: account.issuer != null && account.issuer != ""
                          ? Text("${account.issuer} (${account.name})")
                          : Text(account.name),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: ReorderableDragStartListener(
                                  key: ValueKey(index),
                                  index: index,
                                  child: const Icon(Icons.drag_handle),
                                ),
                              ))
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (account.toUpdate == true || account.isNew)
                            Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                                child: tooltip(
                                  "Have to be synchronised",
                                  const Icon(
                                    Icons.sync,
                                    size: 16,
                                    color: Colors.blueAccent,
                                  ),
                                )),
                          if (account.period != 30)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                              child: tooltip(
                                "The TOTP's period is: ${account.period}s",
                                const Icon(
                                  Icons.more_time_rounded,
                                  size: 16,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          if (otpCode != null)
                            if (!_user.copyWithTap)
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: otpCode));
                                  showToast(
                                      "${account.type == "totp" ? "TOTP" : "HOTP"} code copied");
                                },
                              )
                            else
                              IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.more_vert),
                                onPressed: () => _navigationService.navigateTo(
                                  accountDetailsRoute,
                                  arguments: account,
                                ),
                              ),
                          if (account.type == "hotp")
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(Icons.refresh),
                                onPressed: () {
                                  account.counter = account.counter! + 1;
                                  account.toUpdate = true;
                                  _accountBox.put(account);
                                  setState(() {});
                                  _nextcloud.sync();
                                },
                              ),
                            ),
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
                        if (_user.copyWithTap && otpCode != null) {
                          Clipboard.setData(ClipboardData(text: otpCode));
                          showToast(
                              "${account.type == "totp" ? "TOTP" : "HOTP"} code copied");
                        } else {
                          _navigationService.navigateTo(
                            accountDetailsRoute,
                            arguments: account,
                          );
                        }
                      },
                      onLongPress: () => showDeleteModal(context, account, () {
                        Account? accountToRemove = _accountBox
                            .query(Account_.id.equals(account.id))
                            .build()
                            .findFirst();
                        accountToRemove?.deleted = true;

                        _accountBox
                            .query(Account_.deleted.equals(false) &
                                Account_.position.greaterThan(
                                    accountToRemove?.position ?? 0))
                            .build()
                            .find()
                            .forEach((account) {
                          account.position = account.position! - 1;
                          account.toUpdate = true;
                          _accountBox.put(account);
                        });

                        accountToRemove?.position = null;
                        _accountBox.put(accountToRemove!);

                        _nextcloud.sync();
                        setState(() {});
                        showToast(
                            "${account.type == "totp" ? "TOTP" : "HOTP"} has been removed");
                        _navigationService.goBack();
                      }),
                    );
                  },
                  onReorder: (oldIndex, newIndex) {
                    QueryBuilder<Account> query;
                    int difference;
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                      query = _accountBox.query(Account_.deleted.equals(false) &
                          Account_.position.lessOrEqual(newIndex) &
                          Account_.position.greaterThan(oldIndex));
                      difference = -1;
                    } else {
                      query = _accountBox.query(Account_.deleted.equals(false) &
                          Account_.position.greaterOrEqual(newIndex) &
                          Account_.position.lessThan(oldIndex));
                      difference = 1;
                    }

                    var account = _accountBox
                        .query(Account_.position.equals(oldIndex))
                        .build()
                        .findFirst();

                    query.build().find().forEach((account) {
                      account.position = account.position! + difference;
                      account.toUpdate = true;
                      _accountBox.put(account);
                    });

                    setState(() {
                      account?.position = newIndex;
                      account?.toUpdate = true;
                      _accountBox.put(account!);
                      _nextcloud.sync();
                    });
                  }),
            ),
          ),
        ],
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
        ],
        spaceBetweenChildren: 10,
        spacing: 10,
      ),
    );
  }
}
