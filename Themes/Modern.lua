-- Themes/Modern.lua
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ModernTheme = {
	Type = "Modern",
	Palettes = {
		Dark = {
			MainBackground = Color3.fromRGB(30, 30, 30),
			MainStroke = Color3.fromRGB(45, 45, 45),
			TopBarBackground = Color3.fromRGB(20, 20, 20),
			TopBarLine = Color3.fromRGB(50, 50, 50),
			TitleTextColor = Color3.fromRGB(240, 240, 240),
			TopBarNavDefault = Color3.fromRGB(20, 20, 20),
			TopBarNavHover = Color3.fromRGB(45, 45, 45),
			TopBarNavClick = Color3.fromRGB(65, 65, 65),
			TopBarIconColor = Color3.fromRGB(240, 240, 240),
		},
		Light = {
			MainBackground = Color3.fromRGB(255, 255, 255),
			MainStroke = Color3.fromRGB(220, 220, 220),
			TopBarBackground = Color3.fromRGB(245, 245, 245),
			TopBarLine = Color3.fromRGB(225, 225, 225),
			TitleTextColor = Color3.fromRGB(30, 30, 30),
			TopBarNavDefault = Color3.fromRGB(245, 245, 245),
			TopBarNavHover = Color3.fromRGB(225, 225, 225),
			TopBarNavClick = Color3.fromRGB(205, 205, 205),
			TopBarIconColor = Color3.fromRGB(40, 40, 40),
		}
	}
}

local TWEEN_SMOOTH = TweenInfo.new(0.22, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local minimizedList = {}

local function updateMinimizedGrid(Core)
	local itemW, itemH, pad, marginX, marginY = 180, 28, 6, 10, 10
	local maxCols = math.max(1, math.floor(((workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 1920) - marginX) / (itemW + pad)))
	for idx, win in ipairs(minimizedList) do
		local col = (idx - 1) % maxCols
		local row = math.floor((idx - 1) / maxCols)
		TweenService:Create(win.Frame, TWEEN_SMOOTH, {
			Position = UDim2.new(0, marginX + col * (itemW + pad), 1, -(marginY + itemH + (row * (itemH + pad)))),
			Size = UDim2.new(0, itemW, 0, itemH)
		}):Play()
	end
end

function ModernTheme.CreateWindow(Core, config, subThemeName)
	local palette = ModernTheme.Palettes[subThemeName or "Dark"] or ModernTheme.Palettes.Dark
	local windowTitle = config.Title or "Window"
	local windowIcon = config.Icon or "rbxasset://textures/ui/GuiImagePlaceholder.png"
	local targetParent = config.Parent or Core.NonUserGui
	local defaultSize = config.Size or UDim2.new(0, 550, 0, 350)
	local initialPos = config.Position or Core.GetNextCascadePosition(defaultSize, targetParent)

	local WindowState = {
		IsMaximized = false,
		IsMinimized = false,
		SavedSize = defaultSize,
		SavedPos = initialPos,
	}

	local MainFrame = Instance.new("ImageButton", targetParent)
	MainFrame.Name = "ModernWindow_" .. windowTitle
	MainFrame.BorderSizePixel = 0
	MainFrame.AutoButtonColor = false
	MainFrame.BackgroundColor3 = palette.MainBackground
	MainFrame.Position = initialPos
	MainFrame.Size = defaultSize
	MainFrame.ClipsDescendants = true
	MainFrame.ZIndex = Core.GetNextZIndex()
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

	local MainStroke = Instance.new("UIStroke", MainFrame)
	MainStroke.Color = palette.MainStroke

	local TopBar = Instance.new("ImageButton", MainFrame)
	TopBar.Name = "TopBar"
	TopBar.BorderSizePixel = 0
	TopBar.BackgroundColor3 = palette.TopBarBackground
	TopBar.Size = UDim2.new(1, 0, 0, 28)
	TopBar.ZIndex = 5
	Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

	local Line = Instance.new("Frame", TopBar)
	Line.Name = "Line"
	Line.BorderSizePixel = 0
	Line.BackgroundColor3 = palette.TopBarLine
	Line.Size = UDim2.new(1, 0, 0, 1)
	Line.Position = UDim2.new(0, 0, 1, -1)
	Line.ZIndex = 6

	local Title = Instance.new("TextLabel", TopBar)
	Title.Name = "Title"
	Title.BackgroundTransparency = 1
	Title.Size = UDim2.new(1, -70, 1, 0)
	Title.Position = UDim2.new(0, 10, 0, 0)
	Title.Font = Enum.Font.GothamMedium
	Title.TextSize = 13
	Title.TextColor3 = palette.TitleTextColor
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Text = windowTitle
	Title.ZIndex = 6

	local CloseBtn = Instance.new("TextButton", TopBar)
	CloseBtn.Name = "Close"
	CloseBtn.Size = UDim2.new(0, 22, 0, 22)
	CloseBtn.Position = UDim2.new(1, -26, 0, 3)
	CloseBtn.BackgroundColor3 = palette.TopBarNavDefault
	CloseBtn.Text = "✕"
	CloseBtn.TextColor3 = palette.TopBarIconColor
	CloseBtn.BorderSizePixel = 0
	CloseBtn.ZIndex = 7
	Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

	local Container = Instance.new("Frame", MainFrame)
	Container.Name = "Container"
	Container.BackgroundTransparency = 1
	Container.Size = UDim2.new(1, 0, 1, -28)
	Container.Position = UDim2.new(0, 0, 0, 28)
	Container.ZIndex = 2

	local windowRecord = {}

	local function bringToFront()
		Core.BringToFront(MainFrame, windowRecord)
	end

	MainFrame.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			bringToFront()
		end
	end)

	-- Kéo thả & Aero Snap
	local isDragging, dragStart, startPos = false, nil, nil
	TopBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			bringToFront()
			isDragging = true
			dragStart = input.Position
			startPos = MainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					isDragging = false
					Core.HideSnapGhost()
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	local WindowAPI = {
		Frame = MainFrame,
		TargetParent = targetParent,
		GetFrame = function() return MainFrame end,
		GetContainer = function() return Container end,
		GetTitle = function() return Title.Text end,
		GetIcon = function() return windowIcon end,
		SetTitle = function(t) Title.Text = tostring(t) end,
		Close = function()
			Core.UnregisterActiveWindow(windowRecord)
			MainFrame:Destroy()
		end,
		Focus = function() bringToFront() end,
		SetFocusVisual = function(isFocused)
			Title.TextColor3 = isFocused and palette.TitleTextColor or Color3.fromRGB(140, 140, 140)
		end,
		UpdatePalette = function(newSubTheme)
			local newP = ModernTheme.Palettes[newSubTheme]
			if not newP then return end
			palette = newP
			TweenService:Create(MainFrame, TWEEN_SMOOTH, {BackgroundColor3 = palette.MainBackground}):Play()
			TweenService:Create(MainStroke, TWEEN_SMOOTH, {Color = palette.MainStroke}):Play()
			TweenService:Create(TopBar, TWEEN_SMOOTH, {BackgroundColor3 = palette.TopBarBackground}):Play()
			TweenService:Create(Line, TWEEN_SMOOTH, {BackgroundColor3 = palette.TopBarLine}):Play()
			TweenService:Create(Title, TWEEN_SMOOTH, {TextColor3 = palette.TitleTextColor}):Play()
			TweenService:Create(CloseBtn, TWEEN_SMOOTH, {BackgroundColor3 = palette.TopBarNavDefault, TextColor3 = palette.TopBarIconColor}):Play()
		end
	}

	for k, v in pairs(WindowAPI) do windowRecord[k] = v end
	CloseBtn.MouseButton1Click:Connect(function() WindowAPI.Close() end)

	return WindowAPI
end

return ModernTheme
