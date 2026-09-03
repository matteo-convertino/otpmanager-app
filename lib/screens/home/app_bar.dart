import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_bloc.dart';
import 'package:otp_manager/utils/sync_status.dart';
import 'package:otp_manager/widgets/otp_manager_animate_change_icon.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/home/home_state.dart';

class HomeAppBar extends HookWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  Widget _getSortIcon(
    bool? sortedByNameDesc,
    bool? sortedByIssuerDesc,
    bool? sortedByIdDesc,
  ) {
    if (sortedByNameDesc != null) {
      return PhosphorIcon(
        sortedByNameDesc
            ? PhosphorIconsRegular.sortDescending
            : PhosphorIconsRegular.sortAscending,
      );
    }

    if (sortedByIssuerDesc != null) {
      return Row(
        crossAxisAlignment: sortedByIssuerDesc
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          const PhosphorIcon(PhosphorIconsRegular.building),
          PhosphorIcon(
            sortedByIssuerDesc
                ? PhosphorIconsRegular.arrowUp
                : PhosphorIconsRegular.arrowDown,
            size: 14,
          ),
        ],
      );
    }

    if (sortedByIdDesc != null) {
      return Row(
        crossAxisAlignment: sortedByIdDesc
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          const PhosphorIcon(PhosphorIconsRegular.calendarBlank),
          PhosphorIcon(
            sortedByIdDesc
                ? PhosphorIconsRegular.arrowUp
                : PhosphorIconsRegular.arrowDown,
            size: 14,
          ),
        ],
      );
    }

    return const PhosphorIcon(PhosphorIconsRegular.funnel);
  }

  @override
  Widget build(BuildContext context) {
    final textFieldSearchBarController = useTextEditingController();

    final showSearchBar = useState(false);
    final searchBarAnimationEnd = useState(true);
    final searchBarNode = useFocusNode();

    final openSearchBarOnStartup = context
        .read<OtpManagerBloc>()
        .state
        .openSearchBarOnStartup;

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (openSearchBarOnStartup) {
          searchBarAnimationEnd.value = false;
          showSearchBar.value = true;
        }
      });

      return null;
    }, const []);

    return AppBar(
      title: Row(
        children: [
          if (!showSearchBar.value && searchBarAnimationEnd.value) ...[
            const Text('OTP Manager'),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) => switch (state.syncStatus) {
                  SyncStatus.success => const PhosphorIcon(
                    PhosphorIconsRegular.cloudCheck,
                    color: Colors.green,
                  ),
                  SyncStatus.error => const PhosphorIcon(
                    PhosphorIconsRegular.cloudSlash,
                    color: Colors.redAccent,
                  ),
                  SyncStatus.loading => const PhosphorIcon(
                    PhosphorIconsRegular.cloudArrowUp,
                    color: Colors.amberAccent,
                  ),
                },
              ),
            ),
          ],
        ],
      ),
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: showSearchBar.value ? 15 : 5),
          child: OtpManagerAnimateChangeIcon(
            animateDuration: const Duration(milliseconds: 200),
            icons: const [
              PhosphorIcon(PhosphorIconsRegular.magnifyingGlass),
              PhosphorIcon(PhosphorIconsRegular.arrowLeft),
            ],
            initialIndex: openSearchBarOnStartup ? 1 : 0,
            onTap: (_) {
              if (searchBarAnimationEnd.value) {
                searchBarAnimationEnd.value = false;
                showSearchBar.value = !showSearchBar.value;
                if (!showSearchBar.value) {
                  context.read<HomeBloc>().add(
                    const SearchBarValueChanged(value: ''),
                  );
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
          width: showSearchBar.value
              ? MediaQuery.of(context).size.width - 100
              : 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextFormField(
              focusNode: searchBarNode,
              enabled: showSearchBar.value,
              controller: textFieldSearchBarController,
              decoration: const InputDecoration(hintText: 'Search'),
              onChanged: (value) {
                context.read<HomeBloc>().add(
                  SearchBarValueChanged(value: value),
                );
                context.read<HomeBloc>().add(GetAccounts());
              },
            ),
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
                        const Text('By Name'),
                        Text(
                          state.sortedByNameDesc == null ||
                                  state.sortedByNameDesc == true
                              ? ' (A -> Z)'
                              : ' (Z -> A)',
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<Function>(
                    value: () => context.read<HomeBloc>().add(SortByIssuer()),
                    child: Row(
                      children: [
                        const Text('By Issuer'),
                        Text(
                          state.sortedByIssuerDesc == null ||
                                  state.sortedByIssuerDesc == true
                              ? ' (A -> Z)'
                              : ' (Z -> A)',
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem<Function>(
                    value: () => context.read<HomeBloc>().add(SortById()),
                    child: Row(
                      children: [
                        const Text('By Date'),
                        Text(
                          state.sortedByIdDesc == null ||
                                  state.sortedByIdDesc == true
                              ? ' (most recent)'
                              : ' (most remote)',
                        ),
                      ],
                    ),
                  ),
                ];
              },
              onSelected: (Function value) => value(),
              icon: _getSortIcon(
                state.sortedByNameDesc,
                state.sortedByIssuerDesc,
                state.sortedByIdDesc,
              ),
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
