import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:otp_manager/bloc/otp_account/otp_account_bloc.dart';
import 'package:otp_manager/bloc/otp_account/otp_account_state.dart';
import 'package:otp_manager/bloc/otp_manager/otp_manager_bloc.dart';
import 'package:spoiler_widget/models/spoiler_configs.dart';
import 'package:spoiler_widget/models/text_spoiler_configs.dart';
import 'package:spoiler_widget/spoiler_text_wrapper.dart';

class OtpAccountCode extends HookWidget {
  const OtpAccountCode({
    super.key,
    required this.account,
    required this.blurredCode,
  });

  final dynamic account; // Account | SharedAccount
  final ValueNotifier<bool> blurredCode;

  @override
  Widget build(BuildContext context) {
    final clickToRevealCodes = context.select(
      (OtpManagerBloc bloc) => bloc.state.clickToRevealCodes,
    );

    return BlocBuilder<OtpAccountBloc, OtpAccountState>(
      builder: (context, state) {
        final otpCode = Text(
          state.otpMessage ?? state.otpCode ?? '- ' * account.digits!,
          style: TextStyle(
            fontSize: state.otpMessage == null ? 28 : 14,
            color: Theme.of(context).colorScheme.primary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );

        return clickToRevealCodes && state.otpMessage == null
            ? SpoilerTextWrapper(
                config: TextSpoilerConfig(
                  enableGestureReveal: true,
                  fadeConfig: const FadeConfig(padding: 0, edgeThickness: 0),
                  particleConfig: ParticleConfig(
                    density: 1,
                    speed: 0.2,
                    color: Theme.of(context).colorScheme.primary,
                    maxParticleSize: 1.5,
                  ),
                ),
                resetSpoilerAfter: const Duration(seconds: 2),
                child: otpCode,
              )
            : otpCode;
      },
    );
  }
}
