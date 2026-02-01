local GameSenseUI = {}
GameSenseUI.__index = GameSenseUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local Theme = {
    Background = Color3.fromRGB(17, 17, 17),
    TabBackground = Color3.fromRGB(12, 12, 12),
    Border = Color3.fromRGB(61, 65, 76),
    TabBorder = Color3.fromRGB(50, 48, 52),
    Accent = Color3.fromRGB(149, 192, 33),
    AccentAlt = Color3.fromRGB(144, 187, 32),
    GradientBlue = Color3.fromRGB(69, 170, 242),
    GradientRed = Color3.fromRGB(252, 92, 101),
    GradientYellow = Color3.fromRGB(254, 211, 48),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(90, 90, 90),
    TextHover = Color3.fromRGB(200, 200, 200),
    ElementBackground = Color3.fromRGB(71, 71, 71),
    ElementBorder = Color3.fromRGB(0, 0, 0),
    ToggleBackground = Color3.fromRGB(40, 40, 40),
    ToggleEnabled = Color3.fromRGB(149, 192, 33),
    ToggleDisabled = Color3.fromRGB(60, 60, 60),
    
    TextSize = 16,
    TitleSize = 18,
    ButtonTextSize = 16,
    SliderTextSize = 16,
    CheckboxTextSize = 16,
    DropdownTextSize = 16,
    SectionTextSize = 15,
    TabTextSize = 16,
    LabelTextSize = 16,
    WatermarkTextSize = 14,
    NotificationTitleSize = 15,
    NotificationMessageSize = 14,
    
    TabWidth = 100,
    TabHeight = 50,
    WindowWidth = 700,
    WindowHeight = 550,
    ElementHeight = 28,
    SliderHeight = 38,
    ButtonHeight = 32,
    DropdownHeight = 48,
    TextboxHeight = 44,
}

local function Create(class, properties)
    local instance = Instance.new(class)
    for prop, value in pairs(properties) do
        if prop ~= "Parent" then
            instance[prop] = value
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 4),
        Parent = parent
    })
end

local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        Parent = parent
    })
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

function GameSenseUI:SetTheme(newTheme)
    for key, value in pairs(newTheme) do
        Theme[key] = value
    end
end

function GameSenseUI:GetTheme()
    return Theme
end

function GameSenseUI:CreateWindow(config)
    config = config or {}
    local title = config.Title or "game"
    local subtitle = config.Subtitle or "sense"
    local toggleKey = config.ToggleKey or Enum.KeyCode.Insert
    
    if config.Theme then
        for key, value in pairs(config.Theme) do
            Theme[key] = value
        end
    end
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    Window.ToggleKey = toggleKey

    local ScreenGui = Create("ScreenGui", {
        Name = "GameSenseUI",
        Parent = RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui") or game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 999
    })

    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        Position = UDim2.new(0.5, -Theme.WindowWidth/2, 0.5, -Theme.WindowHeight/2),
        Size = UDim2.new(0, Theme.WindowWidth, 0, Theme.WindowHeight),
        ClipsDescendants = true,
    })

    local OuterBorder = Create("Frame", {
        Name = "OuterBorder",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 4, 1, 4),
        Position = UDim2.new(0, -2, 0, -2),
    })
    AddStroke(OuterBorder, Theme.Border, 2)

    local InnerBorder = Create("Frame", {
        Name = "InnerBorder",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 2, 0, 2),
    })
    AddStroke(InnerBorder, Theme.Border, 1)

    local GradientLine = Create("Frame", {
        Name = "GradientLine",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, 0, 0, 2),
        BorderSizePixel = 0,
    })

    Create("UIGradient", {
        Parent = GradientLine,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.GradientBlue),
            ColorSequenceKeypoint.new(0.5, Theme.GradientRed),
            ColorSequenceKeypoint.new(1, Theme.GradientYellow)
        }),
    })

    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundColor3 = Theme.TabBackground,
        Position = UDim2.new(0, 0, 0, 2),
        Size = UDim2.new(0, Theme.TabWidth, 1, -2),
        BorderSizePixel = 0,
    })

    Create("Frame", {
        Name = "RightBorder",
        Parent = TabContainer,
        BackgroundColor3 = Theme.TabBorder,
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BorderSizePixel = 0,
    })

    local TabButtonContainer = Create("Frame", {
        Name = "TabButtons",
        Parent = TabContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
    })

    Create("UIListLayout", {
        Parent = TabButtonContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, Theme.TabWidth + 10, 0, 15),
        Size = UDim2.new(1, -(Theme.TabWidth + 25), 1, -30),
    })

    local DragHandle = Create("Frame", {
        Name = "DragHandle",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 25),
    })
    MakeDraggable(MainFrame, DragHandle)

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Window.ToggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    Window.ScreenGui = ScreenGui
    Window.MainFrame = MainFrame
    Window.TabContainer = TabButtonContainer
    Window.ContentContainer = ContentContainer

    function Window:SetToggleKey(key)
        Window.ToggleKey = key
    end

    function Window:SetPosition(x, y)
        MainFrame.Position = UDim2.new(0, x, 0, y)
    end

    function Window:SetSize(width, height)
        MainFrame.Size = UDim2.new(0, width, 0, height)
    end

    function Window:CreateTab(config)
        if type(config) == "string" then
            config = {Name = config}
        end
        config = config or {}
        local name = config.Name or "Tab"
        local icon = config.Icon
        
        local Tab = {}
        Tab.Elements = {}
        Tab.Columns = {}
        local tabIndex = #Window.Tabs + 1
        
        local TabButton = Create("TextButton", {
            Name = "Tab_" .. name,
            Parent = TabButtonContainer,
            BackgroundColor3 = Theme.TabBackground,
            Size = UDim2.new(1, 0, 0, Theme.TabHeight),
            BorderSizePixel = 0,
            Font = Enum.Font.GothamBold,
            Text = name,
            TextColor3 = Theme.TextDark,
            TextSize = Theme.TabTextSize,
            LayoutOrder = tabIndex,
            AutoButtonColor = false,
        })
        
        local TopBorder = Create("Frame", {
            Name = "TopBorder",
            Parent = TabButton,
            BackgroundColor3 = Theme.TabBorder,
            Size = UDim2.new(1, 0, 0, 1),
            BorderSizePixel = 0,
            Visible = false,
        })
        
        local BottomBorder = Create("Frame", {
            Name = "BottomBorder",
            Parent = TabButton,
            BackgroundColor3 = Theme.TabBorder,
            Position = UDim2.new(0, 0, 1, -1),
            Size = UDim2.new(1, 0, 0, 1),
            BorderSizePixel = 0,
            Visible = false,
        })
        
        local TabContent = Create("ScrollingFrame", {
            Name = "Content_" .. name,
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Accent,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
        })
        
        local ColumnContainer = Create("Frame", {
            Name = "ColumnContainer",
            Parent = TabContent,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
        })
        
        Create("UIListLayout", {
            Parent = ColumnContainer,
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 10),
        })
        
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Button.TextColor3 = Theme.TextDark
                tab.Button.BackgroundColor3 = Theme.TabBackground
                tab.Button.TopBorder.Visible = false
                tab.Button.BottomBorder.Visible = false
                tab.Content.Visible = false
            end
            TabButton.TextColor3 = Theme.Text
            TabButton.BackgroundColor3 = Theme.Background
            TopBorder.Visible = true
            BottomBorder.Visible = true
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end)
        
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                TabButton.TextColor3 = Theme.TextHover
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                TabButton.TextColor3 = Theme.TextDark
            end
        end)
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        Tab.ColumnContainer = ColumnContainer
        
        if tabIndex == 1 then
            TabButton.TextColor3 = Theme.Text
            TabButton.BackgroundColor3 = Theme.Background
            TopBorder.Visible = true
            BottomBorder.Visible = true
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end
        
        function Tab:CreateColumn(title, count)
            count = count or 2
            local Column = {}
            Column.Elements = {}
            
            local columnWidth = 1 / count
            local columnIndex = #Tab.Columns + 1
            
            local ColumnFrame = Create("Frame", {
                Name = "Column_" .. title,
                Parent = ColumnContainer,
                BackgroundColor3 = Theme.TabBackground,
                Size = UDim2.new(columnWidth, -10, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = columnIndex,
            })
            AddCorner(ColumnFrame, 4)
            AddStroke(ColumnFrame, Theme.Border, 1)
            
            local ColumnTitle = Create("Frame", {
                Name = "TitleBar",
                Parent = ColumnFrame,
                BackgroundColor3 = Theme.Background,
                Size = UDim2.new(1, 0, 0, 28),
            })
            AddCorner(ColumnTitle, 4)
            
            Create("TextLabel", {
                Parent = ColumnTitle,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = title,
                TextColor3 = Theme.Text,
                TextSize = Theme.TitleSize,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local ColumnContent = Create("Frame", {
                Name = "Content",
                Parent = ColumnFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 32),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
            })
            
            Create("UIListLayout", {
                Parent = ColumnContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 6),
            })
            
            Create("UIPadding", {
                Parent = ColumnContent,
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
            })
            
            Column.Frame = ColumnFrame
            Column.Content = ColumnContent
            
            function Column:CreateSection(config)
                if type(config) == "string" then
                    config = {Text = config}
                end
                config = config or {}
                local text = config.Text or "Section"
                local textSize = config.TextSize or Theme.SectionTextSize
                
                local Section = {}
                
                local SectionFrame = Create("Frame", {
                    Name = "Section_" .. text,
                    Parent = ColumnContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, textSize + 10),
                })
                
                local SectionLabel = Create("TextLabel", {
                    Parent = SectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "— " .. text .. " —",
                    TextColor3 = Theme.Accent,
                    TextSize = textSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                function Section:SetText(newText)
                    SectionLabel.Text = "— " .. newText .. " —"
                end
                
                function Section:SetTextSize(size)
                    SectionLabel.TextSize = size
                    SectionFrame.Size = UDim2.new(1, 0, 0, size + 10)
                end
                
                return Section
            end
            
            function Column:CreateCheckbox(config)
                config = config or {}
                local text = config.Text or "Checkbox"
                local default = config.Default or false
                local textSize = config.TextSize or Theme.CheckboxTextSize
                local callback = config.Callback or function() end
                
                local Checkbox = {}
                local toggled = default
                
                local CheckboxFrame = Create("Frame", {
                    Name = "Checkbox_" .. text,
                    Parent = ColumnContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, textSize + 8),
                })
                
                local indicatorSize = math.max(12, textSize - 2)
                local CheckboxIndicator = Create("Frame", {
                    Name = "Indicator",
                    Parent = CheckboxFrame,
                    BackgroundColor3 = toggled and Theme.Accent or Theme.ElementBackground,
                    Position = UDim2.new(0, 0, 0.5, -indicatorSize/2),
                    Size = UDim2.new(0, indicatorSize, 0, indicatorSize),
                })
                AddCorner(CheckboxIndicator, 3)
                AddStroke(CheckboxIndicator, Theme.ElementBorder, 1)
                
                local CheckboxLabel = Create("TextLabel", {
                    Parent = CheckboxFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, indicatorSize + 8, 0, 0),
                    Size = UDim2.new(1, -(indicatorSize + 8), 1, 0),
                    Font = Enum.Font.SourceSans,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = textSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                local ClickButton = Create("TextButton", {
                    Parent = CheckboxFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                })
                
                ClickButton.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    TweenService:Create(CheckboxIndicator, TweenInfo.new(0.15), {
                        BackgroundColor3 = toggled and Theme.Accent or Theme.ElementBackground
                    }):Play()
                    callback(toggled)
                end)
                
                function Checkbox:Set(value)
                    toggled = value
                    CheckboxIndicator.BackgroundColor3 = toggled and Theme.Accent or Theme.ElementBackground
                    callback(toggled)
                end
                
                function Checkbox:Get()
                    return toggled
                end
                
                function Checkbox:SetText(newText)
                    CheckboxLabel.Text = newText
                end
                
                function Checkbox:SetTextSize(size)
                    CheckboxLabel.TextSize = size
                    local newSize = math.max(12, size - 2)
                    CheckboxIndicator.Size = UDim2.new(0, newSize, 0, newSize)
                    CheckboxIndicator.Position = UDim2.new(0, 0, 0.5, -newSize/2)
                    CheckboxLabel.Position = UDim2.new(0, newSize + 8, 0, 0)
                    CheckboxLabel.Size = UDim2.new(1, -(newSize + 8), 1, 0)
                    CheckboxFrame.Size = UDim2.new(1, 0, 0, size + 8)
                end
                
                table.insert(Column.Elements, Checkbox)
                return Checkbox
            end

            function Column:CreateToggle(config)
                config = config or {}
                local text = config.Text or "Toggle"
                local default = config.Default or false
                local textSize = config.TextSize or Theme.CheckboxTextSize
                local callback = config.Callback or function() end
                
                local Toggle = {}
                local toggled = default
                
                local ToggleFrame = Create("Frame", {
                    Name = "Toggle_" .. text,
                    Parent = ColumnContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, textSize + 12),
                })
                
                local ToggleLabel = Create("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -50, 1, 0),
                    Font = Enum.Font.SourceSans,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = textSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                local ToggleBackground = Create("Frame", {
                    Name = "ToggleBG",
                    Parent = ToggleFrame,
                    BackgroundColor3 = toggled and Theme.ToggleEnabled or Theme.ToggleDisabled,
                    Position = UDim2.new(1, -42, 0.5, -10),
                    Size = UDim2.new(0, 40, 0, 20),
                })
                AddCorner(ToggleBackground, 10)
                
                local ToggleCircle = Create("Frame", {
                    Name = "Circle",
                    Parent = ToggleBackground,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                    Size = UDim2.new(0, 16, 0, 16),
                })
                AddCorner(ToggleCircle, 8)
                
                local ClickButton = Create("TextButton", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                })
                
                local function updateToggle()
                    TweenService:Create(ToggleBackground, TweenInfo.new(0.2), {
                        BackgroundColor3 = toggled and Theme.ToggleEnabled or Theme.ToggleDisabled
                    }):Play()
                    TweenService:Create(ToggleCircle, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
                        Position = toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                    }):Play()
                end
                
                ClickButton.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    updateToggle()
                    callback(toggled)
                end)
                
                function Toggle:Set(value)
                    toggled = value
                    updateToggle()
                    callback(toggled)
                end
                
                function Toggle:Get()
                    return toggled
                end
                
                function Toggle:SetText(newText)
                    ToggleLabel.Text = newText
                end
                
                function Toggle:SetTextSize(size)
                    ToggleLabel.TextSize = size
                    ToggleFrame.Size = UDim2.new(1, 0, 0, size + 12)
                end
                
                table.insert(Column.Elements, Toggle)
                return Toggle
            end
            
            function Column:CreateSlider(config)
                config = config or {}
                local text = config.Text or "Slider"
                local min = config.Min or 0
                local max = config.Max or 100
                local default = config.Default or min
                local increment = config.Increment or 1
                local suffix = config.Suffix or ""
                local textSize = config.TextSize or Theme.SliderTextSize
                local callback = config.Callback or function() end
                
                local Slider = {}
                local value = default
                
                local SliderFrame = Create("Frame", {
                    Name = "Slider_" .. text,
                    Parent = ColumnContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, textSize + 22),
                })
                
                local SliderLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, textSize + 4),
                    Font = Enum.Font.SourceSans,
                    Text = text .. ": " .. tostring(value) .. suffix,
                    TextColor3 = Theme.Text,
                    TextSize = textSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                local SliderBackground = Create("Frame", {
                    Parent = SliderFrame,
                    BackgroundColor3 = Theme.ElementBackground,
                    Position = UDim2.new(0, 0, 0, textSize + 6),
                    Size = UDim2.new(1, 0, 0, 14),
                })
                AddCorner(SliderBackground, 4)
                AddStroke(SliderBackground, Theme.ElementBorder, 1)
                
                local SliderFill = Create("Frame", {
                    Parent = SliderBackground,
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                    BorderSizePixel = 0,
                })
                AddCorner(SliderFill, 4)
                
                local SliderButton = Create("TextButton", {
                    Parent = SliderBackground,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                })
                
                local dragging = false
                
                local function updateSlider(inputPos)
                    local relativeX = math.clamp((inputPos.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
                    local rawValue = min + (max - min) * relativeX
                    value = math.floor(rawValue / increment + 0.5) * increment
                    value = math.clamp(value, min, max)
                    
                    TweenService:Create(SliderFill, TweenInfo.new(0.05), {
                        Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    }):Play()
                    SliderLabel.Text = text .. ": " .. tostring(value) .. suffix
                    callback(value)
                end
                
                SliderButton.MouseButton1Down:Connect(function()
                    dragging = true
                    updateSlider(UserInputService:GetMouseLocation())
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input.Position)
                    end
                end)
                
                function Slider:Set(val)
                    value = math.clamp(val, min, max)
                    SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    SliderLabel.Text = text .. ": " .. tostring(value) .. suffix
                    callback(value)
                end
                
                function Slider:Get()
                    return value
                end
                
                function Slider:SetText(newText)
                    text = newText
                    SliderLabel.Text = text .. ": " .. tostring(value) .. suffix
                end
                
                function Slider:SetTextSize(size)
                    SliderLabel.TextSize = size
                    SliderLabel.Size = UDim2.new(1, 0, 0, size + 4)
                    SliderBackground.Position = UDim2.new(0, 0, 0, size + 6)
                    SliderFrame.Size = UDim2.new(1, 0, 0, size + 22)
                end
                
                table.insert(Column.Elements, Slider)
                return Slider
            end

            function Column:CreateButton(config)
                config = config or {}
                local text = config.Text or "Button"
                local textSize = config.TextSize or Theme.ButtonTextSize
                local height = config.Height or Theme.ButtonHeight
                local callback = config.Callback or function() end
                
                local Button = {}
                
                local ButtonFrame = Create("TextButton", {
                    Name = "Button_" .. text,
                    Parent = ColumnContent,
                    BackgroundColor3 = Theme.ElementBackground,
                    Size = UDim2.new(1, 0, 0, height),
                    Font = Enum.Font.SourceSansSemibold,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = textSize,
                    AutoButtonColor = false,
                })
                AddCorner(ButtonFrame, 4)
                AddStroke(ButtonFrame, Theme.ElementBorder, 1)
                
                ButtonFrame.MouseButton1Click:Connect(callback)
                
                ButtonFrame.MouseEnter:Connect(function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Accent}):Play()
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.15), {BackgroundColor3 = Theme.ElementBackground}):Play()
                end)
                
                function Button:SetText(newText)
                    ButtonFrame.Text = newText
                end
                
                function Button:SetTextSize(size)
                    ButtonFrame.TextSize = size
                end
                
                function Button:SetHeight(h)
                    ButtonFrame.Size = UDim2.new(1, 0, 0, h)
                end
                
                table.insert(Column.Elements, Button)
                return Button
            end

            function Column:CreateDropdown(config)
                config = config or {}
                local text = config.Text or "Dropdown"
                local options = config.Options or {}
                local default = config.Default or options[1]
                local textSize = config.TextSize or Theme.DropdownTextSize
                local callback = config.Callback or function() end
                
                local Dropdown = {}
                local selected = default
                local opened = false
                
                local DropdownFrame = Create("Frame", {
                    Name = "Dropdown_" .. text,
                    Parent = ColumnContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, textSize + 32),
                    ClipsDescendants = false,
                    ZIndex = 5,
                })
                
                local DropdownLabel = Create("TextLabel", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, textSize + 4),
                    Font = Enum.Font.SourceSans,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = textSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                local DropdownButton = Create("TextButton", {
                    Parent = DropdownFrame,
                    BackgroundColor3 = Theme.ElementBackground,
                    Position = UDim2.new(0, 0, 0, textSize + 6),
                    Size = UDim2.new(1, 0, 0, 26),
                    Font = Enum.Font.SourceSans,
                    Text = "  " .. tostring(selected or "Select..."),
                    TextColor3 = Theme.Text,
                    TextSize = textSize - 2,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    ZIndex = 5,
                })
                AddCorner(DropdownButton, 4)
                AddStroke(DropdownButton, Theme.ElementBorder, 1)
                
                local Arrow = Create("TextLabel", {
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -25, 0, 0),
                    Size = UDim2.new(0, 20, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "▼",
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    ZIndex = 5,
                })
                
                local OptionContainer = Create("Frame", {
                    Parent = DropdownButton,
                    BackgroundColor3 = Theme.TabBackground,
                    Position = UDim2.new(0, 0, 1, 4),
                    Size = UDim2.new(1, 0, 0, math.min(#options * 28, 140)),
                    Visible = false,
                    ClipsDescendants = true,
                    ZIndex = 10,
                })
                AddCorner(OptionContainer, 4)
                AddStroke(OptionContainer, Theme.ElementBorder, 1)
                
                local OptionScroll = Create("ScrollingFrame", {
                    Parent = OptionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Theme.Accent,
                    CanvasSize = UDim2.new(0, 0, 0, #options * 28),
                    ZIndex = 10,
                })
                
                Create("UIListLayout", {
                    Parent = OptionScroll,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })
                
                local function refreshOptions()
                    for _, child in pairs(OptionScroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    for i, option in ipairs(options) do
                        local OptionButton = Create("TextButton", {
                            Parent = OptionScroll,
                            BackgroundColor3 = Theme.TabBackground,
                            Size = UDim2.new(1, 0, 0, 28),
                            Font = Enum.Font.SourceSans,
                            Text = "  " .. option,
                            TextColor3 = Theme.Text,
                            TextSize = textSize - 2,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            LayoutOrder = i,
                            AutoButtonColor = false,
                            ZIndex = 10,
                        })
                        
                        OptionButton.MouseEnter:Connect(function()
                            TweenService:Create(OptionButton, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ElementBackground}):Play()
                        end)
                        
                        OptionButton.MouseLeave:Connect(function()
                            TweenService:Create(OptionButton, TweenInfo.new(0.1), {BackgroundColor3 = Theme.TabBackground}):Play()
                        end)
                        
                        OptionButton.MouseButton1Click:Connect(function()
                            selected = option
                            DropdownButton.Text = "  " .. option
                            OptionContainer.Visible = false
                            opened = false
                            TweenService:Create(Arrow, TweenInfo.new(0.15), {Rotation = 0}):Play()
                            callback(option)
                        end)
                    end
                end
                
                refreshOptions()
                
                DropdownButton.MouseButton1Click:Connect(function()
                    opened = not opened
                    OptionContainer.Visible = opened
                    TweenService:Create(Arrow, TweenInfo.new(0.15), {Rotation = opened and 180 or 0}):Play()
                end)
                
                function Dropdown:Set(option)
                    selected = option
                    DropdownButton.Text = "  " .. option
                    callback(option)
                end
                
                function Dropdown:Get()
                    return selected
                end
                
                function Dropdown:Refresh(newOptions, newDefault)
                    options = newOptions
                    selected = newDefault or newOptions[1]
                    DropdownButton.Text = "  " .. tostring(selected or "Select...")
                    OptionContainer.Size = UDim2.new(1, 0, 0, math.min(#options * 28, 140))
                    OptionScroll.CanvasSize = UDim2.new(0, 0, 0, #options * 28)
                    refreshOptions()
                end
                
                function Dropdown:SetTextSize(size)
                    textSize = size
                    DropdownLabel.TextSize = size
                    DropdownButton.TextSize = size - 2
                end
                
                table.insert(Column.Elements, Dropdown)
                return Dropdown
            end

            function Column:CreateTextbox(config)
                config = config or {}
                local text = config.Text or "Textbox"
                local placeholder = config.Placeholder or ""
                local textSize = config.TextSize or Theme.TextSize
                local callback = config.Callback or function() end
                
                local Textbox = {}
                
                local TextboxFrame = Create("Frame", {
                    Name = "Textbox_" .. text,
                    Parent = ColumnContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, textSize + 30),
                })
                
                local TextboxLabel = Create("TextLabel", {
                    Parent = TextboxFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, textSize + 4),
                    Font = Enum.Font.SourceSans,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = textSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                local TextboxInput = Create("TextBox", {
                    Parent = TextboxFrame,
                    BackgroundColor3 = Theme.ElementBackground,
                    Position = UDim2.new(0, 0, 0, textSize + 6),
                    Size = UDim2.new(1, 0, 0, 24),
                    Font = Enum.Font.SourceSans,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = Theme.TextDark,
                    Text = "",
                    TextColor3 = Theme.Text,
                    TextSize = textSize - 2,
                    ClearTextOnFocus = false,
                })
                AddCorner(TextboxInput, 4)
                AddStroke(TextboxInput, Theme.ElementBorder, 1)
                
                Create("UIPadding", {
                    Parent = TextboxInput,
                    PaddingLeft = UDim.new(0, 8),
                })
                
                TextboxInput.FocusLost:Connect(function(enterPressed)
                    callback(TextboxInput.Text, enterPressed)
                end)
                
                function Textbox:Set(value)
                    TextboxInput.Text = value
                end
                
                function Textbox:Get()
                    return TextboxInput.Text
                end
                
                function Textbox:SetTextSize(size)
                    TextboxLabel.TextSize = size
                    TextboxInput.TextSize = size - 2
                end
                
                table.insert(Column.Elements, Textbox)
                return Textbox
            end
            
            function Column:CreateKeybind(config)
                config = config or {}
                local text = config.Text or "Keybind"
                local default = config.Default or Enum.KeyCode.Unknown
                local textSize = config.TextSize or Theme.TextSize
                local callback = config.Callback or function() end
                local changedCallback = config.ChangedCallback or function() end
                
                local Keybind = {}
                local currentKey = default
                local listening = false
                
                local KeybindFrame = Create("Frame", {
                    Name = "Keybind_" .. text,
                    Parent = ColumnContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, textSize + 10),
                })
                
                local KeybindLabel = Create("TextLabel", {
                    Parent = KeybindFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.6, 0, 1, 0),
                    Font = Enum.Font.SourceSans,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = textSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                local KeybindButton = Create("TextButton", {
                    Parent = KeybindFrame,
                    BackgroundColor3 = Theme.ElementBackground,
                    Position = UDim2.new(0.6, 5, 0.5, -12),
                    Size = UDim2.new(0.4, -5, 0, 24),
                    Font = Enum.Font.SourceSans,
                    Text = currentKey.Name,
                    TextColor3 = Theme.Text,
                    TextSize = textSize - 2,
                    AutoButtonColor = false,
                })
                AddCorner(KeybindButton, 4)
                AddStroke(KeybindButton, Theme.ElementBorder, 1)
                
                KeybindButton.MouseButton1Click:Connect(function()
                    listening = true
                    KeybindButton.Text = "..."
                end)
                
                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            KeybindButton.Text = currentKey.Name
                            listening = false
                            changedCallback(currentKey)
                        end
                    elseif input.KeyCode == currentKey and not gameProcessed then
                        callback(currentKey)
                    end
                end)
                
                function Keybind:Set(key)
                    currentKey = key
                    KeybindButton.Text = key.Name
                end
                
                function Keybind:Get()
                    return currentKey
                end
                
                function Keybind:SetTextSize(size)
                    KeybindLabel.TextSize = size
                    KeybindButton.TextSize = size - 2
                end
                
                table.insert(Column.Elements, Keybind)
                return Keybind
            end
            
            function Column:CreateLabel(config)
                if type(config) == "string" then
                    config = {Text = config}
                end
                config = config or {}
                local text = config.Text or "Label"
                local textSize = config.TextSize or Theme.LabelTextSize
                local color = config.Color or Theme.Text
                
                local Label = {}
                
                local LabelFrame = Create("TextLabel", {
                    Name = "Label",
                    Parent = ColumnContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, textSize + 6),
                    Font = Enum.Font.SourceSans,
                    Text = text,
                    TextColor3 = color,
                    TextSize = textSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                function Label:Set(newText)
                    LabelFrame.Text = newText
                end
                
                function Label:SetTextSize(size)
                    LabelFrame.TextSize = size
                    LabelFrame.Size = UDim2.new(1, 0, 0, size + 6)
                end
                
                function Label:SetColor(newColor)
                    LabelFrame.TextColor3 = newColor
                end
                
                return Label
            end
            
            function Column:CreateColorPicker(config)
                config = config or {}
                local text = config.Text or "Color"
                local default = config.Default or Color3.fromRGB(255, 255, 255)
                local textSize = config.TextSize or Theme.TextSize
                local callback = config.Callback or function() end
                
                local ColorPicker = {}
                local currentColor = default
                local colorIndex = 1
                
                local colors = {
                    Color3.fromRGB(255, 0, 0),
                    Color3.fromRGB(255, 128, 0),
                    Color3.fromRGB(255, 255, 0),
                    Color3.fromRGB(0, 255, 0),
                    Color3.fromRGB(0, 255, 255),
                    Color3.fromRGB(0, 128, 255),
                    Color3.fromRGB(0, 0, 255),
                    Color3.fromRGB(128, 0, 255),
                    Color3.fromRGB(255, 0, 255),
                    Color3.fromRGB(255, 255, 255),
                    Color3.fromRGB(128, 128, 128),
                    Theme.Accent,
                }
                
                local ColorPickerFrame = Create("Frame", {
                    Name = "ColorPicker_" .. text,
                    Parent = ColumnContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, textSize + 10),
                })
                
                local ColorLabel = Create("TextLabel", {
                    Parent = ColorPickerFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -40, 1, 0),
                    Font = Enum.Font.SourceSans,
                    Text = text,
                    TextColor3 = Theme.Text,
                    TextSize = textSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                })
                
                local ColorDisplay = Create("TextButton", {
                    Parent = ColorPickerFrame,
                    BackgroundColor3 = currentColor,
                    Position = UDim2.new(1, -35, 0.5, -10),
                    Size = UDim2.new(0, 30, 0, 20),
                    Text = "",
                    AutoButtonColor = false,
                })
                AddCorner(ColorDisplay, 4)
                AddStroke(ColorDisplay, Theme.ElementBorder, 1)
                
                ColorDisplay.MouseButton1Click:Connect(function()
                    colorIndex = (colorIndex % #colors) + 1
                    currentColor = colors[colorIndex]
                    TweenService:Create(ColorDisplay, TweenInfo.new(0.15), {BackgroundColor3 = currentColor}):Play()
                    callback(currentColor)
                end)
                
                function ColorPicker:Set(color)
                    currentColor = color
                    ColorDisplay.BackgroundColor3 = color
                    callback(color)
                end
                
                function ColorPicker:Get()
                    return currentColor
                end
                
                function ColorPicker:SetTextSize(size)
                    ColorLabel.TextSize = size
                end
                
                table.insert(Column.Elements, ColorPicker)
                return ColorPicker
            end
            
            table.insert(Tab.Columns, Column)
            return Column
        end

        function Tab:CreateSection(config)
            if type(config) == "string" then
                config = {Text = config}
            end
            config = config or {}
            local text = config.Text or "Section"
            local textSize = config.TextSize or Theme.SectionTextSize
            
            local Section = {}
            
            local SectionFrame = Create("Frame", {
                Name = "Section_" .. text,
                Parent = TabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, textSize + 10),
            })
            
            local SectionLabel = Create("TextLabel", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = "— " .. text .. " —",
                TextColor3 = Theme.Accent,
                TextSize = textSize,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            function Section:SetText(newText)
                SectionLabel.Text = "— " .. newText .. " —"
            end
            
            return Section
        end
        
        table.insert(Window.Tabs, Tab)
        return Tab
    end

    function Window:CreateWatermark(config)
        config = config or {}
        local text = config.Text or "v1.0.0"
        local showFPS = config.ShowFPS ~= false
        local showPing = config.ShowPing ~= false
        local showTime = config.ShowTime ~= false
        local textSize = config.TextSize or Theme.WatermarkTextSize
        
        local WatermarkData = {}
        WatermarkData.ShowFPS = showFPS
        WatermarkData.ShowPing = showPing
        WatermarkData.ShowTime = showTime
        WatermarkData.CustomText = text
        
        local WatermarkFrame = Create("Frame", {
            Name = "Watermark",
            Parent = ScreenGui,
            BackgroundColor3 = Theme.Background,
            Position = UDim2.new(1, -250, 0, 15),
            Size = UDim2.new(0, 230, 0, 32),
        })
        AddCorner(WatermarkFrame, 4)
        
        local WMOuterBorder = Create("Frame", {
            Parent = WatermarkFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 4, 1, 4),
            Position = UDim2.new(0, -2, 0, -2),
        })
        AddStroke(WMOuterBorder, Theme.Border, 2)
        
        local WMGradient = Create("Frame", {
            Parent = WatermarkFrame,
            BackgroundColor3 = Color3.new(1, 1, 1),
            Size = UDim2.new(1, 0, 0, 2),
            BorderSizePixel = 0,
        })
        AddCorner(WMGradient, 4)
        
        Create("UIGradient", {
            Parent = WMGradient,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Theme.GradientBlue),
                ColorSequenceKeypoint.new(0.5, Theme.GradientRed),
                ColorSequenceKeypoint.new(1, Theme.GradientYellow)
            }),
        })
        
        local WatermarkLabel = Create("TextLabel", {
            Name = "WatermarkLabel",
            Parent = WatermarkFrame,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -20, 1, 0),
            Font = Enum.Font.SourceSansSemibold,
            RichText = true,
            Text = "",
            TextColor3 = Theme.Text,
            TextSize = textSize,
        })
        
        local function updateWatermark()
            local parts = {'game<font color="#90bb20">sense</font>'}
            
            if WatermarkData.CustomText and WatermarkData.CustomText ~= "" then
                table.insert(parts, WatermarkData.CustomText)
            end
            
            if WatermarkData.ShowFPS then
                local fps = math.floor(1 / RunService.RenderStepped:Wait())
                table.insert(parts, fps .. " fps")
            end
            
            if WatermarkData.ShowPing then
                local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                table.insert(parts, ping .. " ms")
            end
            
            if WatermarkData.ShowTime then
                table.insert(parts, os.date("%H:%M:%S"))
            end
            
            WatermarkLabel.Text = table.concat(parts, " | ")
        end
        
        task.spawn(function()
            while WatermarkFrame and WatermarkFrame.Parent do
                updateWatermark()
                task.wait(0.5)
            end
        end)
        
        WatermarkData.Frame = WatermarkFrame
        WatermarkData.Label = WatermarkLabel
        
        function WatermarkData:SetText(newText)
            WatermarkData.CustomText = newText
        end
        
        function WatermarkData:Toggle(visible)
            WatermarkFrame.Visible = visible
        end
        
        function WatermarkData:SetFPS(show)
            WatermarkData.ShowFPS = show
        end
        
        function WatermarkData:SetPing(show)
            WatermarkData.ShowPing = show
        end
        
        function WatermarkData:SetTime(show)
            WatermarkData.ShowTime = show
        end
        
        function WatermarkData:SetPosition(x, y)
            WatermarkFrame.Position = UDim2.new(0, x, 0, y)
        end
        
        function WatermarkData:Destroy()
            WatermarkFrame:Destroy()
        end
        
        return WatermarkData
    end

    function Window:Notify(config)
        config = config or {}
        local title = config.Title or "Notification"
        local message = config.Message or ""
        local duration = config.Duration or 3
        local titleSize = config.TitleSize or Theme.NotificationTitleSize
        local messageSize = config.MessageSize or Theme.NotificationMessageSize
        
        local NotificationHolder = ScreenGui:FindFirstChild("NotificationHolder")
        if not NotificationHolder then
            NotificationHolder = Create("Frame", {
                Name = "NotificationHolder",
                Parent = ScreenGui,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -320, 1, -20),
                Size = UDim2.new(0, 300, 0, 0),
                AnchorPoint = Vector2.new(0, 1),
            })
            
            Create("UIListLayout", {
                Parent = NotificationHolder,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
            })
        end
        
        local notifHeight = titleSize + messageSize + 30
        
        local Notification = Create("Frame", {
            Parent = NotificationHolder,
            BackgroundColor3 = Theme.Background,
            Size = UDim2.new(1, 0, 0, notifHeight),
            ClipsDescendants = true,
        })
        AddCorner(Notification, 4)
        AddStroke(Notification, Theme.Border, 1)
        
        local NotifLine = Create("Frame", {
            Parent = Notification,
            BackgroundColor3 = Color3.new(1, 1, 1),
            Size = UDim2.new(1, 0, 0, 2),
            BorderSizePixel = 0,
        })
        Create("UIGradient", {
            Parent = NotifLine,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Theme.GradientBlue),
                ColorSequenceKeypoint.new(0.5, Theme.GradientRed),
                ColorSequenceKeypoint.new(1, Theme.GradientYellow)
            }),
        })
        
        Create("TextLabel", {
            Parent = Notification,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, 8),
            Size = UDim2.new(1, -24, 0, titleSize + 4),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = Theme.Accent,
            TextSize = titleSize,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        Create("TextLabel", {
            Parent = Notification,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0, titleSize + 14),
            Size = UDim2.new(1, -24, 0, messageSize + 10),
            Font = Enum.Font.SourceSans,
            Text = message,
            TextColor3 = Theme.Text,
            TextSize = messageSize,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
        })
        
        Notification.Position = UDim2.new(1, 0, 0, 0)
        TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        task.delay(duration, function()
            TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                Position = UDim2.new(1, 0, 0, 0)
            }):Play()
            task.wait(0.35)
            if Notification and Notification.Parent then
                Notification:Destroy()
            end
        end)
    end

    function Window:Destroy()
        ScreenGui:Destroy()
    end

    function Window:Toggle(visible)
        MainFrame.Visible = visible
    end

    return Window
end

return GameSenseUI
