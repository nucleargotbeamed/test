--[[
    GameSense UI Library for Roblox
    Converted from web gamesense UI
    
    Load via:
    loadstring(game:HttpService():GetAsync("https://raw.githubusercontent.com/YourUsername/YourRepo/main/GameSenseUI.lua"))()
]]

local GameSenseUI = {}
GameSenseUI.__index = GameSenseUI

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Theme Colors (matching gamesense style)
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
}

-- Utility function to create instances
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

-- Utility function to add corner radius
local function AddCorner(parent, radius)
    return Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 0),
        Parent = parent
    })
end

-- Utility function to add stroke
local function AddStroke(parent, color, thickness)
    return Create("UIStroke", {
        Color = color or Theme.Border,
        Thickness = thickness or 1,
        Parent = parent
    })
end

-- Make frame draggable
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

-- Ripple effect for buttons
local function AddRipple(button)
    button.ClipsDescendants = true
    
    button.MouseButton1Click:Connect(function()
        local ripple = Create("Frame", {
            Parent = button,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.8,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0.5, 0, 0.5, 0),
            Size = UDim2.new(0, 0, 0, 0),
        })
        AddCorner(ripple, 100)
        
        local tween = TweenService:Create(ripple, TweenInfo.new(0.5), {
            Size = UDim2.new(2, 0, 2, 0),
            BackgroundTransparency = 1
        })
        tween:Play()
        tween.Completed:Connect(function()
            ripple:Destroy()
        end)
    end)
end

-- Create Window
function GameSenseUI:CreateWindow(config)
    config = config or {}
    local title = config.Title or "game"
    local subtitle = config.Subtitle or "sense"
    local toggleKey = config.ToggleKey or Enum.KeyCode.Insert
    
    local Window = {}
    Window.Tabs = {}
    Window.CurrentTab = nil
    
    -- ScreenGui
    local ScreenGui = Create("ScreenGui", {
        Name = "GameSenseUI",
        Parent = RunService:IsStudio() and Players.LocalPlayer:WaitForChild("PlayerGui") or game:GetService("CoreGui"),
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 999
    })
    
    -- Main Frame
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        Position = UDim2.new(0.5, -330, 0.5, -272),
        Size = UDim2.new(0, 660, 0, 545),
        ClipsDescendants = true,
    })
    
    -- Double border effect
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
    
    -- Gradient Line at top
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
    
    -- Tab Container (left side)
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundColor3 = Theme.TabBackground,
        Position = UDim2.new(0, 0, 0, 2),
        Size = UDim2.new(0, 90, 1, -2),
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
    
    -- Content Container
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 100, 0, 15),
        Size = UDim2.new(1, -115, 1, -30),
    })
    
    -- Make draggable from the gradient line area
    local DragHandle = Create("Frame", {
        Name = "DragHandle",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
    })
    MakeDraggable(MainFrame, DragHandle)
    
    -- Toggle visibility
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == toggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
    
    Window.ScreenGui = ScreenGui
    Window.MainFrame = MainFrame
    Window.TabContainer = TabButtonContainer
    Window.ContentContainer = ContentContainer
    
    -- Create Tab function
    function Window:CreateTab(name)
        local Tab = {}
        Tab.Elements = {}
        local tabIndex = #Window.Tabs + 1
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            Name = "Tab_" .. name,
            Parent = TabButtonContainer,
            BackgroundColor3 = Theme.TabBackground,
            Size = UDim2.new(1, 0, 0, 60),
            BorderSizePixel = 0,
            Font = Enum.Font.GothamBold,
            Text = name,
            TextColor3 = Theme.TextDark,
            TextSize = 28,
            LayoutOrder = tabIndex,
            AutoButtonColor = false,
        })
        
        -- Top/Bottom borders for selected tab
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
        
        -- Tab Content
        local TabContent = Create("ScrollingFrame", {
            Name = "Content_" .. name,
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.Accent,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollingDirection = Enum.ScrollingDirection.Y,
        })
        
        Create("UIListLayout", {
            Parent = TabContent,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 5),
        })
        
        Create("UIPadding", {
            Parent = TabContent,
            PaddingRight = UDim.new(0, 10),
        })
        
        -- Tab click handler
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
        
        -- Set first tab as active
        if tabIndex == 1 then
            TabButton.TextColor3 = Theme.Text
            TabButton.BackgroundColor3 = Theme.Background
            TopBorder.Visible = true
            BottomBorder.Visible = true
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end
        
        -- ============ ELEMENT FUNCTIONS ============
        
        -- Create Section
        function Tab:CreateSection(text)
            local Section = {}
            
            local SectionFrame = Create("Frame", {
                Name = "Section_" .. text,
                Parent = TabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 25),
            })
            
            Create("TextLabel", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = "— " .. text .. " —",
                TextColor3 = Theme.Accent,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            return Section
        end
        
        -- Create Checkbox
        function Tab:CreateCheckbox(config)
            config = config or {}
            local text = config.Text or "Checkbox"
            local default = config.Default or false
            local callback = config.Callback or function() end
            
            local Checkbox = {}
            local toggled = default
            
            local CheckboxFrame = Create("Frame", {
                Name = "Checkbox_" .. text,
                Parent = TabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
            })
            
            local CheckboxIndicator = Create("Frame", {
                Name = "Indicator",
                Parent = CheckboxFrame,
                BackgroundColor3 = toggled and Theme.Accent or Theme.ElementBackground,
                Position = UDim2.new(0, 0, 0.5, -5),
                Size = UDim2.new(0, 9, 0, 9),
            })
            AddStroke(CheckboxIndicator, Theme.ElementBorder, 1)
            
            Create("TextLabel", {
                Parent = CheckboxFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 17, 0, 0),
                Size = UDim2.new(1, -17, 1, 0),
                Font = Enum.Font.SourceSans,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 14,
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
                CheckboxIndicator.BackgroundColor3 = toggled and Theme.Accent or Theme.ElementBackground
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
            
            table.insert(Tab.Elements, Checkbox)
            return Checkbox
        end
        
        -- Create Slider
        function Tab:CreateSlider(config)
            config = config or {}
            local text = config.Text or "Slider"
            local min = config.Min or 0
            local max = config.Max or 100
            local default = config.Default or min
            local increment = config.Increment or 1
            local suffix = config.Suffix or ""
            local callback = config.Callback or function() end
            
            local Slider = {}
            local value = default
            
            local SliderFrame = Create("Frame", {
                Name = "Slider_" .. text,
                Parent = TabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 32),
            })
            
            local SliderLabel = Create("TextLabel", {
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                Font = Enum.Font.SourceSans,
                Text = text .. ": " .. tostring(value) .. suffix,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local SliderBackground = Create("Frame", {
                Parent = SliderFrame,
                BackgroundColor3 = Theme.ElementBackground,
                Position = UDim2.new(0, 0, 0, 18),
                Size = UDim2.new(1, 0, 0, 10),
            })
            AddStroke(SliderBackground, Theme.ElementBorder, 1)
            
            local SliderFill = Create("Frame", {
                Parent = SliderBackground,
                BackgroundColor3 = Theme.Accent,
                Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                BorderSizePixel = 0,
            })
            
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
                
                SliderFill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                SliderLabel.Text = text .. ": " .. tostring(value) .. suffix
                callback(value)
            end
            
            SliderButton.MouseButton1Down:Connect(function()
                dragging = true
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
            
            SliderButton.MouseButton1Down:Connect(function()
                updateSlider(UserInputService:GetMouseLocation())
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
            
            table.insert(Tab.Elements, Slider)
            return Slider
        end
        
        -- Create Button
        function Tab:CreateButton(config)
            config = config or {}
            local text = config.Text or "Button"
            local callback = config.Callback or function() end
            
            local Button = {}
            
            local ButtonFrame = Create("TextButton", {
                Name = "Button_" .. text,
                Parent = TabContent,
                BackgroundColor3 = Theme.ElementBackground,
                Size = UDim2.new(0, 150, 0, 24),
                Font = Enum.Font.SourceSans,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 14,
                AutoButtonColor = false,
            })
            AddStroke(ButtonFrame, Theme.ElementBorder, 1)
            
            ButtonFrame.MouseButton1Click:Connect(callback)
            
            ButtonFrame.MouseEnter:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent}):Play()
            end)
            
            ButtonFrame.MouseLeave:Connect(function()
                TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ElementBackground}):Play()
            end)
            
            table.insert(Tab.Elements, Button)
            return Button
        end
        
        -- Create Dropdown
        function Tab:CreateDropdown(config)
            config = config or {}
            local text = config.Text or "Dropdown"
            local options = config.Options or {}
            local default = config.Default or options[1]
            local callback = config.Callback or function() end
            
            local Dropdown = {}
            local selected = default
            local opened = false
            
            local DropdownFrame = Create("Frame", {
                Name = "Dropdown_" .. text,
                Parent = TabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 42),
                ClipsDescendants = false,
                ZIndex = 5,
            })
            
            Create("TextLabel", {
                Parent = DropdownFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                Font = Enum.Font.SourceSans,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local DropdownButton = Create("TextButton", {
                Parent = DropdownFrame,
                BackgroundColor3 = Theme.ElementBackground,
                Position = UDim2.new(0, 0, 0, 16),
                Size = UDim2.new(1, 0, 0, 22),
                Font = Enum.Font.SourceSans,
                Text = "  " .. tostring(selected or "Select..."),
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                ZIndex = 5,
            })
            AddStroke(DropdownButton, Theme.ElementBorder, 1)
            
            local Arrow = Create("TextLabel", {
                Parent = DropdownButton,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -20, 0, 0),
                Size = UDim2.new(0, 15, 1, 0),
                Font = Enum.Font.GothamBold,
                Text = "v",
                TextColor3 = Theme.Text,
                TextSize = 10,
                ZIndex = 5,
            })
            
            local OptionContainer = Create("Frame", {
                Parent = DropdownButton,
                BackgroundColor3 = Theme.TabBackground,
                Position = UDim2.new(0, 0, 1, 2),
                Size = UDim2.new(1, 0, 0, math.min(#options * 20, 100)),
                Visible = false,
                ClipsDescendants = true,
                ZIndex = 10,
            })
            AddStroke(OptionContainer, Theme.ElementBorder, 1)
            
            local OptionScroll = Create("ScrollingFrame", {
                Parent = OptionContainer,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = Theme.Accent,
                CanvasSize = UDim2.new(0, 0, 0, #options * 20),
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
                        Size = UDim2.new(1, 0, 0, 20),
                        Font = Enum.Font.SourceSans,
                        Text = "  " .. option,
                        TextColor3 = Theme.Text,
                        TextSize = 14,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        LayoutOrder = i,
                        AutoButtonColor = false,
                        ZIndex = 10,
                    })
                    
                    OptionButton.MouseEnter:Connect(function()
                        OptionButton.BackgroundColor3 = Theme.ElementBackground
                    end)
                    
                    OptionButton.MouseLeave:Connect(function()
                        OptionButton.BackgroundColor3 = Theme.TabBackground
                    end)
                    
                    OptionButton.MouseButton1Click:Connect(function()
                        selected = option
                        DropdownButton.Text = "  " .. option
                        OptionContainer.Visible = false
                        opened = false
                        Arrow.Rotation = 0
                        callback(option)
                    end)
                end
            end
            
            refreshOptions()
            
            DropdownButton.MouseButton1Click:Connect(function()
                opened = not opened
                OptionContainer.Visible = opened
                TweenService:Create(Arrow, TweenInfo.new(0.1), {Rotation = opened and 180 or 0}):Play()
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
                OptionContainer.Size = UDim2.new(1, 0, 0, math.min(#options * 20, 100))
                OptionScroll.CanvasSize = UDim2.new(0, 0, 0, #options * 20)
                refreshOptions()
            end
            
            table.insert(Tab.Elements, Dropdown)
            return Dropdown
        end
        
        -- Create Textbox
        function Tab:CreateTextbox(config)
            config = config or {}
            local text = config.Text or "Textbox"
            local placeholder = config.Placeholder or ""
            local callback = config.Callback or function() end
            
            local Textbox = {}
            
            local TextboxFrame = Create("Frame", {
                Name = "Textbox_" .. text,
                Parent = TabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 38),
            })
            
            Create("TextLabel", {
                Parent = TextboxFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                Font = Enum.Font.SourceSans,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local TextboxInput = Create("TextBox", {
                Parent = TextboxFrame,
                BackgroundColor3 = Theme.ElementBackground,
                Position = UDim2.new(0, 0, 0, 16),
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.SourceSans,
                PlaceholderText = placeholder,
                PlaceholderColor3 = Theme.TextDark,
                Text = "",
                TextColor3 = Theme.Text,
                TextSize = 14,
                ClearTextOnFocus = false,
            })
            AddStroke(TextboxInput, Theme.ElementBorder, 1)
            
            TextboxInput.FocusLost:Connect(function(enterPressed)
                callback(TextboxInput.Text, enterPressed)
            end)
            
            function Textbox:Set(value)
                TextboxInput.Text = value
            end
            
            function Textbox:Get()
                return TextboxInput.Text
            end
            
            table.insert(Tab.Elements, Textbox)
            return Textbox
        end
        
        -- Create Keybind
        function Tab:CreateKeybind(config)
            config = config or {}
            local text = config.Text or "Keybind"
            local default = config.Default or Enum.KeyCode.Unknown
            local callback = config.Callback or function() end
            
            local Keybind = {}
            local currentKey = default
            local listening = false
            
            local KeybindFrame = Create("Frame", {
                Name = "Keybind_" .. text,
                Parent = TabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
            })
            
            Create("TextLabel", {
                Parent = KeybindFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.7, 0, 1, 0),
                Font = Enum.Font.SourceSans,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local KeybindButton = Create("TextButton", {
                Parent = KeybindFrame,
                BackgroundColor3 = Theme.ElementBackground,
                Position = UDim2.new(0.7, 5, 0, 0),
                Size = UDim2.new(0.3, -5, 1, 0),
                Font = Enum.Font.SourceSans,
                Text = currentKey.Name,
                TextColor3 = Theme.Text,
                TextSize = 12,
                AutoButtonColor = false,
            })
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
            
            table.insert(Tab.Elements, Keybind)
            return Keybind
        end
        
        -- Create Label
        function Tab:CreateLabel(text)
            local Label = {}
            
            local LabelFrame = Create("TextLabel", {
                Name = "Label",
                Parent = TabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                Font = Enum.Font.SourceSans,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            function Label:Set(newText)
                LabelFrame.Text = newText
            end
            
            return Label
        end
        
        -- Create Color Picker
        function Tab:CreateColorPicker(config)
            config = config or {}
            local text = config.Text or "Color"
            local default = config.Default or Color3.fromRGB(255, 255, 255)
            local callback = config.Callback or function() end
            
            local ColorPicker = {}
            local currentColor = default
            local opened = false
            
            local ColorPickerFrame = Create("Frame", {
                Name = "ColorPicker_" .. text,
                Parent = TabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
            })
            
            Create("TextLabel", {
                Parent = ColorPickerFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.8, 0, 1, 0),
                Font = Enum.Font.SourceSans,
                Text = text,
                TextColor3 = Theme.Text,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
            })
            
            local ColorDisplay = Create("TextButton", {
                Parent = ColorPickerFrame,
                BackgroundColor3 = currentColor,
                Position = UDim2.new(1, -30, 0.5, -8),
                Size = UDim2.new(0, 25, 0, 16),
                Text = "",
                AutoButtonColor = false,
            })
            AddStroke(ColorDisplay, Theme.ElementBorder, 1)
            
            ColorDisplay.MouseButton1Click:Connect(function()
                -- Simple color picker toggle (you can expand this)
                local colors = {
                    Color3.fromRGB(255, 0, 0),
                    Color3.fromRGB(0, 255, 0),
                    Color3.fromRGB(0, 0, 255),
                    Color3.fromRGB(255, 255, 0),
                    Color3.fromRGB(255, 0, 255),
                    Color3.fromRGB(0, 255, 255),
                    Color3.fromRGB(255, 255, 255),
                    Theme.Accent,
                }
                local index = table.find(colors, currentColor) or 0
                currentColor = colors[(index % #colors) + 1]
                ColorDisplay.BackgroundColor3 = currentColor
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
            
            table.insert(Tab.Elements, ColorPicker)
            return ColorPicker
        end
        
        table.insert(Window.Tabs, Tab)
        return Tab
    end
    
    -- Create Watermark
    function Window:CreateWatermark(config)
        config = config or {}
        local text = config.Text or "gamesense"
        
        local Watermark = Create("Frame", {
            Name = "Watermark",
            Parent = ScreenGui,
            BackgroundColor3 = Theme.Background,
            Position = UDim2.new(1, -200, 0, 15),
            Size = UDim2.new(0, 180, 0, 28),
        })
        
        -- Double border
        local WMOuterBorder = Create("Frame", {
            Parent = Watermark,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 4, 1, 4),
            Position = UDim2.new(0, -2, 0, -2),
        })
        AddStroke(WMOuterBorder, Theme.Border, 2)
        
        local WMInnerBorder = Create("Frame", {
            Parent = Watermark,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -4, 1, -4),
            Position = UDim2.new(0, 2, 0, 2),
        })
        AddStroke(WMInnerBorder, Theme.Border, 1)
        
        Create("TextLabel", {
            Parent = Watermark,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.SourceSans,
            RichText = true,
            Text = 'game<font color="#90bb20">sense</font> | ' .. text,
            TextColor3 = Theme.Text,
            TextSize = 14,
        })
        
        function Watermark:SetText(newText)
            Watermark:FindFirstChild("TextLabel").Text = 'game<font color="#90bb20">sense</font> | ' .. newText
        end
        
        function Watermark:Toggle(visible)
            Watermark.Visible = visible
        end
        
        return Watermark
    end
    
    -- Notification System
    function Window:Notify(config)
        config = config or {}
        local title = config.Title or "Notification"
        local message = config.Message or ""
        local duration = config.Duration or 3
        
        local NotificationHolder = ScreenGui:FindFirstChild("NotificationHolder") or Create("Frame", {
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
            Padding = UDim.new(0, 5),
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
        })
        
        local Notification = Create("Frame", {
            Parent = NotificationHolder,
            BackgroundColor3 = Theme.Background,
            Size = UDim2.new(1, 0, 0, 50),
            ClipsDescendants = true,
        })
        AddStroke(Notification, Theme.Border, 1)
        
        -- Top gradient line
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
            Position = UDim2.new(0, 10, 0, 5),
            Size = UDim2.new(1, -20, 0, 18),
            Font = Enum.Font.GothamBold,
            Text = title,
            TextColor3 = Theme.Accent,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
        })
        
        Create("TextLabel", {
            Parent = Notification,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 25),
            Size = UDim2.new(1, -20, 0, 20),
            Font = Enum.Font.SourceSans,
            Text = message,
            TextColor3 = Theme.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
        })
        
        -- Animate in
        Notification.Position = UDim2.new(1, 0, 0, 0)
        TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Position = UDim2.new(0, 0, 0, 0)
        }):Play()
        
        -- Auto remove
        task.delay(duration, function()
            TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                Position = UDim2.new(1, 0, 0, 0)
            }):Play()
            task.wait(0.3)
            Notification:Destroy()
        end)
    end
    
    -- Destroy Window
    function Window:Destroy()
        ScreenGui:Destroy()
    end
    
    -- Toggle Window
    function Window:Toggle(visible)
        MainFrame.Visible = visible
    end
    
    return Window
end

return GameSenseUI
