import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MyWebsite extends StatefulWidget {
  const MyWebsite({Key? key}) : super(key: key);

  @override
  State<MyWebsite> createState() => _MyWebsiteState();
}

class _MyWebsiteState extends State<MyWebsite> {
  late InAppWebViewController inAppWebViewController;
  bool _showSplash = true;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late SharedPreferences _sessionPrefs;
  final String _sessionKey = 'app_session';
 
  @override
  void initState() {
    super.initState();
    _initializeSessionPrefs();
    // Simulate a delay for the splash screen
    Future.delayed(const Duration(seconds: 5 , milliseconds:5 ), () {
      setState(() {
        _showSplash = false;
        _updateSessionStart();
      });
    });
  }

  Future<void> _initializeSessionPrefs() async {
    _sessionPrefs = await _prefs;
  }

  Future<void> _updateSessionStart() async {
    final now = DateTime.now();
    await _sessionPrefs.setString(_sessionKey, now.toIso8601String());
  }

  Future<bool> _isSessionExpired() async {
    final sessionStartString = _sessionPrefs.getString(_sessionKey);
    if (sessionStartString != null) {
      final sessionStart = DateTime.parse(sessionStartString);
      const sessionDuration = Duration(minutes: 15);
      final sessionEnd = sessionStart.add(sessionDuration);
      final now = DateTime.now();
      return now.isAfter(sessionEnd);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var isLastPage = await inAppWebViewController.canGoBack();

        if (isLastPage) {
          inAppWebViewController.goBack();
          return false;
        }

        return true;
      },
      child: SafeArea(
        child: Scaffold(
          body: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: Uri.parse("https://www.trademartlk.com/V03/manager/"),
                ),
                onWebViewCreated: (InAppWebViewController controller) {
                  inAppWebViewController = controller;
                },
                initialOptions: InAppWebViewGroupOptions(
                  android: AndroidInAppWebViewOptions(
                    cacheMode: AndroidCacheMode.LOAD_CACHE_ELSE_NETWORK,
                    allowFileAccess: true,
                  ),
                  ios: IOSInAppWebViewOptions(
                    allowsInlineMediaPlayback: true,
                  ),
                ),
                onLoadStart: (controller, url) {
                  DefaultCacheManager().downloadFile(url!.toString());
                },
              ),
               if (_showSplash)
  Container(
    color: Colors.white,
    child: Stack(
      children: [
        Center(
          child: Lottie.asset(
            'assets/vehicle.json',
          ),
        ),
        const Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              '© IDEAL Motors (Pvt) Ltd.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      ],
    ),
  ),

            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkSessionExpired();
  }

  Future<void> _checkSessionExpired() async {
    if (await _isSessionExpired()) {
      // Handle session expiration here
      // For example, show a login screen or navigate to a different page
      if (kDebugMode) {
        print('Session expired');
      }
    } else {
      if (kDebugMode) {
        print('Session is active');
      }
    }
  }
}

void main() {
  runApp(const MaterialApp(
    home: MyWebsite(),
  ));
}
