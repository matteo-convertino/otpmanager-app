import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:otp_manager/bloc/manual/manual_bloc.dart';
import 'package:otp_manager/bloc/manual/manual_event.dart';
import 'package:otp_manager/di/injection.dart';
import 'package:otp_manager/service/snackbar_service.dart';
import 'package:otp_manager/utils/enum/otp_algorithm.dart';
import 'package:otp_manager/utils/enum/otp_digits.dart';
import 'package:otp_manager/utils/enum/otp_period.dart';
import 'package:otp_manager/utils/enum/otp_type.dart';
import 'package:otp_manager/utils/helper/otp_icons_helper.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../bloc/icon_picker/icon_picker_bloc.dart';
import '../bloc/manual/manual_state.dart';
import 'icon_picker.dart';

class Manual extends HookWidget {
  const Manual({super.key});

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 150),
    );
    final animation = useAnimation(
      IntTween(begin: 3, end: 0).animate(animationController),
    );

    useEffect(() {
      if (context.read<ManualBloc>().state.codeTypeValue ==
          OtpType.hotp.value) {
        animationController.forward();
      }
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${context.read<ManualBloc>().state.isEdit ? "Edit" : "Add"} account manually",
        ),
      ),
      body: BlocBuilder<ManualBloc, ManualState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0, top: 15),
                        child: Column(
                          children: [
                            InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () =>
                                  showModalBottomSheet<String?>(
                                    context: context,
                                    showDragHandle: true,
                                    isScrollControlled: true,
                                    useSafeArea: true,
                                    builder: (BuildContext context) {
                                      return BlocProvider<IconPickerBloc>(
                                        create: (context) => IconPickerBloc(
                                          issuer: state.issuer,
                                        ),
                                        child: const IconPicker(),
                                      );
                                    },
                                  ).then(
                                    (value) => {
                                      if (value != null && context.mounted)
                                        context.read<ManualBloc>().add(
                                          IconKeyChanged(key: value),
                                        ),
                                    },
                                  ),
                              child: Ink(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Theme.of(
                                          context,
                                        ).scaffoldBackgroundColor
                                      : const Color(0xFF313131),
                                  boxShadow: [
                                    if (Theme.of(context).brightness ==
                                        Brightness.light)
                                      BoxShadow(
                                        color: Colors.grey[300]!,
                                        blurRadius: 10.0,
                                        spreadRadius: 1.0,
                                      ),
                                  ],
                                ),
                                child:
                                    OtpIconsHelper.simpleIcons[state.iconKey] ??
                                    OtpIconsHelper.simpleIcons['default'],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 3.0),
                              child: Text(
                                'Change icon',
                                style: TextStyle(
                                  fontSize: 11,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(15, 30, 15, 15),
                        child: TextFormField(
                          initialValue: state.name,
                          decoration: InputDecoration(
                            border: const OutlineInputBorder(),
                            labelText: 'Account name',
                            hintText: 'e.g. Username/Email',
                            errorText: state.nameError,
                            suffixIcon: state.nameError == null
                                ? const PhosphorIcon(PhosphorIconsRegular.user)
                                : const PhosphorIcon(
                                    PhosphorIconsRegular.warningCircle,
                                    color: Colors.red,
                                  ),
                          ),
                          onChanged: (value) {
                            context.read<ManualBloc>().add(
                              NameChanged(name: value),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    initialValue: state.issuer,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Account issuer',
                      errorText: state.issuerError,
                      hintText: 'e.g. Google/Facebook/Github',
                      suffixIcon: state.issuerError == null
                          ? const PhosphorIcon(PhosphorIconsRegular.building)
                          : const PhosphorIcon(
                              PhosphorIconsRegular.warningCircle,
                              color: Colors.red,
                            ),
                    ),
                    onChanged: (value) {
                      context.read<ManualBloc>().add(
                        IssuerChanged(issuer: value),
                      );
                    },
                  ),
                ),
                if (!state.isSharedAccount) ...[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: TextFormField(
                      initialValue: state.secretKey,
                      readOnly: state.isEdit,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: 'Secret key',
                        errorText: state.secretKeyError,
                        suffixIcon: state.secretKeyError == null
                            ? const PhosphorIcon(PhosphorIconsRegular.key)
                            : const PhosphorIcon(
                                PhosphorIconsRegular.warningCircle,
                                color: Colors.red,
                              ),
                      ),
                      onChanged: (value) {
                        context.read<ManualBloc>().add(
                          SecretKeyChanged(secretKey: value),
                        );
                      },
                      onTap: () {
                        if (state.isEdit) {
                          Clipboard.setData(
                            ClipboardData(text: state.secretKey),
                          );
                          getIt<SnackbarService>().showMessage(
                            'Secrey key copied',
                          );
                        }
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: DropdownButtonFormField2(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Type of code',
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            value: state.codeTypeValue,
                            items: [
                              DropdownMenuItem(
                                value: OtpType.totp.value,
                                child: const Text('Time based (TOTP)'),
                              ),
                              DropdownMenuItem(
                                value: OtpType.hotp.value,
                                child: const Text('Counter based (HOTP)'),
                              ),
                            ],
                            onChanged: (String? value) {
                              value == OtpType.hotp.value
                                  ? animationController.forward()
                                  : animationController.reverse();
                              context.read<ManualBloc>().add(
                                CodeTypeValueChanged(codeTypeValue: value!),
                              );
                            },
                          ),
                        ),
                      ),
                      if (animation != 0)
                        Expanded(
                          flex: animation,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              0,
                              15.0,
                              15.0,
                              15.0,
                            ),
                            child: DropdownButtonFormField2(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Interval',
                              ),
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                              ),
                              value: state.intervalValue,
                              items: [
                                DropdownMenuItem(
                                  value: OtpPeriod.p30.value,
                                  child: const Text('30s'),
                                ),
                                DropdownMenuItem(
                                  value: OtpPeriod.p45.value,
                                  child: const Text('45s'),
                                ),
                                DropdownMenuItem(
                                  value: OtpPeriod.p60.value,
                                  child: const Text('60s'),
                                ),
                              ],
                              onChanged: (int? value) {
                                if (value == null) return;
                                context.read<ManualBloc>().add(
                                  IntervalValueChanged(intervalValue: value),
                                );
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
                          padding: const EdgeInsets.fromLTRB(
                            15.0,
                            15.0,
                            0,
                            15.0,
                          ),
                          child: DropdownButtonFormField2(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Algorithm',
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            value: state.algorithmValue,
                            items: [
                              DropdownMenuItem(
                                value: OtpAlgorithm.sha1.value,
                                child: const Text('SHA1'),
                              ),
                              DropdownMenuItem(
                                value: OtpAlgorithm.sha256.value,
                                child: const Text('SHA256'),
                              ),
                              DropdownMenuItem(
                                value: OtpAlgorithm.sha512.value,
                                child: const Text('SHA512'),
                              ),
                            ],
                            onChanged: (String? value) {
                              context.read<ManualBloc>().add(
                                AlgorithmValueChanged(algorithmValue: value!),
                              );
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
                              labelText: 'Digits',
                            ),
                            dropdownStyleData: DropdownStyleData(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                            ),
                            value: state.digitsValue,
                            items: [
                              DropdownMenuItem(
                                value: OtpDigits.d4.value,
                                child: const Text('4'),
                              ),
                              DropdownMenuItem(
                                value: OtpDigits.d6.value,
                                child: const Text('6'),
                              ),
                            ],
                            onChanged: (int? value) {
                              if (value == null) return;
                              context.read<ManualBloc>().add(
                                DigitsValueChanged(digitsValue: value),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: context.read<ManualBloc>().state.isEdit
            ? const PhosphorIcon(
                PhosphorIconsRegular.check,
                color: Colors.white,
              )
            : const PhosphorIcon(
                PhosphorIconsRegular.plus,
                color: Colors.white,
              ),
        onPressed: () => context.read<ManualBloc>().add(AddOrEditAccount()),
      ),
    );
  }
}
