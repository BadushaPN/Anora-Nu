import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final String time;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isUser
                  ? LinearGradient(
                      colors: [AppColors.primary, Color(0xFF6A4CE6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        AppColors.surfaceLight,
                        AppColors.surfaceLight.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isUser ? 18 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 18),
              ),
              boxShadow: [
                BoxShadow(
                  color: isUser
                      ? AppColors.primary.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    color: isUser ? Colors.white : AppColors.textPrimary,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: isUser
                        ? Colors.white.withValues(alpha: 0.6)
                        : AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
