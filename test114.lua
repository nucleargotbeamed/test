local GameSenseLib = {}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer

local Colors = {
    Background = Color3.fromRGB(17, 17, 17),
    Border = Color3.fromRGB(61, 65, 76),
    TabBackground = Color3.fromRGB(12, 12, 12),
    TabBorder = Color3.fromRGB(50, 48, 52),
    TextActive = Color3.fromRGB(255, 255, 255),
    TextInactive = Color3.fromRGB(90, 90, 90),
    TextHover = Color3.fromRGB(200, 200, 200),
    CheckboxBg = Color3.fromRGB(71, 71, 71),
    CheckboxActive = Color3.fromRGB(149, 192, 33),
    Accent = Color3.fromRGB(144, 187, 32),
    GradientColors = {
        Color3.fromRGB(69, 170, 242),
        Color3.fromRGB(252, 92, 101),
        Color3.fromRGB(254, 211, 48)
    }
}

local function Create(className, properties)
    local instance = Instance.new(className)
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

local function Tween(instance, properties, duration)
    local tweenInfo = TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end

function GameSenseLib:CreateWindow(options)
    options = options or {}
    
    local Window = {
        Tabs = {},
        TabButtons = {},
        CurrentTab = nil,
        Visible = true
    }
    
    local title = options.Title or "game"
    local subtitle = options.Subtitle or "sense"
    local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift
    
    local ScreenGui = Create("ScreenGui", {
        Name = "GameSenseUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local success, result = pcall(function()
        ScreenGui.Parent = game:GetService("CoreGui")
    end)
    if not success then
        ScreenGui.Parent = Player:WaitForChild("PlayerGui")
    end
    
    local MainFrame = Create("Frame", {
        Name = "Main",
        Parent = ScreenGui,
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -330, 0.5, -272),
        Size = UDim2.new(0, 660, 0, 545)
    })
    
    Create("UIStroke", {
        Parent = MainFrame,
        Color = Colors.Border,
        Thickness = 2
    })
    
    local InnerBorder = Create("Frame", {
        Name = "InnerBorder",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 4, 0, 4),
        Size = UDim2.new(1, -8, 1, -8)
    })
    
    Create("UIStroke", {
        Parent = InnerBorder,
        Color = Colors.Border,
        Thickness = 1
    })
    
    local GradientLine = Create("Frame", {
        Name = "GradientLine",
        Parent = MainFrame,
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 3)
    })
    
    Create("UIGradient", {
        Parent = GradientLine,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Colors.GradientColors[1]),
            ColorSequenceKeypoint.new(0.5, Colors.GradientColors[2]),
            ColorSequenceKeypoint.new(1, Colors.GradientColors[3])
        })
    })
    
    local TabHolder = Create("Frame", {
        Name = "TabHolder",
        Parent = MainFrame,
        BackgroundColor3 = Colors.TabBackground,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 3),
        Size = UDim2.new(0, 100, 1, -3)
    })
    
    local TabList = Create("Frame", {
        Name = "TabList",
        Parent = TabHolder,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0)
    })
    
    Create("UIListLayout", {
        Parent = TabList,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0)
    })
    
    Create("Frame", {
        Name = "Border",
        Parent = TabHolder,
        BackgroundColor3 = Colors.TabBorder,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0)
    })
    
    local ContentHolder = Create("Frame", {
        Name = "ContentHolder",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 100, 0, 3),
        Size = UDim2.new(1, -100, 1, -3),
        ClipsDescendants = true
    })
    
    local Watermark = Create("Frame", {
        Name = "Watermark",
        Parent = ScreenGui,
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -250, 0, 15),
        Size = UDim2.new(0, 0, 0, 30),
        AutomaticSize = Enum.AutomaticSize.X,
        Visible = false
    })
    
    Create("UIStroke", {
        Parent = Watermark,
        Color = Colors.Border,
        Thickness = 2
    })
    
    Create("UIPadding", {
        Parent = Watermark,
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12)
    })
    
    local WatermarkText = Create("TextLabel", {
        Parent = Watermark,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Font = Enum.Font.Gotham,
        RichText = true,
        Text = title .. "<font color='rgb(144,187,32)'>sense</font> | " .. subtitle,
        TextColor3 = Colors.TextActive,
        TextSize = 14
    })
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local absPos = MainFrame.AbsolutePosition
            local mousePos = Vector2.new(input.Position.X, input.Position.Y)
            local relPos = mousePos - absPos
            
            if relPos.Y < 60 then
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
            end
        end
    end)
    
    MainFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == toggleKey then
            Window.Visible = not Window.Visible
            MainFrame.Visible = Window.Visible
        end
    end)
    
    function Window:CreateTab(name)
        local Tab = {
            Name = name,
            Elements = {}
        }
        
        local TabButton = Create("TextButton", {
            Name = name,
            Parent = TabList,
            BackgroundColor3 = Colors.TabBackground,
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 65),
            Font = Enum.Font.GothamBold,
            Text = name,
            TextColor3 = Colors.TextInactive,
            TextSize = 22,
            AutoButtonColor = false
        })
        
        local TabBorderTop = Create("Frame", {
            Name = "TopBorder",
            Parent = TabButton,
            BackgroundColor3 = Colors.TabBorder,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 0, 1),
            Visible = false
        })
        
        local TabBorderBottom = Create("Frame", {
            Name = "BottomBorder",
            Parent = TabButton,
            BackgroundColor3 = Colors.TabBorder,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -1),
            Size = UDim2.new(1, 0, 0, 1),
            Visible = false
        })
        
        local TabContent = Create("ScrollingFrame", {
            Name = name .. "Content",
            Parent = ContentHolder,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0, 15),
            Size = UDim2.new(1, -30, 1, -30),
            ScrollBarThickness = 5,
            ScrollBarImageColor3 = Colors.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false
        })
        
        local ContentLayout = Create("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 12),
            FillDirection = Enum.FillDirection.Horizontal,
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Wraps = true
        })
        
        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {TextColor3 = Colors.TextHover})
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                Tween(TabButton, {TextColor3 = Colors.TextInactive})
            end
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            Window:SelectTab(Tab)
        end)
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        Tab.TopBorder = TabBorderTop
        Tab.BottomBorder = TabBorderBottom
        
        function Tab:CreateSection(sectionName)
            local Section = {Elements = {}}
            
            local SectionFrame = Create("Frame", {
                Name = sectionName,
                Parent = TabContent,
                BackgroundColor3 = Colors.TabBackground,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 260, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            Create("UIStroke", {
                Parent = SectionFrame,
                Color = Colors.TabBorder,
                Thickness = 1
            })
            
            Create("UIPadding", {
                Parent = SectionFrame,
                PaddingBottom = UDim.new(0, 15),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                PaddingTop = UDim.new(0, 8)
            })
            
            local SectionTitle = Create("TextLabel", {
                Name = "Title",
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 24),
                Font = Enum.Font.GothamBold,
                Text = sectionName,
                TextColor3 = Colors.TextActive,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left
            })
            
            local SectionContent = Create("Frame", {
                Name = "Content",
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 28),
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y
            })
            
            Create("UIListLayout", {
                Parent = SectionContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 10)
            })
            
            function Section:CreateCheckbox(options)
                options = options or {}
                local text = options.Text or "Checkbox"
                local default = options.Default or false
                local callback = options.Callback or function() end
                
                local Checkbox = {Value = default}
                
                local CheckboxFrame = Create("Frame", {
                    Name = text,
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 22)
                })
                
                local CheckboxIndicator = Create("Frame", {
                    Name = "Indicator",
                    Parent = CheckboxFrame,
                    BackgroundColor3 = default and Colors.CheckboxActive or Colors.CheckboxBg,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0.5, -7),
                    Size = UDim2.new(0, 14, 0, 14)
                })
                
                Create("UIStroke", {
                    Parent = CheckboxIndicator,
                    Color = Color3.fromRGB(0, 0, 0),
                    Thickness = 1
                })
                
                local CheckboxLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = CheckboxFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 22, 0, 0),
                    Size = UDim2.new(1, -22, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Colors.TextActive,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local CheckboxButton = Create("TextButton", {
                    Name = "Button",
                    Parent = CheckboxFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })
                
                CheckboxButton.MouseButton1Click:Connect(function()
                    Checkbox.Value = not Checkbox.Value
                    Tween(CheckboxIndicator, {
                        BackgroundColor3 = Checkbox.Value and Colors.CheckboxActive or Colors.CheckboxBg
                    })
                    callback(Checkbox.Value)
                end)
                
                function Checkbox:Set(value)
                    Checkbox.Value = value
                    CheckboxIndicator.BackgroundColor3 = value and Colors.CheckboxActive or Colors.CheckboxBg
                    callback(value)
                end
                
                if default then callback(default) end
                
                table.insert(Section.Elements, Checkbox)
                return Checkbox
            end
            
            function Section:CreateSlider(options)
                options = options or {}
                local text = options.Text or "Slider"
                local min = options.Min or 0
                local max = options.Max or 100
                local default = options.Default or min
                local suffix = options.Suffix or ""
                local callback = options.Callback or function() end
                
                local Slider = {Value = default}
                
                local SliderFrame = Create("Frame", {
                    Name = text,
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 40)
                })
                
                local SliderLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.7, 0, 0, 18),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Colors.TextActive,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local SliderValueLabel = Create("TextLabel", {
                    Name = "Value",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.7, 0, 0, 0),
                    Size = UDim2.new(0.3, 0, 0, 18),
                    Font = Enum.Font.Code,
                    Text = tostring(default) .. suffix,
                    TextColor3 = Colors.TextInactive,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right
                })
                
                local SliderBg = Create("Frame", {
                    Name = "Background",
                    Parent = SliderFrame,
                    BackgroundColor3 = Colors.CheckboxBg,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 22),
                    Size = UDim2.new(1, 0, 0, 14)
                })
                
                Create("UIStroke", {
                    Parent = SliderBg,
                    Color = Color3.fromRGB(0, 0, 0),
                    Thickness = 1
                })
                
                local SliderFill = Create("Frame", {
                    Name = "Fill",
                    Parent = SliderBg,
                    BackgroundColor3 = Colors.CheckboxActive,
                    BorderSizePixel = 0,
                    Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                })
                
                local sliderDragging = false
                
                local function UpdateSlider(input)
                    local pos = math.clamp(
                        (input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X,
                        0, 1
                    )
                    local value = math.floor(min + (max - min) * pos + 0.5)
                    Slider.Value = value
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderValueLabel.Text = tostring(value) .. suffix
                    callback(value)
                end
                
                SliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliderDragging = true
                        UpdateSlider(input)
                    end
                end)
                
                SliderBg.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliderDragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                
                function Slider:Set(value)
                    Slider.Value = value
                    local pos = (value - min) / (max - min)
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    SliderValueLabel.Text = tostring(value) .. suffix
                    callback(value)
                end
                
                table.insert(Section.Elements, Slider)
                return Slider
            end
            
            function Section:CreateDropdown(options)
                options = options or {}
                local text = options.Text or "Dropdown"
                local list = options.Options or {}
                local default = options.Default or list[1]
                local callback = options.Callback or function() end
                
                local Dropdown = {Value = default, Open = false}
                
                local DropdownFrame = Create("Frame", {
                    Name = text,
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 50),
                    ClipsDescendants = false,
                    ZIndex = 5
                })
                
                local DropdownLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Colors.TextActive,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5
                })
                
                local DropdownButton = Create("TextButton", {
                    Name = "Button",
                    Parent = DropdownFrame,
                    BackgroundColor3 = Colors.CheckboxBg,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 20),
                    Size = UDim2.new(1, 0, 0, 28),
                    Font = Enum.Font.Code,
                    Text = "  " .. (default or "Select..."),
                    TextColor3 = Colors.TextActive,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    ZIndex = 5
                })
                
                Create("UIStroke", {
                    Parent = DropdownButton,
                    Color = Color3.fromRGB(0, 0, 0),
                    Thickness = 1
                })
                
                local DropdownArrow = Create("TextLabel", {
                    Name = "Arrow",
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -25, 0, 0),
                    Size = UDim2.new(0, 20, 1, 0),
                    Font = Enum.Font.GothamBold,
                    Text = "v",
                    TextColor3 = Colors.TextInactive,
                    TextSize = 12,
                    ZIndex = 5
                })
                
                local DropdownList = Create("Frame", {
                    Name = "List",
                    Parent = DropdownButton,
                    BackgroundColor3 = Colors.CheckboxBg,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, 2),
                    Size = UDim2.new(1, 0, 0, #list * 26),
                    Visible = false,
                    ZIndex = 10,
                    ClipsDescendants = true
                })
                
                Create("UIStroke", {
                    Parent = DropdownList,
                    Color = Color3.fromRGB(0, 0, 0),
                    Thickness = 1
                })
                
                Create("UIListLayout", {
                    Parent = DropdownList,
                    SortOrder = Enum.SortOrder.LayoutOrder
                })
                
                local function CreateOption(option)
                    local OptionButton = Create("TextButton", {
                        Name = option,
                        Parent = DropdownList,
                        BackgroundColor3 = Colors.CheckboxBg,
                        BackgroundTransparency = 0.3,
                        BorderSizePixel = 0,
                        Size = UDim2.new(1, 0, 0, 26),
                        Font = Enum.Font.Code,
                        Text = "  " .. option,
                        TextColor3 = Colors.TextActive,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        ZIndex = 11
                    })
                    
                    OptionButton.MouseEnter:Connect(function()
                        OptionButton.BackgroundTransparency = 0
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        OptionButton.BackgroundTransparency = 0.3
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        Dropdown.Value = option
                        DropdownButton.Text = "  " .. option
                        Dropdown.Open = false
                        DropdownList.Visible = false
                        DropdownArrow.Text = "v"
                        callback(option)
                    end)
                end
                
                for i, option in ipairs(list) do
                    CreateOption(option)
                end
                
                DropdownButton.MouseButton1Click:Connect(function()
                    Dropdown.Open = not Dropdown.Open
                    DropdownList.Visible = Dropdown.Open
                    DropdownArrow.Text = Dropdown.Open and "^" or "v"
                end)
                
                function Dropdown:Set(value)
                    Dropdown.Value = value
                    DropdownButton.Text = "  " .. value
                    callback(value)
                end
                
                function Dropdown:Refresh(newOptions, newDefault)
                    for _, child in ipairs(DropdownList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    list = newOptions
                    DropdownList.Size = UDim2.new(1, 0, 0, #list * 26)
                    
                    for _, option in ipairs(list) do
                        CreateOption(option)
                    end
                    
                    if newDefault then
                        Dropdown:Set(newDefault)
                    end
                end
                
                if default then callback(default) end
                
                table.insert(Section.Elements, Dropdown)
                return Dropdown
            end
            
            function Section:CreateButton(options)
                options = options or {}
                local text = options.Text or "Button"
                local callback = options.Callback or function() end
                
                local Button = {}
                
                local ButtonFrame = Create("TextButton", {
                    Name = text,
                    Parent = SectionContent,
                    BackgroundColor3 = Colors.CheckboxBg,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 30),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Colors.TextActive,
                    TextSize = 13,
                    AutoButtonColor = false
                })
                
                Create("UIStroke", {
                    Parent = ButtonFrame,
                    Color = Color3.fromRGB(0, 0, 0),
                    Thickness = 1
                })
                
                ButtonFrame.MouseEnter:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Colors.TextInactive})
                end)
                
                ButtonFrame.MouseLeave:Connect(function()
                    Tween(ButtonFrame, {BackgroundColor3 = Colors.CheckboxBg})
                end)
                
                ButtonFrame.MouseButton1Click:Connect(callback)
                
                table.insert(Section.Elements, Button)
                return Button
            end
            
            function Section:CreateLabel(text)
                local Label = {}
                
                local LabelText = Create("TextLabel", {
                    Name = "Label",
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = text or "Label",
                    TextColor3 = Colors.TextActive,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                function Label:Set(newText)
                    LabelText.Text = newText
                end
                
                table.insert(Section.Elements, Label)
                return Label
            end
            
            function Section:CreateTextbox(options)
                options = options or {}
                local text = options.Text or "Textbox"
                local placeholder = options.Placeholder or "Enter text..."
                local callback = options.Callback or function() end
                
                local Textbox = {Value = ""}
                
                local TextboxFrame = Create("Frame", {
                    Name = text,
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 48)
                })
                
                local TextboxLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = TextboxFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Colors.TextActive,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local TextboxInput = Create("TextBox", {
                    Name = "Input",
                    Parent = TextboxFrame,
                    BackgroundColor3 = Colors.CheckboxBg,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 0, 20),
                    Size = UDim2.new(1, 0, 0, 26),
                    Font = Enum.Font.Code,
                    PlaceholderText = placeholder,
                    PlaceholderColor3 = Colors.TextInactive,
                    Text = "",
                    TextColor3 = Colors.TextActive,
                    TextSize = 12,
                    ClearTextOnFocus = false
                })
                
                Create("UIStroke", {
                    Parent = TextboxInput,
                    Color = Color3.fromRGB(0, 0, 0),
                    Thickness = 1
                })
                
                Create("UIPadding", {
                    Parent = TextboxInput,
                    PaddingLeft = UDim.new(0, 8)
                })
                
                TextboxInput.FocusLost:Connect(function(enterPressed)
                    Textbox.Value = TextboxInput.Text
                    callback(TextboxInput.Text, enterPressed)
                end)
                
                function Textbox:Set(value)
                    Textbox.Value = value
                    TextboxInput.Text = value
                end
                
                table.insert(Section.Elements, Textbox)
                return Textbox
            end
            
            function Section:CreateKeybind(options)
                options = options or {}
                local text = options.Text or "Keybind"
                local default = options.Default or Enum.KeyCode.Unknown
                local callback = options.Callback or function() end
                
                local Keybind = {Value = default, Listening = false}
                
                local KeybindFrame = Create("Frame", {
                    Name = text,
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 26)
                })
                
                local KeybindLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = KeybindFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.55, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Colors.TextActive,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local KeybindButton = Create("TextButton", {
                    Name = "Button",
                    Parent = KeybindFrame,
                    BackgroundColor3 = Colors.CheckboxBg,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0.55, 5, 0, 0),
                    Size = UDim2.new(0.45, -5, 1, 0),
                    Font = Enum.Font.Code,
                    Text = default.Name ~= "Unknown" and default.Name or "None",
                    TextColor3 = Colors.TextActive,
                    TextSize = 12,
                    AutoButtonColor = false
                })
                
                Create("UIStroke", {
                    Parent = KeybindButton,
                    Color = Color3.fromRGB(0, 0, 0),
                    Thickness = 1
                })
                
                KeybindButton.MouseButton1Click:Connect(function()
                    Keybind.Listening = true
                    KeybindButton.Text = "..."
                end)
                
                UserInputService.InputBegan:Connect(function(input, processed)
                    if Keybind.Listening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            Keybind.Value = input.KeyCode
                            KeybindButton.Text = input.KeyCode.Name
                            Keybind.Listening = false
                        end
                    elseif input.KeyCode == Keybind.Value and not processed then
                        callback(Keybind.Value)
                    end
                end)
                
                function Keybind:Set(keycode)
                    Keybind.Value = keycode
                    KeybindButton.Text = keycode.Name ~= "Unknown" and keycode.Name or "None"
                end
                
                table.insert(Section.Elements, Keybind)
                return Keybind
            end
            
            function Section:CreateToggle(options)
                options = options or {}
                local text = options.Text or "Toggle"
                local default = options.Default or false
                local callback = options.Callback or function() end
                
                local Toggle = {Value = default}
                
                local ToggleFrame = Create("Frame", {
                    Name = text,
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 26)
                })
                
                local ToggleLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.7, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Colors.TextActive,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ToggleBg = Create("Frame", {
                    Name = "Background",
                    Parent = ToggleFrame,
                    BackgroundColor3 = default and Colors.CheckboxActive or Colors.CheckboxBg,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -45, 0.5, -9),
                    Size = UDim2.new(0, 45, 0, 18)
                })
                
                Create("UIStroke", {
                    Parent = ToggleBg,
                    Color = Color3.fromRGB(0, 0, 0),
                    Thickness = 1
                })
                
                Create("UICorner", {
                    Parent = ToggleBg,
                    CornerRadius = UDim.new(0, 9)
                })
                
                local ToggleCircle = Create("Frame", {
                    Name = "Circle",
                    Parent = ToggleBg,
                    BackgroundColor3 = Colors.TextActive,
                    BorderSizePixel = 0,
                    Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                    Size = UDim2.new(0, 14, 0, 14)
                })
                
                Create("UICorner", {
                    Parent = ToggleCircle,
                    CornerRadius = UDim.new(1, 0)
                })
                
                local ToggleButton = Create("TextButton", {
                    Name = "Button",
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })
                
                ToggleButton.MouseButton1Click:Connect(function()
                    Toggle.Value = not Toggle.Value
                    Tween(ToggleBg, {
                        BackgroundColor3 = Toggle.Value and Colors.CheckboxActive or Colors.CheckboxBg
                    })
                    Tween(ToggleCircle, {
                        Position = Toggle.Value and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                    })
                    callback(Toggle.Value)
                end)
                
                function Toggle:Set(value)
                    Toggle.Value = value
                    ToggleBg.BackgroundColor3 = value and Colors.CheckboxActive or Colors.CheckboxBg
                    ToggleCircle.Position = value and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                    callback(value)
                end
                
                if default then callback(default) end
                
                table.insert(Section.Elements, Toggle)
                return Toggle
            end
            
            function Section:CreateColorPicker(options)
                options = options or {}
                local text = options.Text or "Color"
                local default = options.Default or Color3.fromRGB(255, 255, 255)
                local callback = options.Callback or function() end
                
                local ColorPicker = {Value = default, Open = false}
                
                local ColorFrame = Create("Frame", {
                    Name = text,
                    Parent = SectionContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 26),
                    ZIndex = 5
                })
                
                local ColorLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = ColorFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.7, 0, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = text,
                    TextColor3 = Colors.TextActive,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5
                })
                
                local ColorDisplay = Create("TextButton", {
                    Name = "Display",
                    Parent = ColorFrame,
                    BackgroundColor3 = default,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, -50, 0.5, -10),
                    Size = UDim2.new(0, 50, 0, 20),
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 5
                })
                
                Create("UIStroke", {
                    Parent = ColorDisplay,
                    Color = Color3.fromRGB(0, 0, 0),
                    Thickness = 1
                })
                
                local ColorPanel = Create("Frame", {
                    Name = "Panel",
                    Parent = ColorDisplay,
                    BackgroundColor3 = Colors.TabBackground,
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 0, 1, 5),
                    Size = UDim2.new(0, 150, 0, 120),
                    Visible = false,
                    ZIndex = 20
                })
                
                Create("UIStroke", {
                    Parent = ColorPanel,
                    Color = Color3.fromRGB(0, 0, 0),
                    Thickness = 1
                })
                
                local hue, sat, val = default:ToHSV()
                
                local HueSlider = Create("Frame", {
                    Name = "Hue",
                    Parent = ColorPanel,
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 10),
                    Size = UDim2.new(1, -20, 0, 15),
                    ZIndex = 21
                })
                
                Create("UIGradient", {
                    Parent = HueSlider,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
                        ColorSequenceKeypoint.new(0.167, Color3.fromHSV(0.167, 1, 1)),
                        ColorSequenceKeypoint.new(0.333, Color3.fromHSV(0.333, 1, 1)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromHSV(0.5, 1, 1)),
                        ColorSequenceKeypoint.new(0.667, Color3.fromHSV(0.667, 1, 1)),
                        ColorSequenceKeypoint.new(0.833, Color3.fromHSV(0.833, 1, 1)),
                        ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1))
                    })
                })
                
                local SatValBox = Create("Frame", {
                    Name = "SatVal",
                    Parent = ColorPanel,
                    BackgroundColor3 = Color3.fromHSV(hue, 1, 1),
                    BorderSizePixel = 0,
                    Position = UDim2.new(0, 10, 0, 35),
                    Size = UDim2.new(1, -20, 0, 75),
                    ZIndex = 21
                })
                
                Create("UIGradient", {
                    Parent = SatValBox,
                    Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1)),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 0),
                        NumberSequenceKeypoint.new(1, 1)
                    })
                })
                
                local SatValOverlay = Create("Frame", {
                    Name = "Overlay",
                    Parent = SatValBox,
                    BackgroundColor3 = Color3.new(0, 0, 0),
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 1, 0),
                    ZIndex = 22
                })
                
                Create("UIGradient", {
                    Parent = SatValOverlay,
                    Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, 1),
                        NumberSequenceKeypoint.new(1, 0)
                    }),
                    Rotation = 90
                })
                
                ColorDisplay.MouseButton1Click:Connect(function()
                    ColorPicker.Open = not ColorPicker.Open
                    ColorPanel.Visible = ColorPicker.Open
                end)
                
                local function UpdateColor()
                    local color = Color3.fromHSV(hue, sat, val)
                    ColorPicker.Value = color
                    ColorDisplay.BackgroundColor3 = color
                    SatValBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    callback(color)
                end
                
                local hueDragging = false
                local svDragging = false
                
                HueSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDragging = true
                        hue = math.clamp((input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                        UpdateColor()
                    end
                end)
                
                HueSlider.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        hueDragging = false
                    end
                end)
                
                SatValBox.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDragging = true
                        sat = math.clamp((input.Position.X - SatValBox.AbsolutePosition.X) / SatValBox.AbsoluteSize.X, 0, 1)
                        val = 1 - math.clamp((input.Position.Y - SatValBox.AbsolutePosition.Y) / SatValBox.AbsoluteSize.Y, 0, 1)
                        UpdateColor()
                    end
                end)
                
                SatValBox.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        svDragging = false
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement then
                        if hueDragging then
                            hue = math.clamp((input.Position.X - HueSlider.AbsolutePosition.X) / HueSlider.AbsoluteSize.X, 0, 1)
                            UpdateColor()
                        elseif svDragging then
                            sat = math.clamp((input.Position.X - SatValBox.AbsolutePosition.X) / SatValBox.AbsoluteSize.X, 0, 1)
                            val = 1 - math.clamp((input.Position.Y - SatValBox.AbsolutePosition.Y) / SatValBox.AbsoluteSize.Y, 0, 1)
                            UpdateColor()
                        end
                    end
                end)
                
                function ColorPicker:Set(color)
                    ColorPicker.Value = color
                    hue, sat, val = color:ToHSV()
                    ColorDisplay.BackgroundColor3 = color
                    SatValBox.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
                    callback(color)
                end
                
                callback(default)
                
                table.insert(Section.Elements, ColorPicker)
                return ColorPicker
            end
            
            table.insert(Tab.Elements, Section)
            return Section
        end
        
        table.insert(Window.Tabs, Tab)
        
        if #Window.Tabs == 1 then
            Window:SelectTab(Tab)
        end
        
        return Tab
    end
    
    function Window:SelectTab(tab)
        if Window.CurrentTab then
            Window.CurrentTab.Button.BackgroundColor3 = Colors.TabBackground
            Window.CurrentTab.Button.TextColor3 = Colors.TextInactive
            Window.CurrentTab.TopBorder.Visible = false
            Window.CurrentTab.BottomBorder.Visible = false
            Window.CurrentTab.Content.Visible = false
        end
        
        Window.CurrentTab = tab
        tab.Button.BackgroundColor3 = Colors.Background
        tab.Button.TextColor3 = Colors.TextActive
        tab.TopBorder.Visible = true
        tab.BottomBorder.Visible = true
        tab.Content.Visible = true
    end
    
    function Window:SetWatermark(visible, text)
        Watermark.Visible = visible
        if text then
            WatermarkText.Text = text
        end
    end
    
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    return Window
end

return GameSenseLib
