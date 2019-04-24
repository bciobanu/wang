# wang
[![Build Status](https://travis-ci.org/bciobanu/wang.svg?branch=master)](https://travis-ci.org/bciobanu/wang)

# Build

## Napoca
To build the Napoca server locally, a `protoc` executable is required,
at least at version `3.0`.
- On Mac OS X: `brew install protobuf` / `brew upgrade protobuf`.
If this still doesn't work, try:
```bash
PROTOC_ZIP=protoc-3.7.1-osx-x86_64.zip
curl -OL https://github.com/google/protobuf/releases/download/v3.7.1/$PROTOC_ZIP
sudo unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
rm -f $PROTOC_ZIP
```
- On Linux:
```bash
PROTOC_ZIP=protoc-3.7.1-linux-x86_64.zip
curl -OL https://github.com/google/protobuf/releases/download/v3.7.1/$PROTOC_ZIP
sudo unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
rm -f $PROTOC_ZIP
```
Then, just running `cargo build` will generate the required Protocol Buffer files.

## Beetle
To build the RESTful API of the project, just run `npm install` from `beetle` directory.
Use `npm start` to start the Node server.

## Panda
To build the front-end of the project, you first need to install the `Dart` language:
- https://webdev.dartlang.org/guides/get-started#2-install-dart

For development, the best way to run Panda is through Dart's `webdev` compiler:
- from `panda` directory run `webdev serve web:8080`
