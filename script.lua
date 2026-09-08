local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local tpservice = game:GetService("TeleportService")
local player = Players.LocalPlayer
local vu = game:GetService("VirtualUser")
print("starting the script")
print(tostring(game.PlaceId))
if game.PlaceId ~= 8023712967 then
	print("not in game")
	if game.PlaceId ~= 8008202756 then
		print("not in lobby")
		tpservice:Teleport(8008202756, player)
	else
		print("in lobby")
		task.wait(3)
		local event = game:GetService("ReplicatedStorage").ReplicatedModules.KnitPackage.Knit.Services.MatchmakingService.RF.MakeMatchmakingTeam
		event:InvokeServer(
			"BoundlessTower",
			"NoTypes"
		)
		task.wait(3)

		local event = game:GetService("ReplicatedStorage").ReplicatedModules.KnitPackage.Knit.Services.MatchmakingService.RE.Signal
		event:FireServer(
			"QueueMatchmakingTeam"
		)
	end
else
	print("in game")
	task.wait(3)


	local event = game:GetService("ReplicatedStorage").ReplicatedModules.KnitPackage.Knit.Services.DraftService.RF.SelectAbility
	event:InvokeServer(
		"CGFGGABHAI/1730908371/XPOYN"
	)
	task.wait(3)
	local event = game:GetService("ReplicatedStorage").ReplicatedModules.KnitPackage.Knit.Services.GameModeService.RE.Signal
	event:FireServer(
		{
			Selection = "Metro",
			Action = "Vote",
			Handler = "BoundlessTower"
		}
	)
end
task.spawn(function()
	while task.wait(3) do
		local money = tonumber(game:GetService("Players").LocalPlayer.PlayerGui.UI.Gameplay:GetChildren()[60].Content.UCoins.Content.Text)
		if money > 3000000 then
			
			local Event = game:GetService("ReplicatedStorage").ReplicatedModules.KnitPackage.Knit.Services.GameModeService.RF.RemoveAllLives
			Event:InvokeServer()
		end
	end
end)
task.spawn(function()
	while task.wait(5) do
		vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		task.wait(1)
		vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		print("clicked idk")
	end
end)
local folder = Workspace:WaitForChild("Living")
local Event = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.MoveInputService.RF.FireInput
local SkipEvent = ReplicatedStorage.ReplicatedModules.KnitPackage.Knit.Services.GameModeService.RE.Signal

local target = nil
local char = player.Character or player.CharacterAdded:Wait()
local isattacking = false
local iscanbe = false

-- Проверка жив ли персонаж/цель и есть ли нужные части
local function isAlive(model)
	return model 
		and model.Parent ~= nil 
		and model:FindFirstChild("Humanoid") 
		and model.Humanoid.Health > 0 
		and (model.PrimaryPart or model:FindFirstChild("HumanoidRootPart"))
end

local function getRoot(model)
	if not model then return nil end
	return model.PrimaryPart or model:FindFirstChild("HumanoidRootPart")
end

-- Корректная обработка персонажа при спавне
local function setupCharacter(newChar)
	char = newChar
	local hum = newChar:WaitForChild("Humanoid", 10)
	local root = newChar:WaitForChild("HumanoidRootPart", 10)

	if hum then
		hum.PlatformStand = true
		hum.Died:Connect(function()
			target = nil -- Сбрасываем цель при нашей смерти
		end)
	end
end

player.CharacterAdded:Connect(setupCharacter)
if char then
	task.spawn(setupCharacter, char)
end

-- Удержание над целью
task.spawn(function()
	while task.wait() do
		if iscanbe and isAlive(char) and isAlive(target) then
			local root = getRoot(char)
			local targetRoot = getRoot(target)
			if root and targetRoot then
				root.CFrame = targetRoot.CFrame * CFrame.new(0, 30, 0)
			end
		end
	end
end)

local function attack()
	Event:InvokeServer(
		(function(bytes)
			local b = buffer.create(#bytes)
			for i = 1, #bytes do
				buffer.writeu8(b, i - 1, bytes[i])
			end
			return b
		end)({ 0, 77, 79, 85, 83, 69, 66, 85, 84, 84, 79, 78, 49 })
	)
end

local function getrandomtarget()
	local targets = {}
	for _, v in pairs(folder:GetChildren()) do
		if isAlive(v) and v ~= char then
			table.insert(targets, v)
		end
	end

	if #targets == 0 then
		target = nil
		return
	end

	local randomtarget = targets[math.random(1, #targets)]
	target = randomtarget

	local connect
	connect = randomtarget.AncestryChanged:Connect(function()
		if randomtarget.Parent == nil then
			connect:Disconnect()
			target = nil
		end
	end)
end

-- Поиск цели
task.spawn(function()
	while task.wait(0.5) do
		if not isAlive(target) then
			getrandomtarget()
		end
	end
end)

local function singleHit()
	task.wait(0.2)
	if isAlive(char) and isAlive(target) then
		iscanbe = false
		local root = getRoot(char)
		local targetRoot = getRoot(target)
		if root and targetRoot then
			root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 5)
			root.AssemblyLinearVelocity = Vector3.zero
			root.AssemblyAngularVelocity = Vector3.zero
		end
		task.wait(0.2)
		iscanbe = true
	end
end

local function doacombo()
	for i = 1, 4 do
		if not isAlive(char) or not isAlive(target) then break end
		task.spawn(singleHit)
		attack()
	end
end

-- Скип в башне
task.spawn(function()
	while task.wait(3) do
		SkipEvent:FireServer({
			Action = "BoundlessTowerSkipVote",
			Handler = "BoundlessTower"
		})
	end
end)

-- Основной цикл атаки
task.spawn(function()
	while task.wait() do
		if isAlive(char) and isAlive(target) then
			if not isattacking then
				isattacking = true
				doacombo()
				isattacking = false
				task.wait(2)
			end
		end
	end
end)
