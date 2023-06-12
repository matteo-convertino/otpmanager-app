import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:otp_manager/bloc/login/login_bloc.dart';
import 'package:otp_manager/bloc/login/login_event.dart';

import '../bloc/login/login_state.dart';
import '../utils/show_snackbar.dart';

class Login extends HookWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state.error != "") {
            showSnackBar(
              context: context,
              msg: state.error,
            );
          }
        },
        builder: (context, state) {
          return Stack(
            alignment: Alignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 250),
                child: Icon(
                  Icons.language,
                  size: 150,
                  color: Colors.white,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      onChanged: (value) {
                        context.read<LoginBloc>().add(UrlChanged(url: value));
                      },
                      decoration: InputDecoration(
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white, width: 1),
                        ),
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: const TextStyle(color: Colors.white),
                        hintStyle: const TextStyle(color: Colors.white),
                        labelText: 'Type the server URL',
                        hintText: 'https://www.example.com',
                        suffixIcon: IconButton(
                          splashRadius: 20,
                          onPressed: () =>
                              context.read<LoginBloc>().add(UrlSubmit()),
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
