local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local StudioService = game:GetService("StudioService")
local SelectionService = game:GetService("Selection")
local HttpService = game:GetService("HttpService")
local DebrisService = game:GetService("Debris")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local EngineInterfaceFunctions = {
	TabPreviewShown = false;
}

return function(Global)
	function EngineInterfaceFunctions.ApplyThemeToComponent(UIComponent)
		local ColorThemeAttribute = UIComponent:GetAttribute("ColorTheme")
		if ColorThemeAttribute then
			for Pair in string.gmatch(ColorThemeAttribute, "[^%.]+") do
				local Property, ThemeKey = string.match(Pair, "([^=]+)=([^=]+)")
				if Property and ThemeKey and Global.CurrentThemePack[ThemeKey] then
					pcall(function()
						UIComponent[Property] = Global.CurrentThemePack[ThemeKey]
					end)
				end
			end
		end

		for _, UIDescendant in pairs(UIComponent:GetDescendants()) do
			local DescendantThemeAttribute = UIDescendant:GetAttribute("ColorTheme")
			if DescendantThemeAttribute then
				for Pair in string.gmatch(DescendantThemeAttribute, "[^%.]+") do
					local Property, ThemeKey = string.match(Pair, "([^=]+)=([^=]+)")
					if Property and ThemeKey and Global.CurrentThemePack[ThemeKey] then
						pcall(function()
							UIDescendant[Property] = Global.CurrentThemePack[ThemeKey]
						end)
					end
				end
			end
		end
	end

	function EngineInterfaceFunctions.ClampToScreen(Position, UIElement, AdditionalSize)
		local ScreenSize = Global.NewInterface.AbsoluteSize
		local UISize = UIElement.AbsoluteSize

		local HalfX, HalfY = UISize.X * UIElement.AnchorPoint.X, UISize.Y * UIElement.AnchorPoint.Y
		local MinX, MinY = HalfX, HalfY
		local MaxX, MaxY = ScreenSize.X - (UISize.X - HalfX), ScreenSize.Y - (UISize.Y - HalfY)

		local ClampedX = math.clamp(Position.X, MinX, MaxX)
		local ClampedY = math.clamp(Position.Y, MinY, MaxY)
		return ClampedX, ClampedY
	end

	function EngineInterfaceFunctions.ApplyTheme(ThemePack)
		Global.CurrentThemePack = ThemePack

		if Global.EssentialsStartupDone == true then
			Global.EssentialsToggle.Icon = Global.PluginImages[`Essentials{Global.CurrentThemePack.DerivedFrom}Loaded.png`].Image
		elseif Global.EssentialsStartupDone == false then
			Global.EssentialsToggle.Icon = Global.PluginImages[`Essentials{Global.CurrentThemePack.DerivedFrom}Unloaded.png`].Image
		end

		for _, UIComponent in pairs(Global.NewInterface:GetDescendants()) do
			local ColorThemeAttribute = UIComponent:GetAttribute("ColorTheme")
			if ColorThemeAttribute then
				for Pair in string.gmatch(ColorThemeAttribute, "[^%.]+") do
					local Property, ThemeKey = string.match(Pair, "([^=]+)=([^=]+)")
					if Property and ThemeKey and Global.CurrentThemePack[ThemeKey] then
						pcall(function()
							Global.Spring:Target(UIComponent, 1, 3, {
								[Property] = Global.CurrentThemePack[ThemeKey],
							})
						end)
					end
				end
			end
		end
	end

	function EngineInterfaceFunctions.NewServiceSelectionTab()
		local NewTabConnections = {}

		local NewServiceTab = Global.APIFunctions.Tab.new("New tab")
		NewServiceTab:SetTabLogo(Global.PluginImages["NewTabLogo.png"].Image)
		Global.DefaultEngineLoadup.Visible = false
		Global.EngineSignals.NewTabOpened:Fire()

		local ServiceSelectionInterface = require(Global.InterfaceAssets:WaitForChild("Templates"):WaitForChild("ServiceSelection"))(Global.Component)()
		NewServiceTab:SetInterface(ServiceSelectionInterface)

		EngineInterfaceFunctions.ApplyThemeToComponent(ServiceSelectionInterface)

		ServiceSelectionInterface:WaitForChild("Title"):WaitForChild("EngineTitle").Size = UDim2.fromScale(0.774, 0.192)
		ServiceSelectionInterface:WaitForChild("Title"):WaitForChild("EngineTitle").Position = UDim2.fromScale(0.5, 0.432)
		ServiceSelectionInterface:WaitForChild("Services").Position = UDim2.fromScale(0.5, 0.8)

		Global.Spring:Target(ServiceSelectionInterface:WaitForChild("Title"):WaitForChild("EngineTitle"), 0.9, 2, {
			Size = UDim2.fromScale(0.412, 0.102),
			Position = UDim2.fromScale(0.5, 0.148)
		})

		Global.Spring:Target(ServiceSelectionInterface:WaitForChild("Services"), 0.9, 2, {
			Position = UDim2.fromScale(0.5, 0.565)
		})

		local AddServicesHover, AddServicesUnhover = Global.MouseEvents.Track(ServiceSelectionInterface:WaitForChild("Services"):WaitForChild("ScrollingFrame"):WaitForChild("AddService"):WaitForChild("Container"):WaitForChild("Button"))

		local HoveringAddServices = false

		NewTabConnections["HoverAddServices"] = AddServicesHover:Connect(function()
			HoveringAddServices = true

			Global.Spring:Target(ServiceSelectionInterface:WaitForChild("Services"):WaitForChild("ScrollingFrame"):WaitForChild("AddService"):WaitForChild("Container"), 1, 3, {Position = UDim2.fromScale(0.5, 0.5)})
			Global.Spring:Target(ServiceSelectionInterface:WaitForChild("Services"):WaitForChild("ScrollingFrame"):WaitForChild("AddService"):WaitForChild("Container"):WaitForChild("ServiceName"), 1, 3, {TextTransparency = 0})

			task.delay(1, function()
				if HoveringAddServices then
					EngineInterfaceFunctions.ShowTip(`Download more services`)
				else
					EngineInterfaceFunctions.HideTip()
				end
			end)
		end)

		NewTabConnections["UnhoverAddServices"] = AddServicesUnhover:Connect(function()
			HoveringAddServices = false

			Global.Spring:Target(ServiceSelectionInterface:WaitForChild("Services"):WaitForChild("ScrollingFrame"):WaitForChild("AddService"):WaitForChild("Container"), 1, 3, {Position = UDim2.fromScale(0.5, 0.6)})
			Global.Spring:Target(ServiceSelectionInterface:WaitForChild("Services"):WaitForChild("ScrollingFrame"):WaitForChild("AddService"):WaitForChild("Container"):WaitForChild("ServiceName"), 1, 3, {TextTransparency = 1})

			EngineInterfaceFunctions.HideTip()
		end)

		NewTabConnections["UnhoverAddServices"] = ServiceSelectionInterface:WaitForChild("Services"):WaitForChild("ScrollingFrame"):WaitForChild("AddService"):WaitForChild("Container"):WaitForChild("Button").Activated:Connect(function()
			HoveringAddServices = false
			EngineInterfaceFunctions.HideTip()

			Global.APIFunctions.ServicePlace.OpenServicePlace()
		end)

		local ServicesAdded = 0

		NewTabConnections["ServiceAddedListener"] = Global.EngineSignals.NewServiceAdded:Connect(function(Service)
			local NewServiceButton = Global.ComponentBuilder:Attach(require(Global.InterfaceAssets:WaitForChild("Templates"):WaitForChild("ServiceButtonTemplate"))(Global.Component), ServiceSelectionInterface:WaitForChild("Services"):WaitForChild("ScrollingFrame")).Instance

			EngineInterfaceFunctions.ApplyThemeToComponent(NewServiceButton)

			NewServiceButton.LayoutOrder = -999

			local Logo = NewServiceButton:WaitForChild("Logo")
			Global.Spring:Target(Logo, 0.7, 3.6, {Size = UDim2.fromScale(1, 1)})

			Global.Spring:Target(NewServiceButton:WaitForChild("Logo"), 1, 3, {Position = UDim2.fromScale(0.5, 0.5)})
			Global.Spring:Target(NewServiceButton:WaitForChild("Logo"):WaitForChild("ServiceName"), 1, 3, {TextTransparency = 0})

			task.delay(0.5, function()
				Global.Spring:Target(NewServiceButton:WaitForChild("Logo"), 1, 3, {Position = UDim2.fromScale(0.5, 0.6)})
				Global.Spring:Target(NewServiceButton:WaitForChild("Logo"):WaitForChild("ServiceName"), 1, 3, {TextTransparency = 1})
			end)

			Logo:WaitForChild("Logo").Image = Service.ServiceLogo
			Logo:WaitForChild("ServiceName").Text = string.upper(Service.ServiceName)
			NewServiceButton:SetAttribute("ServiceButton", true)

			local ButtonHover, ButtonUnhover = Global.MouseEvents.Track(NewServiceButton:WaitForChild("Logo"):WaitForChild("Button"))

			local ButtonHovering = true

			NewTabConnections[Service.ServiceName.."ButtonEntered"] = ButtonHover:Connect(function()
				ButtonHovering = true

				Global.Spring:Target(NewServiceButton:WaitForChild("Logo"), 1, 3, {Position = UDim2.fromScale(0.5, 0.5)})
				Global.Spring:Target(NewServiceButton:WaitForChild("Logo"):WaitForChild("ServiceName"), 1, 3, {TextTransparency = 0})

				task.delay(1, function()
					if ButtonHovering then
						EngineInterfaceFunctions.ShowTip(`Open {Service.ServiceName} in a new tab`)
					else
						EngineInterfaceFunctions.HideTip()
					end
				end)
			end)

			NewTabConnections[Service.ServiceName.."ButtonLeft"] = ButtonUnhover:Connect(function()
				ButtonHovering = false

				Global.Spring:Target(NewServiceButton:WaitForChild("Logo"), 1, 3, {Position = UDim2.fromScale(0.5, 0.6)})
				Global.Spring:Target(NewServiceButton:WaitForChild("Logo"):WaitForChild("ServiceName"), 1, 3, {TextTransparency = 1})

				EngineInterfaceFunctions.HideTip()
			end)

			NewTabConnections[Service.ServiceName.."Activated"] = NewServiceButton:WaitForChild("Logo"):WaitForChild("Button").Activated:Connect(function()
				ButtonHovering = false
				EngineInterfaceFunctions.HideTip()

				for i, Connection in pairs(NewTabConnections) do
					if Connection ~= nil then
						Connection:Disconnect()
						NewTabConnections[i] = nil
					end
				end

				NewServiceTab:SetInterface(nil)

				Service.ServiceFunction({
					EssentialsPlugin = Global.EssentialsPlugin;
					EssentialsPack = {
						Libraries = Global.Libraries;
						Components = Global.Components;
						Core = Global.Core;
					};
					EssentialsMouse = Global.EssentialsMouse;
					EngineInterfaceFunctions = Global.EngineInterfaceFunctions;
					EngineFuse = Global.EngineFuse;
					EngineSignals = Global.EngineSignals;
					APIFunctions = Global.APIFunctions;
					EssentialsMainUI = Global.EngineInterface;
					NotificationsInterface = Global.NotificationsInterface;
					ActionsInterface = Global.ActionsInterface;
					EssentialsLauncher = Global.EssentialsLauncher;
					NewInterface = Global.NewInterface
				}, NewServiceTab)
			end)
		end)

		for i, Service in pairs(Global.RegisteredService) do
			ServicesAdded += 1

			local NewServiceButton = Global.ComponentBuilder:Attach(require(Global.InterfaceAssets:WaitForChild("Templates"):WaitForChild("ServiceButtonTemplate"))(Global.Component), ServiceSelectionInterface:WaitForChild("Services"):WaitForChild("ScrollingFrame")).Instance

			EngineInterfaceFunctions.ApplyThemeToComponent(NewServiceButton)

			local Logo = NewServiceButton:WaitForChild("Logo")
			task.delay(ServicesAdded * 0.08, function()
				Global.Spring:Target(Logo, 1, 3.6, {Size = UDim2.fromScale(1, 1)})
			end)
			Logo:WaitForChild("Logo").Image = Service.ServiceLogo
			Logo:WaitForChild("ServiceName").Text = string.upper(Service.ServiceName)
			NewServiceButton:SetAttribute("ServiceButton", true)

			local ButtonHovering = false

			local ButtonHover, ButtonUnhover = Global.MouseEvents.Track(NewServiceButton:WaitForChild("Logo"):WaitForChild("Button"))

			NewTabConnections[i.."ButtonEntered"] = ButtonHover:Connect(function()
				ButtonHovering = true

				Global.Spring:Target(NewServiceButton:WaitForChild("Logo"), 1, 3, {Position = UDim2.fromScale(0.5, 0.5)})
				Global.Spring:Target(NewServiceButton:WaitForChild("Logo"):WaitForChild("ServiceName"), 1, 3, {TextTransparency = 0})

				task.delay(1, function()
					if ButtonHovering then
						EngineInterfaceFunctions.ShowTip(`Open {Service.ServiceName} in a new tab`)
					else
						EngineInterfaceFunctions.HideTip()
					end
				end)
			end)

			NewTabConnections[i.."ButtonLeft"] = ButtonUnhover:Connect(function()
				ButtonHovering = false

				Global.Spring:Target(NewServiceButton:WaitForChild("Logo"), 1, 3, {Position = UDim2.fromScale(0.5, 0.6)})
				Global.Spring:Target(NewServiceButton:WaitForChild("Logo"):WaitForChild("ServiceName"), 1, 3, {TextTransparency = 1})

				EngineInterfaceFunctions.HideTip()
			end)

			NewTabConnections[i.."Activated"] = NewServiceButton:WaitForChild("Logo"):WaitForChild("Button").Activated:Connect(function()
				ButtonHovering = false
				EngineInterfaceFunctions.HideTip()

				for i, Connection in pairs(NewTabConnections) do
					if Connection ~= nil then
						Connection:Disconnect()
						NewTabConnections[i] = nil
					end
				end

				NewServiceTab:SetInterface(nil)

				Service.ServiceFunction(NewServiceTab)
			end)
		end
	end

	function EngineInterfaceFunctions.ShowTip(TipText)
		Global.TipInterface.Position = UDim2.fromOffset(Global.EssentialsMouse.X + 6, Global.EssentialsMouse.Y + 14)
		Global.TipInterface:WaitForChild("Container"):WaitForChild("ActionTip").Text = TipText
		Global.TipInterface.GroupTransparency = 1
		Global.Spring:Target(Global.TipInterface, 1, 4, {GroupTransparency = 0})
		Global.Spring:Target(Global.TipInterface:WaitForChild("UIStroke"), 1, 4, {Transparency = 0})
	end

	function EngineInterfaceFunctions.HideTip()
		Global.Spring:Target(Global.TipInterface, 1, 4, {GroupTransparency = 1})
		Global.Spring:Target(Global.TipInterface:WaitForChild("UIStroke"), 1, 4, {Transparency = 1})
	end

	function EngineInterfaceFunctions.UpdateTab(Elapse)
		task.spawn(function()
			local Updated = false
			task.delay(Elapse, function()
				Updated = true
			end)
			while task.wait(0.05) do
				if Updated == true then
					break
				end
				Global.APIFunctions.Tab.UpdateTabSizes()
			end
		end)
	end

	function EngineInterfaceFunctions.MinimizeEssentials(Minimize)
		local FinalSize = UDim2.fromOffset(820, 476)

		if Minimize then
			Global.EssentialsLauncher.Visible = true
			Global.EssentialsLauncher.Position = Global.EngineInterface.Position
			Global.EssentialsLauncher.Size = UDim2.fromOffset(0, 0)

			Global.LastPositionBeforeMinimize = Global.EngineInterface.Position
			Global.LastSizeBeforeMinimize = Global.EngineInterface.Size

			Global.Spring:Target(Global.EngineInterface, 1, 6, {Size = UDim2.fromOffset(0, 0)})

			Global.Spring:Target(Global.EngineInterface, 0.8, 4, {Position = Global.LastPositionLauncher})
			Global.Spring:Target(Global.EssentialsLauncher, 0.8, 4, {Position = Global.LastPositionLauncher})
			Global.Spring:Target(Global.EssentialsLauncher, 1, 4, {Size = UDim2.fromOffset(50, 50)})

			task.wait(0.13)

			Global.EngineInterface.Visible = false
		else
			Global.EngineInterface.Visible = true
			Global.EngineInterface.Position = Global.EssentialsLauncher.Position

			Global.LastPositionLauncher = Global.EssentialsLauncher.Position

			Global.Spring:Target(Global.EngineInterface, 0.7, 3, {Size = Global.LastSizeBeforeMinimize})
			Global.Spring:Target(Global.EngineInterface, 1, 4, {Position = Global.LastPositionBeforeMinimize})

			Global.Spring:Target(Global.EssentialsLauncher, 0.7, 3, {Size = UDim2.fromOffset(0, 0)})
			Global.Spring:Target(Global.EssentialsLauncher, 0.8, 4, {Position = Global.LastPositionBeforeMinimize})

			task.wait(0.13)

			Global.EssentialsLauncher.Visible = false
		end

		EngineInterfaceFunctions.UpdateTab(4)
	end

	Global.TopmostCounter = Global.TopmostCounter or 0

	function EngineInterfaceFunctions.TopmostWindow(Window)
		if not Window then return end

		local Interface = Global.NewInterface
		local Windows = {}

		for _, OtherWindow in pairs(Interface:GetChildren()) do
			if OtherWindow:GetAttribute("Window") then
				table.insert(Windows, OtherWindow)
			end
		end

		for i, w in ipairs(Windows) do
			if w == Window then
				table.remove(Windows, i)
				break
			end
		end

		for i, w in ipairs(Windows) do
			w.ZIndex = i
		end

		Window.ZIndex = #Windows + 1
	end

	function EngineInterfaceFunctions.ToggleEssentials()
		if Global.EssentialsDebounce == true then return end
		Global.EssentialsDebounce = true

		Global.EssentialsToggled = not Global.EssentialsToggled

		task.spawn(function()
			task.wait(0.62)
			Global.EssentialsDebounce = false
		end)

		Global.EssentialsToggle:SetActive(Global.EssentialsToggled)

		Global.Spring:Target(Global.EngineInterface:WaitForChild("UICorner"), 0.8, 3, {CornerRadius = UDim.new(0, 8)})
		Global.Spring:Target(Global.TabsTopbar:WaitForChild("UICorner"), 0.8, 3, {CornerRadius = UDim.new(0, 8)})

		if not Global.IsMinimized then
			local FinalSize = UDim2.fromOffset(820, 476)

			if Global.EssentialsToggled then
				if Global.EssentialsPlugin:GetSelectedRibbonTool() ~= Enum.RibbonTool.None then
					Global.EssentialsPlugin:SelectRibbonTool(Enum.RibbonTool.None, UDim2.fromScale(0, 0))
				end

				Global.InSnappedWindow = false
				Global.CurrentSnap = nil
				Global.InFullScreen = false

				Global.EngineFuse.PlaySound(Global.AudioAssets:WaitForChild("EngineToggled"))

				Global.TabsTopbar.Visible = false
				Global.DefaultEngineLoadup.Visible = false
				Global.ExcellenceInterface.Visible = false
				Global.EngineInterface.Size = UDim2.fromOffset(1, 1)
				Global.EngineInterface.Position = UDim2.fromScale(0.5, 0.5)

				task.delay(0.2, function()
					Global.EngineInterface.Visible = true
				end)

				Global.SettingsOpened = false
				EngineInterfaceFunctions.OpenSettings(Global.SettingsOpened)

				Global.Spring:Target(Global.EngineInterface:WaitForChild("Shadow"), 1, 1, {ImageTransparency = 0.5})
				Global.Spring:Target(Global.EngineInterface, 0.8, 2, {Size = UDim2.fromOffset(40, FinalSize.Y.Offset * 0.7)})
				task.wait(0.1)
				Global.TabsTopbar.Visible = true
				Global.DefaultEngineLoadup.Visible = true
				Global.ExcellenceInterface.Visible = Global.ExcellenceOpened
				Global.Spring:Target(Global.EngineInterface, 0.6, 4, {Size = UDim2.fromOffset(FinalSize.X.Offset * 1.2, FinalSize.Y.Offset * 1.2)})
				task.wait(0.15)
				Global.Spring:Target(Global.EngineInterface, 0.7, 3, {Size = FinalSize})
			else
				if Global.EssentialsPlugin:GetSelectedRibbonTool() ~= Enum.RibbonTool.Select then
					Global.EssentialsPlugin:SelectRibbonTool(Enum.RibbonTool.Select, UDim2.fromScale(0, 0))
				end

				Global.EngineFuse.PlaySound(Global.AudioAssets:WaitForChild("EngineUntoggled"))

				Global.Spring:Target(Global.EngineInterface:WaitForChild("Shadow"), 1, 3, {ImageTransparency = 1})
				Global.Spring:Target(Global.EngineInterface, 0.6, 3, {Size = UDim2.fromOffset(FinalSize.X.Offset * 1.2, FinalSize.Y.Offset * 1.2)})
				task.wait(0.15)
				Global.Spring:Target(Global.EngineInterface, 0.8, 2, {Size = UDim2.fromOffset(40, FinalSize.Y.Offset * 0.7)})
				task.wait(0.2)
				Global.TabsTopbar.Visible = false
				Global.DefaultEngineLoadup.Visible = false
				Global.ExcellenceInterface.Visible = false
				Global.Spring:Target(Global.EngineInterface, 1, 6, {Size = UDim2.fromOffset(0, 0)})
				task.wait(0.13)
				Global.EngineInterface.Visible = false
			end

			EngineInterfaceFunctions.UpdateTab(4)
		else
			local FinalSize = UDim2.fromOffset(50, 50)

			if Global.EssentialsToggled then
				if Global.EssentialsPlugin:GetSelectedRibbonTool() ~= Enum.RibbonTool.None then
					Global.EssentialsPlugin:SelectRibbonTool(Enum.RibbonTool.None, UDim2.fromScale(0, 0))
				end

				Global.EngineFuse.PlaySound(Global.AudioAssets:WaitForChild("EngineToggled"))

				Global.EssentialsLauncher.Visible = true
				Global.EssentialsLauncher:WaitForChild("EssentialsLogo").Size = UDim2.fromOffset(0, 0)

				Global.SettingsOpened = false
				Global.EngineInterfaceFunctions.OpenSettings(Global.SettingsOpened)

				Global.Spring:Target(Global.EssentialsLauncher:WaitForChild("EssentialsLogo"), 0.8, 2, {Size = UDim2.fromOffset(40, FinalSize.Y.Offset * 0.7)})
				task.wait(0.1)
				Global.Spring:Target(Global.EssentialsLauncher:WaitForChild("EssentialsLogo"), 0.6, 4, {Size = UDim2.fromOffset(FinalSize.X.Offset * 1.2, FinalSize.Y.Offset * 1.2)})
				task.wait(0.15)
				Global.Spring:Target(Global.EssentialsLauncher:WaitForChild("EssentialsLogo"), 0.7, 3, {Size = FinalSize})
			else
				if Global.EssentialsPlugin:GetSelectedRibbonTool() ~= Enum.RibbonTool.Select then
					Global.EssentialsPlugin:SelectRibbonTool(Enum.RibbonTool.Select, UDim2.fromScale(0, 0))
				end

				Global.EngineFuse.PlaySound(Global.AudioAssets:WaitForChild("EngineUntoggled"))

				Global.Spring:Target(Global.EssentialsLauncher:WaitForChild("EssentialsLogo"), 0.6, 3, {Size = UDim2.fromOffset(FinalSize.X.Offset * 1.2, FinalSize.Y.Offset * 1.2)})
				task.wait(0.15)
				Global.Spring:Target(Global.EssentialsLauncher:WaitForChild("EssentialsLogo"), 0.8, 2, {Size = UDim2.fromOffset(40, FinalSize.Y.Offset * 0.7)})
				task.wait(0.2)
				Global.Spring:Target(Global.EssentialsLauncher:WaitForChild("EssentialsLogo"), 1, 6, {Size = UDim2.fromOffset(0, 0)})
				task.wait(0.13)
				Global.EssentialsLauncher.Visible = false
			end
		end
	end

	function EngineInterfaceFunctions.SnapWindow(MousePos, ForcedSnap)
		local TargetSize, TargetPos
		local SnapSlot = nil

		local Width, Height = Global.ScreenSize.X, Global.ScreenSize.Y

		if ForcedSnap then
			SnapSlot = ForcedSnap
		else
			if MousePos.X <= Global.SnapThreshold and MousePos.Y <= Global.SnapThreshold then
				SnapSlot = "TopLeft"
			elseif MousePos.X >= Width - Global.SnapThreshold and MousePos.Y <= Global.SnapThreshold then
				SnapSlot = "TopRight"
			elseif MousePos.X <= Global.SnapThreshold and MousePos.Y >= Height - Global.SnapThreshold then
				SnapSlot = "BottomLeft"
			elseif MousePos.X >= Width - Global.SnapThreshold and MousePos.Y >= Height - Global.SnapThreshold then
				SnapSlot = "BottomRight"
			elseif MousePos.X <= Global.SnapThreshold then
				SnapSlot = "Left"
			elseif MousePos.X >= Width - Global.SnapThreshold then
				SnapSlot = "Right"
			--elseif MousePos.Y <= Global.SnapThreshold then
			--	SnapSlot = "Top"
			elseif MousePos.Y >= Height - Global.SnapThreshold then
				SnapSlot = "Bottom"
			end
		end

		if SnapSlot == "TopLeft" then
			TargetSize = UDim2.fromOffset(Width / 2, Height / 2)
			TargetPos = UDim2.fromOffset(Width / 4, Height / 4)

		elseif SnapSlot == "TopRight" then
			TargetSize = UDim2.fromOffset(Width / 2, Height / 2)
			TargetPos = UDim2.fromOffset(Width * 0.75, Height / 4)

		elseif SnapSlot == "BottomLeft" then
			TargetSize = UDim2.fromOffset(Width / 2, Height / 2)
			TargetPos = UDim2.fromOffset(Width / 4, Height * 0.75)

		elseif SnapSlot == "BottomRight" then
			TargetSize = UDim2.fromOffset(Width / 2, Height / 2)
			TargetPos = UDim2.fromOffset(Width * 0.75, Height * 0.75)

		elseif SnapSlot == "Left" then
			TargetSize = UDim2.fromOffset(Width / 2, Height)
			TargetPos = UDim2.fromOffset(Width / 4, Height / 2)

		elseif SnapSlot == "Right" then
			TargetSize = UDim2.fromOffset(Width / 2, Height)
			TargetPos = UDim2.fromOffset(Width * 0.75, Height / 2)

		elseif SnapSlot == "Top" then
			TargetSize = UDim2.fromOffset(Width, Height / 2)
			TargetPos = UDim2.fromOffset(Width / 2, Height / 4)

		elseif SnapSlot == "Bottom" then
			local SnapHeight = Height / 2
			TargetSize = UDim2.fromOffset(Width, SnapHeight)
			local CenterY = (Height - SnapHeight) + (SnapHeight / 2)
			TargetPos = UDim2.fromOffset(Width / 2, CenterY)
		end

		if TargetSize and TargetPos then
			Global.LastSizeBeforeSnap = Global.EngineInterface.Size
			Global.InSnappedWindow = true
			Global.CurrentSnap = SnapSlot

			Global.InFullScreen = false

			Global.Spring:Target(Global.SnapFramePreviewInterface, 1, 4, { BackgroundTransparency = 1 })
			Global.PreviewingSnap = false

			Global.Spring:Target(Global.EngineInterface, 0.8, 3, {
				Size = TargetSize,
				Position = TargetPos,
			})

			Global.Spring:Target(Global.EngineInterface:WaitForChild("UICorner"), 0.8, 3, {CornerRadius = UDim.new(0, 8)})
			Global.Spring:Target(Global.TabsTopbar:WaitForChild("UICorner"), 0.8, 3, {CornerRadius = UDim.new(0, 8)})

			EngineInterfaceFunctions.UpdateTab(4)
		end
	end

	function EngineInterfaceFunctions.ToggleFullScreen(IsToggled)
		if IsToggled then
			Global.Spring:Target(Global.EngineInterface:WaitForChild("UICorner"), 0.8, 3, {CornerRadius = UDim.new(0, 0)})
			Global.Spring:Target(Global.TabsTopbar:WaitForChild("UICorner"), 0.8, 3, {CornerRadius = UDim.new(0, 0)})
			Global.Spring:Target(Global.EngineInterface, 0.8, 3, {Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0.5, 0.5)})
		else
			Global.Spring:Target(Global.EngineInterface:WaitForChild("UICorner"), 0.8, 3, {CornerRadius = UDim.new(0, 8)})
			Global.Spring:Target(Global.TabsTopbar:WaitForChild("UICorner"), 0.8, 3, {CornerRadius = UDim.new(0, 8)})
			Global.Spring:Target(Global.EngineInterface, 0.8, 3, {Size = Global.LastSizeBeforeSnap, Position = UDim2.fromScale(0.5, 0.5)})
		end

		EngineInterfaceFunctions.UpdateTab(4)
	end
		
	function EngineInterfaceFunctions.ShowTabPreview(TabName, Interface, TabAbsolutePosition)
		EngineInterfaceFunctions.TabPreviewShown = false

		for i, OldPreview in pairs(Global.TabPreviewInterface:WaitForChild("InterfacePreview"):GetChildren()) do
			if OldPreview:IsA("Frame") or OldPreview:IsA("CanvasGroup") then
				OldPreview:Destroy()
			end
		end

		if Interface then
			local PreviewClone = Global.ComponentBuilder:Attach(Interface:Clone(), Global.TabPreviewInterface:WaitForChild("InterfacePreview")).Instance
			PreviewClone.Visible = true
		end

		Global.TabPreviewInterface:WaitForChild("TabInfoEnlarged"):WaitForChild("Container"):WaitForChild("TabName").Text = TabName

		Global.TabPreviewInterface.Position = UDim2.fromOffset(TabAbsolutePosition.X, TabAbsolutePosition.Y + 43)

		Global.Spring:Target(Global.TabPreviewInterface, 1, 3, {GroupTransparency = 0})
	end

	function EngineInterfaceFunctions.HideTabPreview()
		EngineInterfaceFunctions.TabPreviewShown = true

		Global.Spring:Target(Global.TabPreviewInterface, 1, 3, {GroupTransparency = 1})
	end

	function EngineInterfaceFunctions.OpenSettings(Open)
		local OldSize = Global.EngineInterface.Size

		if Open then
			Global.TabsTopbar.ZIndex = 155
			Global.EngineInterface:WaitForChild("Container"):WaitForChild("SettingsInterface").Visible = true
			Global.Spring:Target(Global.EngineInterface:WaitForChild("Container"):WaitForChild("SettingsInterface"), 1, 3, {GroupTransparency = 0})
			task.wait(0.14)
			Global.EngineInterface:WaitForChild("Container"):WaitForChild("EngineInterface").Visible = false
			Global.EngineInterface:WaitForChild("Container"):WaitForChild("TabsTopbar"):WaitForChild("TabsContainer").Visible = false
		else
			Global.Spring:Target(Global.EngineInterface:WaitForChild("Container"):WaitForChild("SettingsInterface"), 1, 3, {GroupTransparency = 1})
			task.wait(0.14)
			Global.TabsTopbar.ZIndex = 80
			Global.EngineInterface:WaitForChild("Container"):WaitForChild("EngineInterface").Visible = true
			Global.EngineInterface:WaitForChild("Container"):WaitForChild("TabsTopbar"):WaitForChild("TabsContainer").Visible = true
			Global.EngineInterface:WaitForChild("Container"):WaitForChild("SettingsInterface").Visible = false
		end		
	end

	local function UpdateEngineInnerSize()
		local XScale = 1
		local XOffset = 0
		local YScale = 1
		local YOffset = -36

		if Global.ExcellenceOpened then
			XScale -= Global.ExcellenceSizeSpace
		end

		if Global.ExecutorOpened then
			YOffset -= Global.ExecutorSizeSpace
		end

		Global.Spring:Target(Global.EngineInnerInterface, 1, 4, {Size = UDim2.new(XScale, XOffset, YScale, YOffset)})
	end

	local UserWarned = false

	function EngineInterfaceFunctions.ToggleExcellencePanel(IsToggled)
		EngineInterfaceFunctions.UpdateTab(4)
		
		if IsToggled then
			if not UserWarned then
				UserWarned = true
				Global.APIFunctions.Popup.new({
					Callback = function(ActionChosen) 
						if ActionChosen == "I understand" then
							UserWarned = true
						end
					end, 
					Header = "Excellence", 
					Actions = {
						[1] = {
							Text = "I understand";
							Color = Color3.fromRGB(255, 255, 255)
						}
					}, 
					Title = "INACCURACY", 
					Description = `Excellence may provide inaccurate data. Always double check!`, 
					Logo = Global.PluginImages["ExcellenceLogo.png"].Image})
			end

			Global.ExcellenceInterface.Visible = true

			Global.Spring:Target(Global.TabsTopbar:WaitForChild("UncorneredTop"):WaitForChild("UICorner"), 1, 4, {CornerRadius = UDim.new(0, 0)})
			Global.Spring:Target(Global.ExecutorInterface, 1, 4, {Size = UDim2.new(1 - Global.ExcellenceSizeSpace, 0, 1, -36)})
			Global.Spring:Target(Global.EngineInnerInterface:WaitForChild("UIPadding"), 1, 4, {PaddingLeft = UDim.new(0, 4)})
			Global.Spring:Target(Global.TabsTopbar, 1, 4, {Size = UDim2.new(1 - Global.ExcellenceSizeSpace, 0, 0, 36)})
			Global.Spring:Target(Global.ExcellenceInterface, 1, 4, {Position = UDim2.fromScale(0, 1)})
			Global.Spring:Target(Global.ExecutorInterface:WaitForChild("Executor"):WaitForChild("UIPadding"), 1, 4, {PaddingLeft = UDim.new(0, 1)})

			UpdateEngineInnerSize()
		else
			Global.Spring:Target(Global.TabsTopbar:WaitForChild("UncorneredTop"):WaitForChild("UICorner"), 1, 4, {CornerRadius = UDim.new(0, 9)})
			Global.Spring:Target(Global.ExecutorInterface, 1, 4, {Size = UDim2.new(1, 0, 1, -36)})
			Global.Spring:Target(Global.TabsTopbar, 1, 4, {Size = UDim2.new(1, 0, 0, 36)})
			Global.Spring:Target(Global.ExcellenceInterface, 1, 4, {Position = UDim2.fromScale(-Global.ExcellenceSizeSpace, 1)})
			Global.Spring:Target(Global.EngineInnerInterface:WaitForChild("UIPadding"), 1, 4, {PaddingLeft = UDim.new(0, 7)})
			Global.Spring:Target(Global.ExecutorInterface:WaitForChild("Executor"):WaitForChild("UIPadding"), 1, 4, {PaddingLeft = UDim.new(0, 3)})

			UpdateEngineInnerSize()
			task.wait(0.16)
			Global.ExcellenceInterface.Visible = false
		end
	end

	function EngineInterfaceFunctions.ToggleExecutorPanel(IsToggled)
		EngineInterfaceFunctions.UpdateTab(4)
		
		if IsToggled then
			Global.ExecutorInterface.Visible = true

			Global.Spring:Target(Global.ExecutorInterface:WaitForChild("Executor"), 1, 4, {Position = UDim2.new(0.5, 0, 1, 0)})
			Global.Spring:Target(Global.EngineInnerInterface:WaitForChild("UIPadding"), 1, 4, {PaddingBottom = UDim.new(0, 5)})

			UpdateEngineInnerSize()
		else
			Global.Spring:Target(Global.ExecutorInterface:WaitForChild("Executor"), 1, 4, {Position = UDim2.new(0.5, 0, 1, Global.ExecutorSizeSpace)})
			Global.Spring:Target(Global.EngineInnerInterface:WaitForChild("UIPadding"), 1, 4, {PaddingBottom = UDim.new(0, 7)})

			UpdateEngineInnerSize()
			task.wait(0.16)
			Global.ExecutorInterface.Visible = false
		end
	end

	function EngineInterfaceFunctions.GlowExcellence(Glow)
		if Glow then
			Global.Spring:Target(Global.ExcellenceGlow, 1, 4, {ImageTransparency = 0})
		else
			Global.Spring:Target(Global.ExcellenceGlow, 1, 1.8, {ImageTransparency = 1})
		end
	end

	function EngineInterfaceFunctions.PerimeterGlowExcellence(Glow)
		if Glow then
			Global.Spring:Target(Global.PerimeterGlow, 1, 4, {ImageTransparency = 0})
		else
			Global.Spring:Target(Global.PerimeterGlow, 1, 1.8, {ImageTransparency = 1})
		end
	end

	function EngineInterfaceFunctions.LoadEnginePlugin()
		--[[ API Initialize ]] do
			for _, APIData in pairs(Global.API:GetChildren()) do
				local Data = require(APIData)
				local Module, Init = Data.Module, Data.Init
				Global.APIFunctions[APIData.Name] = Module
				Init({
					EssentialsPlugin = Global.EssentialsPlugin;
					EssentialsPack = {
						Libraries = Global.Libraries;
						Components = Global.Components;
						Core = Global.Core;
					};
					EssentialsMouse = Global.EssentialsMouse;
					EngineInterfaceFunctions = Global.EngineInterfaceFunctions;
					EngineFuse = Global.EngineFuse;
					EngineSignals = Global.EngineSignals;
					APIFunctions = Global.APIFunctions;
					EssentialsMainUI = Global.EngineInterface;
					NotificationsInterface = Global.NotificationsInterface;
					ActionsInterface = Global.ActionsInterface;
					EssentialsLauncher = Global.EssentialsLauncher;
					NewInterface = Global.NewInterface
				})
			end
		end

		--[[ Essentials Engine ]] do
			Global.EssentialsConnections["SetRibbonFromWindow"] = Global.EngineInterfaceHover:Connect(function()
				if Global.EssentialsToggled == true then
					if Global.EssentialsPlugin:GetSelectedRibbonTool() ~= Enum.RibbonTool.None then
						Global.EssentialsPlugin:SelectRibbonTool(Enum.RibbonTool.None, UDim2.fromScale(0, 0))
					end
				end
			end)

			Global.EssentialsConnections["SetRibbonFromLauncher"] = Global.EngineLauncherHover:Connect(function()
				if Global.IsMinimized == true then
					if Global.EssentialsPlugin:GetSelectedRibbonTool() ~= Enum.RibbonTool.None then
						Global.EssentialsPlugin:SelectRibbonTool(Enum.RibbonTool.None, UDim2.fromScale(0, 0))
					end
				end
			end)

			Global.EssentialsConnections["UnfocusedListener"] = UserInputService.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.MouseButton2 then
					Global.EngineSignals.UserUnfocused:Fire()
				end
			end)

			Global.EssentialsConnections["LauncherClick"] = Global.EssentialsToggle.Click:Connect(function()
				if Global.EssentialsStartupDone == true then
					if Global.EssentialsDebounce == true then return end
					if Global.UserAgreed == true then
						EngineInterfaceFunctions.ToggleEssentials()
					else
						Global.APIFunctions.Popup.new({
							Callback = function(ActionChosen) 
								Global.EssentialsStartupDone = true

								if ActionChosen == "I agree" then
									Global.UserAgreed = true

									Global.APIFunctions.Notifications.Notify({
										Logo = Global.PluginImages[`Essentials{Global.CurrentThemePack.DerivedFrom}Loaded.png`].Image, 
										Header = "Essentials booted", 
										TextContent = "Essentials have booted and downloaded all of your services. Start innovating!"})

									task.delay(0.1, function()
										Global.EngineInterfaceFunctions.ToggleEssentials()
									end)

									task.delay(1, function()
										if not Global.PluginSanityCheckers.HttpEnabled() then
											Global.APIFunctions.Notifications.Notify({
												Logo = Global.PluginImages[`Essentials{Global.CurrentThemePack.DerivedFrom}Unloaded.png`].Image, 
												Header = "Insufficient permission", 
												TextContent = "Essentials needs HttpService to access more functions. Please enable Http requests."})
										end
									end)

									task.delay(1.5, function()
										if not Global.PluginSanityCheckers.ScriptInjectionEnabled() then
											Global.APIFunctions.Notifications.Notify({
												Logo = Global.PluginImages[`Essentials{Global.CurrentThemePack.DerivedFrom}Unloaded.png`].Image, 
												Header = "Insufficient permission", 
												TextContent = "Some services require ScriptInjection access to function properly. Please enable ScriptInjection."})
										end
									end)

									task.delay(1.3, function()
										Global.APIFunctions.Notifications.Notify({
											Logo = Global.PluginImages[`Essentials{Global.CurrentThemePack.DerivedFrom}Unloaded.png`].Image, 
											Header = "Silence", 
											TextContent = "Essentials uses custom sound effects which are private. Roblox temporarily disabled public audios. You might not hear sounds!"})
										Global.Spring:Target(Global.EngineContainer:WaitForChild("LoadingEngine"), 1, 3, {GroupTransparency = 1})
									end)
								end
							end, 
							Header = "Terms and Conditions", 
							Actions = {
								[1] = {
									Text = "I agree";
									Color = Global.CurrentThemePack["Green"]
								};
								[2] = {
									Text = "I don't agree";
									Color = Global.CurrentThemePack["Red"]
								}
							}, 
							Title = "DO YOU AGREE?", 
							Description = `Welcome to Essentials! By clicking "I agree", you agree to our Terms and Conditions.`})
					end
				end
			end)

			Global.EssentialsConnections["WindowFocused"] = Global.EngineInterface.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					EngineInterfaceFunctions.TopmostWindow(Global.EngineInterface)
				end
			end)

			Global.EssentialsConnections["WindowActionClose"] = Global.TabsTopbar:WaitForChild("WindowActions"):WaitForChild("Close").Activated:Connect(function()
				if Global.EssentialsStartupDone == true then
					if Global.EssentialsDebounce == true then return end
					EngineInterfaceFunctions.ToggleEssentials(Global.EssentialsToggled)
				end
			end)

			Global.EssentialsConnections["WindowActionFullScreen"] = Global.TabsTopbar:WaitForChild("WindowActions"):WaitForChild("FullScreen").Activated:Connect(function()
				if Global.EssentialsStartupDone == true then
					Global.EngineSignals.ToggledFullScreen:Fire(true)
				end
			end)

			Global.EssentialsConnections["WindowActionMinimize"] = Global.TabsTopbar:WaitForChild("WindowActions"):WaitForChild("Minimize").Activated:Connect(function()
				if Global.EssentialsStartupDone == true then
					if Global.IsMinimized == false then
						Global.IsMinimized = true
						EngineInterfaceFunctions.MinimizeEssentials(Global.IsMinimized)
					end
				end
			end)

			Global.EssentialsConnections["EssentialsActionSettings"] = Global.TabsTopbar:WaitForChild("EssentialsActions"):WaitForChild("Settings").Activated:Connect(function()
				if Global.EssentialsStartupDone == true then
					if Global.SettingsToggleDebounce == true then return end
					Global.SettingsOpened = not Global.SettingsOpened
					Global.SettingsToggleDebounce = true
					EngineInterfaceFunctions.OpenSettings(Global.SettingsOpened)
					task.wait(0.12)
					Global.SettingsToggleDebounce = false
				end
			end)

			Global.EssentialsConnections["EssentialsActionExcellence"] = Global.TabsTopbar:WaitForChild("EssentialsActions"):WaitForChild("Excellence").Activated:Connect(function()
				if Global.EssentialsStartupDone == true then
					if Global.ExcellenceToggleDebounce == true then return end
					Global.ExcellenceOpened = not Global.ExcellenceOpened
					Global.ExcellenceToggleDebounce = true
					EngineInterfaceFunctions.ToggleExcellencePanel(Global.ExcellenceOpened)
					task.wait(0.2)
					Global.ExcellenceToggleDebounce = false
				end
			end)

			Global.EssentialsConnections["EssentialsActionExecutor"] = Global.TabsTopbar:WaitForChild("EssentialsActions"):WaitForChild("Executor").Activated:Connect(function()
				if Global.EssentialsStartupDone == true then
					if Global.ExecutorToggleDebounce == true then return end
					Global.ExecutorOpened = not Global.ExecutorOpened
					Global.ExecutorToggleDebounce = true
					EngineInterfaceFunctions.ToggleExecutorPanel(Global.ExecutorOpened)
					task.wait(0.2)
					Global.ExecutorToggleDebounce = false
				end
			end)

			--[[ .Instance dropping ]] do		
				--EssentialsConnections.DragDrop["DragStart"] = UserInputService.InputBegan:Connect(function(Input)
				--	if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				--		print("hello")
				--		if #SelectionService:Get() > 0 then
				--			EssentialsConnections.DragDrop["DragEnd"] = UserInputService.InputEnded:Connect(function(Input)
				--				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				--					if #SelectionService:Get() > 0 then
				--						print("hi")
				--						local droppedinstancee = SelectionService:Get()[1]
				--						print(droppedinstancee)
				--					end

				--					EssentialsConnections.DragDrop.DragEnd:Disconnect()
				--					EssentialsConnections.DragDrop.DragEnd = nil
				--				end
				--			end)
				--		end
				--	end
				--end)
			end

			--[[ .Topbar fullscreen ]] do
				local LastClickTime = 0

				Global.EssentialsConnections["TopbarFullScreen"] = Global.TabsTopbar:WaitForChild("DraggableInput").Activated:Connect(function()
					if not Global.EssentialsStartupDone then return end
					local Now = tick()
					if (Now - LastClickTime) <= 0.2 then
						if not Global.InFullScreen then
							Global.EngineSignals.ToggledFullScreen:Fire(true)
						else
							if Global.InFullScreen then
								Global.InFullScreen = false
								Global.InSnappedWindow = false
								EngineInterfaceFunctions.ToggleFullScreen(Global.InFullScreen)
							end
						end
						LastClickTime = 0
					else
						LastClickTime = Now
					end
				end)
			end

			--[[ .Launcher maximize ]] do
				local LastClickTime = 0

				Global.EssentialsConnections["LauncherMaximize"] = Global.EssentialsLauncher:WaitForChild("Button").Activated:Connect(function()
					if not Global.EssentialsStartupDone then return end
					local Now = tick()
					if (Now - LastClickTime) <= 0.2 then
						if Global.IsMinimized then
							Global.IsMinimized = false
							EngineInterfaceFunctions.MinimizeEssentials(Global.IsMinimized)
						end
						LastClickTime = 0
					else
						LastClickTime = Now
					end
				end)
			end

			--[[ .EssentialsLogo idle fade ]] do
				local EssentialsLogo = Global.EssentialsLauncher:WaitForChild("EssentialsLogo")
				local IdleTime = 0
				local FadeDelay = 3
				local FadeTargetTransparency = 0.8
				local FadeSpeed = 0.5

				local HoveringLauncher = false

				Global.EssentialsConnections["LauncherHoverLogo"] = Global.EngineLauncherHover:Connect(function()
					HoveringLauncher = true
					IdleTime = 0
					Global.Spring:Target(EssentialsLogo, FadeSpeed, 3, {ImageTransparency = 0})
				end)

				Global.EssentialsConnections["LauncherLeaveLogo"] = Global.EngineLauncherUnhover:Connect(function()
					HoveringLauncher = false
				end)

				Global.EssentialsConnections["ResetIdleTimer"] = UserInputService.InputBegan:Connect(function()
					IdleTime = 0
					if HoveringLauncher then
						Global.Spring:Target(EssentialsLogo, FadeSpeed, 3, {ImageTransparency = 0})
					end
				end)

				Global.EssentialsConnections["LogoIdleFade"] = RunService.Heartbeat:Connect(function(dt)
					if Global.IsMinimized then
						if not HoveringLauncher then
							IdleTime = IdleTime + dt
							if IdleTime >= FadeDelay then
								Global.Spring:Target(EssentialsLogo, FadeSpeed, 3, {ImageTransparency = FadeTargetTransparency})
							end
						else
							IdleTime = 0
						end
					else
						IdleTime = 0
					end
				end)
			end

			--[[ .EssentialsLauncher dragging ]] do
				local LauncherHovering = false
				local LauncherDragConnection = nil

				Global.EssentialsConnections["LauncherMouseEnter"] = Global.EngineLauncherHover:Connect(function()
					LauncherHovering = true
				end)

				Global.EssentialsConnections["LauncherMouseLeave"] = Global.EngineLauncherUnhover:Connect(function()
					LauncherHovering = false
				end)

				local function DragLauncher()
					if LauncherDragConnection then LauncherDragConnection:Disconnect() end
					local StartOffset = Vector2.new(Global.EssentialsMouse.X, Global.EssentialsMouse.Y) - Global.EssentialsLauncher.AbsolutePosition

					local LastMouse = Vector2.new(Global.EssentialsMouse.X, Global.EssentialsMouse.Y)
					LauncherDragConnection = RunService.Heartbeat:Connect(function()
						local Mouse = Vector2.new(Global.EssentialsMouse.X, Global.EssentialsMouse.Y)
						local NewPos = Mouse - StartOffset
						local ClampedX, ClampedY = EngineInterfaceFunctions.ClampToScreen(NewPos, Global.EssentialsLauncher)
						Global.Spring:Target(Global.EssentialsLauncher, 0.6, 4, {Position = UDim2.fromOffset(ClampedX, ClampedY)})
					end)
				end

				Global.EssentialsConnections["LauncherDragStart"] = UserInputService.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 and LauncherHovering and Global.EssentialsLauncher.Visible then
						DragLauncher()
					end
				end)

				Global.EssentialsConnections["LauncherDragEnd"] = UserInputService.InputEnded:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 and LauncherDragConnection then
						LauncherDragConnection:Disconnect()
						LauncherDragConnection = nil
					end
				end)
			end

			Global.EssentialsPlugin.Unloading:Connect(function()
				Global.DisconnectConnections(Global.EssentialsConnections)
				Global.MouseEvents.Clean()

				Global.EssentialsRoot:Destroy()
			end)
		end

		--[[ Dragging ]] do
			local HoveringTopbar = false
			local DragConnection = nil

			Global.EssentialsConnections["EngineTopbarEntered"] = Global.DragInputHover:Connect(function()
				HoveringTopbar = true
			end)

			Global.EssentialsConnections["EngineTopbarLeft"] = Global.DragInputUnhover:Connect(function()
				HoveringTopbar = false
			end)

			Global.EngineSignals.ToggledFullScreen:Connect(function(FullScreen)
				if FullScreen then
					if not Global.InFullScreen then
						Global.InFullScreen = true
						Global.InSnappedWindow = true
						Global.LastSizeBeforeSnap = Global.EngineInterface.Size

						EngineInterfaceFunctions.ToggleFullScreen(true)
					else
						Global.InFullScreen = false
						Global.InSnappedWindow = false

						EngineInterfaceFunctions.ToggleFullScreen(false)
					end
				end
			end)

			local function GetSnapTarget(MousePosition)
				local Width, Height = Global.ScreenSize.X, Global.ScreenSize.Y
				local SnapName
				local TargetSize, TargetPosition

				if MousePosition.X <= Global.SnapThreshold and MousePosition.Y <= Global.SnapThreshold then
					TargetSize = UDim2.fromOffset(Width / 2, Height / 2)
					TargetPosition = UDim2.fromOffset(Width / 4, Height / 4)
					SnapName = "TopLeft"

				elseif MousePosition.X >= Width - Global.SnapThreshold and MousePosition.Y <= Global.SnapThreshold then
					TargetSize = UDim2.fromOffset(Width / 2, Height / 2)
					TargetPosition = UDim2.fromOffset(Width * 0.75, Height / 4)
					SnapName = "TopRight"

				elseif MousePosition.X <= Global.SnapThreshold and MousePosition.Y >= Height - Global.SnapThreshold then
					TargetSize = UDim2.fromOffset(Width / 2, Height / 2)
					TargetPosition = UDim2.fromOffset(Width / 4, Height * 0.75)
					SnapName = "BottomLeft"

				elseif MousePosition.X >= Width - Global.SnapThreshold and MousePosition.Y >= Height - Global.SnapThreshold then
					TargetSize = UDim2.fromOffset(Width / 2, Height / 2)
					TargetPosition = UDim2.fromOffset(Width * 0.75, Height * 0.75)
					SnapName = "BottomRight"

				elseif MousePosition.X <= Global.SnapThreshold then
					TargetSize = UDim2.fromOffset(Width / 2, Height)
					TargetPosition = UDim2.fromOffset(Width / 4, Height / 2)
					SnapName = "Left"

				elseif MousePosition.X >= Width - Global.SnapThreshold then
					TargetSize = UDim2.fromOffset(Width / 2, Height)
					TargetPosition = UDim2.fromOffset(Width * 0.75, Height / 2)
					SnapName = "Right"

				elseif MousePosition.Y <= Global.SnapThreshold * 1.95 then
					local MiddleStart = Width * 0.25
					local MiddleEnd = Width * 0.75

					if MousePosition.X >= MiddleStart and MousePosition.X <= MiddleEnd then
						SnapName = "ShowSnapLayout"
					end

				elseif MousePosition.Y >= Height - Global.SnapThreshold then
					local SnapHeight = Height / 2
					TargetSize = UDim2.fromOffset(Width, SnapHeight)
					local CenterY = (Height - SnapHeight) + (SnapHeight / 2)
					TargetPosition = UDim2.fromOffset(Width / 2, CenterY)
					SnapName = "Bottom"
				end

				return TargetSize, TargetPosition, SnapName
			end

			local function UpdateSnapPreview(MousePosition)
				local TargetSize, TargetPosition, SnapName = GetSnapTarget(MousePosition)
	
				if SnapName == "ShowSnapLayout" then
					Global.Spring:Target(Global.SnapFrameSetupsInterface, 1, 3, { Position = UDim2.new(0.5, 0, 0, 10) })
					Global.PreviewingSnap = false
				else
					Global.Spring:Target(Global.SnapFrameSetupsInterface, 1, 3, { Position = UDim2.new(0.5, 0, 0, -125) })

					if TargetSize and TargetPosition then
						if Global.LastSnapTarget ~= SnapName or not Global.PreviewingSnap then
							Global.SnapFramePreviewInterface.Size = Global.EngineInterface.Size
							Global.SnapFramePreviewInterface.Position = Global.EngineInterface.Position

							Global.Spring:Target(Global.SnapFramePreviewInterface, 1, 4, {
								BackgroundTransparency = 0.8,
								Size = TargetSize,
								Position = TargetPosition
							})

							Global.LastSnapTarget = SnapName
							Global.PreviewingSnap = true
						end
					else
						if Global.PreviewingSnap then
							Global.Spring:Target(Global.SnapFramePreviewInterface, 1, 4, { BackgroundTransparency = 1 })
							Global.LastSnapTarget = nil
							Global.PreviewingSnap = false
						end
					end
				end
			end

			local function ClampPosition(X, Y)
				local ScreenSize = Global.NewInterface.AbsoluteSize
				local UISize = Global.EngineInterface.AbsoluteSize

				local HalfX, HalfY = UISize.X * Global.EngineInterface.AnchorPoint.X, UISize.Y * Global.EngineInterface.AnchorPoint.Y

				local MinX = HalfX
				local MinY = HalfY
				local MaxX = ScreenSize.X - (UISize.X - HalfX)
				local MaxY = ScreenSize.Y - (UISize.Y - HalfY)

				local ClampedX = math.clamp(X, MinX, MaxX)
				local ClampedY = math.clamp(Y, MinY, MaxY)

				return ClampedX, ClampedY
			end

			local function DragWindow(FromMousePosition, MouseWindowAnchorOffset)
				if DragConnection then DragConnection:Disconnect() end
				
				local EngineInterface = Global.EngineInterface
				
				EngineInterfaceFunctions.TopmostWindow(EngineInterface)

				local UsedSize
				if FromMousePosition and Global.LastSizeBeforeSnap then
					if typeof(Global.LastSizeBeforeSnap) == "UDim2" then
						UsedSize = Vector2.new(Global.LastSizeBeforeSnap.X.Offset, Global.LastSizeBeforeSnap.Y.Offset)
					elseif typeof(Global.LastSizeBeforeSnap) == "Vector2" then
						UsedSize = Global.LastSizeBeforeSnap
					elseif type(Global.LastSizeBeforeSnap) == "table" and Global.LastSizeBeforeSnap.X and Global.LastSizeBeforeSnap.Y then
						UsedSize = Vector2.new(Global.LastSizeBeforeSnap.X, Global.LastSizeBeforeSnap.Y)
					else
						UsedSize = EngineInterface.AbsoluteSize
					end
				else
					UsedSize = EngineInterface.AbsoluteSize
				end

				local UIAbsPos = EngineInterface.AbsolutePosition

				local StartMouse = Vector2.new(Global.EssentialsMouse.X, Global.EssentialsMouse.Y)
				local Offset

				if FromMousePosition and MouseWindowAnchorOffset then
					local AnchorOffset = Vector2.new(UsedSize.X * MouseWindowAnchorOffset.X, UsedSize.Y * MouseWindowAnchorOffset.Y)
					Offset = AnchorOffset
				else
					Offset = StartMouse - UIAbsPos
				end

				local LastMouse = StartMouse

				DragConnection = RunService.Heartbeat:Connect(function()
					if not Global.APIFunctions.Tab.IsDraggingTab then
						local Mouse = Vector2.new(Global.EssentialsMouse.X, Global.EssentialsMouse.Y)
						local Delta = Mouse - LastMouse
						LastMouse = Mouse

						local NewPos = Mouse - Offset
						local AnchorOffset = EngineInterface.AbsoluteSize * EngineInterface.AnchorPoint
						NewPos = NewPos + AnchorOffset

						Global.InFullScreen = false

						local NewX, NewY = ClampPosition(NewPos.X, NewPos.Y)

						Global.Spring:Target(EngineInterface, 0.6, 4, {
							Position = UDim2.fromOffset(NewX, NewY)
						})

						UpdateSnapPreview(Mouse)
					end
				end)
			end
			
			local HoveredLayoutButton = nil
			local HoveredSnapName = nil

			--[[ SnapFrameLayouts ]] do
				for _, LayoutButton in ipairs(Global.SnapFrameSetupsInterface:GetDescendants()) do
					if LayoutButton:IsA("ImageButton") and LayoutButton:GetAttribute("SnapLayout") then
						local SnapLayout = LayoutButton:GetAttribute("SnapLayout")
						
						local LayoutHover, LayoutUnhover = Global.MouseEvents.Track(LayoutButton)
						
						Global.EssentialsConnections["Layout"..LayoutButton.Name.."Hover"] = LayoutHover:Connect(function()
							Global.Spring:Target(LayoutButton, 1, 4, { BackgroundColor3 = Global.CurrentThemePack.SelectedBackground })

							local Width, Height = Global.ScreenSize.X, Global.ScreenSize.Y
							local TargetSize, TargetPos
		
							if SnapLayout == "Left" then
								TargetSize = UDim2.fromOffset(Width / 2, Height)
								TargetPos = UDim2.fromOffset(Width / 4, Height / 2)

							elseif SnapLayout == "Right" then
								TargetSize = UDim2.fromOffset(Width / 2, Height)
								TargetPos = UDim2.fromOffset(Width * 0.75, Height / 2)

							elseif SnapLayout == "Top" then
								TargetSize = UDim2.fromOffset(Width, Height / 2)
								TargetPos = UDim2.fromOffset(Width / 2, Height / 4)

							elseif SnapLayout == "Bottom" then
								local SnapHeight = Height / 2
								TargetSize = UDim2.fromOffset(Width, SnapHeight)
								local CenterY = (Height - SnapHeight) + (SnapHeight / 2)
								TargetPos = UDim2.fromOffset(Width / 2, CenterY)

							elseif SnapLayout == "TopLeft" then
								TargetSize = UDim2.fromOffset(Width / 2, Height / 2)
								TargetPos = UDim2.fromOffset(Width / 4, Height / 4)

							elseif SnapLayout == "TopRight" then
								TargetSize = UDim2.fromOffset(Width / 2, Height / 2)
								TargetPos = UDim2.fromOffset(Width * 0.75, Height / 4)

							elseif SnapLayout == "BottomLeft" then
								TargetSize = UDim2.fromOffset(Width / 2, Height / 2)
								TargetPos = UDim2.fromOffset(Width / 4, Height * 0.75)

							elseif SnapLayout == "BottomRight" then
								TargetSize = UDim2.fromOffset(Width / 2, Height / 2)
								TargetPos = UDim2.fromOffset(Width * 0.75, Height * 0.75)
							end

							if TargetSize and TargetPos then
								Global.Spring:Target(Global.SnapFramePreviewInterface, 1, 4, {
									BackgroundTransparency = 0.8,
									Size = TargetSize,
									Position = TargetPos
								})

								Global.PreviewingSnap = true
								HoveredSnapName = SnapLayout
								HoveredLayoutButton = LayoutButton
							end
						end)

						Global.EssentialsConnections["Layout"..LayoutButton.Name.."Hover"] = LayoutUnhover:Connect(function()
							Global.Spring:Target(LayoutButton, 1, 4, { BackgroundColor3 = Global.CurrentThemePack.MainBackground })
							HoveredLayoutButton = nil
							HoveredSnapName = nil
							Global.Spring:Target(Global.SnapFramePreviewInterface, 1, 4, { BackgroundTransparency = 1 })
							Global.PreviewingSnap = false
						end)
					end
				end
			end

			Global.EssentialsConnections["EngineDragListener"] = UserInputService.InputBegan:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 and HoveringTopbar then
					if Global.InFullScreen then
						if Global.APIFunctions.Tab.TabHovering == false and Global.APIFunctions.Tab.IsDraggingTab == false then
							if Global.InSnappedWindow then
								task.delay(0.2, function()
									if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
										Global.Spring:Target(Global.EngineInterface, 0.8, 3, {Size = Global.LastSizeBeforeSnap})

										Global.Spring:Target(Global.EngineInterface:WaitForChild("UICorner"), 0.8, 3, {CornerRadius = UDim.new(0, 8)})
										Global.Spring:Target(Global.TabsTopbar:WaitForChild("UICorner"), 0.8, 3, {CornerRadius = UDim.new(0, 8)})

										Global.InSnappedWindow = false
										Global.CurrentSnap = nil
										Global.InFullScreen = false

										local Mouse = Vector2.new(Global.EssentialsMouse.X, Global.EssentialsMouse.Y)
										
										DragWindow(Mouse, Vector2.new(0.5, 0.05))
									end
								end)
							else
								DragWindow()
							end
						end
					else
						if Global.APIFunctions.Tab.TabHovering == false and Global.APIFunctions.Tab.IsDraggingTab == false then
							if Global.InSnappedWindow then
								task.delay(0.2, function()
									if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
										Global.Spring:Target(Global.EngineInterface, 0.8, 3, {Size = Global.LastSizeBeforeSnap})

										Global.Spring:Target(Global.EngineInterface:WaitForChild("UICorner"), 0.8, 3, {CornerRadius = UDim.new(0, 8)})
										Global.Spring:Target(Global.TabsTopbar:WaitForChild("UICorner"), 0.8, 3, {CornerRadius = UDim.new(0, 8)})

										Global.InSnappedWindow = false
										Global.CurrentSnap = nil
										Global.InFullScreen = false

										local Mouse = Vector2.new(Global.EssentialsMouse.X, Global.EssentialsMouse.Y)

										DragWindow(Mouse, Vector2.new(0.5, 0.05))
									end
								end)
							else
								DragWindow()
							end
						end
					end
					
					Global.Spring:Target(Global.SnapFrameSetupsInterface, 1, 3, { Position = UDim2.new(0.5, 0, 0, -125) })
				end
			end)

			Global.EssentialsConnections["EngineDragEndListener"] = UserInputService.InputEnded:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 and DragConnection then
					DragConnection:Disconnect()
					DragConnection = nil
					
					Global.Spring:Target(Global.SnapFrameSetupsInterface, 1, 3, { Position = UDim2.new(0.5, 0, 0, -125) })
					
					if HoveredSnapName then
						EngineInterfaceFunctions.SnapWindow(Vector2.zero, HoveredSnapName)
						HoveredSnapName = nil
					else
						local MousePos = Vector2.new(Global.EssentialsMouse.X, Global.EssentialsMouse.Y)
						EngineInterfaceFunctions.SnapWindow(MousePos)
					end
				end
			end)
		end

		--[[ Resizing ]] do
			local Resizers = Global.EngineInterface:WaitForChild("Resizers")

			local Handles = {
				Resizers:WaitForChild("UpperLeft"),
				Resizers:WaitForChild("UpperRight"),
				Resizers:WaitForChild("LowerLeft"),
				Resizers:WaitForChild("LowerRight"),
				Resizers:WaitForChild("Left"),
				Resizers:WaitForChild("Right"),
				Resizers:WaitForChild("Top"),
				Resizers:WaitForChild("Bottom"),
			}

			local MinWidth, MinHeight = 492, 286
			local DragConnection

			local DirMap = {
				UpperLeft  = {X = -1, Y = -1},
				UpperRight = {X =  1, Y = -1},
				LowerLeft  = {X = -1, Y =  1},
				LowerRight = {X =  1, Y =  1},

				Left   = {X = -1, Y =  0},
				Right  = {X =  1, Y =  0},
				Top    = {X =  0, Y = -1},
				Bottom = {X =  0, Y =  1},
			}

			local function BeginResize(Handle)
				EngineInterfaceFunctions.TopmostWindow(Global.EngineInterface)

				if DragConnection then
					DragConnection:Disconnect()
				end

				local Button = Handle:WaitForChild("Button")
				local Icon = Handle:WaitForChild("CornerResizerIcon")
				if Icon then
					Global.Spring:Target(Icon, 1, 6, {ImageTransparency = 0})
				end

				local StartMouse = Vector2.new(Global.EssentialsMouse.X, Global.EssentialsMouse.Y)
				local StartSize = Global.EngineInterface.AbsoluteSize
				local StartPos = Global.EngineInterface.AbsolutePosition
				local StartCenter = StartPos + StartSize / 2
				local Dir = DirMap[Handle.Name]

				if Global.InSnappedWindow then
					Global.InSnappedWindow = false
				end

				DragConnection = RunService.Heartbeat:Connect(function()
					local Mouse = Vector2.new(Global.EssentialsMouse.X, Global.EssentialsMouse.Y)
					local Delta = Mouse - StartMouse

					local TargetW = StartSize.X + Delta.X * Dir.X
					local TargetH = StartSize.Y + Delta.Y * Dir.Y

					local NewWidth = math.max(MinWidth, TargetW)
					local NewHeight = math.max(MinHeight, TargetH)

					local AppliedDeltaX = NewWidth - StartSize.X
					local AppliedDeltaY = NewHeight - StartSize.Y

					local NewCenter = Vector2.new(
						StartCenter.X + (AppliedDeltaX / 2) * Dir.X,
						StartCenter.Y + (AppliedDeltaY / 2) * Dir.Y
					)

					Global.EngineInterface.Size = UDim2.fromOffset(NewWidth, NewHeight)
					Global.EngineInterface.Position = UDim2.fromOffset(NewCenter.X, NewCenter.Y)

					Global.APIFunctions.Tab.UpdateTabSizes()
				end)
			end

			for _, Handle in ipairs(Handles) do
				local Button = Handle:WaitForChild("Button")
				local Icon = Handle:FindFirstChildWhichIsA("ImageLabel")

				local ButtonHover, ButtonUnhover = Global.MouseEvents.Track(Button)

				Button:SetAttribute("Hovering", false)
				if Icon then
					Global.Spring:Target(Icon, 1, 6, {ImageTransparency = 1})
				end

				ButtonHover:Connect(function()
					if not DragConnection then
						Button:SetAttribute("Hovering", true)
						if Icon then
							Global.Spring:Target(Icon, 1, 6, {ImageTransparency = 0.5})
						end
					end
				end)

				ButtonUnhover:Connect(function()
					if not DragConnection then
						Button:SetAttribute("Hovering", false)
						if Icon then
							Global.Spring:Target(Icon, 1, 6, {ImageTransparency = 1})
						end
					end
				end)

				Button.MouseButton1Down:Connect(function()
					if not Global.InFullScreen then
						BeginResize(Handle)
					end
				end)
			end

			Global.EssentialsConnections["ResizeEnd"] = UserInputService.InputEnded:Connect(function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 and DragConnection then
					DragConnection:Disconnect()
					DragConnection = nil

					local MousePos = Vector2.new(Global.EssentialsMouse.X, Global.EssentialsMouse.Y)

					for _, Handle in ipairs(Handles) do
						local Button = Handle:WaitForChild("Button")
						local Icon = Handle:FindFirstChildWhichIsA("ImageLabel")

						if Icon then
							local absPos = Button.AbsolutePosition
							local absSize = Button.AbsoluteSize
							local inside = (
								MousePos.X >= absPos.X and MousePos.X <= absPos.X + absSize.X and
									MousePos.Y >= absPos.Y and MousePos.Y <= absPos.Y + absSize.Y
							)

							if inside then
								Button:SetAttribute("Hovering", true)
								Global.Spring:Target(Icon, 1, 6, {ImageTransparency = 0.5})
							else
								Button:SetAttribute("Hovering", false)
								Global.Spring:Target(Icon, 1, 6, {ImageTransparency = 1})
							end
						end
					end
				end
			end)
		end

		--[[ Tabs ]] do	
			local NewTabDebounce = false

			Global.EssentialsConnections["NewTabClick"] = Global.NewTabButton.Button.Activated:Connect(function()
				if NewTabDebounce == true then return end
				EngineInterfaceFunctions.NewServiceSelectionTab()
				NewTabDebounce = true
				task.wait(0.1)
				NewTabDebounce = false
			end)

			Global.EssentialsConnections["ServiceAddedListener"] = Global.ServiceAdded.Event:Connect(function(Service)
				if not Global.RegisteredService[Service.ServiceName] then
					Global.EngineFuse.AddService(Service)
					Global.EngineSignals.NewServiceAdded:Fire(Service)

					Global.APIFunctions.Notifications.Notify({
						Logo = Service.ServiceLogo, 
						Header = `{Service.ServiceName} downloaded`, 
						TextContent = "Essentials have detected a new service. The service has been downloaded. Hooray!"})
				end
			end)
		end

		--[[ Executor ]] do
			local ExecutorInterface = Global.ExecutorInterface

			local Success, GameName = pcall(function()
				return MarketplaceService:GetProductInfo(game.PlaceId)["Name"]
			end)
			
			local PlayerName = "User"
			
			local Success, Result = pcall(function()
				PlayerName = Players:GetPlayerByUserId(StudioService:GetUserId()).Name
			end)
			
			Global.APIFunctions.Executor.NewCommandLine(`Roblox-Studio/{PlayerName}/{(GameName or game.Name):gsub("[ ,%.]", "-")}`)

			Global.EssentialsConnections["ExecutorHistoryDelete"] = ExecutorInterface:WaitForChild("Executor"):WaitForChild("Topbar"):WaitForChild("Container"):WaitForChild("ResetTerminal").Activated:Connect(function()
				Global.APIFunctions.Executor.DeleteHistory()
			end)

			--[[ .Resizing ]] do
				local Resizer = ExecutorInterface:WaitForChild("Executor"):WaitForChild("Resizer")
				local TopResizer = Resizer:WaitForChild("Top")
				local Button = TopResizer:WaitForChild("Button")
				local Icon = TopResizer:FindFirstChildWhichIsA("ImageLabel")

				local DragConnection
				local DirY = -1

				local MinHeightPx = 140
				local MaxHeightPx = 300

				local function BeginResize()
					if DragConnection then
						DragConnection:Disconnect()
					end

					if Icon then
						Global.Spring:Target(Icon, 1, 6, { ImageTransparency = 0 })
					end

					local StartMouse = Vector2.new(Global.EssentialsMouse.X, Global.EssentialsMouse.Y)
					local StartHeightPx = Global.ExecutorInterface.Executor.AbsoluteSize.Y

					DragConnection = RunService.Heartbeat:Connect(function()
						local Mouse = Vector2.new(Global.EssentialsMouse.X, Global.EssentialsMouse.Y)
						local Delta = Mouse - StartMouse

						local TargetHeightPx = StartHeightPx + (Delta.Y * DirY)
						local ClampedHeightPx = math.clamp(TargetHeightPx, MinHeightPx, MaxHeightPx)

						Global.ExecutorInterface.Executor.Size = UDim2.new(Global.ExecutorInterface.Executor.Size.X.Scale, 0, 0, ClampedHeightPx)
						Global.ExecutorSizeSpace = ClampedHeightPx
						Global.EngineInnerInterface.Size = UDim2.new(
							Global.EngineInnerInterface.Size.X.Scale, 0,
							1, -36 - (Global.ExecutorOpened and Global.ExecutorSizeSpace or 0)
						)
					end)
				end

				local ButtonHover, ButtonUnhover = Global.MouseEvents.Track(Button)

				ButtonHover:Connect(function()
					if not DragConnection then
						Button:SetAttribute("Hovering", true)
						Global.Spring:Target(Global.EngineInnerInterface:WaitForChild("UIPadding"), 1, 4, {PaddingBottom = UDim.new(0, 8)})
						if Icon then
							Global.Spring:Target(Icon, 1, 6, { ImageTransparency = 0.5 })
						end
					end
				end)

				ButtonUnhover:Connect(function()
					if not DragConnection then
						Button:SetAttribute("Hovering", false)
						Global.Spring:Target(Global.EngineInnerInterface:WaitForChild("UIPadding"), 1, 4, {PaddingBottom = UDim.new(0, 5)})
						if Icon then
							Global.Spring:Target(Icon, 1, 6, { ImageTransparency = 1 })
						end
					end
				end)

				Button.MouseButton1Down:Connect(function()
					if Global.ExecutorOpened then
						BeginResize()
					end
				end)

				Global.EssentialsConnections["ExecutorResizeEnd"] = UserInputService.InputEnded:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 and DragConnection then
						DragConnection:Disconnect()
						DragConnection = nil

						local MousePos = Vector2.new(Global.EssentialsMouse.X, Global.EssentialsMouse.Y)

						if Icon then
							local absPos = Button.AbsolutePosition
							local absSize = Button.AbsoluteSize
							local inside = (
								MousePos.X >= absPos.X and MousePos.X <= absPos.X + absSize.X and
									MousePos.Y >= absPos.Y and MousePos.Y <= absPos.Y + absSize.Y
							)

							if inside then
								Button:SetAttribute("Hovering", true)
								Global.Spring:Target(Icon, 1, 6, { ImageTransparency = 0.5 })
							else
								Button:SetAttribute("Hovering", false)
								Global.Spring:Target(Global.EngineInnerInterface:WaitForChild("UIPadding"), 1, 4, {PaddingBottom = UDim.new(0, 5)})
								Global.Spring:Target(Icon, 1, 6, { ImageTransparency = 1 })
							end
						end
					end
				end)
			end
		end

		--[[ Excellence AI ]] do
			Global.APIFunctions.Excellence.WakeExcellence()

			local ChatContent = Global.ExcellenceInterface
				:WaitForChild("Container")
				:WaitForChild("ChatContent")
			local ChatBoxTextInput = Global.ExcellenceInterface
				:WaitForChild("Container")
				:WaitForChild("ChatContent")
				:WaitForChild("TextInput")
				:WaitForChild("Input")
			local Messages = Global.ExcellenceInterface
				:WaitForChild("Container")
				:WaitForChild("ChatContent")
				:WaitForChild("Messages")

			local function FormatCommandsInText(text)
				text = text:gsub("(%-%-[Dd][Oo])", '<font transparency="0.4"><i>%1</i></font>')
				text = text:gsub("(%-%-[Hh][Ee][Ll][Pp])", '<font transparency="0.4"><i>%1</i></font>')

				return text
			end

			local function DynamicResize()
				local TextInput = Global.ExcellenceInterface
					:WaitForChild("Container")
					:WaitForChild("ChatContent")
					:WaitForChild("TextInput")

				local Preview = ChatBoxTextInput:WaitForChild("Preview")
				local Glow = ChatContent:WaitForChild("InputGlow")

				if ChatBoxTextInput.Text == "" then
					Preview.Text = "Ask Excellence anything here!"
					Preview.TextColor3 = Color3.fromRGB(136, 145, 166)
				else
					Preview.Text = FormatCommandsInText(ChatBoxTextInput.Text)
					Preview.TextColor3 = Color3.fromRGB(255, 255, 255)
				end

				Messages.Size = UDim2.new(
					1, 0,
					1, -45 - TextInput.AbsoluteSize.Y - 5
				)

				local inputHeight = TextInput.AbsoluteSize.Y
				local blurPadding = math.clamp(inputHeight * 0.3, 12, 25)
				local sidePadding = math.clamp(inputHeight * 0.25, 6, 18)

				Glow.Position = UDim2.new(
					0.5, 0,
					1, blurPadding * 0.57
				)
				Glow.Size = UDim2.new(
					1, sidePadding * 1.55,
					0, inputHeight + blurPadding * 1.15
				)
			end

			ChatBoxTextInput.Text = ""
			ChatBoxTextInput:WaitForChild("Preview").Text = "Ask Excellence anything here!"
			ChatBoxTextInput:WaitForChild("Preview").TextColor3 = Color3.fromRGB(136, 145, 166)

			task.spawn(function()
				Global.APIFunctions.Excellence.ShowAIReply([[## Hello there! 👋

---

I'm Excellence, your friendly Roblox plugin assistant. How can I help you today? Whether it's scripting, debugging, or UI design, I'm here to make your Roblox experience awesome! 😊

---

For instant prompt generation, type "--do " before your prompt to instantly run it! 💻]])
			end)

			Global.EssentialsConnections.Excellence["ChatBoxInputTextSizeChange"] = RunService.Heartbeat:Connect(DynamicResize)

			Global.EssentialsConnections.Excellence["UserFocusedChatInput"] = ChatBoxTextInput.Focused:Connect(function(Entered)
				Global.Spring:Target(ChatContent:WaitForChild("InputGlow"), 1, 4, {ImageTransparency = 0})
			end)

			Global.EssentialsConnections.Excellence["UserPromptedEnter"] = ChatBoxTextInput.FocusLost:Connect(function(Entered)
				Global.Spring:Target(ChatContent:WaitForChild("InputGlow"), 1, 4, {ImageTransparency = 1})
				if not Global.APIFunctions.Excellence.AIIsTyping and not Global.APIFunctions.Excellence.AIIsThinking then
					if Entered then
						local Prompt = ChatBoxTextInput.Text

						if not Prompt or Prompt:match("^%s*$") then
							return
						end

						Global.APIFunctions.Excellence.ShowUserPrompt(Prompt)
						ChatBoxTextInput.Text = ""

						local ExcellenceAIReply, Endpoint = Global.APIFunctions.Excellence.PromptExcellence(Prompt)

						Global.APIFunctions.Excellence.AITyping(false)

						if Endpoint == "instant" then
							Global.APIFunctions.Excellence.ShowAIInstantCode(ExcellenceAIReply)

							local success, error = pcall(function()
								loadstring(ExcellenceAIReply)()
							end)

							if success then
								Global.APIFunctions.Excellence.ShowAIReply([[Successfully ran your prompt! 😊]])
							else
								Global.APIFunctions.Excellence.ShowAIReply([[Your prompt ran into some problems! 😅]])
							end
						else
							Global.APIFunctions.Excellence.ShowAIReply(ExcellenceAIReply)
						end
					end
				end
			end)

			Global.EssentialsConnections.Excellence["GradientCircular"] = RunService.Heartbeat:Connect(function(DeltaTime)
				ChatContent:WaitForChild("InputGlow"):WaitForChild("UIGradient").Rotation = (ChatContent:WaitForChild("InputGlow"):WaitForChild("UIGradient").Rotation + 95 * DeltaTime) % 360
				Global.PerimeterGlow:WaitForChild("UIGradient").Rotation = (Global.PerimeterGlow:WaitForChild("UIGradient").Rotation + 65 * DeltaTime) % 360
				Global.ExcellenceGlow:WaitForChild("UIGradient").Rotation = (Global.ExcellenceGlow:WaitForChild("UIGradient").Rotation + 65 * DeltaTime) % 360
				Global.ExcellenceInterface:WaitForChild("Container"):WaitForChild("UIGradient").Rotation = (Global.ExcellenceInterface:WaitForChild("Container"):WaitForChild("UIGradient").Rotation + 10 * DeltaTime) % 360
			end)

			--[[ .Resizing ]] do
				local Resizer = Global.ExcellenceInterface:WaitForChild("Resizer")
				local RightResizer = Resizer:WaitForChild("Right")
				local Button = RightResizer:WaitForChild("Button")
				local Icon = RightResizer:FindFirstChildWhichIsA("ImageLabel")

				local DragConnection
				local DirX = 1

				local MinWidthScale = 0.26
				local MaxWidthScale = 0.425

				local function BeginResize()
					if DragConnection then
						DragConnection:Disconnect()
					end

					if Icon then
						Global.Spring:Target(Icon, 1, 6, {ImageTransparency = 0})
					end

					local StartMouse = Vector2.new(Global.EssentialsMouse.X, Global.EssentialsMouse.Y)
					local ParentSize = Global.ExcellenceInterface.Parent.AbsoluteSize
					local StartWidthPx = Global.ExcellenceInterface.AbsoluteSize.X
					local MinWidthPx = ParentSize.X * MinWidthScale
					local MaxWidthPx = ParentSize.X * MaxWidthScale

					DragConnection = RunService.Heartbeat:Connect(function()
						local Mouse = Vector2.new(Global.EssentialsMouse.X, Global.EssentialsMouse.Y)
						local Delta = Mouse - StartMouse

						local TargetWidthPx = StartWidthPx + Delta.X * DirX
						local ClampedWidthPx = math.clamp(TargetWidthPx, MinWidthPx, MaxWidthPx)

						local NewWidthScale = ClampedWidthPx / ParentSize.X

						Global.ExcellenceInterface.Size = UDim2.new(NewWidthScale, 0, Global.ExcellenceInterface.Size.Y.Scale, 0)
						Global.TabsTopbar.Size = UDim2.new(1 - NewWidthScale, 0, 0, 36)
						Global.ExcellenceSizeSpace = NewWidthScale
						Global.EngineInnerInterface.Size = UDim2.new(1 - NewWidthScale, 0, 1, -36 - (Global.ExecutorOpened and Global.ExecutorSizeSpace or 0))
						Global.ExecutorInterface.Size = UDim2.new(1 - NewWidthScale, 0, 1, -36)
					end)
				end

				local ButtonHover, ButtonUnhover = Global.MouseEvents.Track(Button)

				ButtonHover:Connect(function()
					if not DragConnection then
						Global.Spring:Target(Global.EngineInnerInterface:WaitForChild("UIPadding"), 1, 4, {PaddingLeft = UDim.new(0, 8)})
						Global.Spring:Target(Global.ExecutorInterface:WaitForChild("Executor"):WaitForChild("UIPadding"), 1, 4, {PaddingLeft = UDim.new(0, 6)})
						Button:SetAttribute("Hovering", true)
						if Icon then
							Global.Spring:Target(Icon, 1, 6, {ImageTransparency = 0.5})
						end
					end
				end)

				ButtonUnhover:Connect(function()
					if not DragConnection then
						Global.Spring:Target(Global.EngineInnerInterface:WaitForChild("UIPadding"), 1, 4, {PaddingLeft = UDim.new(0, 4)})
						Global.Spring:Target(Global.ExecutorInterface:WaitForChild("Executor"):WaitForChild("UIPadding"), 1, 4, {PaddingLeft = UDim.new(0, 1)})
						Button:SetAttribute("Hovering", false)
						if Icon then
							Global.Spring:Target(Icon, 1, 6, {ImageTransparency = 1})
						end
					end
				end)

				Button.MouseButton1Down:Connect(function()
					if Global.ExcellenceOpened then
						BeginResize()
					end
				end)

				Global.EssentialsConnections["ChatBotResizeEnd"] = UserInputService.InputEnded:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 and DragConnection then
						DragConnection:Disconnect()
						DragConnection = nil

						local MousePos = Vector2.new(Global.EssentialsMouse.X, Global.EssentialsMouse.Y)

						if Icon then
							local absPos = Button.AbsolutePosition
							local absSize = Button.AbsoluteSize
							local inside = (
								MousePos.X >= absPos.X and MousePos.X <= absPos.X + absSize.X and
									MousePos.Y >= absPos.Y and MousePos.Y <= absPos.Y + absSize.Y
							)

							if inside then
								Button:SetAttribute("Hovering", true)
								Global.Spring:Target(Icon, 1, 6, {ImageTransparency = 0.5})
							else
								Button:SetAttribute("Hovering", false)
								Global.Spring:Target(Global.EngineInnerInterface:WaitForChild("UIPadding"), 1, 4, {PaddingLeft = UDim.new(0, 4)})
								Global.Spring:Target(Global.ExecutorInterface:WaitForChild("Executor"):WaitForChild("UIPadding"), 1, 4, {PaddingLeft = UDim.new(0, 1)})
								Global.Spring:Target(Icon, 1, 6, {ImageTransparency = 1})
							end
						end
					end
				end)
			end
		end

		--[[ Essentials commands ]] do
			local ExecutorAPI = Global.APIFunctions.Executor
			local TerminalSyntaxHighligher = ExecutorAPI.SyntaxGetHighlighter()

			local PseudoCommands = {
				["cmdlets"] = function(QuickExecutor, ...)
					local TotalCommandlets = 0
					for _, _ in pairs(ExecutorAPI.GetCommandlets()) do
						TotalCommandlets += 1
					end
					QuickExecutor.Log(`You have {TotalCommandlets} available commands:`)
					for Commandlet, _ in pairs(ExecutorAPI.GetCommandlets()) do
						QuickExecutor.Log(`\t{Commandlet}`)
					end
				end,

				["help"] = function(QuickExecutor, ...)
					QuickExecutor.Log(`nothing to see here yet!`)
				end,

				["--version"] = function(QuickExecutor, ...)
					QuickExecutor.Log(Global.EssentialsVersion)
				end,
			}

			local function FindNearestSubCommand(SubCommand)
				local function StringDistance(a, b)
					local lenA, lenB = #a, #b
					local matrix = {}

					for i = 0, lenA do
						matrix[i] = {[0] = i}
					end
					for j = 0, lenB do
						matrix[0][j] = j
					end

					for i = 1, lenA do
						for j = 1, lenB do
							local cost = (a:sub(i, i) == b:sub(j, j)) and 0 or 1
							matrix[i][j] = math.min(
								matrix[i - 1][j] + 1,
								matrix[i][j - 1] + 1,
								matrix[i - 1][j - 1] + cost
							)
						end
					end

					return matrix[lenA][lenB]
				end

				local Nearest, BestDistance = nil, math.huge
				for Name in pairs(PseudoCommands) do
					local Dist = StringDistance(SubCommand, Name)
					if Dist < BestDistance then
						BestDistance = Dist
						Nearest = Name
					end
				end

				if BestDistance <= 3 then
					return Nearest
				end
				return nil
			end

			local function EssentialsPseudoCommand(QuickExecutor, Subcommand, ...)
				if not Subcommand or Subcommand == "" then
					QuickExecutor.Log("Available subcommands:")
					for CommandName in pairs(PseudoCommands) do
						QuickExecutor.Log(`\t{CommandName}`)
					end
					return
				end

				Subcommand = string.lower(Subcommand)

				if PseudoCommands[Subcommand] then
					PseudoCommands[Subcommand](QuickExecutor, ...)
				else
					local Nearest = FindNearestSubCommand(Subcommand)
					if Nearest then
						QuickExecutor.Log(`<font color="#FF5555">Unknown subcommand</font> '{Subcommand}'<font color="#FF5555">. Did you mean</font> '{Nearest}'<font color="#FF5555">?</font>`)
					else
						QuickExecutor.Log(`<font color="#FF5555">Unknown subcommand. Use</font> '{TerminalSyntaxHighligher("ess")}' <font color="#FF5555">for a list of available subcommands.</font>`)
					end
				end
			end

			ExecutorAPI.RegisterCommandlet("ess", EssentialsPseudoCommand)
		end

		for _, Service in pairs(Global.E_Services) do
			Global.EngineFuse.AddService(Service)
			if Service.Init then
				Service.Init({
					EssentialsPlugin = Global.EssentialsPlugin;
					EssentialsPack = {
						Libraries = Global.Libraries;
						Components = Global.Components;
						Core = Global.Core;
					};
					EssentialsMouse = Global.EssentialsMouse;
					EngineInterfaceFunctions = Global.EngineInterfaceFunctions;
					EngineFuse = Global.EngineFuse;
					EngineSignals = Global.EngineSignals;
					APIFunctions = Global.APIFunctions;
					EssentialsMainUI = Global.EngineInterface;
					NotificationsInterface = Global.NotificationsInterface;
					ActionsInterface = Global.ActionsInterface;
					EssentialsLauncher = Global.EssentialsLauncher;
					NewInterface = Global.NewInterface
				})
			end
			RunService.Heartbeat:Wait()
		end

		task.wait(3)
	end

	return EngineInterfaceFunctions
end
