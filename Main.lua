-- File: Main.lua (Core Hub - Modular Theme Architecture)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Library = {
	Version = "3.0.0",
	CurrentTheme = "Dark",
	CurrentModuleType = "Modern",
	IsOutlineDrag = false,
	LoadedModules = {},
	RegisteredWindows = {},
	ActiveWindows = {},
	MinimizedWindows = {},
	FocusedWindow = nil,
	OnThemeChanged = Instance.new("BindableEvent"),
	BaseThemeURL = "https://raw.githubusercontent.com/khngsml0-cmd/WindowLib_Theme/main/Themes/"
}

-- Bản đồ định tuyến SubTheme sang File Module tương ứng
local THEME_ROUTING = {
	["Dark"]      = { File = "Modern.lua",    ModuleType = "Modern",    SubTheme = "Dark" },
	["Light"]     = { File = "Modern.lua",    ModuleType = "Modern",    SubTheme = "Light" },
	["Classic"]   = { File = "Classic.lua",   ModuleType = "Classic",   SubTheme = "Classic" },
	["ClassicV2"] = { File = "ClassicV2.lua", ModuleType = "ClassicV2", SubTheme = "ClassicV2" }
}

-- Khởi tạo Layer ScreenGui cơ sở
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local RootParent = Instance.new("ScreenGui")
RootParent.Name = "WindowLib_Root"
RootParent.DisplayOrder = 9000000
RootParent.ResetOnSpawn = false
RootParent.IgnoreGuiInset = true
RootParent.Parent = PlayerGui

local NonUserGui = Instance.new("ScreenGui")
NonUserGui.Name = "WindowLib_NonUser"
NonUserGui.DisplayOrder = 8000000
NonUserGui.ResetOnSpawn = false
NonUserGui.IgnoreGuiInset = true
NonUserGui.Parent = PlayerGui

local CustomOpenGui = Instance.new("ScreenGui")
CustomOpenGui.Name = "WindowLib_CustomOpenUI"
CustomOpenGui.DisplayOrder = 8500000
CustomOpenGui.ResetOnSpawn = false
CustomOpenGui.IgnoreGuiInset = true
CustomOpenGui.Parent = PlayerGui

Library.RootParent = RootParent
Library.NonUserGui = NonUserGui
Library.CustomOpenGui = CustomOpenGui

-- Khung hiển thị Outline Drag nét đứt toàn cục
local DragOutlineFrame = Instance.new("Frame", NonUserGui)
DragOutlineFrame.Name = "GlobalDragOutline"
DragOutlineFrame.BackgroundTransparency = 1
DragOutlineFrame.BorderSizePixel = 0
DragOutlineFrame.Visible = false
DragOutlineFrame.ZIndex = 99999

local OutlineStroke = Instance.new("UIStroke", DragOutlineFrame)
OutlineStroke.Color = Color3.fromRGB(0, 170, 255)
OutlineStroke.Thickness = 1.5
OutlineStroke.LineJoinMode = Enum.LineJoinMode.Miter
Library.DragOutlineFrame = DragOutlineFrame

-- Khung bóng mờ Aero Snap Ghost
local SnapGhostFrame = Instance.new("Frame", NonUserGui)
SnapGhostFrame.Name = "GlobalSnapGhost"
SnapGhostFrame.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
SnapGhostFrame.BackgroundTransparency = 0.75
SnapGhostFrame.BorderSizePixel = 0
SnapGhostFrame.Visible = false
SnapGhostFrame.ZIndex = 99998
Instance.new("UICorner", SnapGhostFrame).CornerRadius = UDim.new(0, 8)
local SnapGhostStroke = Instance.new("UIStroke", SnapGhostFrame)
SnapGhostStroke.Color = Color3.fromRGB(0, 150, 255)
SnapGhostStroke.Thickness = 2
Library.SnapGhostFrame = SnapGhostFrame

function Library.ShowSnapGhost(pos, size)
	SnapGhostFrame.Position = pos
	SnapGhostFrame.Size = size
	SnapGhostFrame.Visible = true
end

function Library.HideSnapGhost()
	SnapGhostFrame.Visible = false
end

function Library.IsGlobalOutlineDrag()
	return Library.IsOutlineDrag
end

function Library:SetOutlineDrag(state)
	Library.IsOutlineDrag = state
end

local zIndexCounter = 100
function Library.GetNextZIndex()
	zIndexCounter = zIndexCounter + 5
	return zIndexCounter
end

-- Tính toán tọa độ xuất hiện dạng bậc thang (Cascade)
local cascadeOffset = 0
function Library.GetNextCascadePosition(windowSize, targetParent)
	local startX = 60 + (cascadeOffset * 25)
	local startY = 60 + (cascadeOffset * 25)
	cascadeOffset = (cascadeOffset + 1) % 6
	return UDim2.new(0, startX, 0, startY)
end

--------------------------------------------------------------------------------
-- QUẢN LÝ FOCUS, ACTIVE VÀ MINIMIZE WINDOWS
--------------------------------------------------------------------------------
function Library.BringToFront(mainFrame, windowRecord)
	if not mainFrame or not mainFrame.Parent then return end
	local topZ = Library.GetNextZIndex()
	mainFrame.ZIndex = topZ
	for _, child in ipairs(mainFrame:GetDescendants()) do
		if child:IsA("GuiObject") then
			child.ZIndex = topZ + (child.ZIndex % 10)
		end
	end

	for _, win in ipairs(Library.ActiveWindows) do
		if win ~= windowRecord and win.SetFocusVisual then
			win.SetFocusVisual(false)
		end
	end

	Library.FocusedWindow = windowRecord
	if windowRecord and windowRecord.SetFocusVisual then
		windowRecord.SetFocusVisual(true)
	end
end

function Library.SetFocus(windowRecord)
	if windowRecord then
		Library.BringToFront(windowRecord.Frame, windowRecord)
	else
		Library.FocusedWindow = nil
		for _, win in ipairs(Library.ActiveWindows) do
			if win.SetFocusVisual then win.SetFocusVisual(false) end
		end
	end
end

function Library.RegisterActiveWindow(windowRecord)
	if not table.find(Library.ActiveWindows, windowRecord) then
		table.insert(Library.ActiveWindows, windowRecord)
	end
end

function Library.UnregisterActiveWindow(windowRecord)
	local idx = table.find(Library.ActiveWindows, windowRecord)
	if idx then table.remove(Library.ActiveWindows, idx) end
	local minIdx = table.find(Library.MinimizedWindows, windowRecord)
	if minIdx then table.remove(Library.MinimizedWindows, minIdx) end
	if Library.FocusedWindow == windowRecord then
		Library.FocusedWindow = nil
	end
end

function Library.RegisterMinimized(windowRecord)
	if not table.find(Library.MinimizedWindows, windowRecord) then
		table.insert(Library.MinimizedWindows, windowRecord)
	end
end

function Library.UnregisterMinimized(windowRecord)
	local idx = table.find(Library.MinimizedWindows, windowRecord)
	if idx then table.remove(Library.MinimizedWindows, idx) end
end

--------------------------------------------------------------------------------
-- NẠP VÀ CHUYỂN ĐỔI MODULE THEME
--------------------------------------------------------------------------------
function Library.GetModuleForTheme(themeName)
	local route = THEME_ROUTING[themeName] or THEME_ROUTING["Dark"]
	local fileName = route.File

	if Library.LoadedModules[fileName] then
		return Library.LoadedModules[fileName], route
	end

	local url = Library.BaseThemeURL .. fileName
	local success, content = pcall(function()
		return game:HttpGet(url)
	end)

	if not success or not content or content == "" then
		warn("[Library] Không thể tải Theme Module từ: " .. url)
		return nil, route
	end

	local loadFunc, err = loadstring(content)
	if not loadFunc then
		warn("[Library] Lỗi phân tích cú pháp Module (" .. fileName .. "): " .. tostring(err))
		return nil, route
	end

	local themeModule = loadFunc()
	Library.LoadedModules[fileName] = themeModule
	return themeModule, route
end

function Library:GetTheme()
	return Library.CurrentTheme
end

function Library:SetTheme(newThemeName)
	local themeModule, route = Library.GetModuleForTheme(newThemeName)
	if not themeModule then return end

	local oldModuleType = Library.CurrentModuleType
	local newModuleType = route.ModuleType
	local isModuleChanged = (oldModuleType ~= newModuleType)

	-- Dọn dẹp theme cũ nếu chuyển đổi kiểu kiến trúc
	if isModuleChanged and oldModuleType then
		local oldRoute = THEME_ROUTING[Library.CurrentTheme]
		if oldRoute and Library.LoadedModules[oldRoute.File] and Library.LoadedModules[oldRoute.File].Cleanup then
			Library.LoadedModules[oldRoute.File].Cleanup(Library)
		end
	end

	Library.CurrentTheme = newThemeName
	Library.CurrentModuleType = newModuleType

	-- Khởi tạo theme mới nếu cần
	if themeModule.Init then
		themeModule.Init(Library)
	end

	-- Xử lý Hot-swap màu sắc hoặc Auto-Rebuild toàn bộ Window
	for _, reg in ipairs(Library.RegisteredWindows) do
		local oldRecord = reg.CurrentRecord
		local savedPos = oldRecord and oldRecord.Frame and oldRecord.Frame.Position
		local savedSize = oldRecord and oldRecord.Frame and oldRecord.Frame.Size
		local isVisible = oldRecord and oldRecord.Frame and oldRecord.Frame.Visible

		if not isModuleChanged and oldRecord and oldRecord.UpdateTheme and themeModule.Palettes[route.SubTheme] then
			-- Hot-swap mượt mà bằng Tween nếu cùng loại kiến trúc
			oldRecord.UpdateTheme(themeModule.Palettes[route.SubTheme])
		else
			-- Auto-Rebuild sang kiến trúc mới
			if oldRecord and oldRecord.Close then
				oldRecord.Close()
			elseif oldRecord and oldRecord.Frame then
				oldRecord.Frame:Destroy()
			end

			local configCopy = {}
			for k, v in pairs(reg.Config) do configCopy[k] = v end
			if savedPos then configCopy.Position = savedPos end
			if savedSize then configCopy.Size = savedSize end

			local newRecord = themeModule.CreateWindow(Library, configCopy, route.SubTheme)
			reg.CurrentRecord = newRecord
			Library.RegisterActiveWindow(newRecord)

			if isVisible ~= nil then
				newRecord.API:SetVisible(isVisible)
			end

			-- Thực thi Builder Callback dựng lại nội dung bên trong cửa sổ
			if reg.BuilderCallback then
				local container = newRecord.API:GetContainer()
				container:ClearAllChildren()
				reg.BuilderCallback(container, newRecord.API)
			end

			Library.BringToFront(newRecord.Frame, newRecord)
		end
	end

	Library.OnThemeChanged:Fire(newThemeName)
end

--------------------------------------------------------------------------------
-- HỆ THỐNG CONTEXT MENU TOÀN CỤC
--------------------------------------------------------------------------------
local activeContextMenus = {}

function Library.ClearSubmenus(level)
	for i = level, #activeContextMenus do
		if activeContextMenus[i] then
			activeContextMenus[i]:Destroy()
			activeContextMenus[i] = nil
		end
	end
end

function Library.RenderContextMenu(screenPos, items, level)
	level = level or 1
	Library.ClearSubmenus(level)

	local route = THEME_ROUTING[Library.CurrentTheme] or THEME_ROUTING["Dark"]
	local currentModule = Library.LoadedModules[route.File]
	local palette = (currentModule and currentModule.Palettes and currentModule.Palettes[route.SubTheme])
		or {
			ContextMenuBackground = Color3.fromRGB(35, 35, 35),
			ContextMenuStroke = Color3.fromRGB(60, 60, 60),
			ContextItemDefault = Color3.fromRGB(35, 35, 35),
			ContextItemHover = Color3.fromRGB(40, 90, 150),
			ContextItemText = Color3.fromRGB(240, 240, 240),
			ContextItemTextDisabled = Color3.fromRGB(140, 140, 140),
			ContextItemSeparator = Color3.fromRGB(70, 70, 70),
			ContextCheckBoxBg = Color3.fromRGB(25, 25, 25),
			ContextCheckMark = Color3.fromRGB(45, 120, 200),
			ContextArrow = Color3.fromRGB(180, 180, 180)
		}

	local isClassicStyle = (route.ModuleType == "Classic" or route.ModuleType == "ClassicV2")

	local menuFrame = Instance.new("Frame", NonUserGui)
	menuFrame.Name = "ContextMenu_L" .. level
	menuFrame.BackgroundColor3 = palette.ContextMenuBackground
	menuFrame.BorderSizePixel = 0
	menuFrame.Position = UDim2.new(0, screenPos.X, 0, screenPos.Y)
	menuFrame.Size = UDim2.new(0, 190, 0, 0)
	menuFrame.AutomaticSize = Enum.AutomaticSize.Y
	menuFrame.ClipsDescendants = false
	menuFrame.ZIndex = 95000 + (level * 10)

	local menuCorner = Instance.new("UICorner", menuFrame)
	menuCorner.CornerRadius = isClassicStyle and UDim.new(0, 0) or UDim.new(0, 6)

	local menuStroke = Instance.new("UIStroke", menuFrame)
	menuStroke.Color = palette.ContextMenuStroke
	menuStroke.Thickness = 1

	local menuPadding = Instance.new("UIPadding", menuFrame)
	menuPadding.PaddingTop = UDim.new(0, 4); menuPadding.PaddingBottom = UDim.new(0, 4)
	menuPadding.PaddingLeft = UDim.new(0, 4); menuPadding.PaddingRight = UDim.new(0, 4)

	local menuLayout = Instance.new("UIListLayout", menuFrame)
	menuLayout.Padding = UDim.new(0, 2)
	menuLayout.SortOrder = Enum.SortOrder.LayoutOrder

	for _, item in ipairs(items) do
		if item.Type == "Separator" then
			local sep = Instance.new("Frame", menuFrame)
			sep.Name = "Separator"
			sep.BorderSizePixel = 0
			sep.BackgroundColor3 = palette.ContextItemSeparator
			sep.Size = UDim2.new(1, 0, 0, 1)
			sep.ZIndex = menuFrame.ZIndex + 1
		else
			local itemBtn = Instance.new("ImageButton", menuFrame)
			itemBtn.Name = "Item_" .. tostring(item.Text)
			itemBtn.BorderSizePixel = 0
			itemBtn.AutoButtonColor = false
			itemBtn.BackgroundColor3 = palette.ContextItemDefault
			itemBtn.Size = UDim2.new(1, 0, 0, 24)
			itemBtn.ZIndex = menuFrame.ZIndex + 1

			local itemCorner = Instance.new("UICorner", itemBtn)
			itemCorner.CornerRadius = isClassicStyle and UDim.new(0, 0) or UDim.new(0, 4)

			local itemText = Instance.new("TextLabel", itemBtn)
			itemText.BackgroundTransparency = 1
			itemText.Size = UDim2.new(1, -28, 1, 0)
			itemText.Position = UDim2.new(0, 24, 0, 0)
			itemText.TextXAlignment = Enum.TextXAlignment.Left
			itemText.TextSize = 12
			itemText.TextColor3 = item.Disabled and palette.ContextItemTextDisabled or palette.ContextItemText
			itemText.FontFace = isClassicStyle and Font.fromEnum(Enum.Font.SourceSans) or Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
			itemText.Text = item.Text or ""
			itemText.ZIndex = itemBtn.ZIndex + 1

			-- Icon hoặc Checkbox nếu có
			if item.Type == "Select" then
				local check = Instance.new("Frame", itemBtn)
				check.BorderSizePixel = 0
				check.BackgroundColor3 = palette.ContextCheckBoxBg
				check.Size = UDim2.new(0, 14, 0, 14)
				check.Position = UDim2.new(0, 4, 0.5, -7)
				check.ZIndex = itemBtn.ZIndex + 1
				Instance.new("UICorner", check).CornerRadius = isClassicStyle and UDim.new(0, 0) or UDim.new(0, 3)

				if item.Selected then
					local mark = Instance.new("Frame", check)
					mark.BorderSizePixel = 0
					mark.BackgroundColor3 = palette.ContextCheckMark
					mark.Size = UDim2.new(0, 8, 0, 8)
					mark.AnchorPoint = Vector2.new(0.5, 0.5)
					mark.Position = UDim2.new(0.5, 0, 0.5, 0)
					mark.ZIndex = check.ZIndex + 1
					Instance.new("UICorner", mark).CornerRadius = isClassicStyle and UDim.new(0, 0) or UDim.new(0, 2)
				end
			end

			-- Submenu Arrow
			if item.Type == "Submenu" then
				local arrow = Instance.new("TextLabel", itemBtn)
				arrow.BackgroundTransparency = 1
				arrow.Size = UDim2.new(0, 16, 1, 0)
				arrow.AnchorPoint = Vector2.new(1, 0)
				arrow.Position = UDim2.new(1, -4, 0, 0)
				arrow.Text = "▶"
				arrow.TextSize = 9
				arrow.TextColor3 = palette.ContextArrow
				arrow.ZIndex = itemBtn.ZIndex + 1
			end

			if not item.Disabled then
				itemBtn.MouseEnter:Connect(function()
					itemBtn.BackgroundColor3 = palette.ContextItemHover
					if isClassicStyle then itemText.TextColor3 = Color3.fromRGB(0, 0, 0) end
					if item.Type == "Submenu" and item.Items then
						local nextPos = Vector2.new(menuFrame.AbsolutePosition.X + menuFrame.AbsoluteSize.X + 2, itemBtn.AbsolutePosition.Y)
						Library.RenderContextMenu(nextPos, item.Items, level + 1)
					else
						Library.ClearSubmenus(level + 1)
					end
				end)

				itemBtn.MouseLeave:Connect(function()
					itemBtn.BackgroundColor3 = palette.ContextItemDefault
					if isClassicStyle then itemText.TextColor3 = palette.ContextItemText end
				end)

				itemBtn.MouseButton1Click:Connect(function()
					if item.Type == "Select" then
						item.Selected = not item.Selected
						if item.Callback then item.Callback(item.Selected) end
						Library.ClearSubmenus(1)
					elseif item.Type == "Button" then
						if item.Callback then item.Callback() end
						Library.ClearSubmenus(1)
					end
				end)
			end
		end
	end

	activeContextMenus[level] = menuFrame
end

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
		local mousePos = UserInputService:GetMouseLocation()
		local clickedInside = false
		for _, menu in pairs(activeContextMenus) do
			if menu and menu.Parent then
				local p = menu.AbsolutePosition
				local s = menu.AbsoluteSize
				if mousePos.X >= p.X and mousePos.X <= p.X + s.X and mousePos.Y >= p.Y and mousePos.Y <= p.Y + s.Y then
					clickedInside = true
					break
				end
			end
		end
		if not clickedInside then
			Library.ClearSubmenus(1)
		end
	end
end)

--------------------------------------------------------------------------------
-- HỆ THỐNG THÔNG BÁO (NOTIFICATIONS)
--------------------------------------------------------------------------------
local NotiHolder = Instance.new("Frame", NonUserGui)
NotiHolder.Name = "NotificationHolder"
NotiHolder.BackgroundTransparency = 1
NotiHolder.Position = UDim2.new(1, -290, 1, -20)
NotiHolder.AnchorPoint = Vector2.new(0, 1)
NotiHolder.Size = UDim2.new(0, 280, 0, 0)
NotiHolder.AutomaticSize = Enum.AutomaticSize.Y
NotiHolder.ZIndex = 98000

local NotiLayout = Instance.new("UIListLayout", NotiHolder)
NotiLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotiLayout.Padding = UDim.new(0, 8)
NotiLayout.SortOrder = Enum.SortOrder.LayoutOrder

function Library:Notify(cfg)
	local title = cfg.Title or "Thông Báo"
	local subtitle = cfg.Subtitle or ""
	local duration = cfg.Duration or 3.5

	local route = THEME_ROUTING[Library.CurrentTheme] or THEME_ROUTING["Dark"]
	local currentModule = Library.LoadedModules[route.File]
	local palette = (currentModule and currentModule.Palettes and currentModule.Palettes[route.SubTheme])
		or {
			NotiBackground = Color3.fromRGB(25, 25, 25),
			NotiStroke = Color3.fromRGB(55, 55, 55),
			NotiTitle = Color3.fromRGB(255, 255, 255),
			NotiSubtitle = Color3.fromRGB(200, 200, 200),
			NotiCloseIcon = Color3.fromRGB(220, 220, 220)
		}

	local isClassicStyle = (route.ModuleType == "Classic" or route.ModuleType == "ClassicV2")

	local card = Instance.new("Frame", NotiHolder)
	card.Name = "NotiCard"
	card.BackgroundColor3 = palette.NotiBackground
	card.BorderSizePixel = 0
	card.Size = UDim2.new(1, 0, 0, 0)
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.ZIndex = 98001

	local cCorner = Instance.new("UICorner", card)
	cCorner.CornerRadius = isClassicStyle and UDim.new(0, 0) or UDim.new(0, 8)

	local cStroke = Instance.new("UIStroke", card)
	cStroke.Color = palette.NotiStroke

	local cPadding = Instance.new("UIPadding", card)
	cPadding.PaddingTop = UDim.new(0, 8); cPadding.PaddingBottom = UDim.new(0, 8)
	cPadding.PaddingLeft = UDim.new(0, 10); cPadding.PaddingRight = UDim.new(0, 10)

	local tLabel = Instance.new("TextLabel", card)
	tLabel.BackgroundTransparency = 1
	tLabel.Size = UDim2.new(1, 0, 0, 18)
	tLabel.TextSize = 13
	tLabel.TextColor3 = palette.NotiTitle
	tLabel.TextXAlignment = Enum.TextXAlignment.Left
	tLabel.FontFace = isClassicStyle and Font.fromEnum(Enum.Font.SourceSansBold) or Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	tLabel.Text = title
	tLabel.ZIndex = 98002

	local sLabel = Instance.new("TextLabel", card)
	sLabel.BackgroundTransparency = 1
	sLabel.Position = UDim2.new(0, 0, 0, 20)
	sLabel.Size = UDim2.new(1, 0, 0, 0)
	sLabel.AutomaticSize = Enum.AutomaticSize.Y
	sLabel.TextSize = 11
	sLabel.TextColor3 = palette.NotiSubtitle
	sLabel.TextXAlignment = Enum.TextXAlignment.Left
	sLabel.TextWrapped = true
	sLabel.FontFace = isClassicStyle and Font.fromEnum(Enum.Font.SourceSans) or Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	sLabel.Text = subtitle
	sLabel.ZIndex = 98002

	task.delay(duration, function()
		if card and card.Parent then
			TweenService:Create(card, TweenInfo.new(0.25), {BackgroundTransparency = 1}):Play()
			cStroke.Transparency = 1
			tLabel.TextTransparency = 1
			sLabel.TextTransparency = 1
			task.delay(0.26, function() card:Destroy() end)
		end
	end)
end

--------------------------------------------------------------------------------
-- HÀM KHỞI TẠO CỬA SỔ THEO CHUẨN BUILDER CALLBACK (CREATE WINDOW)
--------------------------------------------------------------------------------
function Library:CreateWindow(config, builderCallback)
	local route = THEME_ROUTING[Library.CurrentTheme] or THEME_ROUTING["Dark"]
	local themeModule = Library.GetModuleForTheme(Library.CurrentTheme)

	if not themeModule then
		error("[Library] Không thể khởi tạo giao diện với Theme: " .. tostring(Library.CurrentTheme))
		return nil
	end

	if themeModule.Init then
		themeModule.Init(Library)
	end

	local windowRecord = themeModule.CreateWindow(Library, config, route.SubTheme)
	Library.RegisterActiveWindow(windowRecord)

	local reg = {
		Config = config,
		BuilderCallback = builderCallback,
		CurrentRecord = windowRecord
	}
	table.insert(Library.RegisteredWindows, reg)

	if builderCallback then
		builderCallback(windowRecord.API:GetContainer(), windowRecord.API)
	end

	Library.BringToFront(windowRecord.Frame, windowRecord)
	return windowRecord.API
end

--------------------------------------------------------------------------------
-- PHÍM TẮT TOÀN CỤC: TOGGLE DESKTOP (CTRL+D) & SWITCHER (CTRL+TAB)
--------------------------------------------------------------------------------
local isDesktopHidden = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed then
		-- Toggle Desktop (Ctrl + D)
		if input.KeyCode == Enum.KeyCode.D and (UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)) then
			isDesktopHidden = not isDesktopHidden
			for _, win in ipairs(Library.ActiveWindows) do
				if isDesktopHidden then
					if win.Minimize then win.Minimize() end
				else
					if win.Restore then win.Restore() end
				end
			end
		end
	end
end)

return Library
