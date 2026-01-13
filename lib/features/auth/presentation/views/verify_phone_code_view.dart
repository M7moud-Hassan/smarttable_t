import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/features/auth/providers/auth_provider.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/providers/request_response_provider.dart';
import 'signup_view.dart';

class PhoneOtpVerifyView extends HookConsumerWidget {
  final String phone;

  const PhoneOtpVerifyView({
    super.key,
    required this.phone,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c1 = useTextEditingController();
    final c2 = useTextEditingController();
    final c3 = useTextEditingController();
    final c4 = useTextEditingController();

    final f1 = useFocusNode();
    final f2 = useFocusNode();
    final f3 = useFocusNode();
    final f4 = useFocusNode();

    String getOtp() => c1.text + c2.text + c3.text + c4.text;

    void submitIfComplete() {
      if (getOtp().length == 4) {
        ref.read(authProvider.notifier).verifyOtp(phone, getOtp());
      }
    }

    // Resend timer state: counts down from 60 and disables resend until 0
    final secondsLeft = useState<int>(60);
    final timerRef = useRef<Timer?>(null);

    void startResendTimer() {
      timerRef.value?.cancel();
      secondsLeft.value = 60;
      timerRef.value = Timer.periodic(const Duration(seconds: 1), (t) {
        if (secondsLeft.value > 0) {
          secondsLeft.value = secondsLeft.value - 1;
        } else {
          t.cancel();
        }
      });
    }

    useEffect(() {
      // start countdown on enter
      startResendTimer();
      return () {
        timerRef.value?.cancel();
      };
    }, const []);

    Widget otpBox({
      required TextEditingController controller,
      required FocusNode focusNode,
      FocusNode? next,
      FocusNode? previous,
    }) {
      return SizedBox(
        width: 60,
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: context.textTheme.titleLarge,
          decoration: const InputDecoration(
            counterText: '',
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) {
            if (value.isNotEmpty && next != null) {
              next.requestFocus();
            } else if (value.isEmpty && previous != null) {
              previous.requestFocus();
            }
            submitIfComplete();
          },
        ),
      );
    }

    ref.listen(
      requestResponseProvider,
      (_, state) {
        if (state.state == RequestResponseState.success &&
            state.actionOnDone == ActionOnDone.goRegisterData) {
          context.showSnackbarSuccess(context.locale.sucessMessage);
          context.pushReplacement(SignupView(
            phone: phone,
            usercode: null,
          ));
        }
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(context.locale.back),
      ),
      body: Padding(
        padding: pgHorizontalPadding18,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      const SizedBox(height: 40),
                      Text(
                        context.locale.verifyPhone,
                        style: context.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${context.locale.enterOtpSentTo} $phone',
                        style: context.textTheme.bodyLarge!
                            .copyWith(color: AppColors.textGrayColor),
                      ),
                      const SizedBox(height: 30),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            otpBox(
                              controller: c1,
                              focusNode: f1,
                              next: f2,
                            ),
                            otpBox(
                              controller: c2,
                              focusNode: f2,
                              next: f3,
                              previous: f1,
                            ),
                            otpBox(
                              controller: c3,
                              focusNode: f3,
                              next: f4,
                              previous: f2,
                            ),
                            otpBox(
                              controller: c4,
                              focusNode: f4,
                              previous: f3,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: secondsLeft.value == 0
                                ? AppColors.primaryColor
                                : AppColors.textGrayColor,
                          ),
                          onPressed: secondsLeft.value == 0
                              ? () async {
                                  // reuse the same method to request OTP
                                  await ref
                                      .read(authProvider.notifier)
                                      .phoneRegisterTeacher(phone);
                                  startResendTimer();
                                }
                              : null,
                          child: secondsLeft.value == 0
                              ? Text(context.locale.resend)
                              : Text(context.locale
                                  .resendInSeconds(secondsLeft.value)),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: ElevatedButton(
                          onPressed: () {
                            if (getOtp().length == 4) {
                              ref
                                  .read(authProvider.notifier)
                                  .verifyOtp(phone, getOtp());
                            } else {
                              context.showSnackbarError(
                                context.locale.invalidOtp,
                              );
                            }
                          },
                          child: Text(context.locale.verify),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
