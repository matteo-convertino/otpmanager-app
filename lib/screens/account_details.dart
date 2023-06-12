import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:otp_manager/bloc/account_details/account_details_bloc.dart';
import 'package:otp_manager/bloc/account_details/account_details_state.dart';
import 'package:otp_manager/utils/show_snackbar.dart';

import '../bloc/account_details/account_details_event.dart';
import "../routing/constants.dart";
import '../routing/navigation_service.dart';
import '../utils/delete_modal.dart';

class AccountDetails extends StatelessWidget {
  const AccountDetails({Key? key}) : super(key: key);

  ListTile newItem(String title, String trailingText) {
    return ListTile(
      title: Text(title),
      trailing: Text(
        trailingText,
        style: const TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Account details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              if (context.read<AccountDetailsBloc>().state.pin == "") {
                showSnackBar(
                    context: context,
                    msg: "To edit an account you have to set a pin before");
              } else {
                NavigationService()
                    .navigateTo(manualRoute, arguments: {"account": context.read<AccountDetailsBloc>().state.account});
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDeleteModal(
                context,
                context.read<AccountDetailsBloc>().state.account,
                () => context
                    .read<AccountDetailsBloc>()
                    .add(DeleteAccount()),
              );
            },
          )
        ],
      ),
      body: BlocConsumer<AccountDetailsBloc, AccountDetailsState>(
        listener: (context, state) {
          if (state.accountDeleted != "") {
            showSnackBar(context: context, msg: state.accountDeleted);
          }
        },
        builder: (context, state) {
          return Center(
            child: ListView(
              children: ListTile.divideTiles(
                context: context,
                tiles: [
                  newItem("Name", state.account.name),
                  newItem("Issuer", state.account.issuer ?? ""),
                  newItem("Period", "${state.account.period}s"),
                  newItem("Digits", state.account.digits.toString()),
                  newItem(
                      "Algorithm", state.account.algorithm.toString().split(".")[1]),
                  newItem("Type", state.account.type.toUpperCase()),
                  if (state.account.type == "hotp")
                    newItem(
                        "Counter",
                        state.account.counter != null
                            ? state.account.counter.toString()
                            : "")
                ],
              ).toList(),
            ),
          );
        },
      ),
    );
  }
}
