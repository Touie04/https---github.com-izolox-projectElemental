-- Services
local players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local CollectionService = game:GetService("CollectionService")
local ts = game:GetService("TweenService")

-- Modules
local util =  require(shared.SharedModules.UtilityModule)
-- Classes

-- Functions

-- Variables
local Camera = workspace.CurrentCamera
local Camfolder = workspace.CameraFolder
local camchildren = Camfolder:GetChildren()

for i,v in pairs(camchildren) do
	if v.Name == "CamLookAt" then
		table.remove(camchildren,i)
	end
end

-- Module

local LoadingScreen = shared.ClassGenerator:extend()


function LoadingScreen:LoadingScreen_Setup()
	self.LoadingScreen = self.Player.PlayerGui:WaitForChild("LoadingScreen")
	self.LoadingScreen.Enabled = true

	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CFrame = CFrame.new(camchildren[math.random(#camchildren)].Position,Camfolder.CamLookAt.Position)

	
	local lastcam = nil
	task.spawn(function()
		repeat
			print(self.Player,"Loading screen")
			local randomcam1 = camchildren[math.random(#camchildren)]

			if randomcam1 == lastcam then
				repeat
					randomcam1 = camchildren[math.random(#camchildren)]
				until
				randomcam1 ~= lastcam
			end
			lastcam = randomcam1
			local start =Camera.CFrame.Position
			local endp = randomcam1.Position

			local dist =(start - endp).Magnitude
			local midpoint = start:Lerp(endp,0.5)

			local pointa = start:Lerp(midpoint,0.5) + Vector3.new(math.random(-500,500),math.random(-100,100),math.random(-500,500))
			local pointb = midpoint
			local pointc = midpoint:Lerp(endp,0.5) + Vector3.new(math.random(-500,500),math.random(-100,100),math.random(-500,500))


			local speed = 0.2

			for i = 1,dist,speed do
				if self.PressedPlay then break end
				local p = i/dist
				local curv = util:cubicBezier(p,start,pointa,pointb,pointc,endp)
				Camera.CFrame = CFrame.new(Camera.CFrame:Lerp(CFrame.new(curv, endp), p).Position,Camfolder.CamLookAt.Position)
				game:GetService("RunService").Heartbeat:Wait()
			end

			game:GetService("RunService").Heartbeat:Wait()

		until self.PressedPlay == true
		self.Hud.Enabled = true
		Camera.CameraType = Enum.CameraType.Custom
	end)
	repeat task.wait() until  self.Loaded == true

	for i,v in pairs(self.LoadingScreen:GetChildren()) do
		if v:IsA("TextButton") or v:IsA("ImageButton") then
			local ogsize = v.Size
			v.MouseButton1Click:Connect(function()
				if v.Name == "Play" then
				local cc = game.Lighting.ColorCorrection
				local goal = {}
				goal.TintColor = Color3.fromRGB(0,0,0)
				local ti = TweenInfo.new(0.3)
				local tween = ts:Create(cc,ti,goal)
				tween:Play()

				local dtwaited = 0
				local charloaded: boolean
				task.spawn(function()
					charloaded =shared.Shared.Remotes.RequestInfo:InvokeServer("LoadCharacter")
				end)

          	 local t = tick()
				self.LoadingScreen.Enabled = false
				repeat 
				dtwaited  = tick() - t
		
				task.wait()
				until charloaded or dtwaited > 5
				if not charloaded then print("sum when wrong with loading character") 
				else
					local goal2 = {}
					goal2.TintColor = Color3.fromRGB(255, 255, 255)
					local ti2 = TweenInfo.new(0.3)
					local tween2 = ts:Create(cc,ti2,goal2)
					tween2:Play()
					
					self.PressedPlay = true
				end
				end
			end)
			v.MouseEnter:Connect(function()
				v.Size = UDim2.fromScale(v.Size.X.Scale * 1.1,v.Size.Y.Scale * 1.1)
			end)
			
			v.MouseLeave:Connect(function()
				v.Size = ogsize
			end)
			
		end
	end

end

return LoadingScreen