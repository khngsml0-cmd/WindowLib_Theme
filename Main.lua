-- Main.lua (Core Hub - 100% Original Backup Engine)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

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
	MRUWindows = {},
	OnThemeChanged = Instance.new("BindableEvent"),
	BaseThemeURL = "https://raw.githubusercontent.com/khngsml0-cmd/WindowLib_Theme/main/Themes/"
}

local THEME_ROUTING = {
	["Dark"]      = { File = "Modern.lua",    ModuleType = "Modern",    SubTheme = "Dark" },
	["Light"]     = { File = "Modern.lua",    ModuleType = "Modern",    SubTheme = "Light" },
	["Classic"]   = { File = "Classic.lua",   ModuleType = "Classic",   SubTheme = "Classic" },
	["ClassicV2"] = { File = "ClassicV2.lua", ModuleType = "ClassicV2", SubTheme = "ClassicV2" }
}

local function getTargetGuiParent()
	if not RunService:IsStudio() then
		if gethui then
			local success, hui = pcall(gethui)
			if success and hui then return hui end
		end
		local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
		if success and coreGui then return coreGui end
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local RootParent = getTargetGuiParent()
local BASE_DISPLAY_ORDER = 100000

local SystemGui = Instance.new("ScreenGui")
SystemGui.Name = "SYSTEM"
SystemGui.IgnoreGuiInset = true
SystemGui.ResetOnSpawn = false
SystemGui.DisplayOrder = BASE_DISPLAY_ORDER
SystemGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
SystemGui.Parent = RootParent

local NonUserGui = Instance.new("ScreenGui")
NonUserGui.Name = "NonUser"
NonUserGui.IgnoreGuiInset = true
NonUserGui.DisplayOrder = BASE_DISPLAY_ORDER + 500
NonUserGui.ResetOnSpawn = false
NonUserGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NonUserGui.Parent = SystemGui

local CustomOpenGui = Instance.new("ScreenGui")
CustomOpenGui.Name = "CustomOpenUI"
CustomOpenGui.IgnoreGuiInset = true
CustomOpenGui.DisplayOrder = BASE_DISPLAY_ORDER + 600
CustomOpenGui.ResetOnSpawn = false
CustomOpenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
CustomOpenGui.Parent = SystemGui

local ContextMenuGui = Instance.new("ScreenGui")
ContextMenuGui.Name = "SYSTEM_DefaultContextMenu"
ContextMenuGui.IgnoreGuiInset = true
ContextMenuGui.DisplayOrder = BASE_DISPLAY_ORDER + 999900
ContextMenuGui.ResetOnSpawn = false
ContextMenuGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ContextMenuGui.Parent = SystemGui

local NotificationGui = Instance.new("ScreenGui")
NotificationGui.Name = "SYSTEM_Notification"
NotificationGui.IgnoreGuiInset = true
NotificationGui.DisplayOrder = BASE_DISPLAY_ORDER + 999999
NotificationGui.ResetOnSpawn = false
NotificationGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotificationGui.Parent = SystemGui

local NotiListLayout = Instance.new("UIListLayout", NotificationGui)
NotiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotiListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotiListLayout.Padding = UDim.new(0, 6)

local NotiPadding = Instance.new("UIPadding", NotificationGui)
NotiPadding.PaddingTop = UDim.new(0, 10); NotiPadding.PaddingRight = UDim.new(0, 10)
NotiPadding.PaddingLeft = UDim.new(0, 10); NotiPadding.PaddingBottom = UDim.new(0, 10)

Library.RootParent = RootParent
Library.SystemGui = SystemGui
Library.NonUserGui = NonUserGui
Library.CustomOpenGui = CustomOpenGui
Library.ContextMenuGui = ContextMenuGui
Library.NotificationGui = NotificationGui

local currentTopWindowZIndex = 10
function Library.GetNextZIndex()
	currentTopWindowZIndex = currentTopWindowZIndex + 1
	return currentTopWindowZIndex
end

local cascadeState = {
	startX = 50, startY = 50, currentX = 50, currentY = 50,
	stepX = 30, stepY = 30, columnStartX = 50, columnStepX = 180
}

function Library.GetNextCascadePosition(defaultSize, targetParent)
	if targetParent ~= NonUserGui then return UDim2.new(0, 20, 0, 20) end
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
	local winW = defaultSize.X.Offset > 0 and defaultSize.X.Offset or 500
	local winH = defaultSize.Y.Offset > 0 and defaultSize.Y.Offset or 350
	local posX = cascadeState.currentX; local posY = cascadeState.currentY
	if posY + winH > viewport.Y - 50 then
		cascadeState.columnStartX = cascadeState.columnStartX + cascadeState.columnStepX
		posX = cascadeState.columnStartX; posY = cascadeState.startY
		cascadeState.currentX = posX; cascadeState.currentY = posY
	end
	if posX + winW > viewport.X - 30 then
		cascadeState.columnStartX = cascadeState.startX
		posX = cascadeState.startX; posY = cascadeState.startY
		cascadeState.currentX = posX; cascadeState.currentY = posY
	end
	cascadeState.currentX = cascadeState.currentX + cascadeState.stepX
	cascadeState.currentY = cascadeState.currentY + cascadeState.stepY
	return UDim2.new(0, posX, 0, posY)
end

--------------------------------------------------------------------------------
-- OUTLINE DRAG & SNAP GHOST
--------------------------------------------------------------------------------
local DragOutlineFrame = Instance.new("Frame", SystemGui)
DragOutlineFrame.Name = "SYSTEM_DragOutlineFrame"
DragOutlineFrame.BorderSizePixel = 0
DragOutlineFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
DragOutlineFrame.BackgroundTransparency = 0.85
DragOutlineFrame.Visible = false
DragOutlineFrame.ZIndex = 99998
Instance.new("UICorner", DragOutlineFrame).CornerRadius = UDim.new(0, 6)

local DragOutlineStroke = Instance.new("UIStroke", DragOutlineFrame)
DragOutlineStroke.Color = Color3.fromRGB(50, 50, 50)
DragOutlineStroke.Thickness = 2
DragOutlineStroke.LineJoinMode = Enum.LineJoinMode.Miter
Library.DragOutlineFrame = DragOutlineFrame

local SnapGhostFrame = Instance.new("Frame", SystemGui)
SnapGhostFrame.Name = "SnapGhostFrame"
SnapGhostFrame.BorderSizePixel = 0
SnapGhostFrame.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
SnapGhostFrame.BackgroundTransparency = 1
SnapGhostFrame.Visible = false
SnapGhostFrame.ZIndex = 99999
Instance.new("UICorner", SnapGhostFrame).CornerRadius = UDim.new(0, 6)

local function createDottedEdge(parent, size, pos, isVertical)
	local edge = Instance.new("ImageLabel", parent)
	edge.Name = isVertical and "DottedV" or "DottedH"
	edge.BackgroundTransparency = 1
	edge.Size = size; edge.Position = pos
	edge.Image = "rbxassetid://6071575925"
	edge.ImageColor3 = Color3.fromRGB(0, 170, 255)
	edge.ImageTransparency = 1
	edge.ScaleType = Enum.ScaleType.Tile
	edge.TileSize = isVertical and UDim2.new(0, 2, 0, 8) or UDim2.new(0, 8, 0, 2)
	return edge
end

local snapTop = createDottedEdge(SnapGhostFrame, UDim2.new(1, 0, 0, 2), UDim2.new(0, 0, 0, 0), false)
local snapBottom = createDottedEdge(SnapGhostFrame, UDim2.new(1, 0, 0, 2), UDim2.new(0, 0, 1, -2), false)
local snapLeft = createDottedEdge(SnapGhostFrame, UDim2.new(0, 2, 1, 0), UDim2.new(0, 0, 0, 0), true)
local snapRight = createDottedEdge(SnapGhostFrame, UDim2.new(0, 2, 1, 0), UDim2.new(1, -2, 0, 0), true)

function Library.ShowSnapGhost(pos, size)
	SnapGhostFrame.Visible = true
	TweenService:Create(SnapGhostFrame, TweenInfo.new(0.15), {Position = pos, Size = size, BackgroundTransparency = 0.88}):Play()
	for _, edge in ipairs({snapTop, snapBottom, snapLeft, snapRight}) do
		TweenService:Create(edge, TweenInfo.new(0.15), {ImageTransparency = 0.1}):Play()
	end
end

function Library.HideSnapGhost()
	local t = TweenService:Create(SnapGhostFrame, TweenInfo.new(0.15), {BackgroundTransparency = 1})
	for _, edge in ipairs({snapTop, snapBottom, snapLeft, snapRight}) do
		TweenService:Create(edge, TweenInfo.new(0.15), {ImageTransparency = 1}):Play()
	end
	t:Play()
	t.Completed:Connect(function()
		if SnapGhostFrame.BackgroundTransparency >= 0.99 then SnapGhostFrame.Visible = false end
	end)
end

function Library.IsGlobalOutlineDrag() return Library.IsOutlineDrag end
function Library:SetOutlineDrag(state) Library.IsOutlineDrag = (state == true) end
function Library:GetOutlineDrag() return Library.IsOutlineDrag end

--------------------------------------------------------------------------------
-- AUTO MINIMIZE TASKBAR GRID (MODERN THEME)
--------------------------------------------------------------------------------
function Library.UpdateMinimizedGrid()
	if Library.CurrentTheme == "Classic" or Library.CurrentTheme == "ClassicV2" then
		return
	end

	local itemW = 180; local itemH = 28; local pad = 6; local marginX = 10; local marginY = 10
	local groups = {}
	for _, win in ipairs(Library.MinimizedWindows) do
		local p = win.TargetParent or NonUserGui
		groups[p] = groups[p] or {}
		table.insert(groups[p], win)
	end

	for parentObj, winGroup in pairs(groups) do
		local containerWidth = 1920
		if parentObj:IsA("GuiObject") and parentObj.AbsoluteSize.X > 0 then
			containerWidth = parentObj.AbsoluteSize.X
		elseif workspace.CurrentCamera then
			containerWidth = workspace.CurrentCamera.ViewportSize.X
		end

		local maxCols = math.max(1, math.floor((containerWidth - marginX) / (itemW + pad)))

		for idx, win in ipairs(winGroup) do
			local col = (idx - 1) % maxCols
			local row = math.floor((idx - 1) / maxCols)
			local targetX = marginX + col * (itemW + pad)
			local targetYOffset = -(marginY + itemH + (row * (itemH + pad)))

			TweenService:Create(win.Frame, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
				Position = UDim2.new(0, targetX, 1, targetYOffset),
				Size = UDim2.new(0, itemW, 0, itemH)
			}):Play()
		end
	end
end

--------------------------------------------------------------------------------
-- QUẢN LÝ CỬA SỔ VÀ FOCUS MANAGER
--------------------------------------------------------------------------------
function Library.BringToFront(frame, windowRecord)
	local topZ = Library.GetNextZIndex()
	frame.ZIndex = topZ

	if Library.FocusedWindow and Library.FocusedWindow ~= windowRecord and Library.FocusedWindow.SetFocusVisual then
		Library.FocusedWindow.SetFocusVisual(false)
	end

	Library.FocusedWindow = windowRecord
	if windowRecord and windowRecord.SetFocusVisual then
		windowRecord.SetFocusVisual(true)
	end

	for i, w in ipairs(Library.MRUWindows) do
		if w == windowRecord then table.remove(Library.MRUWindows, i); break end
	end
	table.insert(Library.MRUWindows, 1, windowRecord)
end

function Library.SetFocus(windowRecord)
	if windowRecord then
		Library.BringToFront(windowRecord.Frame, windowRecord)
	else
		if Library.FocusedWindow and Library.FocusedWindow.SetFocusVisual then
			Library.FocusedWindow.SetFocusVisual(false)
		end
		Library.FocusedWindow = nil
	end
end

function Library.RegisterActiveWindow(windowRecord)
	if not table.find(Library.ActiveWindows, windowRecord) then
		table.insert(Library.ActiveWindows, windowRecord)
		table.insert(Library.MRUWindows, 1, windowRecord)
	end
end

function Library.UnregisterActiveWindow(windowRecord)
	local idx = table.find(Library.ActiveWindows, windowRecord)
	if idx then table.remove(Library.ActiveWindows, idx) end
	local minIdx = table.find(Library.MinimizedWindows, windowRecord)
	if minIdx then table.remove(Library.MinimizedWindows, minIdx) end
	local mruIdx = table.find(Library.MRUWindows, windowRecord)
	if mruIdx then table.remove(Library.MRUWindows, mruIdx) end
	if Library.FocusedWindow == windowRecord then
		Library.FocusedWindow = nil
		if #Library.ActiveWindows > 0 then
			Library.SetFocus(Library.ActiveWindows[#Library.ActiveWindows])
		end
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
-- NẠP MODULE THEME TỪ GITHUB
--------------------------------------------------------------------------------
function Library.GetModuleForTheme(themeName)
	local route = THEME_ROUTING[themeName] or THEME_ROUTING["Dark"]
	local fileName = route.File

	if Library.LoadedModules[fileName] then
		return Library.LoadedModules[fileName], route
	end

	local url = Library.BaseThemeURL .. fileName
	local success, content = pcall(function() return game:HttpGet(url) end)

	if not success or not content or content == "" then
		warn("[Library] Không thể nạp Theme Module từ: " .. url)
		return nil, route
	end

	local loadFunc, err = loadstring(content)
	if not loadFunc then
		warn("[Library] Lỗi phân tích cú pháp Theme (" .. fileName .. "): " .. tostring(err))
		return nil, route
	end

	local themeModule = loadFunc()
	Library.LoadedModules[fileName] = themeModule
	return themeModule, route
end

function Library:GetTheme() return Library.CurrentTheme end

function Library:SetTheme(newThemeName)
	if type(newThemeName) ~= "string" then return end
	local lower = string.lower(newThemeName)
	local targetName = "Dark"

	if lower == "light" or lower == "trang" or lower == "sáng" or lower == "sang" then targetName = "Light"
	elseif lower == "dark" or lower == "den" or lower == "tối" or lower == "toi" then targetName = "Dark"
	elseif lower == "classic" or lower == "retro" or lower == "2016" or lower == "codien" or lower == "cổ điển" then targetName = "Classic"
	elseif lower == "classicv2" or lower == "dock" or lower == "dockwidget" or lower == "studio" then targetName = "ClassicV2" end

	local oldThemeName = Library.CurrentTheme
	local oldRoute = THEME_ROUTING[oldThemeName] or THEME_ROUTING["Dark"]
	local targetRoute = THEME_ROUTING[targetName] or THEME_ROUTING["Dark"]
	local isTransitioningArchetype = (oldRoute.ModuleType ~= targetRoute.ModuleType)

	Library.CurrentTheme = targetName
	Library.CurrentModuleType = targetRoute.ModuleType

	local themeModule = Library.GetModuleForTheme(targetName)
	if not themeModule then return end

	if isTransitioningArchetype then
		-- Hủy bỏ module cũ
		if Library.LoadedModules[oldRoute.File] and Library.LoadedModules[oldRoute.File].Cleanup then
			Library.LoadedModules[oldRoute.File].Cleanup(Library)
		end

		-- Khởi tạo module mới
		if themeModule.Init then
			themeModule.Init(Library)
		end

		-- Xóa sạch Frame cũ ngay lập tức
		for _, win in ipairs(Library.ActiveWindows) do
			if win.Frame and win.Frame.Parent then
				win.Frame:Destroy()
			end
		end

		Library.ActiveWindows = {}
		Library.MinimizedWindows = {}
		Library.MRUWindows = {}
		Library.FocusedWindow = nil

		-- Auto-Rebuild toàn bộ cửa sổ đã đăng ký
		local oldRegistry = Library.RegisteredWindows
		Library.RegisteredWindows = {}

		for _, item in ipairs(oldRegistry) do
			local savedConfig = item.Config
			local newRecord = themeModule.CreateWindow(Library, savedConfig, targetRoute.SubTheme)
			Library.RegisterActiveWindow(newRecord)

			if item.Builder and type(item.Builder) == "function" then
				item.Builder(newRecord.API:GetContainer(), newRecord.API)
			end

			item.CurrentRecord = newRecord
			table.insert(Library.RegisteredWindows, item)
			Library.BringToFront(newRecord.Frame, newRecord)
		end
	else
		-- Cập nhật màu sắc nếu cùng kiểu kiến trúc (Dark <-> Light)
		for _, reg in ipairs(Library.RegisteredWindows) do
			if reg.CurrentRecord and reg.CurrentRecord.UpdateTheme and themeModule.Palettes[targetRoute.SubTheme] then
				reg.CurrentRecord.UpdateTheme(themeModule.Palettes[targetRoute.SubTheme])
			end
		end
	end

	Library.OnThemeChanged:Fire(targetName, isTransitioningArchetype)
end

--------------------------------------------------------------------------------
-- CONTEXT MENU SYSTEM (TỰ DÃN THÔNG MINH, ĐO BỀ RỘNG THEO TEXTSERVICE)
--------------------------------------------------------------------------------
local activeSubmenuFrames = {}

local function clearSubmenusFromLevel(level)
	for i = #activeSubmenuFrames, level, -1 do
		if activeSubmenuFrames[i] then
			activeSubmenuFrames[i]:Destroy()
			table.remove(activeSubmenuFrames, i)
		end
	end
end

function Library.ClearSubmenus(level)
	clearSubmenusFromLevel(level or 1)
end

local function applyContextMenu3DBorder(parentFrame)
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

function Library.RenderContextMenu(pos, items, level, parentBtnWidth)
	level = level or 1
	clearSubmenusFromLevel(level)

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

	local isClassic = (route.ModuleType == "Classic" or route.ModuleType == "ClassicV2")
	local font = isClassic and Enum.Font.SourceSans or Enum.Font.Gotham
	local itemHeight = isClassic and 25 or 24
	local sepHeight = 10
	local itemSpacing = isClassic and 0 or 2
	local padTop = isClassic and 3 or 4
	local padBottom = isClassic and 3 or 4
	local padLeft = isClassic and 3 or 4
	local padRight = isClassic and 3 or 4

	local minMenuWidth = 180
	local maxItemWidth = minMenuWidth

	for _, item in ipairs(items or {}) do
		if item.Type ~= "Separator" then
			local text = item.Text or ""
			local rawSize = TextService:GetTextSize(text, 13, font, Vector2.new(2000, 50))
			local textW = math.ceil(rawSize.X * 1.1)

			local extraPadding = 36
			if item.Type == "Select" then extraPadding = 64
			elseif item.Type == "Submenu" then extraPadding = 54 end

			local itemW = textW + extraPadding
			if itemW > maxItemWidth then maxItemWidth = itemW end
		end
	end

	local menuWidth = math.ceil(maxItemWidth) + 12
	local totalContentHeight = 0
	local itemCount = #items

	for _, item in ipairs(items or {}) do
		if item.Type == "Separator" then
			totalContentHeight = totalContentHeight + sepHeight
		else
			totalContentHeight = totalContentHeight + itemHeight
		end
	end

	local totalGaps = math.max(0, itemCount - 1) * itemSpacing
	local totalMenuHeight = totalContentHeight + totalGaps + padTop + padBottom

	local menuFrame = Instance.new("ImageButton", ContextMenuGui)
	menuFrame.Name = "ContextMenuLevel_" .. level
	menuFrame.BorderSizePixel = 0
	menuFrame.AutoButtonColor = false
	menuFrame.BackgroundColor3 = palette.ContextMenuBackground
	menuFrame.Size = UDim2.new(0, menuWidth, 0, totalMenuHeight)
	menuFrame.ZIndex = 999900 + level

	if isClassic then
		applyContextMenu3DBorder(menuFrame)
	else
		Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0, 6)
		local stroke = Instance.new("UIStroke", menuFrame)
		stroke.Color = palette.ContextMenuStroke
	end

	local padding = Instance.new("UIPadding", menuFrame)
	padding.PaddingTop = UDim.new(0, padTop); padding.PaddingBottom = UDim.new(0, padBottom)
	padding.PaddingLeft = UDim.new(0, padLeft); padding.PaddingRight = UDim.new(0, padRight)

	local listContainer = Instance.new("Frame", menuFrame)
	listContainer.BackgroundTransparency = 1
	listContainer.Size = UDim2.new(1, 0, 1, 0)
	listContainer.ZIndex = menuFrame.ZIndex + 1

	local layout = Instance.new("UIListLayout", listContainer)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, itemSpacing)

	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
	local finalX = pos.X
	local finalY = pos.Y

	if finalX + menuWidth > viewport.X - 10 then
		if level > 1 and parentBtnWidth then finalX = math.max(10, pos.X - parentBtnWidth - menuWidth - 4)
		else finalX = math.max(10, pos.X - menuWidth) end
	end
	if finalY + totalMenuHeight > viewport.Y - 10 then
		finalY = math.max(10, viewport.Y - totalMenuHeight - 10)
	end

	menuFrame.Position = UDim2.new(0, finalX, 0, finalY)
	table.insert(activeSubmenuFrames, menuFrame)

	local itemDefaultBg = palette.ContextItemDefault
	local itemHoverBg = palette.ContextItemHover
	local currentYOffset = finalY + padTop

	for itemIndex, item in ipairs(items or {}) do
		local thisItemY = currentYOffset
		local thisItemH = (item.Type == "Separator") and sepHeight or itemHeight

		if item.Type == "Separator" then
			local Sep = Instance.new("Frame", listContainer)
			Sep.BackgroundTransparency = 1
			Sep.Size = UDim2.new(1, 0, 0, sepHeight)
			Sep.ZIndex = listContainer.ZIndex

			local LineFrame = Instance.new("Frame", Sep)
			LineFrame.BorderSizePixel = 0
			LineFrame.BackgroundColor3 = palette.ContextItemSeparator
			LineFrame.AnchorPoint = Vector2.new(0.5, 0.5)
			LineFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
			LineFrame.Size = UDim2.new(1, -6, 0, 1)
			LineFrame.ZIndex = Sep.ZIndex

		elseif item.Type == "Button" then
			local Btn = Instance.new("TextButton", listContainer)
			Btn.BorderSizePixel = 0
			Btn.AutoButtonColor = false
			Btn.BackgroundColor3 = itemDefaultBg
			Btn.Size = UDim2.new(1, 0, 0, itemHeight)
			Btn.Text = ""
			Btn.ZIndex = listContainer.ZIndex

			if not isClassic then Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4) end

			local Text = Instance.new("TextLabel", Btn)
			Text.BackgroundTransparency = 1
			Text.TextSize = 13
			Text.TextXAlignment = Enum.TextXAlignment.Left
			Text.TextColor3 = item.Disabled and palette.ContextItemTextDisabled or palette.ContextItemText
			Text.Font = font
			Text.Size = UDim2.new(1, 0, 1, 0)
			Text.Text = item.Text or ""
			Text.ZIndex = Btn.ZIndex

			local Pad = Instance.new("UIPadding", Text)
			Pad.PaddingLeft = UDim.new(0, 8); Pad.PaddingRight = UDim.new(0, 8)

			if not item.Disabled then
				Btn.MouseEnter:Connect(function()
					Btn.BackgroundColor3 = itemHoverBg
					if not isClassic then Text.TextColor3 = Color3.fromRGB(255, 255, 255) end
					clearSubmenusFromLevel(level + 1)
				end)
				Btn.MouseLeave:Connect(function()
					Btn.BackgroundColor3 = itemDefaultBg
					if not isClassic then Text.TextColor3 = palette.ContextItemText end
				end)
				Btn.MouseButton1Click:Connect(function()
					clearSubmenusFromLevel(1)
					if item.Callback then item.Callback() end
				end)
			end

		elseif item.Type == "Select" then
			local Btn = Instance.new("TextButton", listContainer)
			Btn.BorderSizePixel = 0
			Btn.AutoButtonColor = false
			Btn.BackgroundColor3 = itemDefaultBg
			Btn.Size = UDim2.new(1, 0, 0, itemHeight)
			Btn.Text = ""
			Btn.ZIndex = listContainer.ZIndex

			if not isClassic then Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4) end

			local Text = Instance.new("TextLabel", Btn)
			Text.BackgroundTransparency = 1
			Text.TextSize = 13
			Text.TextXAlignment = Enum.TextXAlignment.Left
			Text.TextColor3 = item.Disabled and palette.ContextItemTextDisabled or palette.ContextItemText
			Text.Font = font
			Text.Size = UDim2.new(1, -30, 1, 0)
			Text.Text = item.Text or ""
			Text.ZIndex = Btn.ZIndex

			local Pad = Instance.new("UIPadding", Text)
			Pad.PaddingLeft = UDim.new(0, 8)

			local Hitbox = Instance.new("TextButton", Btn)
			Hitbox.Name = "Hitbox"
			Hitbox.BorderSizePixel = 0
			Hitbox.AutoButtonColor = false
			Hitbox.Text = ""
			Hitbox.AnchorPoint = Vector2.new(1, 0.5)
			Hitbox.Position = UDim2.new(1, -6, 0.5, 0)
			Hitbox.Size = UDim2.new(0, 15, 0, 15)
			Hitbox.BackgroundColor3 = palette.ContextCheckBoxBg
			Hitbox.ZIndex = Btn.ZIndex + 1

			local stroke = Instance.new("UIStroke", Hitbox)
			stroke.Color = isClassic and Color3.fromRGB(192, 192, 192) or palette.ContextMenuStroke
			stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			local ActiveMark = Instance.new("Frame", Hitbox)
			ActiveMark.Name = "Active"
			ActiveMark.BorderSizePixel = 0
			ActiveMark.AnchorPoint = Vector2.new(0.5, 0.5)
			ActiveMark.Position = UDim2.new(0.5, 0, 0.5, 0)
			ActiveMark.Size = UDim2.new(1, -4, 1, -4)
			ActiveMark.BackgroundColor3 = palette.ContextCheckMark
			ActiveMark.Visible = item.Selected or false
			ActiveMark.ZIndex = Hitbox.ZIndex + 1

			if not isClassic then
				Instance.new("UICorner", Hitbox).CornerRadius = UDim.new(0, 3)
				Instance.new("UICorner", ActiveMark).CornerRadius = UDim.new(0, 2)
			end

			if not item.Disabled then
				Btn.MouseEnter:Connect(function()
					Btn.BackgroundColor3 = itemHoverBg
					if not isClassic then Text.TextColor3 = Color3.fromRGB(255, 255, 255) end
					clearSubmenusFromLevel(level + 1)
				end)
				Btn.MouseLeave:Connect(function()
					Btn.BackgroundColor3 = itemDefaultBg
					if not isClassic then Text.TextColor3 = palette.ContextItemText end
				end)

				local function toggle()
					item.Selected = not item.Selected
					ActiveMark.Visible = item.Selected
					if item.Callback then item.Callback(item.Selected) end
				end
				Btn.MouseButton1Click:Connect(toggle)
				Hitbox.MouseButton1Click:Connect(toggle)
			end

		elseif item.Type == "Submenu" then
			local Btn = Instance.new("TextButton", listContainer)
			Btn.BorderSizePixel = 0
			Btn.AutoButtonColor = false
			Btn.BackgroundColor3 = itemDefaultBg
			Btn.Size = UDim2.new(1, 0, 0, itemHeight)
			Btn.Text = ""
			Btn.ZIndex = listContainer.ZIndex

			if not isClassic then Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4) end

			local Text = Instance.new("TextLabel", Btn)
			Text.BackgroundTransparency = 1
			Text.TextSize = 13
			Text.TextXAlignment = Enum.TextXAlignment.Left
			Text.TextColor3 = item.Disabled and palette.ContextItemTextDisabled or palette.ContextItemText
			Text.Font = font
			Text.Size = UDim2.new(1, -26, 1, 0)
			Text.Text = item.Text or ""
			Text.ZIndex = Btn.ZIndex

			local Pad = Instance.new("UIPadding", Text)
			Pad.PaddingLeft = UDim.new(0, 8)

			local arrowHolder = Instance.new("Frame", Btn)
			arrowHolder.Name = "SubmenuArrow"
			arrowHolder.BackgroundTransparency = 1
			arrowHolder.AnchorPoint = Vector2.new(1, 0.5)
			arrowHolder.Position = UDim2.new(1, -6, 0.5, 0)
			arrowHolder.Size = UDim2.new(0, 15, 0, 15)
			arrowHolder.ZIndex = Btn.ZIndex + 1

			local arrowColor = item.Disabled and palette.ContextItemTextDisabled or palette.ContextArrow
			if isClassic then
				local bars = {
					{w = 1, h = 11, x = 0, y = -5}, {w = 1, h = 9, x = 1, y = -4},
					{w = 1, h = 7, x = 2, y = -3}, {w = 1, h = 5, x = 3, y = -2},
					{w = 1, h = 3, x = 4, y = -1}, {w = 1, h = 1, x = 5, y = 0}
				}
				for idx, b in ipairs(bars) do
					local bar = Instance.new("Frame", arrowHolder)
					bar.BorderSizePixel = 0; bar.BackgroundColor3 = arrowColor
					bar.Size = UDim2.new(0, b.w, 0, b.h); bar.Position = UDim2.new(0, b.x, 0.5, b.y)
				end
			else
				local arrowText = Instance.new("TextLabel", arrowHolder)
				arrowText.BackgroundTransparency = 1
				arrowText.Size = UDim2.new(1, 0, 1, 0)
				arrowText.Text = "›"
				arrowText.TextColor3 = arrowColor
				arrowText.TextSize = 16
			end

			local function openSubmenu()
				local subPos = Vector2.new(finalX + menuWidth + 2, thisItemY)
				Library.RenderContextMenu(subPos, item.Items, level + 1, menuWidth)
			end

			if not item.Disabled then
				Btn.MouseEnter:Connect(function()
					Btn.BackgroundColor3 = itemHoverBg
					if not isClassic then Text.TextColor3 = Color3.fromRGB(255, 255, 255) end
					openSubmenu()
				end)
				Btn.MouseLeave:Connect(function()
					Btn.BackgroundColor3 = itemDefaultBg
					if not isClassic then Text.TextColor3 = palette.ContextItemText end
				end)
				Btn.MouseButton1Click:Connect(openSubmenu)
			end
		end

		currentYOffset = currentYOffset + thisItemH + itemSpacing
	end

	return menuFrame
end

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if #activeSubmenuFrames > 0 then
			local rawMousePos = UserInputService:GetMouseLocation()
			local guiInset = GuiService:GetGuiInset()
			local mousePos = Vector2.new(rawMousePos.X, rawMousePos.Y - guiInset.Y)

			local clickedInsideAny = false
			for _, frame in ipairs(activeSubmenuFrames) do
				if frame and frame.Parent then
					local framePos = frame.AbsolutePosition; local frameSize = frame.AbsoluteSize
					if mousePos.X >= framePos.X and mousePos.X <= framePos.X + frameSize.X and mousePos.Y >= framePos.Y and mousePos.Y <= framePos.Y + frameSize.Y then
						clickedInsideAny = true
						break
					end
				end
			end

			if not clickedInsideAny then clearSubmenusFromLevel(1) end
		end
	end
end)

--------------------------------------------------------------------------------
-- APP SWITCHER (CTRL + TAB) & DESKTOP TOGGLE (CTRL + D)
--------------------------------------------------------------------------------
local AppSwitcherGui = Instance.new("ScreenGui")
AppSwitcherGui.Name = "SYSTEM_AppSwitcher"
AppSwitcherGui.IgnoreGuiInset = true
AppSwitcherGui.DisplayOrder = BASE_DISPLAY_ORDER + 999950
AppSwitcherGui.ResetOnSpawn = false
AppSwitcherGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
AppSwitcherGui.Parent = SystemGui

local SwitcherContainerModern = Instance.new("Frame", AppSwitcherGui)
SwitcherContainerModern.Name = "SwitcherContainerModern"
SwitcherContainerModern.BorderSizePixel = 0
SwitcherContainerModern.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
SwitcherContainerModern.BackgroundTransparency = 0.1
SwitcherContainerModern.AnchorPoint = Vector2.new(0.5, 0.5)
SwitcherContainerModern.Position = UDim2.new(0.5, 0, 0.5, 0)
SwitcherContainerModern.AutomaticSize = Enum.AutomaticSize.XY
SwitcherContainerModern.Visible = false
Instance.new("UICorner", SwitcherContainerModern).CornerRadius = UDim.new(0, 10)

local SwitcherStrokeModern = Instance.new("UIStroke", SwitcherContainerModern)
SwitcherStrokeModern.Color = Color3.fromRGB(45, 45, 45)

local SwitcherPaddingModern = Instance.new("UIPadding", SwitcherContainerModern)
SwitcherPaddingModern.PaddingTop = UDim.new(0, 14); SwitcherPaddingModern.PaddingBottom = UDim.new(0, 14)
SwitcherPaddingModern.PaddingLeft = UDim.new(0, 14); SwitcherPaddingModern.PaddingRight = UDim.new(0, 14)

local SwitcherLayoutModern = Instance.new("UIListLayout", SwitcherContainerModern)
SwitcherLayoutModern.FillDirection = Enum.FillDirection.Horizontal
SwitcherLayoutModern.HorizontalAlignment = Enum.HorizontalAlignment.Center
SwitcherLayoutModern.VerticalAlignment = Enum.VerticalAlignment.Center
SwitcherLayoutModern.Padding = UDim.new(0, 10)

local SwitcherContainerClassic = Instance.new("Frame", AppSwitcherGui)
SwitcherContainerClassic.Name = "SwitcherContainerClassic"
SwitcherContainerClassic.BorderSizePixel = 0
SwitcherContainerClassic.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SwitcherContainerClassic.AnchorPoint = Vector2.new(0.5, 0.5)
SwitcherContainerClassic.Position = UDim2.new(0.5, 0, 0.5, 0)
SwitcherContainerClassic.Size = UDim2.new(0, 0, 0, 50)
SwitcherContainerClassic.AutomaticSize = Enum.AutomaticSize.X
SwitcherContainerClassic.Visible = false

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

applyWindow3DBorder(SwitcherContainerClassic)

local ClassicAppContainer = Instance.new("Frame", SwitcherContainerClassic)
ClassicAppContainer.Name = "App"
ClassicAppContainer.BackgroundTransparency = 1
ClassicAppContainer.Size = UDim2.new(1, -10, 1, -10)
ClassicAppContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
ClassicAppContainer.AnchorPoint = Vector2.new(0.5, 0.5)
ClassicAppContainer.AutomaticSize = Enum.AutomaticSize.X

local ClassicAppLayout = Instance.new("UIListLayout", ClassicAppContainer)
ClassicAppLayout.Padding = UDim.new(0, 10)
ClassicAppLayout.FillDirection = Enum.FillDirection.Horizontal
ClassicAppLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
ClassicAppLayout.VerticalAlignment = Enum.VerticalAlignment.Center

local ClassicAppPadding = Instance.new("UIPadding", ClassicAppContainer)
ClassicAppPadding.PaddingLeft = UDim.new(0, 8); ClassicAppPadding.PaddingRight = UDim.new(0, 8)

local ClassicAppSelectTitle = Instance.new("TextLabel", SwitcherContainerClassic)
ClassicAppSelectTitle.Name = "AppSelect"
ClassicAppSelectTitle.BackgroundTransparency = 1
ClassicAppSelectTitle.AnchorPoint = Vector2.new(0.5, 0)
ClassicAppSelectTitle.Position = UDim2.new(0.5, 0, 1, 10)
ClassicAppSelectTitle.Size = UDim2.new(1, 40, 0, 20)
ClassicAppSelectTitle.Font = Enum.Font.SourceSans
ClassicAppSelectTitle.TextSize = 20
ClassicAppSelectTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ClassicAppSelectTitle.Text = ""

local ClassicAppSelectShadow = Instance.new("TextLabel", ClassicAppSelectTitle)
ClassicAppSelectShadow.Name = "Shadow"
ClassicAppSelectShadow.BackgroundTransparency = 1
ClassicAppSelectShadow.Position = UDim2.new(0, 1, 0, 1)
ClassicAppSelectShadow.Size = UDim2.new(1, 0, 1, 0)
ClassicAppSelectShadow.Font = Enum.Font.SourceSans
ClassicAppSelectShadow.TextSize = 20
ClassicAppSelectShadow.TextColor3 = Color3.fromRGB(0, 0, 0)
ClassicAppSelectShadow.ZIndex = 0
ClassicAppSelectShadow.Text = ""

local isSwitcherOpen = false
local switcherCurrentIdx = 1
local switcherCardElements = {}

local function renderSwitcherCards()
	for _, card in ipairs(switcherCardElements) do card:Destroy() end
	switcherCardElements = {}

	local isClassic = (Library.CurrentTheme == "Classic" or Library.CurrentTheme == "ClassicV2")
	local route = THEME_ROUTING[Library.CurrentTheme] or THEME_ROUTING["Dark"]
	local currentModule = Library.LoadedModules[route.File]
	local palette = (currentModule and currentModule.Palettes and currentModule.Palettes[route.SubTheme]) or {
		SwitcherBackground = Color3.fromRGB(25, 25, 25),
		SwitcherCardBg = Color3.fromRGB(35, 35, 35),
		SwitcherCardSelected = Color3.fromRGB(50, 50, 50),
		MainStroke = Color3.fromRGB(45, 45, 45),
		TitleTextColor = Color3.fromRGB(240, 240, 240)
	}

	if isClassic then
		SwitcherContainerModern.Visible = false
		SwitcherContainerClassic.Visible = true

		for idx, winData in ipairs(Library.MRUWindows) do
			local isSelected = (idx == switcherCurrentIdx)

			local itemFrame = Instance.new("Frame", ClassicAppContainer)
			itemFrame.Name = isSelected and "Template_Select" or "Template_Unselect"
			itemFrame.Size = UDim2.new(0, 35, 0, 35)
			itemFrame.BorderSizePixel = 0
			itemFrame.BackgroundColor3 = isSelected and Color3.fromRGB(0, 171, 255) or Color3.fromRGB(255, 255, 255)

			local stroke = Instance.new("UIStroke", itemFrame)
			stroke.Thickness = 2
			stroke.Color = Color3.fromRGB(52, 103, 154)
			stroke.LineJoinMode = Enum.LineJoinMode.Miter
			stroke.Enabled = isSelected

			local icon = Instance.new("ImageLabel", itemFrame)
			icon.Name = "Iconapp"
			icon.BackgroundTransparency = 1
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
			icon.Position = UDim2.new(0.5, 0, 0.5, 0)
			icon.Size = UDim2.new(0, 20, 0, 20)
			icon.Image = winData.GetIcon and winData.GetIcon() or "rbxasset://textures/ui/GuiImagePlaceholder.png"

			table.insert(switcherCardElements, itemFrame)
		end

		local activeWin = Library.MRUWindows[switcherCurrentIdx]
		local titleText = activeWin and (activeWin.GetTitle and activeWin.GetTitle() or "Window") or ""
		ClassicAppSelectTitle.Text = titleText
		ClassicAppSelectShadow.Text = titleText
	else
		SwitcherContainerClassic.Visible = false
		SwitcherContainerModern.Visible = true

		for idx, winData in ipairs(Library.MRUWindows) do
			local card = Instance.new("Frame", SwitcherContainerModern)
			card.Name = "Card_" .. idx
			card.Size = UDim2.new(0, 95, 0, 85)
			card.BorderSizePixel = 0
			card.BackgroundColor3 = (idx == switcherCurrentIdx) and palette.SwitcherCardSelected or palette.SwitcherCardBg
			Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

			local cardStroke = Instance.new("UIStroke", card)
			cardStroke.Color = (idx == switcherCurrentIdx) and Color3.fromRGB(0, 140, 255) or palette.MainStroke
			cardStroke.Thickness = (idx == switcherCurrentIdx) and 2 or 1

			local cardPadding = Instance.new("UIPadding", card)
			cardPadding.PaddingTop = UDim.new(0, 8); cardPadding.PaddingBottom = UDim.new(0, 6)
			cardPadding.PaddingLeft = UDim.new(0, 6); cardPadding.PaddingRight = UDim.new(0, 6)

			local cardLayout = Instance.new("UIListLayout", card)
			cardLayout.FillDirection = Enum.FillDirection.Vertical
			cardLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			cardLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			cardLayout.Padding = UDim.new(0, 6)

			local icon = Instance.new("ImageLabel", card)
			icon.BackgroundTransparency = 1
			icon.Size = UDim2.new(0, 36, 0, 36)
			icon.Image = winData.GetIcon and winData.GetIcon() or "rbxasset://textures/ui/GuiImagePlaceholder.png"

			local title = Instance.new("TextLabel", card)
			title.BackgroundTransparency = 1
			title.Size = UDim2.new(1, -12, 0, 16)
			title.TextSize = 11
			title.TextColor3 = palette.TitleTextColor
			title.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
			title.Text = winData.GetTitle and winData.GetTitle() or "Window"
			title.TextTruncate = Enum.TextTruncate.AtEnd

			table.insert(switcherCardElements, card)
		end
	end
end

local function updateSwitcherSelection()
	local isClassic = (Library.CurrentTheme == "Classic" or Library.CurrentTheme == "ClassicV2")
	local route = THEME_ROUTING[Library.CurrentTheme] or THEME_ROUTING["Dark"]
	local currentModule = Library.LoadedModules[route.File]
	local palette = (currentModule and currentModule.Palettes and currentModule.Palettes[route.SubTheme]) or {
		SwitcherCardBg = Color3.fromRGB(35, 35, 35),
		SwitcherCardSelected = Color3.fromRGB(50, 50, 50),
		MainStroke = Color3.fromRGB(45, 45, 45)
	}

	if isClassic then
		for idx, card in ipairs(switcherCardElements) do
			local isSelected = (idx == switcherCurrentIdx)
			card.BackgroundColor3 = isSelected and Color3.fromRGB(0, 171, 255) or Color3.fromRGB(255, 255, 255)
			local stroke = card:FindFirstChildOfClass("UIStroke")
			if stroke then stroke.Enabled = isSelected end
		end
		local activeWin = Library.MRUWindows[switcherCurrentIdx]
		local titleText = activeWin and (activeWin.GetTitle and activeWin.GetTitle() or "Window") or ""
		ClassicAppSelectTitle.Text = titleText
		ClassicAppSelectShadow.Text = titleText
	else
		for idx, card in ipairs(switcherCardElements) do
			local isSelected = (idx == switcherCurrentIdx)
			card.BackgroundColor3 = isSelected and palette.SwitcherCardSelected or palette.SwitcherCardBg
			local stroke = card:FindFirstChildOfClass("UIStroke")
			if stroke then
				stroke.Color = isSelected and Color3.fromRGB(0, 140, 255) or palette.MainStroke
				stroke.Thickness = isSelected and 2 or 1
			end
		end
	end
end

local function openSwitcher()
	if #Library.MRUWindows == 0 then return end
	isSwitcherOpen = true
	switcherCurrentIdx = (#Library.MRUWindows >= 2) and 2 or 1
	renderSwitcherCards()
	updateSwitcherSelection()
end

local function cycleSwitcher()
	if not isSwitcherOpen or #Library.MRUWindows == 0 then return end
	switcherCurrentIdx = (switcherCurrentIdx % #Library.MRUWindows) + 1
	updateSwitcherSelection()
end

local function closeSwitcherAndSelect()
	if not isSwitcherOpen then return end
	isSwitcherOpen = false
	SwitcherContainerModern.Visible = false
	SwitcherContainerClassic.Visible = false

	local targetWin = Library.MRUWindows[switcherCurrentIdx]
	if targetWin then
		if targetWin.IsMinimized and targetWin.IsMinimized() then targetWin.Restore() end
		if targetWin.Focus then targetWin.Focus() end
	end
end

local ctrlPressed = false
local isDesktopMinimizedState = false
local desktopMinimizedStack = {}

UserInputService.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then ctrlPressed = true end
	if input.KeyCode == Enum.KeyCode.Tab and ctrlPressed then
		if not isSwitcherOpen then openSwitcher() else cycleSwitcher() end
	end
	if input.KeyCode == Enum.KeyCode.D and ctrlPressed then
		if not isDesktopMinimizedState then
			desktopMinimizedStack = {}
			local anyMinimized = false
			for _, win in ipairs(Library.ActiveWindows) do
				if win.IsMinimized and not win.IsMinimized() then
					table.insert(desktopMinimizedStack, win)
					win.Minimize()
					anyMinimized = true
				end
			end
			if anyMinimized then isDesktopMinimizedState = true end
		else
			for _, win in ipairs(desktopMinimizedStack) do
				if win and win.Restore then win.Restore() end
			end
			desktopMinimizedStack = {}
			isDesktopMinimizedState = false
		end
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
		ctrlPressed = false
		if isSwitcherOpen then closeSwitcherAndSelect() end
	end
end)

--------------------------------------------------------------------------------
-- HÀM DỰNG GIAO DIỆN CHUẨN BUILDER PATTERN (CREATE WINDOW)
--------------------------------------------------------------------------------
function Library:CreateWindow(config, builderCallback)
	config = config or {}
	local route = THEME_ROUTING[Library.CurrentTheme] or THEME_ROUTING["Dark"]
	local themeModule = Library.GetModuleForTheme(Library.CurrentTheme)

	if not themeModule then
		error("[Library] Không thể nạp giao diện với Theme: " .. tostring(Library.CurrentTheme))
		return nil
	end

	if themeModule.Init then
		themeModule.Init(Library)
	end

	local windowRecord = themeModule.CreateWindow(Library, config, route.SubTheme)
	Library.RegisterActiveWindow(windowRecord)

	local reg = {
		Config = config,
		Builder = builderCallback,
		CurrentRecord = windowRecord
	}
	table.insert(Library.RegisteredWindows, reg)

	if builderCallback and type(builderCallback) == "function" then
		builderCallback(windowRecord.API:GetContainer(), windowRecord.API)
	end

	Library.BringToFront(windowRecord.Frame, windowRecord)
	return windowRecord.API
end

--------------------------------------------------------------------------------
-- PROMPT MODAL WINDOW
--------------------------------------------------------------------------------
function Library:Prompt(config)
	config = config or {}
	local title = config.Title or "Thông Báo"
	local message = config.Message or "Bạn có chắc chắn muốn thực hiện hành động này?"
	local buttons = config.Buttons or { { Text = "OK" } }
	local width = config.Width or 290
	local height = config.Height or 135
	local iconAsset = config.Icon

	local win = Library:CreateWindow({
		Title = title,
		Size = UDim2.new(0, width, 0, height),
		Position = UDim2.new(0.5, -width / 2, 0.5, -height / 2),
		MinSize = Vector2.new(width, height),
		MaxSize = Vector2.new(width, height)
	})

	local container = win:GetContainer()
	local isClassic = (Library.CurrentTheme == "Classic" or Library.CurrentTheme == "ClassicV2")

	local hasIcon = (iconAsset and iconAsset ~= "")
	if hasIcon then
		local iconImg = Instance.new("ImageLabel", container)
		iconImg.Name = "PromptIcon"
		iconImg.Size = UDim2.new(0, 32, 0, 32)
		iconImg.Position = UDim2.new(0, 10, 0, 10)
		iconImg.BackgroundTransparency = 1
		iconImg.Image = iconAsset
	end

	local msgLabel = Instance.new("TextLabel", container)
	msgLabel.Name = "Message"
	msgLabel.Size = UDim2.new(1, hasIcon and -58 or -20, 1, -48)
	msgLabel.Position = UDim2.new(0, hasIcon and 48 or 10, 0, 8)
	msgLabel.BackgroundTransparency = 1
	msgLabel.Font = Enum.Font.SourceSans
	msgLabel.TextSize = 14
	msgLabel.TextColor3 = isClassic and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(240, 240, 240)
	msgLabel.TextXAlignment = Enum.TextXAlignment.Left
	msgLabel.TextYAlignment = Enum.TextYAlignment.Top
	msgLabel.TextWrapped = true
	msgLabel.Text = message

	local btnBar = Instance.new("Frame", container)
	btnBar.Name = "ButtonBar"
	btnBar.Size = UDim2.new(1, -20, 0, 26)
	btnBar.Position = UDim2.new(0, 10, 1, -32)
	btnBar.BackgroundTransparency = 1

	local btnCount = math.min(#buttons, 2)
	local btnWidth = 75; local btnHeight = 23; local gap = 8

	for i = 1, btnCount do
		local btnData = buttons[i]
		local btnText = btnData.Text or (i == 1 and "OK" or "Cancel")

		local posX
		if btnCount == 1 then posX = UDim2.new(0.5, -btnWidth / 2, 0, 0)
		else
			local totalWidth = (btnWidth * 2) + gap
			if i == 1 then posX = UDim2.new(1, -totalWidth, 0, 0)
			else posX = UDim2.new(1, -btnWidth, 0, 0) end
		end

		local btn = Instance.new("TextButton", btnBar)
		btn.Size = UDim2.new(0, btnWidth, 0, btnHeight)
		btn.Position = posX
		btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(0, 120, 215) or Color3.fromRGB(60, 60, 60)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.SourceSansSemibold
		btn.TextSize = 13
		btn.Text = btnText
		btn.BorderSizePixel = 0
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

		btn.MouseButton1Click:Connect(function()
			win:Close()
			if btnData.Callback then btnData.Callback() end
		end)
	end

	return win
end

--------------------------------------------------------------------------------
-- TOAST NOTIFICATION
--------------------------------------------------------------------------------
function Library:Notify(config)
	config = config or {}
	local title = config.Title or "Notification"
	local sub = config.Subtitle or ""
	local duration = config.Duration or 4
	local iconAsset = config.Icon

	local route = THEME_ROUTING[Library.CurrentTheme] or THEME_ROUTING["Dark"]
	local currentModule = Library.LoadedModules[route.File]
	local palette = (currentModule and currentModule.Palettes and currentModule.Palettes[route.SubTheme]) or {
		NotiBackground = Color3.fromRGB(25, 25, 25),
		NotiStroke = Color3.fromRGB(55, 55, 55),
		NotiTitle = Color3.fromRGB(255, 255, 255),
		NotiSubtitle = Color3.fromRGB(200, 200, 200),
		NotiCloseIcon = Color3.fromRGB(220, 220, 220)
	}

	local NotiFrame = Instance.new("Frame", NotificationGui)
	NotiFrame.Name = "Template_Noti"
	NotiFrame.BorderSizePixel = 0
	NotiFrame.BackgroundColor3 = palette.NotiBackground
	NotiFrame.Size = UDim2.new(0, 280, 0, 0)
	NotiFrame.AutomaticSize = Enum.AutomaticSize.Y
	Instance.new("UICorner", NotiFrame).CornerRadius = UDim.new(0, 6)

	local Stroke = Instance.new("UIStroke", NotiFrame)
	Stroke.Color = palette.NotiStroke

	local Padding = Instance.new("UIPadding", NotiFrame)
	Padding.PaddingTop = UDim.new(0, 10); Padding.PaddingBottom = UDim.new(0, 10)
	Padding.PaddingLeft = UDim.new(0, 12); Padding.PaddingRight = UDim.new(0, 12)

	local ContentFrame = Instance.new("Frame", NotiFrame)
	ContentFrame.BackgroundTransparency = 1
	ContentFrame.Size = UDim2.new(1, 0, 0, 0)
	ContentFrame.AutomaticSize = Enum.AutomaticSize.Y

	local ContentLayout = Instance.new("UIListLayout", ContentFrame)
	ContentLayout.FillDirection = Enum.FillDirection.Horizontal
	ContentLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	ContentLayout.Padding = UDim.new(0, 10)

	if iconAsset and iconAsset ~= "" then
		local Icon = Instance.new("ImageLabel", ContentFrame)
		Icon.Name = "ICON"
		Icon.BackgroundTransparency = 1
		Icon.LayoutOrder = 1
		Icon.Size = UDim2.new(0, 36, 0, 36)
		Icon.Image = iconAsset
		Instance.new("UICorner", Icon).CornerRadius = UDim.new(0, 4)
	end

	local MainNoti = Instance.new("Frame", ContentFrame)
	MainNoti.Name = "MainNoti"
	MainNoti.BackgroundTransparency = 1
	MainNoti.LayoutOrder = 2
	MainNoti.Size = UDim2.new(1, (iconAsset and iconAsset ~= "") and -46 or 0, 0, 0)
	MainNoti.AutomaticSize = Enum.AutomaticSize.Y

	local MainLayout = Instance.new("UIListLayout", MainNoti)
	MainLayout.SortOrder = Enum.SortOrder.LayoutOrder
	MainLayout.Padding = UDim.new(0, 2)

	local TitleLabel = Instance.new("TextLabel", MainNoti)
	TitleLabel.Name = "Title"
	TitleLabel.LayoutOrder = 1
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.TextSize = 14
	TitleLabel.TextWrapped = true
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.TextColor3 = palette.NotiTitle
	TitleLabel.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
	TitleLabel.Text = title
	TitleLabel.Size = UDim2.new(1, -20, 0, 0)
	TitleLabel.AutomaticSize = Enum.AutomaticSize.Y

	if sub and sub ~= "" then
		local SubLabel = Instance.new("TextLabel", MainNoti)
		SubLabel.Name = "Subtitle"
		SubLabel.LayoutOrder = 2
		SubLabel.BackgroundTransparency = 1
		SubLabel.TextSize = 13
		SubLabel.TextWrapped = true
		SubLabel.TextXAlignment = Enum.TextXAlignment.Left
		SubLabel.TextColor3 = palette.NotiSubtitle
		SubLabel.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
		SubLabel.Text = sub
		SubLabel.Size = UDim2.new(1, -20, 0, 0)
		SubLabel.AutomaticSize = Enum.AutomaticSize.Y
	end

	local CloseBtn = Instance.new("ImageButton", NotiFrame)
	CloseBtn.Name = "Close"
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.AnchorPoint = Vector2.new(1, 0)
	CloseBtn.Position = UDim2.new(1, 0, 0, 0)
	CloseBtn.Size = UDim2.new(0, 18, 0, 18)

	local CloseImg = Instance.new("ImageLabel", CloseBtn)
	CloseImg.BackgroundTransparency = 1
	CloseImg.AnchorPoint = Vector2.new(0.5, 0.5)
	CloseImg.Position = UDim2.new(0.5, 0, 0.5, 0)
	CloseImg.Size = UDim2.new(0, 12, 0, 12)
	CloseImg.Image = "rbxassetid://11293981586"
	CloseImg.ImageColor3 = palette.NotiCloseIcon

	CloseBtn.MouseButton1Click:Connect(function() NotiFrame:Destroy() end)
	task.delay(duration, function()
		if NotiFrame and NotiFrame.Parent then NotiFrame:Destroy() end
	end)
end

function Library:GetNonUser() return NonUserGui end
function Library:GetCustomOpenUI() return CustomOpenGui end
function Library:GetContextMenuGui() return ContextMenuGui end

return Library
