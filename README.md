<center>
    <h1 align="center">BlockTheSpot</h1>
    <h4 align="center">A multi-purpose adblocker and skip-bypass for the <strong>Windows</strong> Spotify desktop application.</h4>
    <p align="center">
        <strong>Last updated:</strong> 29 October 2021<br>
        <strong>Last tested version:</strong> 1.1.72.439.gc253025e
    </p> 
</center>

#### Important checks before installing:
0. Update Windows, update Spotify and update BlockTheSpot
1. Go to "Windows Security" -> "Virus & Threat Protection"
2. Click "Allowed threats" -> "Remove all allowed threats"

### Features:
* Blocks all banner/video/audio ads within the app
* Retains friend, vertical video and radio functionality
* Unlocks the skip function for any track
* Now supports the new Alpha version (New UI)

:warning: This mod is for the [**Desktop Application**](https://www.spotify.com/download/windows/) of Spotify on Windows only and **not the Microsoft Store version**.

#### Installation/Update:
* Just download and run [install.ps1](https://raw.githubusercontent.com/Daksh777/BlockTheSpot/master/install.ps1) <br>
* (Optional) Use [SpotifyNoPremium](https://github.com/Daksh777/SpotifyNoPremium) to declutter the Spotify UI. 

#### Uninstall:
* Just run [uninstall.bat](https://raw.githubusercontent.com/Daksh777/BlockTheSpot/master/uninstall.bat) <br>

or <br>

* Reinstall Spotify 

### Known Issues:  
* You may face issue [#150](https://github.com/mrpond/BlockTheSpot/issues/150). Can be fixed by enabling the experimental feature when using `BlockTheSpot.bat`.    
* We support last 2 version of Spotify (latest + previous) only. Please check it before opening an issue.

### Additional Notes:  
* Remove "Upgrade" Button [#83](https://github.com/mrpond/BlockTheSpot/issues/83) and Remove "Ad Placeholder" [#150](https://github.com/mrpond/BlockTheSpot/issues/150) only works when you use any of the auto installation methods and press `y` when prompted.  
* "chrome_elf.dll" gets replaced by the Spotify installer each time it updates, hence why you'll probably need to apply the patch again when it happens
* [Spicetify](https://github.com/khanhas/spicetify-cli) users will need to reapply BlockTheSpot after applying a Spicetify patches.
