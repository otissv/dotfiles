# Fresh Monokai

A Monokai-inspired color theme for the [Fresh](https://github.com/sinelaw/fresh) terminal text editor.

Monokai is a classic dark color scheme originally popularized by the [Monokai](https://monokai.pro/) theme for Sublime Text. This port brings the signature vibrant, high-contrast palette to Fresh with full editor, UI, syntax, and diagnostic coverage.

## Installation

Two options — choose whichever fits your workflow.

### Option 1: Clone the repo (recommended)

```bash
git clone https://github.com/Zetaphor/fresh-monokai-theme.git ~/.config/fresh/themes/monokai
```

Then set it in your config:

```json
{
  "theme": "monokai"
}
```

### Option 2: Download the file directly

```bash
mkdir -p ~/.config/fresh/themes
curl -o ~/.config/fresh/themes/monokai.json \
  https://raw.githubusercontent.com/Zetaphor/fresh-monokai-theme/main/monokai.json
```

Then set it in your config:

```json
{
  "theme": "monokai.json"
}
```

Both forms (`"monokai"` and `"monokai.json"`) work — Fresh resolves theme names relative to `~/.config/fresh/themes/`.

### Selecting via the Command Palette

After installing, you can also switch themes inside Fresh:

1. Press `Ctrl+P` to open the command palette
2. Search for **"Select Theme"**
3. Choose **Monokai** from the list

## Colors

### Editor

| Token           | Value       | Description            |
|----------------|-------------|------------------------|
| `bg`           | `[39, 40, 34]` | Editor background   |
| `fg`           | `[248, 248, 242]` | Default text      |
| `cursor`       | `[248, 248, 240]` | Text cursor        |
| `selection_bg` | `[73, 72, 62]` | Selection background    |
| `current_line_bg` | `[62, 61, 50]` | Current line highlight |

### Syntax Highlighting

| Token                | Value          | Color     |
|----------------------|----------------|-----------|
| `keyword`            | `[249, 38, 114]` | Pink    |
| `string`             | `[230, 219, 116]` | Yellow  |
| `function`           | `[166, 226, 46]` | Green   |
| `type`               | `[102, 217, 239]` | Cyan    |
| `constant`           | `[174, 129, 255]` | Purple  |
| `comment`            | `[117, 113, 94]`  | Gray    |
| `variable`           | `[248, 248, 242]` | White   |
| `operator`           | `[249, 38, 114]`  | Pink    |

### Diagnostics

| Token  | Value            |
|--------|------------------|
| Error  | `[249, 38, 114]` |
| Warning| `[230, 219, 116]`|
| Info   | `[102, 217, 239]`|
| Hint   | `[117, 113, 94]` |

## Inheritance

This theme extends the built-in `dark` base theme, so it only defines the colors that differ from the default. See [Fresh Themes → Inheritance](https://github.com/sinelaw/fresh/blob/main/docs/features/themes.md#inheritance) for details.

## Theme File

The full theme can be edited directly at `~/.config/fresh/themes/monokai.json`. Fresh includes a visual **Theme Editor** — open it via `Ctrl+P` → "Edit Theme" for live preview while tweaking colors.

## License

MIT
