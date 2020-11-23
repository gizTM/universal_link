# universal_link

Example of flutter app utilizing universal link for android and ios application

Universal link (universal link for ios, app link for android) is technique that mobile platforms: android and ios use to open the application via a link. The link consists of scheme and host part; if the scheme part is http or https the link will be called universal/app link, otherwise, it will be called deep link. The difference between deep link and universal/app link are that the application website has to be verified by config files placed on the web and that the flow will not be interupted by app confirmation popup.

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
          android:pathPrefix="<website-path-after-host>" />
    </intent-filter>
  </activity>
  ```
  
  3. Verify website that can be used as universal/app link by entering `https://digitalassetlinks.googleapis.com/v1/statements:list?source.web.site=https://<host>&relation=delegate_permission/common.handle_all_urls`
  4. Enter path to assetlinks.json file in flutter project by creating file `android/app/src/main/res/values/strings.xml`
  
  ```
  <resources>
    <string name="asset_statements" translatable="false">[{\"include\": "https://<host>/.well-known/assetlinks.json"}]</string>
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

## Reference

https://benzneststudios.com/blog/flutter/how-to-use-deep-link-in-flutter/
