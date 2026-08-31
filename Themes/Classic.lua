-- Themes/Classic.lua
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local ClassicModule = {
	Type = "Classic",
	Palettes = {
		Classic = {
			Type = "Classic",
			MainBackground = Color3.fromRGB(255, 255, 255),
			MainStroke = Color3.fromRGB(107, 107, 107),
			TopBarBackground = Color3.fromRGB(51, 151, 251),
			TopBarLine = Color3.fromRGB(255, 255, 255),
			TitleTextColor = Color3.fromRGB(0, 0, 0),
			TopBarNavDefault = Color3.fromRGB(240, 240, 240),
			TopBarNavHover = Color3.fromRGB(248, 248, 248),
			TopBarNavClick = Color3.fromRGB(225, 225, 225),
			TopBarIconColor = Color3.fromRGB(0, 0, 0),

			ContextMenuBackground = Color3.fromRGB(255, 255, 255),
			ContextMenuStroke = Color3.fromRGB(107, 107, 107),
			ContextItemDefault = Color3.fromRGB(255, 255, 255),
			ContextItemHover = Color3.fromRGB(225, 225, 225),
			ContextItemText = Color3.fromRGB(0, 0, 0),
			ContextItemTextDisabled = Color3.fromRGB(101, 101, 101),
			ContextItemSeparator = Color3.fromRGB(171, 171, 171),
			ContextCheckBoxBg = Color3.fromRGB(255, 255, 255),
			ContextCheckMark = Color3.fromRGB(86, 171, 255),
			ContextArrow = Color3.fromRGB(0, 0, 0),

			NotiBackground = Color3.fromRGB(255, 255, 255),
			NotiStroke = Color3.fromRGB(107, 107, 107),
			NotiTitle = Color3.fromRGB(0, 0, 0),
			NotiSubtitle = Color3.fromRGB(80, 80, 80),
			NotiCloseIcon = Color3.fromRGB(50, 50, 50),

			SwitcherBackground = Color3.fromRGB(255, 255, 255),
			SwitcherCardBg = Color3.fromRGB(255, 255, 255),
			SwitcherCardSelected = Color3.fromRGB(0, 171, 255),
		}
	}
}

local ICON_NORMAL = "rbxassetid://130313192476512"
local ICON_DRAG = "rbxassetid://129297489576933"
local ASSET_X_NORMAL = "rbxassetid://124970503845830"
local ASSET_X_PRESSED = "rbxassetid://81528672228578"

local isHoveringWindow = false
local lockedIcon = nil
local hoverIcon = nil

local function SetWindowHover(state) isHoveringWindow = state end
local function SetResizeHoverIcon(iconId) hoverIcon = iconId end
local function LockCursorIcon(iconId) lockedIcon = iconId end

local function applyWindow3DBorder(parentFrame)
	local border = Instance.new("Frame", parentFrame)
	border.Name = "Border"
	border.Size = UDim2.new(1, 0, 1, 0)
	border.Position = UDim2.new(0, 0, 0, 0)
	border.BackgroundTransparency = 1
	border.BorderSizePixel = 0
	border.ZIndex = parentFrame.ZIndex

	local function addL(sz, ps, col, name)
		local l = Instance.new("Frame", border)
		l.BorderSizePixel = 0; l.Size = sz; l.Position = ps; l.BackgroundColor3 = col
		l.Name = name or "Line"; l.ZIndex = border.ZIndex
	end

	addL(UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, -1), Color3.fromRGB(107, 107, 107))
	addL(UDim2.new(0, 1, 1, 0), UDim2.new(1, -1, 0, 0), Color3.fromRGB(107, 107, 107))
	addL(UDim2.new(1, -2, 0, 1), UDim2.new(0, 1, 1, -2), Color3.fromRGB(167, 167, 167))
	addL(UDim2.new(0, 1, 1, -2), UDim2.new(1, -2, 0, 1), Color3.fromRGB(167, 167, 167))
	addL(UDim2.new(1, -1, 0, 1), UDim2.new(0, 0, 0, 0), Color3.fromRGB(228, 228, 228))
	addL(UDim2.new(0, 1, 1, -1), UDim2.new(0, 0, 0, 0), Color3.fromRGB(228, 228, 228))

	addL(UDim2.new(0, 3, 1, -3), UDim2.new(0, 1, 0, 1), Color3.fromRGB(255, 255, 255), "White")
	addL(UDim2.new(0, 2, 1, -3), UDim2.new(1, -4, 0, 1), Color3.fromRGB(255, 255, 255), "White")
	addL(UDim2.new(1, -3, 0, 2), UDim2.new(0, 1, 1, -4), Color3.fromRGB(255, 255, 255), "White")
	addL(UDim2.new(1, -3, 0, 3), UDim2.new(0, 1, 0, 1), Color3.fromRGB(255, 255, 255), "White")

	return border
end

local function applyTaskbar3DBorder(parentFrame)
	local border = Instance.new("Frame", parentFrame)
	border.Name = "Border"
	border.BorderSizePixel = 0
	border.BackgroundTransparency = 1
	border.AnchorPoint = Vector2.new(0.5, 0.5)
	border.Size = UDim2.new(1, 5, 1, 5)
	border.Position = UDim2.new(0.5, 0, 0.5, 0)
	border.ZIndex = parentFrame.ZIndex

	local function addL(sz, ps, col, name)
		local l = Instance.new("Frame", border)
		l.BorderSizePixel = 0; l.Size = sz; l.Position = ps; l.BackgroundColor3 = col
		l.Name = name or "Line"; l.ZIndex = border.ZIndex
	end

	addL(UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, -1), Color3.fromRGB(107, 107, 107))
	addL(UDim2.new(0, 1, 1, 0), UDim2.new(1, -1, 0, 0), Color3.fromRGB(107, 107, 107))
	addL(UDim2.new(1, -2, 0, 1), UDim2.new(0, 1, 1, -2), Color3.fromRGB(167, 167, 167))
	addL(UDim2.new(0, 1, 1, -2), UDim2.new(1, -2, 0, 1), Color3.fromRGB(167, 167, 167))
	addL(UDim2.new(1, -1, 0, 1), UDim2.new(0, 0, 0, 0), Color3.fromRGB(228, 228, 228))
	addL(UDim2.new(0, 1, 1, -1), UDim2.new(0, 0, 0, 0), Color3.fromRGB(228, 228, 228))

	addL(UDim2.new(0, 3, 1, -3), UDim2.new(0, 1, 0, 1), Color3.fromRGB(255, 255, 255), "White")
	addL(UDim2.new(0, 2, 1, -3), UDim2.new(1, -4, 0, 1), Color3.fromRGB(255, 255, 255), "White")
	addL(UDim2.new(1, -3, 0, 2), UDim2.new(0, 1, 1, -4), Color3.fromRGB(255, 255, 255), "White")
	addL(UDim2.new(1, -3, 0, 3), UDim2.new(0, 1, 0, 1), Color3.fromRGB(255, 255, 255), "White")

	return border
end

local function createPixelArrow(parent, color, rotation)
	local container = Instance.new("Frame", parent)
	container.Name = "SymmetricArrow"
	container.Size = UDim2.new(0, 6, 0, 11)
	container.Position = UDim2.new(0.5, -3, 0.5, -5)
	container.Rotation = rotation or 0
	container.BackgroundTransparency = 1

	local bars = {
		{w = 1, h = 11, x = 0, y = -5},
		{w = 1, h = 9,  x = 1, y = -4},
		{w = 1, h = 7,  x = 2, y = -3},
		{w = 1, h = 5,  x = 3, y = -2},
		{w = 1, h = 3,  x = 4, y = -1},
		{w = 1, h = 1,  x = 5, y = 0},
	}

	for idx, b in ipairs(bars) do
		local bar = Instance.new("Frame", container)
		bar.Name = "Bar_" .. idx
		bar.BorderSizePixel = 0
		bar.BackgroundColor3 = color or Color3.fromRGB(0, 0, 0)
		bar.Size = UDim2.new(0, b.w, 0, b.h)
		bar.Position = UDim2.new(0, b.x, 0.5, b.y)
	end
	return container
end

local function createSunkenButton(parent, size, pos, name, arrowRotation)
	local btn = Instance.new("ImageButton", parent)
	btn.Name = name
	btn.Size = size
	btn.Position = pos or UDim2.new(0, 0, 0, 0)
	btn.BorderSizePixel = 0
	btn.AutoButtonColor = false
	btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	btn.ZIndex = parent.ZIndex + 1

	local effect = Instance.new("Frame", btn)
	effect.Name = "3dEffect"
	effect.Size = UDim2.new(1, 0, 1, 0)
	effect.BackgroundTransparency = 1
	effect.ZIndex = btn.ZIndex

	local fRight = Instance.new("Frame", effect)
	fRight.BorderSizePixel = 0; fRight.BackgroundColor3 = Color3.fromRGB(119, 119, 119)
	fRight.AnchorPoint = Vector2.new(1, 0); fRight.Size = UDim2.new(0, 2, 1, 0); fRight.Position = UDim2.new(1, 0, 0, 0)
	fRight.ZIndex = effect.ZIndex

	local fBottom = Instance.new("Frame", effect)
	fBottom.BorderSizePixel = 0; fBottom.BackgroundColor3 = Color3.fromRGB(119, 119, 119)
	fBottom.AnchorPoint = Vector2.new(0, 1); fBottom.Size = UDim2.new(1, 0, 0, 2); fBottom.Position = UDim2.new(0, 0, 1, 0)
	fBottom.ZIndex = effect.ZIndex

	if arrowRotation ~= nil then
		createPixelArrow(btn, Color3.fromRGB(0, 0, 0), arrowRotation)
	end

	local isDown = false
	local function setSunken(down)
		if down then
			fRight.AnchorPoint = Vector2.new(0, 0); fRight.Position = UDim2.new(0, 0, 0, 0)
			fBottom.AnchorPoint = Vector2.new(0, 0); fBottom.Position = UDim2.new(0, 0, 0, 0)
			btn.BackgroundColor3 = Color3.fromRGB(225, 225, 225)
		else
			fRight.AnchorPoint = Vector2.new(1, 0); fRight.Position = UDim2.new(1, 0, 0, 0)
			fBottom.AnchorPoint = Vector2.new(0, 1); fBottom.Position = UDim2.new(0, 0, 1, 0)
			btn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		end
	end

	btn.MouseButton1Down:Connect(function() isDown = true; setSunken(true) end)
	UserInputService.InputEnded:Connect(function(inp)
		if isDown and (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch) then
			isDown = false; setSunken(false)
		end
	end)

	return btn
end

--------------------------------------------------------------------------------
-- TASKBAR & CURSOR STATE
--------------------------------------------------------------------------------
local ClassicTaskbar, UnHideTaskbar, TaskbarAppHolder, TaskbarMain, ControlApp, TaskbarMainLayout
local CursorGui, CursorImg
local isTaskbarVisible = false
local isTaskbarAnimating = false

local function animateTaskbar(show)
	if isTaskbarAnimating or isTaskbarVisible == show or not ClassicTaskbar then return end
	isTaskbarAnimating = true

	local startY = show and 2 or -27
	local targetY = show and -27 or 2
	local TOTAL_FRAMES = 5
	local FRAME_DELAY = 1 / 24
	local stepDelta = (targetY - startY) / TOTAL_FRAMES

	if show and UnHideTaskbar then UnHideTaskbar.Visible = false end

	task.spawn(function()
		for i = 1, TOTAL_FRAMES do
			local curY = math.floor(startY + stepDelta * i)
			ClassicTaskbar.Position = UDim2.new(0.5, 0, 1, curY)
			task.wait(FRAME_DELAY)
		end
		ClassicTaskbar.Position = UDim2.new(0.5, 0, 1, targetY)
		isTaskbarVisible = show
		if not show and UnHideTaskbar then UnHideTaskbar.Visible = true end
		isTaskbarAnimating = false
	end)
end

function ClassicModule.UpdateTaskbar(Core)
	if not ClassicTaskbar then return end
	local activeWins = Core.ActiveWindows

	if #activeWins == 0 then
		ClassicTaskbar.Visible = false
		if UnHideTaskbar then UnHideTaskbar.Visible = false end
		return
	end

	if isTaskbarVisible then
		ClassicTaskbar.Visible = true
		if UnHideTaskbar then UnHideTaskbar.Visible = false end
	else
		ClassicTaskbar.Visible = true
		if UnHideTaskbar then UnHideTaskbar.Visible = true end
	end

	for _, child in ipairs(TaskbarAppHolder:GetChildren()) do
		if not child:IsA("UIListLayout") and not child:IsA("UIPadding") then
			child:Destroy()
		end
	end

	for _, win in ipairs(activeWins) do
		local isFocused = (Core.FocusedWindow == win) and not win.IsMinimized()

		local appBtn = Instance.new("ImageButton", TaskbarAppHolder)
		appBtn.Name = isFocused and "Appselect_Template" or "Appunselect_Template"
		appBtn.BorderSizePixel = 0
		appBtn.AutoButtonColor = false
		appBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		appBtn.AutomaticSize = Enum.AutomaticSize.X
		appBtn.Size = UDim2.new(0, 50, 1, 0)
		appBtn.ZIndex = 8004

		local effect = Instance.new("Frame", appBtn)
		effect.Name = "3dEffect"
		effect.BorderSizePixel = 0
		effect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		effect.BackgroundTransparency = 1
		effect.AutomaticSize = Enum.AutomaticSize.X
		effect.Size = UDim2.new(0, 50, 1, 0)
		effect.ZIndex = 8005

		local lineV = Instance.new("Frame", effect)
		lineV.BorderSizePixel = 0
		lineV.BackgroundColor3 = Color3.fromRGB(119, 119, 119)
		lineV.ZIndex = 8006

		local lineH = Instance.new("Frame", effect)
		lineH.BorderSizePixel = 0
		lineH.BackgroundColor3 = Color3.fromRGB(119, 119, 119)
		lineH.Name = "Frame1"
		lineH.ZIndex = 8006

		local appContainer = Instance.new("Frame", effect)
		appContainer.Name = "App"
		appContainer.BorderSizePixel = 0
		appContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		appContainer.BackgroundTransparency = 1
		appContainer.ZIndex = 8006

		local appLayout = Instance.new("UIListLayout", appContainer)
		appLayout.Padding = UDim.new(0, 2)
		appLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		appLayout.SortOrder = Enum.SortOrder.LayoutOrder
		appLayout.FillDirection = Enum.FillDirection.Horizontal

		local appPadding = Instance.new("UIPadding", appContainer)
		appPadding.PaddingRight = UDim.new(0, 5)
		appPadding.PaddingLeft = UDim.new(0, 5)

		local appStroke = Instance.new("UIStroke", appContainer)
		appStroke.Color = Color3.fromRGB(203, 203, 203)

		local icon = Instance.new("ImageLabel", appContainer)
		icon.Name = "Iconapp"
		icon.BorderSizePixel = 0
		icon.BackgroundTransparency = 1
		icon.Size = UDim2.new(0, 18, 0, 18)
		icon.Image = win.GetIcon and win.GetIcon() or "rbxasset://textures/ui/GuiImagePlaceholder.png"
		icon.ZIndex = 8007

		local title = Instance.new("TextLabel", appContainer)
		title.Name = "Title"
		title.BorderSizePixel = 0
		title.BackgroundTransparency = 1
		title.Font = Enum.Font.SourceSans
		title.TextSize = 14
		title.TextColor3 = Color3.fromRGB(0, 0, 0)
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Text = win.GetTitle and win.GetTitle() or "Window"
		title.LayoutOrder = 1
		title.Size = UDim2.new(0, 5, 1, 0)
		title.AutomaticSize = Enum.AutomaticSize.X
		title.ZIndex = 8007

		if isFocused then
			lineV.AnchorPoint = Vector2.new(0, 0); lineV.Position = UDim2.new(0, 0, 0, 0); lineV.Size = UDim2.new(0, 2, 1, 0)
			lineH.AnchorPoint = Vector2.new(0, 0); lineH.Position = UDim2.new(0, 0, 0, 0); lineH.Size = UDim2.new(1, 0, 0, 2)
			appContainer.Size = UDim2.new(1, 0, 1, 0)
		else
			lineV.AnchorPoint = Vector2.new(1, 0); lineV.Position = UDim2.new(1, 0, 0, 0); lineV.Size = UDim2.new(0, 2, 1, 0)
			lineH.AnchorPoint = Vector2.new(0, 1); lineH.Position = UDim2.new(0, 0, 1, 0); lineH.Size = UDim2.new(1, 0, 0, 2)
			appContainer.Size = UDim2.new(1, -2, 1, -2)
		end

		appBtn.MouseButton1Click:Connect(function()
			if win.IsMinimized() then
				win.Restore()
				win.Focus()
			elseif Core.FocusedWindow == win then
				win.Minimize()
			else
				win.Focus()
			end
		end)

		appBtn.MouseButton2Click:Connect(function()
			local mousePos = UserInputService:GetMouseLocation()
			local items = {}
			if win.TaskbarContextMenu then
				for _, it in ipairs(win.TaskbarContextMenu) do table.insert(items, it) end
				table.insert(items, {Type = "Separator"})
			end
			table.insert(items, {
				Type = "Button",
				Text = "Close",
				Callback = function() win.Close() end
			})
			Core.RenderContextMenu(mousePos, items, 1)
		end)
	end

	task.defer(function()
		local contentW = TaskbarMainLayout.AbsoluteContentSize.X
		local containerW = TaskbarMain.AbsoluteSize.X
		if contentW > containerW then
			ControlApp.Visible = true
			TaskbarMain.Size = UDim2.new(1, -100, 1, 0)
		else
			ControlApp.Visible = false
			TaskbarMain.Size = UDim2.new(1, -45, 1, 0)
		end
	end)
end

function ClassicModule.Init(Core)
	-- Tạo Fake Cursor
	if not CursorGui then
		CursorGui = Instance.new("ScreenGui")
		CursorGui.Name = "FakeCursorGui"
		CursorGui.DisplayOrder = 2147483647
		CursorGui.ResetOnSpawn = false
		CursorGui.Parent = Core.RootParent

		CursorImg = Instance.new("ImageLabel", CursorGui)
		CursorImg.Size = UDim2.new(0, 64, 0, 64)
		CursorImg.AnchorPoint = Vector2.new(0.5, 0.5)
		CursorImg.BackgroundTransparency = 1
		CursorImg.Image = ICON_NORMAL
		CursorImg.Visible = false
		CursorImg.ZIndex = 999999

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				lockedIcon = nil
			end
		end)

		RunService.RenderStepped:Connect(function()
			if Core.CurrentModuleType == "Classic" then
				local activeImage = lockedIcon or hoverIcon or (isHoveringWindow and ICON_NORMAL or nil)
				if activeImage then
					UserInputService.MouseIconEnabled = false
					CursorImg.Visible = true
					CursorImg.Image = activeImage
					local mousePos = UserInputService:GetMouseLocation()
					local inset = GuiService:GetGuiInset()
					CursorImg.Position = UDim2.new(0, mousePos.X, 0, mousePos.Y - inset.Y)
				else
					UserInputService.MouseIconEnabled = true
					CursorImg.Visible = false
				end
			else
				if CursorImg and CursorImg.Visible then
					CursorImg.Visible = false
					UserInputService.MouseIconEnabled = true
				end
			end
		end)
	end

	-- Tạo Taskbar
	if not ClassicTaskbar then
		ClassicTaskbar = Instance.new("ImageButton", Core.NonUserGui)
		ClassicTaskbar.Name = "Taskbar"
		ClassicTaskbar.BorderSizePixel = 0
		ClassicTaskbar.AutoButtonColor = false
		ClassicTaskbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ClassicTaskbar.AnchorPoint = Vector2.new(0.5, 0)
		ClassicTaskbar.Size = UDim2.new(1, -20, 0, 25)
		ClassicTaskbar.Position = UDim2.new(0.5, 0, 1, 2)
		ClassicTaskbar.Visible = false
		ClassicTaskbar.ZIndex = 8000
		applyTaskbar3DBorder(ClassicTaskbar)

		TaskbarMain = Instance.new("Frame", ClassicTaskbar)
		TaskbarMain.Name = "main"
		TaskbarMain.BorderSizePixel = 0
		TaskbarMain.BackgroundTransparency = 1
		TaskbarMain.Size = UDim2.new(1, -45, 1, 0)
		TaskbarMain.Position = UDim2.new(0, 4, 0, 0)
		TaskbarMain.ClipsDescendants = true
		TaskbarMain.ZIndex = 8001

		TaskbarAppHolder = Instance.new("Frame", TaskbarMain)
		TaskbarAppHolder.Name = "AppHolder"
		TaskbarAppHolder.BackgroundTransparency = 1
		TaskbarAppHolder.Size = UDim2.new(0, 0, 1, 0)
		TaskbarAppHolder.Position = UDim2.new(0, 0, 0, 0)
		TaskbarAppHolder.AutomaticSize = Enum.AutomaticSize.X
		TaskbarAppHolder.ZIndex = 8001

		TaskbarMainLayout = Instance.new("UIListLayout", TaskbarAppHolder)
		TaskbarMainLayout.Padding = UDim.new(0, 5)
		TaskbarMainLayout.SortOrder = Enum.SortOrder.LayoutOrder
		TaskbarMainLayout.FillDirection = Enum.FillDirection.Horizontal
		TaskbarMainLayout.VerticalAlignment = Enum.VerticalAlignment.Center

		local TaskbarControl = Instance.new("Frame", ClassicTaskbar)
		TaskbarControl.Name = "Control"
		TaskbarControl.BorderSizePixel = 0
		TaskbarControl.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TaskbarControl.AnchorPoint = Vector2.new(1, 0)
		TaskbarControl.Size = UDim2.new(0, 100, 1, 0)
		TaskbarControl.Position = UDim2.new(1, 0, 0, 0)
		TaskbarControl.ZIndex = 8002

		ControlApp = Instance.new("Frame", TaskbarControl)
		ControlApp.Name = "ControlApp"
		ControlApp.BorderSizePixel = 0
		ControlApp.BackgroundTransparency = 1
		ControlApp.Size = UDim2.new(0, 50, 1, 0)
		ControlApp.Visible = false
		ControlApp.ZIndex = 8003

		local ControlAppLayout = Instance.new("UIListLayout", ControlApp)
		ControlAppLayout.Padding = UDim.new(0, 2)
		ControlAppLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ControlAppLayout.FillDirection = Enum.FillDirection.Horizontal

		local BtnScrollLeft = createSunkenButton(ControlApp, UDim2.new(0, 25, 1, 0), nil, "Left", 180)
		local BtnScrollRight = createSunkenButton(ControlApp, UDim2.new(0, 25, 1, 0), nil, "Right", 0)

		local TaskbarLine = Instance.new("Frame", TaskbarControl)
		TaskbarLine.Name = "Line"
		TaskbarLine.BorderSizePixel = 0
		TaskbarLine.BackgroundColor3 = Color3.fromRGB(166, 166, 166)
		TaskbarLine.Size = UDim2.new(0, 1, 1, 0)
		TaskbarLine.Position = UDim2.new(0, -2, 0, 0)
		TaskbarLine.ZIndex = 8003

		local HideTaskBarHolder = Instance.new("Frame", TaskbarControl)
		HideTaskBarHolder.Name = "Hide TaskBar"
		HideTaskBarHolder.BorderSizePixel = 0
		HideTaskBarHolder.BackgroundTransparency = 1
		HideTaskBarHolder.AnchorPoint = Vector2.new(1, 0)
		HideTaskBarHolder.Size = UDim2.new(0, 40, 1, 0)
		HideTaskBarHolder.Position = UDim2.new(1, 0, 0, 0)
		HideTaskBarHolder.ZIndex = 8003

		local BtnHideTaskbar = createSunkenButton(HideTaskBarHolder, UDim2.new(1, 0, 1, 0), nil, "Left", 90)

		UnHideTaskbar = Instance.new("ImageButton", ClassicTaskbar)
		UnHideTaskbar.Name = "UnHideTaskbar"
		UnHideTaskbar.BorderSizePixel = 0
		UnHideTaskbar.AutoButtonColor = false
		UnHideTaskbar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		UnHideTaskbar.AnchorPoint = Vector2.new(1, 1)
		UnHideTaskbar.Size = UDim2.new(0, 50, 0, 20)
		UnHideTaskbar.Position = UDim2.new(1, 0, 0, -5)
		UnHideTaskbar.Visible = true
		UnHideTaskbar.ZIndex = 8010
		applyTaskbar3DBorder(UnHideTaskbar)
		createPixelArrow(UnHideTaskbar, Color3.fromRGB(0, 0, 0), -90)

		BtnHideTaskbar.MouseButton1Click:Connect(function() animateTaskbar(false) end)
		UnHideTaskbar.MouseButton1Click:Connect(function() animateTaskbar(true) end)

		local scrollOffset = 0
		BtnScrollLeft.MouseButton1Click:Connect(function()
			scrollOffset = math.min(0, scrollOffset + 60)
			TaskbarAppHolder.Position = UDim2.new(0, scrollOffset, 0, 0)
		end)
		BtnScrollRight.MouseButton1Click:Connect(function()
			local maxScroll = math.min(0, TaskbarMain.AbsoluteSize.X - TaskbarAppHolder.AbsoluteSize.X - 10)
			scrollOffset = math.max(maxScroll, scrollOffset - 60)
			TaskbarAppHolder.Position = UDim2.new(0, scrollOffset, 0, 0)
		end)
	end

	ClassicModule.UpdateTaskbar(Core)
end

function ClassicModule.Cleanup(Core)
	if ClassicTaskbar then
		ClassicTaskbar.Visible = false
		if UnHideTaskbar then UnHideTaskbar.Visible = false end
	end
	if CursorImg then CursorImg.Visible = false end
	UserInputService.MouseIconEnabled = true
end

function ClassicModule.CreateWindow(Core, config)
	local windowTitle = config.Title or "Window"
	local windowIcon = config.Icon or "rbxasset://textures/ui/GuiImagePlaceholder.png"
	local targetParent = config.Parent or Core.NonUserGui

	local defaultSize = config.Size or UDim2.new(0, 260, 0, 340)
	local defaultPos = config.Position or UDim2.new(0, 60, 0, 60)
	local minSize = config.MinSize or Vector2.new(160, 110)
	local maxSize = config.MaxSize or Vector2.new(1920, 1080)

	local isMinimizedState = false

	local FloatingWindow = Instance.new("Frame", targetParent)
	FloatingWindow.Name = "ClassicWindow_" .. windowTitle
	FloatingWindow.Size = defaultSize
	FloatingWindow.Position = defaultPos
	FloatingWindow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	FloatingWindow.BackgroundTransparency = 1
	FloatingWindow.BorderSizePixel = 0
	FloatingWindow.ClipsDescendants = true
	FloatingWindow.Active = true
	FloatingWindow.ZIndex = Core.GetNextZIndex()

	FloatingWindow.MouseEnter:Connect(function() SetWindowHover(true) end)
	FloatingWindow.MouseLeave:Connect(function() SetWindowHover(false) end)

	applyWindow3DBorder(FloatingWindow)

	-- TitleBar
	local TitleBar = Instance.new("Frame", FloatingWindow)
	TitleBar.Name = "TitleBar"
	TitleBar.Size = UDim2.new(1, -8, 0, 17)
	TitleBar.Position = UDim2.new(0, 4, 0, 4)
	TitleBar.BackgroundColor3 = Color3.fromRGB(51, 151, 251)
	TitleBar.BorderSizePixel = 0
	TitleBar.ZIndex = 5

	local TitleText = Instance.new("TextLabel", TitleBar)
	TitleText.Name = "Title"
	TitleText.Size = UDim2.new(1, -20, 1, -2)
	TitleText.Position = UDim2.new(0, 4, 0, 0)
	TitleText.BackgroundTransparency = 1
	TitleText.Font = Enum.Font.SourceSans
	TitleText.TextSize = 14
	TitleText.TextColor3 = Color3.fromRGB(0, 0, 0)
	TitleText.TextXAlignment = Enum.TextXAlignment.Left
	TitleText.Text = windowTitle
	TitleText.ZIndex = 6

	local XButton = Instance.new("ImageButton", TitleBar)
	XButton.Name = "X"
	XButton.Size = UDim2.new(0, 11, 0, 11)
	XButton.Position = UDim2.new(1, -15, 0, 3)
	XButton.BackgroundTransparency = 1
	XButton.Image = ASSET_X_NORMAL
	XButton.ZIndex = 7

	local Handle = Instance.new("TextButton", TitleBar)
	Handle.Name = "Handle"
	Handle.Size = UDim2.new(1, 0, 1, 0)
	Handle.BackgroundTransparency = 1
	Handle.Text = ""
	Handle.ZIndex = 6

	local Padding = Instance.new("Frame", FloatingWindow)
	Padding.Name = "Padding"
	Padding.Size = UDim2.new(1, -8, 0, 1)
	Padding.Position = UDim2.new(0, 4, 0, 21)
	Padding.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Padding.BorderSizePixel = 0

	local Container = Instance.new("TextButton", FloatingWindow)
	Container.Name = "Container"
	Container.Position = UDim2.new(0, 4, 0, 22)
	Container.Size = UDim2.new(0, math.max(0, FloatingWindow.AbsoluteSize.X - 8), 0, math.max(0, FloatingWindow.AbsoluteSize.Y - 26))
	Container.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Container.BackgroundTransparency = 0
	Container.BorderSizePixel = 0
	Container.Text = ""
	Container.AutoButtonColor = false
	Container.ClipsDescendants = true
	Container.ZIndex = 2

	local UPDATE_INTERVAL = 1 / 22
	local accumulatedTime = 0
	local renderConn
	renderConn = RunService.RenderStepped:Connect(function(dt)
		if not FloatingWindow or not FloatingWindow.Parent then
			renderConn:Disconnect()
			return
		end
		accumulatedTime = accumulatedTime + dt
		if accumulatedTime >= UPDATE_INTERVAL and not isMinimizedState then
			accumulatedTime = accumulatedTime % UPDATE_INTERVAL
			local targetW = math.max(0, FloatingWindow.AbsoluteSize.X - 8)
			local targetH = math.max(0, FloatingWindow.AbsoluteSize.Y - 26)
			Container.Size = UDim2.new(0, targetW, 0, targetH)
		end
	end)

	local ResizeHandles = Instance.new("Frame", FloatingWindow)
	ResizeHandles.Name = "ResizeHandles"
	ResizeHandles.Size = UDim2.new(1, 0, 1, 0)
	ResizeHandles.BackgroundTransparency = 1
	ResizeHandles.BorderSizePixel = 0
	ResizeHandles.ZIndex = 4

	local function makeHandle(name, size, pos)
		local h = Instance.new("TextButton", ResizeHandles)
		h.Name = name; h.Size = size; h.Position = pos
		h.BackgroundTransparency = 1; h.Text = ""; h.ZIndex = 4; h.BorderSizePixel = 0
		return h
	end

	makeHandle("Top", UDim2.new(1, -42, 0, 4), UDim2.new(0, 21, 0, 0))
	makeHandle("Bottom", UDim2.new(1, -42, 0, 4), UDim2.new(0, 21, 1, -4))
	makeHandle("Left", UDim2.new(0, 4, 1, -42), UDim2.new(0, 0, 0, 21))
	makeHandle("Right", UDim2.new(0, 4, 1, -42), UDim2.new(1, -4, 0, 21))
	makeHandle("TopLeftVertical", UDim2.new(0, 4, 0, 21), UDim2.new(0, 0, 0, 0))
	makeHandle("TopLeftHorizontal", UDim2.new(0, 21, 0, 4), UDim2.new(0, 0, 0, 0))
	makeHandle("TopRightVertical", UDim2.new(0, 4, 0, 21), UDim2.new(1, -4, 0, 0))
	makeHandle("TopRightHorizontal", UDim2.new(0, 21, 0, 4), UDim2.new(1, -21, 0, 0))
	makeHandle("BottomLeftVertical", UDim2.new(0, 4, 0, 21), UDim2.new(0, 0, 1, -21))
	makeHandle("BottomLeftHorizontal", UDim2.new(0, 21, 0, 4), UDim2.new(0, 0, 1, -4))
	makeHandle("BottomRightVertical", UDim2.new(0, 4, 0, 21), UDim2.new(1, -4, 1, -21))
	makeHandle("BottomRightHorizontal", UDim2.new(0, 21, 0, 4), UDim2.new(1, -21, 1, -4))

	local windowRecord = {}

	local function bringToFront()
		Core.BringToFront(FloatingWindow, windowRecord)
	end

	local function setFocusVisual(isFocused)
		if isFocused then
			TitleBar.BackgroundColor3 = Color3.fromRGB(51, 151, 251)
			TitleText.TextColor3 = Color3.fromRGB(0, 0, 0)
		else
			TitleBar.BackgroundColor3 = Color3.fromRGB(129, 129, 129)
			TitleText.TextColor3 = Color3.fromRGB(196, 196, 196)
		end
	end

	local function setClassicMinimize(minimize)
		isMinimizedState = minimize
		FloatingWindow.Visible = not minimize
		if minimize then
			if Core.FocusedWindow == windowRecord then Core.SetFocus(nil) end
		else
			bringToFront()
		end
		ClassicModule.UpdateTaskbar(Core)
	end

	FloatingWindow.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
			bringToFront()
		end
	end)

	local isDragging = false
	local dragStartMouse = Vector2.zero
	local dragStartPos = UDim2.new()
	local lastTitleClick = 0

	Handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			bringToFront()

			local now = tick()
			if now - lastTitleClick < 0.28 then
				lastTitleClick = 0
				setClassicMinimize(true)
				return
			else
				lastTitleClick = now
			end

			local useOutlineDrag = (config.OutlineDrag ~= nil) and config.OutlineDrag or Core.IsGlobalOutlineDrag()

			LockCursorIcon(ICON_DRAG)
			isDragging = true
			dragStartMouse = UserInputService:GetMouseLocation()
			dragStartPos = FloatingWindow.Position

			if useOutlineDrag then
				Core.DragOutlineFrame.Size = FloatingWindow.Size
				Core.DragOutlineFrame.Position = FloatingWindow.Position
				Core.DragOutlineFrame.Visible = true
			end

			local moveConn, releaseConn
			moveConn = UserInputService.InputChanged:Connect(function(moveInput)
				if isDragging and (moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch) then
					local mouseNow = UserInputService:GetMouseLocation()
					local delta = mouseNow - dragStartMouse
					local targetPos = UDim2.new(
						dragStartPos.X.Scale,
						dragStartPos.X.Offset + delta.X,
						dragStartPos.Y.Scale,
						dragStartPos.Y.Offset + delta.Y
					)
					if useOutlineDrag then Core.DragOutlineFrame.Position = targetPos
					else FloatingWindow.Position = targetPos end
				end
			end)

			releaseConn = UserInputService.InputEnded:Connect(function(endInput)
				if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
					isDragging = false
					moveConn:Disconnect(); releaseConn:Disconnect()
					if useOutlineDrag then
						Core.DragOutlineFrame.Visible = false
						FloatingWindow.Position = Core.DragOutlineFrame.Position
					end
				end
			end)
		end
	end)

	local RESIZE_ICONS = {
		Top = "rbxassetid://109778282820345", Bottom = "rbxassetid://109778282820345",
		Left = "rbxassetid://77008116399869", Right = "rbxassetid://77008116399869",
		TopLeftVertical = "rbxassetid://109913002781563", TopLeftHorizontal = "rbxassetid://109913002781563",
		BottomRightVertical = "rbxassetid://109913002781563", BottomRightHorizontal = "rbxassetid://109913002781563",
		TopRightVertical = "rbxassetid://82381353175242", TopRightHorizontal = "rbxassetid://82381353175242",
		BottomLeftVertical = "rbxassetid://82381353175242", BottomLeftHorizontal = "rbxassetid://82381353175242"
	}

	for handleName, iconId in pairs(RESIZE_ICONS) do
		local handle = ResizeHandles:FindFirstChild(handleName)
		if handle then
			handle.MouseEnter:Connect(function() if not isMinimizedState then SetResizeHoverIcon(iconId) end end)
			handle.MouseLeave:Connect(function() SetResizeHoverIcon(nil) end)
			handle.InputBegan:Connect(function(input)
				if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not isMinimizedState then
					LockCursorIcon(iconId)
				end
			end)
		end
	end

	local function bindHandle(handle, dirX, dirY)
		if not handle then return end
		handle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and not isMinimizedState then
				bringToFront()
				local startMouse = UserInputService:GetMouseLocation()
				local startSize = FloatingWindow.AbsoluteSize
				local startPos = FloatingWindow.Position

				local moveConn, endConn
				moveConn = UserInputService.InputChanged:Connect(function(moveInput)
					if moveInput.UserInputType == Enum.UserInputType.MouseMovement and not isMinimizedState then
						bringToFront()
						local mouseNow = UserInputService:GetMouseLocation()
						local delta = mouseNow - startMouse
						local newW = startSize.X; local newH = startSize.Y
						local newPosX = startPos.X.Offset; local newPosY = startPos.Y.Offset

						if dirX == 1 then newW = math.clamp(startSize.X + delta.X, minSize.X, maxSize.X)
						elseif dirX == -1 then newW = math.clamp(startSize.X - delta.X, minSize.X, maxSize.X); newPosX = startPos.X.Offset + (startSize.X - newW) end

						if dirY == 1 then newH = math.clamp(startSize.Y + delta.Y, minSize.Y, maxSize.Y)
						elseif dirY == -1 then newH = math.clamp(startSize.Y - delta.Y, minSize.Y, maxSize.Y); newPosY = startPos.Y.Offset + (startSize.Y - newH) end

						FloatingWindow.Size = UDim2.new(0, newW, 0, newH)
						FloatingWindow.Position = UDim2.new(startPos.X.Scale, newPosX, startPos.Y.Scale, newPosY)
					end
				end)

				endConn = UserInputService.InputEnded:Connect(function(endInput)
					if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
						moveConn:Disconnect(); endConn:Disconnect()
					end
				end)
			end
		end)
	end

	bindHandle(ResizeHandles:FindFirstChild("Top"), 0, -1)
	bindHandle(ResizeHandles:FindFirstChild("Bottom"), 0, 1)
	bindHandle(ResizeHandles:FindFirstChild("Left"), -1, 0)
	bindHandle(ResizeHandles:FindFirstChild("Right"), 1, 0)
	bindHandle(ResizeHandles:FindFirstChild("TopLeftVertical"), -1, -1)
	bindHandle(ResizeHandles:FindFirstChild("TopLeftHorizontal"), -1, -1)
	bindHandle(ResizeHandles:FindFirstChild("TopRightVertical"), 1, -1)
	bindHandle(ResizeHandles:FindFirstChild("TopRightHorizontal"), 1, -1)
	bindHandle(ResizeHandles:FindFirstChild("BottomLeftVertical"), -1, 1)
	bindHandle(ResizeHandles:FindFirstChild("BottomLeftHorizontal"), -1, 1)
	bindHandle(ResizeHandles:FindFirstChild("BottomRightVertical"), 1, 1)
	bindHandle(ResizeHandles:FindFirstChild("BottomRightHorizontal"), 1, 1)

	local posNormal = UDim2.new(1, -15, 0, 3)
	local posPressed = UDim2.new(1, -14, 0, 4)

	local function SetXPressed(isPressed)
		if isPressed then XButton.Image = ASSET_X_PRESSED; XButton.Position = posPressed
		else XButton.Image = ASSET_X_NORMAL; XButton.Position = posNormal end
	end

	local function destroyClassicWindow()
		Core.UnregisterActiveWindow(windowRecord)
		ClassicModule.UpdateTaskbar(Core)
		FloatingWindow:Destroy()
	end

	XButton.MouseButton1Down:Connect(function()
		local isHovered = true; local isHolding = true
		SetXPressed(true)
		local enterConn, leaveConn, releaseConn
		enterConn = XButton.MouseEnter:Connect(function() if isHolding then isHovered = true; SetXPressed(true) end end)
		leaveConn = XButton.MouseLeave:Connect(function() if isHolding then isHovered = false; SetXPressed(false) end end)
		releaseConn = UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				isHolding = false; SetXPressed(false)
				if enterConn then enterConn:Disconnect() end
				if leaveConn then leaveConn:Disconnect() end
				if releaseConn then releaseConn:Disconnect() end
				if isHovered then destroyClassicWindow() end
			end
		end)
	end)

	windowRecord.Frame = FloatingWindow
	windowRecord.TargetParent = targetParent
	windowRecord.SetFocusVisual = setFocusVisual
	windowRecord.GetTitle = function() return TitleText.Text end
	windowRecord.GetIcon = function() return windowIcon end
	windowRecord.Focus = function() bringToFront() end
	windowRecord.Close = function() destroyClassicWindow() end
	windowRecord.Minimize = function() setClassicMinimize(true) end
	windowRecord.Restore = function() setClassicMinimize(false) end
	windowRecord.IsMinimized = function() return isMinimizedState end
	windowRecord.TaskbarContextMenu = config.TaskbarContextMenu

	local WindowAPI = {}
	function WindowAPI:GetFrame() return FloatingWindow end
	function WindowAPI:GetContainer() return Container end
	function WindowAPI:GetNonUser() return Core.NonUserGui end
	function WindowAPI:GetCustomOpenUI() return Core.CustomOpenGui end
	function WindowAPI:Focus() bringToFront() end
	function WindowAPI:SetTitle(text) TitleText.Text = tostring(text); ClassicModule.UpdateTaskbar(Core) end
	function WindowAPI:SetIcon(iconId) windowIcon = iconId; ClassicModule.UpdateTaskbar(Core) end
	function WindowAPI:SetVisible(visible) FloatingWindow.Visible = visible end
	function WindowAPI:Close() destroyClassicWindow() end
	function WindowAPI:Minimize() setClassicMinimize(true) end
	function WindowAPI:Restore() setClassicMinimize(false) end
	function WindowAPI:IsMinimized() return isMinimizedState end
	function WindowAPI:SetPosition(pos) FloatingWindow.Position = pos end
	function WindowAPI:SetSize(size) FloatingWindow.Size = size end
	function WindowAPI:GetPosition() return FloatingWindow.Position end
	function WindowAPI:GetSize() return FloatingWindow.Size end
	function WindowAPI:ShowContextMenu(pos, items) Core.RenderContextMenu(pos, items, 1) end
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
		WindowAPI:BindContextMenu(TitleBar, config.TopBarContextMenu, config.TopBarContextMenuTrigger or "Right")
	end

	windowRecord.API = WindowAPI
	return windowRecord
end

return ClassicModule
