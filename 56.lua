local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

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

local function CreateTween(object, properties, duration)
    local tween = TweenService:Create(object, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad), properties)
    tween:Play()
    return tween
end

local function MakeDraggable(frame, handle)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function Library:CreateWindow(title, subtitle)
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "OneTapUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = game:GetService("CoreGui")

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 577, 0, 619)
    MainFrame.Position = UDim2.new(0.35, 0, 0.15, 0)
    MainFrame.BackgroundColor3 = Colors.Background
    MainFrame.BorderColor3 = Colors.Border
    MainFrame.BorderSizePixel = 1
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 5)
    UICorner.Parent = MainFrame

    local ColorBar = Instance.new("Frame")
    ColorBar.Name = "ColorBar"
    ColorBar.Size = UDim2.new(1, 0, 0, 8)
    ColorBar.BackgroundColor3 = Colors.Accent
    ColorBar.BorderSizePixel = 0
    ColorBar.ZIndex = 2
    ColorBar.Parent = MainFrame

    local ColorBarCorner = Instance.new("UICorner")
    ColorBarCorner.CornerRadius = UDim.new(0, 2)
    ColorBarCorner.Parent = ColorBar

    local ColorBarGlow = Instance.new("ImageLabel")
    ColorBarGlow.Size = UDim2.new(1, 20, 1, 20)
    ColorBarGlow.Position = UDim2.new(0, -10, 0, -10)
    ColorBarGlow.BackgroundTransparency = 1
    ColorBarGlow.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    ColorBarGlow.ImageColor3 = Colors.Accent
    ColorBarGlow.ImageTransparency = 0.5
    ColorBarGlow.ScaleType = Enum.ScaleType.Slice
    ColorBarGlow.SliceCenter = Rect.new(10, 10, 10, 10)
    ColorBarGlow.Parent = ColorBar

    local MenuBar = Instance.new("Frame")
    MenuBar.Name = "MenuBar"
    MenuBar.Size = UDim2.new(1, 0, 0, 60)
    MenuBar.Position = UDim2.new(0, 0, 0, 8)
    MenuBar.BackgroundColor3 = Colors.Background
    MenuBar.BorderSizePixel = 0
    MenuBar.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(0, 200, 0, 40)
    TitleLabel.Position = UDim2.new(0, 15, 0, 12)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.Text = title
    TitleLabel.TextColor3 = Colors.Text
    TitleLabel.TextSize = 25
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = MenuBar

    local Line1 = Instance.new("Frame")
    Line1.Name = "Line1"
    Line1.Size = UDim2.new(0, 1, 0, 30)
    Line1.Position = UDim2.new(0, 120, 0, 15)
    Line1.BackgroundColor3 = Color3.fromRGB(55, 58, 67)
    Line1.BorderSizePixel = 0
    Line1.Parent = MainFrame

    local Line2 = Instance.new("Frame")
    Line2.Name = "Line2"
    Line2.Size = UDim2.new(0, 550, 0, 1)
    Line2.Position = UDim2.new(0, 15, 0, 68)
    Line2.BackgroundColor3 = Color3.fromRGB(55, 58, 67)
    Line2.BorderSizePixel = 0
    Line2.Parent = MainFrame

    local Line3 = Instance.new("Frame")
    Line3.Name = "Line3"
    Line3.Size = UDim2.new(0, 550, 0, 1)
    Line3.Position = UDim2.new(0, 15, 0, 590)
    Line3.BackgroundColor3 = Color3.fromRGB(55, 58, 67)
    Line3.BorderSizePixel = 0
    Line3.Parent = MainFrame

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Name = "Subtitle"
    SubtitleLabel.Size = UDim2.new(0, 200, 0, 20)
    SubtitleLabel.Position = UDim2.new(0, 0, 0, 5)
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Font = Enum.Font.Gotham
    SubtitleLabel.Text = subtitle
    SubtitleLabel.TextColor3 = Colors.TextSecondary
    SubtitleLabel.TextSize = 12
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.Parent = Line3

    local SettingsBtn = Instance.new("TextButton")
    SettingsBtn.Name = "SettingsBtn"
    SettingsBtn.Size = UDim2.new(0, 20, 0, 20)
    SettingsBtn.Position = UDim2.new(0, 533, 0, -8)
    SettingsBtn.BackgroundTransparency = 1
    SettingsBtn.Font = Enum.Font.GothamBold
    SettingsBtn.Text = "⚙"
    SettingsBtn.TextColor3 = Color3.fromRGB(196, 198, 208)
    SettingsBtn.TextSize = 13
    SettingsBtn.Parent = Line3

    SettingsBtn.MouseEnter:Connect(function()
        CreateTween(SettingsBtn, {TextColor3 = Colors.Accent}, 0.2)
    end)

    SettingsBtn.MouseLeave:Connect(function()
        CreateTween(SettingsBtn, {TextColor3 = Color3.fromRGB(196, 198, 208)}, 0.2)
    end)

    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 0, 40)
    TabContainer.Position = UDim2.new(0, 140, 0, 23)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.Parent = TabContainer

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(0, 550, 0, 500)
    ContentFrame.Position = UDim2.new(0, 15, 0, 80)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.ClipsDescendants = true
    ContentFrame.Parent = MainFrame

    MakeDraggable(MainFrame, MenuBar)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.Delete then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    local ConfigFrame = Instance.new("Frame")
    ConfigFrame.Name = "ConfigFrame"
    ConfigFrame.Size = UDim2.new(0, 265, 0, 272)
    ConfigFrame.Position = UDim2.new(0.66, 0, 0.05, 0)
    ConfigFrame.BackgroundColor3 = Colors.Background
    ConfigFrame.BorderColor3 = Colors.Border
    ConfigFrame.BorderSizePixel = 1
    ConfigFrame.Visible = false
    ConfigFrame.Parent = ScreenGui

    local ConfigCorner = Instance.new("UICorner")
    ConfigCorner.CornerRadius = UDim.new(0, 5)
    ConfigCorner.Parent = ConfigFrame

    local ConfigColorBar = Instance.new("Frame")
    ConfigColorBar.Size = UDim2.new(1, 0, 0, 8)
    ConfigColorBar.BackgroundColor3 = Colors.Accent
    ConfigColorBar.BorderSizePixel = 0
    ConfigColorBar.Parent = ConfigFrame

    local ConfigColorBarCorner = Instance.new("UICorner")
    ConfigColorBarCorner.CornerRadius = UDim.new(0, 2)
    ConfigColorBarCorner.Parent = ConfigColorBar

    SettingsBtn.MouseButton1Click:Connect(function()
        ConfigFrame.Visible = not ConfigFrame.Visible
    end)

    MakeDraggable(ConfigFrame, ConfigColorBar)

    Window.ScreenGui = ScreenGui
    Window.MainFrame = MainFrame
    Window.TabContainer = TabContainer
    Window.ContentFrame = ContentFrame
    Window.ConfigFrame = ConfigFrame

    return Window
end

return Library
