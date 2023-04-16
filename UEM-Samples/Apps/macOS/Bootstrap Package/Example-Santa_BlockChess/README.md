# Example - Santa (Block Chess.app) package
This package is designed to install Google's [Santa](https://github.com/google/santa) and configure a blacklist rule to block an app, in this example Chess.app

This distribution package will contain 2 sub-packages:  
  1. a pkg to install the latest release of Santa ([here](https://github.com/google/santa/releases))  
  2. a payload-free pkg to run a [postinstall script](https://github.com/vmwaresamples/AirWatch-samples/blob/master/macOS-Samples/BootstrapPackage/Example-Santa_BlockChess/scripts/postinstall) to set a `santactl` blacklist rule

### To build the config pkg with pkgbuild:
Edit the [postinstall script](https://github.com/vmwaresamples/AirWatch-samples/blob/master/macOS-Samples/BootstrapPackage/Example-Santa_BlockChess/scripts/postinstall) to add your desired [Santa rules](https://github.com/google/santa/wiki)

```
# first delete .DS_Store files so that they aren't included in the pkg
find . -name '*.DS_Store' -type f -delete
# build the config pkg
pkgbuild --install-location / --identifier "com.google.santa.santa_config" --version 1.0 --nopayload --scripts ./scripts/ ./build/santa_config.pkg
```

### To build the config pkg with [munkipkg](https://github.com/munki/munki-pkg)
No changes are needed to the [build-info.json](https://github.com/vmwaresamples/AirWatch-samples/blob/master/macOS-Samples/BootstrapPackage/Example-Santa_BlockChess/build-info.json) unless you want to change the pkg identifiers. Munkipkg also ignores .DS_Store automatically.  

```
munkipkg santa_config/
```

### Create final distribution pkg with productbuild
First build the config pkg with either of the above methods  
Second, download the latest Santa release pkg from [here](https://github.com/google/santa/releases)

Create a directory containing both the santa-x.x.x.pkg and the santa_config.pkg

```
# Synthesize the pkgs to create a distribution file (no changes needed)
# Pkgs will be installed in the order defined. In this case, Santa should be installed before the Config
productbuild --synthesize --package ./santa-0.9.19.pkg --package ./santa_config.pkg distribution.plist

# Build the final pkg
productbuild --distribution distribution.plist --resources . --sign "Developer ID Installer: VMWARE AIRWATCH (MXNCQ3W382)" --timestamp ./Santa_BlockChess.pkg
```
