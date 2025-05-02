local RunService = game:GetService("RunService")
local Types = require(script.Parent.types)
local EffectsFolder = script.Parent.Effects

local EffectManager = {}

EffectManager.__index = EffectManager

function EffectManager:AddEffect(Ins : Instance, Effect: string, value: Types.Acceptable, ...)
    self = self :: Class

    if typeof(value) == 'number' then
		assert(value > 0, "value must be greater than 0")
	elseif typeof(value) ~= 'string' then
		error("value must be a number or string")
		return 
	end

	local args = {...}

    local function apply(obj:Instance)
		self.Effects[obj] = self.Effects[obj] or {}
	
		local EffectProps = {
			value = if typeof(value) == 'number' then 
				{start = workspace:GetServerTimeNow(), duration =  value} 
			else
				 value,
				 
			extraArguments = args,
		}
	
		self.Effects[obj][Effect] =  EffectProps
		
		-- if obj:IsA("Player") then
		-- 	StatesRemote:FireClient(obj, {
		-- 		obj = obj,
		-- 		state = State,
		-- 		props = StateProps
		-- 	})
		-- else
		-- 	StatesRemote:FireAllClients({
		-- 		obj = obj,
		-- 		state = State,
		-- 		props = StateProps
		-- 	})
		-- end

	end

	if typeof(Ins) == "table" then
		for _, obj in pairs(Ins) do
			apply(obj)
		end
	else
		apply(Ins)
	end


end

function EffectManager.new()
	local self = setmetatable({}, EffectManager)

    self.Effects = {
        [Instance]: {
            [string]: {
                value: Types.Acceptable | {start: number, duration: number},
                extraArguments: {[any]: any}
            }
        }
    }
    

    RunService.Heartbeat:Connect(function(DT: number)
        local nowTime = workspace:GetServerTimeNow()
        
        for Instance,Main in pairs(self.Effects) do
            for EffectName,EffectInfo in pairs(Main) do
                local Effect = EffectInfo.value

                if typeof(Effect) == 'table' then
                    if Effect.duration + Effect.start < nowTime then
                        if EffectsFolder:FindFirstChild(EffectName) then
                            local EffectClass = require(EffectsFolder[EffectName])
                            EffectClass.Init(Instance, table.unpack(EffectInfo.extraArguments))
                        end

                        Main[EffectName] = nil
                        continue
                    end
                end
            end
        end

    end)

	return self
end

export type Class = typeof(EffectManager.new())

return EffectManager
