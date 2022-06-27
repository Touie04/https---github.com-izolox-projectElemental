local module = shared.ClassGenerator:extend()


function module:new(Frame,PlayerObject)
    self.PlayerObject = PlayerObject
    self.Frame = Frame

    if not PlayerObject or not Frame then return nil end
    self.Name = Frame.Name
    self.CurrentSkill = ""


  Frame.MouseEnter:Connect(function()
    self.PlayerObject.MouseOnUi = self.Name

  end) 
  Frame.MouseLeave:Connect(function()
    if self.PlayerObject.MouseOnUi == self.Name then
        self.PlayerObject.MouseOnUi = nil
    end
  end)
 Frame.MouseButton1Down:Connect(function()
    
 end)  

 Frame.MouseButton1Up:Connect(function()
    
 end)
end


function  module:OnToolChanged()
    
end

function  module:OnToolEquipped()
    
end

return module