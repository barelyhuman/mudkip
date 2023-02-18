### mudkip

#### Index

- [Home](/)
- [Getting Started](/getting-started)
- [Sidebar](/sidebar)
- [Template Variables](/template-variables)
- [CLI Flag Reference](/cli)
- [CI/CD Snippets](/ci)

# Sidebar

The sidebar can be populated by writing a `_sidebar.md` file, which will create
a `nav` section in the html that'll populate the `_sidebar.md`'s content for
you.

While the app atomically processes files as needed, when the `_sidebar.md` file
is changed, all files will be reprocessed, this can either be slow or fast
depending on the number of files you have.

As an example, this is what the sidebar file for this documentation site looks
like

```md
- [Home](/)
  - [Getting Started](/getting-started)
  - [Sidebar](/sidebar)
  - [CLI Flag Reference](/cli)
  - [CI/CD Snippets](/ci)
```

[CLI Flags &rarr;](/cli)

[&larr; Back](/getting-started)
