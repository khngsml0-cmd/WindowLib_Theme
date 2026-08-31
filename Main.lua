-- Main.lua (Core Hub - khngsml0-cmd/WindowLib_Theme)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local LocalPlayer = Players.LocalPlayer

-- ĐƯỜNG DẪN GITHUB CỦA BẠN ĐÃ ĐƯỢC CẤU HÌNH CHUẨN XÁC
local GITHUB_RAW_BASE = "https://raw.githubusercontent.com/khngsml0-cmd/WindowLib_Theme/main/Themes/"

local THEME_MAP = {
	Dark    = { Module = "Modern",  SubTheme = "Dark" },
	Light   = { Module = "Modern",  SubTheme = "Light" },
	Classic = { Module = "Classic", SubTheme = "Classic" },
}

--------------------------------------------------------------------------------
-- 1. ROOT AN TOÀN & PHÂN CẤP NONUSER GUI
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
-- 2. CORE CONTEXT TRUYỀN CHO CÁC THEME
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
end

function Core.HideSnapGhost()
	local t = TweenService:Create(SnapGhostFrame, TweenInfo.new(0.15), {BackgroundTransparency = 1})
	t:Play()
	t.Completed:Connect(function()
		if SnapGhostFrame.BackgroundTransparency >= 0.99 then SnapGhostFrame.Visible = false end
	end)
end

function Core.IsGlobalOutlineDrag() return isGlobalOutlineDrag end

--------------------------------------------------------------------------------
-- 3. THEME DỰ PHÒNG (FALLBACK CHỐNG CRASH KHI MẤT MẠNG HOẶC SAI LINK)
--------------------------------------------------------------------------------
local FallbackModernTheme = {
	Type = "Modern",
	Palettes = {
		Dark = {
			MainBackground = Color3.fromRGB(30, 30, 30),
			MainStroke = Color3.fromRGB(50, 50, 50),
			TopBarBackground = Color3.fromRGB(20, 20, 20),
			TitleTextColor = Color3.fromRGB(240, 240, 240),
			CloseBtnColor = Color3.fromRGB(30, 30, 30),
		},
		Light = {
			MainBackground = Color3.fromRGB(255, 255, 255),
			MainStroke = Color3.fromRGB(220, 220, 220),
			TopBarBackground = Color3.fromRGB(240, 240, 240),
			TitleTextColor = Color3.fromRGB(30, 30, 30),
			CloseBtnColor = Color3.fromRGB(240, 240, 240),
		}
	}
}

function FallbackModernTheme.CreateWindow(coreCtx, config, subThemeName)
	local p = FallbackModernTheme.Palettes[subThemeName or "Dark"] or FallbackModernTheme.Palettes.Dark
	local title = config.Title or "Window"
	local size = config.Size or UDim2.new(0, 500, 0, 320)
	local pos = config.Position or coreCtx.GetNextCascadePosition(size, config.Parent or coreCtx.NonUserGui)

	local frame = Instance.new("ImageButton", config.Parent or coreCtx.NonUserGui)
	frame.Name = "Window_" .. title
	frame.Size = size; frame.Position = pos
	frame.BackgroundColor3 = p.MainBackground
	frame.BorderSizePixel = 0; frame.AutoButtonColor = false
	frame.ZIndex = coreCtx.GetNextZIndex()
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
	local strk = Instance.new("UIStroke", frame); strk.Color = p.MainStroke

	local topBar = Instance.new("Frame", frame)
	topBar.Size = UDim2.new(1, 0, 0, 28)
	topBar.BackgroundColor3 = p.TopBarBackground
	topBar.BorderSizePixel = 0; topBar.ZIndex = frame.ZIndex + 1
	Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

	local titleLbl = Instance.new("TextLabel", topBar)
	titleLbl.Size = UDim2.new(1, -60, 1, 0); titleLbl.Position = UDim2.new(0, 10, 0, 0)
	titleLbl.BackgroundTransparency = 1; titleLbl.Font = Enum.Font.GothamMedium
	titleLbl.TextSize = 13; titleLbl.TextColor3 = p.TitleTextColor
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left; titleLbl.Text = title
	titleLbl.ZIndex = topBar.ZIndex + 1

	local closeBtn = Instance.new("TextButton", topBar)
	closeBtn.Size = UDim2.new(0, 22, 0, 22); closeBtn.Position = UDim2.new(1, -26, 0, 3)
	closeBtn.BackgroundColor3 = p.CloseBtnColor; closeBtn.Text = "✕"
	closeBtn.TextColor3 = p.TitleTextColor; closeBtn.BorderSizePixel = 0
	closeBtn.ZIndex = topBar.ZIndex + 1
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 4)

	local container = Instance.new("Frame", frame)
	container.Name = "Container"
	container.Size = UDim2.new(1, 0, 1, -28); container.Position = UDim2.new(0, 0, 0, 28)
	container.BackgroundTransparency = 1; container.ZIndex = frame.ZIndex + 1

	local isDragging, dragStart, startPos = false, nil, nil
	topBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			coreCtx.BringToFront(frame)
			isDragging = true; dragStart = input.Position; startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then isDragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	local winRecord = {}
	local winAPI = {
		Frame = frame,
		GetFrame = function() return frame end,
		GetContainer = function() return container end,
		SetTitle = function(t) titleLbl.Text = tostring(t) end,
		Close = function() coreCtx.UnregisterActiveWindow(winRecord); frame:Destroy() end,
		Focus = function() coreCtx.BringToFront(frame, winRecord) end,
		SetFocusVisual = function(f) titleLbl.TextColor3 = f and p.TitleTextColor or Color3.fromRGB(140, 140, 140) end,
		UpdatePalette = function(sub)
			local newP = FallbackModernTheme.Palettes[sub or "Dark"] or p
			frame.BackgroundColor3 = newP.MainBackground
			strk.Color = newP.MainStroke
			topBar.BackgroundColor3 = newP.TopBarBackground
			titleLbl.TextColor3 = newP.TitleTextColor
			closeBtn.BackgroundColor3 = newP.CloseBtnColor
			closeBtn.TextColor3 = newP.TitleTextColor
		end
	}
	for k, v in pairs(winAPI) do winRecord[k] = v end
	closeBtn.MouseButton1Click:Connect(function() winAPI.Close() end)
	return winAPI
end

--------------------------------------------------------------------------------
-- 4. MAIN LIBRARY & GITHUB THEME ENGINE
--------------------------------------------------------------------------------
local Library = {
	CurrentThemeName = "Dark",
	CurrentModuleType = "Modern",
	LoadedModules = {},
	RegisteredWindows = {},
	ActiveThemeModule = FallbackModernTheme,
	OnThemeChanged = Instance.new("BindableEvent")
}

function Library:FetchModule(moduleName)
	if self.LoadedModules[moduleName] then return self.LoadedModules[moduleName] end

	local url = GITHUB_RAW_BASE .. moduleName .. ".lua?t=" .. tick()
	local success, response = pcall(function() return game:HttpGet(url) end)

	if not success or not response or response:find("404: Not Found") or response:find("<html") then
		warn("[UI Core] Không tìm thấy file " .. moduleName .. ".lua trên GitHub! Đang dùng Fallback.")
		return FallbackModernTheme
	end

	local loadFunc, syntaxErr = loadstring(response)
	if not loadFunc then
		warn("[UI Core] Lỗi cú pháp trong file (" .. moduleName .. ".lua):", syntaxErr)
		return FallbackModernTheme
	end

	local execSuccess, moduleTable = pcall(loadFunc)
	if execSuccess and type(moduleTable) == "table" and moduleTable.CreateWindow then
		self.LoadedModules[moduleName] = moduleTable
		return moduleTable
	else
		warn("[UI Core] Module " .. moduleName .. " không trả về hàm CreateWindow!")
		return FallbackModernTheme
	end
end

function Library:EnsureDefaultThemeLoaded()
	local targetInfo = THEME_MAP[self.CurrentThemeName] or THEME_MAP.Dark
	local moduleObj = self:FetchModule(targetInfo.Module) or FallbackModernTheme
	self.ActiveThemeModule = moduleObj
	self.CurrentModuleType = moduleObj.Type
	if moduleObj.Init then moduleObj.Init(Core) end
end

function Library:SetTheme(targetThemeName)
	local targetInfo = THEME_MAP[targetThemeName]
	if not targetInfo then return end

	local targetModuleName = targetInfo.Module
	local subTheme = targetInfo.SubTheme
	local moduleObj = self:FetchModule(targetModuleName) or FallbackModernTheme

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
		for _, win in ipairs(Core.ActiveWindows) do
			if win.UpdatePalette then win.UpdatePalette(subTheme) end
		end
	else
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
	local moduleObj = self.ActiveThemeModule or FallbackModernTheme

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
	local title = config.Title or "Notification"
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

-- Tự động kích hoạt nạp Theme ngay lập tức
Library:EnsureDefaultThemeLoaded()

return Library
