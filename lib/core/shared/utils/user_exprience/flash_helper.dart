import 'package:flash/flash.dart';
import 'package:flutter/material.dart';
import 'package:Aman/app/routing/app_routes_fun.dart';

import '../../commonWidgets/custtoms/custom_image.dart';
import '../responsive/responsive_utils.dart';
import '../extensions/extensions.dart';

enum MessageTypeTost { success, fail, warning }

class FlashHelper {
  static Future<void> showToast(String msg,
      {int duration = 2, MessageTypeTost type = MessageTypeTost.fail}) async {
    if (msg.isEmpty) return;

    final context = navigatorKey.currentContext!;
    final responsive = context.responsive;

    return showFlash(
      context: context,
      builder: (context, controller) => FlashBar(
        controller: controller,
        position: FlashPosition.top,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.symmetric(
          horizontal: responsive.spacing(16),
          vertical: responsive.spacing(8),
        ),
        content: Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.spacing(16),
            vertical: responsive.spacing(10),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(responsive.spacing(9)),
            color: _getBgColor(type),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.spacing(8),
                  vertical: responsive.spacing(11),
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: CustomImage(
                    'assets/images/appbar_logo.png',
                    fit: BoxFit.scaleDown,
                    height: responsive.spacing(19),
                    width: responsive.spacing(24),
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: responsive.spacing(10)),
              Expanded(
                child: Text(
                  msg,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                  softWrap: true,
                  style: responsive.bodyMedium(context).copyWith(
                        color: context.primaryColorLight,
                      ),
                ),
              ),
              Container(
                height: responsive.spacing(24),
                width: responsive.spacing(24),
                padding: EdgeInsets.all(responsive.spacing(5)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: CustomImage(
                  _getToastIcon(type),
                  height: responsive.spacing(19),
                  width: responsive.spacing(24),
                  fit: BoxFit.contain,
                  color: _getBgColor(type),
                ),
              ),
            ],
          ),
        ),
      ),
      duration: const Duration(milliseconds: 3000),
    );
  }

  static Color _getBgColor(MessageTypeTost msgType) {
    switch (msgType) {
      case MessageTypeTost.success:
        return '#53A653'.color;
      case MessageTypeTost.warning:
        return '#FFCC00'.color;
      default:
        return '#EF233C'.color;
    }
  }

  static String _getToastIcon(MessageTypeTost msgType) {
    switch (msgType) {
      case MessageTypeTost.success:
        return 'assets/icons/success.svg';
      case MessageTypeTost.warning:
        return 'assets/icons/warning.svg';
      default:
        return 'assets/icons/error.svg';
    }
  }
}
