
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
function RobloxNotify(Ti,tab,icon,sec)
    game.StarterGui:SetCore("SendNotification", {
    Title = Ti,
    Text = tab,
    Icon = icon,
    Duration = sec,
    })
end
RobloxNotify("Welecome to Seraphy Hub",nil,nil,2)
local part = Instance.new("Part");
local lighting = game:GetService("Lighting");
local camera = game.Workspace.CurrentCamera
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Window = OrionLib:MakeWindow({Name = "Seraphy Premium", HidePremium = false, SaveConfig = true, ConfigFolder = "SeraphyTest"})


local Auto_Farm = Window:MakeTab({
	Name = "General",
	Icon = "rbxassetid://4483345998",
	PremiumOnly = false
})
local RACE = Window:MakeTab({
	Name = "Race V4",
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

Auto_Farm:AddToggle({
	Name = "Auto Caft Sanguine",
	Default = _G.Auto_Sanguine_Caft,
	Callback = function(Value)
		_G.START = Value
		_G.START2 = Value
	end    
})
_G.Rejoin = true
if _G.Auto_Selected_Weapon then
	_G.Selected_Weapon = "Melee"
end
task.spawn(function()
	while wait() do
		pcall(function()
			if _G.Selected_Weapon == "Melee" then
				for i ,v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
					if v.ToolTip == "Melee" then
						if game.Players.LocalPlayer.Backpack:FindFirstChild(tostring(v.Name)) then
							_G.Selected_Weapon = v.Name
						end
					end
				end
			end
		end)
	end
end)
local PlaceID = game.PlaceId
local AllIDs = {}
local foundAnything = ""
local actualHour = os.date("!*t").hour
local Deleted = false
function TPReturner()
    local Site;
    if foundAnything == "" then
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
    else
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
    end
    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        foundAnything = Site.nextPageCursor
    end
    local num = 0;
    for i,v in pairs(Site.data) do
        local Possible = true
        ID = tostring(v.id)
        if tonumber(v.maxPlayers) > tonumber(v.playing) then
            for _,Existing in pairs(AllIDs) do
                if num ~= 0 then
                    if ID == tostring(Existing) then
                        Possible = false
                    end
                else
                    if tonumber(actualHour) ~= tonumber(Existing) then
                        local delFile = pcall(function()
                            -- delfile("NotSameServers.json")
                            AllIDs = {}
                            table.insert(AllIDs, actualHour)
                        end)
                    end
                end
                num = num + 1
            end
            if Possible == true then
                table.insert(AllIDs, ID)
                wait()
                pcall(function()
                    -- writefile("NotSameServers.json", game:GetService('HttpService'):JSONEncode(AllIDs))
                    wait()
                    game:GetService("TeleportService"):TeleportToPlaceInstance(PlaceID, ID, game.Players.LocalPlayer)
                end)
                wait(.1)
            end
        end
    end
end

function Teleport() 
    while wait(1) do
        pcall(function()
            TPReturner()
            if foundAnything ~= "" then
                TPReturner()
            end
        end)
    end
end
local CombatFramework = require(game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework)
local Camera = require(game.ReplicatedStorage.Util.CameraShaker)
local Attack = 0.1
local backup = require(game:GetService("Players").LocalPlayer.PlayerScripts.CombatFramework)
local Crit = getupvalues(backup)[2]
local CombatFrameworkR = getupvalues(backup)[2]
local CameraShakerR = require(game.ReplicatedStorage.Util.CameraShaker)
local plr = game.Players.LocalPlayer
local CbFw = debug.getupvalues(require(plr.PlayerScripts.CombatFramework))
local CbFw2 = CbFw[2]
function maxincrement2()
	return #Crit.activeController.anims.basic
end
spawn(function()
    local old
    old = hookmetamethod(game, "__namecall",function(self,...)
        local method = getnamecallmethod() local args = {...}

        if method:lower() == "fireserver" then
            if args[1] == "hit" then
                args[3] = maxincrement2()
                return old(self,unpack(args))
            end end
        return old(self,...)
	end) 
end)
coroutine.wrap(function()
   time_stay_long = 0
   while wait() do
       pcall(function()
           stay_long_pos  = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
           wait(1)
           if game.Players.LocalPlayer.Character.HumanoidRootPart.Position == stay_long_pos then
               repeat wait(1)
                   time_stay_long += 1
               until game.Players.LocalPlayer.Character.HumanoidRootPart.Position ~= stay_long_pos or time_stay_long > 600
               if time_stay_long >= 600 then
                   Teleport() 
               else
                   time_stay_long = 0
               end
           end
       end)
   end
end)()
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
	Name = "Auto Pull Lever",
	Default = _G.Enable_Pull_Lever,
	Callback = function(Value)
		_G.Enable_Pull_Lever = Value
	end    
})
RACE:AddToggle({
	Name = "Auto Complete Trial",
	Default = _G.Enable_Complete_Trial,
	Callback = function(Value)
		_G.Enable_Complete_Trial = Value
	end    
})
RACE:AddToggle({
	Name = "Teleport To Race Doors",
	Default = _G.Enable_Teleport_Race_Doors,
	Callback = function(Value)
		_G.Enable_Teleport_Race_Doors = Value
	end    
})
RACE:AddToggle({
	Name = "Auto Quest Acient One",
	Default = _G.Enable_Auto_Acient_Quest,
	Callback = function(Value)
		_G.Enable_Auto_Acient_Quest = Value
	end    
})
RACE:AddButton({
	Name = "Temple Of Time",
	Callback = function()
		game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875,14895.3017578125, 102.62469482421875)
	end    
})
RACE:AddButton({
	Name = "Acient One",
	Callback = function()
		repeat wait()
			_G.Noclip = true
			if (CFrame.new(28981.552734375, 14888.4267578125, -120.245849609375).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude >= 1500 then
				game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875,14895.3017578125, 102.62469482421875)
			else
				toTargetP(CFrame.new(28981.552734375, 14888.4267578125, -120.245849609375))
			end
		until (CFrame.new(28981.552734375, 14888.4267578125, -120.245849609375).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 5
		_G.Noclip = false
	end
})


spawn(function()
	while wait() do
		pcall(function()
			if _G.Enable_Auto_Acient_Quest then
				heuantedcalstle = CFrame.new(-9520.55957, 271.553131, 6305.31055, 0.999997973, -7.37041717e-07, 0.0020507169, 7.32235378e-07, 1, 2.34449726e-06, -0.0020507169, -2.34299068e-06, 0.999997973)
				if game:GetService("Players").LocalPlayer.PlayerGui.TransformationHUD.ImageLabel.Visible == true then
					game:GetService("VirtualInputManager"):SendKeyEvent(true,"Y",false,game)
					game:GetService("VirtualInputManager"):SendKeyEvent(false,"Y",false,game)
					wait(1)
					toTargetP(CFrame.new(-9525.791015625, 676.1983032226562, 6559.06298828125))
					wait(1)
					game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer('UpgradeRace', 'Buy')
				else
					if game:GetService("Workspace").Enemies:FindFirstChild("Reborn Skeleton") or  game:GetService("Workspace").Enemies:FindFirstChild("Living Zombie") or  game:GetService("Workspace").Enemies:FindFirstChild("Demonic Soul") or  game:GetService("Workspace").Enemies:FindFirstChild("Posessed Mummy") then
						for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
							if v.Name == "Reborn Skeleton" or v.Name == "Living Zombie" or v.Name == "Demonic Soul" or v.Name == "Posessed Mummy" then
								if v.Humanoid.Health > 0 then
									repeat wait()
										if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
											local args = {
												[1] = "Buso"
											}
											game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
										end
										EquipWeapon(_G.SelectToolWeapon)
										StartMagnet = true
										PosMon = v.HumanoidRootPart.CFrame
										FastAttackSpeed = true
										toTargetP(v.HumanoidRootPart.CFrame * CFrame.new(0,30,0))--CFrame.new(7 , 30 , 20))
										v.Humanoid.JumpPower = 0
										v.Humanoid.WalkSpeed = 0
										v.HumanoidRootPart.CanCollide = false
										v.Humanoid:ChangeState(14)
										sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius",  math.huge)
									until not v.Parent or v.Humanoid.Health <= 0 or not _G.Enable_Auto_Acient_Quest or not game:GetService("Workspace").Enemies:FindFirstChild(v.Name)
									FastAttackSpeed = false
									StartMagnet=false
								end
							end
						end
					else
						StartMagnet=false
						FastAttackSpeed=false
						if (heuantedcalstle.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude >= 500 then
							toTargetP(heuantedcalstle)
						end
					end
				end
			end
		end)
	end
end)


local posX = 0
local posY = 30
local posZ = 0
spawn(function()
	pcall(function()
		while task.wait() do
			if _G.Enable_Complete_Trial then
				if game:GetService("Players").LocalPlayer.Data.Race.Value == "Human" then
					for i, v in pairs(game.Workspace.Enemies:GetDescendants()) do
						if v.Name == "Darkness Master" and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
							pcall(function()
								repeat
									wait(.1)
									v.Humanoid.Health = 0
									v.HumanoidRootPart.CanCollide = false
									EquipWeapon(_G.SelectToolWeapon)
									toTargetP(v.HumanoidRootPart.CFrame * CFrame(0,30,0))
									FastAttackSpeed = true
									sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
								until not _G.Enable_Complete_Trial or not v.Parent or v.Humanoid.Health <= 0
								FastAttackSpeed = false
							end)
						end
					end
				elseif game:GetService("Players").LocalPlayer.Data.Race.Value == "Skypiea" then
					for i, v in pairs(game:GetService("Workspace").Map.SkyTrial.Model:GetDescendants()) do
						toTargetP(game.Workspace.Map.SkyTrial.Model.FinishPart.CFrame)
					end
				elseif game:GetService("Players").LocalPlayer.Data.Race.Value == "Fishman" then
					for i, v in pairs(game:GetService("Workspace").SeaBeasts.SeaBeast1:GetDescendants()) do
						if v.Name == "HumanoidRootPart" then
							toTargetP(v.CFrame * CFrame.new(PosX, PosY, PosZ))
							for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
								if v:IsA("Tool") then
									if v.ToolTip == "Melee" then -- "Blox Fruit" , "Sword" , "Wear" , "Agility"
										game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
									end
								end
							end
							game:GetService("VirtualInputManager"):SendKeyEvent(true, 122, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							game:GetService("VirtualInputManager"):SendKeyEvent(false, 122, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							wait(.2)
							game:GetService("VirtualInputManager"):SendKeyEvent(true, 120, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							game:GetService("VirtualInputManager"):SendKeyEvent(false, 120, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							wait(.2)
							game:GetService("VirtualInputManager"):SendKeyEvent(true, 99, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							game:GetService("VirtualInputManager"):SendKeyEvent(false, 99, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							wait(.2)
							game:GetService("VirtualInputManager"):SendKeyEvent(false, 99, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
								if v:IsA("Tool") then
									if v.ToolTip == "Blox Fruit" then -- "Blox Fruit" , "Sword" , "Wear" , "Agility"
										game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
									end
								end
							end
							game:GetService("VirtualInputManager"):SendKeyEvent(true, 122, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							game:GetService("VirtualInputManager"):SendKeyEvent(false, 122, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							wait(.2)
							game:GetService("VirtualInputManager"):SendKeyEvent(true, 120, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							game:GetService("VirtualInputManager"):SendKeyEvent(false, 120, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							wait(.2)
							game:GetService("VirtualInputManager"):SendKeyEvent(true, 99, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							game:GetService("VirtualInputManager"):SendKeyEvent(false, 99, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							wait(0.5)
							for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
								if v:IsA("Tool") then
									if v.ToolTip == "Sword" then -- "Blox Fruit" , "Sword" , "Wear" , "Agility"
										game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
									end
								end
							end
							game:GetService("VirtualInputManager"):SendKeyEvent(true, 122, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							game:GetService("VirtualInputManager"):SendKeyEvent(false, 122, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							wait(.2)
							game:GetService("VirtualInputManager"):SendKeyEvent(true, 120, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							game:GetService("VirtualInputManager"):SendKeyEvent(false, 120, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							wait(.2)
							game:GetService("VirtualInputManager"):SendKeyEvent(true, 99, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							game:GetService("VirtualInputManager"):SendKeyEvent(false, 99, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							wait(0.5)
							for i, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
								if v:IsA("Tool") then
									if v.ToolTip == "Gun" then -- "Blox Fruit" , "Sword" , "Wear" , "Agility"
										game.Players.LocalPlayer.Character.Humanoid:EquipTool(v)
									end
								end
							end
							game:GetService("VirtualInputManager"):SendKeyEvent(true, 122, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							game:GetService("VirtualInputManager"):SendKeyEvent(false, 122, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							wait(.2)
							game:GetService("VirtualInputManager"):SendKeyEvent(true, 120, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							game:GetService("VirtualInputManager"):SendKeyEvent(false, 120, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							wait(.2)
							game:GetService("VirtualInputManager"):SendKeyEvent(true, 99, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
							game:GetService("VirtualInputManager"):SendKeyEvent(false, 99, false,game.Players.LocalPlayer.Character.HumanoidRootPart)
						end
					end
				elseif game:GetService("Players").LocalPlayer.Data.Race.Value == "Cyborg" then
					toTargetP(CFrame.new(28654, 14898.7832, -30, 1, 0, 0, 0, 1, 0, 0, 0, 1))
				elseif game:GetService("Players").LocalPlayer.Data.Race.Value == "Ghoul" then
					for i, v in pairs(game.Workspace.Enemies:GetDescendants()) do
						if v.Name == "Ancient Zombie" or v.Name == "Ancient Vamipire" and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
							pcall(function()
								repeat
									wait(.1)
									v.Humanoid.Health = 0
									v.HumanoidRootPart.CanCollide = false
									FastAttackSpeed = true
									EquipWeapon(_G.SelectToolWeapon)
									toTargetP(v.HumanoidRootPart.CFrame * CFrame(0,30,0))
									sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
								until not _G.Enable_Complete_Trial or not v.Parent or v.Humanoid.Health <= 0
								FastAttackSpeed = false
							end)
						end
					end
				elseif game:GetService("Players").LocalPlayer.Data.Race.Value == "Mink" then
					for i, v in pairs(game:GetService("Workspace"):GetDescendants()) do
						if v.Name == "StartPoint" then
							toTargetP(v.CFrame * CFrame.new(0, 9, 0))
						end
					end
				end
			end
		end
	end)
end)
spawn(function()
	while true do task.wait()
		if _G.Enable_Teleport_Race_Doors then
			pcall(function()
				if game:GetService("Players").LocalPlayer.Data.Race.Value == "Fishman" then
					repeat wait()
						_G.Noclip = true
						if (CFrame.new(28224.056640625, 14889.4267578125, -210.5872039794922).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude >= 1500 then
							game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875,14895.3017578125, 102.62469482421875)
						else
							toTargetP(CFrame.new(28224.056640625, 14889.4267578125, -210.5872039794922))
						end
					until (CFrame.new(28224.056640625, 14889.4267578125, -210.5872039794922).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 5 or not _G.Enable_Teleport_Race_Doors
					_G.Noclip = false
				elseif game:GetService("Players").LocalPlayer.Data.Race.Value == "Human" then
					repeat wait()
						_G.Noclip = true
						if (CFrame.new(29237.294921875, 14889.4267578125, -206.94955444335938).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude >= 1500 then
							game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875,14895.3017578125, 102.62469482421875)
						else
							toTargetP(CFrame.new(29237.294921875, 14889.4267578125, -206.94955444335938))
						end
					until (CFrame.new(29237.294921875, 14889.4267578125, -206.94955444335938).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 5 or not _G.Enable_Teleport_Race_Doors
					_G.Noclip = false
				elseif game:GetService("Players").LocalPlayer.Data.Race.Value == "Skypiea" then
					repeat wait()
						_G.Noclip = true
						if (CFrame.new(28967.408203125, 14918.0751953125, 234.31198120117188).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude >= 1500 then
							game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875,14895.3017578125, 102.62469482421875)
						else
							toTargetP(CFrame.new(28967.408203125, 14918.0751953125, 234.31198120117188))
						end
					until (CFrame.new(28967.408203125, 14918.0751953125, 234.31198120117188).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 5 or not _G.Enable_Teleport_Race_Doors
					_G.Noclip = false
				elseif game:GetService("Players").LocalPlayer.Data.Race.Value == "Cyborg" then
					repeat wait()
						_G.Noclip = true
						if (CFrame.new(28492.4140625, 14894.4267578125, -422.1100158691406).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude >= 1500 then
							game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875,14895.3017578125, 102.62469482421875)
						else
							toTargetP(CFrame.new(28492.4140625, 14894.4267578125, -422.1100158691406))
						end
					until (CFrame.new(28492.4140625, 14894.4267578125, -422.1100158691406).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 5 or not _G.Enable_Teleport_Race_Doors
					_G.Noclip = false
				elseif game:GetService("Players").LocalPlayer.Data.Race.Value == "Ghoul" then
					repeat wait()
						_G.Noclip = true
						if (CFrame.new(28672.720703125, 14889.1279296875, 454.5961608886719).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude >= 1500 then
							game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875,14895.3017578125, 102.62469482421875)
						else
							toTargetP(CFrame.new(28672.720703125, 14889.1279296875, 454.5961608886719))
						end
					until (CFrame.new(28672.720703125, 14889.1279296875, 454.5961608886719).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 5 or not _G.Enable_Teleport_Race_Doors
					_G.Noclip = false
				elseif game:GetService("Players").LocalPlayer.Data.Race.Value == "Mink" then
					repeat wait()
						_G.Noclip = true
						if (CFrame.new(29020.66015625, 14889.4267578125, -379.2682800292969).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude >= 1500 then
							game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(28286.35546875,14895.3017578125, 102.62469482421875)
						else
							toTargetP(CFrame.new(29020.66015625, 14889.4267578125, -379.2682800292969))
						end
					until (CFrame.new(29020.66015625, 14889.4267578125, -379.2682800292969).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 5 or not _G.Enable_Teleport_Race_Doors
					_G.Noclip = false
				end
			end)
		end
	end
end)

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
						if (workspace.Boats:FindFirstChild("PirateBrigade").VehicleSeat.CFrame.Position - CFrame.new(-11581.4482421875, 2.994250774383545, 1252.9136962890625).Position).magnitude >= 10 then
							workspace.Boats.PirateBrigade.VehicleSeat.CFrame = CFrame.new(-11581.4482421875, 2.994250774383545, 1252.9136962890625)
							wait(1)
						elseif (workspace.Boats.PirateBrigade.VehicleSeat.Position - CFrame.new(-11581.4482421875, 2.994250774383545, 1252.9136962890625).Position).magnitude <= 10 then
							if (CFrame.new(-11581.4482421875, 2.994250774383545, 1252.9136962890625).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Position).magnitude <= 5 then
								toTargetP(workspace.Boats.PirateBrigade.VehicleSeat.CFrame)
							else
								toTargetP(CFrame.new(-11581.4482421875, 2.994250774383545, 1252.9136962890625))
							end
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
						if _G.Enable_Pull_ever then
							local args = {
								[1] = "RaceV4Progress",
								[2] = "Check"
							}
							Progress_Check = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
							if tonumber(Progress_Check) == 1 then
								local args = {
									[1] = "RaceV4Progress",
									[2] = "Begin"
								}
							
								game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
							elseif tonumber(Progress_Check) == 2 then
								if (game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Position - CFrame.new(2952.8408203125, 2281.97900390625, -7216.93701171875).Position).magnitude <= 10 then
									local args = {
										[1] = "RaceV4Progress",
										[2] = "Teleport"
									}
							
									game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
									wait(1)
									game.Players.LocalPlayer.Character.Humanoid.Health = 0
								else
									toTargetP(CFrame.new(2952.8408203125, 2281.97900390625, -7216.93701171875))
								end 
							else
								if (game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Position - game:GetService("Workspace").Map:FindFirstChild("MysticIsland").HumanoidRootPart.CFrame.Position).magnitude <= 500 then
									if workspace:FindFirstChild("dsada") then
										player.CameraMaxZoomDistance = 0
										player.CameraMinZoomDistance = 0
										wait(1)
										local camera = game.Workspace.CurrentCamera
										camera.CFrame = CFrame.new(camera.CFrame.Position,workspace.dsada.Position) -- locks into the HEAD
										wait(1)
										game:GetService("VirtualInputManager"):SendKeyEvent(true,"T",true,game)
										wait(0.5)
										game:GetService("VirtualInputManager"):SendKeyEvent(true,"T",false,game)
									end
								else
									toTargetP(game:GetService("Workspace").Map:FindFirstChild("MysticIsland").HumanoidRootPart.CFrame * CFrame.new(0, 500, -100))	
								end
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
function toTargetP(CFgo)
	if game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Health <= 0 or not game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid") then tween:Cancel() repeat wait() until game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid") and game:GetService("Players").LocalPlayer.Character:WaitForChild("Humanoid").Health > 0 wait(7) return end
	if (game:GetService("Players")["LocalPlayer"].Character.HumanoidRootPart.Position - CFgo.Position).Magnitude <= 150 then
		pcall(function()
			tween:Cancel()

			game:GetService("Players")["LocalPlayer"].Character.HumanoidRootPart.CFrame = CFgo

			return
		end)
	end
	local tween_s = game:service"TweenService"
	local info = TweenInfo.new((game:GetService("Players")["LocalPlayer"].Character.HumanoidRootPart.Position - CFgo.Position).Magnitude/325, Enum.EasingStyle.Linear)
	tween = tween_s:Create(game.Players.LocalPlayer.Character["HumanoidRootPart"], info, {CFrame = CFgo})
	tween:Play()

	local tweenfunc = {}

	function tweenfunc:Stop()
		tween:Cancel()
	end

	return tweenfunc
end
task.spawn(function()
	game:GetService("RunService").Heartbeat:Connect(function()
		pcall(function()
			if StartMagnet then
				for i,v in pairs(game.Workspace.Enemies:GetChildren()) do
					if not string.find(v.Humanoid.DisplayName, "Boss") and  (v.HumanoidRootPart.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 350 then
						if InMyNetWork(v.HumanoidRootPart) then
							v.HumanoidRootPart.CFrame = PosMon
							v.Humanoid.JumpPower = 0
							v.Humanoid.WalkSpeed = 0
							v.HumanoidRootPart.Size = Vector3.new(60,60,60)
							v.HumanoidRootPart.Transparency = 1
							v.HumanoidRootPart.CanCollide = false
							v.Head.CanCollide = false
							if v.Humanoid:FindFirstChild("Animator") then
								v.Humanoid.Animator:Destroy()
							end
							v.Humanoid:ChangeState(11)
							v.Humanoid:ChangeState(14)
							if setscriptable then
								setscriptable(game.Players.LocalPlayer, "SimulationRadius", true)
							end
							if sethiddenproperty then
								sethiddenproperty(game.Players.LocalPlayer, "SimulationRadius", math.huge)
							end
						end
					end
				end
			end
		end)
	end)
end)
function InMyNetWork(object)
	if isnetworkowner then
		return isnetworkowner(object)
	else
		if (object.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <= 200 then 
			return true
		end
		return false
	end
end
function EquipWeapon(ToolSe)
	spawn(function()
		if game.Players.LocalPlayer.Backpack:FindFirstChild(ToolSe) or game.Players.LocalPlayer.Character:FindFirstChild(ToolSe) then
			local tool = game.Players.LocalPlayer.Backpack:FindFirstChild(ToolSe)
			wait(.1)
			game.Players.LocalPlayer.Character.Humanoid:EquipTool(tool)
		end
	end)
end
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
local gg = getrawmetatable(game)
local old = gg.__namecall
setreadonly(gg,false)
gg.__namecall = newcclosure(function(...)
	local method = getnamecallmethod()
	local args = {...}
	if tostring(method) == "FireServer" then
		if tostring(args[1]) == "RemoteEvent" then
			if tostring(args[2]) ~= "true" and tostring(args[2]) ~= "false" then
				if Skillaimbot then
					args[2] = AimBotSkillPosition
					return old(unpack(args))
				end
			end
		end
	end
	return old(...)
end)
local TICK = tick()
local Count = 0
spawn(function()
    while wait() do
        if  _G.AUTO_SAHRK_ANCHOR  then
            pcall(function()
				if not game:GetService("Workspace").Enemies:FindFirstChild("Terrorshark") then
					if not game:GetService("Workspace").Enemies:FindFirstChild("Shark") then
						if not game:GetService("Workspace").Enemies:FindFirstChild("Piranha") then
							if not game:GetService("Workspace").Enemies:FindFirstChild("Fish Crew Member") then
								if not game:GetService("Workspace").Enemies:FindFirstChild("PirateBrigade") then
									if not game:GetService("Workspace").Enemies:FindFirstChild("FishBoat") then
										if not game:GetService("Workspace").Boats:FindFirstChild("Guardian") then
											if Count then Count = 0 end
											BuyB = toTargetP(CFrame.new(-16917.17578125, 9.06057357788086, 510.3914794921875))
											if Count <= 5 and (CFrame.new(-16917.17578125, 9.06057357788086, 510.3914794921875).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 10 then
												if BuyB then BuyB:Stop() end
												local args = {
													[1] = "BuyBoat",
													[2] = "Guardian"
												}
												game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
												Count += 10
											end
										elseif Count < 2 and tostring(game:GetService("Workspace").Boats.Guardian.Owner.Value) ~= tostring(game.Players.LocalPlayer.Name) then
											if (CFrame.new(-16917.17578125, 9.06057357788086, 510.3914794921875).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude <= 10 then
												repeat wait()
													local args = {
														[1] = "BuyBoat",
														[2] = "Guardian"
													}
													game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
													Count += 20
												until Count >= 10 or _G.AUTO_SAHRK_ANCHOR == false
											else
												toTargetP(CFrame.new(-16917.17578125, 9.06057357788086, 510.3914794921875))
											end
										elseif game:GetService("Workspace").Boats:FindFirstChild("Guardian") then
											if (game:GetService("Workspace").Boats.Guardian.VehicleSeat.CFrame.Position - CFrame.new(-41228.96484375, 20.907041549682617, 8984.2861328125).Position).magnitude >= 10 then
												game:GetService("Workspace").Boats.Guardian.VehicleSeat.CFrame = CFrame.new(-41228.96484375, 20.907041549682617, 8984.2861328125)
											elseif game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit == false then
												if (game:GetService("Workspace").Boats.Guardian.VehicleSeat.CFrame.Position - game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame.Position).magnitude <= 5 then
													toTargetP(game:GetService("Workspace").Boats.Guardian.VehicleSeat.CFrame * CFrame.new(0,1,0))
												else
													toTargetP(CFrame.new(-41228.96484375, 20.907041549682617, 8984.2861328125))
												end
											end
										elseif game:GetService("Workspace").Boats.Guardian.VehicleSeat.CFrame ~= CFrame.new(-41228.96484375, 20.907041549682617, 8984.2861328125) then
											Count = 0
										end
									else
										if game:GetService("Workspace").Enemies:FindFirstChild("FishBoat") then
											for iu,vbss in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
												if vbss.Name == "FishBoat" then
													repeat task.wait()
														game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = false
														if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
															game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
														end
														toTargetP(vbss.VehicleSeat.CFrame * CFrame.new(0,30,0))
														AutoSkill = true
														Skillaimbot = true
														PositionSkillMasteryDevilFruit = vbss.VehicleSeat
														AimBotSkillPosition = vbss.VehicleSeat.CFrame
														UseSkillMasteryDevilFruit = true
														EquipAllWeapon()
													until not  _G.AUTO_SAHRK_ANCHOR or vbss.Humanoid.Value <= 0 or not game:GetService("Workspace").Enemies:FindFirstChild("FishBoat")
													AutoSkill = false
													Skillaimbot = false
												end
											end
										end
									end
								else
									-- PirateBrigade
									if game:GetService("Workspace").Enemies:FindFirstChild("PirateBrigade") or game:GetService("Workspace").Enemies:FindFirstChild("PirateGrandBrigade") then
										for iu,vbssb in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
											if vbssb.Name == "PirateGrandBrigade" or vbssb.Name == "PirateBrigade" then
												--if vbssb:FindFirstChild("Humanoid") and vbssb.Humanoid.Value > 0 then
													repeat task.wait()
														game.Players.LocalPlayer.Character:WaitForChild("Humanoid").Sit = false
														if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
															game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
														end
														EquipAllWeapon()
														toTargetP(vbssb.VehicleSeat.CFrame * CFrame.new(0,30,0))
														AutoSkill = true
														Skillaimbot = true
														PositionSkillMasteryDevilFruit = vbssb.VehicleSeat.CFrame
														AimBotSkillPosition = vbssb.VehicleSeat.CFrame
														UseSkillMasteryDevilFruit = true
													until not  _G.AUTO_SAHRK_ANCHOR or not vbssb.Parent or vbssb.Humanoid.Value <= 0 or not game:GetService("Workspace").Enemies:FindFirstChild("PirateGrandBrigade") or not game:GetService("Workspace").Enemies:FindFirstChild("PirateBrigade")
													AutoSkill = false
													Skillaimbot = false
												--end
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
											repeat wait()
												toTargetP(vss.HumanoidRootPart.CFrame * CFrame.new(0,300,0))
											until game.Players.LocalPlayer.Character.Humanoid.Health == game.Players.LocalPlayer.Character.Humanoid.MaxHealth or _G.AUTO_SAHRK_ANCHOR
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
			if _G.AUTO_SAHRK_ANCHOR or _G.Auto_Cake_Prince or _G.Enable_Pull_ever or _G.Enable_Find_Mirage or _G.Enable_Find_Gear or _G.Noclip or _G.Enable_Auto_Acient_Quest or _G.START then
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
            
function RobloxNotify(Ti,tab,icon,sec)
    game.StarterGui:SetCore("SendNotification", {
    Title = Ti,
    Text = tab,
    Icon = icon,
    Duration = sec,
    })
end
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
function CheckMasteryWeapon(NameWe,MasNum)
	if game.Players.LocalPlayer.Backpack:FindFirstChild(NameWe) then
		if tonumber(game.Players.LocalPlayer.Backpack:FindFirstChild(NameWe).Level.Value) < tonumber(MasNum) then
			return "true DownTo"
		elseif tonumber(game.Players.LocalPlayer.Backpack:FindFirstChild(NameWe).Level.Value) >= tonumber(MasNum) then
			return "true UpTo"
		end
	end
	if game.Players.LocalPlayer.Character:FindFirstChild(NameWe) then
		if tonumber(game.Players.LocalPlayer.Character:FindFirstChild(NameWe).Level.Value) < tonumber(MasNum) then
			return "true DownTo"
		elseif tonumber(game.Players.LocalPlayer.Character:FindFirstChild(NameWe).Level.Value) >= tonumber(MasNum) then
			return "true UpTo"
		end
	end
	return "else"
end



task.spawn(function()
	pcall(function()
		while task.wait(1) do
			if _G.START then
				game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuySanguineArt")
			end		
		end
	end)
end)

spawn(function()
	pcall(function()
		while true do wait()
			if _G.START then
				if Check_Number("Dark Fragment") >= 2 then
					if Check_Number("Leviathan Heart") >= 1 then
						if Check_Number("Demonic Wisp") >= 20 then
							if Check_Number("Vampire Fang") >= 20 then
								game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuySanguineArt")
							elseif Check_Number("Vampire Fang") < 20 then
								if World2 then
									if game.Workspace.Enemies:FindFirstChild("Vampire") then
										for i,v in pairs(game.Workspace.Enemies:GetChildren()) do
											if v:FindFirstChild("Humanoid") and v.Name == "Vampire" then
												repeat wait()
													if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
														local args = {
															[1] = "Buso"
														}
														game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
													end
													EquipWeapon(_G.Selected_Weapon)
													FastAttackSpeed = true
													StartMagnet = true
													PosMon = v.HumanoidRootPart.CFrame
													v.Humanoid.JumpPower = 0
													v.Humanoid.WalkSpeed = 0
													v.HumanoidRootPart.CanCollide = false
													toTargetP(v.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
												until not _G.START or not v.Parent or v.Humanoid.Health <= 0
											end
										end
									else
										toTargetP(CFrame.new(-6033,7, -1317))
									end
								else
									game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TravelDressrosa")
								end
							end 
						elseif Check_Number("Demonic Wisp") < 20 then
							if World3 then
								if game.Workspace.Enemies:FindFirstChild("Demonic Soul") then
									for i,v in pairs(game.Workspace.Enemies:GetChildren()) do
										if v:FindFirstChild("Humanoid") and v.Name == "Demonic Soul" then
											repeat wait()
												if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
													local args = {
														[1] = "Buso"
													}
													game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer(unpack(args))
												end
												EquipWeapon(_G.Selected_Weapon)
												FastAttackSpeed = true
												StartMagnet = true
												PosMon = v.HumanoidRootPart.CFrame
												v.Humanoid.JumpPower = 0
												v.Humanoid.WalkSpeed = 0
												v.HumanoidRootPart.CanCollide = false
												toTargetP(v.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
											until not _G.START or not v.Parent or v.Humanoid.Health <= 0
										end
									end
								else
									toTargetP(CFrame.new(-9507,172,6158))
								end
							else
								game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TravelZou")
							end
						end
					end
				end
 			end
			if _G.START2 and game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuySanguineArt", true) == 1 then
				if (game.Players.LocalPlayer.Backpack:FindFirstChild("Sanguine Art") or game.Players.LocalPlayer.Character:FindFirstChild("Sanguine Art")) then
					if World3 then
						if game:GetService("Workspace").Enemies:FindFirstChild("Reborn Skeleton") or game:GetService("Workspace").Enemies:FindFirstChild("Living Zombie") or game:GetService("Workspace").Enemies:FindFirstChild("Demonic Soul") or game:GetService("Workspace").Enemies:FindFirstChild("Posessed Mummy") then
							for i,v in pairs(game:GetService("Workspace").Enemies:GetChildren()) do
								if v.Name == "Reborn Skeleton" or v.Name == "Living Zombie" or v.Name == "Demonic Soul" or v.Name == "Posessed Mummy" then
									if v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") and v.Humanoid.Health > 0 then
										repeat wait()
											FastAttackSpeed = true
											StartMagnet = true
											if not game.Players.LocalPlayer.Character:FindFirstChild("HasBuso") then
												game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
											end
											EquipWeapon(_G.Selected_Weapon)
											PosMon = v.HumanoidRootPart.CFrame
											v.HumanoidRootPart.Size = Vector3.new(60,60,60)
											v.Humanoid.JumpPower = 0
											v.Humanoid.WalkSpeed = 0
											v.HumanoidRootPart.CanCollide = false
											v.Humanoid:ChangeState(11)
											toTargetP(v.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
										until not _G.START or v.Humanoid.Health <= 0 or not v.Parent or v.Humanoid.Health <= 0
										StartMagnet = false
										FastAttack = false
									end
								end
							end
						else
							toTargetP(CFrame.new(-9504.8564453125, 172.14292907714844, 6057.259765625))
						end
					else
						game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TravelZou")
					end
				else
					game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuySanguineArt")
				end
			end
		end
	end)
end)
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
									v.Humanoid.JumpPower = 0
									v.Humanoid.WalkSpeed = 0
									v.HumanoidRootPart.CanCollide = false
									toTargetP(v.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
								until not _G.Auto_Cake_Prince or not v.Parent or v.Humanoid.Health <= 0
								FastAttackSpeed = false
								StartMagnet =false
							end
						end
					else
						if game:GetService("Workspace").Map.CakeLoaf.BigMirror.Other.Transparency == 0 and (CFrame.new(-1990.672607421875, 4532.99951171875, -14973.6748046875).Position - game.Players.LocalPlayer.Character.HumanoidRootPart.Position).magnitude >= 2000 then
							FastAttackSpeed = false
							Questtween = toTargetP(CFrame.new(-2151.82153, 149.315704, -12404.9053))
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
										FastAttackSpeed = true
										StartMagnet = true
										PosMon = v.HumanoidRootPart.CFrame
										v.Humanoid.JumpPower = 0
										v.Humanoid.WalkSpeed = 0
										v.HumanoidRootPart.CanCollide = false
										toTargetP(v.HumanoidRootPart.CFrame * CFrame.new(0,30,0))
									end
								until not _G.Auto_Cake_Prince or not v.Parent or v.Humanoid.Health <= 0
								StartMagnet = false
								FastAttackSpeed = false
							end
						end
					else
						Questtween = toTargetP(CFrame.new(-2077, 252, -12373))
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
local cooldownfastattack = tick()
function CurrentWeapon()
	local ac = CombatFrameworkR.activeController
	local ret = ac.blades[1]
	if not ret then return game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Name end
	pcall(function()
		while ret.Parent~=game.Players.LocalPlayer.Character do ret=ret.Parent end
	end)
	if not ret then return game.Players.LocalPlayer.Character:FindFirstChildOfClass("Tool").Name end
	return ret
end
function getAllBladeHits(Sizes)
	local Hits = {}
	local Client = game.Players.LocalPlayer
	local Enemies = game:GetService("Workspace").Enemies:GetChildren()
	for i=1,#Enemies do local v = Enemies[i]
		local Human = v:FindFirstChildOfClass("Humanoid")
		if Human and Human.RootPart and Human.Health > 0 and Client:DistanceFromCharacter(Human.RootPart.Position) < Sizes+5 then
			table.insert(Hits,Human.RootPart)
		end
	end
	return Hits
end
function AttackFunction()
	local ac = CombatFrameworkR.activeController
	if ac and ac.equipped then
		for indexincrement = 1, 1 do
			local bladehit = getAllBladeHits(60)
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
					game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("weaponChange",tostring(CurrentWeapon()))
					game.ReplicatedStorage.Remotes.Validator:FireServer(math.floor(NumberAc12 / 1099511627776 * 16777215), AcAttack10)
					game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("hit", bladehit, 2, "") 
				end
			end
		end
	end
end
local x = game.Players.LocalPlayer
local c = game:GetService("ReplicatedStorage")
local Q = require(x.PlayerScripts.CombatFramework);
local Y = getupvalues(Q)[2];
local C = require(game.ReplicatedStorage.Util.CameraShaker):Stop();
if game:GetService("ReplicatedStorage").Util.Sound:FindFirstChild("Storage") then
	game:GetService("ReplicatedStorage").Util.Sound:FindFirstChild("Storage"):Remove()
end
function Maxincrement()
    local H = #Y.activeController.anims.basic;
    return H;
end;
coroutine.wrap(function()
	task.spawn(function()
		xpcall(function()
			local ac = CombatFrameworkR.activeController
			ac:attack()
		end, function(x)
			print("[ERROR] Fast Attack: "..x)
		end)
	end)
end)()
coroutine.wrap(function()
	while task.wait() do
		local ac = CombatFrameworkR.activeController
		if ac and ac.equipped then
			if FastAttackSpeed and _G.FAST_ATTACK then
				AttackFunction()
				if tick() - cooldownfastattack > .3 then 
					wait(0.1) 
					cooldownfastattack = tick()
				end
			elseif FastAttackSpeed and _G.FAST_ATTACK == false then
				if ac.hitboxMagnitude ~= 55 then
					ac.hitboxMagnitude = 55
				end
				ac:attack()
			end
		end
	end
end)()
getgenv().NoDieEffect = true 
if getgenv().NoDieEffect then
	if game:GetService("ReplicatedStorage").Effect.Container:FindFirstChild("Death") then
		game:GetService("ReplicatedStorage").Effect.Container.Death:Destroy()
	end
	if game:GetService("ReplicatedStorage").Effect.Container:FindFirstChild("Respawn") then
		game:GetService("ReplicatedStorage").Effect.Container.Respawn:Destroy()
	end
end
-- [Anti AFK]

game:GetService("Players").LocalPlayer.Idled:connect(function()
	game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
	wait(1)
	game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0),workspace.CurrentCamera.CFrame)
end)
spawn(function()
	while true do wait()
		getgenv().rejoin = game:GetService("CoreGui").RobloxPromptGui.promptOverlay.ChildAdded:Connect(function(Kick)
			if not _G.TP_Ser and _G.Rejoin then
				if Kick.Name == 'ErrorPrompt' and Kick:FindFirstChild('MessageArea') and Kick.MessageArea:FindFirstChild("ErrorFrame") then
					game:GetService("TeleportService"):Teleport(game.PlaceId)
					wait(50)
				end
			end
		end)
	end
end)
print("Rejoin Load")
return OrionLib
