# TopBar

Horizontal button strip rendered inside Roblox's topbar-safe inset area.

## Features

- **Built-in Favourite / Like+Join button** — red heart icon whose default
  action calls `AvatarEditorService:PromptSetFavorite`.  Can be replaced at
  runtime with a custom open/close panel (e.g. the Monetization2 Like & Join
  prompt) via `SetFavouriteAction`.
- **Custom buttons** — add any number of icon buttons with hover animation
  (spring-driven size + colour).  Each button can be a simple toggle
  (fire-and-forget) or an open/close pair that participates in the
  "only-one-open" policy.
- **Visibility control** — show or hide the entire bar programmatically.

## Dependencies

```
ReplicatedFirst.Fusion3   (Fusion 0.3 / 0.4)
```

## Rojo Project Setup

```json
"StarterGui": {
  "$ignoreUnknownInstances": true,
  "$path": "src/StarterGui",
  "TopBar": {
    "$path": "submodules/TopBar/StarterGui"
  }
}
```

## API

The module is a factory function.  `require` it and call with an optional
parent instance (defaults to the ModuleScript itself, which lives under
PlayerGui):

```lua
local TopBarAPI = require(PlayerGui:WaitForChild("TopBar"))()
```

### `TopBarAPI:SetVisible(visible: boolean)`

Show or hide the entire TopBar strip.

### `TopBarAPI:SetFavouriteAction(openCallback, closeCallback, externalIsOpen?)`

Replace the built-in favourite button action.

| Parameter | Type | Description |
|---|---|---|
| `openCallback` | `() -> ()` | Called when the button should open the panel |
| `closeCallback` | `() -> ()` | Called when the button should close the panel |
| `externalIsOpen` | `Value<boolean>?` | Optional Fusion3 Value that tracks whether the panel is open — keeps TopBar in sync when the panel is dismissed by other means |

```lua
-- Example: hook up the Monetization2 Like & Join prompt
TopBarAPI:SetFavouriteAction(
    function() LikeAndJoinAPI:Open() end,
    function() LikeAndJoinAPI:Close() end,
    LikeAndJoinAPI.IsOpen
)
```

If `SetFavouriteAction` is never called, the button defaults to
`AvatarEditorService:PromptSetFavorite`.

### `TopBarAPI:TopBarButton(props) -> Value<boolean>`

Add a custom button to the bar.  Returns a Fusion3 `Value<boolean>` that
controls the button's visibility (set it to `false` to hide the button).

| Prop | Type | Description |
|---|---|---|
| `Image` | `string` | Asset ID for the icon |
| `ToggleCallback` | `() -> ()?` | Fire-and-forget action (mutually exclusive with Open/Close) |
| `OpenCallback` | `() -> ()?` | Called when the button opens |
| `CloseCallback` | `() -> ()?` | Called when the button closes |
| `ColorFrom` | `Color3?` | Icon colour at rest (default white) |
| `ColorTo` | `Color3?` | Icon colour on hover (default light grey) |
| `InitialState` | `boolean?` | If `true`, button starts in the "open" state |

## Architecture

```
TopBar/
├── StarterGui/
│   ├── init.luau            — Module: TopBar API + built-in favourite button (Fusion 3)
│   ├── start.client.lua     — Client bootstrap (just requires the module)
│   └── Test.story.luau      — Hoarcekat story
└── README.md
```
