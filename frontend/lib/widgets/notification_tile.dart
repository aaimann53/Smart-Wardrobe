import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../theme/app_theme.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  IconData _getIcon() {
    switch (notification.icon) {
      case 'calendar_today':
        return Icons.calendar_today;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'tips_and_updates':
        return Icons.tips_and_updates;
      case 'lightbulb':
        return Icons.lightbulb_outline;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'volunteer_activism':
        return Icons.volunteer_activism;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getIconBg() {
    switch (notification.type) {
      case 'reminder':
        return AppTheme.primary.withValues(alpha: 0.1);
      case 'weather':
        return AppTheme.accent.withValues(alpha: 0.15);
      case 'tip':
        return Colors.green.withValues(alpha: 0.1);
      case 'inspiration':
        return Colors.pink.withValues(alpha: 0.1);
      case 'seasonal':
        return Colors.blue.withValues(alpha: 0.1);
      case 'care':
        return Colors.orange.withValues(alpha: 0.1);
      default:
        return AppTheme.primary.withValues(alpha: 0.1);
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case 'reminder':
        return AppTheme.primary;
      case 'weather':
        return AppTheme.accent;
      case 'tip':
        return Colors.green;
      case 'inspiration':
        return Colors.pink;
      case 'seasonal':
        return Colors.blue;
      case 'care':
        return Colors.orange;
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? AppTheme.surface : AppTheme.primary.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: notification.isRead
                ? Colors.transparent
                : AppTheme.primary.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: AppTheme.softShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _getIconBg(),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(_getIcon(), color: _getIconColor(), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.time,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
