import 'package:flutter/material.dart';

class ProfileSettingsItem {
  const ProfileSettingsItem({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
    this.showChevron = true,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool showChevron;
}
