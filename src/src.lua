local RunService = game:GetService("RunService")
local Types = require(script.Parent.Types)
local EffectsFolder = script.Parent.Effects

local EffectManager = {
	Effects = {} :: {
		[Instance]: {
			[string]: {
				value: Types.Acceptable | { start: number, duration: number },
				extraArguments: { [any]: any },
			},
		},
	},
	_runningConnection = nil :: RBXScriptConnection?,
}

local function startEffectLoop()
	if EffectManager._runningConnection then return end
	
	EffectManager._runningConnection = RunService.Heartbeat:Connect(function(DT)
		local nowTime = workspace:GetServerTimeNow()
		local stillHasEffects = false

		for instance, effects in pairs(EffectManager.Effects) do
			for effectName, effectInfo in pairs(effects) do
				local effect = effectInfo.value
				stillHasEffects = true

				local module = EffectsFolder:FindFirstChild(effectName)
				if module then
					local effectClass = require(module)
					if typeof(effectClass.Init) == "function" then
						task.defer(effectClass.Init, DT, instance, table.unpack(effectInfo.extraArguments))
					end
				end

				if typeof(effect) == "table" and effect.start + effect.duration < nowTime then
					effects[effectName] = nil
				end
			end

			if next(effects) == nil then
				EffectManager.Effects[instance] = nil
			end
		end

		if not stillHasEffects then
			EffectManager._runningConnection:Disconnect()
			EffectManager._runningConnection = nil
		end
	end)
end

function EffectManager:AddEffect(ins: Instance | { Instance }, effect: string, value: Types.Acceptable, ...: any)
	if typeof(value) == "number" then
		assert(value > 0, "value must be greater than 0")
	elseif typeof(value) ~= "string" then
		error("value must be a number or string")
	end

	local args = { ... }

	local function apply(obj: Instance)
		self.Effects[obj] = self.Effects[obj] or {}
		self.Effects[obj][effect] = {
			value = typeof(value) == "number" and {
				start = workspace:GetServerTimeNow(),
				duration = value,
			} or value,
			extraArguments = args,
		}
	end

	if typeof(ins) == "table" then
		for _, obj in ipairs(ins) do
			apply(obj)
		end
	else
		apply(ins)
	end

	startEffectLoop()
end

function EffectManager:RemoveEffect(instance: Instance, effect: string)
	if self.Effects[instance] then
		self.Effects[instance][effect] = nil
		if next(self.Effects[instance]) == nil then
			self.Effects[instance] = nil
		end
	end
end

function EffectManager:HasEffect(instance: Instance, effect: string)
	assert(typeof(instance) == "Instance", "Object must be an Instance")
	assert(typeof(effect) == "string", "Effect must be a string")
	return self.Effects[instance] and self.Effects[instance][effect] ~= nil
end

return EffectManager