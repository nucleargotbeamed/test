
local GameSenseUI = {}
GameSenseUI.__index = GameSenseUI

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

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
    ColumnBackground = Color3.fromRGB(14, 14, 14),
    ColumnHeader = Color3.fromRGB(20, 20, 20),
    Font = Enum.Font.Code
}

local function Create(instanceClass, properties)
    local instance = Instance.new(instanceClass)
    for property, value in pairs(properties) do
        if property ~= "Parent" then
            instance[property] = value
        end
    end
    if properties.Parent then
        instance.Parent = properties.Parent
    end
    return instance
end

local function AddStroke(parent, strokeColor, strokeThickness)
    return Create("UIStroke", {
        Color = strokeColor or Theme.Border,
        Thickness = strokeThickness or 1,
        Parent = parent
    })
end

local function MakeDraggable(frame, handle)
    handle = handle or frame
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos = nil

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

local FPSCounter = {
    fps = 0,
    frameCount = 0,
    lastTime = tick(),
    connections = {},
    running = false
}

function FPSCounter:Start()
    if self.running then
        return
    end
    self.running = true

    self.connections.heartbeat = RunService.Heartbeat:Connect(function()
        self.frameCount = self.frameCount + 1
        local currentTime = tick()
        local elapsed = currentTime - self.lastTime

        if elapsed >= 1 then
            self.fps = math.floor(self.frameCount / elapsed)
            self.frameCount = 0
            self.lastTime = currentTime
        end
    end)
end

function FPSCounter:Stop()
    self.running = false
    for connectionName, connection in pairs(self.connections) do
        if connection then
            connection:Disconnect()
        end
    end
    self.connections = {}
end

function FPSCounter:Get()
    return self.fps
end

FPSCounter:Start()

local TAB_SIZE = 65

function GameSenseUI:CreateWindow(windowConfig)
    windowConfig = windowConfig or {}
    local title = windowConfig.Title or "game"
    local subtitle = windowConfig.Subtitle or "sense"

    local Window = {
        Tabs = {},
        CurrentTab = nil,
        ToggleKey = windowConfig.ToggleKey or Enum.KeyCode.Insert,
        Connections = {}
    }

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
        Position = UDim2.new(0.5, -330, 0.5, -272),
        Size = UDim2.new(0, 660, 0, 545),
        ClipsDescendants = true
    })

    local OuterBorder = Create("Frame", {
        Name = "OuterBorder",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 4, 1, 4),
        Position = UDim2.new(0, -2, 0, -2)
    })
    AddStroke(OuterBorder, Theme.Border, 2)

    local InnerBorder = Create("Frame", {
        Name = "InnerBorder",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 2, 0, 2)
    })
    AddStroke(InnerBorder, Theme.Border, 1)

    local GradientLine = Create("Frame", {
        Name = "GradientLine",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, 0, 0, 2),
        BorderSizePixel = 0
    })

    Create("UIGradient", {
        Parent = GradientLine,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Theme.GradientBlue),
            ColorSequenceKeypoint.new(0.5, Theme.GradientRed),
            ColorSequenceKeypoint.new(1, Theme.GradientYellow)
        })
    })

    local TabContainer = Create("Frame", {
        Name = "TabContainer",
        Parent = MainFrame,
        BackgroundColor3 = Theme.TabBackground,
        Position = UDim2.new(0, 0, 0, 2),
        Size = UDim2.new(0, TAB_SIZE, 1, -2),
        BorderSizePixel = 0
    })

    Create("Frame", {
        Name = "RightBorder",
        Parent = TabContainer,
        BackgroundColor3 = Theme.TabBorder,
        Position = UDim2.new(1, -1, 0, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BorderSizePixel = 0
    })

    local TabButtonContainer = Create("Frame", {
        Name = "TabButtons",
        Parent = TabContainer,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0)
    })

    Create("UIListLayout", {
        Parent = TabButtonContainer,
        SortOrder = Enum.SortOrder.LayoutOrder
    })

    local ContentContainer = Create("Frame", {
        Name = "ContentContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, TAB_SIZE + 10, 0, 10),
        Size = UDim2.new(1, -(TAB_SIZE + 20), 1, -20)
    })

    local DragHandle = Create("Frame", {
        Name = "DragHandle",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20)
    })
    MakeDraggable(MainFrame, DragHandle)

    Window.Connections.ToggleKey = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Window.ToggleKey then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    Window.ScreenGui = ScreenGui
    Window.MainFrame = MainFrame
    Window.TabContainer = TabButtonContainer
    Window.ContentContainer = ContentContainer

    function Window:SetToggleKey(newKey)
        Window.ToggleKey = newKey
    end

    function Window:GetToggleKey()
        return Window.ToggleKey
    end

    function Window:GetFPS()
        return FPSCounter:Get()
    end

    function Window:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        local tabName = tabConfig.Name or tabConfig.Text or "Tab"
        local tabIcon = tabConfig.Icon or nil

        local Tab = {
            Elements = {},
            Columns = {}
        }
        local tabIndex = #Window.Tabs + 1

        local TabButton = Create("TextButton", {
            Name = "Tab_" .. tabName,
            Parent = TabButtonContainer,
            BackgroundColor3 = Theme.TabBackground,
            Size = UDim2.new(0, TAB_SIZE, 0, TAB_SIZE),
            BorderSizePixel = 0,
            Text = "",
            LayoutOrder = tabIndex,
            AutoButtonColor = false
        })

        if tabIcon then
            Create("ImageLabel", {
                Parent = TabButton,
                BackgroundTransparency = 1,
                Position = UDim2.new(0.5, 0, 0.5, 0),
                AnchorPoint = Vector2.new(0.5, 0.5),
                Size = UDim2.new(0, 28, 0, 28),
                Image = tabIcon,
                ImageColor3 = Theme.TextDark,
                Name = "Icon"
            })
        else
            Create("TextLabel", {
                Parent = TabButton,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Theme.Font,
                Text = string.sub(tabName, 1, 1),
                TextColor3 = Theme.TextDark,
                TextSize = 28,
                Name = "Label"
            })
        end

        local TopBorder = Create("Frame", {
            Name = "TopBorder",
            Parent = TabButton,
            BackgroundColor3 = Theme.TabBorder,
            Size = UDim2.new(1, 0, 0, 1),
            BorderSizePixel = 0,
            Visible = false
        })

        local BottomBorder = Create("Frame", {
            Name = "BottomBorder",
            Parent = TabButton,
            BackgroundColor3 = Theme.TabBorder,
            Position = UDim2.new(0, 0, 1, -1),
            Size = UDim2.new(1, 0, 0, 1),
            BorderSizePixel = 0,
            Visible = false
        })

        local TabContent = Create("Frame", {
            Name = "Content_" .. tabName,
            Parent = ContentContainer,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false
        })

        local ColumnContainer = Create("Frame", {
            Name = "ColumnContainer",
            Parent = TabContent,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0)
        })

        Create("UIListLayout", {
            Parent = ColumnContainer,
            SortOrder = Enum.SortOrder.LayoutOrder,
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 10)
        })

        local function updateTabVisual(isActive)
            local iconOrLabel = TabButton:FindFirstChild("Icon") or TabButton:FindFirstChild("Label")
            if isActive then
                TabButton.BackgroundColor3 = Theme.Background
                if iconOrLabel:IsA("ImageLabel") then
                    iconOrLabel.ImageColor3 = Theme.Text
                else
                    iconOrLabel.TextColor3 = Theme.Text
                end
                TopBorder.Visible = true
                BottomBorder.Visible = true
            else
                TabButton.BackgroundColor3 = Theme.TabBackground
                if iconOrLabel:IsA("ImageLabel") then
                    iconOrLabel.ImageColor3 = Theme.TextDark
                else
                    iconOrLabel.TextColor3 = Theme.TextDark
                end
                TopBorder.Visible = false
                BottomBorder.Visible = false
            end
        end

        TabButton.MouseButton1Click:Connect(function()
            for i, tab in pairs(Window.Tabs) do
                tab.Content.Visible = false
                local tabIconOrLabel = tab.Button:FindFirstChild("Icon") or tab.Button:FindFirstChild("Label")
                if tabIconOrLabel:IsA("ImageLabel") then
                    tabIconOrLabel.ImageColor3 = Theme.TextDark
                else
                    tabIconOrLabel.TextColor3 = Theme.TextDark
                end
                tab.Button.BackgroundColor3 = Theme.TabBackground
                tab.Button.TopBorder.Visible = false
                tab.Button.BottomBorder.Visible = false
            end
            updateTabVisual(true)
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end)

        TabButton.MouseEnter:Connect(function()
            if Window.CurrentTab ~= Tab then
                local iconOrLabel = TabButton:FindFirstChild("Icon") or TabButton:FindFirstChild("Label")
                if iconOrLabel:IsA("ImageLabel") then
                    iconOrLabel.ImageColor3 = Theme.TextHover
                else
                    iconOrLabel.TextColor3 = Theme.TextHover
                end
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if Window.CurrentTab ~= Tab then
                local iconOrLabel = TabButton:FindFirstChild("Icon") or TabButton:FindFirstChild("Label")
                if iconOrLabel:IsA("ImageLabel") then
                    iconOrLabel.ImageColor3 = Theme.TextDark
                else
                    iconOrLabel.TextColor3 = Theme.TextDark
                end
            end
        end)

        Tab.Button = TabButton
        Tab.Content = TabContent
        Tab.ColumnContainer = ColumnContainer

        if tabIndex == 1 then
            updateTabVisual(true)
            TabContent.Visible = true
            Window.CurrentTab = Tab
        end

        function Tab:CreateColumn(columnName, columnCount)
            columnCount = columnCount or 1
            local Column = {
                Elements = {}
            }

            local columnWidth = 1
            if columnCount == 2 then
                columnWidth = 0.5
            end

            local ColumnFrame = Create("Frame", {
                Name = "Column_" .. columnName,
                Parent = ColumnContainer,
                BackgroundColor3 = Theme.ColumnBackground,
                Size = UDim2.new(columnWidth, columnCount == 2 and -5 or 0, 1, 0),
                ClipsDescendants = true
            })
            AddStroke(ColumnFrame, Theme.Border, 1)

            local ColumnHeader = Create("Frame", {
                Name = "Header",
                Parent = ColumnFrame,
                BackgroundColor3 = Theme.ColumnHeader,
                Size = UDim2.new(1, 0, 0, 25),
                BorderSizePixel = 0
            })

            Create("Frame", {
                Name = "HeaderBorder",
                Parent = ColumnHeader,
                BackgroundColor3 = Theme.Border,
                Position = UDim2.new(0, 0, 1, -1),
                Size = UDim2.new(1, 0, 0, 1),
                BorderSizePixel = 0
            })

            Create("TextLabel", {
                Parent = ColumnHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Font = Theme.Font,
                Text = columnName,
                TextColor3 = Theme.Text,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ColumnContent = Create("ScrollingFrame", {
                Name = "Content",
                Parent = ColumnFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 25),
                Size = UDim2.new(1, 0, 1, -25),
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = Theme.Accent,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollingDirection = Enum.ScrollingDirection.Y
            })

            Create("UIListLayout", {
                Parent = ColumnContent,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5)
            })

            Create("UIPadding", {
                Parent = ColumnContent,
                PaddingTop = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                PaddingBottom = UDim.new(0, 8)
            })

            Column.Frame = ColumnFrame
            Column.Content = ColumnContent

            function Column:CreateSection(sectionText)
                local Section = {}

                local SectionFrame = Create("Frame", {
                    Name = "Section_" .. sectionText,
                    Parent = ColumnContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20)
                })

                Create("TextLabel", {
                    Parent = SectionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Font = Theme.Font,
                    Text = sectionText,
                    TextColor3 = Theme.Accent,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                return Section
            end

            function Column:CreateCheckbox(checkboxConfig)
                checkboxConfig = checkboxConfig or {}
                local checkboxText = checkboxConfig.Text or "Checkbox"
                local checkboxDefault = checkboxConfig.Default or false
                local checkboxCallback = checkboxConfig.Callback or function() end

                local Checkbox = {}
                local toggled = checkboxDefault

                local CheckboxFrame = Create("Frame", {
                    Name = "Checkbox_" .. checkboxText,
                    Parent = ColumnContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18)
                })

                local CheckboxIndicator = Create("Frame", {
                    Name = "Indicator",
                    Parent = CheckboxFrame,
                    BackgroundColor3 = toggled and Theme.Accent or Theme.ElementBackground,
                    Position = UDim2.new(0, 0, 0.5, -5),
                    Size = UDim2.new(0, 9, 0, 9)
                })
                AddStroke(CheckboxIndicator, Theme.ElementBorder, 1)

                Create("TextLabel", {
                    Parent = CheckboxFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 17, 0, 0),
                    Size = UDim2.new(1, -17, 1, 0),
                    Font = Theme.Font,
                    Text = checkboxText,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ClickButton = Create("TextButton", {
                    Parent = CheckboxFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })

                ClickButton.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    if toggled then
                        CheckboxIndicator.BackgroundColor3 = Theme.Accent
                    else
                        CheckboxIndicator.BackgroundColor3 = Theme.ElementBackground
                    end
                    checkboxCallback(toggled)
                end)

                function Checkbox:Set(value)
                    toggled = value
                    if toggled then
                        CheckboxIndicator.BackgroundColor3 = Theme.Accent
                    else
                        CheckboxIndicator.BackgroundColor3 = Theme.ElementBackground
                    end
                    checkboxCallback(toggled)
                end

                function Checkbox:Get()
                    return toggled
                end

                table.insert(Column.Elements, Checkbox)
                return Checkbox
            end

            function Column:CreateSlider(sliderConfig)
                sliderConfig = sliderConfig or {}
                local sliderText = sliderConfig.Text or "Slider"
                local sliderMin = sliderConfig.Min or 0
                local sliderMax = sliderConfig.Max or 100
                local sliderDefault = sliderConfig.Default or sliderMin
                local sliderIncrement = sliderConfig.Increment or 1
                local sliderSuffix = sliderConfig.Suffix or ""
                local sliderCallback = sliderConfig.Callback or function() end

                local Slider = {}
                local sliderValue = sliderDefault

                local SliderFrame = Create("Frame", {
                    Name = "Slider_" .. sliderText,
                    Parent = ColumnContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32)
                })

                local SliderLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Theme.Font,
                    Text = sliderText .. ": " .. tostring(sliderValue) .. sliderSuffix,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local SliderBackground = Create("Frame", {
                    Parent = SliderFrame,
                    BackgroundColor3 = Theme.ElementBackground,
                    Position = UDim2.new(0, 0, 0, 18),
                    Size = UDim2.new(1, 0, 0, 10)
                })
                AddStroke(SliderBackground, Theme.ElementBorder, 1)

                local SliderFill = Create("Frame", {
                    Parent = SliderBackground,
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new((sliderValue - sliderMin) / (sliderMax - sliderMin), 0, 1, 0),
                    BorderSizePixel = 0
                })

                local SliderButton = Create("TextButton", {
                    Parent = SliderBackground,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = ""
                })

                local sliderDragging = false

                local function updateSlider(inputPosition)
                    local relativeX = math.clamp((inputPosition.X - SliderBackground.AbsolutePosition.X) / SliderBackground.AbsoluteSize.X, 0, 1)
                    local rawValue = sliderMin + (sliderMax - sliderMin) * relativeX
                    sliderValue = math.floor(rawValue / sliderIncrement + 0.5) * sliderIncrement
                    sliderValue = math.clamp(sliderValue, sliderMin, sliderMax)

                    SliderFill.Size = UDim2.new((sliderValue - sliderMin) / (sliderMax - sliderMin), 0, 1, 0)
                    SliderLabel.Text = sliderText .. ": " .. tostring(sliderValue) .. sliderSuffix
                    sliderCallback(sliderValue)
                end

                SliderButton.MouseButton1Down:Connect(function()
                    sliderDragging = true
                    updateSlider(UserInputService:GetMouseLocation())
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        sliderDragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        updateSlider(input.Position)
                    end
                end)

                function Slider:Set(newValue)
                    sliderValue = math.clamp(newValue, sliderMin, sliderMax)
                    SliderFill.Size = UDim2.new((sliderValue - sliderMin) / (sliderMax - sliderMin), 0, 1, 0)
                    SliderLabel.Text = sliderText .. ": " .. tostring(sliderValue) .. sliderSuffix
                    sliderCallback(sliderValue)
                end

                function Slider:Get()
                    return sliderValue
                end

                table.insert(Column.Elements, Slider)
                return Slider
            end

            function Column:CreateButton(buttonConfig)
                buttonConfig = buttonConfig or {}
                local buttonText = buttonConfig.Text or "Button"
                local buttonCallback = buttonConfig.Callback or function() end

                local Button = {}

                local ButtonFrame = Create("TextButton", {
                    Name = "Button_" .. buttonText,
                    Parent = ColumnContent,
                    BackgroundColor3 = Theme.ElementBackground,
                    Size = UDim2.new(1, 0, 0, 24),
                    Font = Theme.Font,
                    Text = buttonText,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    AutoButtonColor = false
                })
                AddStroke(ButtonFrame, Theme.ElementBorder, 1)

                ButtonFrame.MouseButton1Click:Connect(buttonCallback)

                ButtonFrame.MouseEnter:Connect(function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.Accent}):Play()
                end)

                ButtonFrame.MouseLeave:Connect(function()
                    TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ElementBackground}):Play()
                end)

                table.insert(Column.Elements, Button)
                return Button
            end

            function Column:CreateDropdown(dropdownConfig)
                dropdownConfig = dropdownConfig or {}
                local dropdownText = dropdownConfig.Text or "Dropdown"
                local dropdownOptions = dropdownConfig.Options or {}
                local dropdownDefault = dropdownConfig.Default or dropdownOptions[1]
                local dropdownCallback = dropdownConfig.Callback or function() end

                local Dropdown = {}
                local selectedOption = dropdownDefault
                local dropdownOpened = false

                local DropdownFrame = Create("Frame", {
                    Name = "Dropdown_" .. dropdownText,
                    Parent = ColumnContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 42),
                    ClipsDescendants = false,
                    ZIndex = 5
                })

                Create("TextLabel", {
                    Parent = DropdownFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Theme.Font,
                    Text = dropdownText,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local DropdownButton = Create("TextButton", {
                    Parent = DropdownFrame,
                    BackgroundColor3 = Theme.ElementBackground,
                    Position = UDim2.new(0, 0, 0, 16),
                    Size = UDim2.new(1, 0, 0, 22),
                    Font = Theme.Font,
                    Text = "  " .. tostring(selectedOption or "Select..."),
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    AutoButtonColor = false,
                    ZIndex = 5
                })
                AddStroke(DropdownButton, Theme.ElementBorder, 1)

                local Arrow = Create("TextLabel", {
                    Parent = DropdownButton,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(1, -20, 0, 0),
                    Size = UDim2.new(0, 15, 1, 0),
                    Font = Theme.Font,
                    Text = "v",
                    TextColor3 = Theme.Text,
                    TextSize = 10,
                    ZIndex = 5
                })

                local OptionContainer = Create("Frame", {
                    Parent = DropdownButton,
                    BackgroundColor3 = Theme.TabBackground,
                    Position = UDim2.new(0, 0, 1, 2),
                    Size = UDim2.new(1, 0, 0, math.min(#dropdownOptions * 20, 100)),
                    Visible = false,
                    ClipsDescendants = true,
                    ZIndex = 10
                })
                AddStroke(OptionContainer, Theme.ElementBorder, 1)

                local OptionScroll = Create("ScrollingFrame", {
                    Parent = OptionContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ScrollBarThickness = 2,
                    ScrollBarImageColor3 = Theme.Accent,
                    CanvasSize = UDim2.new(0, 0, 0, #dropdownOptions * 20),
                    ZIndex = 10
                })

                Create("UIListLayout", {
                    Parent = OptionScroll,
                    SortOrder = Enum.SortOrder.LayoutOrder
                })

                local function refreshDropdownOptions()
                    for i, child in pairs(OptionScroll:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end

                    for i, option in ipairs(dropdownOptions) do
                        local OptionButton = Create("TextButton", {
                            Parent = OptionScroll,
                            BackgroundColor3 = Theme.TabBackground,
                            Size = UDim2.new(1, 0, 0, 20),
                            Font = Theme.Font,
                            Text = "  " .. option,
                            TextColor3 = Theme.Text,
                            TextSize = 12,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            LayoutOrder = i,
                            AutoButtonColor = false,
                            ZIndex = 10
                        })

                        OptionButton.MouseEnter:Connect(function()
                            OptionButton.BackgroundColor3 = Theme.ElementBackground
                        end)

                        OptionButton.MouseLeave:Connect(function()
                            OptionButton.BackgroundColor3 = Theme.TabBackground
                        end)

                        OptionButton.MouseButton1Click:Connect(function()
                            selectedOption = option
                            DropdownButton.Text = "  " .. option
                            OptionContainer.Visible = false
                            dropdownOpened = false
                            Arrow.Rotation = 0
                            dropdownCallback(option)
                        end)
                    end
                end

                refreshDropdownOptions()

                DropdownButton.MouseButton1Click:Connect(function()
                    dropdownOpened = not dropdownOpened
                    OptionContainer.Visible = dropdownOpened
                    local targetRotation = 0
                    if dropdownOpened then
                        targetRotation = 180
                    end
                    TweenService:Create(Arrow, TweenInfo.new(0.1), {Rotation = targetRotation}):Play()
                end)

                function Dropdown:Set(option)
                    selectedOption = option
                    DropdownButton.Text = "  " .. option
                    dropdownCallback(option)
                end

                function Dropdown:Get()
                    return selectedOption
                end

                function Dropdown:Refresh(newOptions, newDefault)
                    dropdownOptions = newOptions
                    selectedOption = newDefault or newOptions[1]
                    DropdownButton.Text = "  " .. tostring(selectedOption or "Select...")
                    OptionContainer.Size = UDim2.new(1, 0, 0, math.min(#dropdownOptions * 20, 100))
                    OptionScroll.CanvasSize = UDim2.new(0, 0, 0, #dropdownOptions * 20)
                    refreshDropdownOptions()
                end

                table.insert(Column.Elements, Dropdown)
                return Dropdown
            end

            function Column:CreateTextbox(textboxConfig)
                textboxConfig = textboxConfig or {}
                local textboxText = textboxConfig.Text or "Textbox"
                local textboxPlaceholder = textboxConfig.Placeholder or ""
                local textboxCallback = textboxConfig.Callback or function() end

                local Textbox = {}

                local TextboxFrame = Create("Frame", {
                    Name = "Textbox_" .. textboxText,
                    Parent = ColumnContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 38)
                })

                Create("TextLabel", {
                    Parent = TextboxFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 14),
                    Font = Theme.Font,
                    Text = textboxText,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local TextboxInput = Create("TextBox", {
                    Parent = TextboxFrame,
                    BackgroundColor3 = Theme.ElementBackground,
                    Position = UDim2.new(0, 0, 0, 16),
                    Size = UDim2.new(1, 0, 0, 20),
                    Font = Theme.Font,
                    PlaceholderText = textboxPlaceholder,
                    PlaceholderColor3 = Theme.TextDark,
                    Text = "",
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    ClearTextOnFocus = false
                })
                AddStroke(TextboxInput, Theme.ElementBorder, 1)

                TextboxInput.FocusLost:Connect(function(enterPressed)
                    textboxCallback(TextboxInput.Text, enterPressed)
                end)

                function Textbox:Set(value)
                    TextboxInput.Text = value
                end

                function Textbox:Get()
                    return TextboxInput.Text
                end

                table.insert(Column.Elements, Textbox)
                return Textbox
            end

            function Column:CreateKeybind(keybindConfig)
                keybindConfig = keybindConfig or {}
                local keybindText = keybindConfig.Text or "Keybind"
                local keybindDefault = keybindConfig.Default or Enum.KeyCode.Unknown
                local keybindCallback = keybindConfig.Callback or function() end
                local keybindChangedCallback = keybindConfig.ChangedCallback or function() end

                local Keybind = {}
                local currentKey = keybindDefault
                local isListening = false

                local KeybindFrame = Create("Frame", {
                    Name = "Keybind_" .. keybindText,
                    Parent = ColumnContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20)
                })

                Create("TextLabel", {
                    Parent = KeybindFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.6, 0, 1, 0),
                    Font = Theme.Font,
                    Text = keybindText,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local KeybindButton = Create("TextButton", {
                    Parent = KeybindFrame,
                    BackgroundColor3 = Theme.ElementBackground,
                    Position = UDim2.new(0.6, 5, 0, 0),
                    Size = UDim2.new(0.4, -5, 1, 0),
                    Font = Theme.Font,
                    Text = currentKey.Name,
                    TextColor3 = Theme.Text,
                    TextSize = 11,
                    AutoButtonColor = false
                })
                AddStroke(KeybindButton, Theme.ElementBorder, 1)

                KeybindButton.MouseButton1Click:Connect(function()
                    isListening = true
                    KeybindButton.Text = "..."
                end)

                UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if isListening then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            currentKey = input.KeyCode
                            KeybindButton.Text = currentKey.Name
                            isListening = false
                            keybindChangedCallback(currentKey)
                        end
                    elseif input.KeyCode == currentKey and not gameProcessed then
                        keybindCallback(currentKey)
                    end
                end)

                function Keybind:Set(newKey)
                    currentKey = newKey
                    KeybindButton.Text = newKey.Name
                    keybindChangedCallback(newKey)
                end

                function Keybind:Get()
                    return currentKey
                end

                table.insert(Column.Elements, Keybind)
                return Keybind
            end

            function Column:CreateLabel(labelText)
                local Label = {}

                local LabelFrame = Create("TextLabel", {
                    Name = "Label",
                    Parent = ColumnContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    Font = Theme.Font,
                    Text = labelText,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                function Label:Set(newText)
                    LabelFrame.Text = newText
                end

                return Label
            end

            function Column:CreateToggle(toggleConfig)
                toggleConfig = toggleConfig or {}
                local toggleText = toggleConfig.Text or "Toggle"
                local toggleDefault = toggleConfig.Default or false
                local toggleCallback = toggleConfig.Callback or function() end

                local Toggle = {}
                local toggled = toggleDefault

                local ToggleFrame = Create("Frame", {
                    Name = "Toggle_" .. toggleText,
                    Parent = ColumnContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20)
                })

                Create("TextLabel", {
                    Parent = ToggleFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.7, 0, 1, 0),
                    Font = Theme.Font,
                    Text = toggleText,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local toggleButtonColor = Theme.ElementBackground
                if toggled then
                    toggleButtonColor = Theme.Accent
                end

                local ToggleButton = Create("TextButton", {
                    Parent = ToggleFrame,
                    BackgroundColor3 = toggleButtonColor,
                    Position = UDim2.new(1, -40, 0.5, -8),
                    Size = UDim2.new(0, 35, 0, 16),
                    Text = "",
                    AutoButtonColor = false
                })
                AddStroke(ToggleButton, Theme.ElementBorder, 1)

                local circlePosition = UDim2.new(0, 2, 0.5, -6)
                if toggled then
                    circlePosition = UDim2.new(1, -14, 0.5, -6)
                end

                local ToggleCircle = Create("Frame", {
                    Parent = ToggleButton,
                    BackgroundColor3 = Theme.Text,
                    Position = circlePosition,
                    Size = UDim2.new(0, 12, 0, 12)
                })
                Create("UICorner", {
                    Parent = ToggleCircle,
                    CornerRadius = UDim.new(1, 0)
                })

                ToggleButton.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    local newColor = Theme.ElementBackground
                    local newPosition = UDim2.new(0, 2, 0.5, -6)
                    if toggled then
                        newColor = Theme.Accent
                        newPosition = UDim2.new(1, -14, 0.5, -6)
                    end
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = newColor}):Play()
                    TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {Position = newPosition}):Play()
                    toggleCallback(toggled)
                end)

                function Toggle:Set(value)
                    toggled = value
                    local newColor = Theme.ElementBackground
                    local newPosition = UDim2.new(0, 2, 0.5, -6)
                    if toggled then
                        newColor = Theme.Accent
                        newPosition = UDim2.new(1, -14, 0.5, -6)
                    end
                    ToggleButton.BackgroundColor3 = newColor
                    ToggleCircle.Position = newPosition
                    toggleCallback(toggled)
                end

                function Toggle:Get()
                    return toggled
                end

                table.insert(Column.Elements, Toggle)
                return Toggle
            end

            function Column:CreateColorPicker(colorPickerConfig)
                colorPickerConfig = colorPickerConfig or {}
                local colorPickerText = colorPickerConfig.Text or "Color"
                local colorPickerDefault = colorPickerConfig.Default or Color3.fromRGB(255, 255, 255)
                local colorPickerCallback = colorPickerConfig.Callback or function() end

                local ColorPicker = {}
                local currentColor = colorPickerDefault

                local ColorPickerFrame = Create("Frame", {
                    Name = "ColorPicker_" .. colorPickerText,
                    Parent = ColumnContent,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 20)
                })

                Create("TextLabel", {
                    Parent = ColorPickerFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.7, 0, 1, 0),
                    Font = Theme.Font,
                    Text = colorPickerText,
                    TextColor3 = Theme.Text,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                local ColorDisplay = Create("TextButton", {
                    Parent = ColorPickerFrame,
                    BackgroundColor3 = currentColor,
                    Position = UDim2.new(1, -30, 0.5, -8),
                    Size = UDim2.new(0, 25, 0, 16),
                    Text = "",
                    AutoButtonColor = false
                })
                AddStroke(ColorDisplay, Theme.ElementBorder, 1)

                ColorDisplay.MouseButton1Click:Connect(function()
                    local colors = {
                        Color3.fromRGB(255, 0, 0),
                        Color3.fromRGB(0, 255, 0),
                        Color3.fromRGB(0, 0, 255),
                        Color3.fromRGB(255, 255, 0),
                        Color3.fromRGB(255, 0, 255),
                        Color3.fromRGB(0, 255, 255),
                        Color3.fromRGB(255, 255, 255),
                        Theme.Accent
                    }
                    local colorIndex = table.find(colors, currentColor) or 0
                    currentColor = colors[(colorIndex % #colors) + 1]
                    ColorDisplay.BackgroundColor3 = currentColor
                    colorPickerCallback(currentColor)
                end)

                function ColorPicker:Set(newColor)
                    currentColor = newColor
                    ColorDisplay.BackgroundColor3 = newColor
                    colorPickerCallback(newColor)
                end

                function ColorPicker:Get()
                    return currentColor
                end

                table.insert(Column.Elements, ColorPicker)
                return ColorPicker
            end

            table.insert(Tab.Columns, Column)
            return Column
        end

        table.insert(Window.Tabs, Tab)
        return Tab
    end

    function Window:CreateWatermark(watermarkConfig)
        watermarkConfig = watermarkConfig or {}
        local watermarkText = watermarkConfig.Text or "gamesense"
        local watermarkShowFPS = watermarkConfig.ShowFPS or false
        local watermarkShowPing = watermarkConfig.ShowPing or false
        local watermarkShowTime = watermarkConfig.ShowTime or false

        local WatermarkData = {
            showFPS = watermarkShowFPS,
            showPing = watermarkShowPing,
            showTime = watermarkShowTime,
            customText = watermarkText,
            running = true
        }

        local WatermarkFrame = Create("Frame", {
            Name = "Watermark",
            Parent = ScreenGui,
            BackgroundColor3 = Theme.Background,
            Position = UDim2.new(1, -250, 0, 15),
            Size = UDim2.new(0, 230, 0, 28)
        })

        local WMOuterBorder = Create("Frame", {
            Parent = WatermarkFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 4, 1, 4),
            Position = UDim2.new(0, -2, 0, -2)
        })
        AddStroke(WMOuterBorder, Theme.Border, 2)

        local WMInnerBorder = Create("Frame", {
            Parent = WatermarkFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -4, 1, -4),
            Position = UDim2.new(0, 2, 0, 2)
        })
        AddStroke(WMInnerBorder, Theme.Border, 1)

        local WatermarkLabel = Create("TextLabel", {
            Name = "WatermarkLabel",
            Parent = WatermarkFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Theme.Font,
            RichText = true,
            Text = 'game<font color="#90bb20">sense</font> | ' .. watermarkText,
            TextColor3 = Theme.Text,
            TextSize = 12
        })

        WatermarkData.Frame = WatermarkFrame
        WatermarkData.Label = WatermarkLabel

        local function updateWatermark()
            local parts = {'game<font color="#90bb20">sense</font>'}

            if WatermarkData.customText and WatermarkData.customText ~= "" then
                table.insert(parts, WatermarkData.customText)
            end

            if WatermarkData.showFPS then
                table.insert(parts, "fps: " .. tostring(FPSCounter:Get()))
            end

            if WatermarkData.showPing then
                local success, ping = pcall(function()
                    return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
                end)
                if success then
                    table.insert(parts, "ping: " .. tostring(math.floor(ping)) .. "ms")
                end
            end

            if WatermarkData.showTime then
                table.insert(parts, os.date("%H:%M:%S"))
            end

            WatermarkLabel.Text = table.concat(parts, " | ")

            local textService = game:GetService("TextService")
            local plainText = WatermarkLabel.Text:gsub("<.->", "")
            local textSize = textService:GetTextSize(plainText, 12, Theme.Font, Vector2.new(1000, 28))
            WatermarkFrame.Size = UDim2.new(0, textSize.X + 20, 0, 28)
            WatermarkFrame.Position = UDim2.new(1, -(textSize.X + 35), 0, 15)
        end

        task.spawn(function()
            while WatermarkData.running do
                if WatermarkFrame and WatermarkFrame.Parent then
                    updateWatermark()
                else
                    break
                end
                task.wait(0.1)
            end
        end)

        function WatermarkData:SetText(newText)
            WatermarkData.customText = newText
        end

        function WatermarkData:SetFPS(enabled)
            WatermarkData.showFPS = enabled
        end

        function WatermarkData:SetPing(enabled)
            WatermarkData.showPing = enabled
        end

        function WatermarkData:SetTime(enabled)
            WatermarkData.showTime = enabled
        end

        function WatermarkData:Toggle(visible)
            WatermarkFrame.Visible = visible
        end

        function WatermarkData:Destroy()
            WatermarkData.running = false
            WatermarkFrame:Destroy()
        end

        return WatermarkData
    end

    function Window:Notify(notifyConfig)
        notifyConfig = notifyConfig or {}
        local notifyTitle = notifyConfig.Title or "Notification"
        local notifyMessage = notifyConfig.Message or ""
        local notifyDuration = notifyConfig.Duration or 3

        local NotificationHolder = ScreenGui:FindFirstChild("NotificationHolder")
        if not NotificationHolder then
            NotificationHolder = Create("Frame", {
                Name = "NotificationHolder",
                Parent = ScreenGui,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -320, 1, -20),
                Size = UDim2.new(0, 300, 0, 0),
                AnchorPoint = Vector2.new(0, 1)
            })

            Create("UIListLayout", {
                Parent = NotificationHolder,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5),
                VerticalAlignment = Enum.VerticalAlignment.Bottom
            })
        end

        local Notification = Create("Frame", {
            Parent = NotificationHolder,
            BackgroundColor3 = Theme.Background,
            Size = UDim2.new(1, 0, 0, 50),
            ClipsDescendants = true
        })
        AddStroke(Notification, Theme.Border, 1)

        local NotifLine = Create("Frame", {
            Parent = Notification,
            BackgroundColor3 = Color3.new(1, 1, 1),
            Size = UDim2.new(1, 0, 0, 2),
            BorderSizePixel = 0
        })
        Create("UIGradient", {
            Parent = NotifLine,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Theme.GradientBlue),
                ColorSequenceKeypoint.new(0.5, Theme.GradientRed),
                ColorSequenceKeypoint.new(1, Theme.GradientYellow)
            })
        })

        Create("TextLabel", {
            Parent = Notification,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 5),
            Size = UDim2.new(1, -20, 0, 18),
            Font = Theme.Font,
            Text = notifyTitle,
            TextColor3 = Theme.Accent,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        Create("TextLabel", {
            Parent = Notification,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 10, 0, 25),
            Size = UDim2.new(1, -20, 0, 20),
            Font = Theme.Font,
            Text = notifyMessage,
            TextColor3 = Theme.Text,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true
        })

        Notification.Position = UDim2.new(1, 0, 0, 0)
        TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(0, 0, 0, 0)}):Play()

        task.delay(notifyDuration, function()
            TweenService:Create(Notification, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(1, 0, 0, 0)}):Play()
            task.wait(0.3)
            Notification:Destroy()
        end)
    end

    function Window:Destroy()
        FPSCounter:Stop()
        for connectionName, connection in pairs(Window.Connections) do
            if connection then
                connection:Disconnect()
            end
        end
        ScreenGui:Destroy()
    end

    function Window:Toggle(visible)
        MainFrame.Visible = visible
    end

    return Window
end

return GameSenseUI
