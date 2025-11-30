import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/utils/utils.dart';
import 'package:smart_table_app/features/auth/providers/auth_provider.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../home/providers/home_menu_provider.dart';
import '../../../layout/views/main_layout_view.dart';
import '../../../profile/providers/profile_provider.dart';

class SignupView extends HookConsumerWidget with ValidationMixin {
  const SignupView({super.key, required this.usercode, required this.phone});
  final String? usercode;
  final String? phone;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usernameCon = useTextEditingController();
    final emailCon = useTextEditingController();
    final passwordCon = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    ref.listen(
      requestResponseProvider,
      (_, state) {
        if (state.state == RequestResponseState.success) {
          if (state.actionOnDone == ActionOnDone.registerSucess) {
            context.showSnackbarSuccess(context.locale.sucessMessage);
            context.showSnackbarSuccess(context.locale.sucessMessage);
            ref.invalidate(homeMenuProvider);
            ref.invalidate(profileProvider);
            context.pushAndRemoveOthers(const MainLayoutView());
          }
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
                      const SizedBox(
                        height: 40,
                      ),
                      Text(
                          phone == null
                              ? context.locale.signUpTitleId
                              : context.locale.signUpTitlePhone,
                          style: context.textTheme.titleLarge),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        context.locale.signUpDesc,
                        style: context.textTheme.bodyLarge!
                            .copyWith(color: AppColors.textGrayColor),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      AppTextField(
                        controller: usernameCon,
                        hintText: context.locale.username,
                        icon: SvgAssets.user,
                        validator: (username) =>
                            emptyValidation(username, context),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      AppTextField(
                        controller: passwordCon,
                        hintText: context.locale.password,
                        icon: SvgAssets.lock,
                        obscureText: true,
                        validator: (password) =>
                            passwordValidation(password, context),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      AppTextField(
                        controller: emailCon,
                        hintText: context.locale.email,
                        icon: SvgAssets.email,
                        validator: (email) => emailValidation(email, context),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              if (usercode != null) {
                                ref.read(authProvider.notifier).registerTeacher(
                                      usercode!,
                                      usernameCon.text,
                                      passwordCon.text,
                                      emailCon.text,
                                    );
                              } else {
                                ref
                                    .read(authProvider.notifier)
                                    .registerTeacherByPhone(
                                      phone!,
                                      usernameCon.text,
                                      passwordCon.text,
                                      emailCon.text,
                                    );
                              }
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
