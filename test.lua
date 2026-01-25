local GameSenseLib = {}
GameSenseLib.__index = GameSenseLib

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Colors = {
    Background = Color3.fromRGB(17, 17, 17),
    Border = Color3.fromRGB(61, 65, 76),
    TabBackground = Color3.fromRGB(12, 12, 12),
    TabBorder = Color3.fromRGB(50, 48, 52),
    TabText = Color3.fromRGB(90, 90, 90),
    TabTextHover = Color3.fromRGB(200, 200, 200),
    TabTextActive = Color3.fromRGB(255, 255, 255),
    CheckboxOff = Color3.fromRGB(71, 71, 71),
    CheckboxOn = Color3.fromRGB(149, 192, 33),
    Text = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(144, 187, 32),
    GradientBlue = Color3.fromRGB(69, 170, 242),
    GradientRed = Color3.fromRGB(252, 92, 101),
    GradientYellow = Color3.fromRGB(254, 211, 48),
    Black = Color3.fromRGB(0, 0, 0)
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

local function Tween(object, duration, properties)
    local tween = TweenService:Create(object, TweenInfo.new(duration, Enum.EasingStyle.Quad), properties)
    tween:Play()
    return tween
end

function GameSenseLib:Create(title, subtitle)
    local Library = {}
    Library.Tabs = {}
    Library.CurrentTab = nil
    Library.ToggleKey = Enum.KeyCode.Insert
    
    local ScreenGui = Create("ScreenGui", {
        Name = "GameSenseUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = playerGui
    })
    
    local Watermark = Create("Frame", {
        Name = "Watermark",
        Size = UDim2.new(0, 145, 0, 24),
        Position = UDim2.new(1, -160, 0, 15),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Visible = false,
        Parent = ScreenGui
    })
    
    Create("UIStroke", {
        Color = Colors.Border,
        Thickness = 2,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Parent = Watermark
    })
    
    Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Code,
        TextSize = 10,
        TextColor3 = Colors.Text,
        RichText = true,
        Text = string.format('%s<font color="rgb(144,187,32)">%s</font> | norate', title or "game", subtitle or "sense"),
        Parent = Watermark
    })
    
    Library.Watermark = Watermark
    
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 660, 0, 545),
        Position = UDim2.new(0.5, -330, 0.5, -272),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = ScreenGui
    })
    
    Create("UIStroke", {
        Color = Colors.Border,
        Thickness = 2,
        LineJoinMode = Enum.LineJoinMode.Miter,
        Parent = MainFrame
    })
    
    local GradientLine = Create("Frame", {
        Name = "GradientLine",
        Size = UDim2.new(1, 0, 0, 2),
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
        Rotation = 10,
        Parent = GradientLine
    })
    
    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        Size = UDim2.new(0, 92, 1, -2),
        Position = UDim2.new(0, 0, 0, 2),
        BackgroundColor3 = Colors.TabBackground,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = MainFrame
    })
    
    Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
        Parent = TabContainer
    })
    
    local TabBorderRight = Create("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = Colors.TabBorder,
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = TabContainer
    })
    
    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Size = UDim2.new(1, -92, 1, -2),
        Position = UDim2.new(0, 92, 0, 2),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = MainFrame
    })
    
    Library.MainFrame = MainFrame
    Library.TabContainer = TabContainer
    Library.ContentContainer = ContentContainer
    Library.ScreenGui = ScreenGui
    
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
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Library.ToggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
    
    function Library:CreateTab(name)
        local Tab = {}
        Tab.Name = name
        Tab.Elements = {}
        
        local tabIndex = #Library.Tabs + 1
        
        local TabButton = Create("TextButton", {
            Name = "Tab_" .. name,
            Size = UDim2.new(0, 92, 0, 90),
            BackgroundColor3 = Colors.TabBackground,
            BorderSizePixel = 0,
            Font = Enum.Font.GothamBold,
            TextSize = 32,
            TextColor3 = Colors.TabText,
            Text = name,
            LayoutOrder = tabIndex,
            AutoButtonColor = false,
            Parent = TabContainer
        })
        
        local TabButtonBorderRight = Create("Frame", {
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(1, -1, 0, 0),
            BackgroundColor3 = Colors.TabBorder,
            BorderSizePixel = 0,
            ZIndex = 2,
            Parent = TabButton
        })
        
        local TabContent = Create("ScrollingFrame", {
            Name = "Content_" .. name,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Colors.Accent,
            Visible = false,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = ContentContainer
        })
        
        local ContentPadding = Create("UIPadding", {
            PaddingTop = UDim.new(0, 85),
            PaddingLeft = UDim.new(0, 85),
            PaddingRight = UDim.new(0, 85),
            PaddingBottom = UDim.new(0, 20),
            Parent = TabContent
        })
        
        local ContentLayout = Create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 7),
            Parent = TabContent
        })
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 105)
        end)
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        Tab.BorderRight = TabButtonBorderRight
        
        TabButton.MouseButton1Click:Connect(function()
            Library:SelectTab(Tab)
        end)
        
        TabButton.MouseEnter:Connect(function()
            if Library.CurrentTab ~= Tab then
                Tween(TabButton, 0.15, {TextColor3 = Colors.TabTextHover})
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if Library.CurrentTab ~= Tab then
                Tween(TabButton, 0.15, {TextColor3 = Colors.TabText})
            end
        end)
        
        table.insert(Library.Tabs, Tab)
        
        if tabIndex == 1 then
            Library:SelectTab(Tab)
        end
        
        function Tab:AddCheckbox(text, default, callback)
            callback = callback or function() end
            local Checkbox = {Value = default or false}
            
            local Frame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 15),
                BackgroundTransparency = 1,
                LayoutOrder = #Tab.Elements + 1,
                Parent = TabContent
            })
            
            local Box = Create("TextButton", {
                Size = UDim2.new(0, 9, 0, 9),
                Position = UDim2.new(0, 0, 0, 3),
                BackgroundColor3 = Checkbox.Value and Colors.CheckboxOn or Colors.CheckboxOff,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                Parent = Frame
            })
            
            Create("UIStroke", {
                Color = Colors.Black,
                Thickness = 1,
                Parent = Box
            })
            
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 20, 0, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.Code,
                TextSize = 9,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = text,
                Parent = Frame
            })
            
            Box.MouseButton1Click:Connect(function()
                Checkbox.Value = not Checkbox.Value
                Tween(Box, 0.1, {BackgroundColor3 = Checkbox.Value and Colors.CheckboxOn or Colors.CheckboxOff})
                callback(Checkbox.Value)
            end)
            
            function Checkbox:Set(value)
                Checkbox.Value = value
                Box.BackgroundColor3 = value and Colors.CheckboxOn or Colors.CheckboxOff
                callback(value)
            end
            
            table.insert(Tab.Elements, Checkbox)
            return Checkbox
        end
        
        Tab.AddToggle = Tab.AddCheckbox
        
        function Tab:AddButton(text, callback)
            callback = callback or function() end
            
            local Button = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundColor3 = Colors.TabBackground,
                BorderSizePixel = 0,
                Font = Enum.Font.Code,
                TextSize = 9,
                TextColor3 = Colors.Text,
                Text = text,
                AutoButtonColor = false,
                LayoutOrder = #Tab.Elements + 1,
                Parent = TabContent
            })
            
            Create("UIStroke", {
                Color = Colors.TabBorder,
                Thickness = 1,
                Parent = Button
            })
            
            Button.MouseButton1Click:Connect(function()
                callback()
                Tween(Button, 0.08, {BackgroundColor3 = Colors.Accent})
                task.wait(0.08)
                Tween(Button, 0.08, {BackgroundColor3 = Colors.TabBackground})
            end)
            
            Button.MouseEnter:Connect(function()
                Tween(Button, 0.15, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)})
            end)
            
            Button.MouseLeave:Connect(function()
                Tween(Button, 0.15, {BackgroundColor3 = Colors.TabBackground})
            end)
            
            table.insert(Tab.Elements, Button)
            return Button
        end
        
        function Tab:AddSlider(text, min, max, default, callback)
            callback = callback or function() end
            min, max = min or 0, max or 100
            default = math.clamp(default or min, min, max)
            local Slider = {Value = default}
            
            local Frame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundTransparency = 1,
                LayoutOrder = #Tab.Elements + 1,
                Parent = TabContent
            })
            
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 12),
                BackgroundTransparency = 1,
                Font = Enum.Font.Code,
                TextSize = 9,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = text .. ": " .. default,
                Parent = Frame
            })
            
            local SliderBG = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 6),
                Position = UDim2.new(0, 0, 0, 18),
                BackgroundColor3 = Colors.CheckboxOff,
                BorderSizePixel = 0,
                Parent = Frame
            })
            
            Create("UIStroke", {
                Color = Colors.Black,
                Thickness = 1,
                Parent = SliderBG
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
            
            table.insert(Tab.Elements, Slider)
            return Slider
        end
        
        function Tab:AddDropdown(text, options, default, callback)
            callback = callback or function() end
            options = options or {}
            default = default or options[1] or ""
            local Dropdown = {Value = default, Open = false}
            
            local Frame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 38),
                BackgroundTransparency = 1,
                ClipsDescendants = true,
                LayoutOrder = #Tab.Elements + 1,
                Parent = TabContent
            })
            
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 12),
                BackgroundTransparency = 1,
                Font = Enum.Font.Code,
                TextSize = 9,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = text,
                Parent = Frame
            })
            
            local DropButton = Create("TextButton", {
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 0, 0, 14),
                BackgroundColor3 = Colors.TabBackground,
                BorderSizePixel = 0,
                Font = Enum.Font.Code,
                TextSize = 9,
                TextColor3 = Colors.Text,
                Text = "  " .. default .. "  v",
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
                Position = UDim2.new(0, 0, 0, 36),
                BackgroundColor3 = Colors.TabBackground,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Parent = Frame
            })
            
            Create("UIStroke", {
                Color = Colors.TabBorder,
                Thickness = 1,
                Parent = OptionHolder
            })
            
            Create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = OptionHolder
            })
            
            for i, opt in ipairs(options) do
                local OptBtn = Create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundColor3 = Colors.TabBackground,
                    BorderSizePixel = 0,
                    Font = Enum.Font.Code,
                    TextSize = 9,
                    TextColor3 = Colors.Text,
                    Text = "  " .. opt,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    LayoutOrder = i,
                    Parent = OptionHolder
                })
                
                OptBtn.MouseButton1Click:Connect(function()
                    Dropdown.Value = opt
                    DropButton.Text = "  " .. opt .. "  v"
                    callback(opt)
                    Dropdown.Open = false
                    Tween(Frame, 0.15, {Size = UDim2.new(1, 0, 0, 38)})
                    Tween(OptionHolder, 0.15, {Size = UDim2.new(1, 0, 0, 0)})
                end)
                
                OptBtn.MouseEnter:Connect(function()
                    Tween(OptBtn, 0.1, {BackgroundColor3 = Color3.fromRGB(25, 25, 25)})
                end)
                OptBtn.MouseLeave:Connect(function()
                    Tween(OptBtn, 0.1, {BackgroundColor3 = Colors.TabBackground})
                end)
            end
            
            DropButton.MouseButton1Click:Connect(function()
                Dropdown.Open = not Dropdown.Open
                local h = Dropdown.Open and (38 + #options * 18 + 2) or 38
                local oh = Dropdown.Open and (#options * 18) or 0
                Tween(Frame, 0.15, {Size = UDim2.new(1, 0, 0, h)})
                Tween(OptionHolder, 0.15, {Size = UDim2.new(1, 0, 0, oh)})
            end)
            
            function Dropdown:Set(value)
                Dropdown.Value = value
                DropButton.Text = "  " .. value .. "  v"
                callback(value)
            end
            
            table.insert(Tab.Elements, Dropdown)
            return Dropdown
        end
        
        function Tab:AddLabel(text)
            local LabelObj = {}
            
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 14),
                BackgroundTransparency = 1,
                Font = Enum.Font.Code,
                TextSize = 9,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = text,
                LayoutOrder = #Tab.Elements + 1,
                Parent = TabContent
            })
            
            function LabelObj:Set(newText)
                Label.Text = newText
            end
            
            table.insert(Tab.Elements, LabelObj)
            return LabelObj
        end
        
        function Tab:AddTextbox(text, placeholder, callback)
            callback = callback or function() end
            local Textbox = {Value = ""}
            
            local Frame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                LayoutOrder = #Tab.Elements + 1,
                Parent = TabContent
            })
            
            local Label = Create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 12),
                BackgroundTransparency = 1,
                Font = Enum.Font.Code,
                TextSize = 9,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = text,
                Parent = Frame
            })
            
            local Input = Create("TextBox", {
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 0, 0, 14),
                BackgroundColor3 = Colors.TabBackground,
                BorderSizePixel = 0,
                Font = Enum.Font.Code,
                TextSize = 9,
                TextColor3 = Colors.Text,
                PlaceholderText = placeholder or "",
                PlaceholderColor3 = Colors.TabText,
                Text = "",
                TextXAlignment = Enum.TextXAlignment.Left,
                ClearTextOnFocus = false,
                Parent = Frame
            })
            
            Create("UIPadding", {
                PaddingLeft = UDim.new(0, 5),
                Parent = Input
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
            
            table.insert(Tab.Elements, Textbox)
            return Textbox
        end
        
        function Tab:AddKeybind(text, default, callback)
            callback = callback or function() end
            local Keybind = {Value = default or Enum.KeyCode.Unknown, Listening = false}
            
            local Frame = Create("Frame", {
                Size = UDim2.new(1, 0, 0, 15),
                BackgroundTransparency = 1,
                LayoutOrder = #Tab.Elements + 1,
                Parent = TabContent
            })
            
            local Label = Create("TextLabel", {
                Size = UDim2.new(0.6, 0, 1, 0),
                BackgroundTransparency = 1,
                Font = Enum.Font.Code,
                TextSize = 9,
                TextColor3 = Colors.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                Text = text,
                Parent = Frame
            })
            
            local KeyBtn = Create("TextButton", {
                Size = UDim2.new(0.35, 0, 0, 15),
                Position = UDim2.new(0.65, 0, 0, 0),
                BackgroundColor3 = Colors.TabBackground,
                BorderSizePixel = 0,
                Font = Enum.Font.Code,
                TextSize = 9,
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
            
            table.insert(Tab.Elements, Keybind)
            return Keybind
        end
        
        return Tab
    end
    
    function Library:SelectTab(tab)
        for _, t in ipairs(Library.Tabs) do
            t.Button.BackgroundColor3 = Colors.TabBackground
            t.Button.TextColor3 = Colors.TabText
            t.BorderRight.Visible = true
            t.Content.Visible = false
        end
        
        tab.Button.BackgroundColor3 = Colors.Background
        tab.Button.TextColor3 = Colors.TabTextActive
        tab.BorderRight.Visible = false
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
