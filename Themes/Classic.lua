-- Themes/Classic.lua
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local ClassicTheme = {
	Type = "Classic",
	Palettes = {
		Classic = {
			MainBackground = Color3.fromRGB(255, 255, 255),
			MainStroke = Color3.fromRGB(107, 107, 107),
			TopBarBackground = Color3.fromRGB(51, 151, 251),
			TopBarLine = Color3.fromRGB(255, 255, 255),
			TitleTextColor = Color3.fromRGB(0, 0, 0),
		}
	}
}

local function apply3DBorder(frame)
	local border = Instance.new("Frame", frame)
	border.Name = "Border"; border.Size = UDim2.new(1, 0, 1, 0); border.BackgroundTransparency = 1; border.BorderSizePixel = 0
	local function addL(sz, ps, col)
		local l = Instance.new("Frame", border)
		l.BorderSizePixel = 0; l.Size = sz; l.Position = ps; l.BackgroundColor3 = col
	end
	addL(UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, -1), Color3.fromRGB(107, 107, 107))
	addL(UDim2.new(0, 1, 1, 0), UDim2.new(1, -1, 0, 0), Color3.fromRGB(107, 107, 107))
	addL(UDim2.new(1, -1, 0, 1), UDim2.new(0, 0, 0, 0), Color3.fromRGB(228, 228, 228))
	addL(UDim2.new(0, 1, 1, -1), UDim2.new(0, 0, 0, 0), Color3.fromRGB(228, 228, 228))
	return border
end

-- Taskbar Cổ Điển
local TaskbarFrame = nil
local function setupTaskbar(Core)
	if TaskbarFrame then return end
	TaskbarFrame = Instance.new("Frame", Core.NonUserGui)
	TaskbarFrame.Name = "ClassicTaskbar"
	TaskbarFrame.Size = UDim2.new(1, -20, 0, 26)
	TaskbarFrame.Position = UDim2.new(0.5, 0, 1, -28)
	TaskbarFrame.AnchorPoint = Vector2.new(0.5, 0)
	TaskbarFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TaskbarFrame.BorderSizePixel = 0
	TaskbarFrame.ZIndex = 8000
	apply3DBorder(TaskbarFrame)

	local layout = Instance.new("UIListLayout", TaskbarFrame)
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, 4)
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	local pad = Instance.new("UIPadding", TaskbarFrame)
	pad.PaddingLeft = UDim.new(0, 4)
end

function ClassicTheme.Init(Core)
	setupTaskbar(Core)
	if TaskbarFrame then TaskbarFrame.Visible = true end
end

function ClassicTheme.Cleanup(Core)
	if TaskbarFrame then TaskbarFrame.Visible = false end
end

function ClassicTheme.CreateWindow(Core, config)
	local defaultSize = config.Size or UDim2.new(0, 280, 0, 320)
	local defaultPos = config.Position or UDim2.new(0, 60, 0, 60)
	local targetParent = config.Parent or Core.NonUserGui
	local windowTitle = config.Title or "Window"

	local FloatingWindow = Instance.new("Frame", targetParent)
	FloatingWindow.Name = "ClassicWindow_" .. windowTitle
	FloatingWindow.Size = defaultSize
	FloatingWindow.Position = defaultPos
	FloatingWindow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	FloatingWindow.BorderSizePixel = 0
	FloatingWindow.ClipsDescendants = true
	FloatingWindow.ZIndex = Core.GetNextZIndex()
	apply3DBorder(FloatingWindow)

	local TitleBar = Instance.new("Frame", FloatingWindow)
	TitleBar.Name = "TitleBar"
	TitleBar.Size = UDim2.new(1, -8, 0, 18)
	TitleBar.Position = UDim2.new(0, 4, 0, 4)
	TitleBar.BackgroundColor3 = Color3.fromRGB(51, 151, 251)
	TitleBar.BorderSizePixel = 0

	local TitleText = Instance.new("TextLabel", TitleBar)
	TitleText.Size = UDim2.new(1, -25, 1, 0)
	TitleText.Position = UDim2.new(0, 4, 0, 0)
	TitleText.BackgroundTransparency = 1
	TitleText.Font = Enum.Font.SourceSansBold
	TitleText.TextSize = 14
	TitleText.TextColor3 = Color3.fromRGB(0, 0, 0)
	TitleText.TextXAlignment = Enum.TextXAlignment.Left
	TitleText.Text = windowTitle

	local CloseBtn = Instance.new("TextButton", TitleBar)
	CloseBtn.Size = UDim2.new(0, 14, 0, 14)
	CloseBtn.Position = UDim2.new(1, -16, 0, 2)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 220, 220)
	CloseBtn.Text = "✕"
	CloseBtn.Font = Enum.Font.SourceSansBold
	CloseBtn.TextSize = 10
	CloseBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
	CloseBtn.BorderSizePixel = 1

	local Container = Instance.new("Frame", FloatingWindow)
	Container.Name = "Container"
	Container.Position = UDim2.new(0, 4, 0, 24)
	Container.Size = UDim2.new(1, -8, 1, -28)
	Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Container.BorderSizePixel = 0

	local windowRecord = {}

	local function bringToFront()
		Core.BringToFront(FloatingWindow, windowRecord)
	end

	FloatingWindow.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then bringToFront() end
	end)

	local isDragging, dragStart, startPos = false, nil, nil
	TitleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			bringToFront()
			isDragging = true
			dragStart = input.Position
			startPos = FloatingWindow.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then isDragging = false end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			FloatingWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	local WindowAPI = {
		Frame = FloatingWindow,
		TargetParent = targetParent,
		GetFrame = function() return FloatingWindow end,
		GetContainer = function() return Container end,
		GetTitle = function() return TitleText.Text end,
		SetTitle = function(t) TitleText.Text = tostring(t) end,
		Close = function()
			Core.UnregisterActiveWindow(windowRecord)
			FloatingWindow:Destroy()
		end,
		Focus = function() bringToFront() end,
		SetFocusVisual = function(isFocused)
			TitleBar.BackgroundColor3 = isFocused and Color3.fromRGB(51, 151, 251) or Color3.fromRGB(129, 129, 129)
		end,
		UpdatePalette = function() end
	}

	for k, v in pairs(WindowAPI) do windowRecord[k] = v end
	CloseBtn.MouseButton1Click:Connect(function() WindowAPI.Close() end)

	return WindowAPI
end

return ClassicTheme
