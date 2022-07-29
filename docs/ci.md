### mudkip

#### Index

- [Home](/)
- [Getting Started](/getting-started)
- [Sidebar](/sidebar)
- [CLI Flag Reference](/cli)
- [CI/CD Snippets](/ci)

# CI / CD Usage

These are sample script snippets that you can use in your deployments when
working with mudkip

```sh
curl -o mudkip.tgz -L https://github.com/barelyhuman/mudkip/releases/download/testing/linux-amd64.tgz
tar -xvzf mudkip.tgz
sudo install linux-amd64/mudkip /usr/local/bin
```

Replace `testing/linux-amd64.tgz` with `latest/<platform>-<arch>.tgz` to get the
specific build that you need. You can check for the available releases and tags
on the [releases page](https://github.com/barelyhuman/mudkip/releases) of the
project

[&larr; Back](/cli)
