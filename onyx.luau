local lib = {}

--[[

local UI = Onyx:UI() -- Makes the UI

local Window = UI:MakeWindow({ -- Everything must be filled out or it will error
	Title = "title", -- Title of UI
	LoadingAnim = true, -- Whether it has a loading animation, must be true for key system
	Key = {
		Enabled = true -- Requires a key
		Key = "Onyx"
		CloseOnWrong = true -- If someone gets the key wrong, they have to re-run the program (prevents guessing by spamming keys kinda)
	},
})

local Tab = Window:MakeTab({
	Name = "ESP", -- Name of the tab
	Text = "ESP", -- Text that appears on the tab button
})

local Button = Tab:MakeButton({
	Name = "Fling", -- Name of the button, make it simple
	Text = "Fling yourself", -- Text that appears on the button
	Callback = function()
		-- Code here, happens when button is pressed
	end,
})
Button:Click() -- Clicks the button

local Toggle = Tab:MakeToggle({
	Name = "Fly", -- Name of the button, make it simple
	Text = "Fly", -- Text that appears on the button
	BaseValue = false, -- Base value/state of the toggle
	Callback = function(state)
		-- Code here, happens when toggled
		-- State is true or false, represents the toggles state
	end,
})

Toggle:Toggle() -- Replicates the toggle being clicked
Toggle:Set(true) -- Sets the toggles value to true and calls the callback

]]

function tween(obj,time,style,dir,prop,to)
	game:GetService("TweenService"):Create(obj, TweenInfo.new(time, Enum.EasingStyle[style], Enum.EasingDirection[dir]), {[prop] = to}):Play()
end

function updateTabPositions(TabFrame)
	local lastPos = UDim2.fromScale(0.05,0.2)
	
	for i,v in ipairs(TabFrame:GetChildren()) do
		if v:IsA("TextButton") then
			v.Position = lastPos
			
			lastPos += UDim2.fromScale(0.3,0)
		end
	end
end

function drag(drag, input)
	local dragging = false
	local dragInput
	local dragStart
	local startPos
	local lastMousePos
	local lastGoalPos
	local DRAG_SPEED = 25

	local function lerp(a, b, m)
		return a + (b - a) * m
	end

	local function update(dt)
		if not startPos then return end
		if not dragging and lastGoalPos then
			drag.Position = UDim2.new(
				startPos.X.Scale, lerp(drag.Position.X.Offset, lastGoalPos.X.Offset, dt * DRAG_SPEED),
				startPos.Y.Scale, lerp(drag.Position.Y.Offset, lastGoalPos.Y.Offset, dt * DRAG_SPEED)
			)
			return
		end

		local delta = lastMousePos - game:GetService("UserInputService"):GetMouseLocation()
		local xGoal = startPos.X.Offset - delta.X
		local yGoal = startPos.Y.Offset - delta.Y
		lastGoalPos = UDim2.new(startPos.X.Scale, xGoal, startPos.Y.Scale, yGoal)

		drag.Position = UDim2.new(
			startPos.X.Scale, lerp(drag.Position.X.Offset, xGoal, dt * DRAG_SPEED),
			startPos.Y.Scale, lerp(drag.Position.Y.Offset, yGoal, dt * DRAG_SPEED)
		)
	end

	input.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = inp.Position
			startPos = drag.Position
			lastMousePos = game:GetService("UserInputService"):GetMouseLocation()

			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	input.InputChanged:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch then
			dragInput = inp
		end
	end)

	game:GetService("RunService").Heartbeat:Connect(update)
end

function tabClicked(Window, Tab, info, GUI, isReload)
	if isReload == false and Window.SelectedTab == info.Name then return end
	if isReload == true and Window.SelectedTab ~= info.Name then return end

	if Window.Tabs[Window.SelectedTab] then
		for i,v in pairs(Window.Tabs[Window.SelectedTab].Data.Items) do
			task.spawn(function()
				if not GUI.MainFrame.MainSection:FindFirstChild(v.Name) then return end
				local b = GUI.MainFrame.MainSection[v.Name]
				if b:IsA("Frame") and b:FindFirstChild("Type") then
					v.Connection:Disconnect()

					b:Destroy()
				end
			end)
		end
	end

	Window.SelectedTab = info.Name

	local loop = 0

	for i,v in pairs(Tab.Data.Items) do
		loop += 1
		if Tab.Data.Types[v.Name] == "Button" then
			task.spawn(function()
				local ButtonFrame = Instance.new("Frame", GUI.MainFrame.MainSection)
				ButtonFrame.Name = v.Name
				ButtonFrame.BackgroundTransparency = 1
				ButtonFrame.Size = UDim2.fromScale(1,0.15)
				ButtonFrame.LayoutOrder = loop

				local Type = Instance.new("StringValue", ButtonFrame)
				Type.Name = "Type"
				Type.Value = "Button"

				local Button = Instance.new("TextButton", ButtonFrame)
				Button.BackgroundColor3 = Color3.fromRGB(50,50,50)
				Button.AnchorPoint = Vector2.new(0.5,0.5)
				Button.Position = UDim2.fromScale(0.5,0.6)
				Button.Size = UDim2.fromScale(0.9,0.8)
				Button.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
				Button.Text = ""
				Button.Name = "Button"

				local UICorner = Instance.new("UICorner", Button)
				UICorner.CornerRadius = UDim.new(0.25,0)

				local UIStroke = Instance.new("UIStroke", Button)
				UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				UIStroke.Color = Color3.fromRGB(100,100,100)

				local ClickLabel = Instance.new("ImageLabel", Button)
				ClickLabel.BackgroundTransparency = 1
				ClickLabel.AnchorPoint = Vector2.new(0.5,0.5)
				ClickLabel.Position = UDim2.fromScale(0.9,0.5)
				ClickLabel.Size = UDim2.fromScale(0.65,0.65)
				ClickLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
				ClickLabel.Image = "rbxassetid://12974400533"
				ClickLabel.Name = "ClickLabel"

				local ButtonLabel = Instance.new("TextLabel", Button)
				ButtonLabel.BackgroundTransparency = 1
				ButtonLabel.Position = UDim2.fromScale(0.05,0)
				ButtonLabel.Size = UDim2.fromScale(0.5,1)
				ButtonLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
				ButtonLabel.Text = v.Text
				ButtonLabel.TextSize = 16
				ButtonLabel.TextColor3 = Color3.fromRGB(255,255,255)
				ButtonLabel.TextXAlignment = Enum.TextXAlignment.Left

				v.Connection = Button.MouseButton1Click:Connect(v.Callback)
			end)
		elseif Tab.Data.Types[v.Name] == "Toggle" then
			task.spawn(function()
				local ToggleFrame = Instance.new("Frame", GUI.MainFrame.MainSection)
				ToggleFrame.Name = v.Name
				ToggleFrame.BackgroundTransparency = 1
				ToggleFrame.Size = UDim2.fromScale(1,0.15)
				ToggleFrame.LayoutOrder = loop

				local Type = Instance.new("StringValue", ToggleFrame)
				Type.Name = "Type"
				Type.Value = "Toggle"

				local Toggle = Instance.new("TextButton", ToggleFrame)
				Toggle.BackgroundColor3 = Color3.fromRGB(50,50,50)
				Toggle.AnchorPoint = Vector2.new(0.5,0.5)
				Toggle.Position = UDim2.fromScale(0.5,0.6)
				Toggle.Size = UDim2.fromScale(0.9,0.8)
				Toggle.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
				Toggle.Text = ""
				Toggle.Name = "Toggle"

				local UICorner = Instance.new("UICorner", Toggle)
				UICorner.CornerRadius = UDim.new(0.25,0)

				local UIStroke = Instance.new("UIStroke", Toggle)
				UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				UIStroke.Color = Color3.fromRGB(100,100,100)

				local Label = Instance.new("TextLabel", Toggle)
				Label.BackgroundTransparency = 1
				Label.Position = UDim2.fromScale(0.05,0)
				Label.Size = UDim2.fromScale(0.5,1)
				Label.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
				Label.Text = v.Text
				Label.TextSize = 16
				Label.TextColor3 = Color3.fromRGB(255,255,255)
				Label.TextXAlignment = Enum.TextXAlignment.Left

				local SwitchFrame = Instance.new("Frame", Toggle)
				SwitchFrame.BorderSizePixel = 0
				SwitchFrame.BackgroundColor3 = (v.Value == false and Color3.fromRGB(50,50,50) or Color3.fromRGB(25,100,200))   
				SwitchFrame.AnchorPoint = Vector2.new(0.5,0.5)
				SwitchFrame.Name = "Toggle"
				SwitchFrame.Position = UDim2.fromScale(0.85,0.5)
				SwitchFrame.Size = UDim2.fromScale(0.15,0.6)

				local SlidingFrame = Instance.new("Frame", SwitchFrame)
				SlidingFrame.BackgroundTransparency = 1
				SlidingFrame.AnchorPoint = Vector2.new(0.5,0.5)
				SlidingFrame.Position = UDim2.fromScale(0.5,0.5)
				SlidingFrame.Size = UDim2.fromScale(0.9,0.9)
				SlidingFrame.Name = "SlidingFrame"

				local UICorner = Instance.new("UICorner", SwitchFrame)
				UICorner.CornerRadius = UDim.new(1,0)

				local UIStroke = Instance.new("UIStroke", SwitchFrame)
				UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				UIStroke.Color = Color3.fromRGB(100,100,100)

				local Circle = Instance.new("Frame", SlidingFrame)
				Circle.Name = "Circle"
				Circle.BackgroundColor3 = (v.Value == false and Color3.fromRGB(100,100,100) or Color3.fromRGB(75,150,255))
				Circle.AnchorPoint = (v.Value == false and Vector2.new(0,0.5) or Vector2.new(1,0.5))
				Circle.Position = (v.Value == false and UDim2.fromScale(0,0.5) or UDim2.fromScale(1,0.5))
				Circle.Size = UDim2.fromScale(0.9,0.9)
				Circle.SizeConstraint = Enum.SizeConstraint.RelativeYY

				local UICorner = Instance.new("UICorner", Circle)
				UICorner.CornerRadius = UDim.new(1,0)

				v.Connection = Toggle.MouseButton1Click:Connect(function()
					v.Value = not v.Value

					if v.Value == true then
						tween(Circle, 0.15, "Quart", "Out", "AnchorPoint", Vector2.new(1,0.5))
						tween(Circle, 0.15, "Quart", "Out", "Position", UDim2.fromScale(1,0.5))
						tween(Circle, 0.15, "Quart", "Out", "BackgroundColor3", Color3.fromRGB(75,150,255))
						tween(SwitchFrame, 0.15, "Quart", "Out", "BackgroundColor3", Color3.fromRGB(25,100,200))
						--tween(SwitchFrame.UIStroke, 0.2, "Linear", "In", "Color", Color3.fromRGB(10,75,150))
					else
						tween(Circle, 0.15, "Quart", "Out", "AnchorPoint", Vector2.new(0,0.5))
						tween(Circle, 0.15, "Quart", "Out", "Position", UDim2.fromScale(0,0.5))
						tween(Circle, 0.15, "Quart", "Out", "BackgroundColor3", Color3.fromRGB(100,100,100))
						tween(SwitchFrame, 0.15, "Quart", "Out", "BackgroundColor3", Color3.fromRGB(50,50,50))
						--tween(SwitchFrame.UIStroke, 0.2, "Linear", "In", "Color", Color3.fromRGB(100,100,100))
					end

					v.Callback(v.Value)
				end)
			end)
		end
	end
end

function lib:UI()
	local GUI = Instance.new("ScreenGui", game.Players.LocalPlayer.PlayerGui)
	GUI.Name = "OnyxUI"
	GUI.ResetOnSpawn = false
	GUI.IgnoreGuiInset = true
	
	local TabsFolder = Instance.new("Folder", game.Players.LocalPlayer.PlayerGui)
	TabsFolder.Name = "TabsFolder"
	
	local UI = {
		ScreenGUI = GUI,
		Windows = {}
	}
	
	lib.UI = UI
	
	function UI:MakeWindow(info)
		local Window = {
			Tabs = {},
			SelectedTab = "",
		}
		
		UI.Windows[info.Title] = Window
		
		function Window:MakeTab(info)
			local Tab = {
				Name = info.Name,
				Text = info.Text,
				Data = {
					Items = {},
					Types = {},
				},
			}
			
			Window.Tabs[info.Name] = Tab
			
			function Tab:MakeButton(info2)
				local Button = {
					Name = info2.Name,
					Text = info2.Text,
					Callback = info2.Callback,
				}
				
				Tab.Data.Items[info2.Name] = Button
				Tab.Data.Types[info2.Name] = "Button"
				
				tabClicked(Window, Tab, info, GUI, true)
				
				function Button:Click()
					return Button.Callback()
				end
				
				return Button
			end
			
			function Tab:MakeToggle(info2)
				local Toggle = {
					Name = info2.Name,
					Text = info2.Text,
					BaseValue = info2.BaseValue,
					Value = info2.BaseValue,
					Callback = info2.Callback,
				}
				
				Tab.Data.Items[info2.Name] = Toggle
				Tab.Data.Types[info2.Name] = "Toggle"
				
				if info.BaseValue == true then
					info.Callback(true)
				end
				
				tabClicked(Window, Tab, info, GUI, true)
				
				function Toggle:Toggle()
					Toggle.Value = not Toggle.Value
					
					return Toggle.Callback(Toggle.Value)
				end
				
				function Toggle:Set(Value)
					Toggle.Value = Value
					
					return Toggle.Callback(Value)
				end
				
				return Toggle
			end
			
			task.spawn(function()
				local TabFrame = Instance.new("Frame", TabsFolder.Parent ~= nil and TabsFolder or GUI.MainFrame.Tabs)
				TabFrame.Name = info.Name
				TabFrame.Size = UDim2.fromScale(0.3,1)
				TabFrame.BackgroundTransparency = 1
				
				local TabButton = Instance.new("TextButton", TabFrame)
				TabButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
				TabButton.BorderSizePixel = 0
				TabButton.Size = UDim2.fromScale((0.25 / 0.3),0.6)
				TabButton.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
				TabButton.Text = info.Text
				TabButton.TextColor3 = Color3.fromRGB(255,255,255)
				TabButton.TextSize = 14
				TabButton.Name = "TabButton"
				TabButton.Position = UDim2.fromScale((0.05 / 0.3), 0.2)
				
				local UIStroke = Instance.new("UIStroke", TabButton)
				UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				UIStroke.Color = Color3.fromRGB(75,75,75)
				
				local UICorner = Instance.new("UICorner", TabButton)
				UICorner.CornerRadius = UDim.new(0.25,0)
				
				if TabsFolder.Parent == nil then
					updateTabPositions(GUI.MainFrame.Tabs)
				end
				
				TabButton.MouseButton1Click:Connect(function()
					tabClicked(Window, Tab, info, GUI, false)
				end)
			end)
			
			return Tab
		end
		
		task.spawn(function()
			local MainFrame = Instance.new("Frame", UI.ScreenGUI)
			MainFrame.Name = "MainFrame"
			MainFrame.AnchorPoint = Vector2.new(0.5,0.5)
			MainFrame.Position = UDim2.fromScale(0.5,0.5)
			MainFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
			MainFrame.Size = UDim2.fromScale(0,0)
			MainFrame.ClipsDescendants = true
			
			local UIAspectRatio = Instance.new("UIAspectRatioConstraint", MainFrame)
			UIAspectRatio.AspectRatio = 1.5
			
			local UICorner = Instance.new("UICorner", MainFrame)
			UICorner.CornerRadius = UDim.new(0.05,0)
			
			tween(MainFrame, 0.5, "Quart", "Out", "Size", UDim2.fromScale(0.3,0.3))
			
			task.wait(0.1)
			
			local Title = Instance.new("TextLabel", MainFrame)
			Title.Size = UDim2.fromScale(1,0.2)
			Title.Text = info.Title
			Title.BackgroundTransparency = 1
			Title.TextColor3 = Color3.fromRGB(255,255,255)
			Title.TextSize = 14
			Title.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
			Title.Name = "Title"
			
			local LoadingLabel = Instance.new("TextLabel", MainFrame)
			LoadingLabel.Position = UDim2.fromScale(0,0.2)
			LoadingLabel.Size = UDim2.fromScale(1,0.05)
			LoadingLabel.Text = "Loading..."
			LoadingLabel.BackgroundTransparency = 1
			LoadingLabel.TextColor3 = Color3.fromRGB(255,255,255)
			LoadingLabel.TextSize = 14
			LoadingLabel.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Light, Enum.FontStyle.Normal)
			LoadingLabel.Name = "LoadingLabel"
			
			local KeyBox
			local KeyCheck
			
			if info.Key.Enabled == true then
				KeyBox = Instance.new("TextBox",MainFrame)
				KeyBox.AnchorPoint = Vector2.new(0.5,0.5)
				KeyBox.BackgroundColor3 = Color3.fromRGB(25,25,25)
				KeyBox.Position = UDim2.fromScale(0.5,0.55)
				KeyBox.Size = UDim2.fromScale(0.55,0.125)
				KeyBox.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
				KeyBox.PlaceholderText = "Key"
				KeyBox.Text = ""
				KeyBox.TextColor3 = Color3.fromRGB(255,255,255)
				KeyBox.TextSize = 14
				KeyBox.Name = "Key"
				
				KeyCheck = Instance.new("TextButton", MainFrame)
				KeyCheck.AnchorPoint = Vector2.new(0.5,0.5)
				KeyCheck.BackgroundColor3 = Color3.fromRGB(50,150,255)
				KeyCheck.Position = UDim2.fromScale(0.5,0.8)
				KeyCheck.Size = UDim2.fromScale(0.25,0.15)
				KeyCheck.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
				KeyCheck.Text = "Check"
				KeyCheck.Name = "Check"
				KeyCheck.TextColor3 = Color3.fromRGB(0,0,0)
				KeyCheck.TextSize = 14
				
				local CheckImage = Instance.new("ImageLabel", KeyCheck)
				CheckImage.Size = UDim2.fromScale(0.75,0.75)
				CheckImage.BackgroundTransparency = 1
				CheckImage.Image = "rbxassetid://14189590169" --"rbxassetid://3642321726"
				CheckImage.ImageTransparency = 1
				CheckImage.ScaleType = Enum.ScaleType.Fit
				CheckImage.Position = UDim2.fromScale(0.5,0.5)
				CheckImage.AnchorPoint = Vector2.new(0.5,0.5)
				
				local UIAspectRatio = Instance.new("UIAspectRatioConstraint", KeyCheck)
				UIAspectRatio.AspectRatio = 2.5
				
				local UICorner = Instance.new("UICorner", KeyCheck)
				UICorner.CornerRadius = UDim.new(0,0)
				
				local UIStroke1 = Instance.new("UIStroke", KeyBox)
				UIStroke1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				UIStroke1.Color = Color3.fromRGB(100,100,100)
				UIStroke1.Thickness = 2
				
				local UIStroke2 = Instance.new("UIStroke", KeyCheck)
				UIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				UIStroke2.Color = Color3.fromRGB(25,100,125)
				UIStroke2.Thickness = 2
				
				local open = false
				
				local connection
				connection = KeyCheck.MouseButton1Click:Connect(function()
					local Key = KeyBox.Text
					if Key == info.Key.Key then
						open = true
					end
				end)
				
				local dots = 0
				repeat
					dots += 1
					LoadingLabel.Text = "Loading"..string.rep(".", dots)
					
					task.wait(0.5)
					
					if dots == 3 then
						dots = 0
					end
				until open == true
				
				tween(UIAspectRatio, 0.5, "Quart", "Out", "AspectRatio", 1)
				tween(UICorner, 0.5, "Quart", "Out", "CornerRadius", UDim.new(1,0))
				tween(CheckImage, 0.5, "Quart", "Out", "ImageTransparency", 0)
				tween(KeyCheck, 0.3, "Quart", "Out", "TextTransparency", 1)
				
				task.wait(2)
			else
				local dots = 0
				for i=1, 9 do
					dots += 1
					LoadingLabel.Text = "Loading"..string.rep(".", dots)

					task.wait(0.5)

					if dots == 3 then
						dots = 0
					end
				end
			end
			
			LoadingLabel:Destroy()
			Title:Destroy()
			if info.Key.Enabled == true then
				KeyBox:Destroy()
				KeyCheck:Destroy()
			end
			
			tween(MainFrame, 0.75, "Quart", "Out", "Size", UDim2.fromScale(0.3,0.7))
			tween(UIAspectRatio, 0.75, "Quart", "Out", "AspectRatio", 0.9)
			
			local TopBar = Instance.new("Frame", MainFrame)
			TopBar.Size = UDim2.fromScale(1,0.1)
			TopBar.BackgroundColor3 = Color3.fromRGB(50,50,50)
			TopBar.Name = "TopBar"
			
			drag(MainFrame, TopBar)
			
			local UICorner = Instance.new("UICorner", TopBar)
			UICorner.CornerRadius = UDim.new(0.5,0)
			
			local UICornerFill = Instance.new("Frame", TopBar)
			UICornerFill.BackgroundColor3 = Color3.fromRGB(50,50,50)
			UICornerFill.Position = UDim2.fromScale(0,0.5)
			UICornerFill.Size = UDim2.fromScale(1,0.5)
			UICornerFill.Name = "UICornerFill"
			UICornerFill.BorderSizePixel = 0
			
			local Title = Instance.new("TextLabel", TopBar)
			Title.BackgroundTransparency = 1
			Title.Position = UDim2.fromScale(0.05,0)
			Title.Size = UDim2.fromScale(0.5,1)
			Title.FontFace = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
			Title.Text = info.Title
			Title.TextColor3 = Color3.fromRGB(255,255,255)
			Title.TextSize = 14
			Title.TextXAlignment = Enum.TextXAlignment.Left
			Title.Name = "Title"
			
			local Tabs = Instance.new("ScrollingFrame", MainFrame)
			Tabs.Name = "Tabs"
			Tabs.BackgroundTransparency = 1
			Tabs.Position = UDim2.fromScale(0,0.1)
			Tabs.Size = UDim2.fromScale(1,0.125)
			Tabs.CanvasSize = UDim2.fromScale(0,0)
			Tabs.ScrollBarThickness = 0
			Tabs.ScrollingDirection = Enum.ScrollingDirection.X
			Tabs.AutomaticCanvasSize = Enum.AutomaticSize.X
			
			local EndPadding = Instance.new("Frame", Tabs)
			EndPadding.Size = UDim2.fromScale(0.05,1)
			EndPadding.BackgroundTransparency = 1
			EndPadding.LayoutOrder = 100000
			EndPadding.Name = "EndSpacer"
			
			local UIListLayout = Instance.new("UIListLayout", Tabs)
			UIListLayout.FillDirection = Enum.FillDirection.Horizontal
			UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			
			local UIStroke = Instance.new("UIStroke", Tabs)
			UIStroke.Color = Color3.fromRGB(75,75,75)
			
			local MainSection = Instance.new("ScrollingFrame", MainFrame)
			MainSection.Name = "MainSection"
			MainSection.BackgroundTransparency = 1
			MainSection.Position = UDim2.fromScale(0,0.225)
			MainSection.Size = UDim2.fromScale(1,0.775)
			MainSection.CanvasSize = UDim2.fromScale(0,0)
			MainSection.ScrollingDirection = Enum.ScrollingDirection.Y
			MainSection.ScrollBarThickness = 0
			MainSection.AutomaticCanvasSize = Enum.AutomaticSize.Y
			
			local UIListLayout = Instance.new("UIListLayout", MainSection)
			UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			
			local EndPadding = Instance.new("Frame", MainSection)
			EndPadding.Size = UDim2.fromScale(1,0.03)
			EndPadding.BackgroundTransparency = 1
			EndPadding.LayoutOrder = 100000
			
			for i,v in pairs(TabsFolder:GetChildren()) do
				v.Parent = Tabs
			end
			
			TabsFolder:Destroy()
			
			updateTabPositions(GUI.MainFrame.Tabs)
		end)
		
		return Window
	end
	
	return UI
end

print("REACHED END")

_G.TempOnyx = lib

return lib
