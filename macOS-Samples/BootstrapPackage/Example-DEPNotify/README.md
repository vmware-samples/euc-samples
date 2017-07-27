# Example - DEPNotify package
This package is designed to open on first user login

The repository is setup to build with `munkipkg`

### To build with pkgbuild and productbuild:
```
pkgbuild --install-location / --identifier "com.vmware.airwatch.DEPNotify-Example" --version "1.0" --root ./payload/ --scripts ./scripts/ ./build/build.pkg
```
To convert the flat pkg to a signed distribution pkg, use the below command but modify for your certificate in login keychain
```
productbuild --sign "Developer ID Installer: VMWARE AIRWATCH (MXNCQ3W382)" --package ./build/build.pkg ./build/DEPNotify-1.0.pkg
```


## To build with munkipkg
First modify the `build-info.json` file for your certificate in login keychain
```
munkipkg Example-DEPNotify/
```
