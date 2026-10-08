local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------------------------------------
-- APPLE LIQUID GLASS PALETTE
--------------------------------------------------------------------------------

local UI_BgColor = Color3.fromRGB(20, 22, 28)        -- Deep frosted dark
local UI_CardColor = Color3.fromRGB(30, 34, 45)      -- Translucent card tone
local UI_CardBorder = Color3.fromRGB(255, 255, 255)  -- Glass edge highlight
local UI_TextPrimary = Color3.fromRGB(245, 247, 250)
local UI_TextSecondary = Color3.fromRGB(150, 160, 175)
local UI_ToggleOn = Color3.fromRGB(10, 132, 255)     -- iOS Blue
local UI_ToggleOff = Color3.fromRGB(45, 50, 65)
local UI_WarningRed = Color3.fromRGB(255, 69, 58)    -- iOS Red

local UI_Font = Enum.Font.GothamBold

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GabsPanel_LiquidGlass"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = PlayerGui

--------------------------------------------------------------------------------
-- CONFIGURATION & STATE
--------------------------------------------------------------------------------

local StickyAim_Enabled = false
local WallCheck_Enabled = false
local IgnoreDead_Enabled = false
local TeamCheck_Enabled = false
local VisualESP_Enabled = false
local BehindWarning_Enabled = false
local TargetBots_Enabled = false

local FOV_Radius = 82
local Aim_Smoothness = 0.25
local Behind_Distance = 100
local LockTarget = nil

--------------------------------------------------------------------------------
-- GUI COMPONENTS & WINDOW SETUP
--------------------------------------------------------------------------------

-- Themed Warning Box (Glassmorphism)
local warningFrame = Instance.new("Frame")
warningFrame.Name = "WarningFrame"
warningFrame.Size = UDim2.new(0, 210, 0, 38)
warningFrame.Position = UDim2.new(0.5, -105, 0.1, 0)
warningFrame.BackgroundColor3 = UI_CardColor
warningFrame.BackgroundTransparency = 0.25
warningFrame.BorderSizePixel = 0
warningFrame.Active = true
warningFrame.Draggable = true
warningFrame.Visible = false
warningFrame.Parent = screenGui

local warningCorner = Instance.new("UICorner")
warningCorner.CornerRadius = UDim.new(0, 12)
warningCorner.Parent = warningFrame

local warningStroke = Instance.new("UIStroke")
warningStroke.Color = UI_CardBorder
warningStroke.Transparency = 0.7
warningStroke.Thickness = 1
warningStroke.Parent = warningFrame

local warningDot = Instance.new("Frame")
warningDot.Size = UDim2.new(0, 8, 0, 8)
warningDot.Position = UDim2.new(0, 12, 0.5, -4)
warningDot.BackgroundColor3 = UI_WarningRed
warningDot.Parent = warningFrame

local warningDotCorner = Instance.new("UICorner")
warningDotCorner.CornerRadius = UDim.new(1, 0)
warningDotCorner.Parent = warningDot

local warningText = Instance.new("TextLabel")
warningText.Size = UDim2.new(1, -30, 1, 0)
warningText.Position = UDim2.new(0, 26, 0, 0)
warningText.BackgroundTransparency = 1
warningText.Text = "⚠️ ENEMY BEHIND!"
warningText.TextColor3 = UI_TextPrimary
warningText.Font = UI_Font
warningText.TextSize = 11
warningText.TextXAlignment = Enum.TextXAlignment.Left
warningText.TextTruncate = Enum.TextTruncate.AtEnd
warningText.Parent = warningFrame

-- Mobile Floating Re-open Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "MobileToggleBtn"
toggleBtn.Size = UDim2.new(0, 48, 0, 48)
toggleBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
toggleBtn.BackgroundColor3 = UI_BgColor
toggleBtn.BackgroundTransparency = 0.2
toggleBtn.Text = "GAB"
toggleBtn.TextColor3 = UI_TextPrimary
toggleBtn.Font = UI_Font
toggleBtn.TextSize = 13
toggleBtn.Active = true
toggleBtn.Draggable = true
toggleBtn.Visible = false 
toggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 14)
toggleCorner.Parent = toggleBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = UI_CardBorder
toggleStroke.Transparency = 0.6
toggleStroke.Thickness = 1.2
toggleStroke.Parent = toggleBtn

-- Main Frame (Liquid Glass Look)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 520, 0, 360)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
mainFrame.BackgroundColor3 = UI_BgColor
mainFrame.BackgroundTransparency = 0.15
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = false
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 22)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = UI_CardBorder
mainStroke.Transparency = 0.5
mainStroke.Thickness = 1.2
mainStroke.Parent = mainFrame

local mainScale = Instance.new("UIScale")
mainScale.Scale = 0.85
mainScale.Parent = mainFrame

-- Title Header
local headerTitle = Instance.new("TextLabel")
headerTitle.Size = UDim2.new(0, 250, 0, 40)
headerTitle.Position = UDim2.new(0, 20, 0, 12)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = "Gab's Panel"
headerTitle.TextColor3 = UI_TextPrimary
headerTitle.Font = UI_Font
headerTitle.TextSize = 14
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Parent = mainFrame

-- Top Right Window Buttons (- and X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -38, 0, 12)
closeBtn.BackgroundColor3 = UI_CardColor
closeBtn.BackgroundTransparency = 0.3
closeBtn.Text = "✕"
closeBtn.TextColor3 = UI_TextSecondary
closeBtn.Font = UI_Font
closeBtn.TextSize = 12
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

local closeStroke = Instance.new("UIStroke")
closeStroke.Color = UI_CardBorder
closeStroke.Transparency = 0.7
closeStroke.Thickness = 1
closeStroke.Parent = closeBtn

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -72, 0, 12)
minBtn.BackgroundColor3 = UI_CardColor
minBtn.BackgroundTransparency = 0.3
minBtn.Text = "—"
minBtn.TextColor3 = UI_TextSecondary
minBtn.Font = UI_Font
minBtn.TextSize = 12
minBtn.Parent = mainFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minBtn

local minStroke = Instance.new("UIStroke")
minStroke.Color = UI_CardBorder
minStroke.Transparency = 0.7
minStroke.Thickness = 1
minStroke.Parent = minBtn

local panelOpen = false
local function setPanelOpen(openState)
	panelOpen = openState
	if openState then
		mainFrame.Visible = true
		mainScale.Scale = 0.85
		TweenService:Create(mainScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
	else
		local tween = TweenService:Create(mainScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Scale = 0.85})
		tween:Play()
		tween.Completed:Connect(function()
			if not panelOpen then mainFrame.Visible = false end
		end)
	end
end

closeBtn.MouseButton1Click:Connect(function() setPanelOpen(false) end)
minBtn.MouseButton1Click:Connect(function() setPanelOpen(false) end)
toggleBtn.MouseButton1Click:Connect(function() setPanelOpen(not panelOpen) end)

--------------------------------------------------------------------------------
-- LOADER NOTIFICATION
--------------------------------------------------------------------------------

local loaderFrame = Instance.new("Frame")
loaderFrame.Size = UDim2.new(0, 220, 0, 50)
loaderFrame.AnchorPoint = Vector2.new(0.5, 0.5)
loaderFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
loaderFrame.BackgroundColor3 = UI_CardColor
loaderFrame.BackgroundTransparency = 0.2
loaderFrame.BorderSizePixel = 0
loaderFrame.ZIndex = 10
loaderFrame.Parent = screenGui

local loaderCorner = Instance.new("UICorner")
loaderCorner.CornerRadius = UDim.new(0, 14)
loaderCorner.Parent = loaderFrame

local loaderStroke = Instance.new("UIStroke")
loaderStroke.Color = UI_CardBorder
loaderStroke.Transparency = 0.6
loaderStroke.Thickness = 1.2
loaderStroke.Parent = loaderFrame

local loaderText = Instance.new("TextLabel")
loaderText.Size = UDim2.new(1, 0, 1, 0)
loaderText.BackgroundTransparency = 1
loaderText.Text = "GAB'S PANEL | LOADING..."
loaderText.TextColor3 = UI_TextPrimary
loaderText.Font = UI_Font
loaderText.TextSize = 11
loaderText.ZIndex = 11
loaderText.Parent = loaderFrame

task.delay(2, function()
	local tween = TweenService:Create(loaderFrame, TweenInfo.new(0.4), {BackgroundTransparency = 1})
	local textTween = TweenService:Create(loaderText, TweenInfo.new(0.4), {TextTransparency = 1})
	local strokeTween = TweenService:Create(loaderStroke, TweenInfo.new(0.4), {Transparency = 1})
	
	tween:Play()
	textTween:Play()
	strokeTween:Play()
	
	tween.Completed:Connect(function()
		loaderFrame:Destroy()
	end)
	
	toggleBtn.Visible = true
	setPanelOpen(true)
end)

--------------------------------------------------------------------------------
-- LEFT COLUMN: FEATURES LIST & SECTION HEADER
--------------------------------------------------------------------------------

local sectionHeader = Instance.new("Frame")
sectionHeader.Size = UDim2.new(0, 290, 0, 20)
sectionHeader.Position = UDim2.new(0, 20, 0, 46)
sectionHeader.BackgroundTransparency = 1
sectionHeader.Parent = mainFrame

local sectionLine = Instance.new("Frame")
sectionLine.Size = UDim2.new(1, 0, 0, 1)
sectionLine.Position = UDim2.new(0, 0, 0, 0)
sectionLine.BackgroundColor3 = UI_CardBorder
sectionLine.BackgroundTransparency = 0.8
sectionLine.BorderSizePixel = 0
sectionLine.Parent = sectionHeader

local sectionLabelContainer = Instance.new("Frame")
sectionLabelContainer.Size = UDim2.new(0, 95, 0, 14)
sectionLabelContainer.Position = UDim2.new(0, 0, 0, -7)
sectionLabelContainer.BackgroundColor3 = UI_BgColor
sectionLabelContainer.BackgroundTransparency = 1
sectionLabelContainer.BorderSizePixel = 0
sectionLabelContainer.Parent = sectionHeader

local sectionDot = Instance.new("Frame")
sectionDot.Size = UDim2.new(0, 3, 0, 10)
sectionDot.Position = UDim2.new(0, 0, 0.5, -5)
sectionDot.BackgroundColor3 = UI_TextPrimary
sectionDot.BorderSizePixel = 0
sectionDot.Parent = sectionLabelContainer

local sectionText = Instance.new("TextLabel")
sectionText.Size = UDim2.new(1, -8, 1, 0)
sectionText.Position = UDim2.new(0, 8, 0, 0)
sectionText.BackgroundTransparency = 1
sectionText.Text = "FEATURES"
sectionText.TextColor3 = UI_TextSecondary
sectionText.Font = UI_Font
sectionText.TextSize = 10
sectionText.TextXAlignment = Enum.TextXAlignment.Left
sectionText.Parent = sectionLabelContainer

local featuresList = Instance.new("ScrollingFrame")
featuresList.Size = UDim2.new(0, 290, 1, -78)
featuresList.Position = UDim2.new(0, 20, 0, 72)
featuresList.BackgroundTransparency = 1
featuresList.BorderSizePixel = 0
featuresList.ScrollBarThickness = 2
featuresList.ScrollBarImageColor3 = UI_TextSecondary
featuresList.CanvasSize = UDim2.new(0, 0, 0, 0)
featuresList.Parent = mainFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 8)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = featuresList

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	featuresList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

--------------------------------------------------------------------------------
-- RIGHT COLUMN: PLAYER PROFILE CARD
--------------------------------------------------------------------------------

local profileCard = Instance.new("Frame")
profileCard.Size = UDim2.new(0, 175, 1, -68)
profileCard.Position = UDim2.new(1, -195, 0, 52)
profileCard.BackgroundColor3 = UI_CardColor
profileCard.BackgroundTransparency = 0.35
profileCard.Parent = mainFrame

local profileCorner = Instance.new("UICorner")
profileCorner.CornerRadius = UDim.new(0, 16)
profileCorner.Parent = profileCard

local profileStroke = Instance.new("UIStroke")
profileStroke.Color = UI_CardBorder
profileStroke.Transparency = 0.7
profileStroke.Thickness = 1
profileStroke.Parent = profileCard

local avatarFrame = Instance.new("ImageLabel")
avatarFrame.Size = UDim2.new(0, 80, 0, 80)
avatarFrame.Position = UDim2.new(0.5, -40, 0, 20)
avatarFrame.BackgroundColor3 = UI_BgColor
avatarFrame.Parent = profileCard

local avatarCorner = Instance.new("UICorner")
avatarCorner.CornerRadius = UDim.new(1, 0)
avatarCorner.Parent = avatarFrame

local avatarStroke = Instance.new("UIStroke")
avatarStroke.Color = UI_CardBorder
avatarStroke.Transparency = 0.6
avatarStroke.Thickness = 1.5
avatarStroke.Parent = avatarFrame

task.spawn(function()
	local content, isLoaded = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	if isLoaded then
		avatarFrame.Image = content
	end
end)

local function addProfileText(titleText, valText, yPos)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 14)
	label.Position = UDim2.new(0, 10, 0, yPos)
	label.BackgroundTransparency = 1
	label.Text = titleText .. "   " .. valText
	label.TextColor3 = UI_TextSecondary
	label.Font = UI_Font
	label.TextSize = 9
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextTruncate = Enum.TextTruncate.AtEnd
	label.Parent = profileCard
end

addProfileText("DISPLAY:", LocalPlayer.DisplayName, 120)
addProfileText("USER ID:", tostring(LocalPlayer.UserId), 145)

local accountAgeDays = LocalPlayer.AccountAge
local joinDate = os.date("*t", os.time() - (accountAgeDays * 86400))
local formattedDate = string.format("%02d/%02d/%04d", joinDate.day, joinDate.month, joinDate.year)
addProfileText("CREATED:", formattedDate, 170)

--------------------------------------------------------------------------------
-- UI BUILDERS (TOGGLES & SLIDERS)
--------------------------------------------------------------------------------

local function createToggle(text, subtext, defaultState, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -8, 0, 38)
	card.BackgroundColor3 = UI_CardColor
	card.BackgroundTransparency = 0.35
	card.Parent = featuresList

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 10)
	cardCorner.Parent = card

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = UI_CardBorder
	cardStroke.Transparency = 0.75
	cardStroke.Thickness = 1
	cardStroke.Parent = card

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -70, 0, 16)
	label.Position = UDim2.new(0, 12, 0, 4)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = UI_TextPrimary
	label.Font = UI_Font
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = card

	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(1, -70, 0, 12)
	desc.Position = UDim2.new(0, 12, 0, 20)
	desc.BackgroundTransparency = 1
	desc.Text = subtext
	desc.TextColor3 = UI_TextSecondary
	desc.Font = UI_Font
	desc.TextSize = 8
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.Parent = card

	local stateText = Instance.new("TextLabel")
	stateText.Size = UDim2.new(0, 22, 0, 16)
	stateText.Position = UDim2.new(1, -62, 0.5, -8)
	stateText.BackgroundTransparency = 1
	stateText.Text = defaultState and "ON" or "OFF"
	stateText.TextColor3 = UI_TextSecondary
	stateText.Font = UI_Font
	stateText.TextSize = 9
	stateText.Parent = card

	local switchBg = Instance.new("TextButton")
	switchBg.Size = UDim2.new(0, 34, 0, 18)
	switchBg.Position = UDim2.new(1, -38, 0.5, -9)
	switchBg.BackgroundColor3 = defaultState and UI_ToggleOn or UI_ToggleOff
	switchBg.Text = ""
	switchBg.AutoButtonColor = false
	switchBg.Parent = card

	local switchCorner = Instance.new("UICorner")
	switchCorner.CornerRadius = UDim.new(1, 0)
	switchCorner.Parent = switchBg

	local switchStroke = Instance.new("UIStroke")
	switchStroke.Color = UI_CardBorder
	switchStroke.Transparency = 0.6
	switchStroke.Thickness = 1
	switchStroke.Parent = switchBg

	local switchDot = Instance.new("Frame")
	switchDot.Size = UDim2.new(0, 12, 0, 12)
	switchDot.Position = defaultState and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
	switchDot.BackgroundColor3 = UI_BgColor
	switchDot.Parent = switchBg

	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = switchDot

	local state = defaultState
	switchBg.MouseButton1Click:Connect(function()
		state = not state
		stateText.Text = state and "ON" or "OFF"
		
		local targetBg = state and UI_ToggleOn or UI_ToggleOff
		local targetDotPos = state and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)

		TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
		TweenService:Create(switchDot, TweenInfo.new(0.2), {Position = targetDotPos}):Play()
		callback(state)
	end)
end

local function createSlider(titleText, minVal, maxVal, defaultVal, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -8, 0, 44)
	card.BackgroundColor3 = UI_CardColor
	card.BackgroundTransparency = 0.35
	card.Parent = featuresList

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 10)
	cardCorner.Parent = card

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = UI_CardBorder
	cardStroke.Transparency = 0.75
	cardStroke.Thickness = 1
	cardStroke.Parent = card

	local sliderTitle = Instance.new("TextLabel")
	sliderTitle.Size = UDim2.new(1, -70, 0, 16)
	sliderTitle.Position = UDim2.new(0, 12, 0, 6)
	sliderTitle.BackgroundTransparency = 1
	sliderTitle.Text = titleText
	sliderTitle.TextColor3 = UI_TextPrimary
	sliderTitle.Font = UI_Font
	sliderTitle.TextSize = 11
	sliderTitle.TextXAlignment = Enum.TextXAlignment.Left
	sliderTitle.Parent = card

	local valLabel = Instance.new("TextLabel")
	valLabel.Size = UDim2.new(0, 50, 0, 16)
	valLabel.Position = UDim2.new(1, -62, 0, 6)
	valLabel.BackgroundTransparency = 1
	valLabel.Text = tostring(defaultVal)
	valLabel.TextColor3 = UI_TextSecondary
	valLabel.Font = UI_Font
	valLabel.TextSize = 10
	valLabel.TextXAlignment = Enum.TextXAlignment.Right
	valLabel.Parent = card

	local sliderBtn = Instance.new("TextButton")
	sliderBtn.Size = UDim2.new(1, -24, 0, 6)
	sliderBtn.Position = UDim2.new(0, 12, 0, 28)
	sliderBtn.BackgroundColor3 = UI_ToggleOff
	sliderBtn.Text = ""
	sliderBtn.AutoButtonColor = false
	sliderBtn.Parent = card

	local sliderBtnCorner = Instance.new("UICorner")
	sliderBtnCorner.CornerRadius = UDim.new(1, 0)
	sliderBtnCorner.Parent = sliderBtn

	local sliderFill = Instance.new("Frame")
	sliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
	sliderFill.BackgroundColor3 = UI_ToggleOn
	sliderFill.BorderSizePixel = 0
	sliderFill.Parent = sliderBtn

	local sliderFillCorner = Instance.new("UICorner")
	sliderFillCorner.CornerRadius = UDim.new(1, 0)
	sliderFillCorner.Parent = sliderFill

	local dragging = false
	local function update(input)
		local pos = input.Position.X
		local barPos = sliderBtn.AbsolutePosition.X
		local barWidth = sliderBtn.AbsoluteSize.X
		local rel = math.clamp((pos - barPos) / barWidth, 0, 1)
		local val = math.floor(minVal + (rel * (maxVal - minVal)))
		
		sliderFill.Size = UDim2.new(rel, 0, 1, 0)
		valLabel.Text = tostring(val)
		callback(val, rel)
	end

	sliderBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			update(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

--------------------------------------------------------------------------------
-- FOV CIRCLE
--------------------------------------------------------------------------------

local FOVFrame = Instance.new("Frame")
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Size = UDim2.new(0, FOV_Radius * 2, 0, FOV_Radius * 2)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = false
FOVFrame.Parent = screenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVFrame

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = UI_TextPrimary
FOVStroke.Transparency = 0.2
FOVStroke.Thickness = 1.5
FOVStroke.Parent = FOVFrame

--------------------------------------------------------------------------------
-- HELPER & BOT FILTER FUNCTIONS
--------------------------------------------------------------------------------

local function isEntityAlive(modelOrPlayer)
	if not modelOrPlayer then return false end
	
	local char = modelOrPlayer
	if modelOrPlayer:IsA("Player") then
		if not modelOrPlayer.Character then return false end
		char = modelOrPlayer.Character
	end
	
	if not char:IsDescendantOf(workspace) then return false end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead then
		return false
	end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end

	if char:GetAttribute("IsDead") == true or char:GetAttribute("Dead") == true or char:GetAttribute("Downed") == true then
		return false
	end

	return true
end

local function getTargetPart(character)
	if not character then return nil end
	local head = character:FindFirstChild("Head")
	if head then return head end

	local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	if torso then return torso end

	return character:FindFirstChild("HumanoidRootPart")
end

local function isTargetVisible(targetPart)
	if not WallCheck_Enabled then return true end
	if not targetPart then return false end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	
	local ignoreList = {Camera}
	if LocalPlayer.Character then table.insert(ignoreList, LocalPlayer.Character) end
	
	rayParams.FilterDescendantsInstances = ignoreList
	rayParams.IgnoreWater = true

	local origin = Camera.CFrame.Position
	local direction = targetPart.Position - origin
	local raycastResult = workspace:Raycast(origin, direction, rayParams)

	if raycastResult then
		if raycastResult.Instance:IsDescendantOf(targetPart.Parent) then return true end
		return false
	end

	return true
end

local function getAllTargetCharacters()
	local targets = {}

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			if IgnoreDead_Enabled and not isEntityAlive(player) then continue end
			if TeamCheck_Enabled and player.Team and player.Team == LocalPlayer.Team then continue end
			table.insert(targets, player.Character)
		end
	end

	if TargetBots_Enabled then
		local function scanFolder(parent)
			for _, descendant in ipairs(parent:GetChildren()) do
				if descendant:IsA("Model") and descendant:FindFirstChildOfClass("Humanoid") and descendant:FindFirstChild("HumanoidRootPart") then
					
					local isPlayerChar = false
					for _, p in ipairs(Players:GetPlayers()) do
						if p.Character == descendant then isPlayerChar = true; break end
					end

					if not isPlayerChar and descendant ~= LocalPlayer.Character then
						local nameLower = string.lower(descendant.Name)
						if not (nameLower:find("viewmodel") or nameLower:find("camera") or nameLower:find("effect") or nameLower:find("weapon") or nameLower:find("gun") or nameLower:find("item") or nameLower:find("drop")) then
							if descendant:FindFirstChild("Head") or descendant:FindFirstChild("UpperTorso") or descendant:FindFirstChild("Torso") then
								local hum = descendant:FindFirstChildOfClass("Humanoid")
								if hum and hum.Health > 0 then
									if not (IgnoreDead_Enabled and not isEntityAlive(descendant)) then
										table.insert(targets, descendant)
									end
								end
							end
						end
					end
				end
				pcall(function()
					if #descendant:GetChildren() > 0 then
						scanFolder(descendant)
					end
				end)
			end
		end
		scanFolder(workspace)
	end

	return targets
end

local function checkEnemiesBehind()
	if not BehindWarning_Enabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return nil, 999
	end

	local myHRP = LocalPlayer.Character.HumanoidRootPart
	local myLookVector = myHRP.CFrame.LookVector
	local closestEntityName = nil
	local closestDist = 99999

	for _, char in ipairs(getAllTargetCharacters()) do
		local enemyHRP = char:FindFirstChild("HumanoidRootPart")
		if enemyHRP then
			if IgnoreDead_Enabled and not isEntityAlive(char) then continue end
			local dirToEnemy = (enemyHRP.Position - myHRP.Position)
			local dist = dirToEnemy.Magnitude

			if dist <= Behind_Distance then
				local dotProduct = myLookVector:Dot(dirToEnemy.Unit)
				if dotProduct < -0.3 then
					if dist < closestDist then
						closestDist = dist
						closestEntityName = char.Name
					end
				end
			end
		end
	end

	return closestEntityName, math.floor(closestDist)
end

local function getCenterScreenPos()
	local viewportSize = Camera.ViewportSize
	local inset = GuiService:GetGuiInset()
	return Vector2.new(viewportSize.X / 2, (viewportSize.Y / 2) - inset.Y)
end

local function getClosestTarget()
	local closestChar = nil
	local shortestDistance = FOV_Radius
	local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, char in ipairs(getAllTargetCharacters()) do
		if IgnoreDead_Enabled and not isEntityAlive(char) then continue end

		local targetPart = getTargetPart(char)
		if not targetPart then continue end
		if not isTargetVisible(targetPart) then continue end

		local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
		if onScreen and screenPos.Z > 0 then
			local targetVector = Vector2.new(screenPos.X, screenPos.Y)
			local dist = (targetVector - centerPos).Magnitude

			if dist <= shortestDistance then
				shortestDistance = dist
				closestChar = char
			end
		end
	end
	return closestChar
end

--------------------------------------------------------------------------------
-- REGISTER CONTROLS
--------------------------------------------------------------------------------

createToggle("Sticky Aim", "Locks onto targets inside FOV", false, function(state)
	StickyAim_Enabled = state
	FOVFrame.Visible = state
	if not state then LockTarget = nil end
end)

createToggle("Target Bots", "Include NPCs and dummies in aim/ESP", false, function(state)
	TargetBots_Enabled = state
end)

createSlider("FOV Radius", 40, 300, FOV_Radius, function(val)
	FOV_Radius = val
end)

createSlider("Aim Smoothness", 1, 100, math.floor(Aim_Smoothness * 100), function(val, rel)
	Aim_Smoothness = math.clamp(rel, 0.05, 1.0)
end)

createToggle("Wall Check", "Only aim at visible players/bots", false, function(state)
	WallCheck_Enabled = state
	if state and LockTarget then
		local part = getTargetPart(LockTarget)
		if not isTargetVisible(part) then LockTarget = nil end
	end
end)

createToggle("Behind Warning", "Alerts when enemies are behind you", false, function(state)
	BehindWarning_Enabled = state
	if not state then warningFrame.Visible = false end
end)

createSlider("Warning Range", 10, 100, Behind_Distance, function(val)
	Behind_Distance = val
end)

createToggle("Ignore Dead", "Ignore ragdolled or downed targets", false, function(state)
	IgnoreDead_Enabled = state
end)

createToggle("Team Check", "Ignore players on your team", false, function(state)
	TeamCheck_Enabled = state
end)

createToggle("Visual ESP", "Highlights all enemies and bots", false, function(state)
	VisualESP_Enabled = state
end)

--------------------------------------------------------------------------------
-- MAIN RENDER LOOP
--------------------------------------------------------------------------------

RunService.RenderStepped:Connect(function(deltaTime)
	local centerScreen = getCenterScreenPos()
	FOVFrame.Size = UDim2.new(0, FOV_Radius * 2, 0, FOV_Radius * 2)
	FOVFrame.Position = UDim2.new(0, centerScreen.X, 0, centerScreen.Y)

	if BehindWarning_Enabled then
		local entityName, distance = checkEnemiesBehind()
		if entityName and distance <= Behind_Distance then
			warningText.Text = "⚠️ " .. string.upper(entityName) .. " (" .. distance .. "m)"
			warningFrame.Visible = true
		else
			warningFrame.Visible = false
		end
	else
		warningFrame.Visible = false
	end

	if StickyAim_Enabled then
		if LockTarget and IgnoreDead_Enabled and not isEntityAlive(LockTarget) then
			LockTarget = nil
		end

		local targetPart = LockTarget and getTargetPart(LockTarget)
		local isValidTarget = LockTarget and isEntityAlive(LockTarget) and targetPart

		if isValidTarget and WallCheck_Enabled and not isTargetVisible(targetPart) then
			isValidTarget = false
		end

		if not isValidTarget then
			LockTarget = getClosestTarget()
			targetPart = LockTarget and getTargetPart(LockTarget)
		end

		if LockTarget and targetPart then
			local targetPos = targetPart.Position
			local hrp = LockTarget:FindFirstChild("HumanoidRootPart")
			if hrp and hrp.Velocity then
				targetPos = targetPos + (hrp.Velocity * (deltaTime * 1.2))
			end

			local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
			if onScreen and screenPos.Z > 0 then
				local currentCFrame = Camera.CFrame
				local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPos)
				local smoothFactor = math.clamp(Aim_Smoothness * 35 * deltaTime, 0.01, 1)
				Camera.CFrame = currentCFrame:Lerp(targetCFrame, smoothFactor)
				
				-- FOV circle turns Blue when target locked
				FOVStroke.Color = Color3.fromRGB(10, 132, 255)
			else
				LockTarget = nil
				-- FOV circle turns White when no target inside
				FOVStroke.Color = UI_TextPrimary
			end
		else
			-- FOV circle turns White when no target inside
			FOVStroke.Color = UI_TextPrimary
		end
	end

	for _, char in ipairs(getAllTargetCharacters()) do
		if VisualESP_Enabled and char and char:FindFirstChild("HumanoidRootPart") then
			local alive = isEntityAlive(char)
			if IgnoreDead_Enabled and not alive then
				local highlight = char:FindFirstChild("ESPHighlight")
				if highlight then highlight.Enabled = false end
			else
				local highlight = char:FindFirstChild("ESPHighlight")
				if not highlight then
					highlight = Instance.new("Highlight")
					highlight.Name = "ESPHighlight"
					highlight.Adornee = char
					highlight.Parent = char
				end
				highlight.Enabled = true
				highlight.FillTransparency = 0.5
				highlight.OutlineTransparency = 0
				highlight.FillColor = alive and Color3.fromRGB(240, 242, 248) or Color3.fromRGB(100, 115, 130)
			end
		else
			if char and char:FindFirstChild("ESPHighlight") then
				char.ESPHighlight.Enabled = false
			end
		end
	end
end)
