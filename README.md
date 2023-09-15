# renovate-config

Shareable Renovate presets for use in Dintero projects.

## Using presets

There are a few different ways to reference presets from this repo in your Renovate config:

```json5
{
    extends: [
        // Use the default preset
        "github>dintero/renovate-config",

        // Use a specific preset
        "github>dintero/renovate-config:somePreset",
    ],
}
```
