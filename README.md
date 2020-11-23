# universal_link

Example of flutter app utilizing universal/app link for android and ios application

## Table of content
...

Universal link (universal link for ios, app link for android) is technique that mobile platforms: android and ios use to open the application via a link. The link consists of scheme and host part; if the scheme part is http or https the link will be called universal/app link, otherwise, it will be called deep link. The difference between deep link and universal/app link are that the application website has to be verified by config files placed on the web and that the flow will not be interupted by app confirmation popup.

## In this demo

In this demo code, after run the flutter app, entering the link https://new-flutter-universal-link.herokuapp.com will trigger the app to open to default home page with + icon for couter.
The link https://new-flutter-universal-link.herokuapp.com/page1 will trigger the app to open to default home page then navigate to first page component.
The link https://new-flutter-universal-link.herokuapp.com/page2 will trigger the app to open to default home page then navigate to second page component.

## Android

  1. Host a website with https then upload config files: `https://your-web-host-name/.well-known/assetlinks.json`

    [
      {
        "relation": ["delegate_permission/common.handle_all_urls"],
        "target": {
          "namespace": "android_app",
          "package_name": "<android-app-package-name>",
          "sha256_cert_fingerprints": ["<android-fingerprint>"]
        }
      }
    ]
    
   * `android-fingerprint` can be either debug or release fingerprint
   * get `android-debug-fingerprint` from `keytool -exportcert -list -v -alias androiddebugkey -keystore  ~/.android/debug.keystore`
   * to manage keystore checkout https://gist.github.com/henriquemenezes/70feb8fff20a19a65346e48786bedb8f
    
  2. Add code to `android/app/src/main/AndroidManifest.xml`
  
  ```
  <activity ...>
    ...
    <intent-filter android:autoVerify="true">
      <action android:name="android.intent.action.VIEW" />
      <category android:name="android.intent.category.DEFAULT" />
      <category android:name="android.intent.category.BROWSABLE" />
      <data
          android:scheme="https"
          android:host="<host>"
          android:pathPrefix="<website-path-after-host(if any)>" />
      <!-- note that the leading "/" is required for pathPrefix-->
    </intent-filter>
  </activity>
  ```
  
  3. Verify website that can be used as universal/app link by entering `https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://<host>&relation=delegate_permission/common.handle_all_urls`
  4. Enter path to assetlinks.json file in flutter project by creating file `android/app/src/main/res/values/strings.xml`
  
  ```
  <resources>
    <string name="asset_statements" translatable="false">[{"include": "https://<host>/.well-known/assetlinks.json"}]</string>
  </resources>
  ```
  
  And add reference to path by `android/app/src/main/AndroidManifest.xml`
  
  ```
  <activity>
  ...
    <meta-data
      android:name="asset_statements"
      android:resource="@string/asset_statements"/>
  ...
  </activity>
  ```
  
  5. Test by running the app in device/emulator with `flutter run` then
      * for device: paste link to your host website in note then tap the link
      * for emulator: run `adb shell am start -W -a android.intent.action.VIEW -d "https://<host><website-path-after-host(if any)>"`
      * **the app should open if app is installed**

  
## IOS

  1. Host a website with https then upload config files: `https://your-web-host-name/.well-known/apple-app-site-association`
  
    {
      "applinks": {
        "apps": [],
        "details": [
          {
            "appID": "<team-id>.<ios-app-package-name>",
            "paths": [
              "*"
            ]
          }
        ]
      }
    }
  
   * get `team id` from https://developer.apple.com/account/#/membership (you need to have apple developer team)
   * `ios-app-package-name` is the app name that is registered in https://developer.apple.com/account/resources/identifiers/list. The name must be unique. The identifier with the same package name registered must also be configured with `Associated domains` enabled.
  2. Test by running the app in device/emulator with `flutter run` then
    * for device: paste link to your host website in note then tap the link
    * for emulator: run `xcrun simctl openurl booted 'https://<host><website-path-after-host(if any)>'`
    * **the app should open if app is installed**

## Managing route in app

In addition to opening app from link, the universal link can also be used to manage in app route for page rendering. This can be done by detecting the uri used to open the app when the link is tapped.

```
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:uni_links/uni_links.dart' as UniLink;
import './first_page.dart';
import './second_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  checkDeepLink();
  runApp(MyApp());
}

Future checkDeepLink() async {
  StreamSubscription _sub;
  try {
    print("checkDeepLink");
    await UniLink.getInitialLink();
    _sub = UniLink.getUriLinksStream().listen((Uri uri) {
      print('uri: $uri');
      WidgetsFlutterBinding.ensureInitialized();
      runApp(MyApp(uri: uri));
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed

      print("onError");
    });
  } on PlatformException {
    print("PlatformException");
  } on Exception {
    print('Exception thrown');
  }
}

class MyApp extends StatelessWidget {
  final Uri uri;
 
  MyApp({this.uri});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(uri: uri, title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.uri}) : super(key: key);
  final Uri uri;
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_){
      // take action according to data uri
      if (widget.uri != null) {
        List<String> splitted = widget.uri.toString().split('/');
        if (splitted[splitted.length - 1] == 'page1')
          Navigator.push(context, MaterialPageRoute(builder: (context) => FirstPage(widget.uri)));
        if (splitted[splitted.length - 1] == 'page2')
          Navigator.push(context, MaterialPageRoute(builder: (context) => SecondPage(widget.uri)));
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
```

## Reference

https://benzneststudios.com/blog/flutter/how-to-use-deep-link-in-flutter/
