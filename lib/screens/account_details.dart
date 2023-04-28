import 'package:flutter/material.dart';

import '../main.dart' show objectBox;
import '../models/account.dart';
import '../models/user.dart';
import '../object_box/objectbox.g.dart';
import "../routing/constants.dart";
import '../routing/navigation_service.dart';
import '../utils/delete_modal.dart';
import '../utils/nextcloud.dart';
import '../utils/toast.dart';

class AccountDetails extends StatelessWidget {
  AccountDetails({Key? key, required this.account}) : super(key: key);

  final Account account;

  final NavigationService navigationService = NavigationService();

  final User _user = objectBox.store.box<User>().getAll()[0];

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
              if (_user.pin == null || _user.pin == "") {
                showToast("To edit an account you have to set a pin before");
              } else {
                NavigationService()
                    .navigateTo(manualRoute, arguments: {"account": account});
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDeleteModal(context, account, () {
                var box = objectBox.store.box<Account>();
                Account? accountToRemove = box
                    .query(Account_.id.equals(account.id))
                    .build()
                    .findFirst();
                accountToRemove?.deleted = true;

                box
                    .query(Account_.deleted.equals(false) &
                        Account_.position
                            .greaterThan(accountToRemove?.position ?? 0))
                    .build()
                    .find()
                    .forEach((account) {
                  account.position = account.position! - 1;
                  account.toUpdate = true;
                  box.put(account);
                });

                accountToRemove?.position = null;
                box.put(accountToRemove!);

                Nextcloud(user: objectBox.store.box<User>().getAll()[0]).sync();
                showToast(
                    "${account.type == "totp" ? "TOTP" : "HOTP"} has been removed");
                navigationService.resetToScreen(homeRoute);
              });
            },
          )
        ],
      ),
      body: Center(
        child: ListView(
          children: ListTile.divideTiles(
            context: context,
            tiles: [
              newItem("Name", account.name),
              newItem("Issuer", account.issuer ?? ""),
              newItem("Period", "${account.period}s"),
              newItem("Digits", account.digits.toString()),
              newItem("Algorithm", account.algorithm.toString().split(".")[1]),
              newItem("Type", account.type.toUpperCase()),
              if (account.type == "hotp")
                newItem("Counter",
                    account.counter != null ? account.counter.toString() : "")
            ],
          ).toList(),
        ),
      ),
    );
  }
}
