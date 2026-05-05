# Facet

A Crystal-based template compilation system for building interactive component-based UIs.

> [!CAUTION]
> **FACET IS IN VERY EARLY DEVELOPMENT AND PRODUCTION USE IS NOT RECOMMENDED!**

## Quick Start

TODO

## How It Works

Create build.cr to build the website:
```crystal
require "facet"

input_dir = File.dirname(__FILE__)
output_dir = File.join(input_dir, "dist")

Facet.compile_static(input_dir, output_dir)
```

The `crystal run build.cr` command:

1. **Parses** `.hcr` files (Facet Component Resources) using the built-in parser
2. **Extracts** inline `<style>` blocks and combines them into one CSS file
3. **Extracts** binding declarations from `<?cr ... ?>` blocks (e.g., `${'#selector'}.onclick = handler()`)
4. **Compiles** bindings to browser-ready JavaScript with event listeners and fetch handlers
5. **Hashes** CSS and JS content using MD5 (first 8 chars) for cache-busting
6. **Generates** complete output:
   - `index.html` — Complete HTML document with asset references
   - `styles-<hash>.css` — All CSS combined (from `<style>` blocks)
   - `index-<hash>.js` — Compiled JavaScript with event handlers and RPC calls

## Output Example

```
dist/
├── index.html                    # Main HTML file
├── styles-85b40ed1.css          # CSS bundle (content-hashed)
└── index-34ef9096.js            # JavaScript bundle (content-hashed)
```

The HTML automatically references the hashed assets:

```html
<link rel="stylesheet" href="styles-85b40ed1.css">
<script src="index-34ef9096.js"></script>
```

## HCR File Format

HCR files combine event binding declarations and HTML:

```html
<?cr
${'#login-btn'}.onclick = login(${'#email'}, ${'#password'})
${'#logout-btn'}.onclick = logout()
?>
<!DOCTYPE html>
<html>
<head>
  <style>
    body { margin: 0; color: #333; }
  </style>
</head>
<body>
  <input id="email" type="email">
  <input id="password" type="password">
  <button id="login-btn">Login</button>
  <button id="logout-btn">Logout</button>
</body>
</html>
```

**Components:**
- `<?cr ... ?>` — Event binding declarations (optional):
  - Syntax: `${'#selector'}.on{event} = handler(${'#param1'}, ...)`
  - Gets compiled to JavaScript event listeners with RPC calls
- `<style>...</style>` — CSS (extracted into `styles-<hash>.css`)
- Rest of the file — HTML (becomes part of `index.html`)

**Generated JavaScript** (from `<?cr ?>` bindings):
- Creates addEventListener for each binding
- Extracts input values from selectors
- Sends POST request to `/_facet/{handler}`
- Handles redirect and HTML update responses
