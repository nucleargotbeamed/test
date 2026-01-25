--[[
    GameSense UI Library for Roblox
    Converted from HTML/CSS design
    
    Usage:
    local Library = loadstring(game:HttpGet("YOUR_RAW_LINK"))()
    local Window = Library:Create("game", "sense")
    local Tab = Window:CreateTab("A")
    Tab:AddCheckbox("Option", false, function(value) print(value) end)
]]

local GameSenseLib = {}
GameSenseLib.__index = GameSenseLib

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Colors (from original CSS)
local Colors = {
    Background = Color3.fromRGB(17, 17, 17),        -- #111111
    Border = Color3.fromRGB(61, 65, 76),            -- #3d414c
    TabBackground = Color3.fromRGB(12, 12, 12),     -- #0c0c0c
    TabBorder = Color3.fromRGB(50, 48, 52),         -- #323034
    TabText = Color3.fromRGB(90, 90, 90),           -- #5a5a5a
    TabTextHover = Color3.fromRGB(200, 200, 200),
    TabTextActive = Color3.fromRGB(255, 255, 255),
    CheckboxOff = Color3.fromRGB(71, 71, 71),       -- #474747
    CheckboxOn = Color3.fromRGB(149, 192, 33),      -- #95C021
    Text = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(144, 187, 32),          -- #90bb20
    GradientBlue = Color3.fromRGB(69, 170, 242),    -- #45aaf2
    GradientRed = Color3.fromRGB(252, 92, 101),     -- #fc5c65
    GradientYellow = Color3.fromRGB(254, 211, 48)   -- #fed330
}

-- Utility Functions
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

local function Tween(object, duration, properties)
    local tween = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quad), properties)
    tween:Play()
    return tween
end

-- Main Library
function GameSenseLib:Create(title, subtitle)
    local Library = {}
    Library.Tabs = {}
    Library.CurrentTab = nil
    Library.ToggleKey = Enum.KeyCode.Insert
    
    -- Screen GUI
    local ScreenGui = Create("ScreenGui", {
        Name = "GameSenseUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = playerGui
    })
    
    -- ═══════════════════════════════════════
    -- WATERMARK
    -- ═══════════════════════════════════════
    local Watermark = Create("Frame", {
        Name = "Watermark",
        Size = UDim2.new(0, 160, 0, 28),
        Position = UDim2.new(1, -175, 0, 15),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Visible = false,
        Parent = ScreenGui
    })
    
    Create("UIStroke", {
        Color = Colors.Border,
        Thickness = 3,
        Parent = Watermark
    })
    
    Create("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = Watermark
    })
    
    local WatermarkText = Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Code,
        TextSize = 11,
        TextColor3 = Colors.Text,
        RichText = true,
        Text = string.format('%s<font color="rgb(144,187,32)">%s</font> | norate', title or "game", subtitle or "sense"),
        Parent = Watermark
    })
    
    Library.Watermark = Watermark
    
    -- ═══════════════════════════════════════
    -- MAIN FRAME
    -- ═══════════════════════════════════════
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 660, 0, 545),
        Position = UDim2.new(0.5, -330, 0.5, -272),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Parent = ScreenGui
    })
    
    Create("UIStroke", {
        Color = Colors.Border,
        Thickness = 3,
        Parent = MainFrame
    })
    
    -- Gradient Line (Top)
    local GradientLine = Create("Frame", {
        Name = "GradientLine",
        Size = UDim2.new(1, 0, 0, 3),
        Position = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Colors.GradientBlue),
            ColorSequenceKeypoint.new(0.5, Colors.GradientRed),
            ColorSequenceKeypoint.new(1, Colors.GradientYellow)
        }),
        Parent = GradientLine
    })
    
    -- ═══════════════════════════════════════
    -- TAB CONTAINER (Left Side)
    -- ═══════════════════════════════════════
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 92, 1, -3),
        Position = UDim2.new(0, 0, 0, 3),
        BackgroundColor3 = Colors.TabBackground,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabContainer
    })
    
    -- Tab Border (Right side of tab container)
    Create("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Colors.TabBorder,
        BorderSizePixel = 0,
        Parent = TabContainer
    })
    
    -- ═══════════════════════════════════════
    -- CONTENT CONTAINER (Right Side)
    -- ═══════════════════════════════════════
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -92, 1, -3),
        Position = UDim2.new(0, 92, 0, 3),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })
    
    Library.MainFrame = MainFrame
    Library.TabContainer = TabContainer
    Library.ContentContainer = ContentContainer
    Library.ScreenGui = ScreenGui
    
    -- ═══════════════════════════════════════
    -- DRAGGING SYSTEM
    -- ═══════════════════════════════════════
    local dragging, dragInput, dragStart, startPos
    
    MainFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    MainFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- ═══════════════════════════════════════
    -- TOGGLE VISIBILITY (Insert Key)
    -- ═══════════════════════════════════════
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Library.ToggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
    
    -- ═══════════════════════════════════════
    -- CREATE TAB FUNCTION
    -- ═══════════════════════════════════════
    function Library:CreateTab(name)
        local Tab = {}
        Tab.Name = name
        Tab.Elements = {}
        
        local tabIndex = #Library.Tabs + 1
        
        -- Tab Button
        local TabButton = Create("TextButton", {
            Name = "Tab_" .. name,
            Size = UDim2.new(1, 0, 0, 55),
            BackgroundColor3 = Colors.TabBackground,
            BorderSizePixel = 0,
            Font = Enum.Font.GothamBold,
            TextSize = 28,
            TextColor3 = Colors.TabText,
            Text = name,
            LayoutOrder = tabIndex,
            AutoButtonColor = false,
            Parent = TabContainer
        })
        
        -- Tab Content Area
        local TabContent = Create("ScrollingFrame", {
            Name = "Content_" .. name,
            Size = UDim2.new(1, -30, 1, -30),
            Position = UDim2.new(0, 15, 0, 15),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Colors.Accent,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = ContentContainer
        })
        
        local ContentLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 8),
            Parent = TabContent
        })
        
        -- Auto-resize canvas
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 15)
        end)
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        
        -- Tab Click Handler
        TabButton.MouseButton1Click:Connect(function()
            Library:SelectTab(Tab)
        end)
        
        TabButton.MouseEnter:Connect(function()
            if Library.CurrentTab ~= Tab then
                Tween(TabButton, 0.2, {TextColor3 = Colors.TabTextHover})
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Library.CurrentTab ~= Tab then
                Tween(TabButton, 0.2, {TextColor3 = Colors.TabText})
            end
        end)
        
        table.insert(Library.Tabs, Tab)
        
        -- Select first tab by default
        if tabIndex == 1 then
            Library:SelectTab(Tab)
        end
        
        -- ═══════════════════════════════════════
        -- ADD CHECKBOX / TOGGLE
        -- ═══════════════════════════════════════
        function Tab:AddCheckbox(text, default, callback)
            callback = callback or function() end
            
            local Checkbox = {Value = default or false}
            
            local Frame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                Parent = TabContent
            })
            
            local Box = Create("TextButton", {
                Size = UDim2.new(0, 11, 0, 11),
                Position = UDim2.new(0, 0, 0.5, -5),
                BackgroundColor3 = Checkbox.Value and Colors.CheckboxOn or Colors.CheckboxOff,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                Parent = Frame
            })
            
            Create("UIStroke", {
                Color = Color3.fromRGB(0, 0, 0),
                Thickness = 1,
                Parent = Box
            })
            
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, -25, 1, 0),
                Position = UDim2.new(0, 20, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.Code,
                TextSize = 11,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = text,
                Parent = Frame
            })
            
            Box.MouseButton1Click:Connect(function()
                Checkbox.Value = not Checkbox.Value
                Tween(Box, 0.15, {BackgroundColor3 = Checkbox.Value and Colors.CheckboxOn or Colors.CheckboxOff})
                callback(Checkbox.Value)
            end)
            
            function Checkbox:Set(value)
                Checkbox.Value = value
                Box.BackgroundColor3 = value and Colors.CheckboxOn or Colors.CheckboxOff
                callback(value)
            end
            
            return Checkbox
        end
        
        Tab.AddToggle = Tab.AddCheckbox -- Alias
        
        -- ═══════════════════════════════════════
        -- ADD BUTTON
        -- ═══════════════════════════════════════
        function Tab:AddButton(text, callback)
            callback = callback or function() end
            
            local Button = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = Colors.TabBackground,
                BorderSizePixel = 0,
                Font = Enum.Font.Code,
                TextSize = 11,
                TextColor3 = Colors.Text,
                Text = text,
                AutoButtonColor = false,
                Parent = TabContent
            })
            
            Create("UIStroke", {
                Color = Colors.TabBorder,
                Thickness = 1,
                Parent = Button
            })
            
            Button.MouseButton1Click:Connect(function()
                callback()
                Tween(Button, 0.1, {BackgroundColor3 = Colors.Accent})
                task.wait(0.1)
                Tween(Button, 0.1, {BackgroundColor3 = Colors.TabBackground})
            end)
            
            Button.MouseEnter:Connect(function()
                Tween(Button, 0.2, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
            end)
            
            Button.MouseLeave:Connect(function()
                Tween(Button, 0.2, {BackgroundColor3 = Colors.TabBackground})
            end)
            
            return Button
        end
        
        -- ═══════════════════════════════════════
        -- ADD SLIDER
        -- ═══════════════════════════════════════
        function Tab:AddSlider(text, min, max, default, callback)
            callback = callback or function() end
            min, max = min or 0, max or 100
            default = math.clamp(default or min, min, max)
            
            local Slider = {Value = default}
            
            local Frame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundTransparency = 1,
                Parent = TabContent
            })
            
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 14),
                BackgroundTransparency = 1,
                Font = Enum.Font.Code,
                TextSize = 11,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = text .. ": " .. default,
                Parent = Frame
            })
            
            local SliderBG = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 8),
                Position = UDim2.new(0, 0, 0, 22),
                BackgroundColor3 = Colors.CheckboxOff,
                BorderSizePixel = 0,
                Parent = Frame
            })
            
            local SliderFill = Create("Frame", {
                Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
                BackgroundColor3 = Colors.Accent,
                BorderSizePixel = 0,
                Parent = SliderBG
            })
            
            local sliding = false
            
            local function update(input)
                local rel = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                Slider.Value = math.floor(min + (max - min) * rel + 0.5)
                SliderFill.Size = UDim2.new(rel, 0, 1, 0)
                Label.Text = text .. ": " .. Slider.Value
                callback(Slider.Value)
            end
            
            SliderBG.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = true
                    update(input)
                end
            end)
            
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    sliding = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                    update(input)
                end
            end)
            
            function Slider:Set(value)
                value = math.clamp(value, min, max)
                Slider.Value = value
                local rel = (value - min) / (max - min)
                SliderFill.Size = UDim2.new(rel, 0, 1, 0)
                Label.Text = text .. ": " .. value
                callback(value)
            end
            
            return Slider
        end
        
        -- ═══════════════════════════════════════
        -- ADD DROPDOWN
        -- ═══════════════════════════════════════
        function Tab:AddDropdown(text, options, default, callback)
            callback = callback or function() end
            options = options or {}
            default = default or options[1] or ""
            
            local Dropdown = {Value = default, Open = false}
            
            local Frame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 48),
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                Parent = TabContent
            })
            
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 14),
                BackgroundTransparency = 1,
                Font = Enum.Font.Code,
                TextSize = 11,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = text,
                Parent = Frame
            })
            
            local DropButton = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 24),
                Position = UDim2.new(0, 0, 0, 18),
                BackgroundColor3 = Colors.TabBackground,
                BorderSizePixel = 0,
                Font = Enum.Font.Code,
                TextSize = 11,
                TextColor3 = Colors.Text,
                Text = "  " .. default .. "  ▼",
                TextXAlignment = Enum.TextXAlignment.Left,
                AutoButtonColor = false,
                Parent = Frame
            })
            
            Create("UIStroke", {
                Color = Colors.TabBorder,
                Thickness = 1,
                Parent = DropButton
            })
            
            local OptionHolder = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 44),
                BackgroundColor3 = Colors.TabBackground,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Parent = Frame
            })
            
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = OptionHolder
            })
            
            for i, opt in ipairs(options) do
                local OptBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 22),
                    BackgroundColor3 = Colors.TabBackground,
                    BorderSizePixel = 0,
                    Font = Enum.Font.Code,
                    TextSize = 11,
                    TextColor3 = Colors.Text,
                    Text = "  " .. opt,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    Parent = OptionHolder
                })
                
                OptBtn.MouseButton1Click:Connect(function()
                    Dropdown.Value = opt
                    DropButton.Text = "  " .. opt .. "  ▼"
                    callback(opt)
                    Dropdown.Open = false
                    Tween(Frame, 0.2, {Size = UDim2.new(1, 0, 0, 48)})
                    Tween(OptionHolder, 0.2, {Size = UDim2.new(1, 0, 0, 0)})
                end)
                
                OptBtn.MouseEnter:Connect(function()
                    Tween(OptBtn, 0.15, {BackgroundColor3 = Color3.fromRGB(30, 30, 30)})
                end)
                OptBtn.MouseLeave:Connect(function()
                    Tween(OptBtn, 0.15, {BackgroundColor3 = Colors.TabBackground})
                end)
            end
            
            DropButton.MouseButton1Click:Connect(function()
                Dropdown.Open = not Dropdown.Open
                local h = Dropdown.Open and (48 + #options * 22) or 48
                local oh = Dropdown.Open and (#options * 22) or 0
                Tween(Frame, 0.2, {Size = UDim2.new(1, 0, 0, h)})
                Tween(OptionHolder, 0.2, {Size = UDim2.new(1, 0, 0, oh)})
            end)
            
            function Dropdown:Set(value)
                Dropdown.Value = value
                DropButton.Text = "  " .. value .. "  ▼"
                callback(value)
            end
            
            return Dropdown
        end
        
        -- ═══════════════════════════════════════
        -- ADD LABEL
        -- ═══════════════════════════════════════
        function Tab:AddLabel(text)
            local LabelObj = {}
            
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Font = Enum.Font.Code,
                TextSize = 11,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = text,
                Parent = TabContent
            })
            
            function LabelObj:Set(newText)
                Label.Text = newText
            end
            
            return LabelObj
        end
        
        -- ═══════════════════════════════════════
        -- ADD TEXTBOX
        -- ═══════════════════════════════════════
        function Tab:AddTextbox(text, placeholder, callback)
            callback = callback or function() end
            
            local Textbox = {Value = ""}
            
            local Frame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 45),
                BackgroundTransparency = 1,
                Parent = TabContent
            })
            
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 14),
                BackgroundTransparency = 1,
                Font = Enum.Font.Code,
                TextSize = 11,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = text,
                Parent = Frame
            })
            
            local Input = Create("TextBox", {
                Size = UDim2.new(1, 0, 0, 24),
                Position = UDim2.new(0, 0, 0, 18),
                BackgroundColor3 = Colors.TabBackground,
                BorderSizePixel = 0,
                Font = Enum.Font.Code,
                TextSize = 11,
                TextColor3 = Colors.Text,
                PlaceholderText = placeholder or "",
                PlaceholderColor3 = Colors.TabText,
                Text = "",
                ClearTextOnFocus = false,
                Parent = Frame
            })
            
            Create("UIStroke", {
                Color = Colors.TabBorder,
                Thickness = 1,
                Parent = Input
            })
            
            Input.FocusLost:Connect(function(enterPressed)
                Textbox.Value = Input.Text
                callback(Input.Text, enterPressed)
            end)
            
            function Textbox:Set(value)
                Input.Text = value
                Textbox.Value = value
            end
            
            return Textbox
        end
        
        -- ═══════════════════════════════════════
        -- ADD KEYBIND
        -- ═══════════════════════════════════════
        function Tab:AddKeybind(text, default, callback)
            callback = callback or function() end
            
            local Keybind = {Value = default or Enum.KeyCode.Unknown, Listening = false}
            
            local Frame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 22),
                BackgroundTransparency = 1,
                Parent = TabContent
            })
            
            local Label = Create("TextLabel", {
                Size = UDim2.new(0.65, 0, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.Code,
                TextSize = 11,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = text,
                Parent = Frame
            })
            
            local KeyBtn = Create("TextButton", {
                Size = UDim2.new(0.3, 0, 0, 18),
                Position = UDim2.new(0.7, 0, 0.5, -9),
                BackgroundColor3 = Colors.TabBackground,
                BorderSizePixel = 0,
                Font = Enum.Font.Code,
                TextSize = 10,
                TextColor3 = Colors.Text,
                Text = default and default.Name or "None",
                AutoButtonColor = false,
                Parent = Frame
            })
            
            Create("UIStroke", {
                Color = Colors.TabBorder,
                Thickness = 1,
                Parent = KeyBtn
            })
            
            KeyBtn.MouseButton1Click:Connect(function()
                Keybind.Listening = true
                KeyBtn.Text = "..."
            end)
            
            UserInputService.InputBegan:Connect(function(input, gp)
                if Keybind.Listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    Keybind.Value = input.KeyCode
                    KeyBtn.Text = input.KeyCode.Name
                    Keybind.Listening = false
                elseif not gp and input.KeyCode == Keybind.Value then
                    callback(Keybind.Value)
                end
            end)
            
            function Keybind:Set(key)
                Keybind.Value = key
                KeyBtn.Text = key.Name
            end
            
            return Keybind
        end
        
        return Tab
    end
    
    -- ═══════════════════════════════════════
    -- SELECT TAB
    -- ═══════════════════════════════════════
    function Library:SelectTab(tab)
        for _, t in ipairs(Library.Tabs) do
            t.Button.BackgroundColor3 = Colors.TabBackground
            t.Button.TextColor3 = Colors.TabText
            t.Content.Visible = false
        end
        
        tab.Button.BackgroundColor3 = Colors.Background
        tab.Button.TextColor3 = Colors.TabTextActive
        tab.Content.Visible = true
        Library.CurrentTab = tab
    end
    
    function Library:ToggleWatermark(state)
        Watermark.Visible = state
    end
    
    function Library:SetToggleKey(key)
        Library.ToggleKey = key
    end
    
    function Library:Destroy()
        ScreenGui:Destroy()
    end
    
    return Library
end

return GameSenseLib
