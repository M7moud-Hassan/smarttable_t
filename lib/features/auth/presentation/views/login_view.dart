import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/utils/utils.dart';
import 'package:smart_table_app/core/widgets/app_text_field.dart';
import 'package:smart_table_app/features/auth/presentation/views/id_code_register_view.dart';
import 'package:smart_table_app/features/auth/presentation/views/phone_register_view.dart';
import 'package:smart_table_app/features/auth/presentation/views/reset_password_view.dart';
import 'package:smart_table_app/features/auth/providers/auth_provider.dart';
import 'package:smart_table_app/features/layout/views/main_layout_view.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/providers/providers.dart';
import '../../../home/providers/home_menu_provider.dart';
import '../../../profile/providers/profile_provider.dart';

class LoginView extends HookConsumerWidget with ValidationMixin {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    ref.listen(
      requestResponseProvider,
      (_, state) async {
        if (state.state == RequestResponseState.success) {
          if (state.actionOnDone == ActionOnDone.loginSucess) {
            {
              context.showSnackbarSuccess(context.locale.sucessMessage);
              ref.invalidate(homeMenuProvider);
              ref.invalidate(profileProvider);
              //
              context.pushAndRemoveOthers(const MainLayoutView(
                requestFcm: true,
              ));
            }
          }
        }
      },
    );
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: pgHorizontalPadding18,
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Image.asset(
                    PngAssets.splashLogo,
                    width: 300,
                  ),
                ),
                Text(
                  context.locale.wellcome,
                  style: context.textTheme.titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  context.locale.loginDesc,
                  style: context.textTheme.bodyLarge!
                      .copyWith(color: AppColors.textGrayColor),
                ),
                const SizedBox(height: 20),
                Text(
                  context.locale.teacherLogin,
                  style: context.textTheme.titleLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 20,
                ),
                AppTextField(
                  controller: usernameController,
                  hintText: context.locale.username,
                  icon: SvgAssets.user,
                  validator: (username) => emptyValidation(username, context),
                ),
                const SizedBox(
                  height: 15,
                ),
                AppTextField(
                  controller: passwordController,
                  hintText: context.locale.passwordCode,
                  icon: SvgAssets.lock,
                  validator: (password) =>
                      passwordValidation(password, context),
                  obscureText: true,
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  context.locale.termsConditionsText,
                  style: context.textTheme.bodyLarge!
                      .copyWith(color: AppColors.textGrayColor),
                ),
                const SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        ref.read(authProvider.notifier).loginTeacher(
                            usernameController.text, passwordController.text);
                      }
                    },
                    child: Text(context.locale.login)),
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.push(const IdCodeRegisterView());
                    },
                    child: Text(
                      context.locale.loginFirstTime,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.push(const PhoneRegisterView());
                    },
                    child: Text(
                      context.locale.loginFirstTimePhone,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: TextButton(
                    onPressed: () {
                      context.push(const ResetPasswordView());
                    },
                    child: Text(
                      context.locale.forgetPassword,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
