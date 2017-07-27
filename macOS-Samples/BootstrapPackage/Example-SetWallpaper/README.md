# Example - SetWallpaper package
This package is designed to set the wallpaper of an image hosted online

*Be sure to modify the postinstall and change the url for your image*

This package is designed for a user-session install. It will not work if installed during DEP Setup Assistant since there is no desktop yet to modify. As such, recommended deployment for this is to use [InstallApplications](https://github.com/erikng/installapplications) and place the package in Stage1 or Stage2

The repository is setup to build with `munkipkg`

### To build with pkgbuild and productbuild:
```
pkgbuild --install-location / --identifier "com.vmware.airwatch.setwallpaper" --version "1.0" --root ./payload/ --scripts ./scripts/ ./build/build.pkg
```
To convert the flat pkg to a signed distribution pkg, use the below command but modify for your certificate in login keychain
```
productbuild --sign "Developer ID Installer: VMWARE AIRWATCH (MXNCQ3W382)" --package ./build/build.pkg ./build/DEPNotify-1.0.pkg
```


## To build with [munkipkg](https://github.com/munki/munki-pkg)
First modify the `build-info.json` file for your certificate in login keychain
```
munkipkg Example-DEPNotify/
```
