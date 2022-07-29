### mudkip

#### Index

- [Home](/)
- [Getting Started](/getting-started)
- [Sidebar](/sidebar)
- [CLI Flag Reference](/cli)
- [CI/CD Snippets](/ci)

# Getting Started

Since, it's a tiny little cmd line utility, all you do is execute a few commands
for your desired output.

### Installation

You should be able to get a binary for your specific system from the
[github releases](https://github.com/barelyhuman/mudkip/releases) of this
project or compile it from source if you like doing things that way (can't
judge, can I?)

### Usage

- In the most ideal cases, you'll have a folder named `docs` with all the
  markdown files in it. and all you have to do is run `mudkip` to generate what
  you see if you are reading this documentation on the website
  ```sh
  $ mudkip
  ```
- In a less ideal situation you'd need to specify the folder to convert and the
  output of the conversion
  ```sh
  $ mudkip --in='docs' --out='dist'
  ```

### Development Helpers

A few flags that'll help when working with these docs.

```sh
$ mudkip --poll # run the conversion every 3 seconds
```

### Customize

Yeah, I said it's not customizable, but it's not like you don't lie. Anyway, the
only set of customization offered is that of styles.

You can refer the `static/default-styles.css` from the
[source code](https://github.com/barelyhuman/mudkip) to see what the default
styles are, also you can add in your styles using the below flag

```sh
$ mudkip --stylesheet='./styles.css'
```

This will copy your stylesheet to the destination instead of writing the default
style

### Github Pages / Custom base URL

Not every hosting platform allows you to have a custom domain and in various
cases you'd like the documentation to use the the custom sub path.

In which case you can specify a custom base URL by using the `--baseurl` flag.

```
mudkip --baseurl='/mudkip/'
```

This will replace any markdown urls that start with `/` to `/mudkip/` and your
hosting service can handle the rest

[Sidebar &rarr;](/sidebar)

[&larr; Back](/)
