import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/core/extensions/extensions.dart';
import 'package:smart_table_app/core/utils/utils.dart';
import 'package:smart_table_app/core/widgets/app_text_field.dart';
import 'package:smart_table_app/features/contact_us/providers/contact_us_provider.dart';
import 'package:smart_table_app/features/layout/views/main_layout_view.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/providers/providers.dart';
import '../../../profile/providers/profile_provider.dart';

class ContactUsView extends HookConsumerWidget with ValidationMixin {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.read(profileProvider).requireValue;
    final nameController = useTextEditingController(text: userData.teacherName);
    final phoneController =
        useTextEditingController(text: userData.phoneNumber);
    final emailController = useTextEditingController();
    final messageTypeController = useTextEditingController();
    final messageController = useTextEditingController();
    final formKey = useMemoized(GlobalKey<FormState>.new, const []);
    ref.listen(
      requestResponseProvider,
      (_, state) {
        if (state.state == RequestResponseState.success) {
          if (state.actionOnDone == ActionOnDone.loginSucess) {
            {
              context.showSnackbarSuccess(context.locale.sucessMessage);
              context.pushAndRemoveOthers(const MainLayoutView());
            }
          }
        }
      },
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(context.locale.contactUs),
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
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
                      AppTextField(
                        hintText: context.locale.username,
                        controller: nameController,
                        validator: (val) => emptyValidation(val, context),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      AppTextField(
                        hintText: context.locale.phoneNumber,
                        controller: phoneController,
                        textInputType: TextInputType.phone,
                        validator: (val) => emptyValidation(val, context),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      AppTextField(
                        hintText: context.locale.email,
                        controller: emailController,
                        textInputType: TextInputType.emailAddress,
                        validator: (val) => emailValidation(val, context),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      AppTextField(
                        hintText: context.locale.messageType,
                        controller: messageTypeController,
                        validator: (val) => emptyValidation(val, context),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      AppTextField(
                        hintText: context.locale.writeHere,
                        maxLines: 10,
                        controller: messageController,
                        validator: (val) => emptyValidation(val, context),
                      ),
                      const Spacer(),
                      ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              ref.read(contactUsProvider.notifier).send(
                                  name: nameController.text,
                                  phone: phoneController.text,
                                  email: emailController.text,
                                  title: messageTypeController.text,
                                  message: messageController.text);
                            }
                          },
                          child: Text(context.locale.send)),
                      const SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
