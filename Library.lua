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
    Background = Color3.fromRGB(24, 24, 27), -- #18181B
    Header = Color3.fromRGB(22, 22, 25), -- #161619
    Line = Color3.fromRGB(31, 30, 31), -- #1F1E1F
    CategoryBgTop = Color3.fromRGB(31, 31, 36), -- #1F1F24
    CategoryBgBottom = Color3.fromRGB(27, 27, 32), -- #1B1B20
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = 0.5, -- 50% opacity
    SubText = Color3.fromRGB(150, 150, 150),
    Accent = Color3.fromRGB(121, 175, 225), -- #79AFE1
    AccentHover = Color3.fromRGB(140, 190, 235),
    ModuleBackground = Color3.fromRGB(35, 34, 35),
    ModuleStroke = Color3.fromRGB(45, 44, 45),
    ToggleEnabled = Color3.fromRGB(121, 175, 225), -- #79AFE1
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

    local FRAME_WIDTH = 260

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

    -- Corner for header (top corners only)
    local HeaderCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = Header
    })

    -- Cover bottom corners of header (so only top is rounded)
    local HeaderBottomCover = Create("Frame", {
        Name = "HeaderBottomCover",
        Parent = Header,
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -10),
        Size = UDim2.new(1, 0, 0, 10),
        ZIndex = 6
    })

    -- Title Label in Header (accent color)
    local TitleLabel = Create("TextLabel", {
        Name = "TitleLabel",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0, 45, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = Config.Name,
        TextColor3 = Theme.Accent,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7
    })

    -- Game Name Label (next to title, uses real game name)
    local GameNameLabel = Create("TextLabel", {
        Name = "GameNameLabel",
        Parent = Header,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 65, 0, 0),
        Size = UDim2.new(1, -95, 1, 0),
        Font = Enum.Font.Gotham,
        Text = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
        TextColor3 = Theme.Text,
        TextTransparency = 0.5,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
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
        Padding = UDim.new(0, 4)
    })

    local CategoriesPadding = Create("UIPadding", {
        Parent = CategoriesContainer,
        PaddingTop = UDim.new(0, 6),
        PaddingBottom = UDim.new(0, 6),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8)
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

    -- Corner for footer (bottom corners only)
    local FooterCorner = Create("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = Footer
    })

    -- Cover top corners of footer (so only bottom is rounded)
    local FooterTopCover = Create("Frame", {
        Name = "FooterTopCover",
        Parent = Footer,
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 10),
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
        Text = Config.Version,
        TextColor3 = Theme.Text,
        TextTransparency = 0.8,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7
    })

    local Categories = {}
    local OpenCategories = {} -- Track open categories in order

    local SUB_MENU_WIDTH = 250
    local SUB_MENU_GAP = 10

    -- Function to update all sub menu positions based on order
    local function UpdateAllSubMenuPositions()
        local MainPos = MainFrame.AbsolutePosition
        local MainSize = MainFrame.AbsoluteSize
        local currentX = MainPos.X + MainSize.X + SUB_MENU_GAP

        for _, catData in ipairs(OpenCategories) do
            if catData.SubMenuFrame and catData.SubMenuFrame.Visible then
                catData.SubMenuFrame.Position = UDim2.new(0, currentX, 0, MainPos.Y)
                currentX = currentX + SUB_MENU_WIDTH + SUB_MENU_GAP
            end
        end
    end

    MainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateAllSubMenuPositions)
    MainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateAllSubMenuPositions)
    RunService.RenderStepped:Connect(UpdateAllSubMenuPositions)

    -- Toggle visibility
    local Visible = true
    UserInputService.InputBegan:Connect(function(Input, GameProcessed)
        if GameProcessed then return end
        if Input.KeyCode == Config.KeyBind then
            Visible = not Visible
            MainFrame.Visible = Visible
            -- Hide/show all open sub menus
            for _, catData in ipairs(OpenCategories) do
                if catData.SubMenuFrame then
                    catData.SubMenuFrame.Visible = Visible
                    if catData.SubDropShadow then
                        catData.SubDropShadow.Visible = Visible
                    end
                end
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

        -- Category Button with gradient background
        local CategoryButton = Create("Frame", {
            Name = "CategoryButton_" .. CategoryConfig.Name,
            Parent = CategoriesContainer,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BorderSizePixel = 0,
            Size = UDim2.new(1, 0, 0, 32),
            LayoutOrder = CategoryIndex,
            ZIndex = 6
        })

        local CategoryButtonCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 6),
            Parent = CategoryButton
        })

        -- Gradient for inactive state
        local CategoryGradient = Create("UIGradient", {
            Parent = CategoryButton,
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Theme.CategoryBgTop),
                ColorSequenceKeypoint.new(1, Theme.CategoryBgBottom)
            }),
            Rotation = 90
        })

        -- Category Icon (left side)
        local CategoryIcon = Create("ImageLabel", {
            Name = "Icon",
            Parent = CategoryButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0.5, -8),
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
            Position = UDim2.new(0, 36, 0, 0),
            Size = UDim2.new(1, -60, 1, 0),
            Font = Enum.Font.Gotham,
            Text = CategoryConfig.Name,
            TextColor3 = Theme.Text,
            TextTransparency = Theme.TextDim,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 7
        })

        -- Arrow/Link Icon (right side)
        local ArrowIcon = Create("ImageLabel", {
            Name = "Arrow",
            Parent = CategoryButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -24, 0.5, -6),
            Size = UDim2.new(0, 12, 0, 12),
            Image = "rbxassetid://3926305904",
            ImageRectOffset = Vector2.new(964, 284),
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

        local IsSelected = false

        -- Create individual SubMenuFrame for this category
        local SubDropShadow = Create("ImageLabel", {
            Name = "SubDropShadow_" .. CategoryConfig.Name,
            Parent = ScreenGui,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, SUB_MENU_WIDTH + 47, 0, 100),
            ZIndex = 0,
            Visible = false,
            Image = "rbxassetid://6014261993",
            ImageColor3 = Color3.fromRGB(0, 0, 0),
            ImageTransparency = 0.5,
            ScaleType = Enum.ScaleType.Slice,
            SliceCenter = Rect.new(49, 49, 450, 450)
        })

        local SubMenuFrame = Create("Frame", {
            Name = "SubMenuFrame_" .. CategoryConfig.Name,
            Parent = ScreenGui,
            BackgroundColor3 = Theme.Background,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, SUB_MENU_WIDTH, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Visible = false,
            ClipsDescendants = true,
            ZIndex = 5
        })

        local SubMenuCorner = Create("UICorner", {
            CornerRadius = UDim.new(0, 8),
            Parent = SubMenuFrame
        })

        local SubMenuLayout = Create("UIListLayout", {
            Parent = SubMenuFrame,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 0)
        })

        -- SubMenu Header with category name and icon
        local SubMenuHeader = Create("Frame", {
            Name = "SubMenuHeader",
            Parent = SubMenuFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 36),
            LayoutOrder = 0,
            ZIndex = 6
        })

        local SubMenuHeaderPadding = Create("UIPadding", {
            Parent = SubMenuHeader,
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12)
        })

        -- Category icon in header
        local SubMenuIcon = Create("ImageLabel", {
            Name = "Icon",
            Parent = SubMenuHeader,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            Image = CategoryConfig.Icon,
            ImageRectOffset = CategoryConfig.IconRectOffset,
            ImageRectSize = CategoryConfig.IconRectSize,
            ImageColor3 = Theme.Text,
            ZIndex = 7
        })

        -- Category name in header
        local SubMenuTitle = Create("TextLabel", {
            Name = "Title",
            Parent = SubMenuHeader,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 24, 0, 0),
            Size = UDim2.new(1, -50, 1, 0),
            Font = Enum.Font.GothamMedium,
            Text = CategoryConfig.Name,
            TextColor3 = Theme.Text,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 7
        })

        -- Collapse arrow button in header
        local SubMenuArrowButton = Create("ImageButton", {
            Name = "ArrowButton",
            Parent = SubMenuHeader,
            BackgroundTransparency = 1,
            Position = UDim2.new(1, -12, 0.5, -6),
            Size = UDim2.new(0, 12, 0, 12),
            Image = "rbxassetid://3926305904",
            ImageRectOffset = Vector2.new(44, 404),
            ImageRectSize = Vector2.new(36, 36),
            ImageColor3 = Theme.Text,
            ImageTransparency = 0.5,
            Rotation = 0,
            ZIndex = 8
        })

        -- Click area for header title (to collapse/expand)
        local SubMenuHeaderClickArea = Create("TextButton", {
            Name = "HeaderClickArea",
            Parent = SubMenuHeader,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, -20, 1, 0),
            Text = "",
            AutoButtonColor = false,
            ZIndex = 8
        })

        -- Update shadow for this submenu
        local function UpdateThisShadow()
            local pos = SubMenuFrame.AbsolutePosition
            local size = SubMenuFrame.AbsoluteSize
            SubDropShadow.Position = UDim2.new(0, pos.X + size.X / 2, 0, pos.Y + size.Y / 2)
            SubDropShadow.Size = UDim2.new(0, size.X + 47, 0, size.Y + 47)
            SubDropShadow.Visible = SubMenuFrame.Visible
        end

        SubMenuFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateThisShadow)
        SubMenuFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateThisShadow)
        SubMenuFrame:GetPropertyChangedSignal("Visible"):Connect(UpdateThisShadow)

        -- Modules container for this category (below header)
        local ModulesContainer = Create("Frame", {
            Name = "ModulesContainer_" .. CategoryConfig.Name,
            Parent = SubMenuFrame,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = 1,
            ClipsDescendants = true,
            ZIndex = 6
        })

        local ModulesPadding = Create("UIPadding", {
            Parent = ModulesContainer,
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10)
        })

        local ModulesLayout = Create("UIListLayout", {
            Parent = ModulesContainer,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 2)
        })

        -- Submenu collapse state
        local SubMenuCollapsed = false

        local function ToggleSubMenuCollapse()
            SubMenuCollapsed = not SubMenuCollapsed
            if SubMenuCollapsed then
                -- Collapse: hide modules, rotate arrow 180
                Tween(SubMenuArrowButton, {Rotation = 180}, 0.2)
                ModulesContainer.Visible = false
            else
                -- Expand: show modules, rotate arrow back to 0
                Tween(SubMenuArrowButton, {Rotation = 0}, 0.2)
                ModulesContainer.Visible = true
            end
        end

        -- Arrow button click
        SubMenuArrowButton.MouseButton1Click:Connect(ToggleSubMenuCollapse)

        -- Header right click
        SubMenuHeaderClickArea.MouseButton2Click:Connect(ToggleSubMenuCollapse)

        -- Arrow hover effect
        SubMenuArrowButton.MouseEnter:Connect(function()
            Tween(SubMenuArrowButton, {ImageTransparency = 0.2}, 0.1)
        end)

        SubMenuArrowButton.MouseLeave:Connect(function()
            Tween(SubMenuArrowButton, {ImageTransparency = 0.5}, 0.1)
        end)

        -- Function to update visual state
        local function UpdateVisualState(selected)
            IsSelected = selected
            if selected then
                -- Selected: accent background (solid), white text/icons
                CategoryGradient.Enabled = false
                Tween(CategoryButton, {BackgroundColor3 = Theme.Accent}, 0.15)
                Tween(CategoryLabel, {TextTransparency = 0}, 0.15)
                Tween(CategoryIcon, {ImageTransparency = 0}, 0.15)
                Tween(ArrowIcon, {ImageTransparency = 0}, 0.15)
            else
                -- Not selected: white background with gradient, dimmed text/icons
                CategoryGradient.Enabled = true
                Tween(CategoryButton, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.15)
                Tween(CategoryLabel, {TextTransparency = Theme.TextDim}, 0.15)
                Tween(CategoryIcon, {ImageTransparency = Theme.TextDim}, 0.15)
                Tween(ArrowIcon, {ImageTransparency = 0.6}, 0.15)
            end
        end

        local CategoryData = {
            Name = CategoryConfig.Name,
            Button = CategoryButton,
            SubMenuFrame = SubMenuFrame,
            SubDropShadow = SubDropShadow,
            ModulesContainer = ModulesContainer,
            Modules = {},
            UpdateVisualState = UpdateVisualState,
            IsOpen = false
        }

        table.insert(Categories, CategoryData)

        -- Hover effects
        ClickButton.MouseEnter:Connect(function()
            if not IsSelected then
                Tween(CategoryLabel, {TextTransparency = 0.2}, 0.15)
                Tween(CategoryIcon, {ImageTransparency = 0.2}, 0.15)
            end
        end)

        ClickButton.MouseLeave:Connect(function()
            if not IsSelected then
                Tween(CategoryLabel, {TextTransparency = Theme.TextDim}, 0.15)
                Tween(CategoryIcon, {ImageTransparency = Theme.TextDim}, 0.15)
            end
        end)

        -- Click to toggle this category's sub menu
        ClickButton.MouseButton1Click:Connect(function()
            if CategoryData.IsOpen then
                -- Close this category
                CategoryData.IsOpen = false
                SubMenuFrame.Visible = false
                SubDropShadow.Visible = false
                UpdateVisualState(false)
                
                -- Remove from open categories
                for i, cat in ipairs(OpenCategories) do
                    if cat == CategoryData then
                        table.remove(OpenCategories, i)
                        break
                    end
                end
            else
                -- Open this category
                CategoryData.IsOpen = true
                SubMenuFrame.Visible = true
                UpdateVisualState(true)
                
                -- Add to open categories
                table.insert(OpenCategories, CategoryData)
            end
            
            -- Update all positions
            UpdateAllSubMenuPositions()
        end)

        local Category = {}

        -- AddModule creates an expandable module (like Kill Aura, Speed, etc.)
        -- Left click toggles the module on/off
        -- Right click expands to show settings (toggles, sliders, etc.)
        function Category:AddModule(ModuleConfig)
            ModuleConfig = ModuleConfig or {}
            ModuleConfig.Name = ModuleConfig.Name or "Module"
            ModuleConfig.Default = ModuleConfig.Default or false
            ModuleConfig.Callback = ModuleConfig.Callback or function() end

            local Enabled = ModuleConfig.Default
            local Expanded = false
            local ModuleIndex = #CategoryData.Modules + 1

            -- Main module frame (header + expandable content)
            local ModuleFrame = Create("Frame", {
                Name = "Module_" .. ModuleConfig.Name,
                Parent = ModulesContainer,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 28),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = ModuleIndex,
                ClipsDescendants = false,
                ZIndex = 6
            })

            local ModuleLayout = Create("UIListLayout", {
                Parent = ModuleFrame,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 0)
            })

            -- Module header (the clickable row)
            local ModuleHeader = Create("Frame", {
                Name = "Header",
                Parent = ModuleFrame,
                BackgroundColor3 = Enabled and Theme.Accent or Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(1, 0, 0, 28),
                LayoutOrder = 0,
                ZIndex = 6
            })

            local ModuleHeaderCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = ModuleHeader
            })

            -- Gradient for inactive state
            local ModuleHeaderGradient = Create("UIGradient", {
                Parent = ModuleHeader,
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Theme.CategoryBgTop),
                    ColorSequenceKeypoint.new(1, Theme.CategoryBgBottom)
                }),
                Rotation = 90
            })
            ModuleHeaderGradient.Enabled = not Enabled

            local ModuleLabel = Create("TextLabel", {
                Name = "Label",
                Parent = ModuleHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -40, 1, 0),
                Font = Enum.Font.Gotham,
                Text = ModuleConfig.Name,
                TextColor3 = Theme.Text,
                TextTransparency = Enabled and 0 or Theme.TextDim,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 7
            })

            -- Settings icon button on the right
            local SettingsButton = Create("ImageButton", {
                Name = "SettingsButton",
                Parent = ModuleHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(1, -28, 0.5, -8),
                Size = UDim2.new(0, 16, 0, 16),
                Image = "rbxassetid://3926305904",
                ImageRectOffset = Vector2.new(764, 764),
                ImageRectSize = Vector2.new(36, 36),
                ImageColor3 = Theme.Text,
                ImageTransparency = 0.5,
                ZIndex = 9
            })

            local ModuleClickArea = Create("TextButton", {
                Name = "ClickArea",
                Parent = ModuleHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, -30, 1, 0),
                Text = "",
                AutoButtonColor = false,
                ZIndex = 8
            })

            -- Expandable options container (hidden by default)
            local OptionsContainer = Create("Frame", {
                Name = "Options",
                Parent = ModuleFrame,
                BackgroundColor3 = Theme.CategoryBgBottom,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = 1,
                Visible = false,
                ClipsDescendants = true,
                ZIndex = 6
            })

            local OptionsCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = OptionsContainer
            })

            local OptionsPadding = Create("UIPadding", {
                Parent = OptionsContainer,
                PaddingTop = UDim.new(0, 6),
                PaddingBottom = UDim.new(0, 6),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10)
            })

            local OptionsLayout = Create("UIListLayout", {
                Parent = OptionsContainer,
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 4)
            })

            local function UpdateModuleVisual()
                if Enabled then
                    ModuleHeaderGradient.Enabled = false
                    Tween(ModuleHeader, {BackgroundColor3 = Theme.Accent}, 0.15)
                    Tween(ModuleLabel, {TextTransparency = 0}, 0.15)
                    Tween(SettingsButton, {ImageTransparency = 0.3}, 0.15)
                else
                    ModuleHeaderGradient.Enabled = true
                    Tween(ModuleHeader, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.15)
                    Tween(ModuleLabel, {TextTransparency = Theme.TextDim}, 0.15)
                    Tween(SettingsButton, {ImageTransparency = 0.5}, 0.15)
                end
            end

            -- Function to toggle expand with animation
            local function ToggleExpand()
                Expanded = not Expanded
                if Expanded then
                    OptionsContainer.Visible = true
                    OptionsContainer.BackgroundTransparency = 1
                    Tween(OptionsContainer, {BackgroundTransparency = 0}, 0.2)
                    Tween(SettingsButton, {Rotation = 90}, 0.2)
                else
                    Tween(OptionsContainer, {BackgroundTransparency = 1}, 0.15)
                    Tween(SettingsButton, {Rotation = 0}, 0.2)
                    task.delay(0.15, function()
                        if not Expanded then
                            OptionsContainer.Visible = false
                        end
                    end)
                end
            end

            -- Hover effect
            ModuleClickArea.MouseEnter:Connect(function()
                if not Enabled then
                    Tween(ModuleLabel, {TextTransparency = 0.3}, 0.1)
                end
            end)

            ModuleClickArea.MouseLeave:Connect(function()
                if not Enabled then
                    Tween(ModuleLabel, {TextTransparency = Theme.TextDim}, 0.1)
                end
            end)

            -- Settings button hover
            SettingsButton.MouseEnter:Connect(function()
                Tween(SettingsButton, {ImageTransparency = 0.2}, 0.1)
            end)

            SettingsButton.MouseLeave:Connect(function()
                Tween(SettingsButton, {ImageTransparency = Enabled and 0.3 or 0.5}, 0.1)
            end)

            -- Left click: toggle module on/off
            ModuleClickArea.MouseButton1Click:Connect(function()
                Enabled = not Enabled
                UpdateModuleVisual()
                ModuleConfig.Callback(Enabled)
            end)

            -- Right click on module: expand/collapse options
            ModuleClickArea.MouseButton2Click:Connect(function()
                ToggleExpand()
            end)

            -- Settings button click: expand/collapse options
            SettingsButton.MouseButton1Click:Connect(function()
                ToggleExpand()
            end)

            -- Module API with methods to add options
            local ModuleAPI = {
                Set = function(self, Value)
                    Enabled = Value
                    UpdateModuleVisual()
                    ModuleConfig.Callback(Enabled)
                end,
                Get = function(self)
                    return Enabled
                end,
                Options = {}
            }

            -- Add Toggle option inside module
            function ModuleAPI:AddToggle(ToggleConfig)
                ToggleConfig = ToggleConfig or {}
                ToggleConfig.Name = ToggleConfig.Name or "Option"
                ToggleConfig.Default = ToggleConfig.Default or false
                ToggleConfig.Callback = ToggleConfig.Callback or function() end

                local OptionEnabled = ToggleConfig.Default

                local OptionFrame = Create("Frame", {
                    Name = "Option_" .. ToggleConfig.Name,
                    Parent = OptionsContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 24),
                    LayoutOrder = #ModuleAPI.Options + 1,
                    ZIndex = 6
                })

                local OptionLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = OptionFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -45, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = ToggleConfig.Name,
                    TextColor3 = Theme.Text,
                    TextTransparency = OptionEnabled and 0.2 or 0.5,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 7
                })

                -- Toggle switch background
                local ToggleSwitch = Create("Frame", {
                    Name = "Switch",
                    Parent = OptionFrame,
                    BackgroundColor3 = OptionEnabled and Theme.Accent or Theme.ModuleStroke,
                    Position = UDim2.new(1, -36, 0.5, -7),
                    Size = UDim2.new(0, 28, 0, 14),
                    ZIndex = 7
                })

                local ToggleSwitchCorner = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleSwitch
                })

                -- Toggle circle (white ball)
                local ToggleCircle = Create("Frame", {
                    Name = "Circle",
                    Parent = ToggleSwitch,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = OptionEnabled and UDim2.new(1, -12, 0.5, -5) or UDim2.new(0, 2, 0.5, -5),
                    Size = UDim2.new(0, 10, 0, 10),
                    ZIndex = 8
                })

                local ToggleCircleCorner = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleCircle
                })

                local OptionClickArea = Create("TextButton", {
                    Name = "ClickArea",
                    Parent = OptionFrame,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 9
                })

                local function UpdateOption()
                    if OptionEnabled then
                        Tween(ToggleSwitch, {BackgroundColor3 = Theme.Accent}, 0.15)
                        Tween(ToggleCircle, {Position = UDim2.new(1, -12, 0.5, -5)}, 0.15)
                        Tween(OptionLabel, {TextTransparency = 0.2}, 0.15)
                    else
                        Tween(ToggleSwitch, {BackgroundColor3 = Theme.ModuleStroke}, 0.15)
                        Tween(ToggleCircle, {Position = UDim2.new(0, 2, 0.5, -5)}, 0.15)
                        Tween(OptionLabel, {TextTransparency = 0.5}, 0.15)
                    end
                end

                OptionClickArea.MouseButton1Click:Connect(function()
                    OptionEnabled = not OptionEnabled
                    UpdateOption()
                    ToggleConfig.Callback(OptionEnabled)
                end)

                local OptionAPI = {
                    Set = function(self, Value)
                        OptionEnabled = Value
                        UpdateOption()
                        ToggleConfig.Callback(OptionEnabled)
                    end,
                    Get = function(self)
                        return OptionEnabled
                    end
                }

                table.insert(ModuleAPI.Options, OptionAPI)
                return OptionAPI
            end

            -- Add Slider option inside module
            function ModuleAPI:AddSlider(SliderConfig)
                SliderConfig = SliderConfig or {}
                SliderConfig.Name = SliderConfig.Name or "Slider"
                SliderConfig.Min = SliderConfig.Min or 0
                SliderConfig.Max = SliderConfig.Max or 100
                SliderConfig.Default = SliderConfig.Default or SliderConfig.Min
                SliderConfig.Callback = SliderConfig.Callback or function() end

                local SliderValue = SliderConfig.Default

                local SliderFrame = Create("Frame", {
                    Name = "Slider_" .. SliderConfig.Name,
                    Parent = OptionsContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    LayoutOrder = #ModuleAPI.Options + 1,
                    ZIndex = 6
                })

                local SliderLabel = Create("TextLabel", {
                    Name = "Label",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(0.6, 0, 0, 16),
                    Font = Enum.Font.Gotham,
                    Text = SliderConfig.Name,
                    TextColor3 = Theme.Text,
                    TextTransparency = 0.3,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 7
                })

                local SliderValueLabel = Create("TextLabel", {
                    Name = "Value",
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.6, 0, 0, 0),
                    Size = UDim2.new(0.4, 0, 0, 16),
                    Font = Enum.Font.Gotham,
                    Text = tostring(SliderValue),
                    TextColor3 = Theme.Accent,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 7
                })

                local SliderBar = Create("Frame", {
                    Name = "Bar",
                    Parent = SliderFrame,
                    BackgroundColor3 = Theme.ModuleStroke,
                    Position = UDim2.new(0, 0, 0, 20),
                    Size = UDim2.new(1, 0, 0, 6),
                    ZIndex = 7
                })

                local SliderBarCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 3),
                    Parent = SliderBar
                })

                local SliderFill = Create("Frame", {
                    Name = "Fill",
                    Parent = SliderBar,
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new((SliderValue - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min), 0, 1, 0),
                    ZIndex = 8
                })

                local SliderFillCorner = Create("UICorner", {
                    CornerRadius = UDim.new(0, 3),
                    Parent = SliderFill
                })

                -- White circle knob
                local initialPercent = (SliderValue - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)
                local SliderKnob = Create("Frame", {
                    Name = "Knob",
                    Parent = SliderBar,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = UDim2.new(initialPercent, -6, 0.5, -6),
                    Size = UDim2.new(0, 12, 0, 12),
                    ZIndex = 9
                })

                local SliderKnobCorner = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = SliderKnob
                })

                local SliderClickArea = Create("TextButton", {
                    Name = "ClickArea",
                    Parent = SliderBar,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 16),
                    Position = UDim2.new(0, 0, 0, -8),
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 10
                })

                local Dragging = false

                local function UpdateSlider(input)
                    local barPos = SliderBar.AbsolutePosition.X
                    local barSize = SliderBar.AbsoluteSize.X
                    local mouseX = input.Position.X
                    local percent = math.clamp((mouseX - barPos) / barSize, 0, 1)
                    SliderValue = math.floor(SliderConfig.Min + (SliderConfig.Max - SliderConfig.Min) * percent)
                    SliderValueLabel.Text = tostring(SliderValue)
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    SliderKnob.Position = UDim2.new(percent, -6, 0.5, -6)
                    SliderConfig.Callback(SliderValue)
                end

                SliderClickArea.MouseButton1Down:Connect(function()
                    Dragging = true
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if Dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        UpdateSlider(input)
                    end
                end)

                SliderClickArea.MouseButton1Click:Connect(function()
                    local mouse = Players.LocalPlayer:GetMouse()
                    UpdateSlider({Position = Vector3.new(mouse.X, mouse.Y, 0)})
                end)

                local SliderAPI = {
                    Set = function(self, Value)
                        SliderValue = math.clamp(Value, SliderConfig.Min, SliderConfig.Max)
                        local percent = (SliderValue - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)
                        SliderValueLabel.Text = tostring(SliderValue)
                        SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                        SliderKnob.Position = UDim2.new(percent, -6, 0.5, -6)
                        SliderConfig.Callback(SliderValue)
                    end,
                    Get = function(self)
                        return SliderValue
                    end
                }

                table.insert(ModuleAPI.Options, SliderAPI)
                return SliderAPI
            end

            table.insert(CategoryData.Modules, ModuleAPI)
            return ModuleAPI
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
