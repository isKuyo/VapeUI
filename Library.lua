local Wisper = {}

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local Player = Players.LocalPlayer

if _G.WisperInstance then
    _G.WisperInstance:Destroy()
    _G.WisperInstance = nil
end

local Theme = {
    Background = Color3.fromRGB(26, 25, 26), -- #1A191A
    Header = Color3.fromRGB(20, 20, 20), -- #141414
    Line = Color3.fromRGB(31, 30, 31), -- #1F1E1F
    CategoryBg = Color3.fromRGB(26, 25, 26), -- #1A191A
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = 0.6, -- 60% opacity (0.6 transparency)
    SubText = Color3.fromRGB(150, 150, 150),
    Accent = Color3.fromRGB(6, 125, 98), -- #067D62
    AccentHover = Color3.fromRGB(8, 145, 114),
    ModuleBackground = Color3.fromRGB(35, 34, 35),
    ModuleStroke = Color3.fromRGB(45, 44, 45),
    ToggleEnabled = Color3.fromRGB(6, 125, 98),
    ToggleDisabled = Color3.fromRGB(60, 60, 60)
}

local function Create(ClassName, Properties)
    local Instance_ = Instance.new(ClassName)
    for Property, Value in pairs(Properties) do
        Instance_[Property] = Value
    end
    return Instance_
end

local function Tween(Object, Properties, Duration, EasingStyle, EasingDirection)
    EasingStyle = EasingStyle or Enum.EasingStyle.Quad
    EasingDirection = EasingDirection or Enum.EasingDirection.Out
    Duration = Duration or 0.2
    local TweenObj = TweenService:Create(Object, TweenInfo.new(Duration, EasingStyle, EasingDirection), Properties)
    TweenObj:Play()
    return TweenObj
end

local function MakeDraggable(Frame, DragFrame)
    DragFrame = DragFrame or Frame
    local Dragging = false
    local DragInput, MousePos, FramePos

    DragFrame.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            MousePos = Input.Position
            FramePos = Frame.Position

            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    DragFrame.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            DragInput = Input
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Input == DragInput and Dragging then
            local Delta = Input.Position - MousePos
            Frame.Position = UDim2.new(
                FramePos.X.Scale,
                FramePos.X.Offset + Delta.X,
                FramePos.Y.Scale,
                FramePos.Y.Offset + Delta.Y
            )
        end
    end)
end

local ScreenGuiName = "Wisper_" .. tostring(math.random(100000, 999999))

function Wisper:CreateWindow(Config)
    Config = Config or {}
    Config.Name = Config.Name or "wisper"
    Config.GameName = Config.GameName or "Unknown Game"
    Config.Version = Config.Version or "1.0.0"
    Config.KeyBind = Config.KeyBind or Enum.KeyCode.RightControl

    local ScreenGui = Create("ScreenGui", {
        Name = ScreenGuiName,
        Parent = CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 10
    })

    _G.WisperInstance = ScreenGui

    local FRAME_WIDTH = 233

    -- Drop Shadow for MainFrame (separate frame in ScreenGui)
    local MainDropShadow = Create("ImageLabel", {
        Name = "MainDropShadow",
        Parent = ScreenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 50 + FRAME_WIDTH/2, 0, 50),
        Size = UDim2.new(0, FRAME_WIDTH + 47, 0, 100),
        ZIndex = 0,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450)
    })

    -- Main Frame Container (for layout)
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 50, 0, 50),
        Size = UDim2.new(0, FRAME_WIDTH, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = false,
        ZIndex = 5
    })

    local MainLayout = Create("UIListLayout", {
        Parent = MainFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0)
    })

    -- Update shadow position/size to follow MainFrame
    local function UpdateMainShadow()
        local pos = MainFrame.AbsolutePosition
        local size = MainFrame.AbsoluteSize
        MainDropShadow.Position = UDim2.new(0, pos.X + size.X / 2, 0, pos.Y + size.Y / 2)
        MainDropShadow.Size = UDim2.new(0, size.X + 47, 0, size.Y + 47)
        MainDropShadow.Visible = MainFrame.Visible
    end

    MainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateMainShadow)
    MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateMainShadow)
    MainFrame:GetPropertyChangedSignal("Visible"):Connect(UpdateMainShadow)
    RunService.RenderStepped:Connect(UpdateMainShadow)

    local MainCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = MainFrame
    })

    MakeDraggable(MainFrame)

    -- Header (dark bar at top)
    local Header = Create("Frame", {
        Name = "Header",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 36),
        LayoutOrder = 1,
        ZIndex = 6
    })

    -- Title Label in Header
    local TitleLabel = Create("TextLabel", {
        Name = "TitleLabel",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 100, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = Config.Name,
        TextColor3 = Color3.fromRGB(108, 160, 220),
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7
    })

    -- Search Icon (top right in header)
    local SearchIcon = Create("ImageLabel", {
        Name = "SearchIcon",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -28, 0.5, -10),
        Size = UDim2.new(0, 20, 0, 20),
        Image = "rbxassetid://3926305904",
        ImageRectOffset = Vector2.new(964, 324),
        ImageRectSize = Vector2.new(36, 36),
        ImageColor3 = Theme.Text,
        ImageTransparency = 0.6,
        ZIndex = 7
    })

    -- Header bottom line (inside header)
    local HeaderLine = Create("Frame", {
        Name = "HeaderLine",
        Parent = Header,
        BackgroundColor3 = Theme.Line,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 7
    })

    -- Categories Container (between header and footer)
    local CategoriesContainer = Create("Frame", {
        Name = "CategoriesContainer",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 2,
        ZIndex = 6
    })

    local CategoriesLayout = Create("UIListLayout", {
        Parent = CategoriesContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0)
    })

    -- Footer (dark bar at bottom with placeholder text)
    local Footer = Create("Frame", {
        Name = "Footer",
        Parent = MainFrame,
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 26),
        LayoutOrder = 3,
        ZIndex = 6
    })

    -- Footer top line
    local FooterLine = Create("Frame", {
        Name = "FooterLine",
        Parent = Footer,
        BackgroundColor3 = Theme.Line,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 7
    })

    -- Footer placeholder text
    local FooterText = Create("TextLabel", {
        Name = "FooterText",
        Parent = Footer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Font = Enum.Font.Gotham,
        Text = Config.GameName .. " - " .. Config.Version,
        TextColor3 = Theme.Text,
        TextTransparency = 0.8,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7
    })

    local Categories = {}
    local CurrentCategory = nil
    local SubMenuFrame = nil

    -- Drop Shadow for SubMenuFrame (separate in ScreenGui)
    local SubDropShadow = Create("ImageLabel", {
        Name = "SubDropShadow",
        Parent = ScreenGui,
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 310 + 140, 0, 50),
        Size = UDim2.new(0, 280 + 47, 0, 100),
        ZIndex = 0,
        Visible = false,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ImageTransparency = 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450)
    })

    -- Sub Menu Frame (appears when clicking a category)
    SubMenuFrame = Create("Frame", {
        Name = "SubMenuFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 310, 0, 50),
        Size = UDim2.new(0, 280, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
        ClipsDescendants = true,
        ZIndex = 5
    })

    -- Update shadow position/size to follow SubMenuFrame
    local function UpdateSubShadow()
        local pos = SubMenuFrame.AbsolutePosition
        local size = SubMenuFrame.AbsoluteSize
        SubDropShadow.Position = UDim2.new(0, pos.X + size.X / 2, 0, pos.Y + size.Y / 2)
        SubDropShadow.Size = UDim2.new(0, size.X + 47, 0, size.Y + 47)
        SubDropShadow.Visible = SubMenuFrame.Visible
    end

    SubMenuFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateSubShadow)
    SubMenuFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSubShadow)
    SubMenuFrame:GetPropertyChangedSignal("Visible"):Connect(UpdateSubShadow)
    RunService.RenderStepped:Connect(UpdateSubShadow)

    local SubMenuCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 5),
        Parent = SubMenuFrame
    })

    local SubMenuPadding = Create("UIPadding", {
        Parent = SubMenuFrame,
        PaddingTop = UDim.new(0, 15),
        PaddingBottom = UDim.new(0, 15),
        PaddingLeft = UDim.new(0, 15),
        PaddingRight = UDim.new(0, 15)
    })

    local SubMenuLayout = Create("UIListLayout", {
        Parent = SubMenuFrame,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8)
    })

    MakeDraggable(SubMenuFrame)

    -- Update SubMenu position based on MainFrame
    local function UpdateSubMenuPosition()
        local MainPos = MainFrame.AbsolutePosition
        local MainSize = MainFrame.AbsoluteSize
        SubMenuFrame.Position = UDim2.new(0, MainPos.X + MainSize.X + 10, 0, MainPos.Y)
    end

    MainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateSubMenuPosition)
    MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateSubMenuPosition)

    -- Toggle visibility
    local Visible = true
    UserInputService.InputBegan:Connect(function(Input, GameProcessed)
        if GameProcessed then return end
        if Input.KeyCode == Config.KeyBind then
            Visible = not Visible
            MainFrame.Visible = Visible
            if not Visible then
                SubMenuFrame.Visible = false
            elseif CurrentCategory then
                SubMenuFrame.Visible = true
            end
        end
    end)

    local Window = {}

    function Window:AddCategory(CategoryConfig)
        CategoryConfig = CategoryConfig or {}
        CategoryConfig.Name = CategoryConfig.Name or "Category"
        CategoryConfig.Icon = CategoryConfig.Icon or "rbxassetid://3926305904"
        CategoryConfig.IconRectOffset = CategoryConfig.IconRectOffset or Vector2.new(764, 244)
        CategoryConfig.IconRectSize = CategoryConfig.IconRectSize or Vector2.new(36, 36)

        local CategoryIndex = #Categories + 1

        -- Category Button (full width, no rounded corners, flat design)
        local CategoryButton = Create("Frame", {
            Name = "CategoryButton_" .. CategoryConfig.Name,
            Parent = CategoriesContainer,
            BackgroundColor3 = Theme.CategoryBg,
            Size = UDim2.new(1, 0, 0, 31),
            LayoutOrder = CategoryIndex,
            ZIndex = 6
        })

        -- Category Icon (left side)
        local CategoryIcon = Create("ImageLabel", {
            Name = "Icon",
            Parent = CategoryButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 15, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            Image = CategoryConfig.Icon,
            ImageRectOffset = CategoryConfig.IconRectOffset,
            ImageRectSize = CategoryConfig.IconRectSize,
            ImageColor3 = Theme.Text,
            ImageTransparency = Theme.TextDim,
            ZIndex = 7
        })

        -- Category Label
        local CategoryLabel = Create("TextLabel", {
            Name = "Label",
            Parent = CategoryButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 43, 0, 0),
            Size = UDim2.new(1, -70, 1, 0),
            Font = Enum.Font.Gotham,
            Text = CategoryConfig.Name,
            TextColor3 = Theme.Text,
            TextTransparency = Theme.TextDim,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 7
        })

        -- Arrow Icon (right side) - chevron right
        local ArrowIcon = Create("ImageLabel", {
            Name = "Arrow",
            Parent = CategoryButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -20, 0.5, -4),
            Size = UDim2.new(0, 8, 0, 8),
            Image = "rbxassetid://3926305904",
            ImageRectOffset = Vector2.new(564, 284),
            ImageRectSize = Vector2.new(36, 36),
            ImageColor3 = Theme.Text,
            ImageTransparency = 0.6,
            ZIndex = 7
        })

        local ClickButton = Create("TextButton", {
            Name = "ClickArea",
            Parent = CategoryButton,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            AutoButtonColor = false,
            ZIndex = 8
        })

        -- Modules container for this category (inside SubMenuFrame)
        local ModulesContainer = Create("Frame", {
            Name = "ModulesContainer_" .. CategoryConfig.Name,
            Parent = SubMenuFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = false,
            LayoutOrder = CategoryIndex
        })

        local ModulesLayout = Create("UIListLayout", {
            Parent = ModulesContainer,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 6)
        })

        local CategoryData = {
            Name = CategoryConfig.Name,
            Button = CategoryButton,
            ModulesContainer = ModulesContainer,
            Modules = {}
        }

        table.insert(Categories, CategoryData)

        -- Hover effects
        ClickButton.MouseEnter:Connect(function()
            Tween(CategoryLabel, {TextTransparency = 0.2}, 0.15)
            Tween(CategoryIcon, {ImageTransparency = 0.2}, 0.15)
        end)

        ClickButton.MouseLeave:Connect(function()
            Tween(CategoryLabel, {TextTransparency = Theme.TextDim}, 0.15)
            Tween(CategoryIcon, {ImageTransparency = Theme.TextDim}, 0.15)
        end)

        -- Click to open sub menu
        ClickButton.MouseButton1Click:Connect(function()
            -- Hide all other modules containers
            for _, Cat in ipairs(Categories) do
                Cat.ModulesContainer.Visible = false
            end

            if CurrentCategory == CategoryData then
                -- Close sub menu
                CurrentCategory = nil
                SubMenuFrame.Visible = false
            else
                -- Open this category's sub menu
                CurrentCategory = CategoryData
                CategoryData.ModulesContainer.Visible = true
                SubMenuFrame.Visible = true
                UpdateSubMenuPosition()
            end
        end)

        local Category = {}

        function Category:AddToggle(ToggleConfig)
            ToggleConfig = ToggleConfig or {}
            ToggleConfig.Name = ToggleConfig.Name or "Toggle"
            ToggleConfig.Default = ToggleConfig.Default or false
            ToggleConfig.Callback = ToggleConfig.Callback or function() end

            local Enabled = ToggleConfig.Default

            local ToggleFrame = Create("Frame", {
                Name = "Toggle_" .. ToggleConfig.Name,
                Parent = ModulesContainer,
                BackgroundColor3 = Theme.ModuleBackground,
                Size = UDim2.new(1, 0, 0, 36),
                LayoutOrder = #CategoryData.Modules + 1
            })

            local ToggleCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = ToggleFrame
            })

            local ToggleStroke = Create("UIStroke", {
                Parent = ToggleFrame,
                Color = Theme.ModuleStroke,
                Thickness = 1
            })

            local ToggleLabel = Create("TextLabel", {
                Name = "Label",
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -60, 1, 0),
                Font = Enum.Font.Gotham,
                Text = ToggleConfig.Name,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ToggleBox = Create("Frame", {
                Name = "ToggleBox",
                Parent = ToggleFrame,
                BackgroundColor3 = Enabled and Theme.ToggleEnabled or Theme.ToggleDisabled,
                Position = UDim2.new(1, -45, 0.5, -10),
                Size = UDim2.new(0, 36, 0, 20)
            })

            local ToggleBoxCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = ToggleBox
            })

            local ToggleCircle = Create("Frame", {
                Name = "Circle",
                Parent = ToggleBox,
                BackgroundColor3 = Theme.Text,
                Position = Enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16)
            })

            local ToggleCircleCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = ToggleCircle
            })

            local ToggleClickArea = Create("TextButton", {
                Name = "ClickArea",
                Parent = ToggleFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                AutoButtonColor = false
            })

            local function UpdateToggle()
                if Enabled then
                    Tween(ToggleBox, {BackgroundColor3 = Theme.ToggleEnabled}, 0.15)
                    Tween(ToggleCircle, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.15)
                else
                    Tween(ToggleBox, {BackgroundColor3 = Theme.ToggleDisabled}, 0.15)
                    Tween(ToggleCircle, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.15)
                end
            end

            ToggleClickArea.MouseButton1Click:Connect(function()
                Enabled = not Enabled
                UpdateToggle()
                ToggleConfig.Callback(Enabled)
            end)

            local ToggleAPI = {
                Set = function(self, Value)
                    Enabled = Value
                    UpdateToggle()
                    ToggleConfig.Callback(Enabled)
                end,
                Get = function(self)
                    return Enabled
                end
            }

            table.insert(CategoryData.Modules, ToggleAPI)
            return ToggleAPI
        end

        function Category:AddButton(ButtonConfig)
            ButtonConfig = ButtonConfig or {}
            ButtonConfig.Name = ButtonConfig.Name or "Button"
            ButtonConfig.Callback = ButtonConfig.Callback or function() end

            local ButtonFrame = Create("Frame", {
                Name = "Button_" .. ButtonConfig.Name,
                Parent = ModulesContainer,
                BackgroundColor3 = Theme.ModuleBackground,
                Size = UDim2.new(1, 0, 0, 36),
                LayoutOrder = #CategoryData.Modules + 1
            })

            local ButtonCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = ButtonFrame
            })

            local ButtonStroke = Create("UIStroke", {
                Parent = ButtonFrame,
                Color = Theme.ModuleStroke,
                Thickness = 1
            })

            local ButtonLabel = Create("TextLabel", {
                Name = "Label",
                Parent = ButtonFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -20, 1, 0),
                Font = Enum.Font.Gotham,
                Text = ButtonConfig.Name,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ButtonClickArea = Create("TextButton", {
                Name = "ClickArea",
                Parent = ButtonFrame,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = "",
                AutoButtonColor = false
            })

            ButtonClickArea.MouseEnter:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Theme.Accent}, 0.15)
            end)

            ButtonClickArea.MouseLeave:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Theme.ModuleBackground}, 0.15)
            end)

            ButtonClickArea.MouseButton1Click:Connect(function()
                ButtonConfig.Callback()
            end)

            table.insert(CategoryData.Modules, {})
        end

        function Category:AddSlider(SliderConfig)
            SliderConfig = SliderConfig or {}
            SliderConfig.Name = SliderConfig.Name or "Slider"
            SliderConfig.Min = SliderConfig.Min or 0
            SliderConfig.Max = SliderConfig.Max or 100
            SliderConfig.Default = SliderConfig.Default or SliderConfig.Min
            SliderConfig.Callback = SliderConfig.Callback or function() end

            local Value = SliderConfig.Default

            local SliderFrame = Create("Frame", {
                Name = "Slider_" .. SliderConfig.Name,
                Parent = ModulesContainer,
                BackgroundColor3 = Theme.ModuleBackground,
                Size = UDim2.new(1, 0, 0, 50),
                LayoutOrder = #CategoryData.Modules + 1
            })

            local SliderCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 6),
                Parent = SliderFrame
            })

            local SliderStroke = Create("UIStroke", {
                Parent = SliderFrame,
                Color = Theme.ModuleStroke,
                Thickness = 1
            })

            local SliderLabel = Create("TextLabel", {
                Name = "Label",
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 5),
                Size = UDim2.new(1, -60, 0, 18),
                Font = Enum.Font.Gotham,
                Text = SliderConfig.Name,
                TextColor3 = Theme.Text,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local SliderValueLabel = Create("TextLabel", {
                Name = "Value",
                Parent = SliderFrame,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -50, 0, 5),
                Size = UDim2.new(0, 40, 0, 18),
                Font = Enum.Font.Gotham,
                Text = tostring(Value),
                TextColor3 = Theme.SubText,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local SliderBar = Create("Frame", {
                Name = "Bar",
                Parent = SliderFrame,
                BackgroundColor3 = Theme.ToggleDisabled,
                Position = UDim2.new(0, 10, 0, 30),
                Size = UDim2.new(1, -20, 0, 8)
            })

            local SliderBarCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = SliderBar
            })

            local SliderFill = Create("Frame", {
                Name = "Fill",
                Parent = SliderBar,
                BackgroundColor3 = Theme.Accent,
                Size = UDim2.new((Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 0, 1, 0)
            })

            local SliderFillCorner = Create("UICorner", {
                CornerRadius = UDim.new(1, 0),
                Parent = SliderFill
            })

            local Dragging = false

            local function UpdateSlider(InputPosition)
                local BarPos = SliderBar.AbsolutePosition.X
                local BarSize = SliderBar.AbsoluteSize.X
                local Percent = math.clamp((InputPosition - BarPos) / BarSize, 0, 1)
                Value = math.floor(SliderConfig.Min + (SliderConfig.Max - SliderConfig.Min) * Percent)
                SliderFill.Size = UDim2.new(Percent, 0, 1, 0)
                SliderValueLabel.Text = tostring(Value)
                SliderConfig.Callback(Value)
            end

            SliderBar.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    UpdateSlider(Input.Position.X)
                end
            end)

            SliderBar.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(Input)
                if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                    UpdateSlider(Input.Position.X)
                end
            end)

            UserInputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                end
            end)

            local SliderAPI = {
                Set = function(self, NewValue)
                    Value = math.clamp(NewValue, SliderConfig.Min, SliderConfig.Max)
                    local Percent = (Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)
                    SliderFill.Size = UDim2.new(Percent, 0, 1, 0)
                    SliderValueLabel.Text = tostring(Value)
                    SliderConfig.Callback(Value)
                end,
                Get = function(self)
                    return Value
                end
            }

            table.insert(CategoryData.Modules, SliderAPI)
            return SliderAPI
        end

        return Category
    end

    function Window:Destroy()
        ScreenGui:Destroy()
        _G.WisperInstance = nil
    end

    return Window
end

return Wisper
