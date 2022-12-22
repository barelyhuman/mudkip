<p align="center">
  <img src="images/mudkip.png" height="64">
<p align="center">The non-customizable markdown to html generator</p>

## Highlights

- Tightly scoped
- Multi Threaded
- Atomic File Processor
- Small (1.1 MB)
- File Watcher (Monitor file changes)

## Things missing

- File Server (bring your own) (or I'll add it at some point)

## Installation

### Prebuilt Binaries

You can download the binaries from
[Releases &rarr;](https://github.com/barelyhuman/mudkip/releases)

### Curl for the Prebuilt Binaries

On unix(including macOS)/linux environments you can just use the below commands to download and install the binary

```
curl -o mudkip.tgz -L https://github.com/barelyhuman/mudkip/releases/latest/download/<platform>-<arch>.tgz

tar -xvzf mudkip.tgz

install <platform>-<arch>/mudkip /usr/local/bin
```

Replace `<platform>` and `<arch>` with the available values from the releases page

### Compile from source

You can also compile from source
**prerequisites** make sure you have [nim lang](https://nim-lang.org) installed and running on your system.

Then

1. Clone and build

```sh
git clone https://github.com/barelyhuman/mudkip
cd mudkip
nimble install
nimble build -d:release
```

2. Copy the binary to a folder that's available on your system `PATH` variable

## Documentation

You can read it on the [website](https://barelyhuman.github.io/mudkip) (which, mudkip generated)
or if locally cloned, go through the `docs` folders

## License

[MIT](/license) &copy; [Reaper](https://github.com/barelyhuman)
