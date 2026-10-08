local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------------------------------------
-- CONFIGURATION & STATE (ALL DEFAULT TO OFF)
--------------------------------------------------------------------------------

local StickyAim_Enabled = false
local WallCheck_Enabled = false
local IgnoreDead_Enabled = false
local TeamCheck_Enabled = false
local VisualESP_Enabled = false
local BehindWarning_Enabled = false

local FOV_Radius = 82
local Aim_Smoothness = 0.25
local Behind_Distance = 30
local LockTarget = nil

-- Theme Palette (Matches Image Aesthetic)
local UI_BgColor = Color3.fromRGB(10, 12, 16)
local UI_CardColor = Color3.fromRGB(16, 18, 24)
local UI_CardBorder = Color3.fromRGB(35, 40, 50)
local UI_TextPrimary = Color3.fromRGB(240, 242, 248)
local UI_TextSecondary = Color3.fromRGB(130, 138, 155)
local UI_ToggleOn = Color3.fromRGB(240, 242, 248)
local UI_ToggleOff = Color3.fromRGB(25, 28, 36)
local UI_WarningRed = Color3.fromRGB(255, 60, 80)

--------------------------------------------------------------------------------
-- GUI SETUP
--------------------------------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GabsPanel_Sleek"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = PlayerGui

-- Redesigned Themed Warning Box (Matches GUI Card Aesthetic)
local warningFrame = Instance.new("Frame")
warningFrame.Name = "WarningFrame"
warningFrame.Size = UDim2.new(0, 210, 0, 38)
warningFrame.Position = UDim2.new(0.5, -105, 0.1, 0)
warningFrame.BackgroundColor3 = UI_CardColor
warningFrame.BorderSizePixel = 0
warningFrame.Active = true
warningFrame.Draggable = true
warningFrame.Visible = false
warningFrame.Parent = screenGui

local warningCorner = Instance.new("UICorner")
warningCorner.CornerRadius = UDim.new(0, 10)
warningCorner.Parent = warningFrame

local warningStroke = Instance.new("UIStroke")
warningStroke.Color = UI_CardBorder
warningStroke.Thickness = 1
warningStroke.Parent = warningFrame

-- Warning Red Accent Indicator Dot
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
warningText.Font = Enum.Font.GothamBold
warningText.TextSize = 10
warningText.TextXAlignment = Enum.TextXAlignment.Left
warningText.TextTruncate = Enum.TextTruncate.AtEnd
warningText.Parent = warningFrame

-- Mobile Floating Re-open Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "MobileToggleBtn"
toggleBtn.Size = UDim2.new(0, 48, 0, 48)
toggleBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
toggleBtn.BackgroundColor3 = UI_BgColor
toggleBtn.Text = "GAB"
toggleBtn.TextColor3 = UI_TextPrimary
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 13
toggleBtn.Active = true
toggleBtn.Draggable = true
toggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 12)
toggleCorner.Parent = toggleBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = UI_CardBorder
toggleStroke.Thickness = 1.5
toggleStroke.Parent = toggleBtn

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 520, 0, 360)
mainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
mainFrame.BackgroundColor3 = UI_BgColor
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = UI_CardBorder
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

-- Title Header
local headerTitle = Instance.new("TextLabel")
headerTitle.Size = UDim2.new(0, 250, 0, 40)
headerTitle.Position = UDim2.new(0, 20, 0, 8)
headerTitle.BackgroundTransparency = 1
headerTitle.Text = "GAB | PANEL"
headerTitle.TextColor3 = UI_TextPrimary
headerTitle.Font = Enum.Font.GothamBold
headerTitle.TextSize = 16
headerTitle.TextXAlignment = Enum.TextXAlignment.Left
headerTitle.Parent = mainFrame

-- Top Right Window Buttons (- and X)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -38, 0, 12)
closeBtn.BackgroundColor3 = UI_CardColor
closeBtn.Text = "✕"
closeBtn.TextColor3 = UI_TextSecondary
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 12
closeBtn.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

local closeStroke = Instance.new("UIStroke")
closeStroke.Color = UI_CardBorder
closeStroke.Thickness = 1
closeStroke.Parent = closeBtn

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 28)
minBtn.Position = UDim2.new(1, -72, 0, 12)
minBtn.BackgroundColor3 = UI_CardColor
minBtn.Text = "—"
minBtn.TextColor3 = UI_TextSecondary
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 12
minBtn.Parent = mainFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 8)
minCorner.Parent = minBtn

local minStroke = Instance.new("UIStroke")
minStroke.Color = UI_CardBorder
minStroke.Thickness = 1
minStroke.Parent = minBtn

closeBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)

minBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = false
end)

toggleBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

-- Layout Columns
local featuresList = Instance.new("ScrollingFrame")
featuresList.Size = UDim2.new(0, 290, 1, -60)
featuresList.Position = UDim2.new(0, 20, 0, 48)
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
profileCard.Parent = mainFrame

local profileCorner = Instance.new("UICorner")
profileCorner.CornerRadius = UDim.new(0, 16)
profileCorner.Parent = profileCard

local profileStroke = Instance.new("UIStroke")
profileStroke.Color = UI_CardBorder
profileStroke.Thickness = 1
profileStroke.Parent = profileCard

-- Avatar Circle
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
avatarStroke.Thickness = 2
avatarStroke.Parent = avatarFrame

-- Fetch Player Avatar
task.spawn(function()
	local content, isLoaded = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
	if isLoaded then
		avatarFrame.Image = content
	end
end)

-- Profile Info Texts
local function addProfileText(titleText, valText, yPos)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 14)
	label.Position = UDim2.new(0, 10, 0, yPos)
	label.BackgroundTransparency = 1
	label.Text = titleText .. "   " .. valText
	label.TextColor3 = UI_TextSecondary
	label.Font = Enum.Font.GothamSemibold
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
-- UI COMPONENTS (TOGGLES & SLIDERS)
--------------------------------------------------------------------------------

local function createToggle(text, subtext, defaultState, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -8, 0, 38)
	card.BackgroundColor3 = UI_CardColor
	card.Parent = featuresList

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 10)
	cardCorner.Parent = card

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = UI_CardBorder
	cardStroke.Thickness = 1
	cardStroke.Parent = card

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -70, 0, 16)
	label.Position = UDim2.new(0, 12, 0, 4)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = UI_TextPrimary
	label.Font = Enum.Font.GothamBold
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = card

	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(1, -70, 0, 12)
	desc.Position = UDim2.new(0, 12, 0, 20)
	desc.BackgroundTransparency = 1
	desc.Text = subtext:upper()
	desc.TextColor3 = UI_TextSecondary
	desc.Font = Enum.Font.GothamSemibold
	desc.TextSize = 8
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.Parent = card

	local stateText = Instance.new("TextLabel")
	stateText.Size = UDim2.new(0, 22, 0, 16)
	stateText.Position = UDim2.new(1, -62, 0.5, -8)
	stateText.BackgroundTransparency = 1
	stateText.Text = defaultState and "ON" or "OFF"
	stateText.TextColor3 = UI_TextSecondary
	stateText.Font = Enum.Font.GothamBold
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
	switchStroke.Thickness = 1
	switchStroke.Parent = switchBg

	local switchDot = Instance.new("Frame")
	switchDot.Size = UDim2.new(0, 12, 0, 12)
	switchDot.Position = defaultState and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
	switchDot.BackgroundColor3 = defaultState and UI_BgColor or UI_TextSecondary
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
		local targetDotColor = state and UI_BgColor or UI_TextSecondary

		TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
		TweenService:Create(switchDot, TweenInfo.new(0.2), {Position = targetDotPos, BackgroundColor3 = targetDotColor}):Play()
		callback(state)
	end)
end

local function createSlider(titleText, minVal, maxVal, defaultVal, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, -8, 0, 44)
	card.BackgroundColor3 = UI_CardColor
	card.Parent = featuresList

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 10)
	cardCorner.Parent = card

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = UI_CardBorder
	cardStroke.Thickness = 1
	cardStroke.Parent = card

	local sliderTitle = Instance.new("TextLabel")
	sliderTitle.Size = UDim2.new(1, -70, 0, 16)
	sliderTitle.Position = UDim2.new(0, 12, 0, 6)
	sliderTitle.BackgroundTransparency = 1
	sliderTitle.Text = titleText
	sliderTitle.TextColor3 = UI_TextPrimary
	sliderTitle.Font = Enum.Font.GothamBold
	sliderTitle.TextSize = 11
	sliderTitle.TextXAlignment = Enum.TextXAlignment.Left
	sliderTitle.Parent = card

	local valLabel = Instance.new("TextLabel")
	valLabel.Size = UDim2.new(0, 50, 0, 16)
	valLabel.Position = UDim2.new(1, -62, 0, 6)
	valLabel.BackgroundTransparency = 1
	valLabel.Text = tostring(defaultVal)
	valLabel.TextColor3 = UI_TextSecondary
	valLabel.Font = Enum.Font.GothamBold
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
FOVStroke.Thickness = 1.5
FOVStroke.Parent = FOVFrame

--------------------------------------------------------------------------------
-- HIGH PERFORMANCE HELPER FUNCTIONS
--------------------------------------------------------------------------------

local function isPlayerAlive(player)
	if not player or not player.Character then return false end
	local char = player.Character
	
	if not char:IsDescendantOf(workspace) or char.Parent.Name == "Ragdolls" or char.Parent.Name == "Dead" then
		return false
	end

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
	if LocalPlayer.Character then
		table.insert(ignoreList, LocalPlayer.Character)
	end
	
	rayParams.FilterDescendantsInstances = ignoreList
	rayParams.IgnoreWater = true

	local origin = Camera.CFrame.Position
	local direction = targetPart.Position - origin
	local raycastResult = workspace:Raycast(origin, direction, rayParams)

	if raycastResult then
		if raycastResult.Instance:IsDescendantOf(targetPart.Parent) then
			return true
		end
		return false
	end

	return true
end

local function checkEnemiesBehind()
	if not BehindWarning_Enabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return nil, 0
	end

	local myHRP = LocalPlayer.Character.HumanoidRootPart
	local myLookVector = myHRP.CFrame.LookVector

	local closestEnemy = nil
	local closestDist = Behind_Distance

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and isPlayerAlive(player) then
			if TeamCheck_Enabled and player.Team and player.Team == LocalPlayer.Team then
				continue
			end

			local enemyHRP = player.Character:FindFirstChild("HumanoidRootPart")
			if enemyHRP then
				local dirToEnemy = (enemyHRP.Position - myHRP.Position)
				local dist = dirToEnemy.Magnitude

				if dist <= Behind_Distance then
					local dotProduct = myLookVector:Dot(dirToEnemy.Unit)
					if dotProduct < -0.3 then
						if dist < closestDist then
							closestDist = dist
							closestEnemy = player
						end
					end
				end
			end
		end
	end

	return closestEnemy, math.floor(closestDist)
end

local function getCenterScreenPos()
	local viewportSize = Camera.ViewportSize
	local inset = GuiService:GetGuiInset()
	return Vector2.new(viewportSize.X / 2, (viewportSize.Y / 2) - inset.Y)
end

local function getClosestTarget()
	local closestPlayer = nil
	local shortestDistance = FOV_Radius
	local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			if IgnoreDead_Enabled and not isPlayerAlive(player) then
				continue
			end

			if TeamCheck_Enabled and player.Team and player.Team == LocalPlayer.Team then
				continue
			end

			local targetPart = getTargetPart(player.Character)
			if not targetPart then continue end

			if not isTargetVisible(targetPart) then
				continue
			end

			local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)

			if onScreen and screenPos.Z > 0 then
				local targetVector = Vector2.new(screenPos.X, screenPos.Y)
				local dist = (targetVector - centerPos).Magnitude

				if dist <= shortestDistance then
					shortestDistance = dist
					closestPlayer = player
				end
			end
		end
	end
	return closestPlayer
end

--------------------------------------------------------------------------------
-- REGISTER CONTROLS
--------------------------------------------------------------------------------

createToggle("Sticky Aim", "Locks onto targets inside FOV", false, function(state)
	StickyAim_Enabled = state
	FOVFrame.Visible = state
	if not state then LockTarget = nil end
end)

createSlider("FOV Radius", 40, 300, FOV_Radius, function(val)
	FOV_Radius = val
end)

createSlider("Aim Smoothness", 1, 100, math.floor(Aim_Smoothness * 100), function(val, rel)
	Aim_Smoothness = math.clamp(rel, 0.05, 1.0)
end)

createToggle("Wall Check", "Only aim at visible players", false, function(state)
	WallCheck_Enabled = state
	if state and LockTarget and LockTarget.Character then
		local part = getTargetPart(LockTarget.Character)
		if not isTargetVisible(part) then
			LockTarget = nil
		end
	end
end)

createToggle("Behind Warning", "Alerts when enemies are behind you", false, function(state)
	BehindWarning_Enabled = state
	if not state then warningFrame.Visible = false end
end)

createSlider("Warning Range", 10, 60, Behind_Distance, function(val)
	Behind_Distance = val
end)

createToggle("Ignore Dead", "Ignore ragdolled or downed players", false, function(state)
	IgnoreDead_Enabled = state
end)

createToggle("Team Check", "Ignore players on your team", false, function(state)
	TeamCheck_Enabled = state
end)

createToggle("Visual ESP", "Highlights all enemy players", false, function(state)
	VisualESP_Enabled = state
end)

--------------------------------------------------------------------------------
-- MAIN RENDER LOOP
--------------------------------------------------------------------------------

RunService.RenderStepped:Connect(function(deltaTime)
	local centerScreen = getCenterScreenPos()
	FOVFrame.Size = UDim2.new(0, FOV_Radius * 2, 0, FOV_Radius * 2)
	FOVFrame.Position = UDim2.new(0, centerScreen.X, 0, centerScreen.Y)

	-- Behind Warning Check
	if BehindWarning_Enabled then
		local enemyBehind, distance = checkEnemiesBehind()
		if enemyBehind then
			warningText.Text = "⚠️ " .. enemyBehind.DisplayName:upper() .. " (" .. distance .. "m)"
			warningFrame.Visible = true
		else
			warningFrame.Visible = false
		end
	else
		warningFrame.Visible = false
	end

	-- Sticky Aim Execution
	if StickyAim_Enabled then
		local targetPart = LockTarget and LockTarget.Character and getTargetPart(LockTarget.Character)
		local isValidTarget = LockTarget and isPlayerAlive(LockTarget) and targetPart

		if isValidTarget and WallCheck_Enabled and not isTargetVisible(targetPart) then
			isValidTarget = false
		end

		if not isValidTarget then
			LockTarget = getClosestTarget()
			targetPart = LockTarget and LockTarget.Character and getTargetPart(LockTarget.Character)
		end

		if LockTarget and targetPart then
			local targetPos = targetPart.Position

			local hrp = LockTarget.Character:FindFirstChild("HumanoidRootPart")
			if hrp and hrp.Velocity then
				targetPos = targetPos + (hrp.Velocity * (deltaTime * 1.2))
			end

			local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)

			if onScreen and screenPos.Z > 0 then
				local currentCFrame = Camera.CFrame
				local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPos)
				
				local smoothFactor = math.clamp(Aim_Smoothness * 35 * deltaTime, 0.01, 1)
				Camera.CFrame = currentCFrame:Lerp(targetCFrame, smoothFactor)

				FOVStroke.Color = Color3.fromRGB(0, 255, 150)
			else
				LockTarget = nil
				FOVStroke.Color = UI_TextPrimary
			end
		else
			FOVStroke.Color = UI_TextPrimary
		end
	end

	-- ESP Highlights Execution
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			if VisualESP_Enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				local isSameTeam = TeamCheck_Enabled and player.Team and player.Team == LocalPlayer.Team
				local alive = isPlayerAlive(player)

				if not isSameTeam and (not IgnoreDead_Enabled or alive) then
					local highlight = player.Character:FindFirstChild("ESPHighlight")
					if not highlight then
						highlight = Instance.new("Highlight")
						highlight.Name = "ESPHighlight"
						highlight.FillTransparency = 0.5
						highlight.OutlineTransparency = 0
						highlight.Parent = player.Character
					end

					highlight.Enabled = true
					highlight.FillColor = alive and Color3.fromRGB(240, 242, 248) or Color3.fromRGB(100, 115, 130)
				else
					if player.Character and player.Character:FindFirstChild("ESPHighlight") then
						player.Character.ESPHighlight.Enabled = false
					end
				end
			else
				if player.Character and player.Character:FindFirstChild("ESPHighlight") then
					player.Character.ESPHighlight.Enabled = false
				end
			end
		end
	end
end)
