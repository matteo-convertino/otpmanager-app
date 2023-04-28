import 'package:flutter/material.dart';

import "../routing/constants.dart";
import '../routing/navigation_service.dart';
import '../utils/store_new_user.dart';

class Login extends StatefulWidget {
  Login({Key? key, required this.error}) : super(key: key);

  String error;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _urlTextFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Stack(
        alignment: Alignment.center,
        children: [
          const Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 250),
              child: Icon(
                Icons.language,
                size: 150,
                color: Colors.white,
              )),
          Column(
            //crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: TextField(
                  controller: _urlTextFieldController,
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  onChanged: (text) {
                    setState(() {
                      widget.error = "";
                    });
                  },
                  decoration: InputDecoration(
                    //filled: true,
                    enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1)),
                    focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 1)),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    labelStyle: const TextStyle(color: Colors.white),
                    hintStyle: const TextStyle(color: Colors.white),
                    labelText: 'Type the server URL',
                    hintText: 'https://www.example.com',
                    suffixIcon: IconButton(
                      splashRadius: 20,
                      onPressed: () {
                        var url =
                            Uri.parse(_urlTextFieldController.text.trim());
                        if (url.toString() == "http://localhost") {
                          storeNewUser(
                            context: context,
                            url: url.toString(),
                            appPassword: "test",
                            isGuest: true,
                          );
                          NavigationService().resetToScreen(homeRoute);
                        } else {
                          try {
                            NavigationService().navigateTo(webViewerRoute,
                                arguments: url.origin);
                          } catch (error) {
                            setState(() {
                              widget.error = "The URL entered is not valid!";
                            });
                          }
                        }
                      },
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
          if (widget.error != "")
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 150, 0, 0),
              child: Text(
                widget.error,
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
