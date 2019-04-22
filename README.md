# wang
[![Build Status](https://travis-ci.org/bciobanu/wang.svg?branch=master)](https://travis-ci.org/bciobanu/wang)

# Build
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