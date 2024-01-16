import 'package:flutter/material.dart';
import 'package:flutter_animated_icon_button/animate_change_icon.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/home/home_state.dart';

class HomeAppBar extends HookWidget implements PreferredSizeWidget {
  const HomeAppBar({Key? key}) : super(key: key);

  Icon _getSortIcon(
      bool? sortedByNameDesc, bool? sortedByIssuerDesc, bool? sortedByIdDesc) {
    if (sortedByNameDesc != null) {
      if (sortedByNameDesc) {
        return Icon(MdiIcons.sortAlphabeticalDescending);
      } else {
        return Icon(MdiIcons.sortAlphabeticalAscending);
      }
    } else if (sortedByIssuerDesc != null) {
      if (sortedByIssuerDesc) {
        return Icon(MdiIcons.orderAlphabeticalDescending);
      } else {
        return Icon(MdiIcons.orderAlphabeticalAscending);
      }
    } else if (sortedByIdDesc != null) {
      if (sortedByIdDesc) {
        return Icon(MdiIcons.sortCalendarDescending);
      } else {
        return Icon(MdiIcons.sortCalendarAscending);
      }
    } else {
      return const Icon(Icons.sort);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textFieldSearchBarController = useTextEditingController();

    final showSearchBar = useState(false);
    final searchBarAnimationEnd = useState(true);
    final searchBarNode = useFocusNode();

    return AppBar(
      title: Row(
        children: [
          if (!showSearchBar.value && searchBarAnimationEnd.value) ...[
            const Text("OTP Manager"),
            Padding(
              padding: const EdgeInsets.only(left: 10),
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
                              color: Colors.green,
                            )
                          : const Icon(
                              Icons.cloud_sync,
                              color: Colors.amberAccent,
                            );
                },
              ),
            ),
          ]
        ],
      ),
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: showSearchBar.value ? 15 : 5),
          child: AnimateChangeIcon(
            animateDuration: const Duration(milliseconds: 200),
            secondIcon: const Icon(Icons.search),
            firstIcon: const Icon(Icons.arrow_back),
            onTap: () {
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
          ),
        ),
        AnimatedContainer(
          onEnd: () {
            searchBarAnimationEnd.value = true;
            searchBarNode.requestFocus();
          },
          duration: const Duration(milliseconds: 200),
          width:
              showSearchBar.value ? MediaQuery.of(context).size.width - 100 : 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
                focusNode: searchBarNode,
                enabled: showSearchBar.value,
                controller: textFieldSearchBarController,
                decoration: const InputDecoration(hintText: 'Search'),
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
            return PopupMenuButton(
              itemBuilder: (context) {
                return [
                  PopupMenuItem<Function>(
                    value: () => context.read<HomeBloc>().add(SortByName()),
                    child: Row(
                      children: [
                        const Text("By Name"),
                        Text(
                          state.sortedByNameDesc == null ||
                                  state.sortedByNameDesc == true
                              ? " (A -> Z)"
                              : " (Z -> A)",
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
                          state.sortedByIssuerDesc == null ||
                                  state.sortedByIssuerDesc == true
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
                          state.sortedByIdDesc == null ||
                                  state.sortedByIdDesc == true
                              ? " (most recent)"
                              : " (most remote)",
                        ),
                      ],
                    ),
                  ),
                ];
              },
              onSelected: (Function value) => value(),
              icon: _getSortIcon(state.sortedByNameDesc,
                  state.sortedByIssuerDesc, state.sortedByIdDesc),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(3.0)),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
