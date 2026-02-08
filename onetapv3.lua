local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local function CreateInstance(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

local function Tween(object, properties, duration)
    local tweenInfo = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

function Library:CreateWindow(title)
    local Window = {}
    
    local ScreenGui = CreateInstance("ScreenGui", {
        Name = "MenuUI",
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    
    local MainFrame = CreateInstance("Frame", {
        Name = "Menu",
        Parent = ScreenGui,
        BackgroundColor3 = Color3.fromRGB(45, 48, 57),
        BorderColor3 = Color3.fromRGB(0, 0, 0),
        Position = UDim2.new(0.35, 0, 0.15, 0),
        Size = UDim2.new(0, 577, 0, 619),
        Active = true
    })
    
    local dragToggle = nil
    local dragStart = nil
    local startPos = nil
    local dragInput = nil
    
    local function updateInput(input)
        local delta = input.Position - dragStart
        local position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        TweenService:Create(MainFrame, TweenInfo.new(0.15), {Position = position}):Play()
    end
    
    MainFrame.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
            dragToggle = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragToggle = false
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
        if input == dragInput and dragToggle then
            updateInput(input)
        end
    end)
    
    CreateInstance("UICorner", {
        Parent = MainFrame,
        CornerRadius = UDim.new(0, 3)
    })
    
    local ColorBar = CreateInstance("Frame", {
        Name = "ColorBar",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(224, 159, 93),
        Size = UDim2.new(1, 0, 0, 8),
        BorderSizePixel = 0
    })
    
    CreateInstance("UICorner", {
        Parent = ColorBar,
        CornerRadius = UDim.new(0, 2)
    })
    
    local MenuBar = CreateInstance("Frame", {
        Name = "MenuBar",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(45, 48, 57),
        Position = UDim2.new(0, 0, 0, 8),
        Size = UDim2.new(1, 0, 0, 60),
        BorderSizePixel = 0
    })
    
    local TitleLabel = CreateInstance("TextLabel", {
        Parent = MenuBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 12),
        Size = UDim2.new(0, 200, 0, 25),
        Font = Enum.Font.GothamBold,
        Text = title or "onetap",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 25,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local Line1 = CreateInstance("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(55, 58, 67),
        Position = UDim2.new(0, 120, 0, 23),
        Size = UDim2.new(0, 1, 0, 30),
        BorderSizePixel = 0
    })
    
    local Line2 = CreateInstance("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(55, 58, 67),
        Position = UDim2.new(0, 15, 0, 38),
        Size = UDim2.new(0, 550, 0, 1),
        BorderSizePixel = 0
    })
    
    local Line3 = CreateInstance("Frame", {
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(55, 58, 67),
        Position = UDim2.new(0, 15, 0, 558),
        Size = UDim2.new(0, 550, 0, 1),
        BorderSizePixel = 0
    })
    
    local FooterText = CreateInstance("TextLabel", {
        Parent = Line3,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 5),
        Size = UDim2.new(0, 200, 0, 20),
        Font = Enum.Font.Gotham,
        Text = "n0rate",
        TextColor3 = Color3.fromRGB(181, 183, 193),
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local TabContainer = CreateInstance("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 140, 0, -7),
        Size = UDim2.new(0, 400, 0, 60)
    })
    
    local TabList = CreateInstance("UIListLayout", {
        Parent = TabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center
    })
    
    local SubTabBar = CreateInstance("Frame", {
        Name = "SubTabBar",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(32, 32, 38),
        Position = UDim2.new(0, 15, 0, 23),
        Size = UDim2.new(0, 550, 0, 70),
        BorderSizePixel = 0,
        Visible = false
    })
    
    CreateInstance("UICorner", {
        Parent = SubTabBar,
        CornerRadius = UDim.new(0, 2)
    })
    
    local SubTabContainer = CreateInstance("Frame", {
        Parent = SubTabBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 20, 0, 35),
        Size = UDim2.new(1, -40, 0, 30)
    })
    
    local SubTabList = CreateInstance("UIListLayout", {
        Parent = SubTabContainer,
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 50),
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Center
    })
    
    local ContentContainer = CreateInstance("Frame", {
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 98),
        Size = UDim2.new(1, 0, 1, -168)
    })
    
    Window.CurrentTab = nil
    Window.Tabs = {}
    
    function Window:AddTab(tabName, hasSubTabs)
        local Tab = {}
        
        local TabButton = CreateInstance("TextButton", {
            Parent = TabContainer,
            BackgroundColor3 = Color3.fromRGB(33, 36, 43),
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 80, 0, 30),
            Font = Enum.Font.Gotham,
            Text = tabName,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14
        })
        
        CreateInstance("UICorner", {
            Parent = TabButton,
            CornerRadius = UDim.new(0, 5)
        })
        
        local TabContent = CreateInstance("ScrollingFrame", {
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ScrollBarThickness = 4,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            BorderSizePixel = 0,
            ScrollBarImageColor3 = Color3.fromRGB(224, 159, 93)
        })
        
        local ContentLayout = CreateInstance("UIListLayout", {
            Parent = TabContent,
            Padding = UDim.new(0, 15),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Top,
            Wraps = true
        })
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 20)
        end)
        
        Tab.SubTabs = {}
        Tab.CurrentSubTab = nil
        Tab.HasSubTabs = hasSubTabs or false
        
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Button.BackgroundTransparency = 1
                tab.Content.Visible = false
            end
            
            TabButton.BackgroundTransparency = 0
            TabContent.Visible = true
            Window.CurrentTab = Tab
            
            if Tab.HasSubTabs then
                SubTabBar.Visible = true
                for name, subTab in pairs(Tab.SubTabs) do
                    subTab.Container.Parent = SubTabContainer
                end
                if Tab.CurrentSubTab then
                    Tab.CurrentSubTab.Content.Visible = true
                end
            else
                SubTabBar.Visible = false
                for _, child in pairs(SubTabContainer:GetChildren()) do
                    if child:IsA("TextLabel") then
                        child.Parent = nil
                    end
                end
            end
        end)
        
        if not Window.CurrentTab then
            TabButton.BackgroundTransparency = 0
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end
        
        Tab.Button = TabButton
        Tab.Content = TabContent
        Tab.Elements = {}
        
        function Tab:AddSubTab(subTabName)
            local SubTab = {}
            
            local SubTabLabel = CreateInstance("TextLabel", {
                Parent = SubTabContainer,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 80, 0, 20),
                Font = Enum.Font.Gotham,
                Text = subTabName:upper(),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 12,
                TextTransparency = 0.5
            })
            
            local SubTabButton = CreateInstance("TextButton", {
                Parent = SubTabLabel,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                ZIndex = 2
            })
            
            local SubTabContent = CreateInstance("Frame", {
                Parent = TabContent,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Visible = false
            })
            
            local SubContentLayout = CreateInstance("UIListLayout", {
                Parent = SubTabContent,
                Padding = UDim.new(0, 15),
                HorizontalAlignment = Enum.HorizontalAlignment.Left,
                FillDirection = Enum.FillDirection.Horizontal,
                VerticalAlignment = Enum.VerticalAlignment.Top,
                Wraps = true
            })
            
            SubTabButton.MouseButton1Click:Connect(function()
                for name, st in pairs(Tab.SubTabs) do
                    st.Label.TextTransparency = 0.5
                    st.Content.Visible = false
                end
                
                SubTabLabel.TextTransparency = 0
                SubTabContent.Visible = true
                Tab.CurrentSubTab = SubTab
            end)
            
            if not Tab.CurrentSubTab then
                SubTabLabel.TextTransparency = 0
                SubTabContent.Visible = true
                Tab.CurrentSubTab = SubTab
            end
            
            SubTab.Label = SubTabLabel
            SubTab.Button = SubTabButton
            SubTab.Content = SubTabContent
            SubTab.Container = SubTabLabel
            
            Tab.SubTabs[subTabName] = SubTab
            
            function SubTab:AddSection(sectionName)
                return Tab:AddSection(sectionName, SubTabContent)
            end
            
            return SubTab
        end
        
        function Tab:AddSection(sectionName, parentContainer)
            local Section = {}
            
            local targetParent = parentContainer or TabContent
            
            local SectionFrame = CreateInstance("Frame", {
                Parent = targetParent,
                BackgroundColor3 = Color3.fromRGB(32, 32, 38),
                BorderColor3 = Color3.fromRGB(58, 58, 58),
                Size = UDim2.new(0, 250, 0, 200)
            })
            
            CreateInstance("UICorner", {
                Parent = SectionFrame,
                CornerRadius = UDim.new(0, 4)
            })
            
            local TopBorder = CreateInstance("Frame", {
                Parent = SectionFrame,
                BackgroundColor3 = Color3.fromRGB(224, 159, 93),
                Size = UDim2.new(1, 0, 0, 2),
                BorderSizePixel = 0
            })
            
            local SectionLabel = CreateInstance("TextLabel", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, -10),
                Size = UDim2.new(1, 0, 0, 20),
                Font = Enum.Font.Gotham,
                Text = sectionName,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 10
            })
            
            local ElementContainer = CreateInstance("Frame", {
                Parent = SectionFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 15),
                Size = UDim2.new(1, -20, 1, -20)
            })
            
            local ElementLayout = CreateInstance("UIListLayout", {
                Parent = ElementContainer,
                Padding = UDim.new(0, 7),
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Left
            })
            
            local elementCount = 0
            
            ElementLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(0, 250, 0, math.max(200, ElementLayout.AbsoluteContentSize.Y + 30))
            end)
            
            function Section:AddToggle(name, default, callback)
                local Toggle = {}
                
                local ToggleFrame = CreateInstance("Frame", {
                    Parent = ElementContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 15)
                })
                
                local ToggleBox = CreateInstance("Frame", {
                    Parent = ToggleFrame,
                    BackgroundColor3 = Color3.fromRGB(33, 33, 41),
                    BorderColor3 = Color3.fromRGB(0, 0, 0),
                    Position = UDim2.new(0, 10, 0, 3),
                    Size = UDim2.new(0, 9, 0, 9)
                })
                
                CreateInstance("UICorner", {
                    Parent = ToggleBox,
                    CornerRadius = UDim.new(0, 2)
                })
                
                local ToggleLabel = CreateInstance("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 27, 0, 0),
                    Size = UDim2.new(1, -27, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local ToggleButton = CreateInstance("TextButton", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })
                
                Toggle.State = default or false
                
                if Toggle.State then
                    ToggleBox.BackgroundColor3 = Color3.fromRGB(224, 159, 93)
                end
                
                ToggleButton.MouseButton1Click:Connect(function()
                    Toggle.State = not Toggle.State
                    
                    if Toggle.State then
                        Tween(ToggleBox, {BackgroundColor3 = Color3.fromRGB(224, 159, 93)})
                    else
                        Tween(ToggleBox, {BackgroundColor3 = Color3.fromRGB(33, 33, 41)})
                    end
                    
                    if callback then
                        callback(Toggle.State)
                    end
                end)
                
                function Toggle:Set(value)
                    Toggle.State = value
                    if Toggle.State then
                        ToggleBox.BackgroundColor3 = Color3.fromRGB(224, 159, 93)
                    else
                        ToggleBox.BackgroundColor3 = Color3.fromRGB(33, 33, 41)
                    end
                    if callback then
                        callback(Toggle.State)
                    end
                end
                
                return Toggle
            end
            
            function Section:AddSlider(name, min, max, default, callback)
                local Slider = {}
                
                local SliderFrame = CreateInstance("Frame", {
                    Parent = ElementContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 25)
                })
                
                local SliderLabel = CreateInstance("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 17, 0, 0),
                    Size = UDim2.new(1, -17, 0, 12),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 10,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local SliderBG = CreateInstance("Frame", {
                    Parent = SliderFrame,
                    BackgroundColor3 = Color3.fromRGB(32, 35, 43),
                    Position = UDim2.new(0, 5, 0, 15),
                    Size = UDim2.new(1, -10, 0, 5),
                    BorderSizePixel = 0
                })
                
                CreateInstance("UICorner", {
                    Parent = SliderBG,
                    CornerRadius = UDim.new(0, 5)
                })
                
                local SliderFill = CreateInstance("Frame", {
                    Parent = SliderBG,
                    BackgroundColor3 = Color3.fromRGB(224, 159, 93),
                    Size = UDim2.new(0, 0, 1, 0),
                    BorderSizePixel = 0
                })
                
                CreateInstance("UICorner", {
                    Parent = SliderFill,
                    CornerRadius = UDim.new(0, 5)
                })
                
                Slider.Value = default or min
                local dragging = false
                
                local function UpdateSlider(input)
                    local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
                    Slider.Value = math.floor(min + (max - min) * pos)
                    SliderFill.Size = UDim2.new(pos, 0, 1, 0)
                    
                    if callback then
                        callback(Slider.Value)
                    end
                end
                
                SliderBG.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        dragToggle = false
                        UpdateSlider(input)
                    end
                end)
                
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)
                
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
                        dragging = false
                    end
                end)
                
                local initialPos = ((default or min) - min) / (max - min)
                SliderFill.Size = UDim2.new(initialPos, 0, 1, 0)
                
                return Slider
            end
            
            function Section:AddDropdown(name, options, default, callback)
                local Dropdown = {}
                
                local DropdownFrame = CreateInstance("Frame", {
                    Parent = ElementContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 35)
                })
                
                local DropdownLabel = CreateInstance("TextLabel", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 17, 0, 0),
                    Size = UDim2.new(1, -34, 0, 12),
                    Font = Enum.Font.Gotham,
                    Text = name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 9,
                    TextXAlignment = Enum.TextXAlignment.Left
                })
                
                local DropdownButton = CreateInstance("TextButton", {
                    Parent = DropdownFrame,
                    BackgroundColor3 = Color3.fromRGB(32, 31, 36),
                    BorderColor3 = Color3.fromRGB(58, 58, 58),
                    Position = UDim2.new(0.13, 0, 0, 15),
                    Size = UDim2.new(0.75, 0, 0, 20),
                    Font = Enum.Font.Gotham,
                    Text = default or options[1] or "None",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 9
                })
                
                CreateInstance("UICorner", {
                    Parent = DropdownButton,
                    CornerRadius = UDim.new(0, 2)
                })
                
                Dropdown.Value = default or options[1]
                
                DropdownButton.MouseButton1Click:Connect(function()
                    local index = table.find(options, Dropdown.Value) or 1
                    index = index % #options + 1
                    Dropdown.Value = options[index]
                    DropdownButton.Text = Dropdown.Value
                    
                    if callback then
                        callback(Dropdown.Value)
                    end
                end)
                
                return Dropdown
            end
            
            return Section
        end
        
        table.insert(Window.Tabs, Tab)
        return Tab
    end
    
    local toggleKey = Enum.KeyCode.Period
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == toggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)
    
    return Window
end

return Library
