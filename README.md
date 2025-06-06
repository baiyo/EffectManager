# EffectManager

## Documentation
To add new effects create a new module under the effects folder


### Fetching
```lua
local EffectManager = require(path.to.EffectManager)
```

### Example usage

```lua

local Players = game:GetService("Players")

local EffectManager = require(path.to.EffectManager)

local EffectRunner = EffectManager.new()

Players.PlayerAdded:Connect(function(Player)
 Player.CharacterAdded:Connect(function(char)
        -- Shock is active for 5 seconds
        EffectRunner:AddEffect(Player, "Shock", 5)
    end)
end)

-- Shock Module
local Shock = {}

function Shock.Init(dt: number, Player: Player, ...)
    Player.Character.Humanoid.Health -= (5 * dt)
end

return Shock
```