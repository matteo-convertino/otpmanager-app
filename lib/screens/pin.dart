import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:otp_manager/bloc/pin/pin_event.dart';
import 'package:otp_manager/utils/show_snackbar.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../bloc/pin/pin_bloc.dart';
import '../bloc/pin/pin_state.dart';
import "../utils/pin.dart";

class Pin extends HookWidget {
  const Pin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pinTextFieldController = useTextEditingController();
    final errorController = useStreamController<ErrorAnimationType>();

    return Scaffold(
      appBar: AppBar(
        title: Text(context.read<PinBloc>().title),
      ),
      body: BlocConsumer<PinBloc, PinState>(
        listener: (context, state) {
          if (state.message != "") {
            showSnackBar(context: context, msg: state.message);
          } else if (state.isError) {
            pinTextFieldController.clear();
            errorController.add(ErrorAnimationType.shake);
          }
        },
        builder: (context, state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: pin(
                context: context,
                onCompleted: (pin) =>
                    context.read<PinBloc>().add(PinSubmit(pin: pin)),
                textFieldController: pinTextFieldController,
                errorController: errorController,
              ),
            ),
          );
        },
      ),
    );
  }
}
