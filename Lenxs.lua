local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Fluent = {}
Fluent.__index = Fluent
local Colors = {
    Background = Color3.fromRGB(32, 32, 32),
    BackgroundSecondary = Color3.fromRGB(40, 40, 40),
    BackgroundTertiary = Color3.fromRGB(50, 50, 50),
    Accent = Color3.fromRGB(0, 120, 212),
    AccentContrast = Color3.fromRGB(255, 255, 255),
    AccentLight = Color3.fromRGB(100, 180, 240),
    Text = Color3.fromRGB(240, 240, 240),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    Border = Color3.fromRGB(60, 60, 60),
    Error = Color3.fromRGB(232, 17, 35)
}
local Design = {
    Font = Enum.Font.GothamSemibold,
    TitleSize = 18,
    TextSize = 14,
    SmallTextSize = 12,
    CornerRadius = UDim.new(0, 6),
    StrokeThickness = 1,
    ElementHeight = 36,
    ElementPadding = 8,
    SectionPadding = 10,
    AnimationSpeed = 0.2
}
local function CreateInstance(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k == "Parent" or k == "LayoutOrder" or k == "ZIndex" or k == "Name" then
            inst[k] = v
        else
            local success, err = pcall(function()
                inst[k] = v
            end)
            if not success then
                warn("Fluent UI: Failed to set property", k, "on", class, ":", err)
            end
        end
    end
    return inst
end
local function CreateElement(elementType, config, container, layoutUtil)
    local elementFrame = CreateInstance("Frame", {
        Name = config.Name or elementType,
        Parent = container,
        Size = UDim2.new(1, 0, 0, Design.ElementHeight),
        BackgroundColor3 = Colors.BackgroundSecondary,
        BorderSizePixel = 0,
        LayoutOrder = layoutUtil:GetNextOrder(),
        ClipsDescendants = true
    })
    CreateInstance("UICorner", { Parent = elementFrame, CornerRadius = Design.CornerRadius })
    CreateInstance("UIStroke", { Parent = elementFrame, Color = Colors.Border, Thickness = Design.StrokeThickness, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
    CreateInstance("UIPadding", {
        Parent = elementFrame,
        PaddingLeft = UDim.new(0, Design.ElementPadding),
        PaddingRight = UDim.new(0, Design.ElementPadding),
        PaddingTop = UDim.new(0, Design.ElementPadding),
        PaddingBottom = UDim.new(0, Design.ElementPadding)
    })
    return elementFrame
end
local function Animate(instance, properties, overrideInfo)
    local tweenInfo = overrideInfo or TweenInfo.new(Design.AnimationSpeed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    tween:Play()
    return tween
end
function Fluent:SafeCallback(func, ...)
    if not func then return end
    local success, err = pcall(func, ...)
    if not success then
        warn("Fluent UI Callback Error:", err)
        self:Notify({
            Title = "Callback Error",
            Content = tostring(err),
            Duration = 5,
            Type = "Error"
        })
    end
end
function Fluent:Notify(config)
    local parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui")
    local existingHolder = parent:FindFirstChild("FluentNotificationHolder")
    if existingHolder then existingHolder:Destroy() end
    local holder = CreateInstance("ScreenGui", {
        Name = "FluentNotificationHolder",
        Parent = parent,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    local notificationWidth = 320
    local notificationHeight = 60 + (config.Content and 20 or 0)
    local startY = -notificationHeight - 10
    local endY = 10
    local notification = CreateInstance("Frame", {
        Name = "Notification",
        Parent = holder,
        Size = UDim2.new(0, notificationWidth, 0, notificationHeight),
        Position = UDim2.new(0.5, -notificationWidth / 2, 0, startY),
        BackgroundColor3 = Colors.BackgroundSecondary,
        BorderSizePixel = 0,
        ZIndex = 1000
    })
    CreateInstance("UICorner", { Parent = notification, CornerRadius = Design.CornerRadius })
    CreateInstance("UIStroke", { Parent = notification, Color = Colors.Border, Thickness = Design.StrokeThickness, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
    local accentColor = config.Type == "Error" and Colors.Error or Colors.Accent
    CreateInstance("Frame", {
        Name = "AccentBar",
        Parent = notification,
        Size = UDim2.new(0, 4, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = accentColor,
        BorderSizePixel = 0,
        ZIndex = 1001
    })
    CreateInstance("UICorner", { Parent = notification:FindFirstChild("AccentBar"), CornerRadius = Design.CornerRadius })
    local textPadding = 15
    CreateInstance("TextLabel", {
        Name = "Title",
        Parent = notification,
        Size = UDim2.new(1, -textPadding * 2 - 4, 0, 20),
        Position = UDim2.new(0, textPadding + 4, 0, 8),
        BackgroundTransparency = 1,
        Font = Design.Font,
        Text = config.Title or "Notification",
        TextColor3 = Colors.Text,
        TextSize = Design.TextSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        ZIndex = 1001
    })
    if config.Content then
        CreateInstance("TextLabel", {
            Name = "Content",
            Parent = notification,
            Size = UDim2.new(1, -textPadding * 2 - 4, 1, -35),
            Position = UDim2.new(0, textPadding + 4, 0, 28),
            BackgroundTransparency = 1,
            Font = Design.Font,
            Text = config.Content,
            TextColor3 = Colors.TextSecondary,
            TextSize = Design.SmallTextSize,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            ZIndex = 1001
        })
    end
    local progressBar
    if config.Duration and config.Duration > 0 then
        progressBar = CreateInstance("Frame", {
            Name = "ProgressBar",
            Parent = notification,
            Size = UDim2.new(1, 0, 0, 3),
            Position = UDim2.new(0, 0, 1, -3),
            BackgroundColor3 = Colors.BackgroundTertiary,
            BorderSizePixel = 0,
            ZIndex = 1001
        })
        local progressFill = CreateInstance("Frame", {
            Name = "ProgressFill",
            Parent = progressBar,
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
            ZIndex = 1002
        })
        CreateInstance("UICorner", { Parent = progressBar, CornerRadius = UDim.new(0, 2) })
        CreateInstance("UICorner", { Parent = progressFill, CornerRadius = UDim.new(0, 2) })
        Animate(notification, { Position = UDim2.new(0.5, -notificationWidth / 2, 0, endY) })
        Animate(progressFill, { Size = UDim2.new(1, 0, 1, 0) }, TweenInfo.new(config.Duration, Enum.EasingStyle.Linear))
        task.delay(config.Duration, function()
            if notification and notification.Parent then
                local exitTween = Animate(notification, { Position = UDim2.new(0.5, -notificationWidth / 2, 0, startY) })
                exitTween.Completed:Wait()
                if holder and holder.Parent then
                    holder:Destroy()
                end
            end
        end)
    else
        Animate(notification, { Position = UDim2.new(0.5, -notificationWidth / 2, 0, endY) })
    end
end
function Fluent.Create(config)
    local self = setmetatable({}, Fluent)
    local randomName = "FluentUI_" .. string.sub(HttpService:GenerateGUID(false), 1, 8)
    local parent = RunService:IsStudio() and LocalPlayer.PlayerGui or game:GetService("CoreGui")
    for _, v in pairs(parent:GetChildren()) do
        if v:IsA("ScreenGui") and v.Name:match("^FluentUI_") then
            v:Destroy()
        end
    end
    local ProtectGui = protectgui or (syn and syn.protect_gui) or function() end
    self.UI = CreateInstance("ScreenGui", {
        Name = randomName,
        Parent = parent,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    })
    ProtectGui(self.UI)
    local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local uiSize = isMobile and (config.SizeMobile or UDim2.fromOffset(360, 450)) or (config.SizePC or UDim2.fromOffset(580, 420))
    local tabWidth = config.TabWidth or 140
    self.Main = CreateInstance("Frame", {
        Name = "MainFrame",
        Parent = self.UI,
        Size = uiSize,
        Position = UDim2.new(0.5, -uiSize.X.Offset / 2, 0.5, -uiSize.Y.Offset / 2),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        Active = true,
        Draggable = true,
        ClipsDescendants = true
    })
    CreateInstance("UICorner", { Parent = self.Main, CornerRadius = Design.CornerRadius })
    CreateInstance("UIStroke", { Parent = self.Main, Color = Colors.Border, Thickness = Design.StrokeThickness + 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
    local topBarHeight = 30
    local TopBar = CreateInstance("Frame", {
        Name = "TopBar",
        Parent = self.Main,
        Size = UDim2.new(1, 0, 0, topBarHeight),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        ZIndex = 2
    })
    CreateInstance("TextLabel", {
        Name = "Title",
        Parent = TopBar,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Font = Design.Font,
        Text = config.Name or "Fluent UI",
        TextColor3 = Colors.Text,
        TextSize = Design.TitleSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 3
    })
    local TabsContainer = CreateInstance("Frame", {
        Name = "TabsContainer",
        Parent = self.Main,
        Size = UDim2.new(0, tabWidth, 1, -topBarHeight),
        Position = UDim2.new(0, 0, 0, topBarHeight),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        ZIndex = 2
    })
    self.TabHolder = CreateInstance("ScrollingFrame", {
        Name = "TabHolder",
        Parent = TabsContainer,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Colors.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y
    })
    CreateInstance("UIListLayout", {
        Parent = self.TabHolder,
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    CreateInstance("UIPadding", {
        Parent = self.TabHolder,
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10)
    })
    self.ContentFrame = CreateInstance("Frame", {
        Name = "ContentFrame",
        Parent = self.Main,
        Size = UDim2.new(1, -tabWidth, 1, -topBarHeight),
        Position = UDim2.new(0, tabWidth, 0, topBarHeight),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 1
    })
    self.Tabs = {}
    self.CurrentTab = nil
    self.TabOrder = 0
    local isHidden = false
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == Enum.KeyCode.RightAlt then
            isHidden = not isHidden
            self.Main.Visible = not isHidden
        end
    end)
    return self
end
function Fluent:Tab(config)
    self.TabOrder = self.TabOrder + 1
    local tabIndex = self.TabOrder
    local tabData = { Elements = {}, Order = 0, LayoutUtil = { CurrentOrder = 0, GetNextOrder = function(self) self.CurrentOrder = self.CurrentOrder + 1; return self.CurrentOrder end } }
    local tabButton = CreateInstance("TextButton", {
        Name = config.Name or "Tab",
        Parent = self.TabHolder,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Colors.Background,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        LayoutOrder = tabIndex,
        ZIndex = 3
    })
    CreateInstance("UICorner", { Parent = tabButton, CornerRadius = Design.CornerRadius })
    local indicator = CreateInstance("Frame", {
        Name = "Indicator",
        Parent = tabButton,
        Size = UDim2.new(0, 4, 0.7, 0),
        Position = UDim2.new(0, 0, 0.15, 0),
        BackgroundColor3 = Colors.Accent,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 5
    })
    CreateInstance("UICorner", { Parent = indicator, CornerRadius = UDim.new(0, 2) })
    local iconSize = 20
    local textPaddingLeft = 15
    if config.Icon and config.Icon.Enabled and config.Icon.Image then
        tabData.Icon = CreateInstance("ImageLabel", {
            Name = "Icon",
            Parent = tabButton,
            Size = UDim2.new(0, iconSize, 0, iconSize),
            Position = UDim2.new(0, textPaddingLeft, 0.5, -iconSize / 2),
            BackgroundTransparency = 1,
            Image = config.Icon.Image,
            ImageColor3 = Colors.TextSecondary,
            ScaleType = Enum.ScaleType.Fit,
            ZIndex = 4
        })
        textPaddingLeft = textPaddingLeft + iconSize + 8
    end
    tabData.TextLabel = CreateInstance("TextLabel", {
        Name = "Label",
        Parent = tabButton,
        Size = UDim2.new(1, -textPaddingLeft - 10, 1, 0),
        Position = UDim2.new(0, textPaddingLeft, 0, 0),
        BackgroundTransparency = 1,
        Font = Design.Font,
        Text = config.Name or "Tab",
        TextColor3 = Colors.TextSecondary,
        TextSize = Design.TextSize,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 4
    })
    tabData.Content = CreateInstance("ScrollingFrame", {
        Name = config.Name .. "Content",
        Parent = self.ContentFrame,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Visible = false,
        ClipsDescendants = true,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Colors.Accent,
        ZIndex = 2
    })
    tabData.ContentLayout = CreateInstance("UIListLayout", {
        Parent = tabData.Content,
        Padding = UDim.new(0, Design.SectionPadding),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })
    CreateInstance("UIPadding", {
        Parent = tabData.Content,
        PaddingTop = UDim.new(0, 15),
        PaddingBottom = UDim.new(0, 15),
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15)
    })
    local function SelectTab()
        if self.CurrentTab == tabIndex then return end
        if self.CurrentTab and self.Tabs[self.CurrentTab] then
            local previousTab = self.Tabs[self.CurrentTab]
            previousTab.Content.Visible = false
            Animate(previousTab.Button, { BackgroundColor3 = Colors.Background })
            Animate(previousTab.TextLabel, { TextColor3 = Colors.TextSecondary })
            previousTab.Indicator.Visible = false
            if previousTab.Icon then
                Animate(previousTab.Icon, { ImageColor3 = Colors.TextSecondary })
            end
        end
        tabData.Content.Visible = true
        Animate(tabButton, { BackgroundColor3 = Colors.BackgroundTertiary })
        Animate(tabData.TextLabel, { TextColor3 = Colors.Text })
        indicator.Visible = true
        if tabData.Icon then
            Animate(tabData.Icon, { ImageColor3 = Colors.Text })
        end
        self.CurrentTab = tabIndex
        tabData.Content.CanvasPosition = Vector2.new(0, 0)
    end
    tabButton.MouseEnter:Connect(function()
        if self.CurrentTab ~= tabIndex then
            Animate(tabButton, { BackgroundColor3 = Colors.BackgroundTertiary })
            Animate(tabData.TextLabel, { TextColor3 = Colors.Text })
             if tabData.Icon then Animate(tabData.Icon, { ImageColor3 = Colors.Text }) end
        end
    end)
    tabButton.MouseLeave:Connect(function()
        if self.CurrentTab ~= tabIndex then
            Animate(tabButton, { BackgroundColor3 = Colors.Background })
            Animate(tabData.TextLabel, { TextColor3 = Colors.TextSecondary })
             if tabData.Icon then Animate(tabData.Icon, { ImageColor3 = Colors.TextSecondary }) end
        end
    end)
    tabButton.MouseButton1Click:Connect(SelectTab)
    tabData.Button = tabButton
    tabData.Indicator = indicator
    self.Tabs[tabIndex] = tabData
    if tabIndex == 1 then
        SelectTab()
    end
    local methods = {}
    methods.Section = function(cfg)
        local sectionFrame = CreateInstance("Frame", {
            Name = cfg.Name or "Section",
            Parent = tabData.Content,
            Size = UDim2.new(1, 0, 0, 25),
            BackgroundTransparency = 1,
            LayoutOrder = tabData.LayoutUtil:GetNextOrder()
        })
        CreateInstance("TextLabel", {
            Name = "SectionLabel",
            Parent = sectionFrame,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Font = Design.Font,
            Text = "--- " .. (cfg.Name or "Section") .. " ---",
            TextColor3 = Colors.TextSecondary,
            TextSize = Design.SmallTextSize,
            TextXAlignment = Enum.TextXAlignment.Center,
            TextYAlignment = Enum.TextYAlignment.Center
        })
        return sectionFrame
    end
    methods.Label = function(cfg)
        local labelFrame = CreateElement("Label", cfg, tabData.Content, tabData.LayoutUtil)
        labelFrame.BackgroundTransparency = 1
        labelFrame.Size = UDim2.new(1, 0, 0, 20)
        labelFrame:FindFirstChildOfClass("UIStroke"):Destroy()
        labelFrame:FindFirstChildOfClass("UICorner"):Destroy()
        CreateInstance("TextLabel", {
            Name = "InfoLabel",
            Parent = labelFrame,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Font = Design.Font,
            Text = cfg.Text or "Label",
            TextColor3 = Colors.Text,
            TextSize = Design.TextSize,
            TextXAlignment = cfg.Align or Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextWrapped = true
        })
        return labelFrame
    end
    methods.Button = function(cfg)
        local btnFrame = CreateElement("Button", cfg, tabData.Content, tabData.LayoutUtil)
        local btn = CreateInstance("TextButton", {
            Name = "ActionButton",
            Parent = btnFrame,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Colors.Accent,
            BorderSizePixel = 0,
            Text = cfg.Name or "Button",
            Font = Design.Font,
            TextColor3 = Colors.AccentContrast,
            TextSize = Design.TextSize,
            AutoButtonColor = false
        })
        CreateInstance("UICorner", { Parent = btn, CornerRadius = Design.CornerRadius })
        btn.MouseEnter:Connect(function() Animate(btn, { BackgroundColor3 = Colors.AccentLight }) end)
        btn.MouseLeave:Connect(function() Animate(btn, { BackgroundColor3 = Colors.Accent }) end)
        btn.MouseButton1Click:Connect(function()
            Animate(btn, { Size = UDim2.new(0.98, 0, 0.98, 0), Position = UDim2.new(0.01, 0, 0.01, 0) }, TweenInfo.new(0.05))
            task.wait(0.05)
            Animate(btn, { Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 0, 0, 0) }, TweenInfo.new(0.1))
            self:SafeCallback(cfg.Callback)
        end)
        return btnFrame
    end
    methods.Toggle = function(cfg)
        local toggleFrame = CreateElement("Toggle", cfg, tabData.Content, tabData.LayoutUtil)
        local state = cfg.Default or false
        toggleFrame.BackgroundColor3 = Colors.Background
        toggleFrame:FindFirstChildOfClass("UIStroke"):Destroy()
        local label = CreateInstance("TextLabel", {
            Name = "ToggleLabel",
            Parent = toggleFrame,
            Size = UDim2.new(1, -50, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Font = Design.Font,
            Text = cfg.Name or "Toggle",
            TextColor3 = Colors.Text,
            TextSize = Design.TextSize,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center
        })
        local switchWidth = 44
        local switchHeight = 22
        local knobSize = 18
        local switchTrack = CreateInstance("Frame", {
            Name = "SwitchTrack",
            Parent = toggleFrame,
            Size = UDim2.new(0, switchWidth, 0, switchHeight),
            Position = UDim2.new(1, -switchWidth - Design.ElementPadding, 0.5, -switchHeight / 2),
            BackgroundColor3 = state and Colors.Accent or Colors.BackgroundTertiary,
            BorderSizePixel = 0,
            ClipsDescendants = true
        })
        CreateInstance("UICorner", { Parent = switchTrack, CornerRadius = UDim.new(0.5, 0) })
        local switchKnob = CreateInstance("Frame", {
            Name = "SwitchKnob",
            Parent = switchTrack,
            Size = UDim2.new(0, knobSize, 0, knobSize),
            Position = UDim2.new(state and 1 or 0, state and -knobSize - 2 or 2, 0.5, -knobSize / 2),
            BackgroundColor3 = Colors.Text,
            BorderSizePixel = 0
        })
        CreateInstance("UICorner", { Parent = switchKnob, CornerRadius = UDim.new(0.5, 0) })
        local toggleButton = CreateInstance("TextButton", {
            Name = "Hitbox",
            Parent = toggleFrame,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = ""
        })
        local function UpdateVisuals(currentState)
            local targetTrackColor = currentState and Colors.Accent or Colors.BackgroundTertiary
            local targetKnobPos = UDim2.new(currentState and 1 or 0, currentState and -knobSize - 2 or 2, 0.5, -knobSize / 2)
            Animate(switchTrack, { BackgroundColor3 = targetTrackColor })
            Animate(switchKnob, { Position = targetKnobPos })
        end
        toggleButton.MouseButton1Click:Connect(function()
            state = not state
            UpdateVisuals(state)
            self:SafeCallback(cfg.Callback, state)
        end)
        return toggleFrame
    end
    methods.Dropdown = function(cfg)
        local dropdownFrame = CreateElement("Dropdown", cfg, tabData.Content, tabData.LayoutUtil)
        dropdownFrame.ClipsDescendants = false
        dropdownFrame.ZIndex = 5
        local options = cfg.Options or {}
        local selectedValue = cfg.Default or (options[1] or "Select...")
        local isOpen = false
        local optionHeight = 30
        local maxVisibleOptions = 5
        local dropdownButton = CreateInstance("TextButton", {
            Name = "DropdownButton",
            Parent = dropdownFrame,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Colors.BackgroundSecondary,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false
        })
        CreateInstance("UICorner", { Parent = dropdownButton, CornerRadius = Design.CornerRadius })
        local label = CreateInstance("TextLabel", {
            Name = "DropdownLabel",
            Parent = dropdownButton,
            Size = UDim2.new(0.7, 0, 1, 0),
            Position = UDim2.new(0, Design.ElementPadding, 0, 0),
            BackgroundTransparency = 1,
            Font = Design.Font,
            Text = cfg.Name or "Dropdown",
            TextColor3 = Colors.TextSecondary,
            TextSize = Design.SmallTextSize,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        })
        local selectedText = CreateInstance("TextLabel", {
            Name = "SelectedText",
            Parent = dropdownButton,
            Size = UDim2.new(1, -Design.ElementPadding * 2 - 20, 0, 20),
            Position = UDim2.new(0, Design.ElementPadding, 0.5, -5),
            BackgroundTransparency = 1,
            Font = Design.Font,
            Text = tostring(selectedValue),
            TextColor3 = Colors.Text,
            TextSize = Design.TextSize,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Bottom
        })
        local arrow = CreateInstance("ImageLabel", {
            Name = "Arrow",
            Parent = dropdownButton,
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(1, -Design.ElementPadding - 12, 0.5, -6),
            BackgroundTransparency = 1,
            Image = "rbxassetid://3926305904",
            ImageColor3 = Colors.TextSecondary,
            Rotation = 0
        })
        local optionsFrame = CreateInstance("Frame", {
            Name = "OptionsFrame",
            Parent = dropdownFrame,
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 1, 5),
            BackgroundColor3 = Colors.BackgroundTertiary,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Visible = false,
            ZIndex = 10
        })
        CreateInstance("UICorner", { Parent = optionsFrame, CornerRadius = Design.CornerRadius })
        CreateInstance("UIStroke", { Parent = optionsFrame, Color = Colors.Border, Thickness = Design.StrokeThickness, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
        local optionsScroll = CreateInstance("ScrollingFrame", {
            Name = "OptionsScroll",
            Parent = optionsFrame,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Colors.Accent
        })
        local optionsLayout = CreateInstance("UIListLayout", {
            Parent = optionsScroll,
            Padding = UDim.new(0, 2),
            SortOrder = Enum.SortOrder.LayoutOrder
        })
        CreateInstance("UIPadding", {
            Parent = optionsScroll,
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5),
            PaddingTop = UDim.new(0, 5),
            PaddingBottom = UDim.new(0, 5)
        })
        local function UpdateOptions()
            optionsScroll.CanvasPosition = Vector2.zero
            for _, child in ipairs(optionsScroll:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            for i, optionValue in ipairs(options) do
                local optionButton = CreateInstance("TextButton", {
                    Name = tostring(optionValue),
                    Parent = optionsScroll,
                    Size = UDim2.new(1, 0, 0, optionHeight),
                    BackgroundColor3 = Colors.BackgroundTertiary,
                    BorderSizePixel = 0,
                    Text = tostring(optionValue),
                    Font = Design.Font,
                    TextColor3 = Colors.Text,
                    TextSize = Design.TextSize,
                    AutoButtonColor = false,
                    LayoutOrder = i
                })
                CreateInstance("UICorner", { Parent = optionButton, CornerRadius = Design.CornerRadius })
                optionButton.MouseEnter:Connect(function() Animate(optionButton, { BackgroundColor3 = Colors.Accent }) end)
                optionButton.MouseLeave:Connect(function() Animate(optionButton, { BackgroundColor3 = Colors.BackgroundTertiary }) end)
                optionButton.MouseButton1Click:Connect(function()
                    selectedValue = optionValue
                    selectedText.Text = tostring(selectedValue)
                    isOpen = false
                    Animate(optionsFrame, { Size = UDim2.new(1, 0, 0, 0) })
                    Animate(arrow, { Rotation = 0 })
                    optionsFrame.Visible = false
                    dropdownFrame.ZIndex = 5
                    self:SafeCallback(cfg.Callback, selectedValue)
                end)
            end
            local totalHeight = (#options * (optionHeight + optionsLayout.Padding.Offset)) + 10
            local clampedHeight = math.min(totalHeight, (maxVisibleOptions * (optionHeight + optionsLayout.Padding.Offset)) + 10)
            if isOpen then
                 Animate(optionsFrame, { Size = UDim2.new(1, 0, 0, clampedHeight) })
            end
        end
        dropdownButton.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            if isOpen then
                dropdownFrame.ZIndex = 10
                optionsFrame.Visible = true
                UpdateOptions()
                Animate(arrow, { Rotation = 180 })
            else
                Animate(optionsFrame, { Size = UDim2.new(1, 0, 0, 0) })
                Animate(arrow, { Rotation = 0 })
                task.wait(Design.AnimationSpeed)
                if not isOpen then optionsFrame.Visible = false end
                dropdownFrame.ZIndex = 5
            end
        end)
        UpdateOptions()
        return dropdownFrame
    end
    methods.Slider = function(cfg)
        local sliderFrame = CreateElement("Slider", cfg, tabData.Content, tabData.LayoutUtil)
        sliderFrame.Size = UDim2.new(1, 0, 0, Design.ElementHeight + 10)
        local minVal = cfg.Min or 0
        local maxVal = cfg.Max or 100
        local currentVal = cfg.Default or minVal
        local precision = cfg.Precision or 0
        local label = CreateInstance("TextLabel", {
            Name = "SliderLabel",
            Parent = sliderFrame,
            Size = UDim2.new(0.7, 0, 0, 20),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Font = Design.Font,
            Text = cfg.Name or "Slider",
            TextColor3 = Colors.Text,
            TextSize = Design.TextSize,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        })
        local valueLabel = CreateInstance("TextLabel", {
            Name = "ValueLabel",
            Parent = sliderFrame,
            Size = UDim2.new(0.3, -Design.ElementPadding, 0, 20),
            Position = UDim2.new(0.7, 0, 0, 0),
            BackgroundTransparency = 1,
            Font = Design.Font,
            Text = string.format("%." .. precision .. "f", currentVal),
            TextColor3 = Colors.TextSecondary,
            TextSize = Design.TextSize,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextYAlignment = Enum.TextYAlignment.Top
        })
        local trackHeight = 6
        local thumbSize = 16
        local trackYPos = Design.ElementHeight - trackHeight - 5
        local trackBackground = CreateInstance("Frame", {
            Name = "TrackBackground",
            Parent = sliderFrame,
            Size = UDim2.new(1, -Design.ElementPadding * 2, 0, trackHeight),
            Position = UDim2.new(0, Design.ElementPadding, 0, trackYPos),
            BackgroundColor3 = Colors.BackgroundTertiary,
            BorderSizePixel = 0
        })
        CreateInstance("UICorner", { Parent = trackBackground, CornerRadius = UDim.new(0.5, 0) })
        local trackFill = CreateInstance("Frame", {
            Name = "TrackFill",
            Parent = trackBackground,
            Size = UDim2.new((currentVal - minVal) / (maxVal - minVal), 0, 1, 0),
            BackgroundColor3 = Colors.Accent,
            BorderSizePixel = 0
        })
        CreateInstance("UICorner", { Parent = trackFill, CornerRadius = UDim.new(0.5, 0) })
        local thumb = CreateInstance("Frame", {
            Name = "Thumb",
            Parent = trackBackground,
            Size = UDim2.new(0, thumbSize, 0, thumbSize),
            Position = UDim2.new((currentVal - minVal) / (maxVal - minVal), -thumbSize / 2, 0.5, -thumbSize / 2),
            BackgroundColor3 = Colors.Text,
            BorderSizePixel = 0,
            ZIndex = 2
        })
        CreateInstance("UICorner", { Parent = thumb, CornerRadius = UDim.new(0.5, 0) })
        CreateInstance("UIStroke", { Parent = thumb, Color = Colors.Border, Thickness = 1 })
        local dragging = false
        local sliderButton = CreateInstance("TextButton", {
            Name = "Hitbox",
            Parent = trackBackground,
            Size = UDim2.new(1, 0, 3, 0),
            Position = UDim2.new(0, 0, 0.5, -1.5 * trackHeight),
            BackgroundTransparency = 1,
            Text = "",
            ZIndex = 3
        })
        local function UpdateSlider(inputPos)
            local relativePos = inputPos.X - trackBackground.AbsolutePosition.X
            local percentage = math.clamp(relativePos / trackBackground.AbsoluteSize.X, 0, 1)
            local newValue = minVal + (maxVal - minVal) * percentage
            local roundedValue = tonumber(string.format("%." .. precision .. "f", newValue))
            if roundedValue ~= currentVal then
                currentVal = roundedValue
                valueLabel.Text = string.format("%." .. precision .. "f", currentVal)
                local fillScale = (currentVal - minVal) / (maxVal - minVal)
                trackFill.Size = UDim2.new(fillScale, 0, 1, 0)
                thumb.Position = UDim2.new(fillScale, -thumbSize / 2, 0.5, -thumbSize / 2)
                self:SafeCallback(cfg.Callback, currentVal)
            end
        end
        sliderButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                Animate(thumb, { Size = UDim2.new(0, thumbSize * 1.2, 0, thumbSize * 1.2), Position = thumb.Position - UDim2.fromOffset(thumbSize*0.1, thumbSize*0.1) }, TweenInfo.new(0.1))
                UpdateSlider(input.Position)
            end
        end)
        sliderButton.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateSlider(input.Position)
            end
        end)
        sliderButton.InputEnded:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                dragging = false
                Animate(thumb, { Size = UDim2.new(0, thumbSize, 0, thumbSize), Position = thumb.Position + UDim2.fromOffset(thumbSize*0.1, thumbSize*0.1) }, TweenInfo.new(0.1))
            end
        end)
        return sliderFrame
    end
    methods.Input = function(cfg)
        local inputFrame = CreateElement("Input", cfg, tabData.Content, tabData.LayoutUtil)
        local label = CreateInstance("TextLabel", {
            Name = "InputLabel",
            Parent = inputFrame,
            Size = UDim2.new(1, -Design.ElementPadding * 2, 0, 15),
            Position = UDim2.new(0, Design.ElementPadding, 0, 2),
            BackgroundTransparency = 1,
            Font = Design.Font,
            Text = cfg.Name or "Input",
            TextColor3 = Colors.TextSecondary,
            TextSize = Design.SmallTextSize,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top
        })
        local textBox = CreateInstance("TextBox", {
            Name = "InputBox",
            Parent = inputFrame,
            Size = UDim2.new(1, -Design.ElementPadding * 2, 0, 20),
            Position = UDim2.new(0, Design.ElementPadding, 0, 18),
            BackgroundColor3 = Colors.Background,
            BorderSizePixel = 0,
            Font = Design.Font,
            Text = cfg.Default or "",
            TextColor3 = Colors.Text,
            TextSize = Design.TextSize,
            PlaceholderText = cfg.Placeholder or "Enter text...",
            PlaceholderColor3 = Colors.TextSecondary,
            ClearTextOnFocus = cfg.ClearOnFocus or false,
            TextXAlignment = Enum.TextXAlignment.Left,
            ClipsDescendants = true
        })
        CreateInstance("UICorner", { Parent = textBox, CornerRadius = UDim.new(0, 4) })
        CreateInstance("UIStroke", { Parent = textBox, Color = Colors.Border, Thickness = 1 })
        textBox.FocusGained:Connect(function()
            textBox:FindFirstChildOfClass("UIStroke").Color = Colors.Accent
        end)
        textBox.FocusLost:Connect(function(enterPressed)
            textBox:FindFirstChildOfClass("UIStroke").Color = Colors.Border
            if enterPressed then
                self:SafeCallback(cfg.Callback, textBox.Text)
            end
        end)
        textBox.TextChanged:Connect(function()
             if not cfg.CallbackOnEnter then
                 self:SafeCallback(cfg.Callback, textBox.Text)
             end
        end)
        return inputFrame
    end
    methods.Paragraph = function(cfg)
        local paraFrame = CreateElement("Paragraph", cfg, tabData.Content, tabData.LayoutUtil)
        paraFrame.BackgroundTransparency = 1
        paraFrame.Size = UDim2.new(1, 0, 0, 0)
        paraFrame.AutomaticSize = Enum.AutomaticSize.Y
        paraFrame:FindFirstChildOfClass("UIStroke"):Destroy()
        paraFrame:FindFirstChildOfClass("UICorner"):Destroy()
        if cfg.Title then
            CreateInstance("TextLabel", {
                Name = "ParaTitle",
                Parent = paraFrame,
                Size = UDim2.new(1, 0, 0, 20),
                BackgroundTransparency = 1,
                Font = Design.Font,
                Text = cfg.Title,
                TextColor3 = Colors.Text,
                TextSize = Design.TextSize + 2,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                LayoutOrder = 1
            })
        end
        CreateInstance("TextLabel", {
            Name = "ParaContent",
            Parent = paraFrame,
            Size = UDim2.new(1, 0, 0, 0),
            Position = UDim2.new(0, 0, 0, cfg.Title and 22 or 0),
            BackgroundTransparency = 1,
            Font = Design.Font,
            Text = cfg.Content or "Paragraph content goes here.",
            TextColor3 = Colors.TextSecondary,
            TextSize = Design.TextSize,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 2
        })
        CreateInstance("UIListLayout", { Parent = paraFrame, Padding = UDim.new(0, 5) })
        return paraFrame
    end
    return methods
end
return Fluent
