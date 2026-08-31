-- Main.lua (Core Hub - khngsml0-cmd/WindowLib_Theme)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

local GITHUB_RAW_BASE = "https://raw.githubusercontent.com/khngsml0-cmd/WindowLib_Theme/main/Themes/"

local THEME_MAP = {
	Dark    = { Module = "Modern",  SubTheme = "Dark" },
	Light   = { Module = "Modern",  SubTheme = "Light" },
	Classic = { Module = "Classic", SubTheme = "Classic" },
}

--------------------------------------------------------------------------------
-- 1. ROOT GUI & PHÂN CẤP NONUSER
--------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------
-- 2. DRAG OUTLINE & AERO SNAP GHOST
--------------------------------------------------------------------------------
local isGlobalOutlineDrag = false

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

--------------------------------------------------------------------------------
-- 3. CORE CONTEXT
--------------------------------------------------------------------------------
local Core = {
	NonUserGui = NonUserGui,
	SystemGui = SystemGui,
	CustomOpenGui = CustomOpenGui,
	RootParent = RootParent,
	DragOutlineFrame = DragOutlineFrame,
	CurrentZIndex = 10,
	CurrentModuleType = "Modern",
	ActiveWindows = {},
	MruWindows = {},
	MinimizedWindows = {},
	FocusedWindow = nil,
	CascadeState = { startX = 50, startY = 50, currentX = 50, currentY = 50, stepX = 30, stepY = 30, columnStartX = 50, columnStepX = 180 }
}

function Core.GetNextZIndex()
	Core.CurrentZIndex = Core.CurrentZIndex + 1
	return Core.CurrentZIndex
end

function Core.BringToFront(frame, winRecord)
	if frame.ZIndex < Core.CurrentZIndex then
		Core.CurrentZIndex = Core.CurrentZIndex + 1
		frame.ZIndex = Core.CurrentZIndex
	end
	if winRecord then Core.SetFocus(winRecord) end
end

function Core.SetFocus(winRecord)
	if Core.FocusedWindow == winRecord then return end
	if Core.FocusedWindow and Core.FocusedWindow.SetFocusVisual then
		Core.FocusedWindow.SetFocusVisual(false)
	end
	Core.FocusedWindow = winRecord
	if winRecord then
		if winRecord.SetFocusVisual then winRecord.SetFocusVisual(true) end
		for i, w in ipairs(Core.MruWindows) do
			if w == winRecord then table.remove(Core.MruWindows, i); break end
		end
		table.insert(Core.MruWindows, 1, winRecord)
	end
	if Core.ActiveThemeModule and Core.ActiveThemeModule.UpdateTaskbar then
		Core.ActiveThemeModule.UpdateTaskbar(Core)
	end
end

function Core.UnregisterActiveWindow(winRecord)
	for i, w in ipairs(Core.ActiveWindows) do
		if w == winRecord then table.remove(Core.ActiveWindows, i); break end
	end
	for i, w in ipairs(Core.MruWindows) do
		if w == winRecord then table.remove(Core.MruWindows, i); break end
	end
	if Core.FocusedWindow == winRecord then
		Core.FocusedWindow = nil
		if #Core.ActiveWindows > 0 then Core.SetFocus(Core.ActiveWindows[#Core.ActiveWindows]) end
	end
end

function Core.RegisterMinimized(winRecord)
	table.insert(Core.MinimizedWindows, winRecord)
	Core.UpdateMinimizedGrid()
end

function Core.UnregisterMinimized(winRecord)
	for i, w in ipairs(Core.MinimizedWindows) do
		if w == winRecord then table.remove(Core.MinimizedWindows, i); break end
	end
	Core.UpdateMinimizedGrid()
end

function Core.UpdateMinimizedGrid()
	local TWEEN_INFO_SMOOTH = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
	local itemW = 180; local itemH = 28; local pad = 6; local marginX = 10; local marginY = 10
	local groups = {}
	for _, win in ipairs(Core.MinimizedWindows) do
		local p = win.TargetParent or Core.NonUserGui
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

			TweenService:Create(win.Frame, TWEEN_INFO_SMOOTH, {
				Position = UDim2.new(0, targetX, 1, targetYOffset),
				Size = UDim2.new(0, itemW, 0, itemH)
			}):Play()
		end
	end
end

function Core.GetNextCascadePosition(defaultSize, parent)
	if parent ~= NonUserGui then return UDim2.new(0, 20, 0, 20) end
	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
	local winW = defaultSize.X.Offset > 0 and defaultSize.X.Offset or 500
	local winH = defaultSize.Y.Offset > 0 and defaultSize.Y.Offset or 350
	local posX = Core.CascadeState.currentX; local posY = Core.CascadeState.currentY

	if posY + winH > viewport.Y - 50 then
		Core.CascadeState.columnStartX = Core.CascadeState.columnStartX + Core.CascadeState.columnStepX
		posX = Core.CascadeState.columnStartX; posY = Core.CascadeState.startY
		Core.CascadeState.currentX = posX; Core.CascadeState.currentY = posY
	end
	if posX + winW > viewport.X - 30 then
		Core.CascadeState.columnStartX = Core.CascadeState.startX
		posX = Core.CascadeState.startX; posY = Core.CascadeState.startY
		Core.CascadeState.currentX = posX; Core.CascadeState.currentY = posY
	end

	Core.CascadeState.currentX = Core.CascadeState.currentX + Core.CascadeState.stepX
	Core.CascadeState.currentY = Core.CascadeState.currentY + Core.CascadeState.stepY
	return UDim2.new(0, posX, 0, posY)
end

function Core.ShowSnapGhost(pos, size)
	SnapGhostFrame.Visible = true
	TweenService:Create(SnapGhostFrame, TweenInfo.new(0.15), {Position = pos, Size = size, BackgroundTransparency = 0.88}):Play()
	for _, edge in ipairs({snapTop, snapBottom, snapLeft, snapRight}) do
		TweenService:Create(edge, TweenInfo.new(0.15), {ImageTransparency = 0.1}):Play()
	end
end

function Core.HideSnapGhost()
	local t = TweenService:Create(SnapGhostFrame, TweenInfo.new(0.15), {BackgroundTransparency = 1})
	for _, edge in ipairs({snapTop, snapBottom, snapLeft, snapRight}) do
		TweenService:Create(edge, TweenInfo.new(0.15), {ImageTransparency = 1}):Play()
	end
	t:Play()
	t.Completed:Connect(function()
		if SnapGhostFrame.BackgroundTransparency >= 0.99 then SnapGhostFrame.Visible = false end
	end)
end

function Core.IsGlobalOutlineDrag() return isGlobalOutlineDrag end

--------------------------------------------------------------------------------
-- 4. CONTEXT MENU SYSTEM GỐC
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

local function renderContextMenuFrame(pos, items, level, parentBtnWidth)
	level = level or 1
	clearSubmenusFromLevel(level)

	local isClassic = (Core.CurrentModuleType == "Classic")
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
	for _, item in ipairs(items or {}) do
		totalContentHeight = totalContentHeight + ((item.Type == "Separator") and sepHeight or itemHeight)
	end

	local totalGaps = math.max(0, #items - 1) * itemSpacing
	local totalMenuHeight = totalContentHeight + totalGaps + padTop + padBottom

	local menuFrame = Instance.new("ImageButton", ContextMenuGui)
	menuFrame.Name = "ContextMenuLevel_" .. level
	menuFrame.BorderSizePixel = 0
	menuFrame.AutoButtonColor = false
	menuFrame.BackgroundColor3 = isClassic and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(35, 35, 35)
	menuFrame.Size = UDim2.new(0, menuWidth, 0, totalMenuHeight)
	menuFrame.ZIndex = 999900 + level

	if isClassic then
		local border = Instance.new("Frame", menuFrame)
		border.Name = "Border"; border.BorderSizePixel = 0; border.BackgroundTransparency = 1
		border.AnchorPoint = Vector2.new(0.5, 0.5); border.Size = UDim2.new(1, 5, 1, 5); border.Position = UDim2.new(0.5, 0, 0.5, 0)
	else
		Instance.new("UICorner", menuFrame).CornerRadius = UDim.new(0, 6)
		local stroke = Instance.new("UIStroke", menuFrame)
		stroke.Color = Color3.fromRGB(60, 60, 60)
	end

	local padding = Instance.new("UIPadding", menuFrame)
	padding.PaddingTop = UDim.new(0, padTop); padding.PaddingBottom = UDim.new(0, padBottom)
	padding.PaddingLeft = UDim.new(0, padLeft); padding.PaddingRight = UDim.new(0, padRight)

	local listContainer = Instance.new("Frame", menuFrame)
	listContainer.BackgroundTransparency = 1; listContainer.Size = UDim2.new(1, 0, 1, 0); listContainer.ZIndex = menuFrame.ZIndex + 1

	local layout = Instance.new("UIListLayout", listContainer)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, itemSpacing)

	local camera = workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
	local finalX = pos.X; local finalY = pos.Y

	if finalX + menuWidth > viewport.X - 10 then
		finalX = (level > 1 and parentBtnWidth) and math.max(10, pos.X - parentBtnWidth - menuWidth - 4) or math.max(10, pos.X - menuWidth)
	end
	if finalY + totalMenuHeight > viewport.Y - 10 then
		finalY = math.max(10, viewport.Y - totalMenuHeight - 10)
	end

	menuFrame.Position = UDim2.new(0, finalX, 0, finalY)
	table.insert(activeSubmenuFrames, menuFrame)

	local itemDefaultBg = isClassic and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(35, 35, 35)
	local itemHoverBg = isClassic and Color3.fromRGB(225, 225, 225) or Color3.fromRGB(40, 90, 150)
	local currentYOffset = finalY + padTop

	for itemIndex, item in ipairs(items or {}) do
		local thisItemY = currentYOffset
		local thisItemH = (item.Type == "Separator") and sepHeight or itemHeight

		if item.Type == "Separator" then
			local Sep = Instance.new("Frame", listContainer)
			Sep.BackgroundTransparency = 1; Sep.Size = UDim2.new(1, 0, 0, sepHeight)
			local LineFrame = Instance.new("Frame", Sep)
			LineFrame.BorderSizePixel = 0
			LineFrame.BackgroundColor3 = isClassic and Color3.fromRGB(171, 171, 171) or Color3.fromRGB(70, 70, 70)
			LineFrame.AnchorPoint = Vector2.new(0.5, 0.5); LineFrame.Position = UDim2.new(0.5, 0, 0.5, 0); LineFrame.Size = UDim2.new(1, -6, 0, 1)
		elseif item.Type == "Button" then
			local Btn = Instance.new("TextButton", listContainer)
			Btn.BorderSizePixel = 0; Btn.AutoButtonColor = false; Btn.BackgroundColor3 = itemDefaultBg
			Btn.Size = UDim2.new(1, 0, 0, itemHeight); Btn.Text = ""
			if not isClassic then Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4) end

			local Text = Instance.new("TextLabel", Btn)
			Text.BackgroundTransparency = 1; Text.TextSize = 13; Text.TextXAlignment = Enum.TextXAlignment.Left
			Text.TextColor3 = item.Disabled and (isClassic and Color3.fromRGB(101, 101, 101) or Color3.fromRGB(140, 140, 140)) or (isClassic and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(240, 240, 240))
			Text.Font = font; Text.Size = UDim2.new(1, 0, 1, 0); Text.Text = item.Text or ""
			local Pad = Instance.new("UIPadding", Text); Pad.PaddingLeft = UDim.new(0, 8); Pad.PaddingRight = UDim.new(0, 8)

			if not item.Disabled then
				Btn.MouseEnter:Connect(function() Btn.BackgroundColor3 = itemHoverBg; if not isClassic then Text.TextColor3 = Color3.fromRGB(255, 255, 255) end end)
				Btn.MouseLeave:Connect(function() Btn.BackgroundColor3 = itemDefaultBg; if not isClassic then Text.TextColor3 = Color3.fromRGB(240, 240, 240) end end)
				Btn.MouseButton1Click:Connect(function() clearSubmenusFromLevel(1); if item.Callback then item.Callback() end end)
			end
		end
		currentYOffset = currentYOffset + thisItemH + itemSpacing
	end
	return menuFrame
end

Core.RenderContextMenu = renderContextMenuFrame
Core.ClearSubmenus = clearSubmenusFromLevel

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if #activeSubmenuFrames > 0 then
			local rawMousePos = UserInputService:GetMouseLocation()
			local mousePos = Vector2.new(rawMousePos.X, rawMousePos.Y - GuiService:GetGuiInset().Y)
			local clickedInside = false
			for _, f in ipairs(activeSubmenuFrames) do
				if f and f.Parent then
					local p = f.AbsolutePosition; local s = f.AbsoluteSize
					if mousePos.X >= p.X and mousePos.X <= p.X + s.X and mousePos.Y >= p.Y and mousePos.Y <= p.Y + s.Y then
						clickedInside = true; break
					end
				end
			end
			if not clickedInside then clearSubmenusFromLevel(1) end
		end
	end
end)

--------------------------------------------------------------------------------
-- 5. MAIN LIBRARY & GITHUB THEME ENGINE (AUTO LOAD MODERN)
--------------------------------------------------------------------------------
local Library = {
	CurrentThemeName = "Dark",
	LoadedModules = {},
	RegisteredWindows = {},
	ActiveThemeModule = nil,
	OnThemeChanged = Instance.new("BindableEvent")
}

function Library:FetchModule(moduleName)
	if self.LoadedModules[moduleName] then return self.LoadedModules[moduleName] end

	local url = GITHUB_RAW_BASE .. moduleName .. ".lua?t=" .. tick()
	local success, response = pcall(function() return game:HttpGet(url) end)

	if not success or not response or response:find("404: Not Found") or response:find("<html") then
		warn("[UI Core] Không tìm thấy file " .. moduleName .. ".lua trên GitHub!")
		return nil
	end

	local loadFunc, syntaxErr = loadstring(response)
	if not loadFunc then
		warn("[UI Core] Lỗi cú pháp trong file (" .. moduleName .. ".lua):", syntaxErr)
		return nil
	end

	local execSuccess, moduleTable = pcall(loadFunc)
	if execSuccess and type(moduleTable) == "table" and moduleTable.CreateWindow then
		self.LoadedModules[moduleName] = moduleTable
		return moduleTable
	else
		warn("[UI Core] File " .. moduleName .. " không trả về bảng hợp lệ!")
		return nil
	end
end

function Library:EnsureDefaultThemeLoaded()
	if self.ActiveThemeModule then return end
	local targetInfo = THEME_MAP[self.CurrentThemeName] or THEME_MAP.Dark
	local moduleObj = self:FetchModule(targetInfo.Module)
	if moduleObj then
		self.ActiveThemeModule = moduleObj
		Core.CurrentModuleType = moduleObj.Type
		Core.ActiveThemeModule = moduleObj
		if moduleObj.Init then moduleObj.Init(Core) end
	end
end

function Library:SetTheme(targetThemeName)
	local targetInfo = THEME_MAP[targetThemeName]
	if not targetInfo then return end

	local targetModuleName = targetInfo.Module
	local subTheme = targetInfo.SubTheme
	local moduleObj = self:FetchModule(targetModuleName)
	if not moduleObj then return end

	local isSameArchetype = (Core.CurrentModuleType == moduleObj.Type)

	if self.ActiveThemeModule and self.ActiveThemeModule.Cleanup and not isSameArchetype then
		self.ActiveThemeModule.Cleanup(Core)
	end

	self.CurrentThemeName = targetThemeName
	self.ActiveThemeModule = moduleObj
	Core.CurrentModuleType = moduleObj.Type
	Core.ActiveThemeModule = moduleObj

	if moduleObj.Init and not isSameArchetype then
		moduleObj.Init(Core)
	end

	if isSameArchetype then
		local pal = moduleObj.Palettes[subTheme]
		for _, win in ipairs(Core.ActiveWindows) do
			if win.UpdateTheme then win.UpdateTheme(pal) end
		end
	else
		for _, win in ipairs(Core.ActiveWindows) do
			if win.Frame and win.Frame.Parent then win.Frame:Destroy() end
		end
		Core.ActiveWindows = {}
		Core.MruWindows = {}
		Core.MinimizedWindows = {}
		Core.FocusedWindow = nil

		for _, item in ipairs(self.RegisteredWindows) do
			local winRecord = moduleObj.CreateWindow(Core, item.Config, subTheme)
			table.insert(Core.ActiveWindows, winRecord)
			table.insert(Core.MruWindows, 1, winRecord)
			if item.Builder and type(item.Builder) == "function" then
				item.Builder(winRecord.API:GetContainer(), winRecord.API)
			end
		end
	end

	self.OnThemeChanged:Fire(targetThemeName)
end

function Library:CreateWindow(config, builderCallback)
	config = config or {}
	self:EnsureDefaultThemeLoaded()

	local targetInfo = THEME_MAP[self.CurrentThemeName] or THEME_MAP.Dark
	local moduleObj = self.ActiveThemeModule

	local registryItem = { Config = config, Builder = builderCallback }
	table.insert(self.RegisteredWindows, registryItem)

	local winRecord = moduleObj.CreateWindow(Core, config, targetInfo.SubTheme)
	table.insert(Core.ActiveWindows, winRecord)
	table.insert(Core.MruWindows, 1, winRecord)
	Core.SetFocus(winRecord)

	if builderCallback and type(builderCallback) == "function" then
		builderCallback(winRecord.API:GetContainer(), winRecord.API)
	end

	return winRecord.API
end

function Library:Notify(config)
	config = config or {}
	local title = config.Title or "Notification"
	local sub = config.Subtitle or ""
	local duration = config.Duration or 4

	local noti = Instance.new("Frame", NotificationGui)
	noti.BorderSizePixel = 0; noti.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	noti.Size = UDim2.new(0, 280, 0, 0); noti.AutomaticSize = Enum.AutomaticSize.Y
	Instance.new("UICorner", noti).CornerRadius = UDim.new(0, 6)
	local strk = Instance.new("UIStroke", noti); strk.Color = Color3.fromRGB(55, 55, 55)

	local pad = Instance.new("UIPadding", noti)
	pad.PaddingTop = UDim.new(0, 10); pad.PaddingBottom = UDim.new(0, 10); pad.PaddingLeft = UDim.new(0, 12); pad.PaddingRight = UDim.new(0, 12)

	local tLbl = Instance.new("TextLabel", noti)
	tLbl.BackgroundTransparency = 1; tLbl.Font = Enum.Font.GothamBold; tLbl.TextSize = 14
	tLbl.TextColor3 = Color3.fromRGB(255, 255, 255); tLbl.TextXAlignment = Enum.TextXAlignment.Left
	tLbl.Text = title; tLbl.Size = UDim2.new(1, 0, 0, 16)

	if sub ~= "" then
		local sLbl = Instance.new("TextLabel", noti)
		sLbl.BackgroundTransparency = 1; sLbl.Font = Enum.Font.Gotham; sLbl.TextSize = 13
		sLbl.TextColor3 = Color3.fromRGB(200, 200, 200); sLbl.TextXAlignment = Enum.TextXAlignment.Left
		sLbl.TextWrapped = true; sLbl.Text = sub; sLbl.Position = UDim2.new(0, 0, 0, 18)
		sLbl.Size = UDim2.new(1, 0, 0, 0); sLbl.AutomaticSize = Enum.AutomaticSize.Y
	end

	task.delay(duration, function()
		if noti and noti.Parent then noti:Destroy() end
	end)
end

function Library:GetNonUser() return NonUserGui end
function Library:GetCustomOpenUI() return CustomOpenGui end

Library:EnsureDefaultThemeLoaded()
return Library
