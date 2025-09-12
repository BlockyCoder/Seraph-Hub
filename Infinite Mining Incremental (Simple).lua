--URL: https://www.roblox.com/games/132192210247665/MAGMA-Infinite-Mining-Incremental


--Infinite Mining Incremental (Simple).lua


local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local mouse = LocalPlayer:GetMouse()

local TotalOres = LocalPlayer:WaitForChild("NonSaveValues"):WaitForChild("TotalOres")
local MultipliersModule = require(ReplicatedStorage.Modules:WaitForChild("Multipliers"))
local short = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Short"))
local mineOreEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("MineOre")

local UserInputService = game:GetService("UserInputService")

local IsOnMobile = table.find({
	Enum.Platform.IOS,
	Enum.Platform.Android
}, UserInputService:GetPlatform())



game:GetService("Players").LocalPlayer.Idled:connect(function()
	VirtualUser:Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	wait(1)
	VirtualUser:Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)


local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/BlockyCoder/Seraph-Hub/refs/heads/main/Ui%20Libarary_%20Seraph%20Hub"))()
Library:Create("[MAGMA🌋] Infinite Mining Incremental ⛏️")

local maint = Library:Tab("Main")
local Credit = Library:Tab("Credit")


local oresFolder = workspace:FindFirstChild("Ores")
local espEnabled = false
local adornments = {}
local MAX_DISTANCE = 100
local UPDATE_INTERVAL = 0.5

local selectedOres = {} 

local customOreColors = {
	-- Add your custom colors here if needed
}


-- Default Ore Colors
local defaultOreColors = {
	Redlinite           = Color3.fromRGB(255,   0,   0),
	Rainbonium          = Color3.fromRGB(255, 128, 255),
	Laventyx            = Color3.fromRGB(255, 192, 203),
	Ruby                = Color3.fromRGB(255,   0,  64),
	Unobtanium          = Color3.fromRGB(  0, 255, 255),
	Inferno             = Color3.fromRGB(255,  85,   0),
	Morganite           = Color3.fromRGB(255, 153, 153),
	["Nautilus Evolved"]= Color3.fromRGB(  0, 170, 255),
	Crimsonstone        = Color3.fromRGB(170,   0,   0),
	Serenity            = Color3.fromRGB(128,   0, 255),
	Spongebob           = Color3.fromRGB(255, 255,   0),
	Chest               = Color3.fromRGB(180, 140,  70),
	Indigo              = Color3.fromRGB( 75,   0, 130),
	Devilline           = Color3.fromRGB(255, 100, 100),
	Green               = Color3.fromRGB(  0, 255,   0),
	Constellatium       = Color3.fromRGB(255, 215,   0),
	Mineralite          = Color3.fromRGB(240, 240, 240),
	["Aqueduelis Blue"] = Color3.fromRGB(  0, 180, 255),
	Royalty             = Color3.fromRGB(180,   0, 255),
	Malachite           = Color3.fromRGB(  0, 180, 100),
	Darkmatter          = Color3.fromRGB( 20,  20,  20),
	Evorium             = Color3.fromRGB(100, 100, 255),
	Diamond             = Color3.fromRGB(  0, 255, 255),
	["Solar Blossom"]   = Color3.fromRGB(255, 165, 180),
	Datolite            = Color3.fromRGB(180, 255, 180),
	Yumium              = Color3.fromRGB(255, 240, 220),
	Plutonium           = Color3.fromRGB( 50, 100,  50),
	Violet              = Color3.fromRGB(180,   0, 255),
	Rozenite            = Color3.fromRGB(255, 100, 255),
	Ambrosia            = Color3.fromRGB(255, 220, 220),
	Alagamite           = Color3.fromRGB(180,  50,  50),
	Fracturium          = Color3.fromRGB(200, 200, 255),
	["Warped Coal"]     = Color3.fromRGB( 50,  50,  50),
	Alternatus          = Color3.fromRGB(255, 255, 128),
	["Radiant Quartz"]  = Color3.fromRGB(255, 255, 255),
	Crookesite          = Color3.fromRGB(255, 215, 180),
	Chronoverde         = Color3.fromRGB( 50, 255,  50),
	Galactium           = Color3.fromRGB(128, 128, 255),
	Dragonglass         = Color3.fromRGB(  0, 100, 100),
	Taaffeite           = Color3.fromRGB(255, 128, 255),
	Mintite             = Color3.fromRGB(128, 255, 128),
	Lithium             = Color3.fromRGB(200, 200, 200),
	Glitchite           = Color3.fromRGB(  0, 255, 255),
	["Void Crystals"]   = Color3.fromRGB(180, 180, 255),
	Niedermayrite       = Color3.fromRGB(200, 100, 100),
	Lunalyx             = Color3.fromRGB(255, 128, 200),
	["Abyssal Stone"]   = Color3.fromRGB( 10,  10,  10),
	Jasper              = Color3.fromRGB(255,   0, 255),
	Firecrystal         = Color3.fromRGB(255,  70,   0),
	Ekanite             = Color3.fromRGB(255, 128, 128),
	Garnet              = Color3.fromRGB(180,   0,   0),
	["Aqueduelis Red"]  = Color3.fromRGB(255,   0,   0),
	Realgar             = Color3.fromRGB(255,  69,   0),
	Platinum            = Color3.fromRGB(230, 230, 255),
	Masslock            = Color3.fromRGB( 90,  90,  90),
	["Glitchite Reborn"]= Color3.fromRGB(  0, 255, 255),
	Decayium            = Color3.fromRGB(100,  50,  50),
	Ammolite            = Color3.fromRGB(255,  50,  50),
	Lavendulan          = Color3.fromRGB(200, 180, 255),
	Wadsleyite          = Color3.fromRGB(100, 200, 100),
	Blue                = Color3.fromRGB(  0,   0, 255),
	Iron                = Color3.fromRGB(150, 150, 150),
	Voltiblue           = Color3.fromRGB(  0, 180, 255),
	Eclipse             = Color3.fromRGB( 80,  80,  80),
	Coal                = Color3.fromRGB( 20,  20,  20),
	Timeite             = Color3.fromRGB(200, 200, 255),
	Redrum              = Color3.fromRGB(180,   0,   0),
	Shadowite           = Color3.fromRGB( 50,  50,  50),
	["Lightning Crystal"]= Color3.fromRGB(255, 255,   0),
	Rainbonite          = Color3.fromRGB(255, 180, 255),
	Cordierite          = Color3.fromRGB(100, 100, 200),
	Nautilus            = Color3.fromRGB(  0, 120, 255),
	Lucentium           = Color3.fromRGB(255, 255, 255),
	Red                 = Color3.fromRGB(255,   0,   0),
	Obamite             = Color3.fromRGB(  0,   0,   0),
	Miroite             = Color3.fromRGB(255, 180, 255),
	Duskium             = Color3.fromRGB(100, 100, 100),
	Copper              = Color3.fromRGB(184, 115,  51),
	Orange              = Color3.fromRGB(255, 140,   0),
	GalacticShard       = Color3.fromRGB(200, 200, 255),
	Stellarite          = Color3.fromRGB(180, 180, 255),
	Core                = Color3.fromRGB(100, 100, 100),
	Indicolite          = Color3.fromRGB( 75,   0, 130),
	REDACTED            = Color3.fromRGB(255,   0,   0),
	Augelite            = Color3.fromRGB(180, 180, 255),
	Superium            = Color3.fromRGB(255, 220, 180),
	Yellow              = Color3.fromRGB(255, 255,   0),
	Celsian             = Color3.fromRGB(180, 220, 255),
	["101101"] 			= Color3.fromRGB(0, 255, 0)
}


local function isValidOre(ore)
	if not ore then return false end
	if ore.Name ~= "Stone"and ore.Name ~= "Darkstone" and ore.Name ~= "Crimsonstone" and ore.Name ~= "Marble" then
		local canMineVal = ore:FindFirstChild("CanMine")
		return canMineVal and canMineVal.Value == true
	end
end

local function isBagFull()

	if LocalPlayer.Gamepasses.InfiniteStorage.Value then
		return false
	end
	return TotalOres.Value >= MultipliersModule.Storage(LocalPlayer)
end


local function getDistanceToPlayer(part)
	local char = LocalPlayer.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return math.huge end
	return (char.HumanoidRootPart.Position - part.Position).Magnitude
end

local function getOreColor(name)

	return customOreColors[name] or defaultOreColors[name] or Color3.fromRGB(255,255,255)
end

local espFolder = workspace:FindFirstChild("ESPFolder")
if not espFolder then
	espFolder = Instance.new("Folder")
	espFolder.Name = "ESPFolder"
	espFolder.Parent = workspace
end

local function scanOresInRegion(position)
	local regionSize = Vector3.new(MAX_DISTANCE * 2, 50, MAX_DISTANCE * 2)
	local region = Region3.new(position - regionSize/2, position + regionSize/2)
	local partsInRegion = workspace:FindPartsInRegion3WithIgnoreList(region, {LocalPlayer.Character}, math.huge)

	local foundOres = {}
	for _, part in ipairs(partsInRegion) do
		if part.Parent == oresFolder and isValidOre(part) then
			table.insert(foundOres, part)
		end
	end
	return foundOres
end

local function createESP(ore)
	if adornments[ore] then return end

	local adorn = Instance.new("BoxHandleAdornment")
	adorn.Name = "ESP"
	adorn.AlwaysOnTop = true
	adorn.ZIndex = 10
	adorn.Size = ore.Size + Vector3.new(0.1, 0.1, 0.1)
	adorn.Color3 = getOreColor(ore.Name)
	adorn.Transparency = 0.5
	adorn.Adornee = ore
	adorn.Parent = espFolder

	local billboard = Instance.new("BillboardGui")
	billboard.AlwaysOnTop = true
	billboard.Size = UDim2.new(0, 100, 0, 20)
	billboard.StudsOffset = Vector3.new(0, 2, 0)
	billboard.Adornee = ore
	billboard.Parent = game.CoreGui

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = ore.Name
	label.TextColor3 = getOreColor(ore.Name)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextStrokeTransparency = 0.5
	label.TextStrokeColor3 = Color3.new(0,0,0)
	label.Parent = billboard

	local conn
	conn = RunService.Heartbeat:Connect(function()
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local stillValid = ore and ore.Parent and hrp and (hrp.Position - ore.Position).Magnitude <= MAX_DISTANCE
		if not stillValid then
			if conn then conn:Disconnect() end
			if ancestryConn then ancestryConn:Disconnect() end
			if billboard then billboard:Destroy() end
			if adorn then adorn:Destroy() end
			adornments[ore] = nil
		end
	end)

	local ancestryConn
	ancestryConn = ore.AncestryChanged:Connect(function(_, parent)
		if not parent then
			if conn then conn:Disconnect() end
			if ancestryConn then ancestryConn:Disconnect() end
			if billboard then billboard:Destroy() end
			if adorn then adorn:Destroy() end
			adornments[ore] = nil
		end
	end)

	local canMineVal = ore:FindFirstChild("CanMine")
	local canMineConn

	if canMineVal then
		canMineConn = canMineVal.Changed:Connect(function(newValue)
			if newValue == false then
				if conn then conn:Disconnect() end
				if ancestryConn then ancestryConn:Disconnect() end
				if canMineConn then canMineConn:Disconnect() end
				if billboard then billboard:Destroy() end
				if adorn then adorn:Destroy() end
				adornments[ore] = nil
			end
		end)
	end


	adornments[ore] = {Adorn = adorn, Gui = billboard, Connection = conn, AncestryConnection = ancestryConn, CanMineConnection = canMineConn}
end

local function clearESP()
	for _, data in pairs(adornments) do
		if data.Gui then data.Gui:Destroy() end
		if data.Adorn then data.Adorn:Destroy() end 
		if data.Connection then data.Connection:Disconnect() end
	end
	adornments = {}
end



local function refreshESP()
	clearESP()
	if not espEnabled or not oresFolder then return end

	local character = LocalPlayer.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local oresInRange = scanOresInRegion(hrp.Position)

	for _, ore in ipairs(oresInRange) do
		if isValidOre(ore) and (not next(selectedOres) or selectedOres[ore.Name]) then
			createESP(ore)
		end
	end
end

task.spawn(function()
	while true do
		if espEnabled then
			local character = LocalPlayer.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")

			if hrp then
				for ore, data in pairs(adornments) do
					if not ore or not ore.Parent or (hrp.Position - ore.Position).Magnitude > MAX_DISTANCE then
						if data.Gui then data.Gui:Destroy() end
						if data.Adorn then data.Adorn:Destroy() end
						if data.Connection then data.Connection:Disconnect() end
						adornments[ore] = nil
					end
				end

				local oresInRange = scanOresInRegion(hrp.Position)
				for _, ore in ipairs(oresInRange) do
					if isValidOre(ore) and not adornments[ore] and (not next(selectedOres) or selectedOres[ore.Name]) then
						createESP(ore)
					end
				end
			end
		end
		task.wait(UPDATE_INTERVAL + math.random() * 0.1)
	end
end)


if oresFolder then
	oresFolder.ChildAdded:Connect(function(ore)
		if espEnabled and isValidOre(ore) then
			local character = LocalPlayer.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			if hrp and (hrp.Position - ore.Position).Magnitude <= MAX_DISTANCE then
				createESP(ore)
			end
		end
	end)
end


local espB 

espB = Library:Button(maint, "Toggle Ore ESP: "..tostring(espEnabled), function()
	espEnabled = not espEnabled
	if espEnabled then
		refreshESP()
	else
		clearESP()
	end
	espB:UpdateButton("Toggle Ore ESP: " .. tostring(espEnabled))
end)

Library:Button(maint, "Refresh ESP", function()
	if espEnabled then
		refreshESP()
	end
end)


task.spawn(function()
	while true do
		if espEnabled and oresFolder then
			local character = LocalPlayer.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			if hrp then
				for ore, objs in pairs(adornments) do
					local stillValid = ore and ore.Parent and (hrp.Position - ore.Position).Magnitude <= MAX_DISTANCE
					if not stillValid then
						if objs.Connection then objs.Connection:Disconnect() end
						if objs.AncestryConnection then objs.AncestryConnection:Disconnect() end
						if objs.Gui then objs.Gui:Destroy() end
						if objs.Adorn then objs.Adorn:Destroy() end
						if objs.CanMineConnection then 
							objs.CanMineConnection:Disconnect() end
						adornments[ore] = nil
					end
				end

				for _, ore in ipairs(oresFolder:GetChildren()) do
					if isValidOre(ore) and not adornments[ore] then
						if (hrp.Position - ore.Position).Magnitude <= MAX_DISTANCE then
							createESP(ore)
						end
					end
				end
			end
		else
			if next(adornments) then
				clearESP()
			end
		end
		task.wait(UPDATE_INTERVAL + math.random() * 0.1)
	end
end)



local allOreNames = {}
for oreName, _ in pairs(defaultOreColors) do
	table.insert(allOreNames, oreName)
end

Library:MultiDropdown(maint, "Select Ores to Show", allOreNames, function(selectedList)
	selectedOres = {}
	for _, ore in ipairs(selectedList) do
		selectedOres[ore] = true
	end
	if espEnabled then
		refreshESP()
	end
end)


local Mouse = LocalPlayer:GetMouse()
local clicking = false

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.F then
		clicking = not clicking
		print("Auto clicker:", clicking and "ON" or "OFF")
	end
end)

task.spawn(function()
	while true do
		RunService.Heartbeat:Wait()
		if clicking then
			local target = Mouse.Target
			if target then
				mineOreEvent:FireServer(target)
			end
		end
	end
end)

UserInputService.TouchTapInWorld:Connect(function(position, processed)
	if processed then return end

	local ray = workspace.CurrentCamera:ViewportPointToRay(position.X, position.Y)
	local result = workspace:Raycast(ray.Origin, ray.Direction * 1000)

	if result and result.Instance then
		mineOreEvent:FireServer(result.Instance)
	end
end)

if not IsOnMobile then
	Library:Label(maint, "Auto Clicker for PC (No delay) (Press F to toggle)")
else
	local clicMob = Library:Button(maint, "Auto Clicker (No delay):" .. tostring(clicking), function()
		clicking = not clicking
		print("Auto clicker:", clicking and "ON" or "OFF")
	end)
	clicMob:UpdateButton("Auto Clicker (No delay): " .. tostring(clicking))
end


local flying = false
local TELEPORT_DISTANCE = 100

RunService.Stepped:Connect(function()
	if flying then
		local character = LocalPlayer.Character
		if character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end
end)

local function teleportTo(position)
	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local rootPart = character:WaitForChild("HumanoidRootPart")
	rootPart.CFrame = CFrame.new(position + Vector3.new(0, 5, 0))
end

local function horizontalDistance(a, b)
	return Vector3.new(a.X, 0, a.Z) - Vector3.new(b.X, 0, b.Z).Magnitude
end

local function flyTo(position, baseSpeed)
	if flying then return end
	flying = true

	local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
	local rootPart = character:WaitForChild("HumanoidRootPart")

	local bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
	bv.Velocity = Vector3.zero
	bv.P = 1e5
	bv.Parent = rootPart

	local CLOSE_DISTANCE = 150 
	local FINISH_DISTANCE = 5 
	local MIN_SPEED = baseSpeed * 0.5
	local MAX_SPEED = baseSpeed * 2

	local TIMEOUT = 10 
	local startTime = tick()

	while flying do
		local currentDistance = (rootPart.Position - position).Magnitude

		if currentDistance <= TELEPORT_DISTANCE then
			teleportTo(position)
			break
		end

		if tick() - startTime > TIMEOUT then
			break
		end

		local speed
		if currentDistance < CLOSE_DISTANCE then
			speed = math.clamp(MAX_SPEED * (currentDistance / CLOSE_DISTANCE), MIN_SPEED, MAX_SPEED)
		else
			speed = MAX_SPEED
		end

		bv.Velocity = (position - rootPart.Position).Unit * speed
		task.wait()
	end

	bv:Destroy()
	flying = false
end


Library:Button(maint, "Fly to Sell Zone", function()
	task.spawn(function()
		local sellPart = workspace:WaitForChild("Main"):WaitForChild("Pads"):WaitForChild("Sell"):WaitForChild("Interact")
		flyTo(sellPart.Position, 100)
	end)
end)

Library:Button(maint, "Fly to Mining Area", function()
	task.spawn(function()
		local miningPosition = Vector3.new(104.07222, 6.6583333, -7.31344509)
		flyTo(miningPosition, 100)
	end)
end)




local runeRunning = false

local RuneSele = {}

local function refreshRuneList()
	RuneSele = {}
	for i, v in pairs(game:GetService("Workspace").Main.Runes:GetChildren()) do
		if not table.find(RuneSele, v.Name) then
			table.insert(RuneSele, v.Name)
		end
	end
end
refreshRuneList() 

Library:Dropdown(maint, "Select Rune", RuneSele, function(selectedOption)
	getgenv().SeleRune = selectedOption
end)

task.spawn(function()
	while true do
		refreshRuneList()
		task.wait(100 + math.random() * 0.1)
	end
end)

local runeRunning = false

Library:Toggle(maint, "Auto Rune", function(isToggled)
	getgenv().rune = isToggled

	if isToggled and not runeRunning then
		runeRunning = true

		task.spawn(function()
			local players = game:GetService("Players")
			local workspace = game:GetService("Workspace")
			local player = players.LocalPlayer

			while getgenv().rune do
				local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

				if hrp and getgenv().SeleRune then
					local rune = workspace.Main.Runes:FindFirstChild(getgenv().SeleRune)
					if rune and rune:FindFirstChild("Hitbox") then
						pcall(function()
							hrp.CFrame = rune.Hitbox.CFrame + Vector3.new(0, 3, 0)
						end)
					end
				end

				task.wait(0.1 + math.random() * 0.1)
			end

			runeRunning = false
		end)
	end

	if not isToggled then
		runeRunning = false
	end
end)

local labCap = Library:Label(maint, "Bag Capcity: "..short.en(TotalOres.Value)..'/'..short.en(MultipliersModule.Storage(LocalPlayer)))

TotalOres.Changed:Connect(function()
	labCap:UpdateLabel("Bag Capcity: "..short.en(TotalOres.Value) .. '/' .. short.en(MultipliersModule.Storage(LocalPlayer)))
end)


--auto mine
local autoMine = false
local autoMineRadius = 25
local useMouse = false
local autoSelectSpecificOres = false
local selectedOres = {}
local cachedOres = {}
local lastPosition = nil
local cacheDistanceThreshold = 30
local lastCacheUpdateTime = 0
local cacheUpdateInterval = 5

local mineSpeeds = {
	["Normal"] = 0.05,
	["Fast"] = 0.02,
	["Very Fast"] = 0.005,
	["INSANE FAST"] = 0
}
local selectedMineSpeed = mineSpeeds["Normal"]

local function calculateDynamicDelay()
	local fps = 1 / RunService.RenderStepped:Wait()
	if fps < 30 then
		return 0.1
	elseif fps > 100 then
		return 0.01
	else
		return 0.03
	end
end


local function isOreAllowed(ore)
	if not ore then return false end
	if not autoSelectSpecificOres then
		return true
	end
	return selectedOres[ore.Name:lower()] == true
end

local function updateNearbyOres()
	local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp or not oresFolder then return end

	local radius = autoMineRadius
	local regionSize = Vector3.new(radius * 2, 50, radius * 2)
	local regionCenter = hrp.Position

	local region = Region3.new(regionCenter - regionSize / 2, regionCenter + regionSize / 2)
	local partsInRegion = workspace:FindPartsInRegion3(region, nil, math.huge)

	local nearbyOres = {}
	for _, part in ipairs(partsInRegion) do
		if part.Parent == oresFolder and part:FindFirstChild("CanMine") and part.CanMine.Value then
			table.insert(nearbyOres, part)
		end
	end
	cachedOres = nearbyOres
end

Library:Toggle(maint, "Auto Mine + Sell", function(state)
	autoMine = state
	if autoMine then
		lastPosition = nil
		updateNearbyOres()
	else
		cachedOres = {}
	end
end)

Library:Toggle(maint, "Auto mine using Mouse", function(state)
	useMouse = state
end)

Library:MultiDropdown(maint, "Select Ores to farm (nil = all ores nearby)", allOreNames, function(selectedList)
	selectedOres = {}
	for _, oreName in ipairs(selectedList) do
		selectedOres[oreName:lower()] = true
	end
	updateNearbyOres()
end)

Library:Toggle(maint, "Auto Select Specific Ores", function(state)
	autoSelectSpecificOres = state
end)

Library:Dropdown(maint, "Mine Speed", {"Normal", "Fast", "Very Fast", "INSANE FAST"}, function(selected)
	selectedMineSpeed = mineSpeeds[selected]
end)

local sellPart = workspace:WaitForChild("Main"):WaitForChild("Pads"):WaitForChild("Sell"):WaitForChild("Interact")

local returning = false
local returnPosition = nil
local selling = false

task.spawn(function()
	while true do
		RunService.Heartbeat:Wait()

		if autoMine and oresFolder then
			local character = LocalPlayer.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChild("Humanoid")

			if hrp and humanoid and humanoid.Health > 0 then

				if isBagFull() then
					if not returning and not selling then
						returning = true
						selling = true
						returnPosition = hrp.Position
						if sellPart then
							flyTo(sellPart.Position + Vector3.new(0, 5, 0), 30)
							task.spawn(function()
								while isBagFull() do
									RunService.Heartbeat:Wait()
								end
								selling = false
							end)
						else
							selling = false
						end
					end
				elseif returning and not isBagFull() then
					flyTo(returnPosition, 30)
					returning = false
				end

				if returning or selling then
					continue
				end

				if (not lastPosition or (hrp.Position - lastPosition).Magnitude > cacheDistanceThreshold)
					or (tick() - lastCacheUpdateTime > cacheUpdateInterval) then
					lastPosition = hrp.Position
					updateNearbyOres()
					lastCacheUpdateTime = tick()
				end

				local oreToMine = nil
				local distToOre = math.huge

				if useMouse and mouse.Target and isOreAllowed(mouse.Target) then
					local dist = (hrp.Position - mouse.Target.Position).Magnitude
					if dist <= autoMineRadius then
						oreToMine = mouse.Target
						distToOre = dist
					end
				end

				if not oreToMine then
					for _, ore in ipairs(cachedOres) do
						if isOreAllowed(ore) and ore:FindFirstChild("CanMine") and ore.CanMine.Value then
							local dist = (hrp.Position - ore.Position).Magnitude
							if dist <= 5 then
								oreToMine = ore
								distToOre = dist
								break
							end
						end
					end
				end

				if not oreToMine then
					for _, ore in ipairs(cachedOres) do
						if isOreAllowed(ore) and ore:FindFirstChild("CanMine") and ore.CanMine.Value then
							local dist = (hrp.Position - ore.Position).Magnitude
							if dist < distToOre and dist <= autoMineRadius then
								oreToMine = ore
								distToOre = dist
							end
						end
					end
				end

				if oreToMine then
					if distToOre > 30 then
						flyTo(oreToMine.Position, 30)
					end

					if distToOre <= 30 then
						pcall(function()
							mineOreEvent:FireServer(oreToMine)
						end)
					end
				end
			end
		end

		if selectedMineSpeed > 0 then
			task.wait(selectedMineSpeed)
		else
			game:GetService("RunService").Heartbeat:wait()
		end
	end
end)


Library:Toggle(maint, "Auto Tier", function(isToggled)
	getgenv().Tier = isToggled
	if getgenv().Tier then
		while getgenv().Tier == true do
			local args = {
				[1] = "Tier"
			}

			game:GetService("ReplicatedStorage").Events.ToServer:FireServer(unpack(args))
			game:GetService("RunService").Heartbeat:wait();
		end
	end
end)


local geodeLabel = Library:Label(maint, "Geodes Spawned: Scanning...")
local currentGeodes = {}
local lastNotifiedGeodes = {}
local nearestGeode = nil
local gedoDis = math.huge


local function notifyGeode(geodeName, distance)
	game:GetService("StarterGui"):SetCore("SendNotification", {
		Title = "GEODE FOUND!",
		Text = string.format("%s (%d studs away)", geodeName, math.floor(distance)),
		Icon = "rbxassetid://13319773302",
		Duration = 8
	})
end

local function updateGeodeDisplay()
	local character = LocalPlayer.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")

	if not hrp then
		geodeLabel:UpdateLabel("Geodes Spawned: Character not found")
		return
	end

	if not next(currentGeodes) then
		geodeLabel:UpdateLabel("Geodes Spawned: None")
		nearestGeode = nil
		return
	end

	local displayTexts = {}
	local newGeodesFound = false

	for name, ore in pairs(currentGeodes) do
		if ore and ore.Parent then  
			local distance = (hrp.Position - ore.Position).Magnitude
			table.insert(displayTexts, string.format("%s (%d studs)", name, math.floor(distance)))

			if distance < gedoDis then
				MAX_DISTANCE = distance
				nearestGeode = ore
			end
			
			if not lastNotifiedGeodes[name] then
				notifyGeode(name, distance)
				lastNotifiedGeodes[name] = true
				newGeodesFound = true
			end
		else
			currentGeodes[name] = nil
			lastNotifiedGeodes[name] = nil
		end
	end

	if newGeodesFound then
		Library:ShowNotify("New Geodes", "Check the notification for details!", 3)
	end

	if #displayTexts > 0 then
		geodeLabel:UpdateLabel("Geodes Nearby: "..table.concat(displayTexts, ", "))
	else
		geodeLabel:UpdateLabel("Geodes Spawned: None")
		currentGeodes = {} 
		nearestGeode = nil
	end
end


local function initialGeodeScan()
	for _, ore in ipairs(oresFolder:GetChildren()) do
		if ore:IsA("Part") and tonumber(ore.Name) then
			currentGeodes[ore.Name] = ore
		end
	end
	updateGeodeDisplay()
end


oresFolder.ChildAdded:Connect(function(child)
	if child:IsA("Part") and tonumber(child.Name) then
		currentGeodes[child.Name] = child
		updateGeodeDisplay()
	end
end)

oresFolder.ChildRemoved:Connect(function(child)
	if child:IsA("Part") and currentGeodes[child.Name] then
		currentGeodes[child.Name] = nil
		lastNotifiedGeodes[child.Name] = nil
		updateGeodeDisplay()
	end
end)

task.spawn(function()
	while true do
		updateGeodeDisplay()
		task.wait(5 + math.random() * 0.1)
	end
end)

initialGeodeScan()

Library:Button(maint, "Refresh Geode Display", function()
	updateGeodeDisplay()
end)

Library:Button(maint, "Teleport to Nearest Geode", function()
	local character = LocalPlayer.Character
	local hrp = character and character:FindFirstChild("HumanoidRootPart")
	if hrp and nearestGeode and nearestGeode.Parent then
		flyTo(nearestGeode.Position + Vector3.new(0, 5, 0), 30)
		Library:ShowNotify("Teleport", "Teleported to nearest Geode!", 3)
	else
		Library:ShowNotify("Teleport", "No valid Geode to teleport to.", 3)
	end
end)


local esplink = "https://scriptblox.com/script/MARBLE-Infinite-Mining-Incremental-Ore-ESP-42014"


Library:Label(Credit, "Esp By: MeRKUS103")

Library:Button(Credit, "Link to his esp script Link!", function()
	setclipboard(esplink)
	task.wait(0.05 + math.random() * 0.1) 
	game:GetService("StarterGui"):SetCore("SendNotification",{
		Title = "Copied",
		Text = "you have copied the Link!",
		Icon = "rbxassetid://13319773302",
		Duration = 4
	})
end)















Library:ShowNotify("Loaded", "The Guis Have Loaded!", 3) 


Library:ShowNotify("Auto clicker", "The auto clicker is like auto mine but using your mouse!", 2) 
Library:ShowNotify("Auto Mine", "The Auto Mine of inbuilt auto sell when bag is full", 2) 
Library:ShowNotify("Anti AFK", "This has InBuilt ANTI AFK", 2) 
Library:ShowNotify("Warning", "This Game has Small remote Detection BE CAREFUL", 2) 
