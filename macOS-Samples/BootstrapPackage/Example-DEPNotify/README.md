# Example - DEPNotify package
This package is designed to open [DEPNotify](https://gitlab.com/Mactroll/DEPNotify) on first user login coming out of Setup Assistant from a DEP enrollment. 

Additionally, if the pkg is deployed after the user session is already active, it's also designed to start the LaunchAgent immediately, which will kick off the DEPNotify UI.


The repository is setup to build with `munkipkg`

### To build with pkgbuild and productbuild:
```
pkgbuild --install-location / --identifier "com.vmware.airwatch.DEPNotify-Example" --version "1.0" --root ./payload/ --scripts ./scripts/ ./build/build.pkg
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
