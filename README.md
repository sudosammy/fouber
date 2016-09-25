# Fouber

Fouber (pronounced foobar) will calculate what your Uber driver rated you as a passenger.

### Why?
> The rating system works to make sure that the most respectful riders and drivers are using Uber. Ratings are always reported as averages, and **neither riders nor drivers will see the individual rating left for a particular trip**.

How are you meant to gauge your level of *jerkness* without knowing what your Uber driver rated you?! 

Fouber puts you in the driver's seat (figuratively) and calculates exactly what your last driver rated you so you can ~~counter rate accordingly~~ self-assess what led them to think you're a jerk!

**Note:** Uber has an aggressive rating upkeep requirement for drivers. You could be taking someone's source of income away by rating them badly in retaliation.

![Image](git-files/drate.png?raw=true)

### Installation - Android
**Easy Way:** Download the ```.apk``` file from the ```compiled/Android/``` directory and move it onto your device. You will need to accept the installation from an unknown source. Here's a video:

![Image](git-files/android-install.gif?raw=true)

**Build From Source Way:** This app is coded in Lua with the [Corona SDK](https://coronalabs.com/). If you download Corona SDK, create a Corona account and have the Java JDK (Java Development Kit 32bit) installed on your machine you can build the apk yourself then move it to your Android device and install it. See Corona's tutorial [here](https://docs.coronalabs.com/daily/guide/distribution/androidBuild/index.html) or a video guide [from 4:15 onwards here](https://youtu.be/Omu4TJFZU6k?t=4m15s). Use Corona's included debug keystore 'androiddebugkey' - no need to create a Google Developer account.


### Installation - iPhone
**Easy Way:** Buy an Android device.

**Easy Way (For Jailbroken Devices):** TBA

**Build From Source Way (For Jailbroken Devices):** TBA

### Updating
I recommend updating when available; however, the update will overwrite the applications local database and you will be required to re-login. This means you'll lose your most recent driver rating. So don't update the app before viewing what your driver gave you!

You can update by following the steps you took to install the app. Just re-download (or compile) and install on your device. The app will automatically update, so no need to uninstall the existing version first. If you have trouble or the update creates a new application icon you can uninstall the old version using the normal application uninstall methods for your device.

### Security Concerns
**If your device is compromised - assume your Uber account is too** This app stores your Uber API ```userid``` and ```token```. These are used to make private API calls and can perform a number of actions under your Uber account. If your device is compromised you won't be able to ensure the confidentiality of your Uber account.

**Don't use the app on networks you don't trust** Little sanitisation is performed on the response from the Uber API. This means in a Man-in-the-Middle (MitM) scenario an attacker could possibly perform attacks against the app and recover your Uber ```userid``` and ```token```. I wouldn't open the app on public WiFi.

### Known Bugs/Quirks
 - If the rider hasn't taken any rides before using Fouber; it might just crash (haven't tested)
 - Updating the app wipes the database forcing the user to re-login and losing their most recent rating
 - Upon logging out, re-authenticating and logging out again (without closing/re-opening the app) will fail to correctly log the user out

### Future Improvements (Don't hold your breath)
 - iOS install instructions
 - Parameterised queries
 - Show current star rating on app landing page
 - Move away from using pop up messages to notify the user
 - Support for rating your driver from inside the Fouber app
 - Move all messages into a separate file for easier management (and also translation)

### License
Apache License 2.0
