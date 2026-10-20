
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("RunService")
local Rep = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remote = Rep:WaitForChild("TowerHubEvent")
local pg = player:WaitForChild("PlayerGui")

local old = pg:FindFirstChild("TowerHub")
if old then old:Destroy() end

local themes = {
 {"Emerald",Color3.fromRGB(34,197,94),Color3.fromRGB(7,26,18)},
 {"Mint",Color3.fromRGB(94,234,212),Color3.fromRGB(16,42,42)},
 {"Lime",Color3.fromRGB(163,230,53),Color3.fromRGB(32,40,16)},
 {"Ocean",Color3.fromRGB(56,189,248),Color3.fromRGB(10,25,40)},
 {"Purple",Color3.fromRGB(167,139,250),Color3.fromRGB(23,16,37)},
 {"Crimson",Color3.fromRGB(251,113,133),Color3.fromRGB(41,15,25)},
 {"Gold",Color3.fromRGB(251,191,36),Color3.fromRGB(36,27,10)},
 {"Arctic",Color3.fromRGB(226,232,240),Color3.fromRGB(23,32,44)},
 {"Orange",Color3.fromRGB(251,146,60),Color3.fromRGB(41,23,13)},
 {"Cyber",Color3.fromRGB(244,114,182),Color3.fromRGB(33,14,37)},
 {"Rainbow",Color3.fromRGB(255,0,0),Color3.fromRGB(20,20,20)}
}

local ti = 1
local speed, jump, flySpeed = 16, 50, 50
local state = {InfiniteJump=false,Noclip=false,ESP=false,Fly=false}
local highlights = {}
local collision = {}
local vertical = 0
local flyObjects
local accentObjects = {}
local valueLabels = {}
local buttons = {}

local function make(class, props, parent)
 local o = Instance.new(class)
 for k,v in pairs(props) do o[k]=v end
 o.Parent = parent
 return o
end

local gui = make("ScreenGui",{
 Name="TowerHub", ResetOnSpawn=false,
 DisplayOrder=50
},pg)

local main = make("Frame",{
 Size=UDim2.fromOffset(310,500),
 Position=UDim2.new(.5,-155,.5,-250),
 BackgroundColor3=themes[1][3],
 BorderSizePixel=0
},gui)
make("UICorner",{CornerRadius=UDim.new(0,15)},main)
local stroke = make("UIStroke",{Thickness=2,Color=themes[1][2]},main)

local header = make("TextButton",{
 Size=UDim2.new(1,0,0,44),
 BackgroundTransparency=1,
 Text="TOWER HUB  [ − ]",
 TextColor3=themes[1][2],
 Font=Enum.Font.GothamBold,TextSize=16
},main)

local body = make("ScrollingFrame",{
 Position=UDim2.fromOffset(10,48),
 Size=UDim2.new(1,-20,1,-58),
 BackgroundTransparency=1,
 BorderSizePixel=0,
 ScrollBarThickness=4,
 AutomaticCanvasSize=Enum.AutomaticSize.Y,
 CanvasSize=UDim2.new()
},main)
make("UIListLayout",{
 Padding=UDim.new(0,7),
 SortOrder=Enum.SortOrder.LayoutOrder
},body)

local function getChar()
 local c=player.Character
 if not c then return end
 return c,c:FindFirstChildOfClass("Humanoid"),
 c:FindFirstChild("HumanoidRootPart")
end

local function addButton(text, callback)
 local b=make("TextButton",{
  Size=UDim2.new(1,-4,0,38),
  BackgroundColor3=themes[ti][2],
  BackgroundTransparency=.72,
  Text=text,TextColor3=Color3.new(1,1,1),
  Font=Enum.Font.GothamSemibold,TextSize=13,
  AutoButtonColor=true
 },body)
 make("UICorner",{CornerRadius=UDim.new(0,8)},b)
 table.insert(buttons,b)
 b.Activated:Connect(callback)
 return b
end

local function toggleButton(label,key,callback)
 local b
 local function refresh()
  b.Text=label..": "..(state[key] and "ON" or "OFF")
 end
 b=addButton(label..": OFF",function()
  state[key]=not state[key]
  refresh()
  callback(state[key])
 end)
 return b
end

local function slider(label,min,max,initial,callback)
 local box=make("Frame",{
  Size=UDim2.new(1,-4,0,58),
  BackgroundTransparency=1
 },body)

 make("TextLabel",{
  Size=UDim2.new(1,-50,0,22),
  BackgroundTransparency=1,Text=label,
  TextColor3=Color3.new(1,1,1),
  Font=Enum.Font.GothamSemibold,TextSize=12,
  TextXAlignment=Enum.TextXAlignment.Left
 },box)

 local val=make("TextLabel",{
  Name="Value",Position=UDim2.new(1,-45,0,0),
  Size=UDim2.fromOffset(45,22),
  BackgroundTransparency=1,Text=tostring(initial),
  TextColor3=themes[ti][2],
  Font=Enum.Font.GothamBold,TextSize=13
 },box)
 table.insert(valueLabels,val)

 local track=make("TextButton",{
  Position=UDim2.fromOffset(0,31),
  Size=UDim2.new(1,-4,0,12),
  Text="",BackgroundColor3=Color3.fromRGB(50,60,55)
 },box)
 make("UICorner",{CornerRadius=UDim.new(1,0)},track)

 local fill=make("Frame",{
  Name="Accent",
  Size=UDim2.new((initial-min)/(max-min),0,1,0),
  BackgroundColor3=themes[ti][2],BorderSizePixel=0
 },track)
 make("UICorner",{CornerRadius=UDim.new(1,0)},fill)
 table.insert(accentObjects,fill)

 local dragging=false
 local function set(x)
  local ratio=math.clamp((x-track.AbsolutePosition.X)/
   math.max(track.AbsoluteSize.X,1),0,1)
  local n=math.floor(min+ratio*(max-min)+.5)
  val.Text=tostring(n)
  fill.Size=UDim2.new((n-min)/(max-min),0,1,0)
  callback(n)
 end

 track.Activated:Connect(function()
  set(UIS:GetMouseLocation().X)
 end)
 track.InputBegan:Connect(function(input)
  if input.UserInputType==Enum.UserInputType.Touch
  or input.UserInputType==Enum.UserInputType.MouseButton1 then
   dragging=true
   set(input.Position.X)
  end
 end)
 UIS.InputChanged:Connect(function(input)
  if dragging and (input.UserInputType==Enum.UserInputType.Touch
  or input.UserInputType==Enum.UserInputType.MouseMovement) then
   set(input.Position.X)
  end
 end)
 UIS.InputEnded:Connect(function(input)
  if input.UserInputType==Enum.UserInputType.Touch
  or input.UserInputType==Enum.UserInputType.MouseButton1 then
   dragging=false
  end
 end)
end

slider("WALK SPEED",16,100,speed,function(n)
 speed=n
 remote:FireServer("Speed",n)
end)

slider("JUMP POWER",20,200,jump,function(n)
 jump=n
 remote:FireServer("Jump",n)
end)

slider("FLY SPEED",10,150,flySpeed,function(n)
 flySpeed=n
end)

local function clearFly()
 if flyObjects then
  for _,v in ipairs(flyObjects) do
   if v and v.Parent then v:Destroy() end
  end
 end
 flyObjects=nil
 vertical=0
 local _,hum=getChar()
 if hum then hum.PlatformStand=false end
end

local function startFly()
 local c,hum,root=getChar()
 if not c or not hum or not root then return end
 clearFly()
 hum.PlatformStand=true
 local bv=Instance.new("BodyVelocity")
 bv.MaxForce=Vector3.new(1e6,1e6,1e6)
 bv.Velocity=Vector3.zero
 bv.Parent=root
 local bg=Instance.new("BodyGyro")
 bg.MaxTorque=Vector3.new(1e6,1e6,1e6)
 bg.P=10000
 bg.CFrame=workspace.CurrentCamera.CFrame
 bg.Parent=root
 flyObjects={bv,bg}
end

toggleButton("FLY","Fly",function(on)
 if on then startFly() else clearFly() end
end)

local up=addButton("FLY UP / DOWN: UP",function()
 vertical=vertical==1 and 0 or 1
 up.Text=vertical==1 and "FLY VERTICAL: UP" or "FLY VERTICAL: OFF"
end)
local down=addButton("FLY DOWN",function()
 vertical=vertical==-1 and 0 or -1
 down.Text=vertical==-1 and "FLY VERTICAL: DOWN" or "FLY DOWN"
end)

toggleButton("INFINITE JUMP","InfiniteJump",function() end)
UIS.JumpRequest:Connect(function()
 if not state.InfiniteJump then return end
 local _,hum=getChar()
 if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

toggleButton("NOCLIP","Noclip",function(on)
 if not on then
  for part,oldValue in pairs(collision) do
   if part.Parent then part.CanCollide=oldValue end
   collision[part]=nil
  end
 end
end)

RS.Stepped:Connect(function()
 local c,hum,root=getChar()
 if c then
  if state.Noclip then
   for _,p in ipairs(c:GetDescendants()) do
    if p:IsA("BasePart") then
     if collision[p]==nil then collision[p]=p.CanCollide end
     p.CanCollide=false
    end
   end
  end
  if state.Fly and flyObjects and root then
   local cam=workspace.CurrentCamera
   local move=hum.MoveDirection
   flyObjects[1].Velocity=move*flySpeed+Vector3.new(0,vertical*flySpeed,0)
   flyObjects[2].CFrame=cam.CFrame
  end
 end
end)

local function removeESP(p)
 if highlights[p] then
  highlights[p]:Destroy()
  highlights[p]=nil
 end
end

local function updateESP(p)
 if p==player then return end
 removeESP(p)
 if not state.ESP or not p.Character then return end
 local h=Instance.new("Highlight")
 h.Adornee=p.Character
 h.FillColor=themes[ti][2]
 h.OutlineColor=Color3.new(1,1,1)
 h.FillTransparency=.45
 h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
 h.Parent=gui
 highlights[p]=h
end

local function trackPlayer(p)
 if p==player then return end
 p.CharacterAdded:Connect(function()
  task.wait(.3)
  updateESP(p)
 end)
 p.CharacterRemoving:Connect(function()
  removeESP(p)
 end)
 if p.Character then updateESP(p) end
end

for _,p in ipairs(Players:GetPlayers()) do trackPlayer(p) end
Players.PlayerAdded:Connect(trackPlayer)
Players.PlayerRemoving:Connect(removeESP)

toggleButton("PLAYER ESP","ESP",function(on)
 for _,p in ipairs(Players:GetPlayers()) do
  if on then updateESP(p) else removeESP(p) end
 end
end)

addButton("GRAVITY COIL: CHECK",function()
 local bag=player:FindFirstChildOfClass("Backpack")
 local found=bag and bag:FindFirstChild("Gravity Coil")
 local c=player.Character
 if not found and c then found=c:FindFirstChild("Gravity Coil") end
 warn(found and "Gravity Coil found" or "Gravity Coil not found")
end)

local function paintTheme()
 local accent,bg=themes[ti][2],themes[ti][3]
 main.BackgroundColor3=bg
 stroke.Color=accent
 header.TextColor3=accent
 for _,b in ipairs(buttons) do b.BackgroundColor3=accent end
 for _,o in ipairs(accentObjects) do
  if o.Parent then o.BackgroundColor3=accent end
 end
 for _,o in ipairs(valueLabels) do
  if o.Parent then o.TextColor3=accent end
 end
 for _,h in pairs(highlights) do
  if h.Parent then h.FillColor=accent end
 end
end

addButton("CHANGE THEME",function()
 ti=ti%#themes+1
 paintTheme()
end)

addButton("RESET SETTINGS",function()
 speed,jump,flySpeed=16,50,50
 remote:FireServer("Speed",speed)
 remote:FireServer("Jump",jump)
 if state.Fly then
  state.Fly=false
  clearFly()
 end
 for _,p in ipairs(body:GetChildren()) do
  if p:IsA("Frame") then
   local nameLabel=p:FindFirstChildOfClass("TextLabel")
   local track=p:FindFirstChild("TextButton")
   if nameLabel and track then
    -- sliders update when dragged; reset values are applied server-side
   end
  end
 end
end)

local open=make("TextButton",{
 Size=UDim2.fromOffset(54,54),
 Position=UDim2.new(1,-65,.5,-27),
 Text="T",TextSize=24,Font=Enum.Font.GothamBold,
 TextColor3=Color3.new(1,1,1),
 BackgroundColor3=themes[1][2]
},gui)
make("UICorner",{CornerRadius=UDim.new(1,0)},open)

local expanded=true
header.Activated:Connect(function()
 expanded=not expanded
 body.Visible=expanded
 main.Size=expanded and UDim2.fromOffset(310,500)
  or UDim2.fromOffset(310,44)
 header.Text=expanded and "TOWER HUB  [ − ]"
  or "TOWER HUB  [ + ]"
end)
open.Activated:Connect(function()
 main.Visible=not main.Visible
end)

local dragging,startInput,startPos=false,nil,nil
header.InputBegan:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.Touch
 or input.UserInputType==Enum.UserInputType.MouseButton1 then
  dragging=true
  startInput=input.Position
  startPos=main.Position
 end
end)
UIS.InputChanged:Connect(function(input)
 if dragging and (input.UserInputType==Enum.UserInputType.Touch
 or input.UserInputType==Enum.UserInputType.MouseMovement) then
  local d=input.Position-startInput
  main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,
   startPos.Y.Scale,startPos.Y.Offset+d.Y)
 end
end)
UIS.InputEnded:Connect(function(input)
 if input.UserInputType==Enum.UserInputType.Touch
 or input.UserInputType==Enum.UserInputType.MouseButton1 then
  dragging=false
 end
end)

task.spawn(function()
 while gui.Parent do
  if themes[ti][1]=="Rainbow" then
   local c=Color3.fromHSV((os.clock()*.25)%1,1,1)
   stroke.Color=c
   header.TextColor3=c
   for _,b in ipairs(buttons) do b.BackgroundColor3=c end
   for _,o in ipairs(accentObjects) do
    if o.Parent then o.BackgroundColor3=c end
   end
   for _,o in ipairs(valueLabels) do
    if o.Parent then o.TextColor3=c end
   end
   for _,h in pairs(highlights) do
    if h.Parent then h.FillColor=c end
   end
  end
  task.wait(.05)
 end
end)

player.CharacterAdded:Connect(function()
 task.wait(.5)
 remote:FireServer("Speed",speed)
 remote:FireServer("Jump",jump)
 if state.Fly then startFly() end
end)

print("TOWER HUB loaded")
