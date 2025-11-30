import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/utils/utils.dart';
import 'package:smart_table_app/core/widgets/phone_filed.dart';
import 'package:smart_table_app/features/auth/presentation/views/signup_view.dart';
import 'package:smart_table_app/features/auth/providers/auth_provider.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/providers/providers.dart';

class PhoneRegisterView extends HookConsumerWidget with ValidationMixin {
  const PhoneRegisterView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    final countryCode = useState("+966");
    final phoneParsed = useState("");

    ref.listen(
      requestResponseProvider,
      (_, state) {
        if (state.state == RequestResponseState.success &&
            state.actionOnDone == ActionOnDone.goRegisterData) {
          context.showSnackbarSuccess(context.locale.sucessMessage);
          final fullPhone = "${countryCode.value}${phoneParsed.value}";
          context.push(SignupView(
            phone: fullPhone,
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
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      const SizedBox(height: 40),
                      Text(context.locale.phoneNumber,
                          style: context.textTheme.titleLarge),
                      const SizedBox(height: 10),
                      Text(
                        context.locale.enterPhoneConnectedWithAccounr,
                        style: context.textTheme.bodyLarge!
                            .copyWith(color: AppColors.textGrayColor),
                      ),
                      const SizedBox(height: 30),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: PhoneField(
                          controller: phoneController,
                          onChanged: (code, phone) {
                            countryCode.value = code;
                            phoneParsed.value = phone;
                          },
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final fullPhone =
                                  "${countryCode.value}${phoneParsed.value}";
                              ref
                                  .read(authProvider.notifier)
                                  .phoneRegisterTeacher(fullPhone);
                            }
                          },
                          child: Text(context.locale.send),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
