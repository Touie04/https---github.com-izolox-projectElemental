while true do 

	wait(1)
	parent = script.Parent

	for i,v in pairs(parent:GetChildren()) do
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


	for i,v in pairs(parent:GetChildren()) do
		if v:IsA("ParticleEmitter") then
			v.Enabled = false
			
		elseif v:IsA("PointLight") then
			v.Enabled = false
			
		end	
	end

	wait(2)

end