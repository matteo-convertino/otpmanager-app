import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:otp_manager/bloc/manual/manual_bloc.dart';
import 'package:otp_manager/bloc/manual/manual_event.dart';
import 'package:otp_manager/routing/constants.dart';
import 'package:otp_manager/routing/navigation_service.dart';
import 'package:otp_manager/utils/show_snackbar.dart';

import '../utils/toast.dart';
import '../bloc/manual/manual_state.dart';

class Manual extends HookWidget {
  const Manual({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final animationController =
        useAnimationController(duration: const Duration(milliseconds: 150));
    final animation =
        useAnimation(IntTween(begin: 30, end: 0).animate(animationController));

    useEffect(() {
      if (context.read<ManualBloc>().state.codeTypeValue == "hotp") {
        animationController.forward();
      }
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Text(
            "${context.read<ManualBloc>().state.isEdit ? "Edit" : "Add"} account manually"),
      ),
      body: BlocConsumer<ManualBloc, ManualState>(
        listener: (context, state) {
          if (state.message != "") {
            showSnackBar(context: context, msg: state.message);
            NavigationService().resetToScreen(homeRoute);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 30, 15, 15),
                  child: TextFormField(
                    initialValue: state.name,
                    //controller: _nameTextFieldController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Account name",
                      errorText: state.nameError,
                      suffixIcon: state.nameError == null
                          ? const Icon(Icons.drive_file_rename_outline)
                          : const Icon(Icons.error, color: Colors.red),
                    ),
                    onChanged: (value) {
                      context.read<ManualBloc>().add(NameChanged(name: value));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    initialValue: state.issuer,
                    //controller: _issuerTextFieldController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Account issuer",
                      errorText: state.issuerError,
                      hintText: "e.g. Google/Facebook/Github",
                      suffixIcon: state.issuerError == null
                          ? const Icon(Icons.account_box)
                          : const Icon(Icons.error, color: Colors.red),
                    ),
                    onChanged: (value) {
                      context
                          .read<ManualBloc>()
                          .add(IssuerChanged(issuer: value));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    initialValue: state.secretKey,
                    readOnly: state.isEdit,
                    //controller: _secretKeyTextFieldController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: "Secret key",
                      errorText: state.secretKeyError,
                      suffixIcon: state.secretKeyError == null
                          ? const Icon(Icons.vpn_key)
                          : const Icon(Icons.error, color: Colors.red),
                    ),
                    onChanged: (value) {
                      context
                          .read<ManualBloc>()
                          .add(SecretKeyChanged(secretKey: value));
                    },
                    onTap: () {
                      if (state.isEdit) {
                        Clipboard.setData(ClipboardData(text: state.secretKey));
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
                          value: state.codeTypeValue,
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
                            value == "hotp"
                                ? animationController.forward()
                                : animationController.reverse();
                            context.read<ManualBloc>().add(
                                CodeTypeValueChanged(codeTypeValue: value!));
                          },
                        ),
                      ),
                    ),
                    if (animation != 0)
                      Expanded(
                        flex: animation,
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(0, 15.0, 15.0, 15.0),
                          child: DropdownButtonFormField2(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Interval",
                            ),
                            dropdownDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            value: state.intervalValue,
                            items: const [
                              DropdownMenuItem(value: 30, child: Text("30s")),
                              DropdownMenuItem(value: 45, child: Text("45s")),
                              DropdownMenuItem(value: 60, child: Text("60s")),
                            ],
                            onChanged: (int? value) {
                              if (value == null) return;
                              context.read<ManualBloc>().add(
                                  IntervalValueChanged(intervalValue: value));
                            },
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
                          value: state.algorithmValue,
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
                          onChanged: (String? value) {
                            context.read<ManualBloc>().add(
                                AlgorithmValueChanged(algorithmValue: value!));
                          },
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
                          value: state.digitsValue,
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
                          onChanged: (int? value) {
                            if (value == null) return;
                            context
                                .read<ManualBloc>()
                                .add(DigitsValueChanged(digitsValue: value));
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: context.read<ManualBloc>().state.isEdit
            ? const Icon(Icons.save_as, color: Colors.white)
            : const Icon(Icons.add, color: Colors.white),
        onPressed: () => context.read<ManualBloc>().add(AddOrEditAccount()),
      ),
    );
  }
}
