proc defaultStyles*():string =
    return r"""@import "https://fonts.googleapis.com/css?family=Inter:400";@import "https://cdn.jsdelivr.net/npm/hack-font@3/build/web/hack.css";@import "https://unpkg.com/highlight.js@11.5.1/styles/base16/horizon-light.css" screen;@import "https://unpkg.com/highlight.js@11.5.1/styles/base16/horizon-dark.css" screen and (prefers-color-scheme:dark);:root{--zinc-50:#fafafa;--zinc-100:#f4f4f5;--zinc-200:#e4e4e7;--zinc-300:#d4d4d8;--zinc-400:#a1a1aa;--zinc-500:#71717a;--zinc-600:#52525b;--zinc-700:#3f3f46;--zinc-800:#27272a;--zinc-900:#18181b;--base:var(--zinc-50);--surface:var(--zinc-100);--overlay:var(--zinc-200);--text:var(--zinc-700);--subtle:var(--zinc-400);--muted:var(--zinc-300);--font-sans:"Inter",sans-serif;--font-mono:"Hack",monospace}html{font-size:100%}body{background:var(--base);font-family:var(--font-sans);color:var(--text);max-width:80ch;margin:0 auto;padding:1rem;font-weight:400;line-height:1.75}p{margin-bottom:1rem}h1,h2,h3,h4,h5{margin:3rem 0 1.38rem;font-family:Inter,sans-serif;font-weight:400;line-height:1.3}h1{margin-top:0;font-size:3.052rem}h2{font-size:2.441rem}h3{font-size:1.953rem}h4{font-size:1.563rem}h5{font-size:1.25rem}small,.text_small{font-size:.8rem}pre,code{font-family:var(--font-mono)}pre{white-space:pre-wrap}pre>.hljs{background:var(--base);border-radius:6px;padding:0!important}a{color:var(--subtle);text-decoration:none}a:hover{color:var(--text);text-decoration:underline}@media screen and (prefers-color-scheme:dark){:root{--base:var(--zinc-900);--surface:var(--zinc-800);--overlay:var(--zinc-700);--text:var(--zinc-100);--subtle:var(--zinc-400);--muted:var(--zinc-500)}}"""