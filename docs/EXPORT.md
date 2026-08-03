# Exporting a FlowKit project

## Before export

1. Open the Godot editor with your game project (FlowKit addon enabled).
2. **FlowKit → Edit → Generate Provider Manifest**  
   Or export will try to generate one automatically via the export plugin.
3. Confirm `addons/flowkit/saved/provider_manifest.tres` exists and is recent.

## Why

Exported builds cannot scan `res://addons/flowkit/**` folders.  
The **provider manifest** lists only scripts your sheets/behaviors need so unused providers are stripped.

## Object Mode

Object Mode packs store data on **nodes** (`flowkit_behaviors`, `flowkit_object`, `flowkit_variables`).  
Those travel with the scene — no extra step.  
Still generate the manifest so behaviors like `enemy_patrol` / `collectible_pickup` are included.

## Recommended checklist

- [ ] Play demos / your scenes once in editor  
- [ ] Generate provider manifest  
- [ ] Export debug build smoke-test  
- [ ] Export release  

## Demos

Demos under `addons/flowkit/demos/` are optional for end users.  
For a clean game export, do not set demo scenes as main; copy patterns into your project scenes.

## CI

`tools/ci_smoke.gd` validates core classes + registry load.  
GitHub Actions runs smoke + GUT + matrix generation.
