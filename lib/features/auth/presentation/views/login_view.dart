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
import 'package:svg_flutter/svg_flutter.dart';

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
    final rememberMe = useState(false);
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);

    ref.listen(
      requestResponseProvider,
      (_, state) async {
        if (state.state == RequestResponseState.success) {
          if (state.actionOnDone == ActionOnDone.loginSucess) {
            context.showSnackbarSuccess(context.locale.sucessMessage);
            ref.invalidate(homeMenuProvider);
            ref.invalidate(profileProvider);

            context.pushAndRemoveOthers(
              const MainLayoutView(requestFcm: true),
            );
          }
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Image.asset(
            PngAssets.logoText,
            height: 40,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: pgHorizontalPadding18,
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Image.asset(
                    PngAssets.teacher,
                    height: 80,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      context.locale.teacherApp,
                      style: context.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  context.locale.teacherLogin,
                  style: context.textTheme.headlineSmall?.copyWith(
                    color: AppColors.secondryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: context.locale.username,
                  hintText: "ادخل اسم المستخدم",
                  controller: usernameController,
                  validator: (v) => emptyValidation(v, context),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: context.locale.password,
                  hintText: "ادخل كلمة المرور الخاصة بك",
                  controller: passwordController,
                  obscureText: true,
                  validator: (v) => passwordValidation(v, context),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Transform.scale(
                          scale: 0.9,
                          child: Checkbox(
                            value: rememberMe.value,
                            activeColor: AppColors.primaryColor,
                            onChanged: (v) => rememberMe.value = v ?? false,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        Text(
                          context.locale.rememberMe,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: AppColors.secondryColor,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        context.push(const ResetPasswordView());
                      },
                      child: Text(
                        context.locale.forgotPasswordQuestion,
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: AppColors.secondryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      ref.read(authProvider.notifier).loginTeacher(
                            usernameController.text,
                            passwordController.text,
                          );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    context.locale.teacherLogin,
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        context.locale.or,
                        style: context.textTheme.bodyLarge?.copyWith(
                          color: AppColors.secondryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          context.push(const PhoneRegisterView());
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(SvgAssets.phone02),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  context.locale.loginFirstTimePhone,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          context.push(const IdCodeRegisterView());
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(SvgAssets.key02,
                                  width: 24, color: AppColors.primaryColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  context.locale.loginFirstTime,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
