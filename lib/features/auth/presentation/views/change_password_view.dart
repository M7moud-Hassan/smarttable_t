import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/constants/constants.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/utils/utils.dart';
import 'package:smart_table_app/core/widgets/app_text_field.dart';
import 'package:smart_table_app/features/auth/providers/auth_provider.dart';

class ChangePasswordView extends HookConsumerWidget with ValidationMixin {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPasswordController = useTextEditingController();
    final newPasswordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.locale.changePassword),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: pgHorizontalPadding18,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        AppTextField(
                          controller: currentPasswordController,
                          hintText: context.locale.currentPassword,
                          label: context.locale.currentPassword,
                          icon: SvgAssets.lock,
                          obscureText: true,
                          validator: (password) =>
                              passwordValidation(password, context),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: newPasswordController,
                          hintText: context.locale.newPassword,
                          label: context.locale.newPassword,
                          icon: SvgAssets.lock,
                          obscureText: true,
                          validator: (password) =>
                              passwordValidation(password, context),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: confirmPasswordController,
                          hintText: context.locale.confirmNewPassword,
                          label: context.locale.confirmNewPassword,
                          icon: SvgAssets.lock,
                          obscureText: true,
                          validator: (password) =>
                              passwordConfirmationValidation(
                            password,
                            newPasswordController.text,
                            context,
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: ElevatedButton(
                            onPressed: () {
                              if (!(formKey.currentState?.validate() ??
                                  false)) {
                                return;
                              }

                              ref.read(authProvider.notifier).changePassword(
                                    currentPassword:
                                        currentPasswordController.text,
                                    newPassword: newPasswordController.text,
                                    confirmPassword:
                                        confirmPasswordController.text,
                                  );
                            },
                            child: Text(context.locale.changePassword),
                          ),
                        ),
                      ],
                    ),
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
