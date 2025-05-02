local RunService = game:GetService("RunService")
local Types = require(script.Parent.types)

local EffectManager = {}

EffectManager.__index = EffectManager

function EffectManager.new()
	local self = setmetatable({}, EffectManager)

    self.Effects = {
        [Instance]: {
            [string]: {
                value: Types.Acceptable | {start: number, duration: number},
                extra: {[any]: any}
            }
        }
    }

    self.Listeners = {
        Heartbeat = {} :: {[string]: {
            Callback:(Instance, Types.Acceptable | nil) -> nil,
        }} | {},

        Stepped = {} :: {[string]: {
            Callback:(number, Instance, Types.AcceptableState | nil) -> nil,
        }} | {}
    }

	return self
end

export type Class = typeof(EffectManager.new())

return EffectManager
