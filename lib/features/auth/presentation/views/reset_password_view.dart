import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/layout_constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/features/auth/presentation/views/reset_password_sucess_view.dart';
import 'package:smart_table_app/features/auth/providers/auth_provider.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/models/models.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/widgets/app_text_field.dart';

class ResetPasswordView extends HookConsumerWidget {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    ref.listen(
      requestResponseProvider,
      (_, state) {
        if (state.state == RequestResponseState.success) {
          context.pushReplacement(const ResetPasswordSucessView());
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
                      const SizedBox(
                        height: 40,
                      ),
                      Text(context.locale.resetPasswordTitle,
                          style: context.textTheme.titleLarge),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        context.locale.resetPasswordDesc,
                        style: context.textTheme.bodyLarge!
                            .copyWith(color: AppColors.textGrayColor),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      AppTextField(
                        controller: emailController,
                        hintText: context.locale.email,
                        icon: SvgAssets.email,
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              ref
                                  .read(authProvider.notifier)
                                  .resetPassword(emailController.text);
                            }
                          },
                          child: Text(
                            context.locale.send,
                          ),
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
