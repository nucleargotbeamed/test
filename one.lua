local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Library = {}
Library.__index = Library

function Library:CreateWindow(settings)
    local self = setmetatable({}, Library)

    self.Title = settings.Title or "gamesense | norate"
    self.Keybind = settings.Keybind or Enum.KeyCode.Delete

    local player = Players.LocalPlayer

    local gui = Instance.new("ScreenGui")
    gui.Name = "UILibrary"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local main = Instance.new("Frame")
    main.Size = UDim2.fromOffset(660, 545)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(17,17,17)
    main.BorderSizePixel = 0
    main.Parent = gui
    main.Active = true
    main.Draggable = true

    local stroke = Instance.new("UIStroke", main)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(61,65,76)

    local gradient = Instance.new("Frame", main)
    gradient.Size = UDim2.new(1,0,0,3)
    gradient.BackgroundColor3 = Color3.fromRGB(255,255,255)
    gradient.BorderSizePixel = 0

    local grad = Instance.new("UIGradient", gradient)
    grad.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(69,170,242)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(252,92,101)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(254,211,48))
    }

    local watermark = Instance.new("TextLabel")
    watermark.Size = UDim2.fromOffset(170,24)
    watermark.Position = UDim2.new(1,-185,0,10)
    watermark.BackgroundColor3 = Color3.fromRGB(17,17,17)
    watermark.BorderSizePixel = 0
    watermark.Text = self.Title
    watermark.TextColor3 = Color3.fromRGB(255,255,255)
    watermark.Font = Enum.Font.Gotham
    watermark.TextSize = 12
    watermark.Visible = false
    watermark.Parent = main

    local tabHolder = Instance.new("Frame", main)
    tabHolder.Size = UDim2.fromOffset(60, main.Size.Y.Offset)
    tabHolder.BackgroundColor3 = Color3.fromRGB(12,12,12)
    tabHolder.BorderSizePixel = 0

    local tabsLayout = Instance.new("UIListLayout", tabHolder)
    tabsLayout.Padding = UDim.new(0,2)

    local pages = Instance.new("Frame", main)
    pages.Position = UDim2.fromOffset(60,0)
    pages.Size = UDim2.new(1,-60,1,0)
    pages.BackgroundTransparency = 1

    local pageFolder = Instance.new("Folder", pages)

    self.Gui = gui
    self.Main = main
    self.TabHolder = tabHolder
    self.Pages = pageFolder
    self.Watermark = watermark
    self.Tabs = {}

    UIS.InputBegan:Connect(function(input,gp)
        if gp then return end
        if input.KeyCode == self.Keybind then
            main.Visible = not main.Visible
        end
    end)

    return self
end

function Library:CreateTab(name)
    local tab = {}

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(60,60)
    btn.Text = name
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 26
    btn.BackgroundColor3 = Color3.fromRGB(12,12,12)
    btn.TextColor3 = Color3.fromRGB(150,150,150)
    btn.BorderSizePixel = 0
    btn.Parent = self.TabHolder

    local page = Instance.new("Frame")
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = self.Pages

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,6)

    btn.MouseButton1Click:Connect(function()
        for _,v in pairs(self.Pages:GetChildren()) do
            v.Visible = false
        end
        for _,v in pairs(self.TabHolder:GetChildren()) do
            if v:IsA("TextButton") then
                v.TextColor3 = Color3.fromRGB(150,150,150)
            end
        end
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        page.Visible = true
    end)

    if #self.Pages:GetChildren() == 1 then
        btn.TextColor3 = Color3.fromRGB(255,255,255)
        page.Visible = true
    end

    function tab:Toggle(text, callback)
        local t = Instance.new("TextButton")
        t.Size = UDim2.new(0,220,0,22)
        t.BackgroundColor3 = Color3.fromRGB(20,20,20)
        t.Text = text.." [OFF]"
        t.TextColor3 = Color3.fromRGB(255,255,255)
        t.Font = Enum.Font.Gotham
        t.TextSize = 12
        t.BorderSizePixel = 0
        t.Parent = page

        local state = false

        t.MouseButton1Click:Connect(function()
            state = not state
            t.Text = text.." ["..(state and "ON" or "OFF").."]"
            callback(state)
        end)
    end

    return tab
end

return Library
