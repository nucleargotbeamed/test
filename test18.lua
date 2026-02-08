local Library = {}
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Colors = {
	Background = Color3.fromRGB(18,18,18),
	ElementBg = Color3.fromRGB(28,28,28),
	SectionBg = Color3.fromRGB(22,22,22),
	Text = Color3.fromRGB(230,230,230),
	Accent = Color3.fromRGB(120,120,255)
}

function Library:CreateWindow(title, subtitle)
	local ScreenGui = Instance.new("ScreenGui", Players.LocalPlayer.PlayerGui)
	ScreenGui.ResetOnSpawn = false

	local Main = Instance.new("Frame", ScreenGui)
	Main.Size = UDim2.new(0, 620, 0, 420)
	Main.Position = UDim2.new(0.5, -310, 0.5, -210)
	Main.BackgroundColor3 = Colors.Background
	Main.BorderSizePixel = 0

	local Corner = Instance.new("UICorner", Main)
	Corner.CornerRadius = UDim.new(0, 8)

	local Top = Instance.new("TextLabel", Main)
	Top.Size = UDim2.new(1, 0, 0, 40)
	Top.BackgroundTransparency = 1
	Top.Text = title.."  |  "..subtitle
	Top.Font = Enum.Font.GothamBold
	Top.TextSize = 16
	Top.TextColor3 = Colors.Text

	local TabsFrame = Instance.new("Frame", Main)
	TabsFrame.Position = UDim2.new(0, 10, 0, 50)
	TabsFrame.Size = UDim2.new(0, 600, 0, 30)
	TabsFrame.BackgroundTransparency = 1

	local TabsLayout = Instance.new("UIListLayout", TabsFrame)
	TabsLayout.FillDirection = Enum.FillDirection.Horizontal
	TabsLayout.Padding = UDim.new(0, 6)

	local ContentFrame = Instance.new("Frame", Main)
	ContentFrame.Position = UDim2.new(0, 10, 0, 90)
	ContentFrame.Size = UDim2.new(0, 600, 0, 320)
	ContentFrame.BackgroundTransparency = 1

	local Window = {
		Gui = ScreenGui,
		Main = Main,
		TabContainer = TabsFrame,
		ContentFrame = ContentFrame,
		Tabs = {},
		CurrentTab = nil
	}

	UIS.InputBegan:Connect(function(i)
		if i.KeyCode == Enum.KeyCode.Delete then
			Main.Visible = not Main.Visible
		end
	end)

	return Window
end

function Library:CreateTab(Window, name)
	local Tab = {}

	local Button = Instance.new("TextButton", Window.TabContainer)
	Button.Size = UDim2.new(0, 90, 1, 0)
	Button.BackgroundColor3 = Colors.ElementBg
	Button.Text = name
	Button.Font = Enum.Font.Gotham
	Button.TextSize = 13
	Button.TextColor3 = Colors.Text
	Button.BorderSizePixel = 0

	Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

	local Content = Instance.new("Frame", Window.ContentFrame)
	Content.Size = UDim2.new(1, 0, 1, 0)
	Content.Visible = false
	Content.BackgroundTransparency = 1

	local Layout = Instance.new("UIListLayout", Content)
	Layout.Padding = UDim.new(0, 12)

	Button.MouseButton1Click:Connect(function()
		for _,t in ipairs(Window.Tabs) do
			t.Content.Visible = false
		end
		Content.Visible = true
		Window.CurrentTab = Tab
	end)

	Tab.Button = Button
	Tab.Content = Content

	table.insert(Window.Tabs, Tab)

	if not Window.CurrentTab then
		Content.Visible = true
		Window.CurrentTab = Tab
	end

	return Tab
end

function Library:AddWeaponCategory(Window, name)
	return self:CreateTab(Window, name)
end

function Library:CreateSection(Tab, name, height)
	local Section = Instance.new("Frame", Tab.Content)
	Section.Size = UDim2.new(1, 0, 0, height or 200)
	Section.BackgroundColor3 = Colors.SectionBg
	Section.BorderSizePixel = 0

	Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 6)

	local Title = Instance.new("TextLabel", Section)
	Title.Size = UDim2.new(1, -10, 0, 24)
	Title.Position = UDim2.new(0, 5, 0, 4)
	Title.BackgroundTransparency = 1
	Title.Text = name
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 13
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.TextColor3 = Colors.Text

	local Holder = Instance.new("Frame", Section)
	Holder.Position = UDim2.new(0, 5, 0, 32)
	Holder.Size = UDim2.new(1, -10, 1, -36)
	Holder.BackgroundTransparency = 1

	local Layout = Instance.new("UIListLayout", Holder)
	Layout.Padding = UDim.new(0, 6)

	return Holder
end

function Library:CreateCheckbox(parent, text, default, callback)
	local Toggle = Instance.new("TextButton", parent)
	Toggle.Size = UDim2.new(1, 0, 0, 24)
	Toggle.BackgroundColor3 = Colors.ElementBg
	Toggle.Text = text
	Toggle.Font = Enum.Font.Gotham
	Toggle.TextSize = 12
	Toggle.TextColor3 = Colors.Text
	Toggle.BorderSizePixel = 0

	Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 4)

	local State = default

	Toggle.MouseButton1Click:Connect(function()
		State = not State
		Toggle.TextColor3 = State and Colors.Accent or Colors.Text
		if callback then callback(State) end
	end)
end

function Library:CreateSlider(parent, text, min, max, default, callback)
	local Frame = Instance.new("Frame", parent)
	Frame.Size = UDim2.new(1, 0, 0, 32)
	Frame.BackgroundTransparency = 1

	local Label = Instance.new("TextLabel", Frame)
	Label.Size = UDim2.new(1, 0, 0, 14)
	Label.BackgroundTransparency = 1
	Label.Text = text..": "..default
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 12
	Label.TextColor3 = Colors.Text
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Bar = Instance.new("Frame", Frame)
	Bar.Position = UDim2.new(0, 0, 0, 18)
	Bar.Size = UDim2.new(1, 0, 0, 10)
	Bar.BackgroundColor3 = Colors.ElementBg
	Bar.BorderSizePixel = 0

	Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

	local Fill = Instance.new("Frame", Bar)
	Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
	Fill.BackgroundColor3 = Colors.Accent
	Fill.BorderSizePixel = 0

	Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

	Bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			local move
			move = UIS.InputChanged:Connect(function(j)
				if j.UserInputType == Enum.UserInputType.MouseMovement then
					local pct = math.clamp((j.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
					local val = math.floor(min + (max-min)*pct)
					Fill.Size = UDim2.new(pct,0,1,0)
					Label.Text = text..": "..val
					if callback then callback(val) end
				end
			end)
			UIS.InputEnded:Once(function() move:Disconnect() end)
		end
	end)
end

function Library:CreateDropdown(parent, text, list, default, callback)
	local Button = Instance.new("TextButton", parent)
	Button.Size = UDim2.new(1, 0, 0, 24)
	Button.BackgroundColor3 = Colors.ElementBg
	Button.Text = text..": "..default
	Button.Font = Enum.Font.Gotham
	Button.TextSize = 12
	Button.TextColor3 = Colors.Text
	Button.BorderSizePixel = 0

	Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)

	local Open = false
	local Current = default

	Button.MouseButton1Click:Connect(function()
		Open = not Open
		if Open then
			for _,v in ipairs(list) do
				local Opt = Instance.new("TextButton", parent)
				Opt.Size = UDim2.new(1, 0, 0, 22)
				Opt.BackgroundColor3 = Colors.SectionBg
				Opt.Text = v
				Opt.Font = Enum.Font.Gotham
				Opt.TextSize = 12
				Opt.TextColor3 = Colors.Text
				Opt.BorderSizePixel = 0
				Instance.new("UICorner", Opt).CornerRadius = UDim.new(0, 4)
				Opt.MouseButton1Click:Connect(function()
					Current = v
					Button.Text = text..": "..v
					if callback then callback(v) end
					for _,c in ipairs(parent:GetChildren()) do
						if c ~= Button and c:IsA("TextButton") then c:Destroy() end
					end
					Open = false
				end)
			end
		else
			for _,c in ipairs(parent:GetChildren()) do
				if c ~= Button and c:IsA("TextButton") then c:Destroy() end
			end
		end
	end)
end

return Library
local Library = {}
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local Colors = {
	Background = Color3.fromRGB(18,18,18),
	ElementBg = Color3.fromRGB(28,28,28),
	SectionBg = Color3.fromRGB(22,22,22),
	Text = Color3.fromRGB(230,230,230),
	Accent = Color3.fromRGB(120,120,255)
}

function Library:CreateWindow(title, subtitle)
	local ScreenGui = Instance.new("ScreenGui", Players.LocalPlayer.PlayerGui)
	ScreenGui.ResetOnSpawn = false

	local Main = Instance.new("Frame", ScreenGui)
	Main.Size = UDim2.new(0, 620, 0, 420)
	Main.Position = UDim2.new(0.5, -310, 0.5, -210)
	Main.BackgroundColor3 = Colors.Background
	Main.BorderSizePixel = 0

	local Corner = Instance.new("UICorner", Main)
	Corner.CornerRadius = UDim.new(0, 8)

	local Top = Instance.new("TextLabel", Main)
	Top.Size = UDim2.new(1, 0, 0, 40)
	Top.BackgroundTransparency = 1
	Top.Text = title.."  |  "..subtitle
	Top.Font = Enum.Font.GothamBold
	Top.TextSize = 16
	Top.TextColor3 = Colors.Text

	local TabsFrame = Instance.new("Frame", Main)
	TabsFrame.Position = UDim2.new(0, 10, 0, 50)
	TabsFrame.Size = UDim2.new(0, 600, 0, 30)
	TabsFrame.BackgroundTransparency = 1

	local TabsLayout = Instance.new("UIListLayout", TabsFrame)
	TabsLayout.FillDirection = Enum.FillDirection.Horizontal
	TabsLayout.Padding = UDim.new(0, 6)

	local ContentFrame = Instance.new("Frame", Main)
	ContentFrame.Position = UDim2.new(0, 10, 0, 90)
	ContentFrame.Size = UDim2.new(0, 600, 0, 320)
	ContentFrame.BackgroundTransparency = 1

	local Window = {
		Gui = ScreenGui,
		Main = Main,
		TabContainer = TabsFrame,
		ContentFrame = ContentFrame,
		Tabs = {},
		CurrentTab = nil
	}

	UIS.InputBegan:Connect(function(i)
		if i.KeyCode == Enum.KeyCode.Delete then
			Main.Visible = not Main.Visible
		end
	end)

	return Window
end

function Library:CreateTab(Window, name)
	local Tab = {}

	local Button = Instance.new("TextButton", Window.TabContainer)
	Button.Size = UDim2.new(0, 90, 1, 0)
	Button.BackgroundColor3 = Colors.ElementBg
	Button.Text = name
	Button.Font = Enum.Font.Gotham
	Button.TextSize = 13
	Button.TextColor3 = Colors.Text
	Button.BorderSizePixel = 0

	Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

	local Content = Instance.new("Frame", Window.ContentFrame)
	Content.Size = UDim2.new(1, 0, 1, 0)
	Content.Visible = false
	Content.BackgroundTransparency = 1

	local Layout = Instance.new("UIListLayout", Content)
	Layout.Padding = UDim.new(0, 12)

	Button.MouseButton1Click:Connect(function()
		for _,t in ipairs(Window.Tabs) do
			t.Content.Visible = false
		end
		Content.Visible = true
		Window.CurrentTab = Tab
	end)

	Tab.Button = Button
	Tab.Content = Content

	table.insert(Window.Tabs, Tab)

	if not Window.CurrentTab then
		Content.Visible = true
		Window.CurrentTab = Tab
	end

	return Tab
end

function Library:AddWeaponCategory(Window, name)
	return self:CreateTab(Window, name)
end

function Library:CreateSection(Tab, name, height)
	local Section = Instance.new("Frame", Tab.Content)
	Section.Size = UDim2.new(1, 0, 0, height or 200)
	Section.BackgroundColor3 = Colors.SectionBg
	Section.BorderSizePixel = 0

	Instance.new("UICorner", Section).CornerRadius = UDim.new(0, 6)

	local Title = Instance.new("TextLabel", Section)
	Title.Size = UDim2.new(1, -10, 0, 24)
	Title.Position = UDim2.new(0, 5, 0, 4)
	Title.BackgroundTransparency = 1
	Title.Text = name
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 13
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.TextColor3 = Colors.Text

	local Holder = Instance.new("Frame", Section)
	Holder.Position = UDim2.new(0, 5, 0, 32)
	Holder.Size = UDim2.new(1, -10, 1, -36)
	Holder.BackgroundTransparency = 1

	local Layout = Instance.new("UIListLayout", Holder)
	Layout.Padding = UDim.new(0, 6)

	return Holder
end

function Library:CreateCheckbox(parent, text, default, callback)
	local Toggle = Instance.new("TextButton", parent)
	Toggle.Size = UDim2.new(1, 0, 0, 24)
	Toggle.BackgroundColor3 = Colors.ElementBg
	Toggle.Text = text
	Toggle.Font = Enum.Font.Gotham
	Toggle.TextSize = 12
	Toggle.TextColor3 = Colors.Text
	Toggle.BorderSizePixel = 0

	Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 4)

	local State = default

	Toggle.MouseButton1Click:Connect(function()
		State = not State
		Toggle.TextColor3 = State and Colors.Accent or Colors.Text
		if callback then callback(State) end
	end)
end

function Library:CreateSlider(parent, text, min, max, default, callback)
	local Frame = Instance.new("Frame", parent)
	Frame.Size = UDim2.new(1, 0, 0, 32)
	Frame.BackgroundTransparency = 1

	local Label = Instance.new("TextLabel", Frame)
	Label.Size = UDim2.new(1, 0, 0, 14)
	Label.BackgroundTransparency = 1
	Label.Text = text..": "..default
	Label.Font = Enum.Font.Gotham
	Label.TextSize = 12
	Label.TextColor3 = Colors.Text
	Label.TextXAlignment = Enum.TextXAlignment.Left

	local Bar = Instance.new("Frame", Frame)
	Bar.Position = UDim2.new(0, 0, 0, 18)
	Bar.Size = UDim2.new(1, 0, 0, 10)
	Bar.BackgroundColor3 = Colors.ElementBg
	Bar.BorderSizePixel = 0

	Instance.new("UICorner", Bar).CornerRadius = UDim.new(1, 0)

	local Fill = Instance.new("Frame", Bar)
	Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0)
	Fill.BackgroundColor3 = Colors.Accent
	Fill.BorderSizePixel = 0

	Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

	Bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then
			local move
			move = UIS.InputChanged:Connect(function(j)
				if j.UserInputType == Enum.UserInputType.MouseMovement then
					local pct = math.clamp((j.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
					local val = math.floor(min + (max-min)*pct)
					Fill.Size = UDim2.new(pct,0,1,0)
					Label.Text = text..": "..val
					if callback then callback(val) end
				end
			end)
			UIS.InputEnded:Once(function() move:Disconnect() end)
		end
	end)
end

function Library:CreateDropdown(parent, text, list, default, callback)
	local Button = Instance.new("TextButton", parent)
	Button.Size = UDim2.new(1, 0, 0, 24)
	Button.BackgroundColor3 = Colors.ElementBg
	Button.Text = text..": "..default
	Button.Font = Enum.Font.Gotham
	Button.TextSize = 12
	Button.TextColor3 = Colors.Text
	Button.BorderSizePixel = 0

	Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 4)

	local Open = false
	local Current = default

	Button.MouseButton1Click:Connect(function()
		Open = not Open
		if Open then
			for _,v in ipairs(list) do
				local Opt = Instance.new("TextButton", parent)
				Opt.Size = UDim2.new(1, 0, 0, 22)
				Opt.BackgroundColor3 = Colors.SectionBg
				Opt.Text = v
				Opt.Font = Enum.Font.Gotham
				Opt.TextSize = 12
				Opt.TextColor3 = Colors.Text
				Opt.BorderSizePixel = 0
				Instance.new("UICorner", Opt).CornerRadius = UDim.new(0, 4)
				Opt.MouseButton1Click:Connect(function()
					Current = v
					Button.Text = text..": "..v
					if callback then callback(v) end
					for _,c in ipairs(parent:GetChildren()) do
						if c ~= Button and c:IsA("TextButton") then c:Destroy() end
					end
					Open = false
				end)
			end
		else
			for _,c in ipairs(parent:GetChildren()) do
				if c ~= Button and c:IsA("TextButton") then c:Destroy() end
			end
		end
	end)
end

return Library
