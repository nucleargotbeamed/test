local Library = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Colors = {
	Background = Color3.fromRGB(45, 48, 57),
	Secondary = Color3.fromRGB(32, 32, 38),
	Accent = Color3.fromRGB(224, 159, 93),
	Border = Color3.fromRGB(0, 0, 0),
	DarkBorder = Color3.fromRGB(58, 58, 58),
	Text = Color3.fromRGB(255, 255, 255),
	TextSecondary = Color3.fromRGB(181, 183, 193),
	ElementBg = Color3.fromRGB(33, 36, 43),
	CheckboxBg = Color3.fromRGB(33, 33, 41),
}

local function CreateTween(object, properties, duration)
	local tween = TweenService:Create(object, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad), properties)
	tween:Play()
	return tween
end

local function MakeDraggable(frame, handle)
	local dragging = false
	local dragStart
	local startPos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

function Library:CreateWindow(title, subtitle)
	local Window = {}
	Window.Tabs = {}
	Window.CurrentTab = nil

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "OneTapUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = game:GetService("CoreGui")

	local MainFrame = Instance.new("Frame")
	MainFrame.Size = UDim2.new(0, 577, 0, 619)
	MainFrame.Position = UDim2.new(0.35, 0, 0.15, 0)
	MainFrame.BackgroundColor3 = Colors.Background
	MainFrame.BorderColor3 = Colors.Border
	MainFrame.BorderSizePixel = 1
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = ScreenGui

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 5)
	UICorner.Parent = MainFrame

	local ColorBar = Instance.new("Frame")
	ColorBar.Size = UDim2.new(1, 0, 0, 8)
	ColorBar.BackgroundColor3 = Colors.Accent
	ColorBar.BorderSizePixel = 0
	ColorBar.ZIndex = 2
	ColorBar.Parent = MainFrame

	local MenuBar = Instance.new("Frame")
	MenuBar.Size = UDim2.new(1, 0, 0, 60)
	MenuBar.Position = UDim2.new(0, 0, 0, 8)
	MenuBar.BackgroundColor3 = Colors.Background
	MenuBar.BorderSizePixel = 0
	MenuBar.Parent = MainFrame

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(0, 200, 0, 40)
	TitleLabel.Position = UDim2.new(0, 15, 0, 12)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = title
	TitleLabel.TextColor3 = Colors.Text
	TitleLabel.TextSize = 25
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = MenuBar

	local TabContainer = Instance.new("Frame")
	TabContainer.Size = UDim2.new(1, 0, 0, 40)
	TabContainer.Position = UDim2.new(0, 140, 0, 23)
	TabContainer.BackgroundTransparency = 1
	TabContainer.Parent = MainFrame

	local TabLayout = Instance.new("UIListLayout")
	TabLayout.FillDirection = Enum.FillDirection.Horizontal
	TabLayout.Padding = UDim.new(0, 5)
	TabLayout.Parent = TabContainer

	local ContentFrame = Instance.new("Frame")
	ContentFrame.Size = UDim2.new(0, 550, 0, 500)
	ContentFrame.Position = UDim2.new(0, 15, 0, 80)
	ContentFrame.BackgroundTransparency = 1
	ContentFrame.ClipsDescendants = true
	ContentFrame.Parent = MainFrame

	MakeDraggable(MainFrame, MenuBar)

	UserInputService.InputBegan:Connect(function(input, gp)
		if not gp and input.KeyCode == Enum.KeyCode.Delete then
			MainFrame.Visible = not MainFrame.Visible
		end
	end)

	Window.ScreenGui = ScreenGui
	Window.MainFrame = MainFrame
	Window.TabContainer = TabContainer
	Window.ContentFrame = ContentFrame

	return Window
end

function Library:CreateTab(Window, name)
	local Tab = {}

	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(0, 70, 0, 30)
	Button.BackgroundColor3 = Colors.ElementBg
	Button.BorderSizePixel = 0
	Button.Font = Enum.Font.Gotham
	Button.Text = name
	Button.TextColor3 = Colors.Text
	Button.TextSize = 14
	Button.AutoButtonColor = false
	Button.Parent = Window.TabContainer

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 5)
	Corner.Parent = Button

	local Content = Instance.new("Frame")
	Content.Size = UDim2.new(1, 0, 1, 0)
	Content.BackgroundTransparency = 1
	Content.Visible = false
	Content.Parent = Window.ContentFrame

	Button.MouseButton1Click:Connect(function()
		for _, t in pairs(Window.Tabs) do
			t.Content.Visible = false
			CreateTween(t.Button, {BackgroundColor3 = Colors.ElementBg}, 0.2)
		end
		Content.Visible = true
		CreateTween(Button, {BackgroundColor3 = Colors.Secondary}, 0.2)
	end)

	Tab.Button = Button
	Tab.Content = Content

	table.insert(Window.Tabs, Tab)

	if #Window.Tabs == 1 then
		Button:Activate()
		Content.Visible = true
	end

	return Tab
end

function Library:CreateSection(Tab, name, width)
	width = width or 215

	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(0, width, 0, 200)
	Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Frame.BackgroundTransparency = 1
	Frame.BorderColor3 = Colors.DarkBorder
	Frame.BorderSizePixel = 1
	Frame.Parent = Tab.Content

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -10, 0, 20)
	Title.Position = UDim2.new(0, 5, 0, -10)
	Title.BackgroundColor3 = Colors.Background
	Title.BorderSizePixel = 0
	Title.Font = Enum.Font.Gotham
	Title.Text = name
	Title.TextColor3 = Colors.Text
	Title.TextSize = 10
	Title.Parent = Frame

	local Container = Instance.new("Frame")
	Container.Size = UDim2.new(1, -10, 1, -20)
	Container.Position = UDim2.new(0, 5, 0, 15)
	Container.BackgroundTransparency = 1
	Container.Parent = Frame

	return {Frame = Frame, Container = Container}
end

function Library:CreateCheckbox(Section, name, default, callback)
	local value = default or false

	local Holder = Instance.new("Frame")
	Holder.Size = UDim2.new(1, 0, 0, 18)
	Holder.BackgroundTransparency = 1
	Holder.Parent = Section.Container

	local Box = Instance.new("TextButton")
	Box.Size = UDim2.new(0, 9, 0, 9)
	Box.Position = UDim2.new(0, 0, 0, 4)
	Box.BackgroundColor3 = Colors.CheckboxBg
	Box.BorderColor3 = Colors.Border
	Box.BorderSizePixel = 1
	Box.Text = ""
	Box.Parent = Holder

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -15, 1, 0)
	Label.Position = UDim2.new(0, 15, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Font = Enum.Font.Gotham
	Label.Text = name
	Label.TextColor3 = Colors.Text
	Label.TextSize = 10
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Holder

	local function Update()
		CreateTween(Box, {BackgroundColor3 = value and Colors.Accent or Colors.CheckboxBg}, 0.15)
		if callback then callback(value) end
	end

	Box.MouseButton1Click:Connect(function()
		value = not value
		Update()
	end)

	Update()

	return {
		SetValue = function(_, v)
			value = v
			Update()
		end
	}
end

return Library
