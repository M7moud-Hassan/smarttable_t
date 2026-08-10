import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:smart_table_app/features/profile/providers/profile_provider.dart';

class ProfilePhotoAvatar extends ConsumerWidget {
  const ProfilePhotoAvatar({
    super.key,
    required this.radius,
    required this.fallback,
    this.backgroundColor = Colors.white,
  });

  final double radius;
  final Widget fallback;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoAsync = ref.watch(profilePhotoProvider);
    final size = radius * 2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAlias,
      child: photoAsync.when(
        data: (url) => url == null || url.isEmpty
            ? fallback
            : CachedNetworkImage(
                imageUrl: url,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (_, __) => fallback,
                errorWidget: (_, __, ___) => fallback,
              ),
        loading: () => fallback,
        error: (_, __) => fallback,
      ),
    );
  }
}
