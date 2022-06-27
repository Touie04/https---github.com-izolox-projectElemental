while true do 

	wait(1)
	parent = script.Parent
	local circle = parent.Circle
	
	for i,v in pairs(circle:GetChildren())  do
		v:Emit(1)
		v.Enabled = true
	end
	wait(0.5)
	
	for i,v in pairs(parent.FireExplode:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			v:Emit(v:GetAttribute("EmitCount"))
		elseif v:IsA("Attachment") then
			for o,p in pairs(v:GetChildren()) do
				task.spawn(function()
					p.Enabled = true
					wait(0.6)
					p.Enabled = false
				end)
				
			end
		end
	end
	wait(0.5)
	for i,v in pairs(parent:GetChildren()) do
		if v:IsA("ParticleEmitter")  then
			v.Enabled = true
		elseif v:IsA("PointLight") then
			v.Enabled = true
		
		end	
	end
	
	wait(1.5)

	for i,v in pairs(parent:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			v.Enabled = false
			
		elseif v:IsA("PointLight") then
			v.Enabled = false
			
		end	
	end
	
	for i,v in pairs(circle:GetChildren()) do
		v.Enabled = false
	end

	wait(2)

end