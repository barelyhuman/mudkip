### mudkip

#### Index

- [Home](/)
- [Getting Started](/getting-started)
- [Sidebar](/sidebar)
- [Template Variables](/template-variables)
- [CLI Flag Reference](/cli)
- [CI/CD Snippets](/ci)

## Template Variables

Added in `v0.1.8`

These are custom variables that you can use in your markdown files and will be replaced by parameters
that the compiler with replace at build time.

`%baseurl%`

Example, if you build this with the `--baseurl="/mudkip/"` then the following would be the html output

```md
- [Home](%baseurl%)
- [Getting Started](%baseurl%getting-started)
- [Sidebar](%baseurl%sidebar)
- [Template Variables](%baseurl%template-variables)
- [CLI Flag Reference](%baseurl%cli)
- [CI/CD Snippets](%baseurl%ci)
```

```html
<ul>
  <li><a href="/mudkip/">Home</a></li>
  <li><a href="/mudkip/getting-started">Getting Started</a></li>
  <li><a href="/mudkip/sidebar">Sidebar</a></li>
  <li><a href="/mudkip/template-variables">Template Variables</a></li>
  <li><a href="/mudkip/cli">CLI Flag Reference</a></li>
  <li><a href="/mudkip/ci">CI/CD Snippets</a></li>
</ul>
```
