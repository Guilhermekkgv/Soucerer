local TweenService = game:GetService("TweenService")
local InputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Linux = {}

function Linux.Instance(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    return inst
end

function Linux:SafeCallback(Function, ...)
    if not Function then
        return
    end
    local Success, Error = pcall(Function, ...)
    if not Success then
        self:Notify({
            Title = "Callback Error",
            Content = tostring(Error),
            Duration = 5
        })
    end
end

function Linux:Notify(config)
    local isMobile = InputService.TouchEnabled and not InputService.KeyboardEnabled
    local notificationWidth = isMobile and 200 or 300
    local notificationHeight = config.SubContent and 80 or 60
    local startPosX = isMobile and 10 or 20
    local parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui")
    for _, v in pairs(parent:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name == "NotificationHolder" then
            v:Destroy()
        end
    end
    local NotificationHolder = Linux.Instance("ScreenGui", {
        Name = "NotificationHolder",
        Parent = parent,
        ResetOnSpawn = false,
        Enabled = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    local Notification = Linux.Instance("Frame", {
        Parent = NotificationHolder,
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        BorderSizePixel = 0,
        Size = UDim2.new(0, notificationWidth, 0, notificationHeight),
        Position = UDim2.new(1, 10, 1, -notificationHeight - 10),
        ZIndex = 100
    })
    Linux.Instance("UIGradient", {
        Parent = Notification,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 25)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 35))
        }),
        Rotation = 45
    })
    Linux.Instance("UIStroke", {
        Parent = Notification,
        Color = Color3.fromRGB(40, 40, 50),
        Thickness = 1
    })
    Linux.Instance("TextLabel", {
        Parent = Notification,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, 5),
        Font = Enum.Font.SourceSansPro,
        Text = config.Title or "Notification",
        TextColor3 = Color3.fromRGB(220, 220, 230),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 101
    })
    Linux.Instance("TextLabel", {
        Parent = Notification,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 20),
        Position = UDim2.new(0, 5, 0, 25),
        Font = Enum.Font.SourceSansPro,
        Text = config.Content or "Content",
        TextColor3 = Color3.fromRGB(160, 160, 170),
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 101
    })
    if config.SubContent then
        Linux.Instance("TextLabel", {
            Parent = Notification,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 0, 20),
            Position = UDim2.new(0, 5, 0, 45),
            Font = Enum.Font.SourceSansPro,
            Text = config.SubContent,
            TextColor3 = Color3.fromRGB(220, 220, 230),
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 101
        })
    end
    local ProgressBar = Linux.Instance("Frame", {
        Parent = Notification,
        BackgroundColor3 = Color3.fromRGB(40, 40, 50),
        Size = UDim2.new(1, -10, 0, 4),
        Position = UDim2.new(0, 5, 1, -9),
        ZIndex = 101,
        BorderSizePixel = 0
    })
    local ProgressFill = Linux.Instance("Frame", {
        Parent = ProgressBar,
        BackgroundColor3 = Color3.fromRGB(50, 150, 255),
        Size = UDim2.new(0, 0, 1, 0),
        ZIndex = 101,
        BorderSizePixel = 0
    })
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    TweenService:Create(Notification, tweenInfo, {Position = UDim2.new(0, startPosX, 1, -notificationHeight - 10)}):Play()
    if config.Duration then
        local progressTweenInfo = TweenInfo.new(config.Duration, Enum.EasingStyle.Linear, Enum.EasingDirection.In)
        TweenService:Create(ProgressFill, progressTweenInfo, {Size = UDim2.new(1, 0, 1, 0)}):Play()
        task.delay(config.Duration, function()
            TweenService:Create(Notification, tweenInfo, {Position = UDim2.new(1, 10, 1, -notificationHeight - 10)}):Play()
            task.wait(0.5)
            NotificationHolder:Destroy()
        end)
    end
end

function Linux.Create(config)
    local randomName = "UI_" .. tostring(math.random(100000, 999999))
    for _, v in pairs(game.CoreGui:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name:match("^UI_%d+$") then
            v:Destroy()
        end
    end
    local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
    local LinuxUI = Linux.Instance("ScreenGui", {
        Name = randomName,
        Parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui"),
        ResetOnSpawn = false,
        Enabled = true
    })
    ProtectGui(LinuxUI)
    local isMobile = InputService.TouchEnabled and not InputService.KeyboardEnabled
    local uiSize = isMobile and (config.SizeMobile or UDim2.fromOffset(300, 500)) or (config.SizePC or UDim2.fromOffset(550, 355))
    
    local Main = Linux.Instance("Frame", {
        Parent = LinuxUI,
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        BorderSizePixel = 0,
        Size = uiSize,
        Position = UDim2.new(0.5, -uiSize.X.Offset / 2, 0.5, -uiSize.Y.Offset / 2),
        Active = true,
        Draggable = true,
        ZIndex = 1
    })
    Linux.Instance("UIGradient", {
        Parent = Main,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 25)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 35))
        }),
        Rotation = 45
    })
    Linux.Instance("UIStroke", {
        Parent = Main,
        Color = Color3.fromRGB(40, 40, 50),
        Thickness = 1
    })
    local TopBar = Linux.Instance("Frame", {
        Parent = Main,
        BackgroundColor3 = Color3.fromRGB(20, 20, 25),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 25),
        ZIndex = 2
    })
    Linux.Instance("UIGradient", {
        Parent = TopBar,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 25)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 35))
        }),
        Rotation = 45
    })
    local TitleLabel = Linux.Instance("TextLabel", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 0, 1, 0),
        Position = UDim2.new(0, 5, 0, 0),
        Font = Enum.Font.SourceSansPro,
        Text = config.Name or "Linux UI",
        TextColor3 = Color3.fromRGB(220, 220, 230),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutomaticSize = Enum.AutomaticSize.X,
        ZIndex = 2
    })
    local CloseButton = Linux.Instance("TextButton", {
        Parent = TopBar,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 25, 0, 25),
        Position = UDim2.new(1, -25, 0, 0),
        Font = Enum.Font.SourceSansPro,
        Text = "×",
        TextColor3 = Color3.fromRGB(220, 220, 230),
        TextSize = 20,
        ZIndex = 2,
        AutoButtonColor = false
    })
    CloseButton.MouseButton1Click:Connect(function()
        LinuxUI:Destroy()
    })
    local TabsBar = Linux.Instance("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 25),
        Size = UDim2.new(0, config.TabWidth or 110, 1, -25),
        ZIndex = 2,
        BorderSizePixel = 0
    })
    local TabHolder = Linux.Instance("ScrollingFrame", {
        Parent = TabsBar,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 0,
        ZIndex = 2,
        BorderSizePixel = 0,
        ScrollingEnabled = true
    })
    Linux.Instance("UIListLayout", {
        Parent = TabHolder,
        Padding = UDim.new(0, 5),
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder
    })
    Linux.Instance("UIPadding", {
        Parent = TabHolder,
        PaddingLeft = UDim.new(0, 5),
        PaddingTop = UDim.new(0, 5)
    })
    local Content = Linux.Instance("Frame", {
        Parent = Main,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, config.TabWidth or 110, 0,  ovaries = 25),
        Size = UDim2.new(1, -(config.TabWidth or 110), 1, -25),
        ZIndex = 1,
        BorderSizePixel = 0
    })
    local isHidden = false
    InputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.LeftAlt then
            isHidden = not isHidden
            Main.Visible = not isHidden
        end
    end)
    local LinuxLib = {}
    local Tabs = {}
    local CurrentTab = nil
    local tabOrder = 0
    function LinuxLib.Tab(config)
        tabOrder = tabOrder + 1
        local tabIndex = tabOrder
        local TabBtn = Linux.Instance("TextButton", {
            Parent = TabHolder,
            BackgroundColor3 = Color3.fromRGB(20, 20, 25),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -5, 0, 28),
            Font = Enum.Font.SourceSansPro,
            Text = "",
            TextColor3 = Color3.fromRGB(220, 220, 230),
            TextSize = 14,
            ZIndex = 2,
            AutoButtonColor = false,
            LayoutOrder = tabIndex
        })
        Linux.Instance("UIGradient", {
            Parent = TabBtn,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 25)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 35))
            }),
            Rotation = 45
        })
        Linux.Instance("UIStroke", {
            Parent = TabBtn,
            Color = Color3.fromRGB(40, 40, 50),
            Thickness = 1
        })
        local TabIcon
        if config.Icon and config.Icon.Enabled then
            TabIcon = Linux.Instance("ImageLabel", {
                Parent = TabBtn,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 10, 0.5, -8),
                Image = config.Icon.Image or "rbxassetid://10747384394",
                ImageColor3 = Color3.fromRGB(220, 220, 230),
                ZIndex = 2
            })
        end
        local TabText = Linux.Instance("TextLabel", {
            Parent = TabBtn,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, config.Icon and config.Icon.Enabled and -31 or -15, 1, 0),
            Position = UDim2.new(0, config.Icon and config.Icon.Enabled and 31 or 10, 0, 0),
            Font = Enum.Font.SourceSansPro,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(220, 220, 230),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 2
        })
        local TabContent = Linux.Instance("Frame", {
            Parent = Content,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            ZIndex = 1,
            BorderSizePixel = 0
        })
        local Container = Linux.Instance("ScrollingFrame", {
            Parent = TabContent,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 1, -55),
            Position = UDim2.new(0, 5, 0, 30),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 0,
            ZIndex = 1,
            BorderSizePixel = 0,
            ScrollingEnabled = true,
            CanvasPosition = Vector2.new(0, 0)
        })
        local ContainerListLayout = Linux.Instance("UIListLayout", {
            Parent = Container,
            Padding = UDim.new(0, 5),
            HorizontalAlignment = Enum.HorizontalAlignment.Left,
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        Linux.Instance("UIPadding", {
            Parent = Container,
            PaddingLeft = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 5)
        })
        local TitleFrame = Linux.Instance("Frame", {
            Parent = Content,
            BackgroundColor3 = Color3.fromRGB(20, 20, 25),
            BorderSizePixel = 0,
            Size = UDim2.new(1, -5, 0, 30),
            Position = UDim2.new(0, 5, 0, 0),
            Visible = false,
            ZIndex = 3
        })
        Linux.Instance("UIGradient", {
            Parent = TitleFrame,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 25)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 35))
            }),
            Rotation = 45
        })
        local TitleLabel = Linux.Instance("TextLabel", {
            Parent = TitleFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Font = Enum.Font.SourceSansPro,
            Text = config.Name,
            TextColor3 = Color3.fromRGB(220, 220, 230),
            TextSize = 26,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            ZIndex = 4
        })
        local function SelectTab()
            for _, tab in pairs(Tabs) do
                tab.Content.Visible = false
                tab.TitleFrame.Visible = false
                tab.Text.TextColor3 = Color3.fromRGB(220, 220, 230)
                tab.Button.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
                if tab.Icon then
                    tab.Icon.ImageColor3 = Color3.fromRGB(220, 220, 230)
                end
            end
            TabContent.Visible = true
            TitleFrame.Visible = true
            TabText.TextColor3 = Color3.fromRGB(220, 220, 230)
            TabBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 255)
            if TabIcon then
                TabIcon.ImageColor3 = Color3.fromRGB(220, 220, 230)
            end
            CurrentTab = tabIndex
            Container.CanvasPosition = Vector2.new(0, 0)
        end
        TabBtn.MouseButton1Click:Connect(SelectTab)
        Tabs[tabIndex] = {
            Name = config.Name,
            Button = TabBtn,
            Text = TabText,
            Icon = TabIcon,
            Content = TabContent,
            TitleFrame = TitleFrame
        }
        if tabOrder == 1 then
            SelectTab()
        end
        local TabElements = {}
        local elementOrder = 0
        local lastWasDropdown = false
        function TabElements.Button(config)
            elementOrder = elementOrder + 1
            if lastWasDropdown then
                ContainerListLayout.Padding = UDim.new(0, 10)
            else
                ContainerListLayout.Padding = UDim.new(0, 5)
            end
            lastWasDropdown = false
            local BtnFrame = Linux.Instance("Frame", {
                Parent = Container,
                BackgroundColor3 = Color3.fromRGB(25, 25, 30),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -5, 0, 34),
                ZIndex = 2,
                LayoutOrder = elementOrder
            })
            Linux.Instance("UIGradient", {
                Parent = BtnFrame,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 40))
                }),
                Rotation = 45
            })
            Linux.Instance("UIStroke", {
                Parent = BtnFrame,
                Color = Color3.fromRGB(40, 40, 50),
                Thickness = 1
            })
            local Btn = Linux.Instance("TextButton", {
                Parent = BtnFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 34),
                Position = UDim2.new(0, 0, 0, 0),
                Font = Enum.Font.SourceSansPro,
                Text = config.Name,
                TextColor3 = Color3.fromRGB(220, 220, 230),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2,
                AutoButtonColor = false
            })
            Linux.Instance("UIPadding", {
                Parent = Btn,
                PaddingLeft = UDim.new(0, 5)
            })
            local BtnIcon = Linux.Instance("ImageLabel", {
                Parent = BtnFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, -20, 0.5, -7),
                Image = "rbxassetid://10709791437",
                ImageColor3 = Color3.fromRGB(220, 220, 230),
                ZIndex = 2
            })
            local hoverColor = Color3.fromRGB(35, 35, 40)
            local originalColor = Color3.fromRGB(25, 25, 30)
            local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            Btn.MouseEnter:Connect(function()
                TweenService:Create(BtnFrame, tweenInfo, {BackgroundColor3 = hoverColor, Size = UDim2.new(1, -5, 0, 34 * 1.02)}):Play()
            end)
            Btn.MouseLeave:Connect(function()
                TweenService:Create(BtnFrame, tweenInfo, {BackgroundColor3 = originalColor, Size = UDim2.new(1, -5, 0, 34)}):Play()
            end)
            Btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    TweenService:Create(BtnFrame, tweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 150, 255)}):Play()
                end
            end)
            Btn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    TweenService:Create(BtnFrame, tweenInfo, {BackgroundColor3 = originalColor, Size = UDim2.new(1, -5, 0, 34)}):Play()
                end
            end)
            Btn.MouseButton1Click:Connect(function()
                spawn(function() Linux:SafeCallback(config.Callback) end)
            end)
            Container.CanvasPosition = Vector2.new(0, 0)
            return Btn
        end
        function TabElements.Toggle(config)
            elementOrder = elementOrder + 1
            if lastWasDropdown then
                ContainerListLayout.Padding = UDim.new(0, 10)
            else
                ContainerListLayout.Padding = UDim.new(0, 5)
            end
            lastWasDropdown = false
            local Toggle = Linux.Instance("Frame", {
                Parent = Container,
                BackgroundColor3 = Color3.fromRGB(25, 25, 30),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -5, 0, 34),
                ZIndex = 2,
                LayoutOrder = elementOrder
            })
            Linux.Instance("UIGradient", {
                Parent = Toggle,
                Color = zauważyłeś błąd w kodzie, popraw go:
ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 40))
                }),
                Rotation = 45
            })
            Linux.Instance("UIStroke", {
                Parent = Toggle,
                Color = Color3.fromRGB(40, 40, 50),
                Thickness = 1
            })
            local ToggleText = Linux.Instance("TextLabel", {
                Parent = Toggle,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.8, 0, 0, 34),
                Position = UDim2.new(0, 5, 0, 0),
                Font = Enum.Font.SourceSansPro,
                Text = config.Name,
                TextColor3 = Color3.fromRGB(220, 220, 230),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2,
                Name = "ToggleText"
            })
            local ToggleTrack = Linux.Instance("Frame", {
                Parent = Toggle,
                BackgroundColor3 = Color3.fromRGB(40, 40, 50),
                Size = UDim2.new(0, 36, 0, 18),
                Position = UDim2.new(1, -45, 0.5, -9),
                ZIndex = 2,
                BorderSizePixel = 0,
                Name = "Track"
            })
            Linux.Instance("UICorner", {
                Parent = ToggleTrack,
                CornerRadius = UDim.new(1, 0)
            })
            local ToggleKnob = Linux.Instance("Frame", {
                Parent = ToggleTrack,
                BackgroundColor3 = Color3.fromRGB(220, 220, 230),
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(0, 2, 0.5, -7),
                ZIndex = 3,
                BorderSizePixel = 0,
                Name = "Knob"
            })
            Linux.Instance("UICorner", {
                Parent = ToggleKnob,
                CornerRadius = UDim.new(1, 0)
            })
            local State = config.Default or false
            Toggle:SetAttribute("State", State)
            local isToggling = false
            local function UpdateToggle(thisToggle)
                if isToggling then return end
                isToggling = true
                local currentState = thisToggle:GetAttribute("State")
                local thisTrack = thisToggle:FindFirstChild("Track")
                local thisKnob = thisTrack and thisTrack:FindFirstChild("Knob")
                local thisText = thisToggle:FindFirstChild("ToggleText")
                if thisTrack and thisKnob and thisText then
                    local tween = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    if currentState then
                        TweenService:Create(thisTrack, tween, {BackgroundColor3 = Color3.fromRGB(50, 150, 255)}):Play()
                        TweenService:Create(thisKnob, tween, {Position = UDim2.new(0, 20, 0.5, -7)}):Play()
                        TweenService:Create(thisText, tween, {TextColor3 = Color3.fromRGB(50, 150, 255)}):Play()
                    else
                        TweenService:Create(thisTrack, tween, {BackgroundColor3 = Color3.fromRGB(40, 40, 50)}):Play()
                        TweenService:Create(thisKnob, tween, {Position = UDim2.new(0, 2, 0.5, -7)}):Play()
                        TweenService:Create(thisText, tween, {TextColor3 = Color3.fromRGB(220, 220, 230)}):Play()
                    end
                end
                task.wait(0.25)
                isToggling = false
            end
            UpdateToggle(Toggle)
            spawn(function() Linux:SafeCallback(config.Callback, State) end)
            ToggleTrack.InputBegan:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) and not isToggling then
                    local newState = not Toggle:GetAttribute("State")
                    Toggle:SetAttribute("State", newState)
                    UpdateToggle(Toggle)
                    spawn(function() Linux:SafeCallback(config.Callback, newState) end)
                end
            end)
            Container.CanvasPosition = Vector2.new(0, 0)
            return Toggle
        end
        function TabElements.Dropdown(config)
            elementOrder = elementOrder + 1
            lastWasDropdown = true
            local Dropdown = Linux.Instance("Frame", {
                Parent = Container,
                BackgroundColor3 = Color3.fromRGB(25, 25, 30),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -5, 0, 34),
                ZIndex = 2,
                LayoutOrder = elementOrder
            })
            Linux.Instance("UIGradient", {
                Parent = Dropdown,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 40))
                }),
                Rotation = 45
            })
            Linux.Instance("UIStroke", {
                Parent = Dropdown,
                Color = Color3.fromRGB(40, 40, 50),
                Thickness = 1
            })
            local DropdownButton = Linux.Instance("TextButton", {
                Parent = Dropdown,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Font = Enum.Font.SourceSansPro,
                Text = "",
                TextColor3 = Color3.fromRGB(220, 220, 230),
                TextSize = 14,
                ZIndex = 2,
                AutoButtonColor = false
            })
            Linux.Instance("TextLabel", {
                Parent = DropdownButton,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.8, 0, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Font = Enum.Font.SourceSansPro,
                Text = config.Name,
                TextColor3 = Color3.fromRGB(220, 220, 230),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })
            local Options = config.Options or {}
            local SelectedValue = config.Default or (Options[1] or "None")
            local Selected = Linux.Instance("TextLabel", {
                Parent = DropdownButton,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -40, 1, 0),
                Font = Enum.Font.SourceSansPro,
                Text = tostring(SelectedValue),
                TextColor3 = Color3.fromRGB(220, 220, 230),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 2
            })
            local Arrow = Linux.Instance("ImageLabel", {
                Parent = DropdownButton,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 14, 0, 14),
                Position = UDim2.new(1, -20, 0.5, -7),
                Image = "rbxassetid://10709791437",
                ImageColor3 = Color3.fromRGB(220, 220, 230),
                Rotation = 0,
                ZIndex = 2
            })
            local DropFrame = Linux.Instance("ScrollingFrame", {
                Parent = Container,
                BackgroundColor3 = Color3.fromRGB(25, 25, 30),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -5, 0, 0),
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ScrollBarThickness = 0,
                ScrollingEnabled = true,
                ZIndex = 3,
                LayoutOrder = elementOrder + 1,
                Visible = false
            })
            Linux.Instance("UIGradient", {
                Parent = DropFrame,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 40))
                }),
                Rotation = 45
            })
            Linux.Instance("UIStroke", {
                Parent = DropFrame,
                Color = Color3.fromRGB(40, 40, 50),
                Thickness = 1
            })
            Linux.Instance("UIListLayout", {
                Parent = DropFrame,
                Padding = UDim.new(0, 5),
                HorizontalAlignment = Enum.HorizontalAlignment.Left
            })
            Linux.Instance("UIPadding", {
                Parent = DropFrame,
                PaddingLeft = UDim.new(0, 5),
                PaddingTop = UDim.new(0, 5)
            })
            local IsOpen = false
            local function UpdateDropSize()
                local optionHeight = 25
                local paddingBetween = 5
                local paddingTop = 5
                local maxHeight = 150
                local numOptions = #Options
                local calculatedHeight = numOptions * optionHeight + (numOptions > 0 and (numOptions - 1) * paddingBetween + paddingTop or 0)
                local finalHeight = math.min(calculatedHeight, maxHeight)
                local tween = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                if IsOpen then
                    DropFrame.Visible = true
                    TweenService:Create(DropFrame, tween, {Size = UDim2.new(1, -5, 0, finalHeight)}):Play()
                    TweenService:Create(Arrow, tween, {Rotation = 85}):Play()
                else
                    TweenService:Create(DropFrame, tween, {Size = UDim2.new(1, -5, 0, 0)}):Play()
                    TweenService:Create(Arrow, tween, {Rotation = 0}):Play()
                    task.delay(0.25, function()
                        DropFrame.Visible = false
                    end)
                end
                task.wait(0.25)
            end
            local function PopulateOptions()
                for _, child in pairs(DropFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                if IsOpen then
                    for _, opt in pairs(Options) do
                        local OptBtn = Linux.Instance("TextButton", {
                            Parent = DropFrame,
                            BackgroundColor3 = Color3.fromRGB(25, 25, 30),
                            BorderSizePixel = 0,
                            Size = UDim2.new(1, -5, 0, 25),
                            Font = Enum.Font.SourceSansPro,
                            Text = tostring(opt),
                            TextColor3 = opt == SelectedValue and Color3.fromRGB(50, 150, 255) or Color3.fromRGB(160, 160, 170),
                            TextSize = 14,
                            TextXAlignment = Enum.TextXAlignment.Center,
                            ZIndex = 3,
                            AutoButtonColor = false
                        })
                        Linux.Instance("UIGradient", {
                            Parent = OptBtn,
                            Color = ColorSequence.new({
                                ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
                                ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 40))
                            }),
                            Rotation = 45
                        })
                        Linux.Instance("UIStroke", {
                            Parent = OptBtn,
                            Color = Color3.fromRGB(40, 40, 50),
                            Thickness = 1
                        })
                        local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                        OptBtn.MouseEnter:Connect(function()
                            TweenService:Create(OptBtn, tweenInfo, {Size = UDim2.new(1, -5, 0, 25 * 1.02)}):Play()
                        end)
                        OptBtn.MouseLeave:Connect(function()
                            TweenService:Create(OptBtn, tweenInfo, {Size = UDim2.new(1, -5, 0, 25)}):Play()
                        end)
                        OptBtn.MouseButton1Click:Connect(function()
                            SelectedValue = opt
                            Selected.Text = tostring(opt)
                            Selected.TextColor3 = Color3.fromRGB(50, 150, 255)
                            for _, btn in pairs(DropFrame:GetChildren()) do
                                if btn:IsA("TextButton") then
                                    btn.TextColor3 = btn.Text == tostring(opt) and Color3.fromRGB(50, 150, 255) or Color3.fromRGB(160, 160, 170)
                                end
                            end
                            PopulateOptions()
                            spawn(function() Linux:SafeCallback(config.Callback, opt) end)
                        end)
                    end
                end
                UpdateDropSize()
            end
            if #Options > 0 then
                PopulateOptions()
                spawn(function() Linux:SafeCallback(config.Callback, SelectedValue) end)
            end
            DropdownButton.MouseButton1Click:Connect(function()
                IsOpen = not IsOpen
                PopulateOptions()
            end)
            local function SetOptions(newOptions)
                Options = newOptions or {}
                SelectedValue = Options[1] or "None"
                Selected.Text = tostring(SelectedValue)
                Selected.TextColor3 = Color3.fromRGB(50, 150, 255)
                PopulateOptions()
                spawn(function() Linux:SafeCallback(config.Callback, SelectedValue) end)
            end
            local function SetValue(value)
                if table.find(Options, value) then
                    SelectedValue = value
                    Selected.Text = tostring(value)
                    Selected.TextColor3 = Color3.fromRGB(50, 150, 255)
                    for _, btn in pairs(DropFrame:GetChildren()) do
                        if btn:IsA("TextButton") then
                            btn.TextColor3 = btn.Text == tostring(value) and Color3.fromRGB(50, 150, 255) or Color3.fromRGB(160, 160, 170)
                        end
                    end
                    spawn(function() Linux:SafeCallback(config.Callback, value) end)
                end
            end
            Container.CanvasPosition = Vector2.new(0, 0)
            return {
                Instance = Dropdown,
                SetOptions = SetOptions,
                SetValue = SetValue,
                GetValue = function() return SelectedValue end
            }
        end
        function TabElements.Slider(config)
            elementOrder = elementOrder + 1
            if lastWasDropdown then
                ContainerListLayout.Padding = UDim.new(0, 10)
            else
                ContainerListLayout.Padding = UDim.new(0, 5)
            end
            lastWasDropdown = false
            local Slider = Linux.Instance("Frame", {
                Parent = Container,
                BackgroundColor3 = Color3.fromRGB(25, 25, 30),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -5, 0, 34),
                ZIndex = 2,
                LayoutOrder = elementOrder
            })
            Linux.Instance("UIGradient", {
                Parent = Slider,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 40))
                }),
                Rotation = 45
            })
            Linux.Instance("UIStroke", {
                Parent = Slider,
                Color = Color3.fromRGB(40, 40, 50),
                Thickness = 1
            })
            local TitleLabel = Linux.Instance("TextLabel", {
                Parent = Slider,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.4, 0, 0, 16),
                Position = UDim2.new(0, 5, 0, 2),
                Font = Enum.Font.SourceSansPro,
                Text = config.Name,
                TextColor3 = Color3.fromRGB(220, 220, 230),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })
            local SliderBar = Linux.Instance("Frame", {
                Parent = Slider,
                BackgroundColor3 = Color3.fromRGB(40, 40, 50),
                Size = UDim2.new(1, -10, 0, 6),
                Position = UDim2.new(0, 5, 0, 20),
                ZIndex = 2,
                BorderSizePixel = 0,
                Name = "Bar"
            })
            local ValueLabel = Linux.Instance("TextLabel", {
                Parent = Slider,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 40, 0, 16),
                Position = UDim2.new(1, -45, 0, 2),
                Font = Enum.Font.SourceSansPro,
                Text = "",
                TextColor3 = Color3.fromRGB(220, 220, 230),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 2,
                Name = "Value"
            })
            local FillBar = Linux.Instance("Frame", {
                Parent = SliderBar,
                BackgroundColor3 = Color3.fromRGB(50, 150, 255),
                Size = UDim2.new(0, 0, 1, 0),
                ZIndex = 2,
                BorderSizePixel = 0,
                Name = "Fill"
            })
            local Min = config.Min or 0
            local Max = config.Max or 100
            Slider:SetAttribute("Min", Min)
            Slider:SetAttribute("Max", Max)
            local Value = config.Default or Min
            Slider:SetAttribute("Value", Value)
            local function AnimateValueLabel()
                local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                TweenService:Create(ValueLabel, tweenInfo, {TextSize = 16}):Play()
                task.wait(0.25)
                TweenService:Create(ValueLabel, tweenInfo, {TextSize = 14}):Play()
            end
            local function UpdateSlider(pos)
                local barSize = SliderBar.AbsoluteSize.X
                local relativePos = math.clamp((pos - SliderBar.AbsolutePosition.X) / barSize, 0, 1)
                local min = Slider:GetAttribute("Min")
                local max = Slider:GetAttribute("Max")
                local value = min + (max - min) * relativePos
                value = math.floor(value + 0.5)
                Slider:SetAttribute("Value", value)
                FillBar.Size = UDim2.new(relativePos, 0, 1, 0)
                ValueLabel.Text = tostring(value)
                AnimateValueLabel()
                spawn(function() Linux:SafeCallback(config.Callback, value) end)
            end
            local draggingSlider = false
            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = true
                    UpdateSlider(input.Position.X)
                end
            end)
            SliderBar.InputChanged:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) and draggingSlider then
                    UpdateSlider(input.Position.X)
                end
            end)
            SliderBar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingSlider = false
                end
            end)
            local function SetValue(newValue)
                local min = Slider:GetAttribute("Min")
                local max = Slider:GetAttribute("Max")
                newValue = math.clamp(newValue, min, max)
                Slider:SetAttribute("Value", newValue)
                local relativePos = (newValue - min) / (max - min)
                FillBar.Size = UDim2.new(relativePos, 0, 1, 0)
                ValueLabel.Text = tostring(newValue)
                AnimateValueLabel()
                spawn(function() Linux:SafeCallback(config.Callback, newValue) end)
            end
            SetValue(Value)
            Container.CanvasPosition = Vector2.new(0, 0)
            return {
                Instance = Slider,
                SetValue = SetValue,
                GetValue = function() return Slider:GetAttribute("Value") end,
                SetMin = function(min) 
                    Slider:SetAttribute("Min", min)
                    SetValue(Slider:GetAttribute("Value"))
                end,
                SetMax = function(max) 
                    Slider:SetAttribute("Max", max)
                    SetValue(Slider:GetAttribute("Value"))
                end
            }
        end
        function TabElements.Input(config)
            elementOrder = elementOrder + 1
            if lastWasDropdown then
                ContainerListLayout.Padding = UDim.new(0, 10)
            else
                ContainerListLayout.Padding = UDim.new(0, 5)
            end
            lastWasDropdown = false
            local Input = Linux.Instance("Frame", {
                Parent = Container,
                BackgroundColor3 = Color3.fromRGB(25, 25, 30),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -5, 0, 34),
                ZIndex = 2,
                LayoutOrder = elementOrder
            })
            Linux.Instance("UIGradient", {
                Parent = Input,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 40))
                }),
                Rotation = 45
            })
            Linux.Instance("UIStroke", {
                Parent = Input,
                Color = Color3.fromRGB(40, 40, 50),
                Thickness = 1
            })
            Linux.Instance("TextLabel", {
                Parent = Input,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Font = Enum.Font.SourceSansPro,
                Text = config.Name,
                TextColor3 = Color3.fromRGB(220, 220, 230),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })
            local TextBox = Linux.Instance("TextBox", {
                Parent = Input,
                BackgroundColor3 = Color3.fromRGB(20, 20, 25),
                BorderSizePixel = 0,
                Size = UDim2.new(0.2, -5, 0, 22),
                Position = UDim2.new(0.78, 0, 0.5, -11),
                Font = Enum.Font.SourceSansPro,
                Text = config.Default or "",
                PlaceholderText = config.Placeholder or "Text Here",
                PlaceholderColor3 = Color3.fromRGB(160, 160, 170),
                TextColor3 = Color3.fromRGB(220, 220, 230),
                TextSize = 11,
                TextScaled = false,
                TextTruncate = Enum.TextTruncate.AtEnd,
                TextXAlignment = Enum.TextXAlignment.Center,
                ClearTextOnFocus = false,
                ClipsDescendants = true,
                ZIndex = 3
            })
            Linux.Instance("UIStroke", {
                Parent = TextBox,
                Color = Color3.fromRGB(40, 40, 50),
                Thickness = 1
            })
            Linux.Instance("UIPadding", {
                Parent = TextBox,
                PaddingLeft = UDim.new(0, 4),
                PaddingRight = UDim.new(0, 4)
            })
            local MaxLength = 100
            local function CheckTextBounds()
                if #TextBox.Text > MaxLength then
                    TextBox.Text = string.sub(TextBox.Text, 1, MaxLength)
                end
            end
            TextBox:GetPropertyChangedSignal("Text"):Connect(function()
                CheckTextBounds()
            end)
            local function UpdateInput()
                CheckTextBounds()
                spawn(function() Linux:SafeCallback(config.Callback, TextBox.Text) end)
            end
            TextBox.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    UpdateInput()
                end
            end)
            TextBox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                    TextBox:CaptureFocus()
                end
            end)
            spawn(function() Linux:SafeCallback(config.Callback, TextBox.Text) end)
            local function SetValue(newValue)
                local text = tostring(newValue)
                if #text > MaxLength then
                    text = string.sub(text, 1, MaxLength)
                end
                TextBox.Text = text
                UpdateInput()
            end
            Container.CanvasPosition = Vector2.new(0, 0)
            return {
                Instance = Input,
                SetValue = SetValue,
                GetValue = function() return TextBox.Text end
            }
        end
        function TabElements.Label(config)
            elementOrder = elementOrder + 1
            if lastWasDropdown then
                ContainerListLayout.Padding = UDim.new(0, 10)
            else
                ContainerListLayout.Padding = UDim.new(0, 5)
            end
            lastWasDropdown = false
            local LabelFrame = Linux.Instance("Frame", {
                Parent = Container,
                BackgroundColor3 = Color3.fromRGB(25, 25, 30),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -5, 0, 34),
                ZIndex = 2,
                LayoutOrder = elementOrder
            })
            Linux.Instance("UIGradient", {
                Parent = LabelFrame,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 40))
                }),
                Rotation = 45
            })
            Linux.Instance("UIStroke", {
                Parent = LabelFrame,
                Color = Color3.fromRGB(40, 40, 50),
                Thickness = 1
            })
            local LabelText = Linux.Instance("TextLabel", {
                Parent = LabelFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Font = Enum.Font.SourceSansPro,
                Text = config.Text or "Label",
                TextColor3 = Color3.fromRGB(220, 220, 230),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 2
            })
            local UpdateConnection = nil
            local lastUpdate = 0
            local updateInterval = 0.1
            local function StartUpdateLoop()
                if UpdateConnection then
                    UpdateConnection:Disconnect()
                end
                if config.UpdateCallback then
                    UpdateConnection = RunService.Heartbeat:Connect(function()
                        if not LabelFrame:IsDescendantOf(game) then
                            UpdateConnection:Disconnect()
                            return
                        end
                        local currentTime = tick()
                        if currentTime - lastUpdate >= updateInterval then
                            local success, newText = pcall(config.UpdateCallback)
                            if success and newText ~= nil then
                                LabelText.Text = tostring(newText)
                            end
                            lastUpdate = currentTime
                        end
                    end)
                end
            end
            local function SetText(newText)
                if config.UpdateCallback then
                    config.Text = tostring(newText)
                else
                    LabelText.Text = tostring(newText)
                end
            end
            if config.UpdateCallback then
                StartUpdateLoop()
            end
            Container.CanvasPosition = Vector2.new(0, 0)
            return {
                Instance = LabelFrame,
                SetText = SetText,
                GetText = function() return LabelText.Text end
            }
        end
        function TabElements.Section(config)
            elementOrder = elementOrder + 1
            if lastWasDropdown then
                ContainerListLayout.Padding = UDim.new(0, 10)
            else
                ContainerListLayout.Padding = UDim.new(0, 5)
            end
            lastWasDropdown = false
            local Section = Linux.Instance("Frame", {
                Parent = Container,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -5, 0, 24),
                AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = 2,
                LayoutOrder = elementOrder,
                BorderSizePixel = 0
            })
            Linux.Instance("TextLabel", {
                Parent = Section,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Font = Enum.Font.SourceSansPro,
                Text = config.Name,
                TextColor3 = Color3.fromRGB(220, 220, 230),
                TextSize = 18,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })
            Container.CanvasPosition = Vector2.new(0, 0)
            return Section
        end
        function TabElements.Paragraph(config)
            elementOrder = elementOrder + 1
            if lastWasDropdown then
                ContainerListLayout.Padding = UDim.new(0, 10)
            else
                ContainerListLayout.Padding = UDim.new(0, 5)
            end
            lastWasDropdown = false
            local ParagraphFrame = Linux.Instance("Frame", {
                Parent = Container,
                BackgroundColor3 = Color3.fromRGB(25, 25, 30),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -5, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = 2,
                LayoutOrder = elementOrder
            })
            Linux.Instance("UIGradient", {
                Parent = ParagraphFrame,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 40))
                }),
                Rotation = 45
            })
            Linux.Instance("UIStroke", {
                Parent = ParagraphFrame,
                Color = Color3.fromRGB(40, 40, 50),
                Thickness = 1
            })
            Linux.Instance("TextLabel", {
                Parent = ParagraphFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 0, 20),
                Position = UDim2.new(0, 5, 0, 5),
                Font = Enum.Font.SourceSansPro,
                Text = config.Title or "Paragraph",
                TextColor3 = Color3.fromRGB(220, 220, 230),
                TextSize = 16,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })
            local Content = Linux.Instance("TextLabel", {
                Parent = ParagraphFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -10, 0, 0),
                Position = UDim2.new(0, 5, 0, 25),
                Font = Enum.Font.SourceSansPro,
                Text = config.Content or "Content",
                TextColor3 = Color3.fromRGB(160, 160, 170),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                AutomaticSize = Enum.AutomaticSize.Y,
                ZIndex = 2
            })
            Linux.Instance("UIPadding", {
                Parent = ParagraphFrame,
                PaddingBottom = UDim.new(0, 5)
            })
            local function SetTitle(newTitle)
                ParagraphFrame:GetChildren()[1].Text = tostring(newTitle)
            end
            local function SetContent(newContent)
                Content.Text = tostring(newContent)
            end
            Container.CanvasPosition = Vector2.new(0, 0)
            return {
                Instance = ParagraphFrame,
                SetTitle = SetTitle,
                SetContent = SetContent
            }
        end
        function TabElements.Notification(config)
            elementOrder = elementOrder + 1
            if lastWasDropdown then
                ContainerListLayout.Padding = UDim.new(0, 10)
            else
                ContainerListLayout.Padding = UDim.new(0, 5)
            end
            lastWasDropdown = false
            local NotificationFrame = Linux.Instance("Frame", {
                Parent = Container,
                BackgroundColor3 = Color3.fromRGB(25, 25, 30),
                BorderSizePixel = 0,
                Size = UDim2.new(1, -5, 0, 34),
                ZIndex = 2,
                LayoutOrder = elementOrder
            })
            Linux.Instance("UIGradient", {
                Parent = NotificationFrame,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 40))
                }),
                Rotation = 45
            })
            Linux.Instance("UIStroke", {
                Parent = NotificationFrame,
                Color = Color3.fromRGB(40, 40, 50),
                Thickness = 1
            })
            Linux.Instance("TextLabel", {
                Parent = NotificationFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, 0, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                Font = Enum.Font.SourceSansPro,
                Text = config.Name,
                TextColor3 = Color3.fromRGB(220, 220, 230),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 2
            })
            local NotificationText = Linux.Instance("TextLabel", {
                Parent = NotificationFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.5, -10, 1, 0),
                Position = UDim2.new(0.5, 5, 0, 0),
                Font = Enum.Font.SourceSansPro,
                Text = config.Default or "Notification",
                TextColor3 = Color3.fromRGB(220, 220, 230),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 2
            })
            local function SetText(newText)
                NotificationText.Text = tostring(newText)
            end
            Container.CanvasPosition = Vector2.new(0, 0)
            return {
                Instance = NotificationFrame,
                SetText = SetText,
                GetText = function() return NotificationText.Text end
            }
        end
        return TabElements
    end
    return LinuxLib
end
return Linux
