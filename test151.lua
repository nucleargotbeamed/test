local UILib = {}

function UILib:CreateWindow(title)
    local gui = Instance.new("ScreenGui")
    gui.Name = "GameSenseUI"
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("Players").LocalPlayer.PlayerGui

    local main = Instance.new("Frame")
    main.Size = UDim2.fromOffset(660, 545)
    main.Position = UDim2.fromScale(0.5, 0.5) - UDim2.fromOffset(330, 272)
    main.BackgroundColor3 = Color3.fromRGB(17,17,17)
    main.BorderSizePixel = 0
    main.Parent = gui

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(61,65,76)
    stroke.Parent = main

    local topLine = Instance.new("Frame")
    topLine.Size = UDim2.new(1,0,0,2)
    topLine.BackgroundColor3 = Color3.fromRGB(120,180,255)
    topLine.BorderSizePixel = 0
    topLine.Parent = main

    local tabs = Instance.new("Frame")
    tabs.Size = UDim2.new(0,70,1,-2)
    tabs.Position = UDim2.new(0,0,0,2)
    tabs.BackgroundColor3 = Color3.fromRGB(12,12,12)
    tabs.BorderSizePixel = 0
    tabs.Parent = main

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Parent = tabs

    local pages = Instance.new("Frame")
    pages.Size = UDim2.new(1,-70,1,-2)
    pages.Position = UDim2.new(0,70,0,2)
    pages.BackgroundTransparency = 1
    pages.Parent = main

    local window = {
        Tabs = {},
        Pages = {},
        Current = nil
    }

    function window:AddTab(letter)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1,0,0,70)
        button.Text = letter
        button.Font = Enum.Font.GothamBlack
        button.TextSize = 48
        button.TextColor3 = Color3.fromRGB(90,90,90)
        button.BackgroundColor3 = Color3.fromRGB(12,12,12)
        button.BorderSizePixel = 0
        button.Parent = tabs

        local page = Instance.new("Frame")
        page.Size = UDim2.new(1,0,1,0)
        page.Visible = false
        page.BackgroundTransparency = 1
        page.Parent = pages

        button.MouseButton1Click:Connect(function()
            if window.Current then
                window.Current.Page.Visible = false
                window.Current.Button.TextColor3 = Color3.fromRGB(90,90,90)
            end
            page.Visible = true
            button.TextColor3 = Color3.new(1,1,1)
            window.Current = {Button = button, Page = page}
        end)

        if not window.Current then
            button.TextColor3 = Color3.new(1,1,1)
            page.Visible = true
            window.Current = {Button = button, Page = page}
        end

        return page
    end

    local dragging, dragStart, startPos
    main.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = i.Position
            startPos = main.Position
        end
    end)

    main.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - dragStart
            main.Position = startPos + UDim2.fromOffset(delta.X, delta.Y)
        end
    end)

    return window
end

return UILib
