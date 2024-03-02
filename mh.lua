if not game:IsLoaded() then repeat game.Loaded:Wait() until game:IsLoaded() end
_G.Settings = {
    Main = {
        ["StartProcess"] = true,
        ["FAST_ATTACK"] = true,
        ["CHECK_TIRAL"] = true,
    },

    -- Helper Name -- {เผ่าห้ามเหมือนกัน}
    Helper_Settings = {
        ["Helper1"]="mega09833",
        ["Helper2"]="Noshi_Ro8",
    },

    -- ตัวที่จะใช้ฟาร์ม -- 
    Main_Players = {
        ["Main_Name"] = {
            "HyperReggae",
            "Emanukato",
            "ForbHelpful",
            "Kadimwor",
            "Lionham_0",
            "Goldheck8",
            "Inloversit",
            "Ifecruna",
            "CommuniqueJin",
            "Heragene_8",
        }
    },

    -- ลงดันตอนเงินม่วงไม่พอ -- 
    Raids_Settings = {
        ["Selected_Microchip"] = "Flame", -- [[ "Flame","Ice","Quake","Light","Dark","String","Rumble","Magma","Human: Buddha","Sand","Bird: Phoenix","Dough" ]] --
        ["Fruit_UnStores"] = 1000000, -- จะเอาผลต่ำกว่า1ล้านมาลงดัน
        ["Auto_Raids"] = true,
    }
    
}


if game.PlaceId == 2753915549 then
	World1 = true
elseif game.PlaceId == 4442272183 then
	World2 = true
elseif game.PlaceId == 7449423635 then
	World3 = true
end


-- [[ CHECK TIER ZONE ]] --

local TextLabel = Instance.new("TextLabel")

TextLabel.Parent = game.StarterGui.ScreenGui
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1.000
TextLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.BorderSizePixel = 0
TextLabel.Position = UDim2.new(0.237163812, 0, 0.0325814523, 0)
TextLabel.Size = UDim2.new(0, 577, 0, 53)
TextLabel.Font = Enum.Font.SourceSans
TextLabel.Text = "Tier: ".. _G.Tier
TextLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
TextLabel.TextSize = 50.000
TextLabel.TextWrapped = true

spawn(function()
    while true do wait()
        pcall(function()
            if _G.Settings.Main["CHECK_TIRAL"] == true then
                _G.Tier = "nil"
            end
        end)
    end
end)

-- [[ TWEEN ZONE ]] --

function toTargetP(CFgo)
	if game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Health <= 0 or not game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid") then tween:Cancel() repeat wait() until game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid") and game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid").Health > 0 wait(7) return end
	if (game:GetService("Players")["LocalPlayer"].Character.HumanoidRootPart.Position - CFgo.Position).Magnitude <= 150 then
		pcall(function()
			tween:Cancel()

			game:GetService("Players")["LocalPlayer"].Character.HumanoidRootPart.CFrame = CFgo

			return
		end)
	end
	local tween_s = game:service"TweenService"
	local info = TweenInfo.new((game:GetService("Players")["LocalPlayer"].Character.HumanoidRootPart.Position - CFgo.Position).Magnitude/325, Enum.EasingStyle.Linear)
	tween = tween_s:Create(game.Players.LocalPlayer.Character["HumanoidRootPart"], info, {CFrame = CFgo})
	tween:Play()

	local tweenfunc = {}

	function tweenfunc:Stop()
		tween:Cancel()
	end

	return tweenfunc
end


Helper = {}
for i ,v in next , game:GetService("Workspace").Characters:GetChildren() do
    if v.Name ~= plr.Name  then
        if v:FindFirstChild("HumanoidRootPart") then
            table.insert(Helper, v.Name)
        end
    end
end
task.spawn(function()
	while wait() do
		pcall(function()
			if _G.Selected_Weapon == "Melee" then
				for i ,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
					if v.ToolTip == "Melee" then
						if game.Players.LocalPlayer.Backpack:FindFirstChild(tostring(v.Name)) then
							_G.Selected_Weapon = v.Name
						end
					end
				end
			end
		end)
	end
end)
function Check_Position()
    if game.Players["LocalPlayer"].Data.Race.Value == "Mink" and (CFrame.new(29020.66015625, 14889.4267578125, -379.2682800292969).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude >= 1500 then
        return false
    else 
        return true
    end
    if game.Players["LocalPlayer"].Data.Race.Value == "Human" and (CFrame.new(29237.294921875, 14889.4267578125, -206.94955444335938).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude >= 1500 then
        return false
    else 
        return true
    end
    if game.Players["LocalPlayer"].Data.Race.Value == "Fishman" and (CFrame.new(28224.056640625, 14889.4267578125, -210.5872039794922).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude >= 1500 then
        return false
    else 
        return true
    end
    if game.Players["LocalPlayer"].Data.Race.Value == "Skypiea" and (CFrame.new(28967.408203125, 14918.0751953125, 234.31198120117188).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude >= 1500 then
        return false
    else 
        return true
    end
end
function Check_Aweken_Races()
    for i,v in next , game.Players.LocalPlayer.Backpack:GetChildren() do
        if v.Name == "Awakening" then
            return true
        end 
    end
    return false
end
spawn(function()
    while true do wait()
        pcall(function()
            if _G.Settings.Main["StartProcess"] == true and not _G.BreakAllProcess then
                if _G.Settings.Helper_Settings["Helper1"] == Helper or _G.Settings.Helper_Settings["Helper2"] == Helper then
                    if game:GetService("Lighting").Sky.MoonTextureId~="http://www.roblox.com/asset/?id=9709149431" then
                        if Check_Position() == false then
                            if (CFrame.new(28286.35546875,14895.3017578125, 102.62469482421875).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude >= 1500 then
                                game:GetService("Players")["LocalPlayer"].Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875,14895.3017578125, 102.62469482421875)
                                wait(1)
                            else
                                if tostring(game.Players.LocalPlayer.Name) == _G.Settings.Helper_Settings["Helper1"] or tostring(game.Players.LocalPlayer.Name) == _G.Settings.Helper_Settings["Helper2"] then
                                    if game.Players["LocalPlayer"].Data.Race.Value == "Mink" then
                                        if (CFrame.new(29020.66015625, 14889.4267578125, -379.2682800292969).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 5 then
                                            print("Mink: Waiting For ...")
                                            wait()
                                            toTargetP(CFrame.new(29020.66015625, 14889.4267578125, -379.2682800292969))
                                        end
                                    elseif game.Players["LocalPlayer"].Data.Race.Value == "Human" then
                                        if (CFrame.new(29237.294921875, 14889.4267578125, -206.94955444335938).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 5 then
                                            print("Human: Waiting For ...")
                                            wait()
                                            toTargetP(CFrame.new(29237.294921875, 14889.4267578125, -206.94955444335938))
                                        end
                                    elseif game.Players["LocalPlayer"].Data.Race.Value == "Fishman" then
                                        if (CFrame.new(28224.056640625, 14889.4267578125, -210.5872039794922).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 5 then
                                            print("Fishman: Waiting For ...")
                                            wait()
                                            toTargetP(CFrame.new(28224.056640625, 14889.4267578125, -210.5872039794922))
                                        end
                                    elseif game.Players["LocalPlayer"].Data.Race.Value == "Skypiea" then
                                        if (CFrame.new(28967.408203125, 14918.0751953125, 234.31198120117188).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 5 then
                                            print("Skypiea: Waiting For ...")
                                            wait()
                                            toTargetP(CFrame.new(28967.408203125, 14918.0751953125, 234.31198120117188))
                                        end
                                    end
                                elseif tostring(game.Players.LocalPlayer.Name) == _G.Setting.Main_Players["Main_Name"] then
                                    if game.Players["LocalPlayer"].Data.Race.Value == "Mink" then
                                        if (CFrame.new(29020.66015625, 14889.4267578125, -379.2682800292969).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 5 then
                                            print("Mink: Waiting For ...")
                                            wait()
                                            toTargetP(CFrame.new(29020.66015625, 14889.4267578125, -379.2682800292969))
                                        end
                                    elseif game.Players["LocalPlayer"].Data.Race.Value == "Human" then
                                        if (CFrame.new(29237.294921875, 14889.4267578125, -206.94955444335938).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 5 then
                                            print("Human: Waiting For ...")
                                            wait()
                                            toTargetP(CFrame.new(29237.294921875, 14889.4267578125, -206.94955444335938))
                                        end
                                    elseif game.Players["LocalPlayer"].Data.Race.Value == "Fishman" then
                                        if (CFrame.new(28224.056640625, 14889.4267578125, -210.5872039794922).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 5 then
                                            print("Fishman: Waiting For ...")
                                            wait()
                                            toTargetP(CFrame.new(28224.056640625, 14889.4267578125, -210.5872039794922))
                                        end
                                    elseif game.Players["LocalPlayer"].Data.Race.Value == "Skypiea" then
                                        if (CFrame.new(28967.408203125, 14918.0751953125, 234.31198120117188).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 5 then
                                            print("Skypiea: Waiting For ...")
                                            wait()
                                            toTargetP(CFrame.new(28967.408203125, 14918.0751953125, 234.31198120117188))
                                        end
                                    end
                                end
                            end
                        elseif Check_Position()==true then
                            task.wait(3)
                            if game:GetService("Players")["LocalPlayer"].PlayerGui.Main.Timer.Visible == true then
                                if tostring(game.Players.LocalPlayer.Name) == _G.Settings.Helper_Settings["Helper1"] or tostring(game.Players.LocalPlayer.Name) == _G.Settings.Helper_Settings["Helper2"] then
                                    if  then --รอตัวรัน
                                        game.Players.LocalPlayer.Humanoid.Health = 0
                                    else
                                        if game.Players["LocalPlayer"].Data.Race.Value == "Mink" then
                                            for i, v in pairs(game:GetService("Workspace"):GetDescendants()) do
                                                if v.Name == "StartPoint" then
                                                    repeat wait()
                                                        toTargetP(v.CFrame * CFrame.new(0, 9, 0))
                                                    until not v.Name:FindFirstChild("StartPoint") or _G.Settings.Main["StartProcess"] == false or game:GetService("Players")["LocalPlayer"].PlayerGui.Main.Timer.Visible == false
                                                end
                                            end
                                        elseif game.Players["LocalPlayer"].Data.Race.Value == "Human" then
                                            for i, v in pairs(game.Workspace.Enemies:GetDescendants()) do
                                                if v.Name == "Darkness Master" and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                                    pcall(function()
                                                        repeat
                                                            wait(.1)
                                                            v.Humanoid.Health = 0
                                                            v.HumanoidRootPart.CanCollide = false
                                                            _G.Selected_Weapon = "Melee"
                                                            toTargetP(v.HumanoidRootPart.CFrame * CFrame(0,30,0))
                                                            FastAttackSpeed = true
                                                            sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
                                                        until _G.Settings.Main["StartProcess"] == false or not v.Parent or v.Humanoid.Health <= 0 or game:GetService("Players")["LocalPlayer"].PlayerGui.Main.Timer.Visible == false
                                                        FastAttackSpeed = false
                                                    end)
                                                end
                                            end
                                        elseif game.Players["LocalPlayer"].Data.Race.Value == "Skypiea" then
                                            for i, v in pairs(game:GetService("Workspace").Map.SkyTrial.Model:GetDescendants()) do
                                                repeat wait()
                                                    toTargetP(game.Workspace.Map.SkyTrial.Model.FinishPart.CFrame)
                                                until _G.Settings.Main["StartProcess"] == false or game:GetService("Players")["LocalPlayer"].PlayerGui.Main.Timer.Visible == false
                                            end
                                        end
                                    end
                                elseif tostring(game.Players.LocalPlayer.Name) == _G.Setting.Main_Players["Main_Name"] then
                                    if game.Players["LocalPlayer"].Data.Race.Value == "Mink" then
                                        for i, v in pairs(game:GetService("Workspace"):GetDescendants()) do
                                            if v.Name == "StartPoint" then
                                                repeat wait()
                                                    toTargetP(v.CFrame * CFrame.new(0, 9, 0))
                                                until not v.Name:FindFirstChild("StartPoint") or _G.Settings.Main["StartProcess"] == false or game:GetService("Players")["LocalPlayer"].PlayerGui.Main.Timer.Visible == false
                                            end
                                        end
                                    elseif game.Players["LocalPlayer"].Data.Race.Value == "Human" then
                                        for i, v in pairs(game.Workspace.Enemies:GetDescendants()) do
                                            if v.Name == "Darkness Master" and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                                pcall(function()
                                                    repeat
                                                        wait(.1)
                                                        v.Humanoid.Health = 0
                                                        v.HumanoidRootPart.CanCollide = false
                                                        _G.Selected_Weapon = "Melee"
                                                        toTargetP(v.HumanoidRootPart.CFrame * CFrame(0,30,0))
                                                        FastAttackSpeed = true
                                                        sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
                                                    until _G.Settings.Main["StartProcess"] == false or not v.Parent or v.Humanoid.Health <= 0 or game:GetService("Players")["LocalPlayer"].PlayerGui.Main.Timer.Visible == false
                                                    FastAttackSpeed = false
                                                end)
                                            end
                                        end
                                    elseif game.Players["LocalPlayer"].Data.Race.Value == "Skypiea" then
                                        for i, v in pairs(game:GetService("Workspace").Map.SkyTrial.Model:GetDescendants()) do
                                            repeat wait()
                                                toTargetP(game.Workspace.Map.SkyTrial.Model.FinishPart.CFrame)
                                            until _G.Settings.Main["StartProcess"] == false or game:GetService("Players")["LocalPlayer"].PlayerGui.Main.Timer.Visible == false
                                        end
                                    end
                                end
                            elseif game:GetService("Players")["LocalPlayer"].PlayerGui.Main.Timer.Visible == false then
                                task.wait(1)
                                game:GetService("VirtualInputManager"):SendKeyEvent(true,"T",true,game)
                                wait(0.5)
                                game:GetService("VirtualInputManager"):SendKeyEvent(true,"T",false,game)
                            end
                        end
                    -- elseif game:GetService("Lighting").Sky.MoonTextureId~="http://www.roblox.com/asset/?id=9709149431" and Check_Aweken_Races()==true then
                    --     -- รอ ทำใหม่
                    -- else
                    --     if game:GetService("Players").LocalPlayer.Data.Fragments.Value <= 24000 then
                    --         if not _G.BreakAllProcess then
                    --             _G.BreakAllProcess = true
                    --         end 
                    --     end
                    end
                else
                    print("ERROR: NOT FOUND HELPER")
                end
            end
        end)
    end
end)

-- [[ FAST ATTACK ZONE ]] --

local CombatFramework = require(game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework)
local Camera = require(game.ReplicatedStorage.Util.CameraShaker)
local Attack = 0.1
local backup = require(game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework)
local Crit = getupvalues(backup)[2]
local CombatFrameworkR = getupvalues(backup)[2]
local CameraShakerR = require(game.ReplicatedStorage.Util.CameraShaker)
local plr = game.Players.LocalPlayer
local CbFw = debug.getupvalues(require(plr.PlayerScripts.CombatFramework))
local CbFw2 = CbFw[2]
local CombatFramework = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
local CombatFrameworkR = getupvalues(CombatFramework)[2]
local RigController = require(game:GetService("Players")["LocalPlayer"].PlayerScripts.CombatFramework.RigController)
local RigControllerR = getupvalues(RigController)[2]
local realbhit = require(game.ReplicatedStorage.CombatFramework.RigLib)
local cooldownfastattack = tick()
function CurrentWeapon()
	local ac = CombatFrameworkR.activeController
	local ret = ac.blades[1]
	if not ret then return game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Name end
	pcall(function()
		while ret.Parent~=game.Players.LocalPlayer.Character do ret=ret.Parent end
	end)
	if not ret then return game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Name end
	return ret
end
function getAllBladeHits(Sizes)
	local Hits = {}
	local Client = game.Players.LocalPlayer
	local Enemies = game:GetService("Workspace").Enemies:GetChildren()
	for i=1,#Enemies do local v = Enemies[i]
		local Human = v:FindFirstChildOfClass("Humanoid")
		if Human and Human.RootPart and Human.Health > 0 and Client:DistanceFromCharacter(Human.RootPart.Position) < Sizes+5 then
			table.insert(Hits,Human.RootPart)
		end
	end
	return Hits
end
function AttackFunction()
	local ac = CombatFrameworkR.activeController
	if ac and ac.equipped then
		for indexincrement = 1, 1 do
			local bladehit = getAllBladeHits(60)
			if #bladehit > 0 then
				local AcAttack8 = debug.getupvalue(ac.attack, 5)
				local AcAttack9 = debug.getupvalue(ac.attack, 6)
				local AcAttack7 = debug.getupvalue(ac.attack, 4)
				local AcAttack10 = debug.getupvalue(ac.attack, 7)
				local NumberAc12 = (AcAttack8 * 798405 + AcAttack7 * 727595) % AcAttack9
				local NumberAc13 = AcAttack7 * 798405
				(function()
					NumberAc12 = (NumberAc12 * AcAttack9 + NumberAc13) % 1099511627776
					AcAttack8 = math.floor(NumberAc12 / AcAttack9)
					AcAttack7 = NumberAc12 - AcAttack8 * AcAttack9
				end)()
				AcAttack10 = AcAttack10 + 1
				debug.setupvalue(ac.attack, 5, AcAttack8)
				debug.setupvalue(ac.attack, 6, AcAttack9)
				debug.setupvalue(ac.attack, 4, AcAttack7)
				debug.setupvalue(ac.attack, 7, AcAttack10)
				for k, v in pairs(ac.animator.anims.basic) do
					v:Play(0.01,0.01,0.01)
				end   
				              
				if game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool") and ac.blades and ac.blades[1] then 
					game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("weaponChange",tostring(CurrentWeapon()))
					game.ReplicatedStorage.Remotes.Validator:FireServer(math.floor(NumberAc12 / 1099511627776 * 16777215), AcAttack10)
					game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("hit", bladehit, 2, "") 
				end
			end
		end
	end
end
local x = game.Players.LocalPlayer
local c = game:GetService("ReplicatedStorage")
local Q = require(x.PlayerScripts.CombatFramework);
local Y = getupvalues(Q)[2];
local C = require(game.ReplicatedStorage.Util.CameraShaker):Stop();
function Maxincrement()
    local H = #Y.activeController.anims.basic;
    return H;
end;
coroutine.wrap(function()
	task.spawn(function()
		xpcall(function()
			local ac = CombatFrameworkR.activeController
			ac:attack()
		end, function(x)
			print("[ERROR] Fast Attack: "..x)
		end)
	end)
end)()
coroutine.wrap(function()
	while task.wait() do
		local ac = CombatFrameworkR.activeController
		if ac and ac.equipped then
			if FastAttackSpeed and _G.Settings.Main["FAST_ATTACK"] == false then
				AttackFunction()
				if tick() - cooldownfastattack > .3 then 
					wait(0.1) 
					cooldownfastattack = tick()
				end
			elseif FastAttackSpeed and _G.Settings.Main["FAST_ATTACK"] == false then
				if ac.hitboxMagnitude ~= 55 then
					ac.hitboxMagnitude = 55
				end
				ac:attack()
			end
		end
	end
end)()


-- [[ RAIDS ZONE ]] --

function GET_FRIUIT()
    fruit = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("getInventoryFruits")
    for i,v in pairs(fruit) do
        if v["Price"] < _G.Settings.Raids_Settings["Fruit_UnStores"] then
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("LoadFruit",v["Name"])
        end
    end
end
spawn(function ()
    while true do wait()
        if _G.Settings.Raids_Settings["Auto_Raids"] and game:GetService("Lighting").Sky.MoonTextureId~="http://www.roblox.com/asset/?id=9709149431" then
            game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("RaidsNpc", "Select", _G.Settings.Raids_Settings["Selected_Microchip"])
        end
    end
end)
spawn(function()
    while true do wait()
        pcall(function ()
            if _G.Settings.Raids_Settings["Auto_Raids"] and game:GetService("Lighting").Sky.MoonTextureId~="http://www.roblox.com/asset/?id=9709149431" and (game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Special Microchip") or game:GetService("Players").LocalPlayer.Character:FindFirstChild("Special Microchip")) then
                if not _G.BreakAllProcess then
                    _G.BreakAllProcess = true
                end
                if not game:GetService("Workspace")["_WorldOrigin"].Locations:FindFirstChild("Island 1") then
                    if game:GetService("Players")["LocalPlayer"].PlayerGui.Main.Timer.Visible == false then
                        if World2 then
                            fireclickdetector(game:GetService("Workspace").Map.CircleIsland.RaidSummon2.Button.Main.ClickDetector)
                        elseif World3 then
                            fireclickdetector(game:GetService("Workspace").Map["Boat Castle"].RaidSummon2.Button.Main.ClickDetector)
                        end
                    elseif game:GetService("Players")["LocalPlayer"].PlayerGui.Main.Timer.Visible == true then
                            for i,v in pairs(game:GetService("Workspace").Enemies:GetDescendants()) do
                                if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
                                    pcall(function()
                                        repeat task.wait()                                    
                                            v.Humanoid.Health = 0
                                            v.HumanoidRootPart.CanCollide = false
                                            sethiddenproperty(game:GetService("Players").LocalPlayer,"SimulationRadius",math.huge)
                                        until not _G.Settings.Raids_Settings["Auto_Raids"] or not v.Parent or v.Humanoid.Health <= 0
                                    end)
                                end
                            end
                        end
					end
                else
                    if game:GetService("Workspace")["_WorldOrigin"].Locations:FindFirstChild("Island 5") then
						toTargetP(game:GetService("Workspace")["_WorldOrigin"].Locations:FindFirstChild("Island 5").CFrame*CFrame.new(0,30,0))
					elseif game:GetService("Workspace")["_WorldOrigin"].Locations:FindFirstChild("Island 4") then
						toTargetP(game:GetService("Workspace")["_WorldOrigin"].Locations:FindFirstChild("Island 4").CFrame*CFrame.new(0,30,0))
					elseif game:GetService("Workspace")["_WorldOrigin"].Locations:FindFirstChild("Island 3") then
						toTargetP(game:GetService("Workspace")["_WorldOrigin"].Locations:FindFirstChild("Island 3").CFrame*CFrame.new(0,30,0))
					elseif game:GetService("Workspace")["_WorldOrigin"].Locations:FindFirstChild("Island 2") then
						toTargetP(game:GetService("Workspace")["_WorldOrigin"].Locations:FindFirstChild("Island 2").CFrame*CFrame.new(0,30,0))
					elseif game:GetService("Workspace")["_WorldOrigin"].Locations:FindFirstChild("Island 1") then
						toTargetP(game:GetService("Workspace")["_WorldOrigin"].Locations:FindFirstChild("Island 1").CFrame*CFrame.new(0,30,0))
					end
				end
            elseif _G.Settings.Raids_Settings["Auto_Raids"] and game:GetService("Lighting").Sky.MoonTextureId~="http://www.roblox.com/asset/?id=9709149431" and ( not game:GetService("Players").LocalPlayer.Backpack:FindFirstChild("Special Microchip") or not game:GetService("Players").LocalPlayer.Character:FindFirstChild("Special Microchip")) then
                GET_FRIUIT()
            else
                _G.BreakAllProcess = nil
            end
        end)
    end
end)
