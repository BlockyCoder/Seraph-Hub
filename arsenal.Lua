
--The codes aren't mine!! i changed the UI ONLY!! i found it on the internet!

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/BlockyCoder/Seraph-Hub/main/Ui Libarary: Seraph Hub"))()

local Window = Library:Create("The Example UI for the script! ?")

-- Tabs
local Combat = Library:Tab("Combat")
local GunMods = Library:Tab("GunMods")
local Player = Library:Tab("Player")
local Misc = Library:Tab("Misc")


-- Silent Aim
Library:Button(Combat, "Silent Aim", function()
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Silent Aim",
		Text = "Silent Aim Activated",
		Duration = 5
	})

	local Camera = workspace.CurrentCamera
	local Players = game.Players
	local LocalPlayer = Players.LocalPlayer

	function GetClosestEnemy()
		local closest, shortestDistance = nil, math.huge
		for _, player in pairs(Players:GetPlayers()) do
			if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character then
				local head = player.Character:FindFirstChild("Head")
				if head then
					local screenPos, visible = Camera:WorldToScreenPoint(head.Position)
					local mousePosition = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
					local distance = (mousePosition - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
					if visible and distance < shortestDistance then
						closest = player
						shortestDistance = distance
					end
				end
			end
		end
		return closest
	end

	local mt = getrawmetatable(game)
	local originalNamecall = mt.__namecall
	setreadonly(mt, false)

	mt.__namecall = newcclosure(function(self, ...)
		local args = { ... }
		local method = getnamecallmethod()
		if method == "FindPartOnRayWithIgnoreList" and not checkcaller() then
			local enemy = GetClosestEnemy()
			if enemy and enemy.Character then
				local head = enemy.Character:FindFirstChild("Head")
				if head then
					args[1] = Ray.new(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 1000)
					return originalNamecall(self, unpack(args))
				end
			end
		end
		return originalNamecall(self, ...)
	end)

	setreadonly(mt, true)
end)

-- Aimbot Toggle
Library:Toggle(Combat, "Aimbot", function(state)
	getgenv().Options.Enabled = state
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera
local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
local Inset = GuiService:GetGuiInset()
local Down = false

getgenv().Options = {
	Enabled = false,
	TeamCheck = true,
	Smoothness = 0.1,
	AimPart = "Head",
	FOV = 150
}

local function GetClosestEnemy()
	local nearest, nearestPlayer = math.huge, nil
	for _, v in pairs(Players:GetPlayers()) do
		if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild(getgenv().Options.AimPart) then
			if not getgenv().Options.TeamCheck or v.Team ~= LocalPlayer.Team then
				local pos, onScreen = Camera:WorldToScreenPoint(v.Character[getgenv().Options.AimPart].Position)
				local dist = (Vector2.new(pos.X, pos.Y) - ScreenCenter).Magnitude
				if onScreen and dist < nearest and dist < getgenv().Options.FOV then
					nearest, nearestPlayer = dist, v
				end
			end
		end
	end
	return nearestPlayer
end

local FOVCircle = Drawing.new("Circle")
FOVCircle.Transparency = 1
FOVCircle.Thickness = 1.5
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.NumSides = 150
FOVCircle.Radius = getgenv().Options.FOV

UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		Down = true
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		Down = false
	end
end)

RunService.RenderStepped:Connect(function()
	FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + Inset.Y)
	FOVCircle.Visible = getgenv().Options.Enabled

	if getgenv().Options.Enabled and Down then
		local target = GetClosestEnemy()
		if target and target.Character:FindFirstChild(getgenv().Options.AimPart) then
			local aimPos = target.Character[getgenv().Options.AimPart].Position
			local info = TweenInfo.new(getgenv().Options.Smoothness, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
			TweenService:Create(Camera, info, {CFrame = CFrame.new(Camera.CFrame.p, aimPos)}):Play()
		end
	end
end)


-- Aimlock Function

local LocalPlayer = game.Players.LocalPlayer
local AimlockEnabled = false
local SilentAimEnabled = false
local currentTarget = nil
local AimOptions = {
	Smoothness = 0.05,  -- Lower = Faster and more accurate
	AimPart = "Head",  
	TeamCheck = true,   
	WallCheck = true,   
	PredictionFactor = 12,  
	SpeedThreshold = 20,  
	MaximumHackSpeed = 500,  
	MinimumHeight = -500,  
	Keybind = Enum.KeyCode.C,  
	MultiTarget = true,  
	StrafeAssist = true,  
	TeleportAssist = true,   
	PingCompensation = true,  
	AimPredictionControl = 1.5,  
	WallbangEnabled = false,  -- Wallbang toggle
}

-- ✅ Toggle Aimlock via Keybind
game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == AimOptions.Keybind then
		AimlockEnabled = not AimlockEnabled
	end
end)

local function isEnemy(player)
	-- In FFA mode (no team), everyone is considered an enemy
	if LocalPlayer.Team == nil then
		return true
	end

	-- Regular team check
	if AimOptions.TeamCheck and LocalPlayer.Team and player.Team then
		return player.Team ~= LocalPlayer.Team
	end

	return true
end

-- Wall Check Logic
local function isTargetVisible(target)
	local cam = workspace.CurrentCamera
	local startPosition = cam.CFrame.Position
	local targetPosition = target.Character.PrimaryPart.Position
	local direction = (targetPosition - startPosition).unit
	local ray = Ray.new(startPosition, direction * 10000)
	local ignoreList = { LocalPlayer.Character }

	-- Wallbang logic: Always return true when Wallbang is enabled
	if AimOptions.WallbangEnabled then
		return true
	else
		-- Regular visibility check with raycast (only if Wallbang is disabled)
		local hit, _ = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList, false, true)
		return hit and hit.Parent == target.Character
	end
end

local function isTargetAboveGround(target)
	return target and target.Character and target.Character.PrimaryPart and target.Character.PrimaryPart.Position.Y >= AimOptions.MinimumHeight
end

local function getPingAdjustedPrediction(target)
	local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
	local adjustment = ping / 1000  
	return AimOptions.PingCompensation and (adjustment * AimOptions.AimPredictionControl) or 0
end

local function predictTargetPosition(target)
	if not target or not target.Character or not target.Character.PrimaryPart then return nil end

	local enemyVelocity = target.Character.PrimaryPart.Velocity
	local targetPos = target.Character.PrimaryPart.Position

	-- ✅ Separate horizontal and vertical speed
	local horizontalSpeed = Vector3.new(enemyVelocity.X, 0, enemyVelocity.Z).Magnitude  
	local verticalSpeed = math.abs(enemyVelocity.Y)  

	-- ✅ Ignore normal jumping/falling players (no prediction)
	if verticalSpeed > 20 and horizontalSpeed < 75 then
		return targetPos  -- ✅ No prediction for jumping/falling players
	end

	-- ✅ Only activate prediction if **enemy speed is hacker-level (extremely fast)**
	if horizontalSpeed > 150 then
		return targetPos + (enemyVelocity * AimOptions.PredictionFactor * 0.02) + Vector3.new(getPingAdjustedPrediction(target), 0, 0)
	else
		return targetPos  -- ✅ No prediction for normal fast players
	end
end

local function getBestTarget()
	local bestTarget = nil
	local bestDistance = math.huge

	for _, v in pairs(game.Players:GetPlayers()) do
		if v ~= LocalPlayer and v.Character and v.Character.PrimaryPart and isEnemy(v) then
			if AimOptions.WallCheck and not isTargetVisible(v) then continue end
			if not isTargetAboveGround(v) then continue end

			-- ✅ Correctly calculate velocity for prediction decision
			local velocity = v.Character.PrimaryPart.Velocity
			local horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude  

			-- ✅ Always use raw position; apply prediction **only if necessary**
			local predictedPos = predictTargetPosition(v)
			local rawPos = v.Character.PrimaryPart.Position

			-- ✅ Ensure Aimlock doesn't miss slow-moving enemies
			if horizontalSpeed < AimOptions.SpeedThreshold then
				predictedPos = rawPos  -- ✅ Use exact position for slow-moving targets
			end

			-- ✅ Prioritize closest enemy
			local distanceToTarget = (predictedPos - LocalPlayer.Character.PrimaryPart.Position).Magnitude
			if distanceToTarget < bestDistance then
				bestDistance = distanceToTarget
				bestTarget = v
			end
		end
	end
	return bestTarget
end

local function switchTargetIfNeeded()
	local bestTarget = getBestTarget()
	if bestTarget and bestTarget ~= currentTarget then
		currentTarget = bestTarget
	end
end

function AimLock()
	if not AimlockEnabled then return end

	if currentTarget and currentTarget.Character then
		if not isTargetVisible(currentTarget) or not isTargetAboveGround(currentTarget) then
			currentTarget = nil
		end
	end

	switchTargetIfNeeded()

	if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild(AimOptions.AimPart) then
		local targetPos = predictTargetPosition(currentTarget)
		if not targetPos then return end

		local cam = workspace.CurrentCamera
		local pos = cam.CFrame.Position

		if not SilentAimEnabled then
			cam.CFrame = CFrame.new(pos, targetPos)  -- Lock camera to the target
		end
	end
end

game.Players.PlayerRemoving:Connect(function(player)
	if player == currentTarget then
		currentTarget = nil
	end
end)

game:GetService("RunService").RenderStepped:Connect(function()
	if AimlockEnabled then
		AimLock()
	end
end)

--Library

-- ✅ UI Controls
Library:Toggle(Combat, "Aimlock", function(state)
	AimlockEnabled = state
end)

Library:Toggle(Combat, "Silent Aim", function(state)
	SilentAimEnabled = state
end)

Library:Toggle(Combat, "Wallbang",  function(state)
	AimOptions.WallbangEnabled = state
end)

Library:Toggle(Combat, "Wallcheck", function(state)
	AimOptions.WallCheck = state
end)

Library:Toggle(Combat, "Multi-Target Lock", function(state)
	AimOptions.MultiTarget = state
end)

Library:Toggle(Combat, "Strafe Aim Assist", function(state)
	AimOptions.StrafeAssist = state
end)

Library:Toggle(Combat, "Teleport Aim Assist", function(state)
	AimOptions.TeleportAssist = state
end)

Library:Toggle(Combat, "Ping Compensation", function(state)
	AimOptions.PingCompensation = state
end)

Library:Slider(Combat, "Smoothness",  0, 1, AimOptions.Smoothness, function(value)
	AimOptions.Smoothness = value
end)

Library:Slider(Combat, "Aim Prediction", 0, 2, AimOptions.AimPredictionControl, function(value)
	AimOptions.AimPredictionControl = value
end)

Library:Dropdown(Combat, "AimPart", {"Head", "HumanoidRootPart", "Torso"}, function(selected)
	AimOptions.AimPart = selected
end)

Library:Keybind(Combat, "Aim Keybind", AimOptions.Keybind, function()
	AimlockEnabled = not AimlockEnabled
end)


-- Hitbox Expander
Library:Button(Combat, "Hitbox Expander",  function()
	local Players = game:GetService("Players")
	local LocalPlayer = Players.LocalPlayer
	local Team = LocalPlayer.Team

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Team ~= Team and player.Character then
			local torso = player.Character:FindFirstChild("UpperTorso")
			if torso then
				torso.Size = Vector3.new(20, 20, 20)
				torso.Transparency = 0.7
				torso.CanCollide = false
			end
		end
	end
end)

Library:Toggle(Combat, "AutoFarm", function(bool)  
	getgenv().AutoFarm = bool

	local runServiceConnection
	local mouseDown = false
	local player = game.Players.LocalPlayer
	local camera = game.Workspace.CurrentCamera

	-- Set initial curse
	game:GetService("ReplicatedStorage").wkspc.CurrentCurse.Value = bool and "Infinite Ammo" or ""

	-- Function to get the closest player
	local function closestPlayer()
		local closestDistance = math.huge
		local closestPlayer = nil

		for _, enemyPlayer in pairs(game.Players:GetPlayers()) do
			if enemyPlayer ~= player and enemyPlayer.TeamColor ~= player.TeamColor and enemyPlayer.Character then
				local character = enemyPlayer.Character
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				local humanoid = character:FindFirstChild("Humanoid")
				if humanoidRootPart and humanoid and humanoid.Health > 0 then
					local distance = (player.Character.HumanoidRootPart.Position - humanoidRootPart.Position).Magnitude
					if distance < closestDistance then
						closestDistance = distance
						closestPlayer = enemyPlayer
					end
				end
			end
		end

		return closestPlayer
	end

	-- Function to perform autofarming actions
	local function AutoFarm()
		game:GetService("ReplicatedStorage").wkspc.TimeScale.Value = 12

		runServiceConnection = game:GetService("RunService").Stepped:Connect(function()
			if getgenv().AutoFarm then
				local closestPlayer = closestPlayer()
				if closestPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
					local enemyRootPart = closestPlayer.Character.HumanoidRootPart

					local targetPosition = enemyRootPart.Position - enemyRootPart.CFrame.LookVector * 2 + Vector3.new(0, 2, 0)
					player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)

					-- Face camera towards enemy's head
					if closestPlayer.Character:FindFirstChild("Head") then
						local enemyHead = closestPlayer.Character.Head.Position
						camera.CFrame = CFrame.new(camera.CFrame.Position, enemyHead)
					end

					-- Trigger mouse click only if not already pressed
					if not mouseDown then
						mouse1press()
						mouseDown = true
					end
				else
					-- Release mouse if no player is found
					if mouseDown then
						mouse1release()
						mouseDown = false
					end
				end
			else
				-- Stop autofarm and release mouse
				if runServiceConnection then
					runServiceConnection:Disconnect()
					runServiceConnection = nil
				end
				if mouseDown then
					mouse1release()
					mouseDown = false
				end
			end
		end)
	end

	-- Start autofarming when character is added
	local function onCharacterAdded(character)
		wait(0.5)
		AutoFarm()
	end

	-- Listen for character addition and start autofarm
	player.CharacterAdded:Connect(onCharacterAdded)

	-- Toggle the AutoFarm
	if bool then
		wait(0.5)
		AutoFarm()
	else
		-- Reset values when toggled off
		game:GetService("ReplicatedStorage").wkspc.CurrentCurse.Value = ""
		getgenv().AutoFarm = false
		game:GetService("ReplicatedStorage").wkspc.TimeScale.Value = 1
		if runServiceConnection then
			runServiceConnection:Disconnect()
			runServiceConnection = nil
		end
		if mouseDown then
			mouse1release()
			mouseDown = false
		end
	end
end)




-- RapidFire
Library:Button(GunMods, "RapidFire", function()
	local Weapons = game:GetService("ReplicatedStorage"):FindFirstChild("Weapons")
	if Weapons then
		for _, weapon in pairs(Weapons:GetDescendants()) do
			if weapon:IsA("NumberValue") then
				if weapon.Name == "FireRate" then
					weapon.Value = 0.05
				end
				if weapon.Name == "ReloadTime" then
					weapon.Value = 0
				end
			end
		end
	end
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "Rapid Fire",
		Text = "Rapid Fire Activated",
		Durati
	})
end)

Library:Toggle(GunMods, "Always Auto", function(state)
	for _, v in pairs(game.ReplicatedStorage.Weapons:GetDescendants()) do
		if v.Name == "Auto" or v.Name == "AutoFire" or v.Name == "Automatic" or v.Name == "AutoShoot" or v.Name == "AutoGun" then
			if state then
				if not originalValues.Auto[v] then
					originalValues.Auto[v] = v.Value
				end
				v.Value = true
			else
				if originalValues.Auto[v] then
					v.Value = originalValues.Auto[v]
				else
					v.Value = false 
				end
			end
		end
	end
end)

Library:Toggle(GunMods, "No Spread", function(state)
	for _, v in pairs(game:GetService("ReplicatedStorage").Weapons:GetDescendants()) do
		if v.Name == "MaxSpread" or v.Name == "Spread" or v.Name == "SpreadControl" then
			if state then
				if not originalValues.Spread[v] then
					originalValues.Spread[v] = v.Value
				end
				v.Value = 0
			else
				if originalValues.Spread[v] then
					v.Value = originalValues.Spread[v]
				else
					v.Value = 1 
				end
			end
		end
	end
end)

Library:Toggle(GunMods, "No Recoil", function(state)
	for _, v in pairs(game:GetService("ReplicatedStorage").Weapons:GetDescendants()) do
		if v.Name == "RecoilControl" or v.Name == "Recoil" then
			if state then
				if not originalValues.Recoil[v] then
					originalValues.Recoil[v] = v.Value
				end
				v.Value = 0
			else
				if originalValues.Recoil[v] then
					v.Value = originalValues.Recoil[v]
				else
					v.Value = 1 
				end
			end
		end
	end
end)



Library:Button(GunMods, "RGB GUN", function()

	game:GetService("StarterGui"):SetCore("SendNotification",{

		Title = "RGB gun has been executed lol",

		Text = "RBG = More fps (Joke)", 

		Durati

	})

	local c = 1 function zigzag(X)  return math.acos(math.cos(X * math.pi)) / math.pi end game:GetService("RunService").RenderStepped:Connect(function()  if game.Workspace.Camera:FindFirstChild('Arms') then   for i,v in pairs(game.Workspace.Camera.Arms:GetDescendants()) do    if v.ClassName == 'MeshPart' then      v.Color = Color3.fromHSV(zigzag(c),1,1)     c = c + .0001    end   end  end end)

end)

Library:Button(GunMods, "Inf Ammo", function()

	while wait() do

		game:GetService("Players").LocalPlayer.PlayerGui.GUI.Client.Variables.ammocount.Value = 999

		game:GetService("Players").LocalPlayer.PlayerGui.GUI.Client.Variables.ammocount2.Value = 999

	end 

end)

Library:Keybind(GunMods, "KeybindText", Enum.KeyCode.F, function()
	Library:ToggleUI()
end)

Library:Button(Player, "Inf Jump", function()


	-- Instances:

	local DropGUI = Instance.new("ScreenGui")

	local main = Instance.new("Frame")

	local DropTool = Instance.new("TextButton")

	--Properties:

	DropGUI.Name = "Drop GUI"

	DropGUI.Parent = game.CoreGui

	DropGUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

	main.Name = "main"

	main.Parent = DropGUI

	main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

	main.Position = UDim2.new(0.0809101239, 0, 0.203790441, 0)

	main.Size = UDim2.new(0, 100, 0, 100)

	main.Active = true

	main.Draggable = true

	DropTool.Name = "Drop Tool"

	DropTool.Parent = main

	DropTool.BackgroundColor3 = Color3.fromRGB(350, 0, 0)

	DropTool.Position = UDim2.new(0.0597826242, 0, 0.119906127, 0)

	DropTool.Size = UDim2.new(0, 80, 0, 80)

	DropTool.Font = Enum.Font.SourceSans

	DropTool.Text = "^"

	DropTool.TextColor3 = Color3.fromRGB(0, 0, 0)

	DropTool.TextScaled = true

	DropTool.TextSize = 14.000

	DropTool.TextWrapped = true

	DropTool.MouseButton1Down:Connect(function()

		local InfiniteJumpEnabled = true

		game:GetService("UserInputService").JumpRequest:connect(function()

			if InfiniteJumpEnabled then

				game:GetService"Players".LocalPlayer.Character:FindFirstChildOfClass'Humanoid':ChangeState("Jumping")

			end

		end)

		game:GetService"Players".LocalPlayer.Character:FindFirstChildOfClass'Humanoid':ChangeState("Jumping")

	end)

end)

Library:Button(Player, "Invisible", function()

	loadstring(game:HttpGet(('https://raw.githubusercontent.com/Cesare0328/my-scripts/main/arsenal updated invis.lua'),true))()

end)

players = {}

for i, v in pairs(game:GetService("Players"):GetChildren()) do
    if v.Name ~= game.Players.LocalPlayer.Name then -- Exclude the local player
        table.insert(players, v.Name)
    end
end

	Library:Dropdown(Player, "Select Player", players, function(abc)
		Select = abc
	end)


	Library:Button(Player, "Refresh", function()
	table.clear(players)
    for i, v in pairs(game:GetService("Players"):GetChildren()) do
        if v.Name ~= game.Players.LocalPlayer.Name then -- Exclude the local player
            table.insert(players, v.Name)
        end
    end
end)

	Library:Button(Player, "Teleport",function()
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = game.Players[Select].Character.HumanoidRootPart.CFrame
	end)


	Library:Toggle(Player, "Toggle Xray", function(enabled) -- xray go brrrrrrrr
		xrayOn = enabled

		if xrayOn then
			for _, descendant in pairs(workspace:GetDescendants()) do
				if descendant:IsA("BasePart") then
					if not descendant:FindFirstChild("OriginalTransparency") then
						local originalTransparency = Instance.new("NumberValue")
						originalTransparency.Name = "OriginalTransparency"
						originalTransparency.Value = descendant.Transparency
						originalTransparency.Parent = descendant
					end
					descendant.Transparency = 0.5
				end
			end
		else
			for _, descendant in pairs(workspace:GetDescendants()) do
				if descendant:IsA("BasePart") then
					if descendant:FindFirstChild("OriginalTransparency") then
						descendant.Transparency = descendant.OriginalTransparency.Value
						descendant.OriginalTransparency:Destroy()
					end
				end
			end
		end
	end)

	-- Flying Script

	local flySettings = {fly = false, flyspeed = 50}
	local c, h, bv, bav, cam, flying
	local p = game.Players.LocalPlayer
	local buttons = {W = false, S = false, A = false, D = false, Moving = false}

	local function startFly()
		if not p.Character or not p.Character.Head or flying then return end
		c = p.Character
		h = c.Humanoid
		h.PlatformStand = true
		cam = workspace:WaitForChild('Camera')
		bv = Instance.new("BodyVelocity")
		bav = Instance.new("BodyAngularVelocity")
		bv.Velocity, bv.MaxForce, bv.P = Vector3.new(0, 0, 0), Vector3.new(10000, 10000, 10000), 1000
		bav.AngularVelocity, bav.MaxTorque, bav.P = Vector3.new(0, 0, 0), Vector3.new(10000, 10000, 10000), 1000
		bv.Parent = c.Head
		bav.Parent = c.Head
		flying = true
		h.Died:Connect(function()
			flying = false
		end)
	end

	local function endFly()
		if not p.Character or not flying then return end
		h.PlatformStand = false
		bv:Destroy()
		bav:Destroy()
		flying = false
	end

	game:GetService("UserInputService").InputBegan:Connect(function(input, GPE)
		if GPE then return end
		for i, e in pairs(buttons) do
			if i ~= "Moving" and input.KeyCode == Enum.KeyCode[i] then
				buttons[i] = true
				buttons.Moving = true
			end
		end
	end)

	game:GetService("UserInputService").InputEnded:Connect(function(input, GPE)
		if GPE then return end
		local a = false
		for i, e in pairs(buttons) do
			if i ~= "Moving" then
				if input.KeyCode == Enum.KeyCode[i] then
					buttons[i] = false
				end
				if buttons[i] then
					a = true
				end
			end
		end
		buttons.Moving = a
	end)

	local function setVec(vec)
		return vec * (flySettings.flyspeed / vec.Magnitude)
	end

	game:GetService("RunService").Heartbeat:Connect(function(step)
		if flying and c and c.PrimaryPart then
			local p = c.PrimaryPart.Position
			local cf = cam.CFrame
			local ax, ay, az = cf:toEulerAnglesXYZ()
			c:SetPrimaryPartCFrame(CFrame.new(p.x, p.y, p.z) * CFrame.Angles(ax, ay, az))
			if buttons.Moving then
				local t = Vector3.new()
				if buttons.W then t = t + (setVec(cf.lookVector)) end
				if buttons.S then t = t - (setVec(cf.lookVector)) end
				if buttons.A then t = t - (setVec(cf.rightVector)) end
				if buttons.D then t = t + (setVec(cf.rightVector)) end
				c:TranslateBy(t * step)
			end
		end
	end)

	Library:Toggle(Player, "Fly", function(state)
		if state then
			startFly()
		else
			endFly()
		end
	end)

	Library:Slider(Player, "Fly Speed", 500, 1, function(s)
		flySettings.flyspeed = s
	end)


	Library:Button(Misc, "Fps Booster", function()

		local decalsyeeted = true -- Leaving this on makes games look shitty but the fps goes up by at least 20.

		local g = game

		local w = g.Workspace

		local l = g.Lighting

		local t = w.Terrain

		t.WaterWaveSize = 0

		t.WaterWaveSpeed = 0

		t.WaterReflectance = 0

		t.WaterTransparency = 0

		l.GlobalShadows = false

		l.FogEnd = 9e9

		l.Brightness = 0

		settings().Rendering.QualityLevel = "Level01"

		for i, v in pairs(g:GetDescendants()) do

			if v:IsA("Part") or v:IsA("Union") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then

				v.Material = "Plastic"

				v.Reflectance = 0

			elseif v:IsA("Decal") or v:IsA("Texture") and decalsyeeted then

				v.Transparency = 1

			elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then

				v.Lifetime = NumberRange.new(0)

			elseif v:IsA("Explosion") then

				v.BlastPressure = 1

				v.BlastRadius = 1

			elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") then

				v.Enabled = false

			elseif v:IsA("MeshPart") then

				v.Material = "Plastic"

				v.Reflectance = 0

				v.TextureID = 10385902758728957

			end

		end

		for i, e in pairs(l:GetChildren()) do

			if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then

				e.Enabled = false

			end

		end

	end)

	-- Add this to your Misc section
	Library:Label(Misc, "Chat") -- fun i guess

	Library:Toggle(Misc, "IsChad", function(x)
		if game.Players.LocalPlayer:FindFirstChild('IsChad') then
			game.Players.LocalPlayer.IsChad:Destroy()
			return
		end
		if x then
			local IsMod = Instance.new('IntValue', game.Players.LocalPlayer)
			IsMod.Name = "IsChad"
		end
	end)

	Library:Toggle(Misc, "VIP", function(x)
		if game.Players.LocalPlayer:FindFirstChild('VIP') then
			game.Players.LocalPlayer.VIP:Destroy()
			return
		end
		if x then
			local IsMod = Instance.new('IntValue', game.Players.LocalPlayer)
			IsMod.Name = "VIP"
		end
	end)

	Library:Toggle(Misc, "OldVIP", function(x)
		if game.Players.LocalPlayer:FindFirstChild('OldVIP') then
			game.Players.LocalPlayer.OldVIP:Destroy()
			return
		end
		if x then
			local IsMod = Instance.new('IntValue', game.Players.LocalPlayer)
			IsMod.Name = "OldVIP"
		end
	end)

	Library:Toggle(Misc, "Romin", function(x)
		if game.Players.LocalPlayer:FindFirstChild('Romin') then
			game.Players.LocalPlayer.Romin:Destroy()
			return
		end
		if x then
			local IsAdmin = Instance.new('IntValue', game.Players.LocalPlayer)
			IsAdmin.Name = "Romin"
		end
	end)

	Library:Toggle(Misc, "IsAdmin", function(x)
		if game.Players.LocalPlayer:FindFirstChild('IsAdmin') then
			game.Players.LocalPlayer.IsAdmin:Destroy()
			return
		end
		if x then
			local IsAdmin = Instance.new('IntValue', game.Players.LocalPlayer)
			IsAdmin.Name = "IsAdmin"
		end
	end)

	Library:Button(Misc, "FullBright", function()

		local Light = game:GetService("Lighting")

		function dofullbright()

			Light.Ambient = Color3.new(1, 1, 1)

			Light.ColorShift_Bottom = Color3.new(1, 1, 1)

			Light.ColorShift_Top = Color3.new(1, 1, 1)

		end

		dofullbright()

		Light.LightingChanged:Connect(dofullbright)

	end)

	Library:Button(Misc, "Esp", function()
		_G.FriendColor = Color3.fromRGB(0, 0, 255)
		_G.EnemyColor = Color3.fromRGB(255, 0, 0)
		_G.UseTeamColor = true

		--------------------------------------------------------------------
		local Holder = Instance.new("Folder", game.CoreGui)
		Holder.Name = "ESP"

		local Box = Instance.new("BoxHandleAdornment")
		Box.Name = "nilBox"
		Box.Size = Vector3.new(1, 2, 1)
		Box.Color3 = Color3.new(100 / 255, 100 / 255, 100 / 255)
		Box.Transparency = 0.7
		Box.ZIndex = 0
		Box.AlwaysOnTop = false
		Box.Visible = false

		local NameTag = Instance.new("BillboardGui")
		NameTag.Name = "nilNameTag"
		NameTag.Enabled = false
		NameTag.Size = UDim2.new(0, 200, 0, 50)
		NameTag.AlwaysOnTop = true
		NameTag.StudsOffset = Vector3.new(0, 1.8, 0)
		local Tag = Instance.new("TextLabel", NameTag)
		Tag.Name = "Tag"
		Tag.BackgroundTransparency = 1
		Tag.Position = UDim2.new(0, -50, 0, 0)
		Tag.Size = UDim2.new(0, 300, 0, 20)
		Tag.TextSize = 15
		Tag.TextColor3 = Color3.new(100 / 255, 100 / 255, 100 / 255)
		Tag.TextStrokeColor3 = Color3.new(0 / 255, 0 / 255, 0 / 255)
		Tag.TextStrokeTransparency = 0.4
		Tag.Text = "nil"
		Tag.Font = Enum.Font.SourceSansBold
		Tag.TextScaled = false

		local LoadCharacter = function(v)
			repeat wait() until v.Character ~= nil
			v.Character:WaitForChild("Humanoid")
			local vHolder = Holder:FindFirstChild(v.Name)
			vHolder:ClearAllChildren()
			local b = Box:Clone()
			b.Name = v.Name .. "Box"
			b.Adornee = v.Character
			b.Parent = vHolder
			local t = NameTag:Clone()
			t.Name = v.Name .. "NameTag"
			t.Enabled = true
			t.Parent = vHolder
			t.Adornee = v.Character:WaitForChild("Head", 5)
			if not t.Adornee then
				return UnloadCharacter(v)
			end
			t.Tag.Text = v.Name
			b.Color3 = Color3.new(v.TeamColor.r, v.TeamColor.g, v.TeamColor.b)
			t.Tag.TextColor3 = Color3.new(v.TeamColor.r, v.TeamColor.g, v.TeamColor.b)
			local Update
			local UpdateNameTag = function()
				if not pcall(function()
						v.Character.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
						local maxh = math.floor(v.Character.Humanoid.MaxHealth)
						local h = math.floor(v.Character.Humanoid.Health)
					end) then
					Update:Disconnect()
				end
			end
			UpdateNameTag()
			Update = v.Character.Humanoid.Changed:Connect(UpdateNameTag)
		end

		local UnloadCharacter = function(v)
			local vHolder = Holder:FindFirstChild(v.Name)
			if vHolder and (vHolder:FindFirstChild(v.Name .. "Box") ~= nil or vHolder:FindFirstChild(v.Name .. "NameTag") ~= nil) then
				vHolder:ClearAllChildren()
			end
		end

		local LoadPlayer = function(v)
			local vHolder = Instance.new("Folder", Holder)
			vHolder.Name = v.Name
			v.CharacterAdded:Connect(function()
				pcall(LoadCharacter, v)
			end)
			v.CharacterRemoving:Connect(function()
				pcall(UnloadCharacter, v)
			end)
			v.Changed:Connect(function(prop)
				if prop == "TeamColor" then
					UnloadCharacter(v)
					wait()
					LoadCharacter(v)
				end
			end)
			LoadCharacter(v)
		end

		local UnloadPlayer = function(v)
			UnloadCharacter(v)
			local vHolder = Holder:FindFirstChild(v.Name)
			if vHolder then
				vHolder:Destroy()
			end
		end

		for i,v in pairs(game:GetService("Players"):GetPlayers()) do
			spawn(function() pcall(LoadPlayer, v) end)
		end

		game:GetService("Players").PlayerAdded:Connect(function(v)
			pcall(LoadPlayer, v)
		end)

		game:GetService("Players").PlayerRemoving:Connect(function(v)
			pcall(UnloadPlayer, v)
		end)

		game:GetService("Players").LocalPlayer.NameDisplayDistance = 0

		if _G.Reantheajfdfjdgs then
			return
		end

		_G.Reantheajfdfjdgs = ":suifayhgvsdghfsfkajewfrhk321rk213kjrgkhj432rj34f67df"

		local players = game:GetService("Players")
		local plr = players.LocalPlayer

		function esp(target, color)
			if target.Character then
				if not target.Character:FindFirstChild("GetReal") then
					local highlight = Instance.new("Highlight")
					highlight.RobloxLocked = true
					highlight.Name = "GetReal"
					highlight.Adornee = target.Character
					highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					highlight.FillColor = color
					highlight.Parent = target.Character
				else
					target.Character.GetReal.FillColor = color
				end
			end
		end

		while task.wait() do
			for i, v in pairs(players:GetPlayers()) do
				if v ~= plr then
					esp(v, _G.UseTeamColor and v.TeamColor.Color or ((plr.TeamColor == v.TeamColor) and _G.FriendColor or _G.EnemyColor))
				end
			end
		end
		end)
