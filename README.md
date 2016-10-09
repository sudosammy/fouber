# Fouber

Fouber (pronounced foo-bar) will calculate what your Uber driver rated you as a passenger.

### Why?
> The rating system works to make sure that the most respectful riders and drivers are using Uber. Ratings are always reported as averages, and **neither riders nor drivers will see the individual rating left for a particular trip**.

How are you meant to gauge your level of *jerkness* without knowing what your Uber driver rated you?! 

Fouber puts you in the driver's seat (figuratively) and calculates exactly what your last driver rated you so you can ~~counter rate accordingly~~ self-assess what led them to think you're a jerk!

**Note:** Uber has an aggressive rating upkeep requirement for drivers. You could be taking someone's source of income away by rating them badly in retaliation.

![Image](git-files/drate.png?raw=true)

### Installation - Android
**Easy Way:** Download the ```.apk``` file [from here](compiled/Android/Fouber.apk) onto your device. You will need to accept the installation from an [unknown source](http://www.ubergizmo.com/how-to/how-to-install-apk-files-sideloading-on-android/). Here's a video:

![Image](git-files/android-install.gif?raw=true)

**Build From Source Way:** This app is coded in Lua with the [Corona SDK](https://coronalabs.com/). If you download Corona SDK, create a Corona account and have the Java JDK (Java Development Kit) installed on your machine you can build the app yourself then move it to your Android device and install it. See Corona's tutorial [here](https://docs.coronalabs.com/daily/guide/distribution/androidBuild/index.html) or a video guide [from 4:15 onwards here](https://youtu.be/Omu4TJFZU6k?t=4m15s). Use Corona's included debug keystore 'androiddebugkey' - no need to create a Google Developer account.


### Installation - iOS
**For Jailbroken iDevices using [Cydia](http://cydiainstaller.net/):** You can use an [IPA Installer](http://cydia.saurik.com/package/com.slugrail.ipainstaller/) to install straight from your iDevice. Download the ```.ipa``` file [from here](compiled/iOS/Fouber.ipa) and install.

**For Jailbroken iDevices:** Download the ```.ipa``` file [from here](compiled/iOS/Fouber.ipa) onto your computer. Use iTunes to [sync the app](https://support.apple.com/kb/PH19460) to your iDevice and install it. A video guide [from 15 seconds onwards + shitty background music is here](https://youtu.be/egF6-yml9mQ?t=15s).

**For Non-Jailbroken iDevices (Build From Source Way):** You will need a Mac machine to sideload this app to your device. You **don't** need a paid Apple developer account but you will need a free account as shown in [this video](https://www.youtube.com/watch?v=ZvC0VWgIET4). This app is coded in Lua with the [Corona SDK](https://coronalabs.com/). If you download Corona SDK, create a Corona account and use Xcode to create a "provisioning profile" for your iDevice you will be able to build the app and sync it to your iDevice with iTunes. The process is similar to "Method 2" in [this](http://lifehacker.com/how-to-install-unapproved-apps-on-an-iphone-without-jai-1749519150) article. However, in "Step Two" you want to create a dummy Xcode project (for example; a blank single-view iOS project) rather than trying to open Lua code in Xcode (which won't work). In "Step Four", don't use Xcode to compile and install the app, you need to build the app in Corona SDK (video guide [from 3 minutes onwards here](https://youtu.be/vueupVlsBPs?t=2m59s)) with the provisioning profile you just created and then use iTunes (video guide [from 15 seconds onwards + shitty background music here](https://youtu.be/egF6-yml9mQ?t=15s)) to install the app on your iDevice. **Note:** Corona SDK builds a ```.app``` file rather than a ```.ipa``` file. You can still use iTunes to install the ```.app```. If you care, you can learn how to convert the ```.app``` file into ```.ipa``` [here](http://stackoverflow.com/questions/15826646/how-to-create-ipa-file-from-corona-sdk).

### Updating
I recommend updating when available; however, the update will overwrite the applications local database and you will be required to re-login. This means you'll lose your most recent driver rating. So don't update the app before viewing what your driver gave you!

You can update by following the steps you took to install the app. Just re-download (or compile) and install on your device. The app will automatically update, so no need to uninstall the existing version first. If you have trouble or the update creates a new application icon you can uninstall the old version using the normal application uninstall methods for your device.

### Security Concerns
**If your device is compromised - assume your Uber account is too** This app stores your Uber API ```userid``` and ```token```. These are used to make private API calls and can perform a number of actions under your Uber account. If your device is compromised you won't be able to ensure the confidentiality of your Uber account.

**Don't use the app on networks you don't trust** Little sanitisation is performed on the response from the Uber API. This means in a Man-in-the-Middle (MitM) scenario an attacker could possibly perform attacks against the app and recover your Uber ```userid``` and ```token```. I wouldn't open the app on public WiFi.

### Bugs/Quirks
 - If the rider hasn't taken any rides before using Fouber; it might just crash (haven't tested)
 - Updating the app wipes the database forcing the user to re-login and losing their most recent rating
 - Upon logging out, re-authenticating and logging out again (without closing/re-opening the app) will fail to correctly log the user out
 - Building from source won't include the app icon, you can use the included ```fouber.psd``` Photoshop file to re-create the icon before compiling or make your own. Either way, [this](http://icon.angrymarmot.org/) website will help

### Future Improvements (Don't hold your breath)
 - Parameterised queries
 - Show current star rating on app landing page
 - Move away from using pop up messages to notify the user
 - Support for rating your driver from inside the Fouber app
 - Move all messages into a separate file for easier management (and also translation)

### License
Apache License 2.0
