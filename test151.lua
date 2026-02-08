local UILib = loadstring(game:HttpGet("https://raw.githubusercontent.com/USER/REPO/main/UILib.lua"))()

local win = UILib:CreateWindow("gamesense")

local tabA = win:AddTab("A")
local tabB = win:AddTab("B")
local tabC = win:AddTab("C")
local tabD = win:AddTab("D")
local tabE = win:AddTab("E")
local tabF = win:AddTab("F")

local wm = Instance.new("TextLabel")
wm.Text = "game sense | norate"
wm.Font = Enum.Font.SourceSans
wm.TextSize = 12
wm.TextColor3 = Color3.new(1,1,1)
wm.BackgroundColor3 = Color3.fromRGB(17,17,17)
wm.Size = UDim2.fromOffset(180,24)
wm.Position = UDim2.new(1,-190,0,10)
wm.Visible = false
wm.Parent = tabF

local toggle = Instance.new("TextButton")
toggle.Text = "watermark"
toggle.Font = Enum.Font.Code
toggle.TextSize = 11
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundTransparency = 1
toggle.Size = UDim2.fromOffset(120,20)
toggle.Position = UDim2.fromOffset(20,20)
toggle.Parent = tabF

toggle.MouseButton1Click:Connect(function()
    wm.Visible = not wm.Visible
end)
