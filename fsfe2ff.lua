local function ry(so)
	game:GetService("VirtualInputManager"):SendMouseButtonEvent(so.AbsolutePosition.X+so.AbsoluteSize.X/2,so.AbsolutePosition.Y+50,0,true,so,1);
	game:GetService("VirtualInputManager"):SendMouseButtonEvent(so.AbsolutePosition.X+so.AbsoluteSize.X/2,so.AbsolutePosition.Y+50,0,false,so,1);
end;
repeat wait()
	if game.Players.LocalPlayer.Team == nil and game:GetService("Players")["LocalPlayer"].PlayerGui.Main.ChooseTeam.Visible == true then
		if _G.Teams == "Pirates" then
            ry(game:GetService("Players").LocalPlayer.PlayerGui.Main.ChooseTeam.Container.Pirates.Frame.TextButton)
		elseif _G.Teams == "Marine" then
			ry(game:GetService("Players").LocalPlayer.PlayerGui.Main.ChooseTeam.Container.Marines.Frame.TextButton)
		else
			ry(game:GetService("Players").LocalPlayer.PlayerGui.Main.ChooseTeam.Container.Pirates.Frame.TextButton)
		end
	end
until game.Players.LocalPlayer.Team ~= nil and game:IsLoaded()
wait(1)

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

local OrionLib = {
	Elements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
	Themes = {
		Default = {
			Main = Color3.fromRGB(25, 25, 25),
			Second = Color3.fromRGB(32, 32, 32),
			Stroke = Color3.fromRGB(60, 60, 60),
			Divider = Color3.fromRGB(60, 60, 60),
			Text = Color3.fromRGB(240, 240, 240),
			TextDark = Color3.fromRGB(150, 150, 150)
		}
	},
	SelectedTheme = "Default",
	Folder = nil,
	SaveCfg = false
}

--Feather Icons https://github.com/evoincorp/lucideblox/tree/master/src/modules/util - Created by 7kayoh
local Icons = {}

local Success, Response = pcall(function()
	Icons = HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json")).icons
end)

if not Success then
	warn("\nOrion Library - Failed to load Feather Icons. Error code: " .. Response .. "\n")
end	

local function GetIcon(IconName)
	if Icons[IconName] ~= nil then
		return Icons[IconName]
	else
		return nil
	end
end   

local Orion = Instance.new("ScreenGui")
Orion.Name = "Orion"
if syn then
	syn.protect_gui(Orion)
	Orion.Parent = game.CoreGui
else
	Orion.Parent = gethui() or game.CoreGui
end

if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
else
	for _, Interface in ipairs(game.CoreGui:GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
end

function OrionLib:IsRunning()
	if gethui then
		return Orion.Parent == gethui()
	else
		return Orion.Parent == game:GetService("CoreGui")
	end

end

local function AddConnection(Signal, Function)
	if (not OrionLib:IsRunning()) then
		return
	end
	local SignalConnect = Signal:Connect(Function)
	table.insert(OrionLib.Connections, SignalConnect)
	return SignalConnect
end

task.spawn(function()
	while (OrionLib:IsRunning()) do
		wait()
	end

	for _, Connection in next, OrionLib.Connections do
		Connection:Disconnect()
	end
end)

local function MakeDraggable(DragPoint, Main)
	pcall(function()
		local Dragging, DragInput, MousePos, FramePos = false
		AddConnection(DragPoint.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position

				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)
		AddConnection(DragPoint.InputChanged, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement then
				DragInput = Input
			end
		end)
		AddConnection(UserInputService.InputChanged, function(Input)
			if Input == DragInput and Dragging then
				local Delta = Input.Position - MousePos
				--TweenService:Create(Main, TweenInfo.new(0.05, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position  = UDim2.new(FramePos.X.Scale,FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)}):Play()
				Main.Position  = UDim2.new(FramePos.X.Scale,FramePos.X.Offset + Delta.X, FramePos.Y.Scale, FramePos.Y.Offset + Delta.Y)
			end
		end)
	end)
end    

local function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do
		Object[i] = v
	end
	for i, v in next, Children or {} do
		v.Parent = Object
	end
	return Object
end

local function CreateElement(ElementName, ElementFunction)
	OrionLib.Elements[ElementName] = function(...)
		return ElementFunction(...)
	end
end

local function MakeElement(ElementName, ...)
	local NewElement = OrionLib.Elements[ElementName](...)
	return NewElement
end

local function SetProps(Element, Props)
	table.foreach(Props, function(Property, Value)
		Element[Property] = Value
	end)
	return Element
end

local function SetChildren(Element, Children)
	table.foreach(Children, function(_, Child)
		Child.Parent = Element
	end)
	return Element
end

local function Round(Number, Factor)
	local Result = math.floor(Number/Factor + (math.sign(Number) * 0.5)) * Factor
	if Result < 0 then Result = Result + Factor end
	return Result
end

local function ReturnProperty(Object)
	if Object:IsA("Frame") or Object:IsA("TextButton") then
		return "BackgroundColor3"
	end 
	if Object:IsA("ScrollingFrame") then
		return "ScrollBarImageColor3"
	end 
	if Object:IsA("UIStroke") then
		return "Color"
	end 
	if Object:IsA("TextLabel") or Object:IsA("TextBox") then
		return "TextColor3"
	end   
	if Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
		return "ImageColor3"
	end   
end

local function AddThemeObject(Object, Type)
	if not OrionLib.ThemeObjects[Type] then
		OrionLib.ThemeObjects[Type] = {}
	end    
	table.insert(OrionLib.ThemeObjects[Type], Object)
	Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Type]
	return Object
end    

local function SetTheme()
	for Name, Type in pairs(OrionLib.ThemeObjects) do
		for _, Object in pairs(Type) do
			Object[ReturnProperty(Object)] = OrionLib.Themes[OrionLib.SelectedTheme][Name]
		end    
	end    
end

local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end    

local function UnpackColor(Color)
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadCfg(Config)
	local Data = HttpService:JSONDecode(Config)
	table.foreach(Data, function(a,b)
		if OrionLib.Flags[a] then
			spawn(function() 
				if OrionLib.Flags[a].Type == "Colorpicker" then
					OrionLib.Flags[a]:Set(UnpackColor(b))
				else
					OrionLib.Flags[a]:Set(b)
				end    
			end)
		else
			warn("Orion Library Config Loader - Could not find ", a ,b)
		end
	end)
end

local function SaveCfg(Name)
	local Data = {}
	for i,v in pairs(OrionLib.Flags) do
		if v.Save then
			if v.Type == "Colorpicker" then
				Data[i] = PackColor(v.Value)
			else
				Data[i] = v.Value
			end
		end	
	end
	writefile(OrionLib.Folder .. "/" .. Name .. ".txt", tostring(HttpService:JSONEncode(Data)))
end

local WhitelistedMouse = {Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2,Enum.UserInputType.MouseButton3}
local BlacklistedKeys = {Enum.KeyCode.Unknown,Enum.KeyCode.W,Enum.KeyCode.A,Enum.KeyCode.S,Enum.KeyCode.D,Enum.KeyCode.Up,Enum.KeyCode.Left,Enum.KeyCode.Down,Enum.KeyCode.Right,Enum.KeyCode.Slash,Enum.KeyCode.Tab,Enum.KeyCode.Backspace,Enum.KeyCode.Escape}

local function CheckKey(Table, Key)
	for _, v in next, Table do
		if v == Key then
			return true
		end
	end
end

CreateElement("Corner", function(Scale, Offset)
	local Corner = Create("UICorner", {
		CornerRadius = UDim.new(Scale or 0, Offset or 10)
	})
	return Corner
end)

CreateElement("Stroke", function(Color, Thickness)
	local Stroke = Create("UIStroke", {
		Color = Color or Color3.fromRGB(255, 255, 255),
		Thickness = Thickness or 1
	})
	return Stroke
end)

CreateElement("List", function(Scale, Offset)
	local List = Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(Scale or 0, Offset or 0)
	})
	return List
end)

CreateElement("Padding", function(Bottom, Left, Right, Top)
	local Padding = Create("UIPadding", {
		PaddingBottom = UDim.new(0, Bottom or 4),
		PaddingLeft = UDim.new(0, Left or 4),
		PaddingRight = UDim.new(0, Right or 4),
		PaddingTop = UDim.new(0, Top or 4)
	})
	return Padding
end)

CreateElement("TFrame", function()
	local TFrame = Create("Frame", {
		BackgroundTransparency = 1
	})
	return TFrame
end)

CreateElement("Frame", function(Color)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	})
	return Frame
end)

CreateElement("RoundFrame", function(Color, Scale, Offset)
	local Frame = Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	}, {
		Create("UICorner", {
			CornerRadius = UDim.new(Scale, Offset)
		})
	})
	return Frame
end)

CreateElement("Button", function()
	local Button = Create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
	return Button
end)

CreateElement("ScrollFrame", function(Color, Width)
	local ScrollFrame = Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		MidImage = "rbxassetid://7445543667",
		BottomImage = "rbxassetid://7445543667",
		TopImage = "rbxassetid://7445543667",
		ScrollBarImageColor3 = Color,
		BorderSizePixel = 0,
		ScrollBarThickness = Width,
		CanvasSize = UDim2.new(0, 0, 0, 0)
	})
	return ScrollFrame
end)

CreateElement("Image", function(ImageID)
	local ImageNew = Create("ImageLabel", {
		Image = ImageID,
		BackgroundTransparency = 1
	})

	if GetIcon(ImageID) ~= nil then
		ImageNew.Image = GetIcon(ImageID)
	end	

	return ImageNew
end)

CreateElement("ImageButton", function(ImageID)
	local Image = Create("ImageButton", {
		Image = ImageID,
		BackgroundTransparency = 1
	})
	return Image
end)

CreateElement("Label", function(Text, TextSize, Transparency)
	local Label = Create("TextLabel", {
		Text = Text or "",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = Transparency or 0,
		TextSize = TextSize or 15,
		Font = Enum.Font.Gotham,
		RichText = true,
		BackgroundTransparency = 1,
		TextXAlignment = Enum.TextXAlignment.Left
	})
	return Label
end)

local NotificationHolder = SetProps(SetChildren(MakeElement("TFrame"), {
	SetProps(MakeElement("List"), {
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 5)
	})
}), {
	Position = UDim2.new(1, -25, 1, -25),
	Size = UDim2.new(0, 300, 1, -25),
	AnchorPoint = Vector2.new(1, 1),
	Parent = Orion
})

function OrionLib:MakeNotification(NotificationConfig)
	spawn(function()
		NotificationConfig.Name = NotificationConfig.Name or "Notification"
		NotificationConfig.Content = NotificationConfig.Content or "Test"
		NotificationConfig.Image = NotificationConfig.Image or "rbxassetid://4384403532"
		NotificationConfig.Time = NotificationConfig.Time or 15

		local NotificationParent = SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = NotificationHolder
		})

		local NotificationFrame = SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(25, 25, 25), 0, 10), {
			Parent = NotificationParent, 
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(1, -55, 0, 0),
			BackgroundTransparency = 0,
			AutomaticSize = Enum.AutomaticSize.Y
		}), {
			MakeElement("Stroke", Color3.fromRGB(93, 93, 93), 1.2),
			MakeElement("Padding", 12, 12, 12, 12),
			SetProps(MakeElement("Image", NotificationConfig.Image), {
				Size = UDim2.new(0, 20, 0, 20),
				ImageColor3 = Color3.fromRGB(240, 240, 240),
				Name = "Icon"
			}),
			SetProps(MakeElement("Label", NotificationConfig.Name, 15), {
				Size = UDim2.new(1, -30, 0, 20),
				Position = UDim2.new(0, 30, 0, 0),
				Font = Enum.Font.GothamBold,
				Name = "Title"
			}),
			SetProps(MakeElement("Label", NotificationConfig.Content, 14), {
				Size = UDim2.new(1, 0, 0, 0),
				Position = UDim2.new(0, 0, 0, 25),
				Font = Enum.Font.GothamSemibold,
				Name = "Content",
				AutomaticSize = Enum.AutomaticSize.Y,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextWrapped = true
			})
		})

		TweenService:Create(NotificationFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 0, 0, 0)}):Play()

		wait(NotificationConfig.Time - 0.88)
		TweenService:Create(NotificationFrame.Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageTransparency = 1}):Play()
		TweenService:Create(NotificationFrame, TweenInfo.new(0.8, Enum.EasingStyle.Quint), {BackgroundTransparency = 0.6}):Play()
		wait(0.3)
		TweenService:Create(NotificationFrame.UIStroke, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {Transparency = 0.9}):Play()
		TweenService:Create(NotificationFrame.Title, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.4}):Play()
		TweenService:Create(NotificationFrame.Content, TweenInfo.new(0.6, Enum.EasingStyle.Quint), {TextTransparency = 0.5}):Play()
		wait(0.05)

		NotificationFrame:TweenPosition(UDim2.new(1, 20, 0, 0),'In','Quint',0.8,true)
		wait(1.35)
		NotificationFrame:Destroy()
	end)
end    

function OrionLib:Init()
	if OrionLib.SaveCfg then	
		pcall(function()
			if isfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt") then
				LoadCfg(readfile(OrionLib.Folder .. "/" .. game.GameId .. ".txt"))
				OrionLib:MakeNotification({
					Name = "Configuration",
					Content = "Auto-loaded configuration for the game " .. game.GameId .. ".",
					Time = 5
				})
			end
		end)		
	end	
end	

function OrionLib:MakeWindow(WindowConfig)
	local FirstTab = true
	local Minimized = false
	local Loaded = false
	local UIHidden = false

	WindowConfig = WindowConfig or {}
	WindowConfig.Name = WindowConfig.Name or "Seraphy Premium"
	WindowConfig.ConfigFolder = WindowConfig.ConfigFolder or WindowConfig.Name
	WindowConfig.SaveConfig = WindowConfig.SaveConfig or false
	WindowConfig.HidePremium = WindowConfig.HidePremium or false
	if WindowConfig.IntroEnabled == nil then
		WindowConfig.IntroEnabled = true
	end
	WindowConfig.IntroText = WindowConfig.IntroText or "Seraphy Premium"
	WindowConfig.CloseCallback = WindowConfig.CloseCallback or function() end
	WindowConfig.ShowIcon = WindowConfig.ShowIcon or false
	WindowConfig.Icon = WindowConfig.Icon or "rbxassetid://8834748103"
	WindowConfig.IntroIcon = WindowConfig.IntroIcon or "rbxassetid://8834748103"
	OrionLib.Folder = WindowConfig.ConfigFolder
	OrionLib.SaveCfg = WindowConfig.SaveConfig

	if WindowConfig.SaveConfig then
		if not isfolder(WindowConfig.ConfigFolder) then
			makefolder(WindowConfig.ConfigFolder)
		end	
	end

	local TabHolder = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 4), {
		Size = UDim2.new(1, 0, 1, -50)
	}), {
		MakeElement("List"),
		MakeElement("Padding", 8, 0, 0, 8)
	}), "Divider")

	AddConnection(TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
		TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 16)
	end)

	local CloseBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072725342"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18)
		}), "Text")
	})

	local MinimizeBtn = SetChildren(SetProps(MakeElement("Button"), {
		Size = UDim2.new(0.5, 0, 1, 0),
		BackgroundTransparency = 1
	}), {
		AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072719338"), {
			Position = UDim2.new(0, 9, 0, 6),
			Size = UDim2.new(0, 18, 0, 18),
			Name = "Ico"
		}), "Text")
	})

	local DragPoint = SetProps(MakeElement("TFrame"), {
		Size = UDim2.new(1, 0, 0, 50)
	})

	local WindowStuff = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
		Size = UDim2.new(0, 150, 1, -50),
		Position = UDim2.new(0, 0, 0, 50)
	}), {
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(1, 0, 0, 10),
			Position = UDim2.new(0, 0, 0, 0)
		}), "Second"), 
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(0, 10, 1, 0),
			Position = UDim2.new(1, -10, 0, 0)
		}), "Second"), 
		AddThemeObject(SetProps(MakeElement("Frame"), {
			Size = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(1, -1, 0, 0)
		}), "Stroke"), 
		TabHolder,
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 50),
			Position = UDim2.new(0, 0, 1, -50)
		}), {
			AddThemeObject(SetProps(MakeElement("Frame"), {
				Size = UDim2.new(1, 0, 0, 1)
			}), "Stroke"), 
			AddThemeObject(SetChildren(SetProps(MakeElement("Frame"), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 32, 0, 32),
				Position = UDim2.new(0, 10, 0.5, 0)
			}), {
				SetProps(MakeElement("Image", "https://www.roblox.com/headshot-thumbnail/image?userId=".. LocalPlayer.UserId .."&width=420&height=420&format=png"), {
					Size = UDim2.new(1, 0, 1, 0)
				}),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4031889928"), {
					Size = UDim2.new(1, 0, 1, 0),
				}), "Second"),
				MakeElement("Corner", 1)
			}), "Divider"),
			SetChildren(SetProps(MakeElement("TFrame"), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 32, 0, 32),
				Position = UDim2.new(0, 10, 0.5, 0)
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				MakeElement("Corner", 1)
			}),
			AddThemeObject(SetProps(MakeElement("Label", LocalPlayer.DisplayName, WindowConfig.HidePremium and 14 or 13), {
				Size = UDim2.new(1, -60, 0, 13),
				Position = WindowConfig.HidePremium and UDim2.new(0, 50, 0, 19) or UDim2.new(0, 50, 0, 12),
				Font = Enum.Font.GothamBold,
				ClipsDescendants = true
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", "", 12), {
				Size = UDim2.new(1, -60, 0, 12),
				Position = UDim2.new(0, 50, 1, -25),
				Visible = not WindowConfig.HidePremium
			}), "TextDark")
		}),
	}), "Second")

	local WindowName = AddThemeObject(SetProps(MakeElement("Label", WindowConfig.Name, 14), {
		Size = UDim2.new(1, -30, 2, 0),
		Position = UDim2.new(0, 25, 0, -24),
		Font = Enum.Font.GothamBlack,
		TextSize = 20
	}), "Text")

	local WindowTopBarLine = AddThemeObject(SetProps(MakeElement("Frame"), {
		Size = UDim2.new(1, 0, 0, 1),
		Position = UDim2.new(0, 0, 1, -1)
	}), "Stroke")

	local MainWindow = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 10), {
		Parent = Orion,
		Position = UDim2.new(0.5, -307, 0.5, -172),
		Size = UDim2.new(0, 615, 0, 344),
		ClipsDescendants = true
	}), {
		--SetProps(MakeElement("Image", "rbxassetid://3523728077"), {
		--	AnchorPoint = Vector2.new(0.5, 0.5),
		--	Position = UDim2.new(0.5, 0, 0.5, 0),
		--	Size = UDim2.new(1, 80, 1, 320),
		--	ImageColor3 = Color3.fromRGB(33, 33, 33),
		--	ImageTransparency = 0.7
		--}),
		SetChildren(SetProps(MakeElement("TFrame"), {
			Size = UDim2.new(1, 0, 0, 50),
			Name = "TopBar"
		}), {
			WindowName,
			WindowTopBarLine,
			AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 7), {
				Size = UDim2.new(0, 70, 0, 30),
				Position = UDim2.new(1, -90, 0, 10)
			}), {
				AddThemeObject(MakeElement("Stroke"), "Stroke"),
				AddThemeObject(SetProps(MakeElement("Frame"), {
					Size = UDim2.new(0, 1, 1, 0),
					Position = UDim2.new(0.5, 0, 0, 0)
				}), "Stroke"), 
				CloseBtn,
				MinimizeBtn
			}), "Second"), 
		}),
		DragPoint,
		WindowStuff
	}), "Main")

	if WindowConfig.ShowIcon then
		WindowName.Position = UDim2.new(0, 50, 0, -24)
		local WindowIcon = SetProps(MakeElement("Image", WindowConfig.Icon), {
			Size = UDim2.new(0, 20, 0, 20),
			Position = UDim2.new(0, 25, 0, 15)
		})
		WindowIcon.Parent = MainWindow.TopBar
	end	

	MakeDraggable(DragPoint, MainWindow)

	AddConnection(CloseBtn.MouseButton1Up, function()
		MainWindow.Visible = false
		UIHidden = true
		OrionLib:MakeNotification({
			Name = "Interface Hidden",
			Content = "Tap RightShift to reopen the interface",
			Time = 5
		})
		WindowConfig.CloseCallback()
	end)

	AddConnection(UserInputService.InputBegan, function(Input)
		if Input.KeyCode == Enum.KeyCode.RightShift and UIHidden then
			MainWindow.Visible = true
		end
	end)

	AddConnection(MinimizeBtn.MouseButton1Up, function()
		if Minimized then
			TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, 615, 0, 344)}):Play()
			MinimizeBtn.Ico.Image = "rbxassetid://7072719338"
			wait(.02)
			MainWindow.ClipsDescendants = false
			WindowStuff.Visible = true
			WindowTopBarLine.Visible = true
		else
			MainWindow.ClipsDescendants = true
			WindowTopBarLine.Visible = false
			MinimizeBtn.Ico.Image = "rbxassetid://7072720870"

			TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, WindowName.TextBounds.X + 140, 0, 50)}):Play()
			wait(0.1)
			WindowStuff.Visible = false	
		end
		Minimized = not Minimized    
	end)

	local function LoadSequence()
		MainWindow.Visible = false
		local LoadSequenceLogo = SetProps(MakeElement("Image", WindowConfig.IntroIcon), {
			Parent = Orion,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.4, 0),
			Size = UDim2.new(0, 28, 0, 28),
			ImageColor3 = Color3.fromRGB(255, 255, 255),
			ImageTransparency = 1
		})

		local LoadSequenceText = SetProps(MakeElement("Label", WindowConfig.IntroText, 14), {
			Parent = Orion,
			Size = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 19, 0.5, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
			Font = Enum.Font.GothamBold,
			TextTransparency = 1
		})

		TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0)}):Play()
		wait(0.8)
		TweenService:Create(LoadSequenceLogo, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, -(LoadSequenceText.TextBounds.X/2), 0.5, 0)}):Play()
		wait(0.3)
		TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
		wait(2)
		TweenService:Create(LoadSequenceText, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 1}):Play()
		MainWindow.Visible = true
		LoadSequenceLogo:Destroy()
		LoadSequenceText:Destroy()
	end 

	if WindowConfig.IntroEnabled then
		LoadSequence()
	end	

	local TabFunction = {}
	function TabFunction:MakeTab(TabConfig)
		TabConfig = TabConfig or {}
		TabConfig.Name = TabConfig.Name or "Tab"
		TabConfig.Icon = TabConfig.Icon or ""
		TabConfig.PremiumOnly = TabConfig.PremiumOnly or false

		local TabFrame = SetChildren(SetProps(MakeElement("Button"), {
			Size = UDim2.new(1, 0, 0, 30),
			Parent = TabHolder
		}), {
			AddThemeObject(SetProps(MakeElement("Image", TabConfig.Icon), {
				AnchorPoint = Vector2.new(0, 0.5),
				Size = UDim2.new(0, 18, 0, 18),
				Position = UDim2.new(0, 10, 0.5, 0),
				ImageTransparency = 0.4,
				Name = "Ico"
			}), "Text"),
			AddThemeObject(SetProps(MakeElement("Label", TabConfig.Name, 14), {
				Size = UDim2.new(1, -35, 1, 0),
				Position = UDim2.new(0, 35, 0, 0),
				Font = Enum.Font.GothamSemibold,
				TextTransparency = 0.4,
				Name = "Title"
			}), "Text")
		})

		if GetIcon(TabConfig.Icon) ~= nil then
			TabFrame.Ico.Image = GetIcon(TabConfig.Icon)
		end	

		local Container = AddThemeObject(SetChildren(SetProps(MakeElement("ScrollFrame", Color3.fromRGB(255, 255, 255), 5), {
			Size = UDim2.new(1, -150, 1, -50),
			Position = UDim2.new(0, 150, 0, 50),
			Parent = MainWindow,
			Visible = false,
			Name = "ItemContainer"
		}), {
			MakeElement("List", 0, 6),
			MakeElement("Padding", 15, 10, 10, 15)
		}), "Divider")

		AddConnection(Container.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
			Container.CanvasSize = UDim2.new(0, 0, 0, Container.UIListLayout.AbsoluteContentSize.Y + 30)
		end)

		if FirstTab then
			FirstTab = false
			TabFrame.Ico.ImageTransparency = 0
			TabFrame.Title.TextTransparency = 0
			TabFrame.Title.Font = Enum.Font.GothamBlack
			Container.Visible = true
		end    

		AddConnection(TabFrame.MouseButton1Click, function()
			for _, Tab in next, TabHolder:GetChildren() do
				if Tab:IsA("TextButton") then
					Tab.Title.Font = Enum.Font.GothamSemibold
					TweenService:Create(Tab.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0.4}):Play()
					TweenService:Create(Tab.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0.4}):Play()
				end    
			end
			for _, ItemContainer in next, MainWindow:GetChildren() do
				if ItemContainer.Name == "ItemContainer" then
					ItemContainer.Visible = false
				end    
			end  
			TweenService:Create(TabFrame.Ico, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
			TweenService:Create(TabFrame.Title, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
			TabFrame.Title.Font = Enum.Font.GothamBlack
			Container.Visible = true   
		end)

		local function GetElements(ItemParent)
			local ElementFunction = {}
			function ElementFunction:AddLabel(Text)
				local LabelFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")

				local LabelFunction = {}
				function LabelFunction:Set(ToChange)
					LabelFrame.Content.Text = ToChange
				end
				return LabelFunction
			end
			function ElementFunction:AddParagraph(Text, Content)
				Text = Text or "Text"
				Content = Content or "Content"

				local ParagraphFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundTransparency = 0.7,
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", Text, 15), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 10),
						Font = Enum.Font.GothamBold,
						Name = "Title"
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Label", "", 13), {
						Size = UDim2.new(1, -24, 0, 0),
						Position = UDim2.new(0, 12, 0, 26),
						Font = Enum.Font.GothamSemibold,
						Name = "Content",
						TextWrapped = true
					}), "TextDark"),
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Second")

				AddConnection(ParagraphFrame.Content:GetPropertyChangedSignal("Text"), function()
					ParagraphFrame.Content.Size = UDim2.new(1, -24, 0, ParagraphFrame.Content.TextBounds.Y)
					ParagraphFrame.Size = UDim2.new(1, 0, 0, ParagraphFrame.Content.TextBounds.Y + 35)
				end)

				ParagraphFrame.Content.Text = Content

				local ParagraphFunction = {}
				function ParagraphFunction:Set(ToChange)
					ParagraphFrame.Content.Text = ToChange
				end
				return ParagraphFunction
			end    
			function ElementFunction:AddButton(ButtonConfig)
				ButtonConfig = ButtonConfig or {}
				ButtonConfig.Name = ButtonConfig.Name or "Button"
				ButtonConfig.Callback = ButtonConfig.Callback or function() end
				ButtonConfig.Icon = ButtonConfig.Icon or "rbxassetid://3944703587"

				local Button = {}

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local ButtonFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 33),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ButtonConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(SetProps(MakeElement("Image", ButtonConfig.Icon), {
						Size = UDim2.new(0, 20, 0, 20),
						Position = UDim2.new(1, -30, 0, 7),
					}), "TextDark"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					Click
				}), "Second")

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseLeave, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)

				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
					spawn(function()
						ButtonConfig.Callback()
					end)
				end)

				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(ButtonFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)

				function Button:Set(ButtonText)
					ButtonFrame.Content.Text = ButtonText
				end	

				return Button
			end    
			function ElementFunction:AddToggle(ToggleConfig)
				ToggleConfig = ToggleConfig or {}
				ToggleConfig.Name = ToggleConfig.Name or "Toggle"
				ToggleConfig.Default = ToggleConfig.Default or false
				ToggleConfig.Callback = ToggleConfig.Callback or function() end
				ToggleConfig.Color = ToggleConfig.Color or Color3.fromRGB(9, 99, 195)
				ToggleConfig.Flag = ToggleConfig.Flag or nil
				ToggleConfig.Save = ToggleConfig.Save or false

				local Toggle = {Value = ToggleConfig.Default, Save = ToggleConfig.Save}

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local ToggleBox = SetChildren(SetProps(MakeElement("RoundFrame", ToggleConfig.Color, 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -24, 0.5, 0),
					AnchorPoint = Vector2.new(0.5, 0.5)
				}), {
					SetProps(MakeElement("Stroke"), {
						Color = ToggleConfig.Color,
						Name = "Stroke",
						Transparency = 0.5
					}),
					SetProps(MakeElement("Image", "rbxassetid://3944680095"), {
						Size = UDim2.new(0, 20, 0, 20),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.new(0.5, 0, 0.5, 0),
						ImageColor3 = Color3.fromRGB(255, 255, 255),
						Name = "Ico"
					}),
				})

				local ToggleFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", ToggleConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					ToggleBox,
					Click
				}), "Second")

				function Toggle:Set(Value)
					Toggle.Value = Value
					TweenService:Create(ToggleBox, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Toggle.Value and ToggleConfig.Color or OrionLib.Themes.Default.Divider}):Play()
					TweenService:Create(ToggleBox.Stroke, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Color = Toggle.Value and ToggleConfig.Color or OrionLib.Themes.Default.Stroke}):Play()
					TweenService:Create(ToggleBox.Ico, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {ImageTransparency = Toggle.Value and 0 or 1, Size = Toggle.Value and UDim2.new(0, 20, 0, 20) or UDim2.new(0, 8, 0, 8)}):Play()
					ToggleConfig.Callback(Toggle.Value)
				end    

				Toggle:Set(Toggle.Value)

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseLeave, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)

				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
					SaveCfg(game.GameId)
					Toggle:Set(not Toggle.Value)
				end)

				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(ToggleFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)

				if ToggleConfig.Flag then
					OrionLib.Flags[ToggleConfig.Flag] = Toggle
				end	
				return Toggle
			end  
			function ElementFunction:AddSlider(SliderConfig)
				SliderConfig = SliderConfig or {}
				SliderConfig.Name = SliderConfig.Name or "Slider"
				SliderConfig.Min = SliderConfig.Min or 0
				SliderConfig.Max = SliderConfig.Max or 100
				SliderConfig.Increment = SliderConfig.Increment or 1
				SliderConfig.Default = SliderConfig.Default or 50
				SliderConfig.Callback = SliderConfig.Callback or function() end
				SliderConfig.ValueName = SliderConfig.ValueName or ""
				SliderConfig.Color = SliderConfig.Color or Color3.fromRGB(9, 149, 98)
				SliderConfig.Flag = SliderConfig.Flag or nil
				SliderConfig.Save = SliderConfig.Save or false

				local Slider = {Value = SliderConfig.Default, Save = SliderConfig.Save}
				local Dragging = false

				local SliderDrag = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 5), {
					Size = UDim2.new(0, 0, 1, 0),
					BackgroundTransparency = 0.3,
					ClipsDescendants = true
				}), {
					AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 6),
						Font = Enum.Font.GothamBold,
						Name = "Value",
						TextTransparency = 0
					}), "Text")
				})

				local SliderBar = SetChildren(SetProps(MakeElement("RoundFrame", SliderConfig.Color, 0, 5), {
					Size = UDim2.new(1, -24, 0, 26),
					Position = UDim2.new(0, 12, 0, 30),
					BackgroundTransparency = 0.9
				}), {
					SetProps(MakeElement("Stroke"), {
						Color = SliderConfig.Color
					}),
					AddThemeObject(SetProps(MakeElement("Label", "value", 13), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 6),
						Font = Enum.Font.GothamBold,
						Name = "Value",
						TextTransparency = 0.8
					}), "Text"),
					SliderDrag
				})

				local SliderFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(1, 0, 0, 65),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", SliderConfig.Name, 15), {
						Size = UDim2.new(1, -12, 0, 14),
						Position = UDim2.new(0, 12, 0, 10),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					SliderBar
				}), "Second")

				SliderBar.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then 
						Dragging = true 
					end 
				end)
				SliderBar.InputEnded:Connect(function(Input) 
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then 
						Dragging = false 
					end 
				end)

				UserInputService.InputChanged:Connect(function(Input)
					if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then 
						local SizeScale = math.clamp((Input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
						Slider:Set(SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * SizeScale)) 
						SaveCfg(game.GameId)
					end
				end)

				function Slider:Set(Value)
					self.Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
					TweenService:Create(SliderDrag,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = UDim2.fromScale((self.Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 1)}):Play()
					SliderBar.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
					SliderDrag.Value.Text = tostring(self.Value) .. " " .. SliderConfig.ValueName
					SliderConfig.Callback(self.Value)
				end      

				Slider:Set(Slider.Value)
				if SliderConfig.Flag then				
					OrionLib.Flags[SliderConfig.Flag] = Slider
				end
				return Slider
			end  
			function ElementFunction:AddDropdown(DropdownConfig)
				DropdownConfig = DropdownConfig or {}
				DropdownConfig.Name = DropdownConfig.Name or "Dropdown"
				DropdownConfig.Options = DropdownConfig.Options or {}
				DropdownConfig.Default = DropdownConfig.Default or ""
				DropdownConfig.Callback = DropdownConfig.Callback or function() end
				DropdownConfig.Flag = DropdownConfig.Flag or nil
				DropdownConfig.Save = DropdownConfig.Save or false

				local Dropdown = {Value = DropdownConfig.Default, Options = DropdownConfig.Options, Buttons = {}, Toggled = false, Type = "Dropdown", Save = DropdownConfig.Save}
				local MaxElements = 5

				if not table.find(Dropdown.Options, Dropdown.Value) then
					Dropdown.Value = "..."
				end

				local DropdownList = MakeElement("List")

				local DropdownContainer = AddThemeObject(SetProps(SetChildren(MakeElement("ScrollFrame", Color3.fromRGB(40, 40, 40), 4), {
					DropdownList
				}), {
					Parent = ItemParent,
					Position = UDim2.new(0, 0, 0, 38),
					Size = UDim2.new(1, 0, 1, -38),
					ClipsDescendants = true
				}), "Divider")

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local DropdownFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent,
					ClipsDescendants = true
				}), {
					DropdownContainer,
					SetProps(SetChildren(MakeElement("TFrame"), {
						AddThemeObject(SetProps(MakeElement("Label", DropdownConfig.Name, 15), {
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font = Enum.Font.GothamBold,
							Name = "Content"
						}), "Text"),
						AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://7072706796"), {
							Size = UDim2.new(0, 20, 0, 20),
							AnchorPoint = Vector2.new(0, 0.5),
							Position = UDim2.new(1, -30, 0.5, 0),
							ImageColor3 = Color3.fromRGB(240, 240, 240),
							Name = "Ico"
						}), "TextDark"),
						AddThemeObject(SetProps(MakeElement("Label", "Selected", 13), {
							Size = UDim2.new(1, -40, 1, 0),
							Font = Enum.Font.Gotham,
							Name = "Selected",
							TextXAlignment = Enum.TextXAlignment.Right
						}), "TextDark"),
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name = "Line",
							Visible = false
						}), "Stroke"), 
						Click
					}), {
						Size = UDim2.new(1, 0, 0, 38),
						ClipsDescendants = true,
						Name = "F"
					}),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					MakeElement("Corner")
				}), "Second")

				AddConnection(DropdownList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
					DropdownContainer.CanvasSize = UDim2.new(0, 0, 0, DropdownList.AbsoluteContentSize.Y)
				end)  

				local function AddOptions(Options)
					for _, Option in pairs(Options) do
						local OptionBtn = AddThemeObject(SetProps(SetChildren(MakeElement("Button", Color3.fromRGB(40, 40, 40)), {
							MakeElement("Corner", 0, 6),
							AddThemeObject(SetProps(MakeElement("Label", Option, 13, 0.4), {
								Position = UDim2.new(0, 8, 0, 0),
								Size = UDim2.new(1, -8, 1, 0),
								Name = "Title"
							}), "Text")
						}), {
							Parent = DropdownContainer,
							Size = UDim2.new(1, 0, 0, 28),
							BackgroundTransparency = 1,
							ClipsDescendants = true
						}), "Divider")

						AddConnection(OptionBtn.MouseButton1Click, function()
							Dropdown:Set(Option)
							SaveCfg(game.GameId)
						end)

						Dropdown.Buttons[Option] = OptionBtn
					end
				end	

				function Dropdown:Refresh(Options, Delete)
					if Delete then
						for _,v in pairs(Dropdown.Buttons) do
							v:Destroy()
						end    
						table.clear(Dropdown.Options)
						table.clear(Dropdown.Buttons)
					end
					Dropdown.Options = Options
					AddOptions(Dropdown.Options)
				end  

				function Dropdown:Set(Value)
					if not table.find(Dropdown.Options, Value) then
						Dropdown.Value = "..."
						DropdownFrame.F.Selected.Text = Dropdown.Value
						for _, v in pairs(Dropdown.Buttons) do
							TweenService:Create(v,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{BackgroundTransparency = 1}):Play()
							TweenService:Create(v.Title,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{TextTransparency = 0.4}):Play()
						end	
						return
					end

					Dropdown.Value = Value
					DropdownFrame.F.Selected.Text = Dropdown.Value

					for _, v in pairs(Dropdown.Buttons) do
						TweenService:Create(v,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{BackgroundTransparency = 1}):Play()
						TweenService:Create(v.Title,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{TextTransparency = 0.4}):Play()
					end	
					TweenService:Create(Dropdown.Buttons[Value],TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{BackgroundTransparency = 0}):Play()
					TweenService:Create(Dropdown.Buttons[Value].Title,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{TextTransparency = 0}):Play()
					return DropdownConfig.Callback(Dropdown.Value)
				end

				AddConnection(Click.MouseButton1Click, function()
					Dropdown.Toggled = not Dropdown.Toggled
					DropdownFrame.F.Line.Visible = Dropdown.Toggled
					TweenService:Create(DropdownFrame.F.Ico,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Rotation = Dropdown.Toggled and 180 or 0}):Play()
					if #Dropdown.Options > MaxElements then
						TweenService:Create(DropdownFrame,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = Dropdown.Toggled and UDim2.new(1, 0, 0, 38 + (MaxElements * 28)) or UDim2.new(1, 0, 0, 38)}):Play()
					else
						TweenService:Create(DropdownFrame,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = Dropdown.Toggled and UDim2.new(1, 0, 0, DropdownList.AbsoluteContentSize.Y + 38) or UDim2.new(1, 0, 0, 38)}):Play()
					end
				end)

				Dropdown:Refresh(Dropdown.Options, false)
				Dropdown:Set(Dropdown.Value)
				if DropdownConfig.Flag then				
					OrionLib.Flags[DropdownConfig.Flag] = Dropdown
				end
				return Dropdown
			end
			function ElementFunction:AddBind(BindConfig)
				BindConfig.Name = BindConfig.Name or "Bind"
				BindConfig.Default = BindConfig.Default or Enum.KeyCode.Unknown
				BindConfig.Hold = BindConfig.Hold or false
				BindConfig.Callback = BindConfig.Callback or function() end
				BindConfig.Flag = BindConfig.Flag or nil
				BindConfig.Save = BindConfig.Save or false

				local Bind = {Value, Binding = false, Type = "Bind", Save = BindConfig.Save}
				local Holding = false

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local BindBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 14), {
						Size = UDim2.new(1, 0, 1, 0),
						Font = Enum.Font.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Center,
						Name = "Value"
					}), "Text")
				}), "Main")

				local BindFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", BindConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					BindBox,
					Click
				}), "Second")

				AddConnection(BindBox.Value:GetPropertyChangedSignal("Text"), function()
					--BindBox.Size = UDim2.new(0, BindBox.Value.TextBounds.X + 16, 0, 24)
					TweenService:Create(BindBox, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, BindBox.Value.TextBounds.X + 16, 0, 24)}):Play()
				end)

				AddConnection(Click.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						if Bind.Binding then return end
						Bind.Binding = true
						BindBox.Value.Text = ""
					end
				end)

				AddConnection(UserInputService.InputBegan, function(Input)
					if UserInputService:GetFocusedTextBox() then return end
					if (Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value) and not Bind.Binding then
						if BindConfig.Hold then
							Holding = true
							BindConfig.Callback(Holding)
						else
							BindConfig.Callback()
						end
					elseif Bind.Binding then
						local Key
						pcall(function()
							if not CheckKey(BlacklistedKeys, Input.KeyCode) then
								Key = Input.KeyCode
							end
						end)
						pcall(function()
							if CheckKey(WhitelistedMouse, Input.UserInputType) and not Key then
								Key = Input.UserInputType
							end
						end)
						Key = Key or Bind.Value
						Bind:Set(Key)
						SaveCfg(game.GameId)
					end
				end)

				AddConnection(UserInputService.InputEnded, function(Input)
					if Input.KeyCode.Name == Bind.Value or Input.UserInputType.Name == Bind.Value then
						if BindConfig.Hold and Holding then
							Holding = false
							BindConfig.Callback(Holding)
						end
					end
				end)

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseLeave, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)

				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(BindFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)

				function Bind:Set(Key)
					Bind.Binding = false
					Bind.Value = Key or Bind.Value
					Bind.Value = Bind.Value.Name or Bind.Value
					BindBox.Value.Text = Bind.Value
				end

				Bind:Set(BindConfig.Default)
				if BindConfig.Flag then				
					OrionLib.Flags[BindConfig.Flag] = Bind
				end
				return Bind
			end  
			function ElementFunction:AddTextbox(TextboxConfig)
				TextboxConfig = TextboxConfig or {}
				TextboxConfig.Name = TextboxConfig.Name or "Textbox"
				TextboxConfig.Default = TextboxConfig.Default or ""
				TextboxConfig.TextDisappear = TextboxConfig.TextDisappear or false
				TextboxConfig.Callback = TextboxConfig.Callback or function() end

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local TextboxActual = AddThemeObject(Create("TextBox", {
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					PlaceholderColor3 = Color3.fromRGB(210,210,210),
					PlaceholderText = "Input",
					Font = Enum.Font.GothamSemibold,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextSize = 14,
					ClearTextOnFocus = false
				}), "Text")

				local TextContainer = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					TextboxActual
				}), "Main")


				local TextboxFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					AddThemeObject(SetProps(MakeElement("Label", TextboxConfig.Name, 15), {
						Size = UDim2.new(1, -12, 1, 0),
						Position = UDim2.new(0, 12, 0, 0),
						Font = Enum.Font.GothamBold,
						Name = "Content"
					}), "Text"),
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
					TextContainer,
					Click
				}), "Second")

				AddConnection(TextboxActual:GetPropertyChangedSignal("Text"), function()
					--TextContainer.Size = UDim2.new(0, TextboxActual.TextBounds.X + 16, 0, 24)
					TweenService:Create(TextContainer, TweenInfo.new(0.45, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Size = UDim2.new(0, TextboxActual.TextBounds.X + 16, 0, 24)}):Play()
				end)

				AddConnection(TextboxActual.FocusLost, function()
					TextboxConfig.Callback(TextboxActual.Text)
					if TextboxConfig.TextDisappear then
						TextboxActual.Text = ""
					end	
				end)

				TextboxActual.Text = TextboxConfig.Default

				AddConnection(Click.MouseEnter, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
				end)

				AddConnection(Click.MouseLeave, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = OrionLib.Themes[OrionLib.SelectedTheme].Second}):Play()
				end)

				AddConnection(Click.MouseButton1Up, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 3, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 3)}):Play()
					TextboxActual:CaptureFocus()
				end)

				AddConnection(Click.MouseButton1Down, function()
					TweenService:Create(TextboxFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {BackgroundColor3 = Color3.fromRGB(OrionLib.Themes[OrionLib.SelectedTheme].Second.R * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.G * 255 + 6, OrionLib.Themes[OrionLib.SelectedTheme].Second.B * 255 + 6)}):Play()
				end)
			end 
			function ElementFunction:AddColorpicker(ColorpickerConfig)
				ColorpickerConfig = ColorpickerConfig or {}
				ColorpickerConfig.Name = ColorpickerConfig.Name or "Colorpicker"
				ColorpickerConfig.Default = ColorpickerConfig.Default or Color3.fromRGB(255,255,255)
				ColorpickerConfig.Callback = ColorpickerConfig.Callback or function() end
				ColorpickerConfig.Flag = ColorpickerConfig.Flag or nil
				ColorpickerConfig.Save = ColorpickerConfig.Save or false

				local ColorH, ColorS, ColorV = 1, 1, 1
				local Colorpicker = {Value = ColorpickerConfig.Default, Toggled = false, Type = "Colorpicker", Save = ColorpickerConfig.Save}

				local ColorSelection = Create("ImageLabel", {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(select(3, Color3.toHSV(Colorpicker.Value))),
					ScaleType = Enum.ScaleType.Fit,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=4805639000"
				})

				local HueSelection = Create("ImageLabel", {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0.5, 0, 1 - select(1, Color3.toHSV(Colorpicker.Value))),
					ScaleType = Enum.ScaleType.Fit,
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = 1,
					Image = "http://www.roblox.com/asset/?id=4805639000"
				})

				local Color = Create("ImageLabel", {
					Size = UDim2.new(1, -25, 1, 0),
					Visible = false,
					Image = "rbxassetid://4155801252"
				}, {
					Create("UICorner", {CornerRadius = UDim.new(0, 5)}),
					ColorSelection
				})

				local Hue = Create("Frame", {
					Size = UDim2.new(0, 20, 1, 0),
					Position = UDim2.new(1, -20, 0, 0),
					Visible = false
				}, {
					Create("UIGradient", {Rotation = 270, Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)), ColorSequenceKeypoint.new(0.20, Color3.fromRGB(234, 255, 0)), ColorSequenceKeypoint.new(0.40, Color3.fromRGB(21, 255, 0)), ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.80, Color3.fromRGB(0, 17, 255)), ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 0, 251)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 4))},}),
					Create("UICorner", {CornerRadius = UDim.new(0, 5)}),
					HueSelection
				})

				local ColorpickerContainer = Create("Frame", {
					Position = UDim2.new(0, 0, 0, 32),
					Size = UDim2.new(1, 0, 1, -32),
					BackgroundTransparency = 1,
					ClipsDescendants = true
				}, {
					Hue,
					Color,
					Create("UIPadding", {
						PaddingLeft = UDim.new(0, 35),
						PaddingRight = UDim.new(0, 35),
						PaddingBottom = UDim.new(0, 10),
						PaddingTop = UDim.new(0, 17)
					})
				})

				local Click = SetProps(MakeElement("Button"), {
					Size = UDim2.new(1, 0, 1, 0)
				})

				local ColorpickerBox = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 4), {
					Size = UDim2.new(0, 24, 0, 24),
					Position = UDim2.new(1, -12, 0.5, 0),
					AnchorPoint = Vector2.new(1, 0.5)
				}), {
					AddThemeObject(MakeElement("Stroke"), "Stroke")
				}), "Main")

				local ColorpickerFrame = AddThemeObject(SetChildren(SetProps(MakeElement("RoundFrame", Color3.fromRGB(255, 255, 255), 0, 5), {
					Size = UDim2.new(1, 0, 0, 38),
					Parent = ItemParent
				}), {
					SetProps(SetChildren(MakeElement("TFrame"), {
						AddThemeObject(SetProps(MakeElement("Label", ColorpickerConfig.Name, 15), {
							Size = UDim2.new(1, -12, 1, 0),
							Position = UDim2.new(0, 12, 0, 0),
							Font = Enum.Font.GothamBold,
							Name = "Content"
						}), "Text"),
						ColorpickerBox,
						Click,
						AddThemeObject(SetProps(MakeElement("Frame"), {
							Size = UDim2.new(1, 0, 0, 1),
							Position = UDim2.new(0, 0, 1, -1),
							Name = "Line",
							Visible = false
						}), "Stroke"), 
					}), {
						Size = UDim2.new(1, 0, 0, 38),
						ClipsDescendants = true,
						Name = "F"
					}),
					ColorpickerContainer,
					AddThemeObject(MakeElement("Stroke"), "Stroke"),
				}), "Second")

				AddConnection(Click.MouseButton1Click, function()
					Colorpicker.Toggled = not Colorpicker.Toggled
					TweenService:Create(ColorpickerFrame,TweenInfo.new(.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),{Size = Colorpicker.Toggled and UDim2.new(1, 0, 0, 148) or UDim2.new(1, 0, 0, 38)}):Play()
					Color.Visible = Colorpicker.Toggled
					Hue.Visible = Colorpicker.Toggled
					ColorpickerFrame.F.Line.Visible = Colorpicker.Toggled
				end)

				local function UpdateColorPicker()
					ColorpickerBox.BackgroundColor3 = Color3.fromHSV(ColorH, ColorS, ColorV)
					Color.BackgroundColor3 = Color3.fromHSV(ColorH, 1, 1)
					Colorpicker:Set(ColorpickerBox.BackgroundColor3)
					ColorpickerConfig.Callback(ColorpickerBox.BackgroundColor3)
					SaveCfg(game.GameId)
				end

				ColorH = 1 - (math.clamp(HueSelection.AbsolutePosition.Y - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y) / Hue.AbsoluteSize.Y)
				ColorS = (math.clamp(ColorSelection.AbsolutePosition.X - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X) / Color.AbsoluteSize.X)
				ColorV = 1 - (math.clamp(ColorSelection.AbsolutePosition.Y - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y)

				AddConnection(Color.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if ColorInput then
							ColorInput:Disconnect()
						end
						ColorInput = AddConnection(RunService.RenderStepped, function()
							local ColorX = (math.clamp(Mouse.X - Color.AbsolutePosition.X, 0, Color.AbsoluteSize.X) / Color.AbsoluteSize.X)
							local ColorY = (math.clamp(Mouse.Y - Color.AbsolutePosition.Y, 0, Color.AbsoluteSize.Y) / Color.AbsoluteSize.Y)
							ColorSelection.Position = UDim2.new(ColorX, 0, ColorY, 0)
							ColorS = ColorX
							ColorV = 1 - ColorY
							UpdateColorPicker()
						end)
					end
				end)

				AddConnection(Color.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if ColorInput then
							ColorInput:Disconnect()
						end
					end
				end)

				AddConnection(Hue.InputBegan, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if HueInput then
							HueInput:Disconnect()
						end;

						HueInput = AddConnection(RunService.RenderStepped, function()
							local HueY = (math.clamp(Mouse.Y - Hue.AbsolutePosition.Y, 0, Hue.AbsoluteSize.Y) / Hue.AbsoluteSize.Y)

							HueSelection.Position = UDim2.new(0.5, 0, HueY, 0)
							ColorH = 1 - HueY

							UpdateColorPicker()
						end)
					end
				end)

				AddConnection(Hue.InputEnded, function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if HueInput then
							HueInput:Disconnect()
						end
					end
				end)

				function Colorpicker:Set(Value)
					Colorpicker.Value = Value
					ColorpickerBox.BackgroundColor3 = Colorpicker.Value
					ColorpickerConfig.Callback(Colorpicker.Value)
				end

				Colorpicker:Set(Colorpicker.Value)
				if ColorpickerConfig.Flag then				
					OrionLib.Flags[ColorpickerConfig.Flag] = Colorpicker
				end
				return Colorpicker
			end  
			return ElementFunction   
		end	

		local ElementFunction = {}

		function ElementFunction:AddSection(SectionConfig)
			SectionConfig.Name = SectionConfig.Name or "Section"

			local SectionFrame = SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 0, 26),
				Parent = Container
			}), {
				AddThemeObject(SetProps(MakeElement("Label", SectionConfig.Name, 14), {
					Size = UDim2.new(1, -12, 0, 16),
					Position = UDim2.new(0, 0, 0, 3),
					Font = Enum.Font.GothamSemibold
				}), "TextDark"),
				SetChildren(SetProps(MakeElement("TFrame"), {
					AnchorPoint = Vector2.new(0, 0),
					Size = UDim2.new(1, 0, 1, -24),
					Position = UDim2.new(0, 0, 0, 23),
					Name = "Holder"
				}), {
					MakeElement("List", 0, 6)
				}),
			})

			AddConnection(SectionFrame.Holder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"), function()
				SectionFrame.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y + 31)
				SectionFrame.Holder.Size = UDim2.new(1, 0, 0, SectionFrame.Holder.UIListLayout.AbsoluteContentSize.Y)
			end)

			local SectionFunction = {}
			for i, v in next, GetElements(SectionFrame.Holder) do
				SectionFunction[i] = v 
			end
			return SectionFunction
		end	

		for i, v in next, GetElements(Container) do
			ElementFunction[i] = v 
		end

		if TabConfig.PremiumOnly then
			for i, v in next, ElementFunction do
				ElementFunction[i] = function() end
			end    
			Container:FindFirstChild("UIListLayout"):Destroy()
			Container:FindFirstChild("UIPadding"):Destroy()
			SetChildren(SetProps(MakeElement("TFrame"), {
				Size = UDim2.new(1, 0, 1, 0),
				Parent = ItemParent
			}), {
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://3610239960"), {
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0, 15, 0, 15),
					ImageTransparency = 0.4
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Unauthorised Access", 14), {
					Size = UDim2.new(1, -38, 0, 14),
					Position = UDim2.new(0, 38, 0, 18),
					TextTransparency = 0.4
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Image", "rbxassetid://4483345875"), {
					Size = UDim2.new(0, 56, 0, 56),
					Position = UDim2.new(0, 84, 0, 110),
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "Premium Features", 14), {
					Size = UDim2.new(1, -150, 0, 14),
					Position = UDim2.new(0, 150, 0, 112),
					Font = Enum.Font.GothamBold
				}), "Text"),
				AddThemeObject(SetProps(MakeElement("Label", "This part of the script is locked to Sirius Premium users. Purchase Premium in the Discord server (discord.gg/sirius)", 12), {
					Size = UDim2.new(1, -200, 0, 14),
					Position = UDim2.new(0, 150, 0, 138),
					TextWrapped = true,
					TextTransparency = 0.4
				}), "Text")
			})
		end
		return ElementFunction   
	end  
	
	--if writefile and isfile then
	--	if not isfile("NewLibraryNotification1.txt") then
	--		local http_req = (syn and syn.request) or (http and http.request) or http_request
	--		if http_req then
	--			http_req({
	--				Url = 'http://127.0.0.1:6463/rpc?v=1',
	--				Method = 'POST',
	--				Headers = {
	--					['Content-Type'] = 'application/json',
	--					Origin = 'https://discord.com'
	--				},
	--				Body = HttpService:JSONEncode({
	--					cmd = 'INVITE_BROWSER',
	--					nonce = HttpService:GenerateGUID(false),
	--					args = {code = 'sirius'}
	--				})
	--			})
	--		end
	--		OrionLib:MakeNotification({
	--			Name = "UI Library Available",
	--			Content = "New UI Library Available - Joining Discord (#announcements)",
	--			Time = 8
	--		})
	--		spawn(function()
	--			local UI = game:GetObjects("rbxassetid://11403719739")[1]

	--			if gethui then
	--				UI.Parent = gethui()
	--			elseif syn.protect_gui then
	--				syn.protect_gui(UI)
	--				UI.Parent = game.CoreGui
	--			else
	--				UI.Parent = game.CoreGui
	--			end

	--			wait(11)

	--			UI:Destroy()
	--		end)
	--		writefile("NewLibraryNotification1.txt","The value for the notification having been sent to you.")
	--	end
	--end
	

	
	return TabFunction
end   

function OrionLib:Destroy()
	Orion:Destroy()
end

if game.PlaceId == 2753915549 then
    World1 = true
elseif game.PlaceId == 4442272183 then
    World2 = true
elseif game.PlaceId == 7449423635 then
    World3 = true
end


local Window = OrionLib:MakeWindow({Name = "Seraphy Premium", HidePremium = false, SaveConfig = true, ConfigFolder = "SeraphyTest"})


local Auto_Farm = Window:MakeTab({
	Name = "General",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})

local Main = Window:MakeTab({
	Name = "Sea Events",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
local Main2 = Window:MakeTab({
	Name = "Settings",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
local Main3 = Window:MakeTab({
	Name = "Items",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
local Section = Main:AddSection({
	Name = "Section"
})

Cake = Auto_Farm:AddLabel("N/A")

spawn(function()
	while wait() do
		pcall(function()
			if string.len(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner")) == 88 then
				Cake:Set("Killed : "..string.sub(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner"),39,41))
			elseif string.len(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner")) == 87 then
				Cake:Set("Killed : "..string.sub(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner"),39,40))
			elseif string.len(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner")) == 86 then
				Cake:Set("Killed : "..string.sub(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner"),39,39))
			else
				Cake:Set("Boss Is Spawning")
			end
		end)
	end
end)
task.spawn(function()
	while wait() do
		pcall(function()
			if string.len(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner")) == 88 then
				KillMob = (tonumber(string.sub(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner"),39,41)) - 500)
			elseif string.len(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner")) == 87 then
				KillMob = (tonumber(string.sub(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner"),40,41)) - 500)
			elseif string.len(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner")) == 86 then
				KillMob = (tonumber(string.sub(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner"),41,41)) - 500)
			end
		end)
	end
end)

Auto_Farm:AddToggle({
	Name = "Auto Cake Prince",
	Default = _G.Auto_Cake_Prince,
	Callback = function(Value)
		_G.Auto_Cake_Prince = Value
	end    
})
Auto_Farm:AddToggle({
	Name = "Enable Quest",
	Default = _G.Enable_Quest,
	Callback = function(Value)
		_G.Enable_Quest = Value
	end    
})
Auto_Farm:AddToggle({
	Name = "Enable Spawn Cake",
	Default = _G.Enable_Spawn_Cake,
	Callback = function(Value)
		_G.Enable_Spawn_Cake = Value
	end    
})

Mirage = Auto_Farm:AddLabel("N/A")
FM = Auto_Farm:AddLabel("N/A")
task.spawn(function()
	while task.wait() do
		pcall(function()
			if game:GetService("Lighting").Sky.MoonTextureId=="http://www.roblox.com/asset/?id=9709149431" then
				FM:Set("🌑 : Full Moon 100%")
			elseif game:GetService("Lighting").Sky.MoonTextureId=="http://www.roblox.com/asset/?id=9709149052" then
				FM:Set("🌒 : Full Moon 75%")
			elseif game:GetService("Lighting").Sky.MoonTextureId=="http://www.roblox.com/asset/?id=9709143733" then
				FM:Set("🌓 : Full Moon 50%")
			elseif game:GetService("Lighting").Sky.MoonTextureId=="http://www.roblox.com/asset/?id=9709150401" then
				FM:Set("🌗 : Full Moon 25%")
			elseif game:GetService("Lighting").Sky.MoonTextureId=="http://www.roblox.com/asset/?id=9709149680" then
				FM:Set("🌖 : Full Moon 15%")
			else
				FM:Set("🌚 : Full Moon 0%")
			end
		end)
	end
end)
spawn(function()
	while wait() do
		pcall(function()
			for i,v in pairs(game:GetService("Workspace")["_WorldOrigin"].Locations:GetChildren()) do
				if v.Name == "Mirage Island" then
					Mirage:Set("Mirage Island: 🟢")
				else
					Mirage:Set("Mirage Island: 🔴")
				end
			end
		end)
	end
end)
Auto_Farm:AddToggle({
	Name = "Auto Find Mirage Island",
	Default = _G.Enable_Find_Mirage,
	Callback = function(Value)
		_G.Enable_Find_Mirage = Value
	end    
})
Auto_Farm:AddToggle({
	Name = "Auto Find Gear",
	Default = _G.Enable_Find_Gear,
	Callback = function(Value)
		_G.Enable_Find_Gear = Value
	end    
})
Auto_Farm:AddToggle({
	Name = "Auto Pullever",
	Default = _G.Enable_Pull_ever,
	Callback = function(Value)
		_G.Enable_Pull_ever = Value
		if not _G.Enable_Pull_ever then
			player.CameraMaxZoomDistance = 50
			player.CameraMinZoomDistance = 75
		end
	end    
})
local part = Instance.new("Part");
local lighting = game:GetService("Lighting");
local camera = game.Workspace.CurrentCamera
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local distFromCam = 16;
part.Name = "dsada"
part.Anchored = true;
part.Size = Vector3.new(1,1,1);
part.Parent = workspace;
part.CanCollide = false;
spawn(function()
    pcall(function()
        if _G.Enable_Pull_ever then
            game:GetService("RunService").RenderStepped:Connect(function()
                part.Position = workspace.CurrentCamera.CFrame.Position + lighting:GetMoonDirection() * distFromCam;
            end);
        end
    end)
end)

spawn(function()
	while true do wait()
		if _G.Enable_Find_Mirage then
			pcall(function()
				if not game:GetService("Workspace").Map:FindFirstChild("MysticIsland") then
					if not workspace.Boats:FindFirstChild("PirateBrigade") then
						BuyBoat = toTargetP(CFrame.new(-6042.7802734375, 16.420740127563477, -2038.7415771484375))
						if (CFrame.new(-6042.7802734375, 16.420740127563477, -2038.7415771484375).Position-game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 10 then
							if BuyBoat then BuyBoat:Stop() end
							local args = {
								[1] = "BuyBoat",
								[2] = "PirateBrigade"
							}
							game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
						end
					elseif workspace.Boats:FindFirstChild("PirateBrigade") then
						if (workspace.Boats:FindFirstChild("PirateBrigade").VehicleSeat.CFrame.Position - CFrame.new(-11581.4482421875, 2.994250774383545, 1252.9136962890625).Position).magnitude >= 30 then
							workspace.Boats:FindFirstChild("PirateBrigade").VehicleSeat.CFrame = CFrame.new(-11581.4482421875, 2.994250774383545, 1252.9136962890625)
							wait(1)
						elseif (CFrame.new(-11581.4482421875, 2.994250774383545, 1252.9136962890625).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 30 then
							workspace.Boats:FindFirstChild("PirateBrigade").VehicleSeat.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
							wai(0.5)
							toTargetP(CFrame.new(-11581.4482421875, 2.994250774383545, 1252.9136962890625))
						elseif game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit == true then
							game:service('VirtualInputManager'):SendKeyEvent(true, "W", false, game)
							wait(2)
							game:service('VirtualInputManager'):SendKeyEvent(false, "W", false, game)
							wait(0.5)
							game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = false
						elseif game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit == false then
							toTargetP(workspace.Boats:FindFirstChild("PirateBrigade").VehicleSeat.CFrame)
						end
					end
				else
					if game:GetService("Workspace").Map:FindFirstChild("MysticIsland") then
						toTargetP(game:GetService("Workspace").Map:FindFirstChild("MysticIsland").HumanoidRootPart.CFrame * CFrame.new(0, 500, -100))
						if _G.Enable_Pull_ever then
							if workspace:FindFirstChild("dsada") then
								player.CameraMaxZoomDistance = 0
								player.CameraMinZoomDistance = 0
								wait(1)
								local camera = game.Workspace.CurrentCamera
								camera.CFrame = CFrame.new(camera.CFrame.Position,workspace.dsada.Position) -- locks into the HEAD
								wait(0.5)
								game:GetService("VirtualInputManager"):SendKeyEvent(true,"T",true,game)
								wait(0.5)
								game:GetService("VirtualInputManager"):SendKeyEvent(true,"T",false,game)
							end
						elseif _G.Enable_Find_Gear then
							for i, v in pairs(game:GetService("Workspace").Map.MysticIsland:GetChildren()) do
								if v:IsA("MeshPart") then
									if v.Material == Enum.Material.Neon then
										toTargetP(v.CFrame)
									end
								end
							end
						end
					end
				end
			end)
		end
	end
end)

function Check_Weapon(Name_Weapon)
	local ReturnText = ""
	for i,v in pairs(game:GetService("ReplicatedStorage").Remotes["CommF_"]:InvokeServer("getInventoryWeapons")) do
		if type(v) == "table" then
			if v.Name == Name_Weapon then
				ReturnText = ReturnText .. v.Name .. " "
			end
		end
	end
	if game.Players.LocalPlayer.Backpack:FindFirstChild(Name_Weapon) or game.Players.LocalPlayer.Character:FindFirstChild(Name_Weapon) or ReturnText ~= "" then
		return "Have"
	else
		return "Not Have"
	end
	return "else"
end
function Check_Number(matname)
	for i,v in pairs(game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("getInventory")) do
		if type(v) == "table" then
			if v.Type == "Material" then
				if v.Name == matname then
					return v.Count
				end
			end
		end
	end
	return 0
end
Anchor=Main:AddLabel("⚓ Shark Anchor: 🔴")
Main:AddToggle({
	Name = "Auto Shark Anchor",
	Default = _G.AUTO_SAHRK_ANCHOR,
	Callback = function(Value)
		_G.AUTO_SAHRK_ANCHOR = Value
	end    
})
Main:AddToggle({
	Name = "Auto Terror Jaw",
	Default = _G.AUTO_TRROR_JAW,
	Callback = function(Value)
		_G.AUTO_TRROR_JAW = Value
	end    
})
Main:AddToggle({
	Name = "Auto Tooth Necklace",
	Default = _G.AUTO_TOOTH_NECKLACE,
	Callback = function(Value)
		_G.AUTO_TOOTH_NECKLACE = Value
	end    
})
local E=function(U)
	return game:GetService(U);
end;
local c=E("ReplicatedStorage");
warn(c);
local w=workspace:WaitForChild("Enemies");
warn(w);
local r=E("Players").LocalPlayer;
getgenv().toTargetP=function(p)
    task.spawn(function()
        pcall(function()
            if r:DistanceFromCharacter(p.Position)<=200 then 
                r.Character.HumanoidRootPart.CFrame=p;
			else 
				if not game.Players.LocalPlayer.Character:FindFirstChild("Root")then 
					local K=Instance.new("Part",game.Players.LocalPlayer.Character);
						K.Size=Vector3.new(1,0.5,1);
						K.Name="Root";
						K.Anchored=true;
						K.Transparency=1;
						K.CanCollide=false;
						K.CFrame=game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame*CFrame.new(0,20,0);
					end;

					local U=(game.Players.LocalPlayer.Character.HumanoidRootPart.Position-p.Position).Magnitude;
					local z=game:service("TweenService");
					local B=TweenInfo.new((p.Position-game.Players.LocalPlayer.Character.Root.Position).Magnitude/300,Enum.EasingStyle.Linear);
					local S,g=pcall(function()local q=z:Create(game.Players.LocalPlayer.Character.Root,B,{CFrame=p});
						q:Play();
					end);
					if not S then return g; end;
					
					game.Players.LocalPlayer.Character.Root.CFrame=game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame;
					if S and game.Players.LocalPlayer.Character:FindFirstChild("Root")then 
						pcall(function()
						if(game.Players.LocalPlayer.Character.HumanoidRootPart.Position-p.Position).Magnitude>=20 then 
							spawn(function()
								pcall(function()
									if(game.Players.LocalPlayer.Character.Root.Position-game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude>150 then 
										game.Players.LocalPlayer.Character.Root.CFrame=game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame;
									else 
										game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame=game.Players.LocalPlayer.Character.Root.CFrame;
									end;
								end);
							end);
						elseif(game.Players.LocalPlayer.Character.HumanoidRootPart.Position-p.Position).Magnitude>=10 and(game.Players.LocalPlayer.Character.HumanoidRootPart.Position-p.Position).Magnitude<20 then 
							game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame=p;
						elseif(game.Players.LocalPlayer.Character.HumanoidRootPart.Position-p.Position).Magnitude<10 then 
							game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame=p;
						end;
					end);
				end;
				local tweenfunct = {}

				function tweenfunct:Stop()
					q:Cancel()
				end

				return tweenfunct		
			end;
		end);
	end);
end;
-- function toTargetP(CFgo)
-- 	if game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Health <= 0 or not game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid") then tween:Cancel() repeat wait() until game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid") and game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid").Health > 0 wait(7) return end
-- 	if (game:GetService("Players")["LocalPlayer"].Character.HumanoidRootPart.Position - CFgo.Position).Magnitude <= 150 then
-- 		pcall(function()
-- 			tween:Cancel()

-- 			game:GetService("Players")["LocalPlayer"].Character.HumanoidRootPart.CFrame = CFgo

-- 			return
-- 		end)
-- 	end
-- 	local tween_s = game:service"TweenService"
-- 	local info = TweenInfo.new((game:GetService("Players")["LocalPlayer"].Character.HumanoidRootPart.Position - CFgo.Position).Magnitude/325, Enum.EasingStyle.Linear)
-- 	tween = tween_s:Create(game.Players.LocalPlayer.Character["HumanoidRootPart"], info, {CFrame = CFgo})
-- 	tween:Play()

-- 	local tweenfunc = {}

-- 	function tweenfunc:Stop()
-- 		tween:Cancel()
-- 	end

-- 	return tweenfunc
-- end
function EquipWeapon(ToolSe)
	spawn(function()
		if game.Players.LocalPlayer.Backpack:FindFirstChild(ToolSe) or game.Players.LocalPlayer.Character:FindFirstChild(ToolSe) then
			local tool = game.Players.LocalPlayer.Backpack:FindFirstChild(ToolSe)
			wait(.1)
			game.Players.LocalPlayer.Character.Humanoid:EquipTool(tool)
		end
	end)
end
-- spawn(function()
--     while wait() do
--         if  _G.AUTO_SAHRK_ANCHOR  then
--             pcall(function()
-- 				if game:GetService("ReplicatedStorage"):FindFirstChild("Stone") or game:GetService("Workspace").Enemies:FindFirstChild("Stone") then
-- 					if game:GetService("Workspace").Enemies:FindFirstChild("Captain Elephant") then
-- 						for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
-- 							if v.Name == "Captain Elephant" then
-- 								if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
-- 									repeat task.wait()
-- 										if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
-- 											game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
-- 										end
-- 										EquipWeapon(_G.SelectToolWeapon)
-- 										v.HumanoidRootPart.Size = Vector3.new(60,60,60)
-- 										v.Humanoid.JumpPower = 0
-- 										v.Humanoid.WalkSpeed = 0
-- 										v.HumanoidRootPart.CanCollide = false
-- 										toTargetP(v.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
-- 									until not  _G.AUTO_SAHRK_ANCHOR or not v.Parent or v.Humanoid.Health <= 0
-- 								end
-- 							end
-- 						end
-- 					else
-- 						repeat wait()
-- 							TP(game:GetService("ReplicatedStorage"):FindFirstChild("Captain Elephant").HumanoidRootPart.CFrame * CFrame.new(0,35,0))
-- 						until not _G.AUTO_SAHRK_ANCHOR or game:GetService("Workspace").Enemies:FindFirstChild("Captain Elephant")
-- 					end
-- 				else

-- 				end
--             end)
--         end
--     end
-- end)
function EquipAllWeapon()
	pcall(function()
		for i,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
			if v:IsA('Tool') and not (v.Name == "Summon Sea Beast" or v.Name == "Water Body" or v.Name == "Awakening") then
				local ToolHumanoid = game.Players.LocalPlayer.Backpack:FindFirstChild(v.Name) 
				game.Players.LocalPlayer.Character.Humanoid:EquipTool(ToolHumanoid) 
                wait(1)
			end
		end
	end)
end
spawn(function()
	local gg = getrawmetatable(game)
	local old = gg.__namecall
	setreadonly(gg,false)
	gg.__namecall = newcclosure(function(...)
		local method = getnamecallmethod()
		local args = {...}
		if tostring(method) == "FireServer" then
			if tostring(args[1]) == "RemoteEvent" then
				if tostring(args[2]) ~= "true" and tostring(args[2]) ~= "false" then
					if UseSkillMasteryDevilFruit and _G.AUTO_SAHRK_ANCHOR then
						if type(args[2]) == "vector" then 
							args[2] = PositionSkillMasteryDevilFruit
						else
							args[2] = CFrame.new(PositionSkillMasteryDevilFruit)
						end
						return old(unpack(args))
					end
				end
			end
		end
		return old(...)
	end)
end)
Method = 1
WARP = 0
function Method_sit()
	if Method == 1 then
		game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = true
		Method = Method + 1
	elseif Method == 2 then
		game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = false
		Method = Method +1
	elseif Method == 3 then
		game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = true
		Method = Method +1
	elseif Method == 4 then
		game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = false
		Method = Method-1
	end
end
spawn(function()
    while wait() do
        if  _G.AUTO_SAHRK_ANCHOR  then
            pcall(function()
				if not game:GetService("Workspace").Enemies:FindFirstChild("Terrorshark") then
					if not game:GetService("Workspace").Enemies:FindFirstChild("Shark") then
						if not game:GetService("Workspace").Enemies:FindFirstChild("Piranha") then
							if not game:GetService("Workspace").Enemies:FindFirstChild("Fish Crew Member") then
								if not game:GetService("Workspace").Enemies:FindFirstChild("PirateGrandBrigade") then
									if not game:GetService("Workspace").Enemies:FindFirstChild("FishBoat") then
										if not game:GetService("Workspace").Enemies:FindFirstChild("FishBoat") then
											if not game:GetService("Workspace").Boats:FindFirstChild("Guardian") then
												BuyB = toTargetP(CFrame.new(-16917.17578125, 9.06057357788086, 510.3914794921875))
												if (CFrame.new(-16917.17578125, 9.06057357788086, 510.3914794921875).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 10 then
													if BuyB then BuyB:Stop() end
													local args = {
														[1] = "BuyBoat",
														[2] = "Guardian"
													}
													game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
												end
											elseif game:GetService("Workspace").Boats:FindFirstChild("Guardian") then
												if game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit == false and (game:GetService("Workspace").Boats.Guardian.VehicleSeat.CFrame.Position - CFrame.new(-41228.96484375, 20.907041549682617, 8984.2861328125).Position).magnitude <=10 then
													repeat task.wait()
														stopsit = toTargetP(game:GetService("Workspace").Boats.Guardian.VehicleSeat.CFrame * CFrame.new(0,1,0))
													until not _G.AUTO_SAHRK_ANCHOR or game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit == true
												elseif game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit == true then
													if stopsit then stopsit:Stop() end
													-- spawn(function()
													-- 	pcall(Method_sit)
													-- end)
												else
													repeat task.wait()
														game:GetService("Workspace").Boats.Guardian.VehicleSeat.CFrame = CFrame.new(-41228.96484375, 20.907041549682617, 8984.2861328125)
														game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = false
														WARP = WARP + 1
													until (game:GetService("Workspace").Boats.Guardian.VehicleSeat.CFrame.Position - CFrame.new(-41228.96484375, 20.907041549682617, 8984.2861328125).Position).magnitude <=10 or not _G.AUTO_SAHRK_ANCHOR or WARP >= 5
													WARP = 0
												end
											end
										else
											if game:GetService("Workspace").Enemies:FindFirstChild("FishBoat") then
												for iu,vbss in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
													if vbss.Name == "FishBoat" then
														if vbss:FindFirstChild("VehicleSeat") then
															repeat task.wait()
																game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = false
																if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
																	game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
																end
																if game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value) then
																	MasteryDevilFruit = require(game:GetService("Players").LocalPlayer.Character[game.Players.LocalPlayer.Data.DevilFruit.Value].Data)
																	DevilFruitMastery = game:GetService("Players").LocalPlayer.Character[game.Players.LocalPlayer.Data.DevilFruit.Value].Level.Value
																elseif game:GetService("Players").LocalPlayer.Backpack:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value) then
																	MasteryDevilFruit = require(game:GetService("Players").LocalPlayer.Backpack[game.Players.LocalPlayer.Data.DevilFruit.Value].Data)
																	DevilFruitMastery = game:GetService("Players").LocalPlayer.Backpack[game.Players.LocalPlayer.Data.DevilFruit.Value].Level.Value
																end
																AutoSkill = true
																UseSkillMasteryDevilFruit = true
																if game:GetService("Players").LocalPlayer.Character:FindFirstChild("Dragon-Dragon") then
																	if _G.Skillz and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbss.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.Z then
																		game:service('VirtualInputManager'):SendKeyEvent(true, "Z", false, game)
																		wait(.1)
																		game:service('VirtualInputManager'):SendKeyEvent(false, "Z", false, game)
																	end
																	if _G.Skillx and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbss.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.X then
																		game:service('VirtualInputManager'):SendKeyEvent(true, "X", false, game)
																		wait(.1)
																		game:service('VirtualInputManager'):SendKeyEvent(false, "X", false, game)
																	end   
																elseif game:GetService("Players").LocalPlayer.Character:FindFirstChild("Human-Human: Buddha") then
																	if _G.Skillz and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbss.Humanoid.Health > 0 and game.Players.LocalPlayer.Character.HumanoidRootPart.Size == Vector3.new(7.6, 7.676, 3.686) and DevilFruitMastery >= MasteryDevilFruit.Lvl.Z then
																	else
																		game:service('VirtualInputManager'):SendKeyEvent(true, "Z", false, game)
																		wait(.1)
																		game:service('VirtualInputManager'):SendKeyEvent(false, "Z", false, game)
																	end
																	if _G.Skillx and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbss.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.X then
																		game:service('VirtualInputManager'):SendKeyEvent(true, "X", false, game)
																		wait(.1)
																		game:service('VirtualInputManager'):SendKeyEvent(false, "X", false, game)
																	end
																	if _G.Skillc and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbss.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.C then
																		game:service('VirtualInputManager'):SendKeyEvent(true, "C", false, game)
																		wait(.1)
																		game:service('VirtualInputManager'):SendKeyEvent(false, "C", false, game)
																	end  
																elseif game:GetService("Players").LocalPlayer.Character:FindFirstChild("Venom-Venom") then
																	if _G.Skillz and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbss.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.Z then
																		game:service('VirtualInputManager'):SendKeyEvent(true, "Z", false, game)
																		wait(4)
																		game:service('VirtualInputManager'):SendKeyEvent(false, "Z", false, game)
																	end
																	if _G.Skillx and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbss.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.X then
																		game:service('VirtualInputManager'):SendKeyEvent(true, "X", false, game)
																		wait(.1)
																		game:service('VirtualInputManager'):SendKeyEvent(false, "X", false, game)
																	end
																	if _G.Skillc and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbss.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.C then
																		game:service('VirtualInputManager'):SendKeyEvent(true, "C", false, game)
																		wait(.1)
																		game:service('VirtualInputManager'):SendKeyEvent(false, "C", false, game)
																	end
																elseif game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value) then
																	game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value).MousePos.Value = vbss.HumanoidRootPart.Position
																	if _G.Skillz and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbss.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.Z then
																		game:service('VirtualInputManager'):SendKeyEvent(true, "Z", false, game)
																		wait(.1)
																		game:service('VirtualInputManager'):SendKeyEvent(false, "Z", false, game)
																	end
																	if _G.Skillx and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbss.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.X then
																		game:service('VirtualInputManager'):SendKeyEvent(true, "X", false, game)
																		wait(.1)
																		game:service('VirtualInputManager'):SendKeyEvent(false, "X", false, game)
																	end
																	if _G.Skillc and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbss.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.C then
																		game:service('VirtualInputManager'):SendKeyEvent(true, "C", false, game)
																		wait(.1)
																		game:service('VirtualInputManager'):SendKeyEvent(false, "C", false, game)
																	end
																	if _G.Skillv and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbss.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.V then
																		game:service('VirtualInputManager'):SendKeyEvent(true, "V", false, game)
																		wait(.1)
																		game:service('VirtualInputManager'):SendKeyEvent(false, "V", false, game)
																	end
																end
																EquipAllWeapon()
																PositionSkillMasteryDevilFruit = vbss.VehicleSeat.CFrame
																toTargetP(vbss.VehicleSeat.CFrame * CFrame.new(0,30,0))
																Skillaimbot = true
															until not  _G.AUTO_SAHRK_ANCHOR or not vbss.Parent or vbss.Humanoid.Value <= 0 or not game:GetService("Workspace").Enemies:FindFirstChild("FishBoat")
															AutoSkill = false
															Skillaimbot = false
														end
													end
												end
											end
										end
									else
										-- PirateBrigade
										if game:GetService("Workspace").Enemies:FindFirstChild("PirateBrigade") then
											for iu,vbssb in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
												if vbssb.Name == "PirateBrigade" then
													if vbssb:FindFirstChild("VehicleSeat") then
														repeat task.wait()
															game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = false
															if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
																game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
															end
															if game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value) then
																MasteryDevilFruit = require(game:GetService("Players").LocalPlayer.Character[game.Players.LocalPlayer.Data.DevilFruit.Value].Data)
																DevilFruitMastery = game:GetService("Players").LocalPlayer.Character[game.Players.LocalPlayer.Data.DevilFruit.Value].Level.Value
															elseif game:GetService("Players").LocalPlayer.Backpack:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value) then
																MasteryDevilFruit = require(game:GetService("Players").LocalPlayer.Backpack[game.Players.LocalPlayer.Data.DevilFruit.Value].Data)
																DevilFruitMastery = game:GetService("Players").LocalPlayer.Backpack[game.Players.LocalPlayer.Data.DevilFruit.Value].Level.Value
															end
															AutoSkill = true
															UseSkillMasteryDevilFruit = true
															if game:GetService("Players").LocalPlayer.Character:FindFirstChild("Dragon-Dragon") then
																if _G.Skillz and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbssb.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.Z then
																	game:service('VirtualInputManager'):SendKeyEvent(true, "Z", false, game)
																	wait(.1)
																	game:service('VirtualInputManager'):SendKeyEvent(false, "Z", false, game)
																end
																if _G.Skillx and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbssb.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.X then
																	game:service('VirtualInputManager'):SendKeyEvent(true, "X", false, game)
																	wait(.1)
																	game:service('VirtualInputManager'):SendKeyEvent(false, "X", false, game)
																end   
															elseif game:GetService("Players").LocalPlayer.Character:FindFirstChild("Human-Human: Buddha") then
																if _G.Skillz and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbssb.Humanoid.Health > 0 and game.Players.LocalPlayer.Character.HumanoidRootPart.Size == Vector3.new(7.6, 7.676, 3.686) and DevilFruitMastery >= MasteryDevilFruit.Lvl.Z then
																else
																	game:service('VirtualInputManager'):SendKeyEvent(true, "Z", false, game)
																	wait(.1)
																	game:service('VirtualInputManager'):SendKeyEvent(false, "Z", false, game)
																end
																if _G.Skillx and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbssb.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.X then
																	game:service('VirtualInputManager'):SendKeyEvent(true, "X", false, game)
																	wait(.1)
																	game:service('VirtualInputManager'):SendKeyEvent(false, "X", false, game)
																end
																if _G.Skillc and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbssb.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.C then
																	game:service('VirtualInputManager'):SendKeyEvent(true, "C", false, game)
																	wait(.1)
																	game:service('VirtualInputManager'):SendKeyEvent(false, "C", false, game)
																end  
															elseif game:GetService("Players").LocalPlayer.Character:FindFirstChild("Venom-Venom") then
																if _G.Skillz and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbssb.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.Z then
																	game:service('VirtualInputManager'):SendKeyEvent(true, "Z", false, game)
																	wait(4)
																	game:service('VirtualInputManager'):SendKeyEvent(false, "Z", false, game)
																end
																if _G.Skillx and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbssb.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.X then
																	game:service('VirtualInputManager'):SendKeyEvent(true, "X", false, game)
																	wait(.1)
																	game:service('VirtualInputManager'):SendKeyEvent(false, "X", false, game)
																end
																if _G.Skillc and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbssb.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.C then
																	game:service('VirtualInputManager'):SendKeyEvent(true, "C", false, game)
																	wait(.1)
																	game:service('VirtualInputManager'):SendKeyEvent(false, "C", false, game)
																end
															elseif game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value) then
																game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value).MousePos.Value = vbssb.HumanoidRootPart.Position
																if _G.Skillz and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbssb.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.Z then
																	game:service('VirtualInputManager'):SendKeyEvent(true, "Z", false, game)
																	wait(.1)
																	game:service('VirtualInputManager'):SendKeyEvent(false, "Z", false, game)
																end
																if _G.Skillx and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbssb.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.X then
																	game:service('VirtualInputManager'):SendKeyEvent(true, "X", false, game)
																	wait(.1)
																	game:service('VirtualInputManager'):SendKeyEvent(false, "X", false, game)
																end
																if _G.Skillc and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbssb.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.C then
																	game:service('VirtualInputManager'):SendKeyEvent(true, "C", false, game)
																	wait(.1)
																	game:service('VirtualInputManager'):SendKeyEvent(false, "C", false, game)
																end
																if _G.Skillv and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbssb.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.V then
																	game:service('VirtualInputManager'):SendKeyEvent(true, "V", false, game)
																	wait(.1)
																	game:service('VirtualInputManager'):SendKeyEvent(false, "V", false, game)
																end
															end
															EquipAllWeapon()
															PositionSkillMasteryDevilFruit = vbssb.VehicleSeat.CFrame
															toTargetP(vbssb.VehicleSeat.CFrame * CFrame.new(0,30,0))
															Skillaimbot = true
														until not  _G.AUTO_SAHRK_ANCHOR or not vbssb.Parent or vbssb.Humanoid.Value <= 0 or not game:GetService("Workspace").Enemies:FindFirstChild("PirateBrigade")
														AutoSkill = false
														Skillaimbot = false
													end
												end
											end
										end
									end
								else
									if game:GetService("Workspace").Enemies:FindFirstChild("PirateGrandBrigade") then
										for iu,vbs in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
											if vbs.Name == "PirateGrandBrigade" then
												if vbs:FindFirstChild("VehicleSeat") then
													repeat task.wait()
														game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = false
														if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
															game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
														end
														if game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value) then
															MasteryDevilFruit = require(game:GetService("Players").LocalPlayer.Character[game.Players.LocalPlayer.Data.DevilFruit.Value].Data)
															DevilFruitMastery = game:GetService("Players").LocalPlayer.Character[game.Players.LocalPlayer.Data.DevilFruit.Value].Level.Value
														elseif game:GetService("Players").LocalPlayer.Backpack:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value) then
															MasteryDevilFruit = require(game:GetService("Players").LocalPlayer.Backpack[game.Players.LocalPlayer.Data.DevilFruit.Value].Data)
															DevilFruitMastery = game:GetService("Players").LocalPlayer.Backpack[game.Players.LocalPlayer.Data.DevilFruit.Value].Level.Value
														end
														AutoSkill = true
														UseSkillMasteryDevilFruit = true
														if game:GetService("Players").LocalPlayer.Character:FindFirstChild("Dragon-Dragon") then
															if _G.Skillz and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbs.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.Z then
																game:service('VirtualInputManager'):SendKeyEvent(true, "Z", false, game)
																wait(.1)
																game:service('VirtualInputManager'):SendKeyEvent(false, "Z", false, game)
															end
															if _G.Skillx and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbs.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.X then
																game:service('VirtualInputManager'):SendKeyEvent(true, "X", false, game)
																wait(.1)
																game:service('VirtualInputManager'):SendKeyEvent(false, "X", false, game)
															end   
														elseif game:GetService("Players").LocalPlayer.Character:FindFirstChild("Human-Human: Buddha") then
															if _G.Skillz and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbs.Humanoid.Health > 0 and game.Players.LocalPlayer.Character.HumanoidRootPart.Size == Vector3.new(7.6, 7.676, 3.686) and DevilFruitMastery >= MasteryDevilFruit.Lvl.Z then
															else
																game:service('VirtualInputManager'):SendKeyEvent(true, "Z", false, game)
																wait(.1)
																game:service('VirtualInputManager'):SendKeyEvent(false, "Z", false, game)
															end
															if _G.Skillx and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbs.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.X then
																game:service('VirtualInputManager'):SendKeyEvent(true, "X", false, game)
																wait(.1)
																game:service('VirtualInputManager'):SendKeyEvent(false, "X", false, game)
															end
															if _G.Skillc and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbs.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.C then
																game:service('VirtualInputManager'):SendKeyEvent(true, "C", false, game)
																wait(.1)
																game:service('VirtualInputManager'):SendKeyEvent(false, "C", false, game)
															end  
														elseif game:GetService("Players").LocalPlayer.Character:FindFirstChild("Venom-Venom") then
															if _G.Skillz and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbs.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.Z then
																game:service('VirtualInputManager'):SendKeyEvent(true, "Z", false, game)
																wait(4)
																game:service('VirtualInputManager'):SendKeyEvent(false, "Z", false, game)
															end
															if _G.Skillx and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbs.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.X then
																game:service('VirtualInputManager'):SendKeyEvent(true, "X", false, game)
																wait(.1)
																game:service('VirtualInputManager'):SendKeyEvent(false, "X", false, game)
															end
															if _G.Skillc and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbs.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.C then
																game:service('VirtualInputManager'):SendKeyEvent(true, "C", false, game)
																wait(.1)
																game:service('VirtualInputManager'):SendKeyEvent(false, "C", false, game)
															end
														elseif game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value) then
															game:GetService("Players").LocalPlayer.Character:FindFirstChild(game.Players.LocalPlayer.Data.DevilFruit.Value).MousePos.Value = vbs.HumanoidRootPart.Position
															if _G.Skillz and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbs.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.Z then
																game:service('VirtualInputManager'):SendKeyEvent(true, "Z", false, game)
																wait(.1)
																game:service('VirtualInputManager'):SendKeyEvent(false, "Z", false, game)
															end
															if _G.Skillx and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbs.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.X then
																game:service('VirtualInputManager'):SendKeyEvent(true, "X", false, game)
																wait(.1)
																game:service('VirtualInputManager'):SendKeyEvent(false, "X", false, game)
															end
															if _G.Skillc and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbs.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.C then
																game:service('VirtualInputManager'):SendKeyEvent(true, "C", false, game)
																wait(.1)
																game:service('VirtualInputManager'):SendKeyEvent(false, "C", false, game)
															end
															if _G.Skillv and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and vbs.Humanoid.Health > 0 and DevilFruitMastery >= MasteryDevilFruit.Lvl.V then
																game:service('VirtualInputManager'):SendKeyEvent(true, "V", false, game)
																wait(.1)
																game:service('VirtualInputManager'):SendKeyEvent(false, "V", false, game)
															end
														end
														EquipAllWeapon()
														PositionSkillMasteryDevilFruit = vbs.VehicleSeat.CFrame
														toTargetP(vbs.VehicleSeat.CFrame * CFrame.new(0,50,0))
														Skillaimbot = true
													until not  _G.AUTO_SAHRK_ANCHOR or not vbs.Parent or vbs.Humanoid.Value <= 0 or not game:GetService("Workspace").Enemies:FindFirstChild("PirateGrandBrigade")
													AutoSkill = false
													Skillaimbot = false
												end
											end
										end
									end
								end
							else
								if game:GetService("Workspace").Enemies:FindFirstChild("Fish Crew Member") then
									for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
										if v.Name == "Fish Crew Member" then
											if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
												repeat task.wait()
													game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = false
													if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
														game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
													end
													EquipWeapon(_G.SelectToolWeapon)
													FastAttackSpeed = true
													v.HumanoidRootPart.Size = Vector3.new(60,60,60)
													v.Humanoid.JumpPower = 0
													v.Humanoid.WalkSpeed = 0
													v.HumanoidRootPart.CanCollide = false
													toTargetP(v.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
												until not  _G.AUTO_SAHRK_ANCHOR or not v.Parent or v.Humanoid.Health <= 0 or not game:GetService("Workspace").Enemies:FindFirstChild("Terrorshark")
											end
										end
									end
								else
									repeat wait()
										toTargetP(game:GetService("ReplicatedStorage"):FindFirstChild("Fish Crew Member").HumanoidRootPart.CFrame * CFrame.new(0,35,0))
									until not _G.AUTO_SAHRK_ANCHOR or game:GetService("Workspace").Enemies:FindFirstChild("Fish Crew Member")
								end
							end
						else
							if game:GetService("Workspace").Enemies:FindFirstChild("Piranha") then
								for is,vs in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
									if vs.Name == "Piranha" then
										if vs:FindFirstChild("Humanoid") and vs:FindFirstChild("HumanoidRootPart") and vs.Humanoid.Health > 0 then
											repeat task.wait()
												game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = false
												if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
													game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
												end
												EquipWeapon(_G.SelectToolWeapon)
												FastAttackSpeed = true
												vs.HumanoidRootPart.Size = Vector3.new(60,60,60)
												vs.Humanoid.JumpPower = 0
												vs.Humanoid.WalkSpeed = 0
												vs.HumanoidRootPart.CanCollide = false
												toTargetP(vs.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
											until not  _G.AUTO_SAHRK_ANCHOR or not vs.Parent or vs.Humanoid.Health <= 0 or not game:GetService("Workspace").Enemies:FindFirstChild("Piranha")
										end
									end
								end
							else
								repeat wait()
									toTargetP(game:GetService("ReplicatedStorage"):FindFirstChild("Piranha").HumanoidRootPart.CFrame * CFrame.new(0,35,0))
								until not _G.AUTO_SAHRK_ANCHOR or game:GetService("Workspace").Enemies:FindFirstChild("Piranha")
							end
						end
					else
						if game:GetService("Workspace").Enemies:FindFirstChild("Shark") then
							for iss,vss in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
								if vss.Name == "Shark" then
									if vss:FindFirstChild("Humanoid") and vss:FindFirstChild("HumanoidRootPart") and vss.Humanoid.Health > 0 then
										repeat task.wait()
											game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = false
											if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
												game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
											end
											EquipWeapon(_G.SelectToolWeapon)
											FastAttackSpeed = true
											toTargetP(vss.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
										until not  _G.AUTO_SAHRK_ANCHOR or not vss.Parent or vss.Humanoid.Health <= 0 or not game:GetService("Workspace").Enemies:FindFirstChild("Shark")
									end
								end
							end
						else
							repeat wait()
								toTargetP(game:GetService("ReplicatedStorage"):FindFirstChild("Shark").HumanoidRootPart.CFrame * CFrame.new(0,35,0))
							until not _G.AUTO_SAHRK_ANCHOR or game:GetService("Workspace").Enemies:FindFirstChild("Shark")
						end
					end
				else
					if game:GetService("Workspace").Enemies:FindFirstChild("Terrorshark") then
						for iss,vss in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
							if vss.Name == "Terrorshark" then
								if vss:FindFirstChild("Humanoid") and vss:FindFirstChild("HumanoidRootPart") and vss.Humanoid.Health > 0 then
									MaxHealth = game.Players.LocalPlayer.Character.Humanoid.MaxHealth * 30/100
									repeat task.wait()
										game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = false
										if game.Players.LocalPlayer.Character.Humanoid.Health <= MaxHealth then
											toTargetP(vss.HumanoidRootPart.CFrame * CFrame.new(0,300,0))
										else
											if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
												game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
											end
											EquipWeapon(_G.SelectToolWeapon)
											FastAttackSpeed = true
											toTargetP(vss.HumanoidRootPart.CFrame * CFrame.new(0,40,0))
										end
									until not  _G.AUTO_SAHRK_ANCHOR or not vss.Parent or vss.Humanoid.Health <= 0 or not game:GetService("Workspace").Enemies:FindFirstChild("Shark")
								end
							end
						end
					else
						repeat wait()
							toTargetP(game:GetService("ReplicatedStorage"):FindFirstChild("Terrorshark").HumanoidRootPart.CFrame * CFrame.new(0,35,0))
						until not _G.AUTO_SAHRK_ANCHOR or game:GetService("Workspace").Enemies:FindFirstChild("Terrorshark")
					end
				end
			end)
		end
	end
end)

task.spawn(function()
	game:GetService("RunService").Stepped:Connect(function()
		pcall(function()
			--[World 1]
			if _G.AUTO_SAHRK_ANCHOR or _G.Auto_Cake_Prince then
				if syn then
					setfflag("HumanoidParallelRemoveNoPhysics", "False")
					setfflag("HumanoidParallelRemoveNoPhysicsNoSimulate2", "False")
					game.Players.LocalPlayer.Character.Humanoid:ChangeState(11)
					if game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit == true then
						game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = false
					end
				else
					if game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
						if not game:GetService("Players").LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyVelocity1") then
							if game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit == true then
								game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = false
							end
							local BodyVelocity = Instance.new("BodyVelocity")
							BodyVelocity.Name = "BodyVelocity1"
							BodyVelocity.Parent =  game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
							BodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
							BodyVelocity.Velocity = Vector3.new(0, 0, 0)
						end
					end
					for _, v in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
						if v:IsA("BasePart") then
							v.CanCollide = false    
						end
					end
				end
			else
				if game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyVelocity1") then
					game.Players.LocalPlayer.Character.HumanoidRootPart:FindFirstChild("BodyVelocity1"):Destroy();
				end
			end
		end)
	end)
end)

spawn(function()
    while wait(5) do
        --pcall(function()
            if _G.AUTO_TRROR_JAW then
                pcall(function()
                    local args = {
                        [1] = "CraftItem",
                        [2] = "Craft",
                        [3] = "TerrorJaw"
                    }
                    
                    JAW = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
                end)
                if tostring(JAW) == 2 then
                    break
                end
            end
            if _G.AUTO_TOOTH_NECKLACE then
                pcall(function()
                    local args = {
                        [1] = "CraftItem",
                        [2] = "Craft",
                        [3] = "ToothNecklace"
                    }
                    
                    NECKLACE = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
                end)
                if tostring(NECKLACE) == 2 then
                    break
                end
            end
            if _G.AUTO_SAHRK_ANCHOR then
                pcall(function()
                    local args = {
                        [1] = "CraftItem",
                        [2] = "Craft",
                        [3] = "SharkAnchor"
                    }
                    
                    SharkAnchor = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
                end)
                if tostring(SharkAnchor) == 2 then
                    break
                end
            end
        --end)
    end
end)

Main:AddLabel("")
Magnet=Main:AddLabel("")
Terror=Main:AddLabel("")
Wings=Main:AddLabel("")
Golds=Main:AddLabel("")
Tooth=Main:AddLabel("")
Main:AddLabel("")
Jaw=Main:AddLabel("")
Terror2=Main:AddLabel("")
Mutant=Main:AddLabel("")
Golds2=Main:AddLabel("")
Tooth2=Main:AddLabel("")
Main:AddLabel("")
Necklace=Main:AddLabel("")
Mutant2=Main:AddLabel("")
Tooth3=Main:AddLabel("")

spawn(function()
    pcall(function()
        while true do wait()
            if _G.AUTO_SAHRK_ANCHOR then
                if Check_Weapon("Shark Anchor") == "Have" then
                    Anchor:Set("⚓ Shark Anchor: 🟢")
                else
                    Anchor:Set("⚓ Shark Anchor: 🔴")
                end
                if Check_Weapon("Terror Jaw") == "Have" then
                    Jaw:Set("🦈 Terror Jaw: 🟢")
                else
                    Jaw:Set("🦈 Terror Jaw: 🔴")
                end
                if Check_Weapon("Shark Tooth Necklace") == "Have" then
                    Necklace:Set("📿 Shark Tooth Necklace: 🟢")
                else
                    Necklace:Set("📿 Shark Tooth Necklace: 🔴")
                end
                if Check_Number("Monster Magnet") >= 1 then
                    Magnet:Set("🧭 Monster Magnet: 🟢")
                else
                    Magnet:Set("🧭 Monster Magnet: 🔴")
                end
                if Check_Number("Terror Eyes") >= 2 then
                    Terror:Set("🟢 Terror Eyes:".. Check_Number("Terror Eyes") .."/2")
                else
                    Terror:Set("🔴 Terror Eyes: ".. Check_Number("Terror Eyes") .."/2")
                end
                if Check_Number("Electric Wing") >= 8 then
                    Wings:Set("🟢 Electric Wings:".. Check_Number("Electric Wing") .."/8")
                else
                    Wings:Set("🔴 Electric Wings: ".. Check_Number("Electric Wing") .."/8")
                end
                if Check_Number("Fool's Gold") >= 20 then
                    Golds:Set("🟢 Fool's Golds:".. Check_Number("Fool's Gold") .."/20")
                else
                    Golds:Set("🔴 Fool's Golds: ".. Check_Number("Fool's Gold") .."/20")
                end
                if Check_Number("Shark Tooth") >= 10 then
                    Tooth:Set("🟢 Shark Tooth:".. Check_Number("Shark Tooth") .."/10")
                else
                    Tooth:Set("🔴 Shark Tooth: ".. Check_Number("Shark Tooth") .."/10")
                end
                if Check_Number("Terror Eyes") >= 1 then
                    Terror2:Set("🟢 Terror Eyes:".. Check_Number("Terror Eyes") .."/1")
                else
                    Terror2:Set("🔴 Terror Eyes: ".. Check_Number("Terror Eyes") .."/1")
                end
                if Check_Number("Mutant Tooth") >= 2 then
                    Mutant:Set("🟢 Mutant Tooth:".. Check_Number("Mutant Tooth") .."/2")
                else
                    Mutant:Set("🔴 Mutant Tooth: ".. Check_Number("Mutant Tooth") .."/2")
                end
                if Check_Number("Fool's Gold") >= 10 then
                    Golds2:Set("🟢 Fool's Golds:".. Check_Number("Fool's Gold") .."/10")
                else
                    Golds2:Set("🔴 Fool's Golds: ".. Check_Number("Fool's Gold") .."/10")
                end
                if Check_Number("Shark Tooth") >= 5 then
                    Tooth2:Set("🟢 Shark Tooth:".. Check_Number("Shark Tooth") .."/5")
                else
                    Tooth2:Set("🔴 Shark Tooth: ".. Check_Number("Shark Tooth") .."/5")
                end
                if Check_Number("Shark Tooth") >= 5 then
                    Tooth3:Set("🟢 Shark Tooth:".. Check_Number("Shark Tooth") .."/5")
                else
                    Tooth3:Set("🔴 Shark Tooth: ".. Check_Number("Shark Tooth") .."/5")
                end
                if Check_Number("Mutant Tooth") >= 1 then
                    Mutant2:Set("🟢 Mutant Tooth:".. Check_Number("Mutant Tooth") .."/1")
                else
                    Mutant2:Set("🔴 Mutant Tooth: ".. Check_Number("Mutant Tooth") .."/1")
                end
            else
                Jaw:Set("")
                Magnet:Set("")
                Terror:Set("")
                Wings:Set("")
                Golds:Set("")
                Tooth:Set("")
                Terror2:Set("")
                Mutant:Set("")
                Golds2:Set("")
                Tooth2:Set("")
                Tooth3:Set("")
                Necklace:Set("")
                Mutant2:Set("")
            end
        end
    end)
end)

WeaponList = {}
            
for i,v in pairs(game:GetService("Players").LocalPlayer.Backpack:GetChildren()) do  
    if v:IsA("Tool") then
        table.insert(WeaponList ,v.Name)
    end
end

for i,v in pairs(game:GetService("Players").LocalPlayer.Character:GetChildren()) do  
    if v:IsA("Tool") then
        table.insert(WeaponList ,v.Name)
    end
end
Main2:AddDropdown({
	Name = "Selected Weapon / Combat",
	Default = "1",
	Options = WeaponList,
	Callback = function(Value)
		_G.SelectToolWeapon = Value
	end    
})
_G.FAST_ATTACK = true;
Main2:AddToggle({
	Name = "Fast Attack",
	Default = _G.FAST_ATTACK,
	Callback = function(Value)
		_G.FAST_ATTACK = Value
	end    
})
_G.Skillz = true
_G.Skillx = true
_G.Skillc = true
_G.Skillv = true
Main2:AddToggle({
	Name = "Skill Z",
	Default = _G.Skillz,
	Callback = function(Value)
		_G.Skillz = Value
	end    
})
Main2:AddToggle({
	Name = "Skill X",
	Default = _G.Skillx,
	Callback = function(Value)
		_G.Skillx = Value
	end    
})
Main2:AddToggle({
	Name = "Skill C",
	Default = _G.Skillc,
	Callback = function(Value)
		_G.Skillc = Value
	end    
})
Main2:AddToggle({
	Name = "Skill V",
	Default = _G.Skillv,
	Callback = function(Value)
		_G.Skillv = Value
	end    
})
spawn(function()
    while wait() do
        pcall(function()
            if AutoSkill then
                if _G.Skillz then
                    game:service('VirtualInputManager'):SendKeyEvent(true, "Z", false, game)
                    wait(.1)
                    game:service('VirtualInputManager'):SendKeyEvent(false, "Z", false, game)
                end
                if _G.Skillx then
                    game:service('VirtualInputManager'):SendKeyEvent(true, "X", false, game)
                    wait(.1)
                    game:service('VirtualInputManager'):SendKeyEvent(false, "X", false, game)
                end
                if _G.Skillc then
                    game:service('VirtualInputManager'):SendKeyEvent(true, "C", false, game)
                    wait(.1)
                    game:service('VirtualInputManager'):SendKeyEvent(false, "C", false, game)
                end
                if _G.Skillv then
                    game:service('VirtualInputManager'):SendKeyEvent(true, "V", false, game)
                    wait(.1)
                    game:service('VirtualInputManager'):SendKeyEvent(false, "V", false, game)
                end
            end
        end)
    end
end)


getgenv().BringMobs = function(F, z)
	coroutine.wrap(
		function()
			pcall(
				function()
					for U, d in pairs(game.Workspace.Enemies:GetChildren()) do
						if d:FindFirstChild("Humanoid") and d:FindFirstChild("HumanoidRootPart") and (d.Name == z) then
							if isnetworkowner ~= nil and isnetworkowner(d:FindFirstChild("HumanoidRootPart")) then
								d:FindFirstChild("HumanoidRootPart").CanCollide = false
								d:FindFirstChild("HumanoidRootPart").Transparency = 1
								d:FindFirstChild("Humanoid"):ChangeState(11)
								d:FindFirstChild("HumanoidRootPart").Size = Vector3.new(80,80,80)
								d:FindFirstChild("Humanoid").Sit = true
								d:FindFirstChild("Humanoid").WalkSpeed = 0
								d:FindFirstChild("Humanoid").JumpPower = 0
								if not d:FindFirstChild("HumanoidRootPart"):FindFirstChild("BV") then
									local m = Instance.new("BodyVelocity")
									m.Parent = d:FindFirstChild("HumanoidRootPart")
									m.Name = "BV"
									m.MaxForce = Vector3.new(100000, 100000, 100000)
									m.Velocity = Vector3.new(0, 0, 0)
								end
								if d:FindFirstChild("Humanoid"):FindFirstChild("Animator") then
									d:FindFirstChild("Humanoid"):FindFirstChild("Animator"):Remove()
								end
								d:FindFirstChild("HumanoidRootPart").CFrame = F
								sethiddenproperty(game:GetService("Players").LocalPlayer,"SimulationRadius",math.huge)
							elseif (F.Position - d.HumanoidRootPart.Position).magnitude < 300 then
								d:FindFirstChild("HumanoidRootPart").CanCollide = false
								d:FindFirstChild("HumanoidRootPart").Transparency = 1
								d:FindFirstChild("Humanoid"):ChangeState(11)
								d:FindFirstChild("HumanoidRootPart").Size = Vector3.new(80,80,80)
								d:FindFirstChild("Humanoid").Sit = true
								d:FindFirstChild("Humanoid").WalkSpeed = 0
								d:FindFirstChild("Humanoid").JumpPower = 0
								if not d:FindFirstChild("HumanoidRootPart"):FindFirstChild("BV") then
									local u = Instance.new("BodyVelocity")
									u.Parent = d:FindFirstChild("HumanoidRootPart")
									u.Name = "BV"
									u.MaxForce = Vector3.new(100000, 100000, 100000)
									u.Velocity = Vector3.new(0, 0, 0)
								end
								if d:FindFirstChild("Humanoid"):FindFirstChild("Animator") then
									d:FindFirstChild("Humanoid"):FindFirstChild("Animator"):Remove()
								end
								d:FindFirstChild("HumanoidRootPart").CFrame = F
								sethiddenproperty(game:GetService("Players").LocalPlayer,"SimulationRadius",math.huge)
						end
					end
				end
			end)
		end
	)()
	end
spawn(function()
	while wait() do
		if _G.Auto_Cake_Prince then
			pcall(function()
				if _G.Enable_Spawn_Cake then
					if KillMob == 0 then
						game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("CakePrinceSpawner",true)
					end
				end
				if game.ReplicatedStorage:FindFirstChild("Cake Prince") or game:GetService("Workspace").Enemies:FindFirstChild("Cake Prince") then
					if game:GetService("Workspace").Enemies:FindFirstChild("Cake Prince") then
						for i,v in pairs(game.Workspace.Enemies:GetChildren()) do
							if _G.Auto_Cake_Prince and v.Name == "Cake Prince" and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
								repeat wait()
									if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
										local args = {
											[1] = "Buso"
										}
										game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
									end
									EquipWeapon(_G.SelectToolWeapon)
									FastAttackSpeed = true
									PosMonDoughtOpenDoor = v.HumanoidRootPart.CFrame
									v.HumanoidRootPart.Size = Vector3.new(60,60,60)
									v.Humanoid.JumpPower = 0
									v.Humanoid.WalkSpeed = 0
									v.HumanoidRootPart.CanCollide = false
									toTargetP(v.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
								until not _G.Auto_Cake_Prince or not v.Parent or v.Humanoid.Health <= 0
								FastAttackSpeed = false
							end
						end
					else
						if game:GetService("Workspace").Map.CakeLoaf.BigMirror.Other.Transparency == 0 and (CFrame.new(-1990.672607421875, 4532.99951171875, -14973.6748046875).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude >= 2000 then
							FastAttackSpeed = false
							repeat wait()
								Questtween = toTargetP(CFrame.new(-2151.82153, 149.315704, -12404.9053))
							until not _G.Auto_Cake_Prince or (CFrame.new(-2151.82153, 149.315704, -12404.9053).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300
							if (CFrame.new(-2151.82153, 149.315704, -12404.9053).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300 then
								if Questtween then Questtween:Stop() end
								game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2151.82153, 149.315704, -12404.9053)
								wait(.1)
							end
						end 
					end
				else
					if game:GetService("Workspace").Enemies:FindFirstChild("Cookie Crafter") or game:GetService("Workspace").Enemies:FindFirstChild("Cake Guard") or game:GetService("Workspace").Enemies:FindFirstChild("Baking Staff") or game:GetService("Workspace").Enemies:FindFirstChild("Head Baker") then
						for i,v in pairs(game.Workspace.Enemies:GetChildren()) do
							if (v.Name == "Cookie Crafter" or v.Name == "Cake Guard" or v.Name == "Baking Staff" or v.Name == "Head Baker") and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
								repeat wait()
									if (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude > 300 then
										Farmtween = toTargetP(v.HumanoidRootPart.CFrame)
									elseif (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 300 then
										if Farmtween then
											Farmtween:Stop()
										end
										if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
											local args = {
												[1] = "Buso"
											}
											game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
										end
										EquipWeapon(_G.SelectToolWeapon)
										BringMobs(v.HumanoidRootPart.CFrame,v.Name)
										FastAttackSpeed = true
										MagnetDought = true
										PosMonDoughtOpenDoor = v.HumanoidRootPart.CFrame
										v.HumanoidRootPart.Size = Vector3.new(60,60,60)
										v.Humanoid.JumpPower = 0
										v.Humanoid.WalkSpeed = 0
										v.HumanoidRootPart.CanCollide = false
										toTargetP(v.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
									end
								until not _G.Auto_Cake_Prince or not v.Parent or v.Humanoid.Health <= 0
								MagnetDought = false
								FastAttackSpeed = false
							end
						end
					else
						repeat wait()
							Questtween = toTargetP(CFrame.new(-2077, 252, -12373))
						until not _G.Auto_Cake_Prince or (CFrame.new(-2077, 252, -12373).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 200
						if (CFrame.new(-2077, 252, -12373).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 200 then
							if Questtween then Questtween:Stop() end
							game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2077, 252, -12373)
						end
					end
				end
			end)
		end
	end
end)
spawn(function()
	while true do wait()
		pcall(function()
			if _G.Auto_Cake_Prince and MagnetDought then
				if (v.Name == "Cookie Crafter" or v.Name == "Cake Guard" or v.Name == "Baking Staff" or v.Name == "Head Baker") and (v.HumanoidRootPart.Position - PosMonDoughtOpenDoor.Position).Magnitude <= 250 and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
					v.HumanoidRootPart.Size = Vector3.new(50,50,50)
					v.HumanoidRootPart.CanCollide = false
					v.Head.CanCollide = false
					v.HumanoidRootPart.CFrame = PosMonDoughtOpenDoor
					if v.Humanoid:FindFirstChild("Animator") then
						v.Humanoid.Animator:Destroy()
					end
					sethiddenproperty(game:GetService("Players").LocalPlayer, "SimulationRadius", math.huge)
				end
			end
		end)
	end
end)
task.spawn(function()
    while wait() do
        for i,v in pairs(game:GetService("Workspace")["_WorldOrigin"]:GetChildren()) do
            pcall(function()
                if v.Name == ("CurvedRing") or v.Name == ("SlashHit") or v.Name == ("SwordSlash") or v.Name == ("SlashTail") or v.Name == ("Sounds") then
                    v:Destroy()
                end
            end)
        end
    end
end)
local CombatFramework = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("CombatFramework"))
local CombatFrameworkR = getupvalues(CombatFramework)[2]
local RigController = require(game:GetService("Players")["LocalPlayer"].PlayerScripts.CombatFramework.RigController)
local RigControllerR = getupvalues(RigController)[2]
local realbhit = require(game.ReplicatedStorage.CombatFramework.RigLib)
local SeraphFrame = debug.getupvalues(require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("CombatFramework")))[2]
local VirtualUser = game:GetService('VirtualUser')
local RigControllerR = debug.getupvalues(require(game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework.RigController))[2]
local Client = game:GetService("Players").LocalPlayer
local DMG = require(Client.PlayerScripts.CombatFramework.Particle.Damage)
local cooldownfastattack = tick()
function SeraphFuckWeapon() 
	local p13 = SeraphFrame.activeController
	local wea = p13.blades[1]
	if not wea then return end
	while wea.Parent~=game.Players.LocalPlayer.Character do wea=wea.Parent end
	return wea
end

function getHits(Size)
	local Hits = {}
	local Enemies = workspace.Enemies:GetChildren()
	local Characters = workspace.Characters:GetChildren()
	for i=1,#Enemies do local v = Enemies[i]
		local Human = v:FindFirstChildOfClass("Humanoid")
		if Human and Human.RootPart and Human.Health > 0 and game.Players.LocalPlayer:DistanceFromCharacter(Human.RootPart.Position) < Size+5 then
			table.insert(Hits,Human.RootPart)
		end
	end
	for i=1,#Characters do local v = Characters[i]
		if v ~= game.Players.LocalPlayer.Character then
			local Human = v:FindFirstChildOfClass("Humanoid")
			if Human and Human.RootPart and Human.Health > 0 and game.Players.LocalPlayer:DistanceFromCharacter(Human.RootPart.Position) < Size+5 then
				table.insert(Hits,Human.RootPart)
			end
		end
	end
	return Hits
end

task.spawn(
	function()
		while wait(0) do
			if  _G.FAST_ATTACK and FastAttackSpeed then
				if SeraphFrame.activeController then
					-- if v.Humanoid.Health > 0 then
					SeraphFrame.activeController.timeToNextAttack = 0
					SeraphFrame.activeController.focusStart = 0
					SeraphFrame.activeController.hitboxMagnitude = 40
					SeraphFrame.activeController.humanoid.AutoRotate = true
					SeraphFrame.activeController.increment = 1 + 1 / 1
					-- end
				end
			end
		end
	end)

function Boost()
	spawn(function()
		game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("weaponChange",tostring(SeraphFuckWeapon()))
	end)
end

function Unboost()
	spawn(function()
		game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("unequipWeapon",tostring(SeraphFuckWeapon()))
	end)
end

local cdnormal = 0
local Animation = Instance.new("Animation")
local CooldownFastAttack = 0
Attack = function()
	local ac = SeraphFrame.activeController
	if ac and ac.equipped then
		task.spawn(
			function()
				if tick() - cdnormal > 0.5 then
					ac:attack()
					cdnormal = tick()
				else
					Animation.AnimationId = ac.anims.basic[2]
					ac.humanoid:LoadAnimation(Animation):Play(2, 2) --ท่าไม่ทำงานแก้เป็น (1,1)
					game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("hit", getHits(120), 2, "")
				end
			end)
	end
end

b = tick()
spawn(function()
	while wait(0) do
		if  _G.FAST_ATTACK and FastAttackSpeed then
			if b - tick() > 0.75 then
				wait(.2)
				b = tick()
			end
			pcall(function()
				for i, v in pairs(game.Workspace.Enemies:GetChildren()) do
					if v.Humanoid.Health > 0 then
						if (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 40 then
							Attack()
							wait(0)
							Boost()
						end
					end
				end
			end)
		end
	end
end)

k = tick()
spawn(function()
	while wait(0) do
		if  _G.FAST_ATTACK and FastAttackSpeed then
			if k - tick() > 0.75 then
				wait(0)
				k = tick()
			end
			pcall(function()
				for i, v in pairs(game.Workspace.Enemies:GetChildren()) do
					if v.Humanoid.Health > 0 then
						if (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 40 then
							wait(0)
							Unboost()
						end
					end
				end
			end)
		end
	end
end)

tjw1 = true
task.spawn(
	function()
		local a = game.Players.LocalPlayer
		local b = require(a.PlayerScripts.CombatFramework.Particle)
		local c = require(game:GetService("ReplicatedStorage").CombatFramework.RigLib)
		if not shared.orl then
			shared.orl = c.wrapAttackAnimationAsync
		end
		if not shared.cpc then
			shared.cpc = b.play
		end
		if tjw1 then
			pcall(
				function()
					c.wrapAttackAnimationAsync = function(d, e, f, g, h)
						local i = c.getBladeHits(e, f, g)
						if i then
							b.play = function()
							end
							d:Play(15.25, 15.25, 15.25)
							h(i)
							b.play = shared.cpc
							wait(0)
							d:Stop()
						end
					end
				end
			)
		end
	end
)
function AttackFunction()
	local ac = CombatFrameworkR.activeController
	if ac and ac.equipped then
		for indexincrement = 1, 1 do
			local bladehit = getHits(60)
			if #bladehit > 0 then
				local AcAttack8 = debug.getupvalue(ac.attack, 5)
				local AcAttack9 = debug.getupvalue(ac.attack, 6)
				local AcAttack7 = debug.getupvalue(ac.attack, 4)
				local AcAttack10 = debug.getupvalue(ac.attack, 7)
				local NumberAc12 = (AcAttack8 * 798405 + AcAttack7 * 727595) % AcAttack9
				local NumberAc13 = AcAttack7 * 798405
				(function()
					NumberAc12 = (NumberAc12 * AcAttack9 + NumberAc13) % 1099511627776
					AcAttack8 = math.floor(NumberAc12 / AcAttack9)
					AcAttack7 = NumberAc12 - AcAttack8 * AcAttack9
				end)()
				AcAttack10 = AcAttack10 + 1
				debug.setupvalue(ac.attack, 5, AcAttack8)
				debug.setupvalue(ac.attack, 6, AcAttack9)
				debug.setupvalue(ac.attack, 4, AcAttack7)
				debug.setupvalue(ac.attack, 7, AcAttack10)
				for k, v in pairs(ac.animator.anims.basic) do
					v:Play(0.01,0.01,0.01)
				end                 
				if game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool") and ac.blades and ac.blades[1] then 
					game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("weaponChange",tostring(SeraphFuckWeapon()))
					game.ReplicatedStorage.Remotes.Validator:FireServer(math.floor(NumberAc12 / 1099511627776 * 16777215), AcAttack10)
					game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("hit", bladehit, 2, "") 
				end
			end
		end
	end
end
coroutine.wrap(function()
	while task.wait() do
		local ac = CombatFrameworkR.activeController
		if ac and ac.equipped then
			wait(.1)
			if _G.FAST_ATTACK and FastAttackSpeed then
				AttackFunction()
				if tick() - cooldownfastattack > 1.5 then wait(.01) cooldownfastattack = tick() end
			elseif _G.FAST_ATTACK and not FastAttackSpeed then
				if ac.hitboxMagnitude ~= 55 then
					ac.hitboxMagnitude = 55
				end
				ac:attack()
			end
		end
	end
end)()


local CameRa = require(game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework.CameraShaker)
CameRa.CameraShakeInstance.CameraShakeState = {FadingIn = 3,FadingOut = 2,Sustained = 0,Inactive =1}

local Client = game.Players.LocalPlayer
local STOP = require(Client.PlayerScripts.CombatFramework.Particle)
local STOPRL = require(game:GetService("ReplicatedStorage").CombatFramework.RigLib)
task.spawn(function()
	pcall(function()
		if not shared.orl then
			shared.orl = STOPRL.wrapAttackAnimationAsync
		end
		if not shared.cpc then
			shared.cpc = STOP.play 
		end
		spawn(function()
			require(game.ReplicatedStorage.Util.CameraShaker):Stop()
			game:GetService("RunService").Stepped:Connect(function()
				STOPRL.wrapAttackAnimationAsync = function(a,b,c,d,func)
					local Hits = STOPRL.getBladeHits(b,c,d)
					if Hits then
						if  _G.FAST_ATTACK and FastAttackSpeed then
							STOP.play = function() end
							a:Play(10.1,9.1,8.1)
							func(Hits)
							STOP.play = shared.cpc
							wait(a.length * 10.5)
							a:Stop()
						else
							func(Hits)
							STOP.play = shared.cpc
							wait(a.length * 10.5)
							a:Stop()
						end
					end
				end
			end)
		end)
	end)
end)
if game:GetService("ReplicatedStorage").Effect.Container:FindFirstChild("Death") then
    game:GetService("ReplicatedStorage").Effect.Container.Death:Destroy()
end
if game:GetService("ReplicatedStorage").Effect.Container:FindFirstChild("Respawn") then
    game:GetService("ReplicatedStorage").Effect.Container.Respawn:Destroy()
end
return OrionLib
