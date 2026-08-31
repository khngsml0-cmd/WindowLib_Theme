-- Themes/ClassicV2.lua (Roblox Studio DockWidget Edition)
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

local ClassicV2Module = {
	Type = "ClassicV2",
	Palettes = {
		ClassicV2 = {
			Type = "ClassicV2",
			MainBackground = Color3.fromRGB(255, 255, 255),
			MainStroke = Color3.fromRGB(240, 240, 240),
			TopBarBackground = Color3.fromRGB(231, 232, 235),
			TopBarLine = Color3.fromRGB(189, 191, 201),
			TitleTextColor = Color3.fromRGB(0, 0, 0),
			TopBarNavDefault = Color3.fromRGB(231, 232, 235),
			TopBarNavHover = Color3.fromRGB(235, 241, 255),
			TopBarNavClick = Color3.fromRGB(210, 220, 245),
			TopBarNavStroke = Color3.fromRGB(201, 204, 215),
			TopBarIconColor = Color3.fromRGB(0, 0, 0),

			-- Kế thừa bảng màu Context Menu từ Classic
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

--------------------------------------------------------------------------------
-- HỆ THỐNG CON TRỎ CHUỘT TÙY BIẾN (FAKE CURSOR SYSTEM)
--------------------------------------------------------------------------------
local ICON_NORMAL = "rbxassetid://130313192476512"
local ICON_DRAG = "rbxassetid://129297489576933"

local isHoveringWindow = false
local lockedIcon = nil
local hoverIcon = nil

local function SetWindowHover(state) isHoveringWindow = state end
local function SetResizeHoverIcon(iconId) hoverIcon = iconId end
local function LockCursorIcon(iconId) lockedIcon = iconId end

local CursorGui, CursorImg

function ClassicV2Module.Init(Core)
	if not CursorGui then
		CursorGui = Instance.new("ScreenGui")
		CursorGui.Name = "ClassicV2FakeCursorGui"
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
			if Core.CurrentModuleType == "ClassicV2" or Core.CurrentModuleType == "Classic" then
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
end

function ClassicV2Module.Cleanup(Core)
	if CursorImg then CursorImg.Visible = false end
	UserInputService.MouseIconEnabled = true
end

--------------------------------------------------------------------------------
-- HÀM DỰNG CỬA SỔ CHÍNH (CREATE WINDOW)
--------------------------------------------------------------------------------
function ClassicV2Module.CreateWindow(Core, config, subThemeName)
	local currentPalette = ClassicV2Module.Palettes[subThemeName or "ClassicV2"] or ClassicV2Module.Palettes.ClassicV2
	local windowTitle = config.Title or "Window"
	local windowIcon = config.Icon or "rbxasset://textures/ui/GuiImagePlaceholder.png"
	local targetParent = config.Parent or Core.NonUserGui

	local defaultSize = config.Size or UDim2.new(0, 300, 0, 400)
	local defaultPos = config.Position or UDim2.new(0.5, -150, 0.5, -200)
	local minSize = config.MinSize or Vector2.new(180, 120)
	local maxSize = config.MaxSize or Vector2.new(1920, 1080)

	local isMinimizedState = false
	local isResizingActive = false

	-- Khung Window chính
	local Window = Instance.new("ImageButton", targetParent)
	Window.Name = "DockWindow_" .. windowTitle
	Window.BorderSizePixel = 0
	Window.AutoButtonColor = false
	Window.BackgroundColor3 = currentPalette.MainBackground
	Window.Size = defaultSize
	Window.Position = defaultPos
	Window.ClipsDescendants = false
	Window.Active = true
	Window.ZIndex = Core.GetNextZIndex()

	Window.MouseEnter:Connect(function() SetWindowHover(true) end)
	Window.MouseLeave:Connect(function() SetWindowHover(false) end)

	local MainUIStroke = Instance.new("UIStroke", Window)
	MainUIStroke.Color = currentPalette.MainStroke

	-- Đổ bóng viền ngoài 9-Slice (Outlines)
	local Outlines = Instance.new("ImageLabel", Window)
	Outlines.Name = "Outlines"
	Outlines.ZIndex = 0
	Outlines.BorderSizePixel = 0
	Outlines.SliceCenter = Rect.new(6, 6, 25, 25)
	Outlines.ScaleType = Enum.ScaleType.Slice
	Outlines.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Outlines.Image = "rbxassetid://1427967925"
	Outlines.TileSize = UDim2.new(0, 20, 0, 20)
	Outlines.Size = UDim2.new(1, 10, 1, 10)
	Outlines.Position = UDim2.new(0, -5, 0, -5)
	Outlines.BackgroundTransparency = 1

	-- Điểm pixel trang trí (FakeBug)
	local FakeBug = Instance.new("Frame", Window)
	FakeBug.Name = "FakeBug"
	FakeBug.BorderSizePixel = 0
	FakeBug.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	FakeBug.AnchorPoint = Vector2.new(0, 1)
	FakeBug.Size = UDim2.new(0, 1, 0, 1)
	FakeBug.Position = UDim2.new(1, 0, 0, 0)

	-- Khung chứa tổng thể (Gen) - Nơi áp dụng Lag Resize
	local Gen = Instance.new("Frame", Window)
	Gen.Name = "Gen"
	Gen.BorderSizePixel = 0
	Gen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Gen.Size = UDim2.new(1, 0, 1, 0)
	Gen.BackgroundTransparency = 1
	Gen.ClipsDescendants = true
	Gen.ZIndex = Window.ZIndex + 1

	-- Thanh TopBar bên trong Gen
	local TopBar = Instance.new("ImageButton", Gen)
	TopBar.Name = "TopBar"
	TopBar.BorderSizePixel = 0
	TopBar.AutoButtonColor = false
	TopBar.BackgroundColor3 = currentPalette.TopBarBackground
	TopBar.AnchorPoint = Vector2.new(0.5, 0)
	TopBar.Size = UDim2.new(1, -4, 0, 22)
	TopBar.Position = UDim2.new(0.5, 0, 0, 2)
	TopBar.ZIndex = Gen.ZIndex + 1

	-- Đường viền 3D viền trên và trái của TopBar
	local Effect3D = Instance.new("Frame", TopBar)
	Effect3D.Name = "3DEffect"
	Effect3D.BorderSizePixel = 0
	Effect3D.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Effect3D.Size = UDim2.new(1, 0, 1, 0)
	Effect3D.BackgroundTransparency = 1
	Effect3D.ZIndex = TopBar.ZIndex

	local TopLine = Instance.new("Frame", Effect3D)
	TopLine.Name = "TopLine"
	TopLine.BorderSizePixel = 0
	TopLine.BackgroundColor3 = currentPalette.TopBarLine
	TopLine.Size = UDim2.new(1, 0, 0, 1)
	TopLine.ZIndex = Effect3D.ZIndex

	local LeftLine = Instance.new("Frame", Effect3D)
	LeftLine.Name = "LeftLine"
	LeftLine.BorderSizePixel = 0
	LeftLine.BackgroundColor3 = currentPalette.TopBarLine
	LeftLine.Size = UDim2.new(0, 1, 1, 0)
	LeftLine.ZIndex = Effect3D.ZIndex

	-- Tiêu đề cửa sổ
	local TitleLabel = Instance.new("TextLabel", TopBar)
	TitleLabel.Name = "Title"
	TitleLabel.BorderSizePixel = 0
	TitleLabel.TextSize = 14
	TitleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	TitleLabel.TextColor3 = currentPalette.TitleTextColor
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Size = UDim2.new(1, 0, 1, 0)
	TitleLabel.Text = windowTitle
	TitleLabel.ZIndex = TopBar.ZIndex + 1

	-- Cụm nút điều hướng (NavSystem)
	local NavSystem = Instance.new("Frame", TopBar)
	NavSystem.Name = "NavSystem"
	NavSystem.BorderSizePixel = 0
	NavSystem.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	NavSystem.AnchorPoint = Vector2.new(1, 0)
	NavSystem.AutomaticSize = Enum.AutomaticSize.X
	NavSystem.Size = UDim2.new(0, 50, 1, 0)
	NavSystem.Position = UDim2.new(1, 0, 0, 0)
	NavSystem.BackgroundTransparency = 1
	NavSystem.ZIndex = TopBar.ZIndex + 1

	local NavPadding = Instance.new("UIPadding", NavSystem)
	NavPadding.PaddingRight = UDim.new(0, 8)

	local NavLayout = Instance.new("UIListLayout", NavSystem)
	NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	NavLayout.Padding = UDim.new(0, 2)
	NavLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	NavLayout.SortOrder = Enum.SortOrder.LayoutOrder

	-- Nút đóng cửa sổ (Close Button)
	local CloseBtn = Instance.new("ImageButton", NavSystem)
	CloseBtn.Name = "Close"
	CloseBtn.BorderSizePixel = 0
	CloseBtn.AutoButtonColor = false
	CloseBtn.BackgroundColor3 = currentPalette.TopBarNavDefault
	CloseBtn.Size = UDim2.new(0, 14, 0, 14)
	CloseBtn.ZIndex = NavSystem.ZIndex + 1

	local CloseIcon = Instance.new("ImageLabel", CloseBtn)
	CloseIcon.Name = "Icon"
	CloseIcon.BorderSizePixel = 0
	CloseIcon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	CloseIcon.ImageColor3 = currentPalette.TopBarIconColor
	CloseIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	CloseIcon.Image = "rbxassetid://16167590639"
	CloseIcon.ImageRectSize = Vector2.new(36, 36)
	CloseIcon.ImageRectOffset = Vector2.new(442, 0)
	CloseIcon.Size = UDim2.new(1, -2, 1, -2)
	CloseIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	CloseIcon.BackgroundTransparency = 1
	CloseIcon.ZIndex = CloseBtn.ZIndex + 1

	local CloseStroke = Instance.new("UIStroke", CloseBtn)
	CloseStroke.Enabled = false
	CloseStroke.Color = currentPalette.TopBarNavStroke
	CloseStroke.LineJoinMode = Enum.LineJoinMode.Miter

	CloseBtn.MouseEnter:Connect(function()
		CloseBtn.BackgroundColor3 = currentPalette.TopBarNavHover
		CloseStroke.Enabled = true
	end)

	CloseBtn.MouseLeave:Connect(function()
		CloseBtn.BackgroundColor3 = currentPalette.TopBarNavDefault
		CloseStroke.Enabled = false
	end)

	-- Khung chứa nội dung chính của người dùng (Container)
	local Container = Instance.new("Frame", Gen)
	Container.Name = "Container"
	Container.BorderSizePixel = 0
	Container.BackgroundColor3 = currentPalette.MainBackground
	Container.Size = UDim2.new(1, 0, 1, -25)
	Container.Position = UDim2.new(0, 0, 0, 25)
	Container.BackgroundTransparency = 1
	Container.ClipsDescendants = true
	Container.ZIndex = Gen.ZIndex + 1

	--------------------------------------------------------------------------------
	-- CƠ CHẾ LAG RESIZE TOÀN BỘ KHUNG GEN (~22 FPS)
	--------------------------------------------------------------------------------
	local UPDATE_INTERVAL = 1 / 22
	local accumulatedTime = 0
	local renderConn
	renderConn = RunService.RenderStepped:Connect(function(dt)
		if not Window or not Window.Parent then
			renderConn:Disconnect()
			return
		end
		if isResizingActive and not isMinimizedState then
			accumulatedTime = accumulatedTime + dt
			if accumulatedTime >= UPDATE_INTERVAL then
				accumulatedTime = accumulatedTime % UPDATE_INTERVAL
				Gen.Size = UDim2.new(0, Window.AbsoluteSize.X, 0, Window.AbsoluteSize.Y)
			end
		end
	end)

	--------------------------------------------------------------------------------
	-- TẠO 12 HANDLES ĐIỀU KHIỂN RESIZE CHUẨN XÁC
	--------------------------------------------------------------------------------
	local ResizeHandles = Instance.new("Folder", Window)
	ResizeHandles.Name = "ResizeHandles"

	local function makeHandle(name, size, pos)
		local h = Instance.new("TextButton", ResizeHandles)
		h.Name = name
		h.Size = size
		h.Position = pos
		h.BackgroundTransparency = 1
		h.Text = ""
		h.ZIndex = Window.ZIndex + 5
		h.BorderSizePixel = 0
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

	local windowRecord = {}

	local function bringToFront()
		Core.BringToFront(Window, windowRecord)
	end

	local function setFocusVisual(isFocused)
		if isFocused then
			TopBar.BackgroundColor3 = currentPalette.TopBarBackground
			TitleLabel.TextColor3 = currentPalette.TitleTextColor
			CloseIcon.ImageColor3 = currentPalette.TopBarIconColor
		else
			TopBar.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
			TitleLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
			CloseIcon.ImageColor3 = Color3.fromRGB(150, 150, 150)
		end
	end

	local function setDockMinimize(minimize)
		isMinimizedState = minimize
		Window.Visible = not minimize
		if minimize then
			if Core.FocusedWindow == windowRecord then Core.SetFocus(nil) end
		else
			bringToFront()
		end
	end

	Window.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 or input.UserInputType == Enum.UserInputType.Touch then
			bringToFront()
		end
	end)

	--------------------------------------------------------------------------------
	-- KÉO THẢ VÀ OUTLINE DRAG QUA TOPBAR
	--------------------------------------------------------------------------------
	local isDragging = false
	local dragStartMouse = Vector2.zero
	local dragStartPos = UDim2.new()
	local lastTitleClick = 0

	TopBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			bringToFront()

			local now = tick()
			if now - lastTitleClick < 0.28 then
				lastTitleClick = 0
				setDockMinimize(true)
				return
			else
				lastTitleClick = now
			end

			local useOutlineDrag = (config.OutlineDrag ~= nil) and config.OutlineDrag or Core.IsGlobalOutlineDrag()

			LockCursorIcon(ICON_DRAG)
			isDragging = true
			dragStartMouse = UserInputService:GetMouseLocation()
			dragStartPos = Window.Position

			if useOutlineDrag then
				Core.DragOutlineFrame.Size = Window.Size
				Core.DragOutlineFrame.Position = Window.Position
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
					else Window.Position = targetPos end
				end
			end)

			releaseConn = UserInputService.InputEnded:Connect(function(endInput)
				if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
					isDragging = false
					moveConn:Disconnect(); releaseConn:Disconnect()
					if useOutlineDrag then
						Core.DragOutlineFrame.Visible = false
						Window.Position = Core.DragOutlineFrame.Position
					end
				end
			end)
		end
	end)

	--------------------------------------------------------------------------------
	-- GẮN LOGIC CO DÃN & KÍCH HOẠT LAG RESIZE CHO GEN
	--------------------------------------------------------------------------------
	local function bindHandle(handle, dirX, dirY)
		if not handle then return end
		handle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 and not isMinimizedState then
				bringToFront()
				isResizingActive = true
				accumulatedTime = 0

				local startMouse = UserInputService:GetMouseLocation()
				local startSize = Window.AbsoluteSize
				local startPos = Window.Position

				-- Cố định pixel kích thước Gen khi bắt đầu resize
				Gen.Size = UDim2.new(0, startSize.X, 0, startSize.Y)

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

						Window.Size = UDim2.new(0, newW, 0, newH)
						Window.Position = UDim2.new(startPos.X.Scale, newPosX, startPos.Y.Scale, newPosY)
					end
				end)

				endConn = UserInputService.InputEnded:Connect(function(endInput)
					if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
						isResizingActive = false
						moveConn:Disconnect(); endConn:Disconnect()
						-- Khi thả chuột, snap Gen về lấp đầy 100% kích thước Window
						Gen.Size = UDim2.new(1, 0, 1, 0)
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

	local function destroyWindow()
		Core.UnregisterActiveWindow(windowRecord)
		Window:Destroy()
	end

	CloseBtn.MouseButton1Click:Connect(function()
		destroyWindow()
	end)

	windowRecord.Frame = Window
	windowRecord.TargetParent = targetParent
	windowRecord.SetFocusVisual = setFocusVisual
	windowRecord.GetTitle = function() return TitleLabel.Text end
	windowRecord.GetIcon = function() return windowIcon end
	windowRecord.Focus = function() bringToFront() end
	windowRecord.Close = function() destroyWindow() end
	windowRecord.Minimize = function() setDockMinimize(true) end
	windowRecord.Restore = function() setDockMinimize(false) end
	windowRecord.IsMinimized = function() return isMinimizedState end

	local WindowAPI = {}
	function WindowAPI:GetFrame() return Window end
	function WindowAPI:GetContainer() return Container end
	function WindowAPI:GetNonUser() return Core.NonUserGui end
	function WindowAPI:GetCustomOpenUI() return Core.CustomOpenGui end
	function WindowAPI:Focus() bringToFront() end
	function WindowAPI:SetTitle(text) TitleLabel.Text = tostring(text) end
	function WindowAPI:SetIcon(iconId) windowIcon = iconId end
	function WindowAPI:SetVisible(visible) Window.Visible = visible end
	function WindowAPI:Close() destroyWindow() end
	function WindowAPI:Minimize() setDockMinimize(true) end
	function WindowAPI:Restore() setDockMinimize(false) end
	function WindowAPI:IsMinimized() return isMinimizedState end
	function WindowAPI:SetPosition(pos) Window.Position = pos end
	function WindowAPI:SetSize(size) Window.Size = size; Gen.Size = UDim2.new(1, 0, 1, 0) end
	function WindowAPI:GetPosition() return Window.Position end
	function WindowAPI:GetSize() return Window.Size end
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
		WindowAPI:BindContextMenu(TopBar, config.TopBarContextMenu, config.TopBarContextMenuTrigger or "Right")
	end

	windowRecord.API = WindowAPI
	return windowRecord
end

return ClassicV2Module
