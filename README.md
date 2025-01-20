# Module Installation

## Current Features
- Invite friends
- Favourite the game

## Dependencies:
```url
https://github.com/dphfox/Fusion
```

* Requires fusion src installed to Replicated Storage *

## Add to Rojo Project File:

```json
    "StarterGui" : {
      "$ignoreUnknownInstances": true,
      "$path": "src/StarterGui", 
      "TopBar":{
        "$path": "submodules/TopBar/StarterGui"
      }
    },
```
