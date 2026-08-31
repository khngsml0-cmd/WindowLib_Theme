-- Themes/Modern.lua
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ModernModule = {
	Type = "Modern",
	Palettes = {
		Dark = {
			Type = "Modern",
			MainBackground = Color3.fromRGB(30, 30, 30),
			MainStroke = Color3.fromRGB(45, 45, 45),
			TopBarBackground = Color3.fromRGB(20, 20, 20),
			TopBarLine = Color3.fromRGB(50, 50, 50),
			TitleTextColor = Color3.fromRGB(240, 240, 240),
			TopBarNavDefault = Color3.fromRGB(20, 20, 20),
			TopBarNavHover = Color3.fromRGB(45, 45, 45),
			TopBarNavClick = Color3.fromRGB(65, 65, 65),
			TopBarIconColor = Color3.fromRGB(240, 240, 240),

			ContextMenuBackground = Color3.fromRGB(35, 35, 35),
			ContextMenuStroke = Color3.fromRGB(60, 60, 60),
			ContextItemDefault = Color3.fromRGB(35, 35, 35),
			ContextItemHover = Color3.fromRGB(40, 90, 150),
			ContextItemText = Color3.fromRGB(240, 240, 240),
			ContextItemTextDisabled = Color3.fromRGB(140, 140, 140),
			ContextItemSeparator = Color3.fromRGB(70, 70, 70),
			ContextCheckBoxBg = Color3.fromRGB(25, 25, 25),
			ContextCheckMark = Color3.fromRGB(45, 120, 200),
			ContextArrow = Color3.fromRGB(180, 180, 180),

			NotiBackground = Color3.fromRGB(25, 25, 25),
			NotiStroke = Color3.fromRGB(55, 55, 55),
			NotiTitle = Color3.fromRGB(255, 255, 255),
			NotiSubtitle = Color3.fromRGB(200, 200, 200),
			NotiCloseIcon = Color3.fromRGB(220, 220, 220),

			SwitcherBackground = Color3.fromRGB(25, 25, 25),
			SwitcherCardBg = Color3.fromRGB(35, 35, 35),
			SwitcherCardSelected = Color3.fromRGB(50, 50, 50),
		},
		Light = {
			Type = "Modern",
			MainBackground = Color3.fromRGB(255, 255, 255),
			MainStroke = Color3.fromRGB(220, 220, 220),
			TopBarBackground = Color3.fromRGB(245, 245, 245),
			TopBarLine = Color3.fromRGB(225, 225, 225),
			TitleTextColor = Color3.fromRGB(30, 30, 30),
			TopBarNavDefault = Color3.fromRGB(245, 245, 245),
			TopBarNavHover = Color3.fromRGB(225, 225, 225),
			TopBarNavClick = Color3.fromRGB(205, 205, 205),
			TopBarIconColor = Color3.fromRGB(40, 40, 40),

			ContextMenuBackground = Color3.fromRGB(255, 255, 255),
			ContextMenuStroke = Color3.fromRGB(215, 215, 215),
			ContextItemDefault = Color3.fromRGB(255, 255, 255),
			ContextItemHover = Color3.fromRGB(0, 120, 215),
			ContextItemText = Color3.fromRGB(30, 30, 30),
			ContextItemTextDisabled = Color3.fromRGB(150, 150, 150),
			ContextItemSeparator = Color3.fromRGB(225, 225, 225),
			ContextCheckBoxBg = Color3.fromRGB(230, 230, 230),
			ContextCheckMark = Color3.fromRGB(0, 120, 215),
			ContextArrow = Color3.fromRGB(100, 100, 100),

			NotiBackground = Color3.fromRGB(255, 255, 255),
			NotiStroke = Color3.fromRGB(215, 215, 215),
			NotiTitle = Color3.fromRGB(20, 20, 20),
			NotiSubtitle = Color3.fromRGB(90, 90, 90),
			NotiCloseIcon = Color3.fromRGB(60, 60, 60),

			SwitcherBackground = Color3.fromRGB(245, 245, 245),
			SwitcherCardBg = Color3.fromRGB(255, 255, 255),
			SwitcherCardSelected = Color3.fromRGB(230, 230, 230),
		}
	}
}

local TWEEN_INFO_SMOOTH = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
local TWEEN_INFO_OPEN   = TweenInfo.new(0.18, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
local TWEEN_INFO_CLOSE  = TweenInfo.new(0.15, Enum.EasingStyle.Cubic, Enum.EasingDirection.In)
local TWEEN_INFO_THEME  = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)

local function applyHoverEffect(button, defaultColor, hoverColor, clickColor)
	local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	button.BackgroundColor3 = defaultColor

	button.MouseEnter:Connect(function()
		if button.Active then
			TweenService:Create(button, tweenInfo, {BackgroundColor3 = hoverColor}):Play()
		end
	end)
	button.MouseLeave:Connect(function()
		if button.Active then
			TweenService:Create(button, tweenInfo, {BackgroundColor3 = defaultColor}):Play()
		end
	end)

	if clickColor then
		button.MouseButton1Down:Connect(function()
			if button.Active then
				TweenService:Create(button, tweenInfo, {BackgroundColor3 = clickColor}):Play()
			end
		end)
		button.MouseButton1Up:Connect(function()
			if button.Active then
				TweenService:Create(button, tweenInfo, {BackgroundColor3 = hoverColor}):Play()
			end
		end)
	end

	return {
		UpdateColors = function(newDefault, newHover, newClick)
			defaultColor = newDefault
			hoverColor = newHover
			clickColor = newClick or clickColor
			TweenService:Create(button, tweenInfo, {BackgroundColor3 = defaultColor}):Play()
		end
	}
end

function ModernModule.CreateWindow(Core, config, subThemeName)
	local currentTheme = ModernModule.Palettes[subThemeName or "Dark"] or ModernModule.Palettes.Dark
	local windowTitle = config.Title or "Window"
	local windowIcon = config.Icon or "rbxasset://textures/ui/GuiImagePlaceholder.png"
	local targetParent = config.Parent or Core.NonUserGui

	local hideMinimize = config.HideMinimize or false
	local hideMaximize = config.HideMaximize or false
	local hideClose = config.HideClose or false
	local isRounded = (config.Rounded ~= false)
	local defaultSize = config.Size or UDim2.new(0, 700, 0, 420)
	local initialPos = config.Position or Core.GetNextCascadePosition(defaultSize, targetParent)

	local WindowState = {
		IsMaximized = false,
		IsMinimized = false,
		IsClosing = false,
		IsSnapped = nil,
		IsFocused = true,
		IsRounded = isRounded,
		SavedSize = defaultSize,
		SavedPos = initialPos,
		MinSize = Vector2.new(240, 150)
	}

	local centerSpawnPos = UDim2.new(
		WindowState.SavedPos.X.Scale,
		WindowState.SavedPos.X.Offset + (WindowState.SavedSize.X.Offset * 0.5),
		WindowState.SavedPos.Y.Scale,
		WindowState.SavedPos.Y.Offset + (WindowState.SavedSize.Y.Offset * 0.5)
	)

	local initW = WindowState.SavedSize.X.Offset * 0.95
	local initH = WindowState.SavedSize.Y.Offset * 0.95

	local MainFrame = Instance.new("ImageButton", targetParent)
	MainFrame.Name = "Window_" .. windowTitle
	MainFrame.BorderSizePixel = 0
	MainFrame.AutoButtonColor = false
	MainFrame.BackgroundColor3 = currentTheme.MainBackground
	MainFrame.BackgroundTransparency = 1
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.Position = centerSpawnPos
	MainFrame.Size = UDim2.new(WindowState.SavedSize.X.Scale, initW, WindowState.SavedSize.Y.Scale, initH)
	MainFrame.ClipsDescendants = true
	MainFrame.ZIndex = Core.GetNextZIndex()

	local MainCorner = Instance.new("UICorner", MainFrame)
	MainCorner.CornerRadius = WindowState.IsRounded and UDim.new(0, 8) or UDim.new(0, 0)

	local MainUIStroke = Instance.new("UIStroke", MainFrame)
	MainUIStroke.Color = currentTheme.MainStroke
	MainUIStroke.Transparency = 1

	local TopBar = Instance.new("ImageButton", MainFrame)
	TopBar.Name = "TopBar"
	TopBar.BorderSizePixel = 0
	TopBar.AutoButtonColor = false
	TopBar.BackgroundColor3 = currentTheme.TopBarBackground
	TopBar.BackgroundTransparency = 1
	TopBar.Size = UDim2.new(1, 0, 0, 28)
	TopBar.ZIndex = 5

	local TopBarCorner = Instance.new("UICorner", TopBar)
	TopBarCorner.CornerRadius = WindowState.IsRounded and UDim.new(0, 8) or UDim.new(0, 0)

	local Line = Instance.new("Frame", TopBar)
	Line.Name = "Line"
	Line.BorderSizePixel = 0
	Line.BackgroundColor3 = currentTheme.TopBarLine
	Line.BackgroundTransparency = 1
	Line.AnchorPoint = Vector2.new(0, 1)
	Line.Size = UDim2.new(1, 0, 0, 1)
	Line.Position = UDim2.new(0, 0, 1, 0)
	Line.ZIndex = 6

	local Fix = Instance.new("Frame", TopBar)
	Fix.Name = "Fix"
	Fix.BorderSizePixel = 0
	Fix.BackgroundColor3 = currentTheme.TopBarBackground
	Fix.BackgroundTransparency = 1
	Fix.AnchorPoint = Vector2.new(0, 1)
	Fix.Size = UDim2.new(1, 0, 0.5, 0)
	Fix.Position = UDim2.new(0, 0, 1, 0)
	Fix.ZIndex = 5

	local TitleFrame = Instance.new("Frame", TopBar)
	TitleFrame.Name = "Title"
	TitleFrame.ZIndex = 6
	TitleFrame.BackgroundTransparency = 1
	TitleFrame.Size = UDim2.new(0.5, 0, 1, 0)

	local TitleLayout = Instance.new("UIListLayout", TitleFrame)
	TitleLayout.Padding = UDim.new(0, 6)
	TitleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	TitleLayout.FillDirection = Enum.FillDirection.Horizontal

	local TitlePadding = Instance.new("UIPadding", TitleFrame)
	TitlePadding.PaddingLeft = UDim.new(0, 8)

	local IconLabel = Instance.new("ImageLabel", TitleFrame)
	IconLabel.Name = "Icon"
	IconLabel.ZIndex = 7
	IconLabel.BackgroundTransparency = 1
	IconLabel.ImageTransparency = 1
	IconLabel.Image = windowIcon
	IconLabel.Size = UDim2.new(0, 18, 0, 18)
	Instance.new("UICorner", IconLabel).CornerRadius = UDim.new(0, 2)

	local TitleLabel = Instance.new("TextLabel", TitleFrame)
	TitleLabel.Name = "Title"
	TitleLabel.ZIndex = 7
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.TextTransparency = 1
	TitleLabel.TextSize = 13
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.TextColor3 = currentTheme.TitleTextColor
	TitleLabel.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
	TitleLabel.Text = windowTitle
	TitleLabel.Size = UDim2.new(0, 50, 1, 0)
	TitleLabel.AutomaticSize = Enum.AutomaticSize.X

	local NavFrame = Instance.new("Frame", TopBar)
	NavFrame.Name = "Nav"
	NavFrame.ZIndex = 6
	NavFrame.BackgroundTransparency = 1
	NavFrame.AnchorPoint = Vector2.new(1, 0)
	NavFrame.Size = UDim2.new(0.5, 0, 1, 0)
	NavFrame.Position = UDim2.new(1, 0, 0, 0)

	local NavLayout = Instance.new("UIListLayout", NavFrame)
	NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	NavLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	NavLayout.FillDirection = Enum.FillDirection.Horizontal
	NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NavLayout.Padding = UDim.new(0, 4)

	local NavPadding = Instance.new("UIPadding", NavFrame)
	NavPadding.PaddingRight = UDim.new(0, 6)

	local MinBtn = Instance.new("ImageButton", NavFrame)
	MinBtn.Name = "MinimizeButton"
	MinBtn.ZIndex = 7
	MinBtn.Size = UDim2.new(0, 20, 0, 20)
	MinBtn.LayoutOrder = 1
	MinBtn.Active = true
	MinBtn.Visible = not hideMinimize
	MinBtn.BackgroundTransparency = 1
	Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 3)
	local minHover = applyHoverEffect(MinBtn, currentTheme.TopBarNavDefault, currentTheme.TopBarNavHover, currentTheme.TopBarNavClick)

	local MinImg = Instance.new("ImageLabel", MinBtn)
	MinImg.ZIndex = 8
	MinImg.BackgroundTransparency = 1
	MinImg.ImageTransparency = 1
	MinImg.AnchorPoint = Vector2.new(0.5, 0.5)
	MinImg.Position = UDim2.new(0.5, 0, 0.5, 0)
	MinImg.Size = UDim2.new(0, 14, 0, 14)
	MinImg.Image = "rbxassetid://11293980042"
	MinImg.ImageColor3 = currentTheme.TopBarIconColor

	local MaxBtn = Instance.new("ImageButton", NavFrame)
	MaxBtn.Name = "MaximizeButton"
	MaxBtn.ZIndex = 7
	MaxBtn.Size = UDim2.new(0, 20, 0, 20)
	MaxBtn.LayoutOrder = 2
	MaxBtn.Active = true
	MaxBtn.Visible = not hideMaximize
	MaxBtn.BackgroundTransparency = 1
	Instance.new("UICorner", MaxBtn).CornerRadius = UDim.new(0, 3)
	local maxHover = applyHoverEffect(MaxBtn, currentTheme.TopBarNavDefault, currentTheme.TopBarNavHover, currentTheme.TopBarNavClick)

	local MaxImg = Instance.new("ImageLabel", MaxBtn)
	MaxImg.ZIndex = 8
	MaxImg.BackgroundTransparency = 1
	MaxImg.ImageTransparency = 1
	MaxImg.AnchorPoint = Vector2.new(0.5, 0.5)
	MaxImg.Position = UDim2.new(0.5, 0, 0.5, 0)
	MaxImg.Size = UDim2.new(0, 14, 0, 14)
	MaxImg.Image = "rbxassetid://11293980310"
	MaxImg.ImageColor3 = currentTheme.TopBarIconColor

	local CloseBtn = Instance.new("ImageButton", NavFrame)
	CloseBtn.Name = "CloseButton"
	CloseBtn.ZIndex = 7
	CloseBtn.Size = UDim2.new(0, 20, 0, 20)
	CloseBtn.LayoutOrder = 3
	CloseBtn.Active = true
	CloseBtn.Visible = not hideClose
	CloseBtn.BackgroundTransparency = 1
	Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 3)
	local closeHover = applyHoverEffect(CloseBtn, currentTheme.TopBarNavDefault, Color3.fromRGB(232, 17, 35), Color3.fromRGB(160, 0, 15))

	local CloseImg = Instance.new("ImageLabel", CloseBtn)
	CloseImg.ZIndex = 8
	CloseImg.BackgroundTransparency = 1
	CloseImg.ImageTransparency = 1
	CloseImg.AnchorPoint = Vector2.new(0.5, 0.5)
	CloseImg.Position = UDim2.new(0.5, 0, 0.5, 0)
	CloseImg.Size = UDim2.new(0, 14, 0, 14)
	CloseImg.Image = "rbxassetid://11293981586"
	CloseImg.ImageColor3 = currentTheme.TopBarIconColor

	CloseBtn.MouseEnter:Connect(function() CloseImg.ImageColor3 = Color3.fromRGB(255, 255, 255) end)
	CloseBtn.MouseLeave:Connect(function() CloseImg.ImageColor3 = currentTheme.TopBarIconColor end)

	local Non_Container = Instance.new("Frame", MainFrame)
	Non_Container.Name = "Non_Container"
	Non_Container.BackgroundTransparency = 1
	Non_Container.Size = UDim2.new(1, 0, 1, -28)
	Non_Container.Position = UDim2.new(0, 0, 0, 28)
	Non_Container.ZIndex = 2
	Non_Container.Visible = false

	local openTween = TweenService:Create(MainFrame, TWEEN_INFO_OPEN, {Size = WindowState.SavedSize, BackgroundTransparency = 0})
	openTween:Play()
	TweenService:Create(MainUIStroke, TWEEN_INFO_OPEN, {Transparency = 0}):Play()
	TweenService:Create(TopBar, TWEEN_INFO_OPEN, {BackgroundTransparency = 0}):Play()
	TweenService:Create(Line, TWEEN_INFO_OPEN, {BackgroundTransparency = 0}):Play()
	TweenService:Create(Fix, TWEEN_INFO_OPEN, {BackgroundTransparency = 0}):Play()
	TweenService:Create(TitleLabel, TWEEN_INFO_OPEN, {TextTransparency = 0}):Play()
	TweenService:Create(IconLabel, TWEEN_INFO_OPEN, {ImageTransparency = 0}):Play()
	TweenService:Create(MinBtn, TWEEN_INFO_OPEN, {BackgroundTransparency = 0}):Play()
	TweenService:Create(MinImg, TWEEN_INFO_OPEN, {ImageTransparency = 0}):Play()
	TweenService:Create(MaxBtn, TWEEN_INFO_OPEN, {BackgroundTransparency = 0}):Play()
	TweenService:Create(MaxImg, TWEEN_INFO_OPEN, {ImageTransparency = 0}):Play()
	TweenService:Create(CloseBtn, TWEEN_INFO_OPEN, {BackgroundTransparency = 0}):Play()
	TweenService:Create(CloseImg, TWEEN_INFO_OPEN, {ImageTransparency = 0}):Play()

	openTween.Completed:Connect(function()
		if not WindowState.IsClosing and not WindowState.IsMinimized then
			MainFrame.AnchorPoint = Vector2.new(0, 0)
			MainFrame.Position = WindowState.SavedPos
			MainFrame.Size = WindowState.SavedSize
			Non_Container.Visible = true
		end
	end)

	local windowRecord = {}

	local function setFocusVisual(isFocused)
		WindowState.IsFocused = isFocused
		local titleColor = isFocused and currentTheme.TitleTextColor or currentTheme.ContextItemTextDisabled
		local iconColor = isFocused and currentTheme.TopBarIconColor or currentTheme.ContextItemTextDisabled
		TweenService:Create(TitleLabel, TWEEN_INFO_SMOOTH, {TextColor3 = titleColor}):Play()
		TweenService:Create(MinImg, TWEEN_INFO_SMOOTH, {ImageColor3 = iconColor}):Play()
		TweenService:Create(MaxImg, TWEEN_INFO_SMOOTH, {ImageColor3 = iconColor}):Play()
		TweenService:Create(CloseImg, TWEEN_INFO_SMOOTH, {ImageColor3 = iconColor}):Play()
	end

	local function bringToFront()
		Core.BringToFront(MainFrame, windowRecord)
	end

	MainFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
			bringToFront()
		end
	end)

	local function setMaximizeState(maximized)
		if WindowState.IsMinimized then return end
		WindowState.IsMaximized = maximized
		WindowState.IsSnapped = nil
		if maximized then
			WindowState.SavedSize = MainFrame.Size
			WindowState.SavedPos = MainFrame.Position
			MinBtn.Active = false
			MinImg.ImageTransparency = 0.5
			TweenService:Create(MainFrame, TWEEN_INFO_SMOOTH, {Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(1, 0, 1, 0)}):Play()
		else
			MinBtn.Active = true
			MinImg.ImageTransparency = 0
			TweenService:Create(MainFrame, TWEEN_INFO_SMOOTH, {Position = WindowState.SavedPos, Size = WindowState.SavedSize}):Play()
		end
	end

	local lastTopBarClick = 0
	TopBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local now = tick()
			if now - lastTopBarClick < 0.28 and not WindowState.IsMinimized and not hideMaximize then
				setMaximizeState(not WindowState.IsMaximized)
				lastTopBarClick = 0
			else
				lastTopBarClick = now
			end
		end
	end)

	local dragging = false
	local dragInput, dragStart, startPos
	local snapTarget = nil

	local function setMinimizeState(minimize)
		if WindowState.IsMaximized then return end
		WindowState.IsMinimized = minimize
		if minimize then
			WindowState.SavedSize = MainFrame.Size
			WindowState.SavedPos = MainFrame.Position
			Line.Visible = false
			Fix.Visible = false
			MaxBtn.Active = false
			MaxImg.ImageTransparency = 0.5
			Non_Container.Visible = false
			Core.RegisterMinimized(windowRecord)
		else
			Core.UnregisterMinimized(windowRecord)
			Non_Container.Visible = true
			Line.Visible = true
			Fix.Visible = true
			MaxBtn.Active = true
			MaxImg.ImageTransparency = 0
			TweenService:Create(MainFrame, TWEEN_INFO_SMOOTH, {Position = WindowState.SavedPos, Size = WindowState.SavedSize}):Play()
			bringToFront()
		end
	end

	TopBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
			bringToFront()
		end

		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if WindowState.IsMinimized then setMinimizeState(false); return end

			local useOutlineDrag = (config.OutlineDrag ~= nil) and config.OutlineDrag or Core.IsGlobalOutlineDrag()
			dragging = true
			dragStart = input.Position
			startPos = MainFrame.Position

			if useOutlineDrag then
				Core.DragOutlineFrame.Size = MainFrame.Size
				Core.DragOutlineFrame.Position = MainFrame.Position
				Core.DragOutlineFrame.Visible = true
			end

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					if dragging then
						dragging = false
						Core.HideSnapGhost()
						if useOutlineDrag then Core.DragOutlineFrame.Visible = false end

						if snapTarget == "Top" then setMaximizeState(true)
						elseif snapTarget == "Left" then
							WindowState.IsSnapped = "Left"
							WindowState.SavedPos = startPos
							WindowState.SavedSize = MainFrame.Size
							TweenService:Create(MainFrame, TWEEN_INFO_SMOOTH, {Position = UDim2.new(0, 0, 0, 0), Size = UDim2.new(0.5, 0, 1, 0)}):Play()
						elseif snapTarget == "Right" then
							WindowState.IsSnapped = "Right"
							WindowState.SavedPos = startPos
							WindowState.SavedSize = MainFrame.Size
							TweenService:Create(MainFrame, TWEEN_INFO_SMOOTH, {Position = UDim2.new(0.5, 0, 0, 0), Size = UDim2.new(0.5, 0, 1, 0)}):Play()
						else
							if useOutlineDrag then MainFrame.Position = Core.DragOutlineFrame.Position end
						end
						snapTarget = nil
					end
				end
			end)
		end
	end)

	TopBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging and not WindowState.IsMinimized then
			local delta = input.Position - dragStart
			local useOutlineDrag = (config.OutlineDrag ~= nil) and config.OutlineDrag or Core.IsGlobalOutlineDrag()

			if WindowState.IsMaximized or WindowState.IsSnapped then
				WindowState.IsMaximized = false; WindowState.IsSnapped = nil
				MinBtn.Active = true; MinImg.ImageTransparency = 0
				local parentW = targetParent.AbsoluteSize.X > 0 and targetParent.AbsoluteSize.X or (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 1920)
				local ratioX = (input.Position.X) / parentW
				local targetW = WindowState.SavedSize.X.Offset
				startPos = UDim2.new(0, input.Position.X - (targetW * ratioX), 0, input.Position.Y - 14)
				MainFrame.Size = WindowState.SavedSize
				if useOutlineDrag then Core.DragOutlineFrame.Size = WindowState.SavedSize end
			end

			local newX = startPos.X.Offset + delta.X
			local newY = startPos.Y.Offset + delta.Y
			local targetPos = UDim2.new(startPos.X.Scale, newX, startPos.Y.Scale, newY)

			if useOutlineDrag then Core.DragOutlineFrame.Position = targetPos
			else MainFrame.Position = targetPos end

			if targetParent == Core.NonUserGui then
				local camera = workspace.CurrentCamera
				local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
				local mousePos = UserInputService:GetMouseLocation()
				if mousePos.Y <= 6 then
					snapTarget = "Top"
					Core.ShowSnapGhost(UDim2.new(0, 6, 0, 6), UDim2.new(1, -12, 1, -12))
				elseif mousePos.X <= 6 then
					snapTarget = "Left"
					Core.ShowSnapGhost(UDim2.new(0, 6, 0, 6), UDim2.new(0.5, -9, 1, -12))
				elseif mousePos.X >= viewport.X - 6 then
					snapTarget = "Right"
					Core.ShowSnapGhost(UDim2.new(0.5, 3, 0, 6), UDim2.new(0.5, -9, 1, -12))
				else
					snapTarget = nil
					Core.HideSnapGhost()
				end
			end
		end
	end)

	local handles = {
		Top = {Size = UDim2.new(1, -16, 0, 6), Pos = UDim2.new(0, 8, 0, -3)},
		Bottom = {Size = UDim2.new(1, -16, 0, 6), Pos = UDim2.new(0, 8, 1, -3)},
		Left = {Size = UDim2.new(0, 6, 1, -16), Pos = UDim2.new(0, -3, 0, 8)},
		Right = {Size = UDim2.new(0, 6, 1, -16), Pos = UDim2.new(1, -3, 0, 8)},
		TopLeft = {Size = UDim2.new(0, 10, 0, 10), Pos = UDim2.new(0, -3, 0, -3)},
		TopRight = {Size = UDim2.new(0, 10, 0, 10), Pos = UDim2.new(1, -7, 0, -3)},
		BottomLeft = {Size = UDim2.new(0, 10, 0, 10), Pos = UDim2.new(0, -3, 1, -7)},
		BottomRight = {Size = UDim2.new(0, 10, 0, 10), Pos = UDim2.new(1, -7, 1, -7)}
	}

	for name, info in pairs(handles) do
		local handle = Instance.new("ImageButton", MainFrame)
		handle.Name = "Resize_" .. name
		handle.BackgroundTransparency = 1
		handle.BorderSizePixel = 0
		handle.Size = info.Size
		handle.Position = info.Pos
		handle.ZIndex = 4

		local resizing = false
		local resizeStart, startFramePos, startFrameSize
		local lastInnerResizeTick = 0

		handle.InputBegan:Connect(function(input)
			if WindowState.IsMaximized or WindowState.IsMinimized then return end
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				bringToFront()
				resizing = true
				resizeStart = input.Position
				startFramePos = MainFrame.Position
				startFrameSize = MainFrame.Size
				lastInnerResizeTick = tick()
				Non_Container.Size = UDim2.new(0, startFrameSize.X.Offset, 0, startFrameSize.Y.Offset - 28)

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						resizing = false
						Non_Container.Size = UDim2.new(1, 0, 1, -28)
					end
				end)
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if resizing and input.UserInputType == Enum.UserInputType.MouseMovement and not WindowState.IsMaximized and not WindowState.IsMinimized then
				local delta = input.Position - resizeStart
				local startW = startFrameSize.X.Offset; local startH = startFrameSize.Y.Offset
				local startX = startFramePos.X.Offset; local startY = startFramePos.Y.Offset

				local newW = startW; local newH = startH
				local newX = startX; local newY = startY

				if name:find("Right") then newW = math.max(WindowState.MinSize.X, startW + delta.X)
				elseif name:find("Left") then newW = math.max(WindowState.MinSize.X, startW - delta.X); newX = startX - (newW - startW) end

				if name:find("Bottom") then newH = math.max(WindowState.MinSize.Y, startH + delta.Y)
				elseif name:find("Top") then newH = math.max(WindowState.MinSize.Y, startH - delta.Y); newY = startY - (newH - startH) end

				MainFrame.Size = UDim2.new(startFrameSize.X.Scale, newW, startFrameSize.Y.Scale, newH)
				MainFrame.Position = UDim2.new(startFramePos.X.Scale, newX, startFramePos.Y.Scale, newY)

				if tick() - lastInnerResizeTick >= 0.045 then
					lastInnerResizeTick = tick()
					Non_Container.Size = UDim2.new(0, newW, 0, newH - 28)
				end
			end
		end)
	end

	local function destroyWindow()
		Core.UnregisterMinimized(windowRecord)
		Core.UnregisterActiveWindow(windowRecord)
		MainFrame:Destroy()
	end

	CloseBtn.MouseButton1Click:Connect(function()
		if WindowState.IsClosing then return end
		WindowState.IsClosing = true
		Non_Container.Visible = false

		local curPos = MainFrame.Position; local curSize = MainFrame.Size
		MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
		MainFrame.Position = UDim2.new(
			curPos.X.Scale, curPos.X.Offset + (curSize.X.Offset * 0.5),
			curPos.Y.Scale, curPos.Y.Offset + (curSize.Y.Offset * 0.5)
		)

		local closeTargetSize = UDim2.new(curSize.X.Scale, curSize.X.Offset * 0.95, curSize.Y.Scale, curSize.Y.Offset * 0.95)
		TweenService:Create(MainFrame, TWEEN_INFO_CLOSE, {Size = closeTargetSize, BackgroundTransparency = 1}):Play()
		TweenService:Create(MainUIStroke, TWEEN_INFO_CLOSE, {Transparency = 1}):Play()

		for _, descendant in ipairs(MainFrame:GetDescendants()) do
			if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
				TweenService:Create(descendant, TWEEN_INFO_CLOSE, {TextTransparency = 1}):Play()
			elseif descendant:IsA("ImageLabel") or descendant:IsA("ImageButton") then
				TweenService:Create(descendant, TWEEN_INFO_CLOSE, {ImageTransparency = 1, BackgroundTransparency = 1}):Play()
			elseif descendant:IsA("Frame") then
				TweenService:Create(descendant, TWEEN_INFO_CLOSE, {BackgroundTransparency = 1}):Play()
			elseif descendant:IsA("UIStroke") then
				TweenService:Create(descendant, TWEEN_INFO_CLOSE, {Transparency = 1}):Play()
			end
		end

		task.delay(0.16, function() destroyWindow() end)
	end)

	MinBtn.MouseButton1Click:Connect(function()
		if not MinBtn.Active or WindowState.IsMaximized then return end
		setMinimizeState(not WindowState.IsMinimized)
	end)

	MaxBtn.MouseButton1Click:Connect(function()
		if not MaxBtn.Active or WindowState.IsMinimized then return end
		setMaximizeState(not WindowState.IsMaximized)
	end)

	local function setWindowRounded(rounded)
		WindowState.IsRounded = rounded
		local rad = rounded and UDim.new(0, 8) or UDim.new(0, 0)
		MainCorner.CornerRadius = rad; TopBarCorner.CornerRadius = rad
	end

	local function updateWindowTheme(theme)
		if theme.Type == "Classic" then return end
		currentTheme = theme
		TweenService:Create(MainFrame, TWEEN_INFO_THEME, {BackgroundColor3 = theme.MainBackground}):Play()
		TweenService:Create(MainUIStroke, TWEEN_INFO_THEME, {Color = theme.MainStroke}):Play()
		TweenService:Create(TopBar, TWEEN_INFO_THEME, {BackgroundColor3 = theme.TopBarBackground}):Play()
		TweenService:Create(Fix, TWEEN_INFO_THEME, {BackgroundColor3 = theme.TopBarBackground}):Play()
		TweenService:Create(Line, TWEEN_INFO_THEME, {BackgroundColor3 = theme.TopBarLine}):Play()
		TweenService:Create(TitleLabel, TWEEN_INFO_THEME, {TextColor3 = theme.TitleTextColor}):Play()

		minHover.UpdateColors(theme.TopBarNavDefault, theme.TopBarNavHover, theme.TopBarNavClick)
		maxHover.UpdateColors(theme.TopBarNavDefault, theme.TopBarNavHover, theme.TopBarNavClick)
		closeHover.UpdateColors(theme.TopBarNavDefault, Color3.fromRGB(232, 17, 35), Color3.fromRGB(160, 0, 15))

		TweenService:Create(MinImg, TWEEN_INFO_THEME, {ImageColor3 = theme.TopBarIconColor}):Play()
		TweenService:Create(MaxImg, TWEEN_INFO_THEME, {ImageColor3 = theme.TopBarIconColor}):Play()
		TweenService:Create(CloseImg, TWEEN_INFO_THEME, {ImageColor3 = theme.TopBarIconColor}):Play()
	end

	windowRecord.Frame = MainFrame
	windowRecord.TargetParent = targetParent
	windowRecord.UpdateTheme = updateWindowTheme
	windowRecord.SetFocusVisual = setFocusVisual
	windowRecord.SetRounded = setWindowRounded
	windowRecord.GetTitle = function() return TitleLabel.Text end
	windowRecord.GetIcon = function() return IconLabel.Image end
	windowRecord.Focus = function() bringToFront() end
	windowRecord.Minimize = function() setMinimizeState(true) end
	windowRecord.Restore = function() setMinimizeState(false) end
	windowRecord.IsMinimized = function() return WindowState.IsMinimized end

	local WindowAPI = {}
	function WindowAPI:GetFrame() return MainFrame end
	function WindowAPI:GetContainer() return Non_Container end
	function WindowAPI:GetNonUser() return Core.NonUserGui end
	function WindowAPI:GetCustomOpenUI() return Core.CustomOpenGui end
	function WindowAPI:Focus() bringToFront() end
	function WindowAPI:SetTitle(text) TitleLabel.Text = tostring(text) end
	function WindowAPI:SetIcon(iconId) IconLabel.Image = tostring(iconId) end
	function WindowAPI:SetVisible(visible) MainFrame.Visible = visible end
	function WindowAPI:SetRounded(rounded) setWindowRounded(rounded) end
	function WindowAPI:Close() destroyWindow() end
	function WindowAPI:Minimize() setMinimizeState(true) end
	function WindowAPI:Restore() setMinimizeState(false) end

	function WindowAPI:SetPosition(targetPos, animated, customTweenInfo)
		local finalPos = targetPos
		if typeof(targetPos) == "Vector2" then finalPos = UDim2.new(0, targetPos.X, 0, targetPos.Y)
		elseif typeof(targetPos) ~= "UDim2" then return end
		WindowState.SavedPos = finalPos
		if not WindowState.IsMaximized and not WindowState.IsMinimized then
			if animated then TweenService:Create(MainFrame, customTweenInfo or TWEEN_INFO_SMOOTH, {Position = finalPos}):Play()
			else MainFrame.Position = finalPos end
		end
	end

	function WindowAPI:MoveTo(targetPos, animated, customTweenInfo) self:SetPosition(targetPos, animated, customTweenInfo) end
	function WindowAPI:GetPosition() return MainFrame.Position end

	function WindowAPI:SetSize(targetSize, animated, customTweenInfo)
		local finalSize = targetSize
		if typeof(targetSize) == "Vector2" then finalSize = UDim2.new(0, targetSize.X, 0, targetSize.Y)
		elseif typeof(targetSize) ~= "UDim2" then return end
		WindowState.SavedSize = finalSize
		if not WindowState.IsMaximized and not WindowState.IsMinimized then
			if animated then TweenService:Create(MainFrame, customTweenInfo or TWEEN_INFO_SMOOTH, {Size = finalSize}):Play()
			else MainFrame.Size = finalSize end
		end
	end

	function WindowAPI:GetSize() return MainFrame.Size end
	function WindowAPI:ShowContextMenu(position, items) Core.RenderContextMenu(position, items, 1) end
	function WindowAPI:HideContextMenu() Core.ClearSubmenus(1) end
	function WindowAPI:BindContextMenu(guiObject, items, triggerType)
		triggerType = triggerType or "Right"
		if guiObject:IsA("GuiObject") then guiObject.Active = true end
		local function triggerMenu()
			local mousePos = UserInputService:GetMouseLocation()
			self:ShowContextMenu(mousePos, items)
		end

		if guiObject:IsA("GuiButton") then
			if triggerType == "Right" then guiObject.MouseButton2Click:Connect(triggerMenu)
			elseif triggerType == "Left" then guiObject.MouseButton1Click:Connect(triggerMenu)
			elseif triggerType == "Both" then guiObject.MouseButton1Click:Connect(triggerMenu); guiObject.MouseButton2Click:Connect(triggerMenu) end
		else
			guiObject.InputBegan:Connect(function(input)
				local isLeft = (input.UserInputType == Enum.UserInputType.MouseButton1)
				local isRight = (input.UserInputType == Enum.UserInputType.MouseButton2)
				if (triggerType == "Right" and isRight) or (triggerType == "Left" and isLeft) or (triggerType == "Both" and (isLeft or isRight)) then
					triggerMenu()
				end
			end)
		end
	end

	if config.TopBarContextMenu then
		WindowAPI:BindContextMenu(TopBar, config.TopBarContextMenu, config.TopBarContextMenuTrigger or "Right")
	end

	windowRecord.API = WindowAPI
	return windowRecord
end

return ModernModule
