
# SQLite

The purpose of this package is to provide a build system around SQLite as a Shared Library for cross-compiling for Android & iOS, as well as building for testing on local machines.

If an application contains mulitple copies of SQLite, database corruption could ensue on POSIX systems, so it's important that applications (including linked libraries) to only use one copy of SQLite. See Section 2.2 of [How To Corrupt](https://www.sqlite.org/howtocorrupt.html) for more information.

This package contains the original SQLite sources which is in the Public Domain. Additionally it contains build scripts for producing binaries for several architectures. Built binaries gets published to the [sqlite-bin](https://github.com/totalpaveinc/sqlite-bin) repository.

This package is currently using SQLite3 v3.46.0.

Prebuilt binaries are available for:
- iOS:
- - ARM64 (iOS SDK)
- - x86_64, ARM64 (iOS Simulator SDK)
- - xcframework (Contains all architectures)
- Android:
- - armeabi-v7a
- - arm64-v8a
- - x86
- - x86_64
- - AAR library (Contains all prebuilt architectures)

Android builds are built on NDK 27 and is 16k page size supported and is backwards compatible to 4k page size devices.

Note that the AAR files do not contain JNI. The AAR package is simply to ensure applications all use a single copy of SQLite.

The individual SO libraries are provided for linking with other libraries. Applications should import the AAR / xcframework file.

## Licensing

See [LICENSE](./LICENSE)

## Docs

See [Documentation](./docs.md)

## Building

To build, simply run the `build.sh` script in the root directory.

### Build Requirements

Mac OS or Linux with bash shell is required.

#### Android

The following tools is required:
- NDK Version 27.0.11902837
- Gradle 8.9
- `ANDROID_HOME` environment variable should be set to the Android SDK.

#### iOS

The following tools is required:
- XCode 15.0 (with additional command line tools installed)

#### Linux

Clang compiler is required.

## Updating SQLite

To update SQLite, unpack the sources into the `src/sqlite` folder.

## TotalPave Committers

This repository contains submodules. Clone this repo with the `--recurse-submodules` flag.

e.g: `git clone --recurse-submodules git@github.com:totalpaveinc/sqlite.git`

If you have already cloned without submodules, you can correct the repo by running `git submodule update --init`

To publish, run `./makeRelease.sh <version>`
