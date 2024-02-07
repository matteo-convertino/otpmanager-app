import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:otp_manager/bloc/icon_picker/icon_picker_bloc.dart';
import 'package:otp_manager/bloc/icon_picker/icon_picker_event.dart';
import 'package:otp_manager/bloc/icon_picker/icon_picker_state.dart';

class IconPicker extends HookWidget {
  const IconPicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IconPickerBloc, IconPickerState>(
      builder: (context, state) {
        return SizedBox(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: Text('Pick an icon', style: TextStyle(fontSize: 20)),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                  right: 15.0,
                  bottom: 20.0,
                  left: 15.0,
                ),
                child: TextFormField(
                  initialValue: state.searchBarValue,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    labelText: "Search",
                  ),
                  onChanged: (value) {
                    context
                        .read<IconPickerBloc>()
                        .add(SearchBarValueChanged(value: value));
                  },
                ),
              ),
              if (state.searchBarValue == "" && state.iconsBestMatch.isNotEmpty) ...[
                const Text(
                  'Best match based on issuer',
                  style: TextStyle(fontSize: 18),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: GridView.builder(
                    scrollDirection: Axis.vertical,
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                    ),
                    shrinkWrap: true,
                    itemCount: state.iconsBestMatch.length,
                    itemBuilder: (BuildContext context, int index) {
                      String key = state.iconsBestMatch.keys.elementAt(index);
                      Icon icon = state.iconsBestMatch[key]!;

                      return InkWell(
                        onTap: () => Navigator.pop(context, key),
                        child: Tooltip(
                          triggerMode: TooltipTriggerMode.longPress,
                          message: key,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              icon,
                              Positioned(
                                bottom: 5,
                                width: 70,
                                child: Text(
                                  key.substring(0, 1).toUpperCase() +
                                      key.substring(1),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Text(
                  "All icons",
                  style: TextStyle(fontSize: 18),
                ),
              ],
              Expanded(
                child: GridView.builder(
                  scrollDirection: Axis.vertical,
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                  ),
                  shrinkWrap: true,
                  itemCount: state.icons.length,
                  itemBuilder: (BuildContext context, int index) {
                    String key = state.icons.keys.elementAt(index);
                    Icon icon = state.icons[key]!;

                    return InkWell(
                      onTap: () => Navigator.pop(context, key),
                      child: Tooltip(
                        triggerMode: TooltipTriggerMode.longPress,
                        message: key,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            icon,
                            Positioned(
                              bottom: 5,
                              width: 70,
                              child: Text(
                                key.substring(0, 1).toUpperCase() +
                                    key.substring(1),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 12,

                                  //fontStyle: FontStyle.italic
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
