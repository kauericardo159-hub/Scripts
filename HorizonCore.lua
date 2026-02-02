-- [[ HORIZON CORE MODULE - SALVAR NO GITHUB ]] --
local Core = {}

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Estados Internos
local States = {
	Fly = false,
	Noclip = false,
	ESP_Players = false,
	ESP_Items = false,
	FlySpeed = 50,
	WalkSpeed = 16
}

local Cache = {
	Connections = {},
	ESP_Objects = {}
}

-- [[ FUNÇÕES INTERNAS (Privadas) ]] --

local function ClearConnection(name)
	if Cache.Connections[name] then
		Cache.Connections[name]:Disconnect()
		Cache.Connections[name] = nil
	end
end

local function CreateHighlight(model, color)
	local hl = model:FindFirstChild("HorizonHL") or Instance.new("Highlight")
	hl.Name = "HorizonHL"
	hl.Parent = model
	hl.FillColor = color
	hl.OutlineColor = Color3.new(1,1,1)
	hl.FillTransparency = 0.6
	hl.OutlineTransparency = 0
	return hl
end

local function CreateTag(head, text, color)
	local tag = head:FindFirstChild("HorizonTag") or Instance.new("BillboardGui")
	tag.Name = "HorizonTag"
	tag.Parent = head
	tag.Size = UDim2.new(0, 200, 0, 50)
	tag.AlwaysOnTop = true
	tag.StudsOffset = Vector3.new(0, 3.5, 0)
	
	local lbl = tag:FindFirstChild("Label") or Instance.new("TextLabel", tag)
	lbl.Name = "Label"
	lbl.Size = UDim2.new(1,0,1,0)
	lbl.BackgroundTransparency = 1
	lbl.TextStrokeTransparency = 0
	lbl.TextColor3 = color
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 12
	lbl.Text = text
end

-- [[ SISTEMAS EXPORTADOS (Públicos) ]] --

function Core.SetFlySpeed(val)
	States.FlySpeed = tonumber(val) or 50
end

function Core.SetWalkSpeed(val)
	local num = tonumber(val)
	if num and LocalPlayer.Character then
		States.WalkSpeed = num
		LocalPlayer.Character.Humanoid.WalkSpeed = num
	end
end

function Core.ToggleFly()
	States.Fly = not States.Fly
	local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	
	if States.Fly and root then
		local bg = Instance.new("BodyGyro", root)
		bg.Name = "FlyGyro"; bg.maxTorque = Vector3.new(9e9,9e9,9e9); bg.P = 9e4
		local bv = Instance.new("BodyVelocity", root)
		bv.Name = "FlyVel"; bv.maxForce = Vector3.new(9e9,9e9,9e9)
		
		ClearConnection("FlyLoop")
		Cache.Connections["FlyLoop"] = RunService.RenderStepped:Connect(function()
			if not States.Fly or not root.Parent then 
				bg:Destroy(); bv:Destroy(); ClearConnection("FlyLoop")
				return 
			end
			bg.CFrame = Camera.CFrame
			bv.Velocity = Camera.CFrame.LookVector * States.FlySpeed
		end)
	else
		ClearConnection("FlyLoop")
		for _,v in pairs(root:GetChildren()) do 
			if v.Name == "FlyGyro" or v.Name == "FlyVel" then v:Destroy() end 
		end
	end
	return States.Fly
end

function Core.ToggleNoclip()
	States.Noclip = not States.Noclip
	ClearConnection("NoclipLoop")
	if States.Noclip then
		Cache.Connections["NoclipLoop"] = RunService.Stepped:Connect(function()
			if LocalPlayer.Character then
				for _,v in pairs(LocalPlayer.Character:GetDescendants()) do
					if v:IsA("BasePart") then v.CanCollide = false end
				end
			end
		end)
	end
	return States.Noclip
end

function Core.ToggleESP_Players()
	States.ESP_Players = not States.ESP_Players
	
	-- Loop de atualização leve (0.5s)
	ClearConnection("ESP_Players_Loop")
	if States.ESP_Players then
		Cache.Connections["ESP_Players_Loop"] = task.spawn(function()
			while States.ESP_Players do
				for _, p in pairs(Players:GetPlayers()) do
					if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
						local char = p.Character
						local color = p.TeamColor.Color
						
						CreateHighlight(char, color)
						
						local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - char.Head.Position).Magnitude)
						local item = "Vazio"
						local tool = char:FindFirstChildWhichIsA("Tool")
						if tool then item = "✋ " .. tool.Name end
						
						local txt = string.format("%s\nHP: %d | %dm\n%s", p.Name, char.Humanoid.Health, dist, item)
						CreateTag(char.Head, txt, color)
					end
				end
				task.wait(0.5)
			end
			-- Limpeza ao sair do loop
			for _,v in pairs(Workspace:GetDescendants()) do
				if v.Name == "HorizonHL" or v.Name == "HorizonTag" then v:Destroy() end
			end
		end)
	end
	return States.ESP_Players
end

function Core.ToggleESP_Items()
	States.ESP_Items = not States.ESP_Items
	
	ClearConnection("ESP_Items_Loop")
	if States.ESP_Items then
		Cache.Connections["ESP_Items_Loop"] = task.spawn(function()
			while States.ESP_Items do
				for _, obj in pairs(Workspace:GetChildren()) do
					if obj:IsA("Tool") or obj:FindFirstChild("ClickDetector") then
						local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart")
						if handle then
							CreateTag(handle, "📦 " .. obj.Name, Color3.fromRGB(255,255,0))
						end
					end
				end
				task.wait(1)
			end
			-- Limpeza Itens
			for _,v in pairs(Workspace:GetDescendants()) do
				if v.Name == "HorizonTag" and (v.Parent.Parent:IsA("Tool") or v.Parent:FindFirstChild("ClickDetector")) then v:Destroy() end
			end
		end)
	end
	return States.ESP_Items
end

function Core.ToggleFullBright()
	Lighting.ClockTime = 12
	Lighting.Brightness = 2
	Lighting.FogEnd = 100000
end

return Core
