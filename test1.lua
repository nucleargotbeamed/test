local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Colors = {
    Background = Color3.fromRGB(45, 48, 57),
    Secondary = Color3.fromRGB(32, 32, 38),
    Accent = Color3.fromRGB(224, 159, 93),
    Border = Color3.fromRGB(0, 0, 0),
    DarkBorder = Color3.fromRGB(58, 58, 58),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(181, 183, 193),
    ElementBg = Color3.fromRGB(33, 36, 43),
    CheckboxBg = Color3.fromRGB(33, 33, 41),
}

local function CreateTween(o, p, d)
    local t = TweenService:Create(o, TweenInfo.new(d or 0.2, Enum.EasingStyle.Quad), p)
    t:Play()
    return t
end

local function MakeDraggable(f, h)
    local d = false
    local s
    local p
    h.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            d = true
            s = i.Position
            p = f.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if d and i.UserInputType == Enum.UserInputType.MouseMovement then
            local g = i.Position - s
            f.Position = UDim2.new(p.X.Scale, p.X.Offset + g.X, p.Y.Scale, p.Y.Offset + g.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            d = false
        end
    end)
end

function Library:CreateWindow(title, subtitle)
    local Window = {Tabs = {}, CurrentTab = nil}

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game:GetService("CoreGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Size = UDim2.new(0, 577, 0, 619)
    MainFrame.Position = UDim2.new(0.35, 0, 0.15, 0)
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BorderColor3 = Colors.Border
    MainFrame.Parent = ScreenGui

    local MenuBar = Instance.new("Frame")
    MenuBar.Size = UDim2.new(1, 0, 0, 60)
    MenuBar.BackgroundColor3 = Colors.Background
    MenuBar.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0, 200, 0, 40)
    Title.Position = UDim2.new(0, 15, 0, 12)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.GothamBold
    Title.Text = title
    Title.TextColor3 = Colors.Text
    Title.TextSize = 25
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = MenuBar

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, 0, 0, 40)
    TabContainer.Position = UDim2.new(0, 140, 0, 20)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.FillDirection = Enum.FillDirection.Horizontal
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = TabContainer

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(0, 550, 0, 500)
    ContentFrame.Position = UDim2.new(0, 15, 0, 90)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ClipsDescendants = true
    ContentFrame.Parent = MainFrame

    MakeDraggable(MainFrame, MenuBar)

    Window.ScreenGui = ScreenGui
    Window.MainFrame = MainFrame
    Window.TabContainer = TabContainer
    Window.ContentFrame = ContentFrame

    return Window
end

function Library:CreateTab(Window, name)
    local Tab = {Sections = {}}

    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(0, 70, 0, 30)
    Button.BackgroundColor3 = Colors.ElementBg
    Button.BorderSizePixel = 0
    Button.Font = Enum.Font.Gotham
    Button.Text = name
    Button.TextColor3 = Colors.Text
    Button.TextSize = 14
    Button.Parent = Window.TabContainer

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, 0, 1, 0)
    Content.BackgroundTransparency = 1
    Content.Visible = false
    Content.Parent = Window.ContentFrame

    local Sections = Instance.new("ScrollingFrame")
    Sections.Size = UDim2.new(1, 0, 1, 0)
    Sections.ScrollBarThickness = 0
    Sections.BackgroundTransparency = 1
    Sections.Parent = Content

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 15)
    Layout.Parent = Sections

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Sections.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
    end)

    Button.MouseButton1Click:Connect(function()
        for _, t in ipairs(Window.Tabs) do
            t.Content.Visible = false
        end
        Content.Visible = true
        Window.CurrentTab = Tab
    end)

    Tab.Button = Button
    Tab.Content = Content
    Tab.SectionContainer = Sections

    table.insert(Window.Tabs, Tab)

    if #Window.Tabs == 1 then
        Content.Visible = true
        Window.CurrentTab = Tab
    end

    return Tab
end
function Library:AddWeaponCategory(Window, name)
    return self:CreateTab(Window, name)
end

function Library:CreateSection(Tab, name, width)
    local Section = {}
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(0, width or 215, 0, 30)
    Frame.BackgroundColor3 = Colors.Secondary
    Frame.BorderColor3 = Colors.DarkBorder
    Frame.Parent = Tab.SectionContainer

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -10, 0, 20)
    Title.Position = UDim2.new(0, 5, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Font = Enum.Font.Gotham
    Title.Text = name
    Title.TextColor3 = Colors.Text
    Title.TextSize = 10
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Frame

    local Container = Instance.new("Frame")
    Container.Position = UDim2.new(0, 5, 0, 25)
    Container.Size = UDim2.new(1, -10, 1, -30)
    Container.BackgroundTransparency = 1
    Container.Parent = Frame

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 7)
    Layout.Parent = Container

    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Frame.Size = UDim2.new(Frame.Size.X.Scale, Frame.Size.X.Offset, 0, Layout.AbsoluteContentSize.Y + 35)
    end)

    Section.Frame = Frame
    Section.Container = Container
    return Section
end

function Library:CreateCheckbox(Section, name, default, callback)
    callback = callback or function() end
    local v = default or false

    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, 0, 0, 18)
    F.BackgroundTransparency = 1
    F.Parent = Section.Container

    local B = Instance.new("TextButton")
    B.Size = UDim2.new(0, 9, 0, 9)
    B.Position = UDim2.new(0, 0, 0, 4)
    B.BackgroundColor3 = Colors.CheckboxBg
    B.BorderColor3 = Colors.Border
    B.Text = ""
    B.Parent = F

    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -20, 1, 0)
    L.Position = UDim2.new(0, 15, 0, 0)
    L.BackgroundTransparency = 1
    L.Font = Enum.Font.Gotham
    L.Text = name
    L.TextColor3 = Colors.Text
    L.TextSize = 10
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = F

    local function u()
        CreateTween(B, {BackgroundColor3 = v and Colors.Accent or Colors.CheckboxBg}, 0.1)
        callback(v)
    end

    B.MouseButton1Click:Connect(function()
        v = not v
        u()
    end)

    u()
end

function Library:CreateSlider(Section, name, min, max, default, callback)
    callback = callback or function() end
    local v = default or min

    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, 0, 0, 25)
    F.BackgroundTransparency = 1
    F.Parent = Section.Container

    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, 0, 0, 12)
    L.BackgroundTransparency = 1
    L.Font = Enum.Font.Gotham
    L.Text = name
    L.TextColor3 = Colors.Text
    L.TextSize = 10
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = F

    local BG = Instance.new("Frame")
    BG.Size = UDim2.new(1, -10, 0, 5)
    BG.Position = UDim2.new(0, 5, 0, 17)
    BG.BackgroundColor3 = Colors.ElementBg
    BG.BorderSizePixel = 0
    BG.Parent = F

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((v - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Colors.Accent
    Fill.BorderSizePixel = 0
    Fill.Parent = BG

    local d = false

    local function s(i)
        local p = math.clamp((i.Position.X - BG.AbsolutePosition.X) / BG.AbsoluteSize.X, 0, 1)
        v = math.floor(min + (max - min) * p)
        Fill.Size = UDim2.new(p, 0, 1, 0)
        callback(v)
    end

    BG.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            d = true
            s(i)
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if d and i.UserInputType == Enum.UserInputType.MouseMovement then
            s(i)
        end
    end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            d = false
        end
    end)
end

function Library:CreateDropdown(Section, name, options, default, callback)
    callback = callback or function() end
    local v = default or options[1]

    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, 0, 0, 40)
    F.BackgroundTransparency = 1
    F.Parent = Section.Container

    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 20)
    B.Position = UDim2.new(0, 0, 0, 18)
    B.BackgroundColor3 = Colors.ElementBg
    B.BorderColor3 = Colors.DarkBorder
    B.Font = Enum.Font.Gotham
    B.Text = "  " .. v
    B.TextColor3 = Colors.Text
    B.TextSize = 9
    B.TextXAlignment = Enum.TextXAlignment.Left
    B.Parent = F

    local M = Instance.new("Frame")
    M.Size = UDim2.new(1, 0, 0, #options * 22)
    M.Position = UDim2.new(0, 0, 0, 40)
    M.BackgroundColor3 = Colors.Secondary
    M.BorderColor3 = Colors.Border
    M.Visible = false
    M.Parent = F

    for i, o in ipairs(options) do
        local O = Instance.new("TextButton")
        O.Size = UDim2.new(1, 0, 0, 22)
        O.Position = UDim2.new(0, 0, 0, (i - 1) * 22)
        O.BackgroundTransparency = 1
        O.Font = Enum.Font.Gotham
        O.Text = "  " .. o
        O.TextColor3 = Colors.Text
        O.TextSize = 9
        O.TextXAlignment = Enum.TextXAlignment.Left
        O.Parent = M

        O.MouseButton1Click:Connect(function()
            v = o
            B.Text = "  " .. o
            M.Visible = false
            callback(o)
        end)
    end

    B.MouseButton1Click:Connect(function()
        M.Visible = not M.Visible
    end)
end

return Library
