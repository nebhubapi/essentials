local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StudioService = game:GetService("StudioService")
local SelectionService = game:GetService("Selection")
local HttpService = game:GetService("HttpService")
local DebrisService = game:GetService("Debris")
local MarketplaceService = game:GetService("MarketplaceService")

local PluginSanityCheckers = {}

return function(Global)
	function PluginSanityCheckers.HttpEnabled()
		return pcall(function()
			HttpService:GetAsync('http://www.google.com/')
		end)
	end

	function PluginSanityCheckers.ScriptInjectionEnabled()
		return pcall(function()
			local NewScript = Instance.new("Script", UserInputService)
			DebrisService:AddItem(NewScript, 0.5)
		end)
	end

	function PluginSanityCheckers.PluginUpToDate()
		local PluginId = 75248355839509
		local PluginInfo = MarketplaceService:GetProductInfo(PluginId)
		local PluginDescription = PluginInfo.Description

		local MarketVersion = string.match(PluginDescription, "{%s*Current%s+Version:%s*v([%d%.%a]+)%s*}")

		if MarketVersion then
			if MarketVersion == Global.EssentialsVersion then
				return true
			end
		end

		return nil
	end

	function PluginSanityCheckers.StartAutoCheckPluginVersion()
		local LastCheck = 0

		if Global.EssentialsConnections["PluginVersionAutoCheck"] ~= nil then
			Global.EssentialsConnections["PluginVersionAutoCheck"]:Disconnect()
			Global.EssentialsConnections["PluginVersionAutoCheck"] = nil
		end

		Global.EssentialsConnections["PluginVersionAutoCheck"] = RunService.Heartbeat:Connect(function()
			if tick() - LastCheck >= 60 then
				LastCheck = tick()
				if not PluginSanityCheckers.PluginUpToDate() then
					Global.APIFunctions.Notifications.Notify(Global.PluginImages["EssentialsUnloaded.png"].Image, "Plugin outdated", "Essentials just updated! Please update the plugin to access new features and fixes.")
				end
			end
		end)
	end
	
	return PluginSanityCheckers
end
