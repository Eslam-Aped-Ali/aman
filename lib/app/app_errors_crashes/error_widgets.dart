import 'package:Aman/core/shared/utils/responsive/responsive_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'phoneix.dart';

class ErrorScreen extends StatelessWidget {
  final FlutterErrorDetails details;

  const ErrorScreen({
    super.key,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = context.responsive;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Error Occurred',
          style: responsive.headline3(context),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: responsive.maxContentWidth,
            ),
            padding: responsive.padding(24, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: responsive.spacing(64),
                    color: Colors.red,
                  ),
                  SizedBox(height: responsive.spacing(16)),
                  Text(
                    'Something went wrong',
                    style: responsive.headline2(context),
                  ),
                  SizedBox(height: responsive.spacing(8)),
                  Text(
                    'The app encountered an unexpected error',
                    style: responsive.bodyMedium(context).copyWith(
                          color: Colors.grey,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  if (kDebugMode) ...[
                    SizedBox(height: responsive.spacing(24)),
                    Container(
                      padding: responsive.padding(12, 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(
                          responsive.spacing(8),
                        ),
                      ),
                      constraints: BoxConstraints(
                        maxHeight: responsive.height * 0.3,
                      ),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          details.exception.toString(),
                          style: TextStyle(
                            fontSize: responsive.fontSize(12),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: responsive.spacing(24)),
                  SizedBox(
                    height: responsive.spacing(48),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Phoenix.rebirth(context);
                      },
                      icon: Icon(
                        Icons.refresh,
                        size: responsive.fontSize(20),
                      ),
                      label: Text(
                        'Restart App',
                        style: responsive.bodyLarge(context),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: responsive.padding(24, 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InitializationErrorApp extends StatelessWidget {
  final Object error;

  const InitializationErrorApp({
    super.key,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) {
          final responsive = context.responsive;

          return Scaffold(
            body: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: responsive.maxContentWidth,
                ),
                padding: responsive.padding(24, 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: responsive.spacing(80),
                      color: Colors.orange,
                    ),
                    SizedBox(height: responsive.spacing(24)),
                    Text(
                      'Failed to Initialize App',
                      style: responsive.headline1(context),
                    ),
                    SizedBox(height: responsive.spacing(16)),
                    Text(
                      kDebugMode
                          ? error.toString()
                          : 'Please check your internet connection and try again',
                      textAlign: TextAlign.center,
                      style: responsive.bodyMedium(context).copyWith(
                            color: Colors.grey,
                          ),
                    ),
                    SizedBox(height: responsive.spacing(32)),
                    SizedBox(
                      height: responsive.spacing(48),
                      child: ElevatedButton(
                        onPressed: () {
                          SystemNavigator.pop();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: responsive.padding(32, 12),
                        ),
                        child: Text(
                          'Close App',
                          style: responsive.bodyLarge(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
