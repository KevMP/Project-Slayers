local player = game.Players.LocalPlayer
local char = player.Character
local runService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
---------------------------------------------
local remotes = game.ReplicatedStorage.Remotes
local pDodge = remotes.P_Dodge
local initiateS = remotes.To_Server.Handle_Initiate_S_ 
local initiateC = remotes.To_Server.Handle_Initiate_C
local npcsFolder = game.ReplicatedStorage.Npcs
---------------------------------------------
local screenUI = game:GetService("CoreGui").BOFA
local killAura = false
local autoFarm = false
local scared = false


local tweenInfo = TweenInfo.new(
	0.1,
	Enum.EasingStyle.Linear,
	Enum.EasingDirection.Out,
	0
)

---------------------------------------------
local lastTime = os.clock()
---------------------------------------------
local targetMob = "Zoku's Subordinate"
local targets = {}
local currentTarget;
local npcSettingsModules = {}
---------------------------------------------
local tools = {}
local selectedTool = nil
---------------------------------------------


---------------------------------------------
local locations = {}
locations["Kiribating Village"] = Vector3.new(123.878, 280.238, -1624.75)
locations["Zapiwara Cave"] = Vector3.new(28.476, 273.908, -2419.13)
locations["Butterfly Mansion"] = Vector3.new(2989.1, 314.059, -3876.97)
locations["Zapiwara Mountain"] = Vector3.new(-330.748, 423.905, -2331.74)
locations["Ushumaru Village"] = Vector3.new(-468.203, 273.851, -3331.97)
locations["Waroru Cave"] = Vector3.new(599.624, 282.69, -2566.42)
locations["Kabiwaru Village"] = Vector3.new(1841.65, 320.511, -3243.7)
locations["Abubu Cave"] = Vector3.new(1073,276,-3553)
locations["Final Selection"] = Vector3.new(5216,365,-2422)
locations["Ouwabashi Home"] = Vector3.new(1580,315,-4609)
locations["Wind Trainer"] = Vector3.new(1788,334,-3518)
locations["Dangerous Woods"] = Vector3.new(4030,3242,-3955)
locations["Slasher Demon"] = Vector3.new(4305,342,-4254)
---------------------------------------------
function disableAntiCheat()
	local smallScripts = player.PlayerScripts["Small_Scripts"]
	local block1 = smallScripts["client_global_delete_script"]
	local block2 = smallScripts["Client_Global_utility"]

	block1:Destroy()
	block2:Destroy()
end



function checkTargets()
--------------------------------------------------------
	for object, module in pairs(npcSettingsModules) do 
		if module.Name == targetMob then 
			local mobModel = object.Parent:FindFirstChildOfClass("Model")
			
			if mobModel and mobModel:FindFirstChild("HumanoidRootPart") then 
				currentTarget = mobModel
			end
		end
	end
--------------------------------------------------------	
	if currentTarget == nil then 
		for object, module in pairs(npcSettingsModules) do
			if module.Name == targetMob then
				char:SetPrimaryPartCFrame(CFrame.new(module.Npc_Spawning.Spawn_Locations[1]))
			end
		end
	end
	
	print("---------------------")
	print(currentTarget)
	print("---------------------")
end


function goToTarget()
	if currentTarget and currentTarget:FindFirstChild("HumanoidRootPart") then 
		char:SetPrimaryPartCFrame(currentTarget.HumanoidRootPart.CFrame * CFrame.new(0,0,2))
	else 
		currentTarget = nil
	end
end


function attack()
	local timeThing = lastTime + 0.1
	lastTime = timeThing

	pDodge:FireServer()
	--initiateC:FireServer("Players."..player.Name..".PlayerScripts.Client_Modules.Main_Script", timeThing, "Play_Sound", game.ReplicatedStorage.Sounds.Sword["Rapid_Swing"])

	if selectedTool == nil or not selectedTool:match("Katana") then 
		initiateS:InvokeServer("fist_combat", player, char, char.HumanoidRootPart, char.Humanoid, 1)
	else 
		initiateS:InvokeServer("Sword_Combat_Slash", player, char, char.HumanoidRootPart, char.Humanoid, 1)
	end
end


function setAllMobsSelectable()
	local mobNames = {}
	local mobsDecentants = game.Workspace.Mobs:GetDescendants()
	local templateTextBox = screenUI.Draggable.Main.MainFrame.Holder.FarmMob.Holder.ScrollingFrame.Template

	
	for i, v in pairs(mobsDecentants) do 
		if v.Name == "Npc_Configuration" and v:IsA("ModuleScript") then 
			local module = require(v)
			
			npcSettingsModules[v] = module
			
			if not mobNames[module.Name] then 
				mobNames[module.Name] = v
			end
		end
	end
	
	
	
	for name, _ in pairs(mobNames) do 
		print(name)
		local textButton = templateTextBox:Clone()
		textButton.Name = name
		textButton.Text = name		
		textButton.Parent = templateTextBox.Parent


		textButton.MouseButton1Click:Connect(function()
			targetMob = name
			screenUI.Draggable.Main.MainFrame.Holder.FarmMob.btntext.Text = "Select Mob: "..targetMob
			
		end)
		
		textButton.MouseEnter:Connect(function()
			tweenService:Create(textButton, tweenInfo, {TextColor3 = Color3.new(170, 0, 0)}):Play()
		end)

		textButton.MouseLeave:Connect(function()
			tweenService:Create(textButton, tweenInfo, {TextColor3 = Color3.new(255, 255, 255)}):Play()
		end)
		
	end


	templateTextBox:Destroy()
	screenUI.Draggable.Main.MainFrame.Holder.FarmMob.btntext.Text = "Select Mob: "..targetMob
end

function changeTools()

end


function updateTools()
	local weaponSelect = screenUI.Draggable.Main.MainFrame.Holder.WeaponSelect
	local template = weaponSelect.Holder.ScrollingFrame.Template
	local backPackChildren = player.Backpack:GetChildren()
	local charChildren = char:GetChildren()
	local allTools = {}

	---------------------------------------------~	
	for i, v in pairs(backPackChildren) do
		if v:IsA("Tool") and not allTools[v.Name] then 
			allTools[v.Name] = v
		end
	end

	for i, v in pairs(charChildren) do 
		if v:IsA("Tool") and not allTools[v.Name] then 
			allTools[v.Name] = v
		end		
	end
	---------------------------------------------	

	tools = allTools

	for name, tool in pairs(tools) do 
		if not weaponSelect.Holder.ScrollingFrame:FindFirstChild(name) then 
			local newSelector = template:Clone()
			newSelector.Name = name
			newSelector.Text = name
			newSelector.Parent = template.Parent

			newSelector.MouseButton1Click:Connect(function()
				selectedTool = name
				changeTools()
			end)
			
				newSelector.MouseEnter:Connect(function()
					tweenService:Create(newSelector, tweenInfo, {TextColor3 = Color3.new(170, 0, 0)}):Play()
				end)

				newSelector.MouseLeave:Connect(function()
					tweenService:Create(newSelector, tweenInfo, {TextColor3 = Color3.new(255, 255, 255)}):Play()
				end)

		end
	end


	for _, textButton in pairs(weaponSelect.Holder.ScrollingFrame:GetChildren()) do 
		if textButton:IsA("TextButton") and textButton.Name ~= "Template" and not tools[textButton.Name] then 
			textButton:Destroy()
		end
	end
	-----------------------------------------------
	if selectedTool then 
		weaponSelect.btntext.Text = "Select Tool: "..selectedTool
	else 
		weaponSelect.btntext.Text = "Select Tool:"
	end
end


function setLocations()
	local template = screenUI.Draggable.Main.MainFrame.Holder.locationTP.Holder.ScrollingFrame.Template
	
	for name, position in pairs(locations) do 
		local copy = template:Clone()
		copy.Name = name
		copy.Text = name
		copy.Parent = template.Parent
				
		copy.MouseButton1Click:Connect(function()
			char:SetPrimaryPartCFrame(CFrame.new(locations[name]))
		end)		
		
		copy.MouseEnter:Connect(function()
			tweenService:Create(copy, tweenInfo, {TextColor3 = Color3.new(170, 0, 0)}):Play()
		end)

		copy.MouseLeave:Connect(function()
			tweenService:Create(copy, tweenInfo, {TextColor3 = Color3.new(255, 255, 255)}):Play()
		end)
		
	end
end


function dodgePlayers()
	local players = game.Players:GetPlayers()
	
	for i, v in pairs(players) do 
		local hasChar = v.Character
		
		if hasChar and hasChar ~= char and hasChar:FindFirstChild("HumanoidRootPart") then 
			local dist = (hasChar.HumanoidRootPart.Position - char.HumanoidRootPart.Position).magnitude

			
			if dist <= 4 then 
				local direction = (hasChar.HumanoidRootPart.Position - char.HumanoidRootPart.Position).unit
				char:SetPrimaryPartCFrame(hasChar.HumanoidRootPart.CFrame * CFrame.new(direction * -6))
			end
		end
		
	end
end



disableAntiCheat()
setAllMobsSelectable()
setLocations()



screenUI.Draggable.Main.MainFrame.Holder.KillAura.btndesign.TextButton.MouseButton1Click:Connect(function()
	killAura = not killAura

	if killAura then 
		tweenService:Create(screenUI.Draggable.Main.MainFrame.Holder.KillAura.btndesign.circle, tweenInfo, {Position = UDim2.new(0.6,0,0.075,0)}):Play()
		tweenService:Create(screenUI.Draggable.Main.MainFrame.Holder.KillAura.btndesign.Frame, tweenInfo, {ImageColor3 = Color3.new(0, .185, 0)}):Play()
		tweenService:Create(screenUI.Draggable.Main.MainFrame.Holder.KillAura.btndesign, tweenInfo, {ImageColor3 = Color3.new(0, .285, 0)}):Play()
	else 
		tweenService:Create(screenUI.Draggable.Main.MainFrame.Holder.KillAura.btndesign.circle, tweenInfo, {Position = UDim2.new(0.03,0,0.075,0)}):Play()
		tweenService:Create(screenUI.Draggable.Main.MainFrame.Holder.KillAura.btndesign, tweenInfo, {ImageColor3 = Color3.new(.4115, 0, 0)}):Play()
		tweenService:Create(screenUI.Draggable.Main.MainFrame.Holder.KillAura.btndesign.Frame, tweenInfo, {ImageColor3 = Color3.new(.162, 0, 0)}):Play()
	end
end)



screenUI.Draggable.Main.MainFrame.Holder.AutoFarm.btndesign.TextButton.MouseButton1Click:Connect(function()
	autoFarm = not autoFarm

	if autoFarm then 
		tweenService:Create(screenUI.Draggable.Main.MainFrame.Holder.AutoFarm.btndesign.circle, tweenInfo, {Position = UDim2.new(0.6,0,0.075,0)}):Play()
		tweenService:Create(screenUI.Draggable.Main.MainFrame.Holder.AutoFarm.btndesign.Frame, tweenInfo, {ImageColor3 = Color3.new(0, .185, 0)}):Play()
		tweenService:Create(screenUI.Draggable.Main.MainFrame.Holder.AutoFarm.btndesign, tweenInfo, {ImageColor3 = Color3.new(0, .285, 0)}):Play()
	else 
		tweenService:Create(screenUI.Draggable.Main.MainFrame.Holder.AutoFarm.btndesign.circle, tweenInfo, {Position = UDim2.new(0.03,0,0.075,0)}):Play()
		tweenService:Create(screenUI.Draggable.Main.MainFrame.Holder.AutoFarm.btndesign, tweenInfo, {ImageColor3 = Color3.new(.4115, 0, 0)}):Play()
		tweenService:Create(screenUI.Draggable.Main.MainFrame.Holder.AutoFarm.btndesign.Frame, tweenInfo, {ImageColor3 = Color3.new(.162, 0, 0)}):Play()
	end
end)

screenUI.Draggable.Main.MainFrame.Holder.instinct.btndesign.TextButton.MouseButton1Click:Connect(function()
	scared = not scared
	
	if scared then
		tweenService:Create(screenUI.Draggable.Main.MainFrame.Holder.instinct.btndesign.circle, tweenInfo, {Position = UDim2.new(0.6,0,0.075,0)}):Play()
		tweenService:Create(screenUI.Draggable.Main.MainFrame.Holder.instinct.btndesign.Frame, tweenInfo, {ImageColor3 = Color3.new(0, .185, 0)}):Play()
		tweenService:Create(screenUI.Draggable.Main.MainFrame.Holder.instinct.btndesign, tweenInfo, {ImageColor3 = Color3.new(0, .285, 0)}):Play()
	else
		tweenService:Create(screenUI.Draggable.Main.MainFrame.Holder.instinct.btndesign.circle, tweenInfo, {Position = UDim2.new(0.03,0,0.075,0)}):Play()
		tweenService:Create(screenUI.Draggable.Main.MainFrame.Holder.instinct.btndesign, tweenInfo, {ImageColor3 = Color3.new(.4115, 0, 0)}):Play()
		tweenService:Create(screenUI.Draggable.Main.MainFrame.Holder.instinct.btndesign.Frame, tweenInfo, {ImageColor3 = Color3.new(.162, 0, 0)}):Play()
	end
	
end)


UIS.InputBegan:Connect(function(input, typing)
	if typing then return end
	-------------------------------
	if input.KeyCode == Enum.KeyCode.RightShift then 
		screenUI.Enabled = not screenUI.Enabled 
	end
end)


player.CharacterAdded:Connect(function(newChar)
	char = newChar
end)


runService.Stepped:Connect(function()
	updateTools()

	if autoFarm then 	
		checkTargets()
		goToTarget()
	end	


	if killAura or autoFarm then 
		attack()
	end
	
	if scared then 
		dodgePlayers()
	end
	
end)
