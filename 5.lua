local Library = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function CreateDraggable(frame)
    local dragging = false
    local dragInput, mousePos, framePos
    
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local mouse = game.Players.LocalPlayer:GetMouse()
            local absPos = frame.AbsolutePosition
            local absSize = frame.AbsoluteSize
            local mouseX = mouse.X - absPos.X
            local mouseY = mouse.Y - absPos.Y
            
            if mouseX > absSize.X - 12 or mouseY > absSize.Y - 12 then
                return
            end
            
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

function Library:CreateWindow(title)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GameSenseUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = game.CoreGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 660, 0, 545)
    MainFrame.Position = UDim2.new(0.5, -330, 0.5, -272)
    MainFrame.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
    MainFrame.BorderColor3 = Color3.fromRGB(61, 65, 76)
    MainFrame.BorderSizePixel = 5
    MainFrame.Parent = ScreenGui
    
    local TopLine = Instance.new("Frame")
    TopLine.Name = "TopLine"
    TopLine.Size = UDim2.new(1, 0, 0, 2)
    TopLine.Position = UDim2.new(0, 0, 0, 0)
    TopLine.BorderSizePixel = 0
    TopLine.Parent = MainFrame
    
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(69, 170, 242)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(252, 92, 101)),
        ColorSequenceKeypoint.new(0.66, Color3.fromRGB(254, 211, 48)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(69, 170, 242))
    }
    Gradient.Rotation = 90
    Gradient.Parent = TopLine
    
    local Watermark = Instance.new("TextLabel")
    Watermark.Name = "Watermark"
    Watermark.Size = UDim2.new(0, 120, 0, 25)
    Watermark.Position = UDim2.new(1, -135, 0, 15)
    Watermark.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
    Watermark.BorderColor3 = Color3.fromRGB(61, 65, 76)
    Watermark.BorderSizePixel = 5
    Watermark.Text = "game"
    Watermark.RichText = true
    Watermark.TextColor3 = Color3.fromRGB(255, 255, 255)
    Watermark.Font = Enum.Font.SourceSans
    Watermark.TextSize = 10
    Watermark.Visible = false
    Watermark.Parent = ScreenGui
    
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 90, 1, -2)
    TabContainer.Position = UDim2.new(0, 0, 0, 2)
    TabContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MainFrame
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Parent = TabContainer
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, -90, 1, -2)
    ContentFrame.Position = UDim2.new(0, 90, 0, 2)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame
    
    CreateDraggable(MainFrame)
    
    local ToggleKey = Enum.KeyCode.Period
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == ToggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
    
    local Window = {}
    Window.MainFrame = MainFrame
    Window.TabContainer = TabContainer
    Window.ContentFrame = ContentFrame
    Window.Watermark = Watermark
    Window.Tabs = {}
    Window.CurrentTab = nil
    
    function Window:AddTab(name)
        local Tab = {}
        
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name
        TabButton.Size = UDim2.new(1, 0, 0, 90)
        TabButton.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
        TabButton.BorderSizePixel = 0
        TabButton.Text = name
        TabButton.TextColor3 = Color3.fromRGB(90, 90, 90)
        TabButton.Font = Enum.Font.SourceSans
        TabButton.TextSize = 58
        TabButton.Parent = TabContainer
        
        local RightBorder = Instance.new("Frame")
        RightBorder.Size = UDim2.new(0, 1, 1, 0)
        RightBorder.Position = UDim2.new(1, -1, 0, 0)
        RightBorder.BackgroundColor3 = Color3.fromRGB(50, 48, 52)
        RightBorder.BorderSizePixel = 0
        RightBorder.Parent = TabButton
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "Content"
        TabContent.Size = UDim2.new(1, -170, 1, -170)
        TabContent.Position = UDim2.new(0, 85, 0, 85)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 0
        TabContent.ScrollBarImageColor3 = Color3.fromRGB(90, 90, 90)
        TabContent.Visible = false
        TabContent.Parent = ContentFrame
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 7)
        ContentLayout.Parent = TabContent
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Button.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
                tab.Button.TextColor3 = Color3.fromRGB(90, 90, 90)
                tab.Content.Visible = false
                tab.TopBorder.Visible = false
                tab.BottomBorder.Visible = false
                tab.RightBorder.Visible = true
            end
            
            TabButton.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabContent.Visible = true
            Tab.TopBorder.Visible = true
            Tab.BottomBorder.Visible = true
            RightBorder.Visible = false
            Window.CurrentTab = Tab
        end)
        
        local TopBorder = Instance.new("Frame")
        TopBorder.Name = "TopBorder"
        TopBorder.Size = UDim2.new(1, 0, 0, 1)
        TopBorder.Position = UDim2.new(0, 0, 0, 0)
        TopBorder.BackgroundColor3 = Color3.fromRGB(50, 48, 52)
        TopBorder.BorderSizePixel = 0
        TopBorder.Visible = false
        TopBorder.Parent = TabButton
        
        local BottomBorder = Instance.new("Frame")
        BottomBorder.Name = "BottomBorder"
        BottomBorder.Size = UDim2.new(1, 0, 0, 1)
        BottomBorder.Position = UDim2.new(0, 0, 1, -1)
        BottomBorder.BackgroundColor3 = Color3.fromRGB(50, 48, 52)
        BottomBorder.BorderSizePixel = 0
        BottomBorder.Visible = false
        BottomBorder.Parent = TabButton
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        Tab.TopBorder = TopBorder
        Tab.BottomBorder = BottomBorder
        Tab.RightBorder = RightBorder
        
        function Tab:AddCheckbox(text, default, callback)
            callback = callback or function() end
            
            local CheckboxFrame = Instance.new("Frame")
            CheckboxFrame.Name = "Checkbox"
            CheckboxFrame.Size = UDim2.new(1, 0, 0, 20)
            CheckboxFrame.BackgroundTransparency = 1
            CheckboxFrame.Parent = TabContent
            
            local CheckboxButton = Instance.new("TextButton")
            CheckboxButton.Size = UDim2.new(0, 9, 0, 9)
            CheckboxButton.Position = UDim2.new(0, 0, 0, 3)
            CheckboxButton.BackgroundColor3 = Color3.fromRGB(71, 71, 71)
            CheckboxButton.BorderColor3 = Color3.fromRGB(0, 0, 0)
            CheckboxButton.BorderSizePixel = 1
            CheckboxButton.Text = ""
            CheckboxButton.Parent = CheckboxFrame
            
            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -20, 1, 0)
            Label.Position = UDim2.new(0, 20, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = text
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.Font = Enum.Font.SourceSans
            Label.TextSize = 9
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = CheckboxFrame
            
            local toggled = default or false
            
            local function UpdateCheckbox()
                if toggled then
                    CheckboxButton.BackgroundColor3 = Color3.fromRGB(149, 192, 33)
                else
                    CheckboxButton.BackgroundColor3 = Color3.fromRGB(71, 71, 71)
                end
            end
            
            UpdateCheckbox()
            
            CheckboxButton.MouseButton1Click:Connect(function()
                toggled = not toggled
                UpdateCheckbox()
                callback(toggled)
            end)
            
            CheckboxButton.MouseEnter:Connect(function()
                CheckboxButton.BackgroundColor3 = toggled and Color3.fromRGB(149, 192, 33) or Color3.fromRGB(71, 71, 71)
            end)
            
            return CheckboxFrame
        end
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            TabButton.BackgroundColor3 = Color3.fromRGB(17, 17, 17)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabContent.Visible = true
            TopBorder.Visible = true
            BottomBorder.Visible = true
            RightBorder.Visible = false
            Window.CurrentTab = Tab
        end
        
        return Tab
    end
    
    return Window
end

return Library
