-- Main.lua (Core Hub)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

-- CẤU HÌNH GITHUB CỦA BẠN (Thay User và Repo của bạn vào đây)
local GITHUB_RAW_BASE = "https://raw.githubusercontent.com/<YOUR_USER>/<YOUR_REPO>/main/Themes/"

local THEME_MAP = {
	Dark    = { Module = "Modern",  SubTheme = "Dark" },
	Light   = { Module = "Modern",  SubTheme = "Light" },
	Classic = { Module = "Classic", SubTheme = "Classic" },
}

--------------------------------------------------------------------------------
-- 1. ROOT AN TOÀN & CÁC LỚP SCREEN GUI
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
SystemGui.Name = "SYSTEM_CORE"
SystemGui.IgnoreGuiInset = true
SystemGui.ResetOnSpawn = false
SystemGui.DisplayOrder = BASE_DISPLAY_ORDER
SystemGui.Parent = RootParent

local NonUserGui = Instance.new("ScreenGui")
NonUserGui.Name = "NonUser"
NonUserGui.IgnoreGuiInset = true
NonUserGui.DisplayOrder = BASE_DISPLAY_ORDER + 500
NonUserGui.ResetOnSpawn = false
NonUserGui.Parent = SystemGui

local CustomOpenGui = Instance.new("ScreenGui")
CustomOpenGui.Name = "CustomOpenUI"
CustomOpenGui.IgnoreGuiInset = true
CustomOpenGui.DisplayOrder = BASE_DISPLAY_ORDER + 600
CustomOpenGui.ResetOnSpawn = false
CustomOpenGui.Parent = SystemGui

local ContextMenuGui = Instance.new("ScreenGui")
ContextMenuGui.Name = "SYSTEM_ContextMenu"
ContextMenuGui.IgnoreGuiInset = true
ContextMenuGui.DisplayOrder = BASE_DISPLAY_ORDER + 999900
ContextMenuGui.ResetOnSpawn = false
ContextMenuGui.Parent = SystemGui

local NotificationGui = Instance.new("ScreenGui")
NotificationGui.Name = "SYSTEM_Notification"
NotificationGui.IgnoreGuiInset = true
NotificationGui.DisplayOrder = BASE_DISPLAY_ORDER + 999999
NotificationGui.ResetOnSpawn = false
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
-- 2. HIỆU ỨNG AERO SNAP & DRAG OUTLINE TOÀN CỤC
--------------------------------------------------------------------------------
local isGlobalOutlineDrag = false

local DragOutlineFrame = Instance.new("Frame", SystemGui)
DragOutlineFrame.Name = "DragOutlineFrame"
DragOutlineFrame.BorderSizePixel = 0
DragOutlineFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
DragOutlineFrame.BackgroundTransparency = 0.85
DragOutlineFrame.Visible = false
DragOutlineFrame.ZIndex = 99998
Instance.new("UICorner", DragOutlineFrame).CornerRadius = UDim.new(0, 6)

local DragOutlineStroke = Instance.new("UIStroke", DragOutlineFrame)
DragOutlineStroke.Color = Color3.fromRGB(50, 50, 50)
DragOutlineStroke.Thickness = 2

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
-- 3. CORE CONTEXT TRUYỀN CHO CÁC THEME
--------------------------------------------------------------------------------
local Core = {
	NonUserGui = NonUserGui,
	SystemGui = SystemGui,
	CustomOpenGui = CustomOpenGui,
	RootParent = RootParent,
	DragOutlineFrame = DragOutlineFrame,
	CurrentZIndex = 10,
	ActiveWindows = {},
	MruWindows = {},
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
	if winRecord then
		Core.SetFocus(winRecord)
	end
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
-- 4. CONTEXT MENU ENGINE
--------------------------------------------------------------------------------
local activeSubmenuFrames = {}

local function clearSubmenus(level)
	for i = #activeSubmenuFrames, level or 1, -1 do
		if activeSubmenuFrames[i] then
			activeSubmenuFrames[i]:Destroy()
			table.remove(activeSubmenuFrames, i)
		end
	end
end

local function renderContextMenu(pos, items, level, parentWidth, palette)
	level = level or 1
	clearSubmenus(level)
	palette = palette or {
		ContextMenuBackground = Color3.fromRGB(35, 35, 35),
		ContextMenuStroke = Color3.fromRGB(60, 60, 60),
		ContextItemDefault = Color3.fromRGB(35, 35, 35),
		ContextItemHover = Color3.fromRGB(40, 90, 150),
		ContextItemText = Color3.fromRGB(240, 240, 240),
		ContextItemTextDisabled = Color3.fromRGB(140, 140, 140),
		ContextItemSeparator = Color3.fromRGB(70, 70, 70),
	}

	local itemHeight = 24; local sepHeight = 10; local itemSpacing = 2
	local maxW = 180

	for _, it in ipairs(items or {}) do
		if it.Type ~= "Separator" then
			local sz = TextService:GetTextSize(it.Text or "", 13, Enum.Font.Gotham, Vector2.new(2000, 50))
			local w = math.ceil(sz.X * 1.1) + 40
			if w > maxW then maxW = w end
		end
	end

	local totalH = 8
	for _, it in ipairs(items or {}) do
		totalH = totalH + (it.Type == "Separator" and sepHeight or itemHeight) + itemSpacing
	end

	local menu = Instance.new("ImageButton", ContextMenuGui)
	menu.BorderSizePixel = 0
	menu.BackgroundColor3 = palette.ContextMenuBackground
	menu.Size = UDim2.new(0, maxW, 0, totalH)
	menu.Position = UDim2.new(0, pos.X, 0, pos.Y)
	menu.ZIndex = 999900 + level
	Instance.new("UICorner", menu).CornerRadius = UDim.new(0, 6)
	local strk = Instance.new("UIStroke", menu)
	strk.Color = palette.ContextMenuStroke

	local pad = Instance.new("UIPadding", menu)
	pad.PaddingTop = UDim.new(0, 4); pad.PaddingBottom = UDim.new(0, 4); pad.PaddingLeft = UDim.new(0, 4); pad.PaddingRight = UDim.new(0, 4)

	local list = Instance.new("UIListLayout", menu)
	list.Padding = UDim.new(0, itemSpacing)

	for _, it in ipairs(items or {}) do
		if it.Type == "Separator" then
			local sep = Instance.new("Frame", menu)
			sep.BackgroundTransparency = 1; sep.Size = UDim2.new(1, 0, 0, sepHeight)
			local line = Instance.new("Frame", sep)
			line.BorderSizePixel = 0; line.BackgroundColor3 = palette.ContextItemSeparator
			line.Size = UDim2.new(1, -6, 0, 1); line.Position = UDim2.new(0.5, 0, 0.5, 0); line.AnchorPoint = Vector2.new(0.5, 0.5)
		else
			local btn = Instance.new("TextButton", menu)
			btn.BorderSizePixel = 0; btn.BackgroundColor3 = palette.ContextItemDefault
			btn.Size = UDim2.new(1, 0, 0, itemHeight); btn.Text = ""
			Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

			local txt = Instance.new("TextLabel", btn)
			txt.BackgroundTransparency = 1; txt.Size = UDim2.new(1, -16, 1, 0); txt.Position = UDim2.new(0, 8, 0, 0)
			txt.Font = Enum.Font.Gotham; txt.TextSize = 13; txt.TextXAlignment = Enum.TextXAlignment.Left
			txt.Text = it.Text or ""; txt.TextColor3 = it.Disabled and palette.ContextItemTextDisabled or palette.ContextItemText

			if not it.Disabled then
				btn.MouseEnter:Connect(function() btn.BackgroundColor3 = palette.ContextItemHover; txt.TextColor3 = Color3.fromRGB(255, 255, 255) end)
				btn.MouseLeave:Connect(function() btn.BackgroundColor3 = palette.ContextItemDefault; txt.TextColor3 = palette.ContextItemText end)
				btn.MouseButton1Click:Connect(function()
					clearSubmenus(1)
					if it.Callback then it.Callback() end
				end)
			end
		end
	end

	table.insert(activeSubmenuFrames, menu)
	return menu
end

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		if #activeSubmenuFrames > 0 then
			local mousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
			local clickedInside = false
			for _, f in ipairs(activeSubmenuFrames) do
				if f and f.Parent then
					local p = f.AbsolutePosition; local s = f.AbsoluteSize
					if mousePos.X >= p.X and mousePos.X <= p.X + s.X and mousePos.Y >= p.Y and mousePos.Y <= p.Y + s.Y then
						clickedInside = true; break
					end
				end
			end
			if not clickedInside then clearSubmenus(1) end
		end
	end
end)

--------------------------------------------------------------------------------
-- 5. MAIN LIBRARY & GITHUB THEME ENGINE (AUTO LOAD MODERN)
--------------------------------------------------------------------------------
local Library = {
	CurrentThemeName = "Dark",
	CurrentModuleType = nil,
	LoadedModules = {},
	RegisteredWindows = {},
	ActiveThemeModule = nil,
	OnThemeChanged = Instance.new("BindableEvent")
}

function Library:FetchModule(moduleName)
	if self.LoadedModules[moduleName] then return self.LoadedModules[moduleName] end

	local url = GITHUB_RAW_BASE .. moduleName .. ".lua?t=" .. tick()
	local success, response = pcall(function() return game:HttpGet(url) end)

	if not success or not response then
		warn("[UI Core] Không thể tải Theme:", moduleName, "từ GitHub! Đường dẫn:", url)
		return nil
	end

	local loadSuccess, moduleTable = pcall(function() return loadstring(response)() end)
	if loadSuccess and type(moduleTable) == "table" then
		self.LoadedModules[moduleName] = moduleTable
		return moduleTable
	else
		warn("[UI Core] Lỗi cú pháp khi nạp Module Theme:", moduleName)
		return nil
	end
end

-- Tự động đảm bảo đã nạp Theme mặc định
function Library:EnsureDefaultThemeLoaded()
	if self.ActiveThemeModule then return end
	local targetInfo = THEME_MAP[self.CurrentThemeName] or THEME_MAP.Dark
	local moduleObj = self:FetchModule(targetInfo.Module)
	if moduleObj then
		self.ActiveThemeModule = moduleObj
		self.CurrentModuleType = moduleObj.Type
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

	local isSameArchetype = (self.CurrentModuleType == moduleObj.Type)

	if self.ActiveThemeModule and self.ActiveThemeModule.Cleanup and not isSameArchetype then
		self.ActiveThemeModule.Cleanup(Core)
	end

	self.CurrentThemeName = targetThemeName
	self.ActiveThemeModule = moduleObj
	self.CurrentModuleType = moduleObj.Type

	if moduleObj.Init and not isSameArchetype then
		moduleObj.Init(Core)
	end

	if isSameArchetype then
		-- Cùng Engine (VD: Dark <-> Light): Hot-swap Palette cực mượt
		for _, win in ipairs(Core.ActiveWindows) do
			if win.UpdatePalette then win.UpdatePalette(subTheme) end
		end
	else
		-- Khác Engine (VD: Modern <-> Classic): Rebuild sạch sẽ
		for _, win in ipairs(Core.ActiveWindows) do
			if win.Frame and win.Frame.Parent then win.Frame:Destroy() end
		end
		Core.ActiveWindows = {}
		Core.MruWindows = {}
		Core.FocusedWindow = nil

		for _, item in ipairs(self.RegisteredWindows) do
			local winAPI = moduleObj.CreateWindow(Core, item.Config, subTheme)
			table.insert(Core.ActiveWindows, winAPI)
			table.insert(Core.MruWindows, 1, winAPI)
			if item.Builder and type(item.Builder) == "function" then
				item.Builder(winAPI:GetContainer(), winAPI)
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

	local winAPI = moduleObj.CreateWindow(Core, config, targetInfo.SubTheme)
	table.insert(Core.ActiveWindows, winAPI)
	table.insert(Core.MruWindows, 1, winAPI)
	Core.SetFocus(winAPI)

	if builderCallback and type(builderCallback) == "function" then
		builderCallback(winAPI:GetContainer(), winAPI)
	end

	return winAPI
end

function Library:Notify(config)
	config = config or {}
	local title = config.Title or "Thông báo"
	local sub = config.Subtitle or ""
	local duration = config.Duration or 4

	local noti = Instance.new("Frame", NotificationGui)
	noti.BorderSizePixel = 0; noti.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	noti.Size = UDim2.new(0, 260, 0, 0); noti.AutomaticSize = Enum.AutomaticSize.Y
	Instance.new("UICorner", noti).CornerRadius = UDim.new(0, 6)
	local strk = Instance.new("UIStroke", noti); strk.Color = Color3.fromRGB(55, 55, 55)

	local pad = Instance.new("UIPadding", noti)
	pad.PaddingTop = UDim.new(0, 8); pad.PaddingBottom = UDim.new(0, 8); pad.PaddingLeft = UDim.new(0, 10); pad.PaddingRight = UDim.new(0, 10)

	local tLbl = Instance.new("TextLabel", noti)
	tLbl.BackgroundTransparency = 1; tLbl.Font = Enum.Font.GothamBold; tLbl.TextSize = 13
	tLbl.TextColor3 = Color3.fromRGB(255, 255, 255); tLbl.TextXAlignment = Enum.TextXAlignment.Left
	tLbl.Text = title; tLbl.Size = UDim2.new(1, 0, 0, 16)

	if sub ~= "" then
		local sLbl = Instance.new("TextLabel", noti)
		sLbl.BackgroundTransparency = 1; sLbl.Font = Enum.Font.Gotham; sLbl.TextSize = 12
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

-- TỰ ĐỘNG KHỞI CHẠY THEME MẶC ĐỊNH NGAY KHI EXECUTE
task.spawn(function()
	Library:EnsureDefaultThemeLoaded()
end)

return Library
