import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:otp/otp.dart';

import '../main.dart' show objectBox;
import '../models/account.dart';
import '../object_box/objectbox.g.dart';
import '../routing/constants.dart';
import '../routing/navigation_service.dart';
import '../utils/toast.dart';
import '../utils/uri_decoder.dart';

class Manual extends StatefulWidget {
  const Manual({Key? key, this.account}) : super(key: key);

  final Account? account;

  @override
  State<Manual> createState() => _ManualState();
}

class _ManualState extends State<Manual> with SingleTickerProviderStateMixin {
  final TextEditingController _nameTextFieldController =
      TextEditingController();
  final TextEditingController _issuerTextFieldController =
      TextEditingController();
  final TextEditingController _secretKeyTextFieldController =
      TextEditingController();
  late final AnimationController _animationController;
  late final Animation _animation;
  final Box<Account> _box = objectBox.store.box<Account>();

  String? _nameError;
  String? _issuerError;
  String? _secretKeyError;

  late String _codeTypeValue;
  late int _intervalValue;
  late String _algorithmValue;
  late int _digitsValue;

  String _getAlgorithm(Algorithm? algorithm) {
    if (algorithm == Algorithm.SHA1) {
      return "SHA1";
    } else if (algorithm == Algorithm.SHA256) {
      return "SHA256";
    } else if (algorithm == Algorithm.SHA512) {
      return "SHA512";
    } else {
      return "SHA1";
    }
  }

  void _storeAccount(Account account, String msg) {
    _box.put(account);
    showToast(msg);
    NavigationService().resetToScreen(homeRoute);
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
        duration: const Duration(milliseconds: 150), vsync: this);
    _animation = IntTween(begin: 30, end: 0).animate(_animationController)
      ..addListener(() => setState(() {}));

    _codeTypeValue = widget.account?.type ?? 'totp';
    _intervalValue = widget.account?.period ?? 30;
    _algorithmValue = _getAlgorithm(widget.account?.algorithm);
    _digitsValue = widget.account?.digits ?? 6;

    _nameTextFieldController.text = widget.account?.name ?? "";
    _issuerTextFieldController.text = widget.account?.issuer ?? "";
    _secretKeyTextFieldController.text = widget.account?.secret ?? "";

    if (_codeTypeValue == "hotp") _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text("${widget.account == null ? "Add" : "Edit"} account manually"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 30, 15, 15),
              child: TextField(
                controller: _nameTextFieldController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: "Account name",
                  errorText: _nameError,
                  suffixIcon: _nameError == null
                      ? const Icon(Icons.drive_file_rename_outline)
                      : const Icon(Icons.error, color: Colors.red),
                ),
                onChanged: (String? value) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: _issuerTextFieldController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: "Account issuer",
                  errorText: _issuerError,
                  hintText: "e.g. Google/Facebook/Github",
                  suffixIcon: _issuerError == null
                      ? const Icon(Icons.account_box)
                      : const Icon(Icons.error, color: Colors.red),
                ),
                onChanged: (String? value) {
                  if (_issuerError != null) setState(() => _issuerError = null);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                readOnly: widget.account != null,
                controller: _secretKeyTextFieldController,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  labelText: "Secret key",
                  errorText: _secretKeyError,
                  suffixIcon: _secretKeyError == null
                      ? const Icon(Icons.vpn_key)
                      : const Icon(Icons.error, color: Colors.red),
                ),
                onChanged: (String? value) {
                  if (_secretKeyError != null) {
                    setState(() => _secretKeyError = null);
                  }
                },
                onTap: () {
                  if (widget.account != null) {
                    Clipboard.setData(
                        ClipboardData(text: widget.account?.secret));
                    showToast("Secrey key copied");
                  }
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  flex: 80,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: DropdownButtonFormField2(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Type of code",
                        ),
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        value: _codeTypeValue,
                        items: const [
                          DropdownMenuItem(
                            value: "totp",
                            child: Text("Based on time (TOTP)"),
                          ),
                          DropdownMenuItem(
                            value: "hotp",
                            child: Text("Based on counter (HOTP)"),
                          ),
                        ],
                        onChanged: (String? value) {
                          value! == "hotp"
                              ? _animationController.forward()
                              : _animationController.reverse();
                          setState(() => _codeTypeValue = value);
                        }),
                  ),
                ),
                if (_animation.value != 0)
                  Expanded(
                    flex: _animation.value,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15.0, 15.0, 15.0),
                      child: DropdownButtonFormField2(
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Interval",
                        ),
                        dropdownDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        value: _intervalValue,
                        items: const [
                          DropdownMenuItem(value: 30, child: Text("30s")),
                          DropdownMenuItem(value: 45, child: Text("45s")),
                          DropdownMenuItem(value: 60, child: Text("60s")),
                        ],
                        onChanged: (int? value) =>
                            setState(() => _intervalValue = value!),
                      ),
                    ),
                  ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 15.0, 0, 15.0),
                    child: DropdownButtonFormField2(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Algorithm",
                      ),
                      dropdownDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      value: _algorithmValue,
                      items: const [
                        DropdownMenuItem(
                          value: "SHA1",
                          child: Text("SHA1"),
                        ),
                        DropdownMenuItem(
                          value: "SHA256",
                          child: Text("SHA256"),
                        ),
                        DropdownMenuItem(
                          value: "SHA512",
                          child: Text("SHA512"),
                        ),
                      ],
                      onChanged: (String? value) =>
                          setState(() => _algorithmValue = value!),
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: DropdownButtonFormField2(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Digits",
                      ),
                      dropdownDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      value: _digitsValue,
                      items: const [
                        DropdownMenuItem(
                          value: 4,
                          child: Text("4"),
                        ),
                        DropdownMenuItem(
                          value: 6,
                          child: Text("6"),
                        ),
                      ],
                      onChanged: (int? value) =>
                          setState(() => _digitsValue = value!),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: widget.account != null
            ? const Icon(Icons.save_as, color: Colors.white)
            : const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          String name = Uri.decodeFull(_nameTextFieldController.text.trim());
          String issuer =
              Uri.decodeFull(_issuerTextFieldController.text.trim());
          String secretKey =
              _secretKeyTextFieldController.text.trim().toUpperCase();

          if (name.isEmpty) {
            _nameError = "The account name is required";
          } else if (name.length > 64) {
            _nameError = "The account name cannot be longer than 64 characters";
          } else {
            _nameError = null;
          }

          if (issuer.length > 64) {
            _issuerError =
                "The account issuer cannot be longer than 64 characters";
          } else {
            _issuerError = null;
          }

          if (secretKey.isEmpty) {
            _secretKeyError = "The secret key is required";
          } else if (secretKey.length < 16) {
            _secretKeyError =
                "The secret key cannot be shorter than 16 characters";
          } else if (secretKey.length > 256) {
            _secretKeyError =
                "The secret key cannot be longer than 256 characters";
          } else {
            _secretKeyError = null;
          }

          if (_nameError == null &&
              _issuerError == null &&
              _secretKeyError == null) {
            Account? newAccount;
            int? lastPosition = (_box.query(Account_.deleted.equals(false))
                  ..order(Account_.position, flags: Order.descending))
                .build()
                .findFirst()
                ?.position;
            int position;

            if (lastPosition != null) {
              position = lastPosition + 1;
            } else {
              position = 0;
            }

            if (widget.account == null) {
              newAccount = Account(
                secret: secretKey,
                name: name,
                issuer: issuer,
                dbAlgorithm: UriDecoder.getAlgorithm(_algorithmValue),
                digits: _digitsValue,
                type: _codeTypeValue,
                period: _codeTypeValue == "totp" ? _intervalValue : null,
                position: position,
              );
            } else {
              widget.account?.name = name;
              widget.account?.issuer = issuer;
              widget.account?.dbAlgorithm =
                  UriDecoder.getAlgorithm(_algorithmValue);
              widget.account?.digits = _digitsValue;
              widget.account?.type = _codeTypeValue;
              widget.account?.period =
                  _codeTypeValue == "totp" ? _intervalValue : null;
              widget.account?.toUpdate = true;
              newAccount = widget.account;
            }

            if (widget.account != null) {
              _storeAccount(newAccount as Account, "Account has been edited");
            } else {
              Account? sameAccount = _box
                  .query(Account_.secret.equals(secretKey))
                  .build()
                  .findFirst();

              if (sameAccount == null) {
                _storeAccount(
                    newAccount as Account, "New account has been added");
              } else if (sameAccount.deleted) {
                newAccount?.id = newAccount.id;
                _storeAccount(
                    newAccount as Account, "New account has been added");
              } else {
                _secretKeyError = "This secret key already exists";
                setState(() {});
              }
            }
          } else {
            setState(() {});
          }
        },
      ),
    );
  }
}
