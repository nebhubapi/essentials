local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StudioService = game:GetService("StudioService")
local SelectionService = game:GetService("Selection")
local HttpService = game:GetService("HttpService")
local DebrisService = game:GetService("Debris")
local MarketplaceService = game:GetService("MarketplaceService")

local EngineFuse = {}

return function(Global)
	function EngineFuse.PlaySound(Sound)
		local SoundPlayer = Instance.new("Sound")
		SoundPlayer.SoundId = Sound.SoundId
		SoundPlayer.Volume = Sound.Volume
		SoundPlayer.Parent = Global.EssentialsAudioPlayer
		SoundPlayer.Ended:Once(function()
			SoundPlayer:Destroy()
		end)
		SoundPlayer:Play()
	end

	function EngineFuse.AddService(Service)
		if not Global.RegisteredService[Service.ServiceName] then
			Global.RegisteredService[Service.ServiceName] = Service
		end
	end
	
	return EngineFuse
end
