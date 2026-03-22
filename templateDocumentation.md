# Keyboard Layout JSON Configuration

This document describes the JSON structure used to define a keyboard layout, including rows, physical key units, legends, layers, positioning, and per-legend overrides.

> **Important:** JSON does not support comments. The examples below are valid JSON and the explanations are provided separately.

---

## 1. Minimal Structure

```json
{
  "profile": "think",
  "layout": "ISO",
  "font": "Calibri",
  "font_size": 3,
  "rows": [
    {
      "row": 1,
      "units": [
        {
          "widthUnit": "U1",
          "keys": [
            {
              "base": "A",
              "shift": "B",
              "altgr": "C",
              "shift_altgr": "D",
              "row_index": 0,
              "spillRow": 1
            }
          ]
        }
      ]
    }
  ]
}
```

This represents the basic hierarchy:

```text
Configuration
└── rows[]
    └── row
        └── units[]
            └── unit
                └── keys[]
                    └── key
```

---

## 2. Top-Level Properties

```json
{
  "profile": "think",
  "layout": "ISO",
  "font": "Calibri",
  "font_size": 3,
  "rows": []
}
```

### `profile` [*required*]

```json
"profile": "think"
```

Identifies the configuration/profile being used.

---

### `layout` [*required*]

```json
"layout": "ISO"
```

Specifies the physical keyboard layout.

Example:

```text
ISO
```

The layout can be used by the renderer to determine physical key geometry, such as the shape and placement of the ISO Enter key.

---

### `font` [*required*]

```json
"font": "Calibri"
```

Defines the default font used for legends. It can be either:

- the name of a font installed on the system, such as `Calibri`, or
- a path relative to the template directory, such as `Inter-Bold.ttf`.

The renderer resolves template-relative paths before falling back to the system font registry. Individual legends can override this setting with a legend `override`.

---

### `font_size` [*required*]

```json
"font_size": 3
```

Defines the default font size.

Layer-specific and legend-specific values can override this default.

---

### `rows` [*required*]

```json
"rows": []
```

Contains the keyboard rows.

It is an array because a keyboard contains multiple rows.

---

## 3. Rows

A row has the following basic structure:

```json
{
  "row": 1,
  "units": []
}
```

### `row` [*required*]

```json
"row": 1
```

Identifies the keyboard row.

For example:

```json
{
  "row": 1,
  "units": []
}
```

```json
{
  "row": 2,
  "units": []
}
```

```json
{
  "row": 3,
  "units": []
}
```

The exact meaning of the row number is determined by the layout system.

---

### `font` [*optional*]

```json
{
  "row": 2,
  "font": "OpenGorton-Regular.otf",
  "font_size": 4,
  "units": []
}
```

Overrides the default root font for every legend rendered in that row.

This is useful when a row needs a different typeface without redefining the font for every individual key. If a row font is missing, the generator falls back to the root `font` value. A legend-level `override.font` still wins for that specific key/legend.


---

### `font_size` [*optional*]

```json
{
  "row": 2,
  "font": "OpenGorton-Regular.otf",
  "font_size": 4,
  "units": []
}
```

Overrides the default root font size for every legend rendered in that row.

This is useful when a row needs a different font size without redefining it for every individual key. If is missing, the generator falls back to the root `font_size` value. A legend-level `override.font_size` still wins for that specific key/legend.

---

### `units` [*required*]

```json
"units": []
```

Contains the physical units making up the row.

A row can contain multiple units of different widths and heights.

For example:

```text
Row
├── U1
├── U1
├── U1
├── U15
└── ISO_ENTER
```

---

## 4. Units

A unit represents a physical section of a keyboard row.

Minimal example:

```json
{
  "widthUnit": "U1",
  "keys": []
}
```

A unit can contain:

```text
widthUnit
heightUnit
base_layer
shift_layer
altgr_layer
shift_altgr_layer
keys
```

> The renderer expects the key name `shift_altgr_layer`. Older examples sometimes use `shift_altrgr_layer`; that spelling is a legacy typo and should be avoided.

---

### `widthUnit` [*required*]

```json
"widthUnit": "U1"
```

Defines the horizontal size/type of the unit.

Examples:

```text
U1
U15
U2
ISO_ENTER
```

Typical interpretation:

```text
U1  → 1 key unit wide
U15 → 1.5 key units wide
U2  → 2 key units wide
```

`ISO_ENTER` represents the special physical geometry of an ISO Enter key.

The exact dimensions are defined by the layout/renderer.

---

### `heightUnit` [*optional*]

```json
"heightUnit": "U2"
```

Defines the vertical size of the unit.

For example:

```json
{
  "widthUnit": "U1",
  "heightUnit": "U2"
}
```

represents a unit that is one unit wide and two units high.

`heightUnit` is optional when the unit has the normal/default height.

---

## 5. Layers

A unit can define rendering settings for different keyboard layers:

```text
base_layer
shift_layer
altgr_layer
shift_altgr_layer
```

The four layers correspond conceptually to:

| Layer                | Modifier      |
| -------------------- | ------------- |
| `base_layer`         | Normal        |
| `shift_layer`        | Shift         |
| `altgr_layer`        | AltGr         |
| `shift_altgr_layer`  | Shift + AltGr |

A layer controls how the legends belonging to that layer are positioned and rendered.

This is the same precedence order used by the renderer: root defaults first, then per-layer settings, then per-legend overrides.

---

### 5.1 Layer Structure

A layer has this structure:

```json
{
  "font_size": 5,
  "translation": {
    "x": 0,
    "y": 0,
    "z": 0
  },
  "rotation": {
    "x": 0,
    "y": 0,
    "z": 0
  },
  "halign" : "center",
  "valign" : "center"
}
```

---

#### `font_size` [*optional*]

```json
"font_size": 5
```

Defines the default font size for legends in this layer.

For example:

```json
"base_layer": {
  "font_size": 5
}
```

can make base legends larger than Shift legends:

```json
"shift_layer": {
  "font_size": 3.5
}
```

---

#### `translation` [*optional*]

```json
"translation": {
  "x": 0,
  "y": 0,
  "z": 0
}
```

Defines the position offset of the layer's legends.

##### `x`

Horizontal translation.

```json
"x": 1
```

moves the legend along the X axis.

##### `y`

Vertical translation.

```json
"y": -2.5
```

moves the legend along the Y axis.

##### `z`

Depth translation.

```json
"z": 0
```

moves the legend along the Z axis.

Example:

```json
"base_layer": {
  "font_size": 5,
  "translation": {
    "x": 0,
    "y": -2.5,
    "z": 0
  }
}
```

---

#### `rotation` [*optional*]

```json
"rotation": {
  "x": 0,
  "y": 0,
  "z": 0
}
```

Defines the rotation of the layer's legends.

##### `x`

Rotation around the X axis.

##### `y`

Rotation around the Y axis.

##### `z`

Rotation around the Z axis.

For example:

```json
"rotation": {
  "x": 0,
  "y": 0,
  "z": 90
}
```

rotates the legend around the Z axis.

---

#### `halign` [*optional*]

```json
"halign": "center"
```

Defines the horizontal alignment of the text.
Possible values are `["center", left, right]`.

---

#### `valign` [*optional*]

```json
"valign": "center"
```

Defines the vertical alignment of the text.
Possible values are `["center", top, bottom]`.

---

## 7. Keys

The `keys` property contains the legends assigned to the physical unit.

Example:

```json
"keys": [
  {
    "base": "A",
    "shift": "B",
    "altgr": "C",
    "shift_altgr": "D",
    "row_index": 0,
    "spillRow": 1
  }
]
```

Each key can contain:

```text
base
shift
altgr
shift_altgr
row_index
spillRow
```

The legend properties are optional depending on which layers are required.

---

## 8. Key Legends

### `base` [*optional*]

```json
"base": "A"
```

Defines the normal/base legend.

Example:

```json
{
  "base": "1"
}
```

displays:

```text
1
```

---

### `shift` [*optional*]

```json
"shift": "!"
```

Defines the legend produced when Shift is used.

Example:

```json
{
  "base": "1",
  "shift": "!"
}
```

represents:

```text
Normal → 1
Shift  → !
```

---

### `altgr` [*optional*]

```json
"altgr": "@"
```

Defines the legend produced when AltGr is used.

Example:

```json
{
  "base": "Q",
  "altgr": "@"
}
```

represents:

```text
Normal → Q
AltGr  → @
```

---

### `shift_altgr` [*optional*]

```json
"shift_altgr": "€"
```

Defines the legend produced with Shift + AltGr.

Example:

```json
{
  "base": "A",
  "shift": "B",
  "altgr": "C",
  "shift_altgr": "D"
}
```

represents:

```text
Normal        → A
Shift         → B
AltGr         → C
Shift + AltGr → D
```

---

## 9. Legend Types

A legend can be represented in two ways.

### Simple string

```json
"base": "A"
```

This is the normal form.

The legend is simply the string itself.

Conceptually:

```text
legend = "A"
```

A legend can also be a vector asset stored in the template folder, for example:

```json
"base": "custom_icon.svg"
```

or

```json
"base": "custom_icon.dxf"
```

The renderer detects `.svg` and `.dxf` files automatically. SVG assets are converted to DXF internally before rendering, so both formats are valid in the same places where a text legend would normally be used.

---

### Legend with override

A legend can instead be an object:

```json
"base": {
  "value": "A",
  "override": {
    "font_size": 7
  }
}
```

This provides the legend value plus rendering overrides.

The same pattern also works for vector assets:

```json
"base": {
  "value": "custom_icon.svg",
  "override": {
    "font_size": 0.75,
    "rotation": {
      "z": 180
    },
    "translation": {
      "x": 0,
      "y": 0,
      "z": 0
    }
  }
}
```

This is useful for scaling, re-positioning, or rotating imported SVG/DXF art without changing the source file itself.

Conceptually:

```text
Legend
├── value
└── override
    ├── translation
    ├── rotation
    ├── font
    └── font_size
```

---

## 10. Legend `value` [*required*]

```json
"value": "A"
```

Contains the actual legend text or the filename of a vector asset in the template folder.

This can be either:

- plain text, such as `"A"` or `"Esc"`
- an SVG file, such as `"arrow_northwest.svg"`
- a DXF file, such as `"logo.dxf"`

For example:

```json
"base": {
  "value": "A"
}
```

is equivalent to:

```json
"base": "A"
```

when no override is required.

---

## 11. Legend `override` [*optional*]

The `override` object allows a specific legend to override the normal layer/default settings.

Supported override properties are:

```text
translation
rotation
font
font_size
```

Example:

```json
"base": {
  "value": "A",
  "override": {
    "font": "Arial",
    "font_size": 7
  }
}
```

Only the properties that need to be changed need to be supplied.

---

### `override.translation` [*optional*]

```json
"override": {
  "translation": {
    "x": 1,
    "y": 2,
    "z": 0
  }
}
```

Overrides the translation for this specific legend.

---

### `override.rotation` [*optional*]

```json
"override": {
  "rotation": {
    "x": 0,
    "y": 0,
    "z": 90
  }
}
```

Overrides the rotation for this specific legend.

---

### `override.font` [*optional*]

```json
"override": {
  "font": "Arial"
}
```

Overrides the font for this specific legend.

---

### `override.font_size` [*optional*]

```json
"override": {
  "font_size": 7
}
```

Overrides the font size for this specific legend.

---

## 12. Override Precedence

The configuration has multiple levels of rendering settings.

Conceptually:

```text
Global defaults
      ↓
Layer settings
      ↓
Legend override
```

For example:

```json
{
  "font": "Calibri",
  "font_size": 3,

  "rows": [
    {
      "units": [
        {
          "base_layer": {
            "font_size": 5
          },

          "keys": [
            {
              "base": {
                "value": "A",
                "override": {
                  "font_size": 8
                }
              }
            }
          ]
        }
      ]
    }
  ]
}
```

The `A` legend ultimately uses:

```text
font_size = 8
```

because the legend-specific override takes precedence over the layer setting.

---

## 13. `row_index` [*required*]

```json
"row_index": 0
```

Identifies the key's row/index position within the layout system.

Example:

```json
{
  "base": "Q",
  "row_index": 1
}
```

`row_index` is a property of the **key**, not the row object.

This is different from:

```json
"row": 1
```

which identifies the containing keyboard row.

---

## 14. `spillRow` [*optional*]

```json
"spillRow": [4, 13]
```

Defines the row-spanning relationship for a key that extends into another row.

This is used for keys such as ISO Enter, numpad keys, and other keys whose geometry occupies more than one row.

**Structure:**

```json
"spillRow": [extendToRow, positionInRow]
```

Where:
- `extendToRow` — the additional row the key extends into
- `positionInRow` — the key's position in that row

For example:

```json
{
  "base": "Enter",
  "row_index": 13,
  "spillRow": [4, 13]
}
```

This means the key is positioned at index 13 and occupies the row-spanning relationship with row 4 at that position.

Other examples:

```json
{
  "base": "+",
  "row_index": 17,
  "spillRow": [4, 17]
}
```

```json
{
  "base": "Enter",
  "row_index": 12,
  "spillRow": [5, 17]
}
```

`spillRow` is optional. If it is absent, the key is treated as occupying only its primary row.

---

# Complete Example

The following example demonstrates the complete structure, including all layer types, key properties, and a legend override:

```json
{
  "profile": "think",
  "layout": "ISO",
  "font": "Calibri",
  "font_size": 3,

  "rows": [
    {
      "row": 1,
      "font": "Calibri",

      "units": [
        {
          "widthUnit": "U1",
          "heightUnit": "U1",

          "base_layer": {
            "font_size": 5,
            "translation": {
              "x": 0,
              "y": -2.5,
              "z": 0
            },
            "rotation": {
              "x": 0,
              "y": 0,
              "z": 0
            }
          },

          "shift_layer": {
            "font_size": 3.5,
            "translation": {
              "x": 0,
              "y": 2.5,
              "z": 0
            },
            "rotation": {
              "x": 0,
              "y": 0,
              "z": 0
            }
          },

          "altgr_layer": {
            "font_size": 3,
            "translation": {
              "x": 0,
              "y": 0,
              "z": 0
            },
            "rotation": {
              "x": 0,
              "y": 0,
              "z": 0
            }
          },

          "shift_altgr_layer": {
            "font_size": 3,
            "translation": {
              "x": 0,
              "y": 0,
              "z": 0
            },
            "rotation": {
              "x": 0,
              "y": 0,
              "z": 0
            }
          },

          "keys": [
            {
              "base": {
                "value": "A",
                "override": {
                  "font": "Arial",
                  "font_size": 7,
                  "translation": {
                    "x": 1,
                    "y": 0,
                    "z": 0
                  },
                  "rotation": {
                    "x": 0,
                    "y": 0,
                    "z": 0
                  }
                }
              },

              "shift": "B",
              "altgr": "C",
              "shift_altgr": "D",

              "row_index": 0,
              "spillRow": 1
            }
          ]
        }
      ]
    }
  ]
}
```

---

# 16. Schema Summary

| Property             | Level          | Required? | Purpose                          |
| -------------------- | -------------- | --------- | -------------------------------- |
| `profile`            | Root           | Required | Configuration/profile name       |
| `layout`             | Root           | Required | Physical keyboard layout         |
| `font`               | Root           | Required | Default font                     |
| `font_size`          | Root           | Required | Default font size                |
| `rows`               | Root           | Required | List of keyboard rows            |
| `row`                | Row            | Required | Row identifier                   |
| `font`               | Row            | Optional | Row-level font override          |
| `units`              | Row            | Required | Physical units in the row        |
| `widthUnit`          | Unit           | Required | Horizontal unit/size             |
| `heightUnit`         | Unit           | Optional | Vertical unit/size               |
| `base_layer`         | Unit           | Optional | Base legend rendering settings    |
| `shift_layer`        | Unit           | Optional | Shift legend rendering settings   |
| `altgr_layer`        | Unit           | Optional | AltGr legend rendering settings   |
| `shift_altgr_layer`  | Unit           | Optional | Shift + AltGr rendering settings  |
| `keys`               | Unit           | Required | Key definitions                   |
| `base`               | Key            | Optional | Normal legend                    |
| `shift`              | Key            | Optional | Shift legend                     |
| `altgr`              | Key            | Optional | AltGr legend                     |
| `shift_altgr`        | Key            | Optional | Shift + AltGr legend             |
| `row_index`          | Key            | Required | Key position/index               |
| `spillRow`           | Key            | Optional | Additional/spilled row           |
| `value`              | Legend object  | Required | Legend text                      |
| `override`           | Legend object  | Optional | Per-legend rendering overrides   |
| `translation`        | Layer/Override | Optional | X/Y/Z position                   |
| `rotation`           | Layer/Override | Optional | X/Y/Z rotation                   |
| `font`               | Override       | Optional | Per-legend font                  |
| `font_size`          | Layer/Override | Optional | Font size                        |

---

# 17. Compact Mental Model

The entire format can be remembered as:

```text
ROOT
│
├── defaults
│   ├── profile
│   ├── layout
│   ├── font
│   └── font_size
│
└── rows[]
    │
    └── ROW
        ├── row
        ├── font
        │
        └── units[]
            │
            └── UNIT
                ├── widthUnit
                ├── heightUnit
                │
                ├── LAYERS
                │   ├── base_layer
                │   ├── shift_layer
                │   ├── altgr_layer
                │   └── shift_altgr_layer
                │
                └── keys[]
                    │
                    └── KEY
                        ├── base
                        ├── shift
                        ├── altgr
                        ├── shift_altgr
                        ├── row_index
                        └── spillRow

Legend
├── "A"
│
└── {
      "value": "A",
      "override": {
        "translation": {...},
        "rotation": {...},
        "font": "...",
        "font_size": ...
      }
    }
```

The most important distinction is that **`row` describes the keyboard row, `row_index` identifies the key position, and `spillRow` allows a key to extend/associate with another row**.
