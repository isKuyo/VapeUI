local Wisper = {}

-- Anti-detection: Cache services with obfuscated access
local Services = setmetatable({}, {
    __index = function(self, serviceName)
        local service = game:GetService(serviceName)
        rawset(self, serviceName, service)
        return service
    end
})

local TweenService = Services.TweenService
local UserInputService = Services.UserInputService
local RunService = Services.RunService
local Players = Services.Players
local CoreGui = (syn and syn.protect_gui) and Services.CoreGui or (gethui and gethui()) or Services.CoreGui

local Player = Players.LocalPlayer

-- Anti-detection: Use random key for instance storage
local InstanceKey = tostring(math.random(100000000, 999999999))
local OldInstance = rawget(_G, InstanceKey)
if OldInstance and typeof(OldInstance) == "Instance" then
    pcall(function() OldInstance:Destroy() end)
    rawset(_G, InstanceKey, nil)
end

-- Anti-detection: Generate random names
local function RandomString(length)
    local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local result = ""
    for i = 1, length do
        local idx = math.random(1, #chars)
        result = result .. chars:sub(idx, idx)
    end
    return result
end

local function RandomName()
    return RandomString(math.random(8, 16))
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
    Accent = Color3.fromRGB(120, 134, 224), -- #7886E0
    AccentHover = Color3.fromRGB(140, 154, 240),
    ModuleBackground = Color3.fromRGB(35, 34, 35),
    ModuleStroke = Color3.fromRGB(45, 44, 45),
    ToggleDisabled = Color3.fromRGB(60, 60, 60)
}

-- Anti-detection: Protected instance creation
local ProtectedCreate = (function()
    local create = Instance.new
    local cloneFrom = {}
    
    return function(ClassName, Properties)
        local success, Instance_ = pcall(function()
            return create(ClassName)
        end)
        
        if not success then
            return nil
        end
        
        -- Randomize Name if not explicitly set
        if not Properties.Name then
            Properties.Name = RandomName()
        end
        
        for Property, Value in pairs(Properties) do
            pcall(function()
                Instance_[Property] = Value
            end)
        end
        
        return Instance_
    end
end)()

local function Create(ClassName, Properties)
    return ProtectedCreate(ClassName, Properties)
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

-- Anti-detection: Completely random ScreenGui name
local ScreenGuiName = RandomName()

local Icons = {
	["lucide-accessibility"] = "rbxassetid://10709751939",
	["lucide-activity"] = "rbxassetid://10709752035",
	["lucide-air-vent"] = "rbxassetid://10709752131",
	["lucide-airplay"] = "rbxassetid://10709752254",
	["lucide-alarm-check"] = "rbxassetid://10709752405",
	["lucide-alarm-clock"] = "rbxassetid://10709752630",
	["lucide-alarm-clock-off"] = "rbxassetid://10709752508",
	["lucide-alarm-minus"] = "rbxassetid://10709752732",
	["lucide-alarm-plus"] = "rbxassetid://10709752825",
	["lucide-album"] = "rbxassetid://10709752906",
	["lucide-alert-circle"] = "rbxassetid://10709752996",
	["lucide-alert-octagon"] = "rbxassetid://10709753064",
	["lucide-alert-triangle"] = "rbxassetid://10709753149",
	["lucide-align-center"] = "rbxassetid://10709753570",
	["lucide-align-center-horizontal"] = "rbxassetid://10709753272",
	["lucide-align-center-vertical"] = "rbxassetid://10709753421",
	["lucide-align-end-horizontal"] = "rbxassetid://10709753692",
	["lucide-align-end-vertical"] = "rbxassetid://10709753808",
	["lucide-align-horizontal-distribute-center"] = "rbxassetid://10747779791",
	["lucide-align-horizontal-distribute-end"] = "rbxassetid://10747784534",
	["lucide-align-horizontal-distribute-start"] = "rbxassetid://10709754118",
	["lucide-align-horizontal-justify-center"] = "rbxassetid://10709754204",
	["lucide-align-horizontal-justify-end"] = "rbxassetid://10709754317",
	["lucide-align-horizontal-justify-start"] = "rbxassetid://10709754436",
	["lucide-align-horizontal-space-around"] = "rbxassetid://10709754590",
	["lucide-align-horizontal-space-between"] = "rbxassetid://10709754749",
	["lucide-align-justify"] = "rbxassetid://10709759610",
	["lucide-align-left"] = "rbxassetid://10709759764",
	["lucide-align-right"] = "rbxassetid://10709759895",
	["lucide-align-start-horizontal"] = "rbxassetid://10709760051",
	["lucide-align-start-vertical"] = "rbxassetid://10709760244",
	["lucide-align-vertical-distribute-center"] = "rbxassetid://10709760351",
	["lucide-align-vertical-distribute-end"] = "rbxassetid://10709760434",
	["lucide-align-vertical-distribute-start"] = "rbxassetid://10709760612",
	["lucide-align-vertical-justify-center"] = "rbxassetid://10709760814",
	["lucide-align-vertical-justify-end"] = "rbxassetid://10709761003",
	["lucide-align-vertical-justify-start"] = "rbxassetid://10709761176",
	["lucide-align-vertical-space-around"] = "rbxassetid://10709761324",
	["lucide-align-vertical-space-between"] = "rbxassetid://10709761434",
	["lucide-anchor"] = "rbxassetid://10709761530",
	["lucide-angry"] = "rbxassetid://10709761629",
	["lucide-annoyed"] = "rbxassetid://10709761722",
	["lucide-aperture"] = "rbxassetid://10709761813",
	["lucide-apple"] = "rbxassetid://10709761889",
	["lucide-archive"] = "rbxassetid://10709762233",
	["lucide-archive-restore"] = "rbxassetid://10709762058",
	["lucide-armchair"] = "rbxassetid://10709762327",
	["lucide-anvil"] = "rbxassetid://77943964625400",
	["lucide-arrow-big-down"] = "rbxassetid://10747796644",
	["lucide-arrow-big-left"] = "rbxassetid://10709762574",
	["lucide-arrow-big-right"] = "rbxassetid://10709762727",
	["lucide-arrow-big-up"] = "rbxassetid://10709762879",
	["lucide-arrow-down"] = "rbxassetid://10709767827",
	["lucide-arrow-down-circle"] = "rbxassetid://10709763034",
	["lucide-arrow-down-left"] = "rbxassetid://10709767656",
	["lucide-arrow-down-right"] = "rbxassetid://10709767750",
	["lucide-arrow-left"] = "rbxassetid://10709768114",
	["lucide-arrow-left-circle"] = "rbxassetid://10709767936",
	["lucide-arrow-left-right"] = "rbxassetid://10709768019",
	["lucide-arrow-right"] = "rbxassetid://10709768347",
	["lucide-arrow-right-circle"] = "rbxassetid://10709768226",
	["lucide-arrow-up"] = "rbxassetid://10709768939",
	["lucide-arrow-up-circle"] = "rbxassetid://10709768432",
	["lucide-arrow-up-down"] = "rbxassetid://10709768538",
	["lucide-arrow-up-left"] = "rbxassetid://10709768661",
	["lucide-arrow-up-right"] = "rbxassetid://10709768787",
	["lucide-asterisk"] = "rbxassetid://10709769095",
	["lucide-at-sign"] = "rbxassetid://10709769286",
	["lucide-award"] = "rbxassetid://10709769406",
	["lucide-axe"] = "rbxassetid://10709769508",
	["lucide-axis-3d"] = "rbxassetid://10709769598",
	["lucide-baby"] = "rbxassetid://10709769732",
	["lucide-backpack"] = "rbxassetid://10709769841",
	["lucide-baggage-claim"] = "rbxassetid://10709769935",
	["lucide-banana"] = "rbxassetid://10709770005",
	["lucide-banknote"] = "rbxassetid://10709770178",
	["lucide-bar-chart"] = "rbxassetid://10709773755",
	["lucide-bar-chart-2"] = "rbxassetid://10709770317",
	["lucide-bar-chart-3"] = "rbxassetid://10709770431",
	["lucide-bar-chart-4"] = "rbxassetid://10709770560",
	["lucide-bar-chart-horizontal"] = "rbxassetid://10709773669",
	["lucide-barcode"] = "rbxassetid://10747360675",
	["lucide-baseline"] = "rbxassetid://10709773863",
	["lucide-bath"] = "rbxassetid://10709773963",
	["lucide-battery"] = "rbxassetid://10709774640",
	["lucide-battery-charging"] = "rbxassetid://10709774068",
	["lucide-battery-full"] = "rbxassetid://10709774206",
	["lucide-battery-low"] = "rbxassetid://10709774370",
	["lucide-battery-medium"] = "rbxassetid://10709774513",
	["lucide-beaker"] = "rbxassetid://10709774756",
	["lucide-bed"] = "rbxassetid://10709775036",
	["lucide-bed-double"] = "rbxassetid://10709774864",
	["lucide-bed-single"] = "rbxassetid://10709774968",
	["lucide-beer"] = "rbxassetid://10709775167",
	["lucide-bell"] = "rbxassetid://10709775704",
	["lucide-bell-minus"] = "rbxassetid://10709775241",
	["lucide-bell-off"] = "rbxassetid://10709775320",
	["lucide-bell-plus"] = "rbxassetid://10709775448",
	["lucide-bell-ring"] = "rbxassetid://10709775560",
	["lucide-bike"] = "rbxassetid://10709775894",
	["lucide-binary"] = "rbxassetid://10709776050",
	["lucide-bitcoin"] = "rbxassetid://10709776126",
	["lucide-bluetooth"] = "rbxassetid://10709776655",
	["lucide-bluetooth-connected"] = "rbxassetid://10709776240",
	["lucide-bluetooth-off"] = "rbxassetid://10709776344",
	["lucide-bluetooth-searching"] = "rbxassetid://10709776501",
	["lucide-bold"] = "rbxassetid://10747813908",
	["lucide-bomb"] = "rbxassetid://10709781460",
	["lucide-bone"] = "rbxassetid://10709781605",
	["lucide-book"] = "rbxassetid://10709781824",
	["lucide-book-open"] = "rbxassetid://10709781717",
	["lucide-bookmark"] = "rbxassetid://10709782154",
	["lucide-bookmark-minus"] = "rbxassetid://10709781919",
	["lucide-bookmark-plus"] = "rbxassetid://10709782044",
	["lucide-bot"] = "rbxassetid://10709782230",
	["lucide-box"] = "rbxassetid://10709782497",
	["lucide-box-select"] = "rbxassetid://10709782342",
	["lucide-boxes"] = "rbxassetid://10709782582",
	["lucide-briefcase"] = "rbxassetid://10709782662",
	["lucide-brush"] = "rbxassetid://10709782758",
	["lucide-bug"] = "rbxassetid://10709782845",
	["lucide-building"] = "rbxassetid://10709783051",
	["lucide-building-2"] = "rbxassetid://10709782939",
	["lucide-bus"] = "rbxassetid://10709783137",
	["lucide-cake"] = "rbxassetid://10709783217",
	["lucide-calculator"] = "rbxassetid://10709783311",
	["lucide-calendar"] = "rbxassetid://10709789505",
	["lucide-calendar-check"] = "rbxassetid://10709783474",
	["lucide-calendar-check-2"] = "rbxassetid://10709783392",
	["lucide-calendar-clock"] = "rbxassetid://10709783577",
	["lucide-calendar-days"] = "rbxassetid://10709783673",
	["lucide-calendar-heart"] = "rbxassetid://10709783835",
	["lucide-calendar-minus"] = "rbxassetid://10709783959",
	["lucide-calendar-off"] = "rbxassetid://10709788784",
	["lucide-calendar-plus"] = "rbxassetid://10709788937",
	["lucide-calendar-range"] = "rbxassetid://10709789053",
	["lucide-calendar-search"] = "rbxassetid://10709789200",
	["lucide-calendar-x"] = "rbxassetid://10709789407",
	["lucide-calendar-x-2"] = "rbxassetid://10709789329",
	["lucide-camera"] = "rbxassetid://10709789686",
	["lucide-camera-off"] = "rbxassetid://10747822677",
	["lucide-car"] = "rbxassetid://10709789810",
	["lucide-carrot"] = "rbxassetid://10709789960",
	["lucide-cast"] = "rbxassetid://10709790097",
	["lucide-charge"] = "rbxassetid://10709790202",
	["lucide-check"] = "rbxassetid://10709790644",
	["lucide-check-circle"] = "rbxassetid://10709790387",
	["lucide-check-circle-2"] = "rbxassetid://10709790298",
	["lucide-check-square"] = "rbxassetid://10709790537",
	["lucide-chef-hat"] = "rbxassetid://10709790757",
	["lucide-cherry"] = "rbxassetid://10709790875",
	["lucide-chevron-down"] = "rbxassetid://10709790948",
	["lucide-chevron-first"] = "rbxassetid://10709791015",
	["lucide-chevron-last"] = "rbxassetid://10709791130",
	["lucide-chevron-left"] = "rbxassetid://10709791281",
	["lucide-chevron-right"] = "rbxassetid://10709791437",
	["lucide-chevron-up"] = "rbxassetid://10709791523",
	["lucide-chevrons-down"] = "rbxassetid://10709796864",
	["lucide-chevrons-down-up"] = "rbxassetid://10709791632",
	["lucide-chevrons-left"] = "rbxassetid://10709797151",
	["lucide-chevrons-left-right"] = "rbxassetid://10709797006",
	["lucide-chevrons-right"] = "rbxassetid://10709797382",
	["lucide-chevrons-right-left"] = "rbxassetid://10709797274",
	["lucide-chevrons-up"] = "rbxassetid://10709797622",
	["lucide-chevrons-up-down"] = "rbxassetid://10709797508",
	["lucide-chrome"] = "rbxassetid://10709797725",
	["lucide-circle"] = "rbxassetid://10709798174",
	["lucide-circle-dot"] = "rbxassetid://10709797837",
	["lucide-circle-ellipsis"] = "rbxassetid://10709797985",
	["lucide-circle-slashed"] = "rbxassetid://10709798100",
	["lucide-citrus"] = "rbxassetid://10709798276",
	["lucide-clapperboard"] = "rbxassetid://10709798350",
	["lucide-clipboard"] = "rbxassetid://10709799288",
	["lucide-clipboard-check"] = "rbxassetid://10709798443",
	["lucide-clipboard-copy"] = "rbxassetid://10709798574",
	["lucide-clipboard-edit"] = "rbxassetid://10709798682",
	["lucide-clipboard-list"] = "rbxassetid://10709798792",
	["lucide-clipboard-signature"] = "rbxassetid://10709798890",
	["lucide-clipboard-type"] = "rbxassetid://10709798999",
	["lucide-clipboard-x"] = "rbxassetid://10709799124",
	["lucide-clock"] = "rbxassetid://10709805144",
	["lucide-clock-1"] = "rbxassetid://10709799535",
	["lucide-clock-10"] = "rbxassetid://10709799718",
	["lucide-clock-11"] = "rbxassetid://10709799818",
	["lucide-clock-12"] = "rbxassetid://10709799962",
	["lucide-clock-2"] = "rbxassetid://10709803876",
	["lucide-clock-3"] = "rbxassetid://10709803989",
	["lucide-clock-4"] = "rbxassetid://10709804164",
	["lucide-clock-5"] = "rbxassetid://10709804291",
	["lucide-clock-6"] = "rbxassetid://10709804435",
	["lucide-clock-7"] = "rbxassetid://10709804599",
	["lucide-clock-8"] = "rbxassetid://10709804784",
	["lucide-clock-9"] = "rbxassetid://10709804996",
	["lucide-cloud"] = "rbxassetid://10709806740",
	["lucide-cloud-cog"] = "rbxassetid://10709805262",
	["lucide-cloud-drizzle"] = "rbxassetid://10709805371",
	["lucide-cloud-fog"] = "rbxassetid://10709805477",
	["lucide-cloud-hail"] = "rbxassetid://10709805596",
	["lucide-cloud-lightning"] = "rbxassetid://10709805727",
	["lucide-cloud-moon"] = "rbxassetid://10709805942",
	["lucide-cloud-moon-rain"] = "rbxassetid://10709805838",
	["lucide-cloud-off"] = "rbxassetid://10709806060",
	["lucide-cloud-rain"] = "rbxassetid://10709806277",
	["lucide-cloud-rain-wind"] = "rbxassetid://10709806166",
	["lucide-cloud-snow"] = "rbxassetid://10709806374",
	["lucide-cloud-sun"] = "rbxassetid://10709806631",
	["lucide-cloud-sun-rain"] = "rbxassetid://10709806475",
	["lucide-cloudy"] = "rbxassetid://10709806859",
	["lucide-clover"] = "rbxassetid://10709806995",
	["lucide-code"] = "rbxassetid://10709810463",
	["lucide-code-2"] = "rbxassetid://10709807111",
	["lucide-codepen"] = "rbxassetid://10709810534",
	["lucide-codesandbox"] = "rbxassetid://10709810676",
	["lucide-coffee"] = "rbxassetid://10709810814",
	["lucide-cog"] = "rbxassetid://10709810948",
	["lucide-coins"] = "rbxassetid://10709811110",
	["lucide-columns"] = "rbxassetid://10709811261",
	["lucide-command"] = "rbxassetid://10709811365",
	["lucide-compass"] = "rbxassetid://10709811445",
	["lucide-component"] = "rbxassetid://10709811595",
	["lucide-concierge-bell"] = "rbxassetid://10709811706",
	["lucide-connection"] = "rbxassetid://10747361219",
	["lucide-contact"] = "rbxassetid://10709811834",
	["lucide-contrast"] = "rbxassetid://10709811939",
	["lucide-cookie"] = "rbxassetid://10709812067",
	["lucide-copy"] = "rbxassetid://10709812159",
	["lucide-copyleft"] = "rbxassetid://10709812251",
	["lucide-copyright"] = "rbxassetid://10709812311",
	["lucide-corner-down-left"] = "rbxassetid://10709812396",
	["lucide-corner-down-right"] = "rbxassetid://10709812485",
	["lucide-corner-left-down"] = "rbxassetid://10709812632",
	["lucide-corner-left-up"] = "rbxassetid://10709812784",
	["lucide-corner-right-down"] = "rbxassetid://10709812939",
	["lucide-corner-right-up"] = "rbxassetid://10709813094",
	["lucide-corner-up-left"] = "rbxassetid://10709813185",
	["lucide-corner-up-right"] = "rbxassetid://10709813281",
	["lucide-cpu"] = "rbxassetid://10709813383",
	["lucide-croissant"] = "rbxassetid://10709818125",
	["lucide-crop"] = "rbxassetid://10709818245",
	["lucide-cross"] = "rbxassetid://10709818399",
	["lucide-crosshair"] = "rbxassetid://10709818534",
	["lucide-crown"] = "rbxassetid://10709818626",
	["lucide-cup-soda"] = "rbxassetid://10709818763",
	["lucide-curly-braces"] = "rbxassetid://10709818847",
	["lucide-currency"] = "rbxassetid://10709818931",
	["lucide-container"] = "rbxassetid://17466205552",
	["lucide-database"] = "rbxassetid://10709818996",
	["lucide-delete"] = "rbxassetid://10709819059",
	["lucide-diamond"] = "rbxassetid://10709819149",
	["lucide-dice-1"] = "rbxassetid://10709819266",
	["lucide-dice-2"] = "rbxassetid://10709819361",
	["lucide-dice-3"] = "rbxassetid://10709819508",
	["lucide-dice-4"] = "rbxassetid://10709819670",
	["lucide-dice-5"] = "rbxassetid://10709819801",
	["lucide-dice-6"] = "rbxassetid://10709819896",
	["lucide-dices"] = "rbxassetid://10723343321",
	["lucide-diff"] = "rbxassetid://10723343416",
	["lucide-disc"] = "rbxassetid://10723343537",
	["lucide-divide"] = "rbxassetid://10723343805",
	["lucide-divide-circle"] = "rbxassetid://10723343636",
	["lucide-divide-square"] = "rbxassetid://10723343737",
	["lucide-dollar-sign"] = "rbxassetid://10723343958",
	["lucide-download"] = "rbxassetid://10723344270",
	["lucide-download-cloud"] = "rbxassetid://10723344088",
	["lucide-door-open"] = "rbxassetid://124179241653522",
	["lucide-droplet"] = "rbxassetid://10723344432",
	["lucide-droplets"] = "rbxassetid://10734883356",
	["lucide-drumstick"] = "rbxassetid://10723344737",
	["lucide-edit"] = "rbxassetid://10734883598",
	["lucide-edit-2"] = "rbxassetid://10723344885",
	["lucide-edit-3"] = "rbxassetid://10723345088",
	["lucide-egg"] = "rbxassetid://10723345518",
	["lucide-egg-fried"] = "rbxassetid://10723345347",
	["lucide-electricity"] = "rbxassetid://10723345749",
	["lucide-electricity-off"] = "rbxassetid://10723345643",
	["lucide-equal"] = "rbxassetid://10723345990",
	["lucide-equal-not"] = "rbxassetid://10723345866",
	["lucide-eraser"] = "rbxassetid://10723346158",
	["lucide-euro"] = "rbxassetid://10723346372",
	["lucide-expand"] = "rbxassetid://10723346553",
	["lucide-external-link"] = "rbxassetid://10723346684",
	["lucide-eye"] = "rbxassetid://10723346959",
	["lucide-eye-off"] = "rbxassetid://10723346871",
	["lucide-factory"] = "rbxassetid://10723347051",
	["lucide-fan"] = "rbxassetid://10723354359",
	["lucide-fast-forward"] = "rbxassetid://10723354521",
	["lucide-feather"] = "rbxassetid://10723354671",
	["lucide-figma"] = "rbxassetid://10723354801",
	["lucide-file"] = "rbxassetid://10723374641",
	["lucide-file-archive"] = "rbxassetid://10723354921",
	["lucide-file-audio"] = "rbxassetid://10723355148",
	["lucide-file-audio-2"] = "rbxassetid://10723355026",
	["lucide-file-axis-3d"] = "rbxassetid://10723355272",
	["lucide-file-badge"] = "rbxassetid://10723355622",
	["lucide-file-badge-2"] = "rbxassetid://10723355451",
	["lucide-file-bar-chart"] = "rbxassetid://10723355887",
	["lucide-file-bar-chart-2"] = "rbxassetid://10723355746",
	["lucide-file-box"] = "rbxassetid://10723355989",
	["lucide-file-check"] = "rbxassetid://10723356210",
	["lucide-file-check-2"] = "rbxassetid://10723356100",
	["lucide-file-clock"] = "rbxassetid://10723356329",
	["lucide-file-code"] = "rbxassetid://10723356507",
	["lucide-file-cog"] = "rbxassetid://10723356830",
	["lucide-file-cog-2"] = "rbxassetid://10723356676",
	["lucide-file-diff"] = "rbxassetid://10723357039",
	["lucide-file-digit"] = "rbxassetid://10723357151",
	["lucide-file-down"] = "rbxassetid://10723357322",
	["lucide-file-edit"] = "rbxassetid://10723357495",
	["lucide-file-heart"] = "rbxassetid://10723357637",
	["lucide-file-image"] = "rbxassetid://10723357790",
	["lucide-file-input"] = "rbxassetid://10723357933",
	["lucide-file-json"] = "rbxassetid://10723364435",
	["lucide-file-json-2"] = "rbxassetid://10723364361",
	["lucide-file-key"] = "rbxassetid://10723364605",
	["lucide-file-key-2"] = "rbxassetid://10723364515",
	["lucide-file-line-chart"] = "rbxassetid://10723364725",
	["lucide-file-lock"] = "rbxassetid://10723364957",
	["lucide-file-lock-2"] = "rbxassetid://10723364861",
	["lucide-file-minus"] = "rbxassetid://10723365254",
	["lucide-file-minus-2"] = "rbxassetid://10723365086",
	["lucide-file-output"] = "rbxassetid://10723365457",
	["lucide-file-pie-chart"] = "rbxassetid://10723365598",
	["lucide-file-plus"] = "rbxassetid://10723365877",
	["lucide-file-plus-2"] = "rbxassetid://10723365766",
	["lucide-file-question"] = "rbxassetid://10723365987",
	["lucide-file-scan"] = "rbxassetid://10723366167",
	["lucide-file-search"] = "rbxassetid://10723366550",
	["lucide-file-search-2"] = "rbxassetid://10723366340",
	["lucide-file-signature"] = "rbxassetid://10723366741",
	["lucide-file-spreadsheet"] = "rbxassetid://10723366962",
	["lucide-file-symlink"] = "rbxassetid://10723367098",
	["lucide-file-terminal"] = "rbxassetid://10723367244",
	["lucide-file-text"] = "rbxassetid://10723367380",
	["lucide-file-type"] = "rbxassetid://10723367606",
	["lucide-file-type-2"] = "rbxassetid://10723367509",
	["lucide-file-up"] = "rbxassetid://10723367734",
	["lucide-file-video"] = "rbxassetid://10723373884",
	["lucide-file-video-2"] = "rbxassetid://10723367834",
	["lucide-file-volume"] = "rbxassetid://10723374172",
	["lucide-file-volume-2"] = "rbxassetid://10723374030",
	["lucide-file-warning"] = "rbxassetid://10723374276",
	["lucide-file-x"] = "rbxassetid://10723374544",
	["lucide-file-x-2"] = "rbxassetid://10723374378",
	["lucide-files"] = "rbxassetid://10723374759",
	["lucide-film"] = "rbxassetid://10723374981",
	["lucide-filter"] = "rbxassetid://10723375128",
	["lucide-fingerprint"] = "rbxassetid://10723375250",
	["lucide-flag"] = "rbxassetid://10723375890",
	["lucide-flag-off"] = "rbxassetid://10723375443",
	["lucide-flag-triangle-left"] = "rbxassetid://10723375608",
	["lucide-flag-triangle-right"] = "rbxassetid://10723375727",
	["lucide-flame"] = "rbxassetid://10723376114",
	["lucide-flashlight"] = "rbxassetid://10723376471",
	["lucide-flashlight-off"] = "rbxassetid://10723376365",
	["lucide-flask-conical"] = "rbxassetid://10734883986",
	["lucide-flask-round"] = "rbxassetid://10723376614",
	["lucide-flip-horizontal"] = "rbxassetid://10723376884",
	["lucide-flip-horizontal-2"] = "rbxassetid://10723376745",
	["lucide-flip-vertical"] = "rbxassetid://10723377138",
	["lucide-flip-vertical-2"] = "rbxassetid://10723377026",
	["lucide-flower"] = "rbxassetid://10747830374",
	["lucide-flower-2"] = "rbxassetid://10723377305",
	["lucide-focus"] = "rbxassetid://10723377537",
	["lucide-folder"] = "rbxassetid://10723387563",
	["lucide-folder-archive"] = "rbxassetid://10723384478",
	["lucide-folder-check"] = "rbxassetid://10723384605",
	["lucide-folder-clock"] = "rbxassetid://10723384731",
	["lucide-folder-closed"] = "rbxassetid://10723384893",
	["lucide-folder-cog"] = "rbxassetid://10723385213",
	["lucide-folder-cog-2"] = "rbxassetid://10723385036",
	["lucide-folder-down"] = "rbxassetid://10723385338",
	["lucide-folder-edit"] = "rbxassetid://10723385445",
	["lucide-folder-heart"] = "rbxassetid://10723385545",
	["lucide-folder-input"] = "rbxassetid://10723385721",
	["lucide-folder-key"] = "rbxassetid://10723385848",
	["lucide-folder-lock"] = "rbxassetid://10723386005",
	["lucide-folder-minus"] = "rbxassetid://10723386127",
	["lucide-folder-open"] = "rbxassetid://10723386277",
	["lucide-folder-output"] = "rbxassetid://10723386386",
	["lucide-folder-plus"] = "rbxassetid://10723386531",
	["lucide-folder-search"] = "rbxassetid://10723386787",
	["lucide-folder-search-2"] = "rbxassetid://10723386674",
	["lucide-folder-symlink"] = "rbxassetid://10723386930",
	["lucide-folder-tree"] = "rbxassetid://10723387085",
	["lucide-folder-up"] = "rbxassetid://10723387265",
	["lucide-folder-x"] = "rbxassetid://10723387448",
	["lucide-folders"] = "rbxassetid://10723387721",
	["lucide-form-input"] = "rbxassetid://10723387841",
	["lucide-forward"] = "rbxassetid://10723388016",
	["lucide-frame"] = "rbxassetid://10723394389",
	["lucide-framer"] = "rbxassetid://10723394565",
	["lucide-frown"] = "rbxassetid://10723394681",
	["lucide-fuel"] = "rbxassetid://10723394846",
	["lucide-function-square"] = "rbxassetid://10723395041",
	["lucide-gamepad"] = "rbxassetid://10723395457",
	["lucide-gamepad-2"] = "rbxassetid://10723395215",
	["lucide-gauge"] = "rbxassetid://10723395708",
	["lucide-gavel"] = "rbxassetid://10723395896",
	["lucide-gem"] = "rbxassetid://10723396000",
	["lucide-ghost"] = "rbxassetid://10723396107",
	["lucide-gift"] = "rbxassetid://10723396402",
	["lucide-gift-card"] = "rbxassetid://10723396225",
	["lucide-git-branch"] = "rbxassetid://10723396676",
	["lucide-git-branch-plus"] = "rbxassetid://10723396542",
	["lucide-git-commit"] = "rbxassetid://10723396812",
	["lucide-git-compare"] = "rbxassetid://10723396954",
	["lucide-git-fork"] = "rbxassetid://10723397049",
	["lucide-git-merge"] = "rbxassetid://10723397165",
	["lucide-git-pull-request"] = "rbxassetid://10723397431",
	["lucide-git-pull-request-closed"] = "rbxassetid://10723397268",
	["lucide-git-pull-request-draft"] = "rbxassetid://10734884302",
	["lucide-glass"] = "rbxassetid://10723397788",
	["lucide-glass-2"] = "rbxassetid://10723397529",
	["lucide-glass-water"] = "rbxassetid://10723397678",
	["lucide-glasses"] = "rbxassetid://10723397895",
	["lucide-globe"] = "rbxassetid://10723404337",
	["lucide-globe-2"] = "rbxassetid://10723398002",
	["lucide-grab"] = "rbxassetid://10723404472",
	["lucide-graduation-cap"] = "rbxassetid://10723404691",
	["lucide-grape"] = "rbxassetid://10723404822",
	["lucide-grid"] = "rbxassetid://10723404936",
	["lucide-grip-horizontal"] = "rbxassetid://10723405089",
	["lucide-grip-vertical"] = "rbxassetid://10723405236",
	["lucide-hammer"] = "rbxassetid://10723405360",
	["lucide-hand"] = "rbxassetid://10723405649",
	["lucide-hand-metal"] = "rbxassetid://10723405508",
	["lucide-hard-drive"] = "rbxassetid://10723405749",
	["lucide-hard-hat"] = "rbxassetid://10723405859",
	["lucide-hash"] = "rbxassetid://10723405975",
	["lucide-haze"] = "rbxassetid://10723406078",
	["lucide-headphones"] = "rbxassetid://10723406165",
	["lucide-heart"] = "rbxassetid://10723406885",
	["lucide-heart-crack"] = "rbxassetid://10723406299",
	["lucide-heart-handshake"] = "rbxassetid://10723406480",
	["lucide-heart-off"] = "rbxassetid://10723406662",
	["lucide-heart-pulse"] = "rbxassetid://10723406795",
	["lucide-help-circle"] = "rbxassetid://10723406988",
	["lucide-hexagon"] = "rbxassetid://10723407092",
	["lucide-highlighter"] = "rbxassetid://10723407192",
	["lucide-history"] = "rbxassetid://10723407335",
	["lucide-home"] = "rbxassetid://10723407389",
	["lucide-hourglass"] = "rbxassetid://10723407498",
	["lucide-ice-cream"] = "rbxassetid://10723414308",
	["lucide-image"] = "rbxassetid://10723415040",
	["lucide-image-minus"] = "rbxassetid://10723414487",
	["lucide-image-off"] = "rbxassetid://10723414677",
	["lucide-image-plus"] = "rbxassetid://10723414827",
	["lucide-import"] = "rbxassetid://10723415205",
	["lucide-inbox"] = "rbxassetid://10723415335",
	["lucide-indent"] = "rbxassetid://10723415494",
	["lucide-indian-rupee"] = "rbxassetid://10723415642",
	["lucide-infinity"] = "rbxassetid://10723415766",
	["lucide-info"] = "rbxassetid://10723415903",
	["lucide-inspect"] = "rbxassetid://10723416057",
	["lucide-italic"] = "rbxassetid://10723416195",
	["lucide-japanese-yen"] = "rbxassetid://10723416363",
	["lucide-joystick"] = "rbxassetid://10723416527",
	["lucide-key"] = "rbxassetid://10723416652",
	["lucide-keyboard"] = "rbxassetid://10723416765",
	["lucide-lamp"] = "rbxassetid://10723417513",
	["lucide-lamp-ceiling"] = "rbxassetid://10723416922",
	["lucide-lamp-desk"] = "rbxassetid://10723417016",
	["lucide-lamp-floor"] = "rbxassetid://10723417131",
	["lucide-lamp-wall-down"] = "rbxassetid://10723417240",
	["lucide-lamp-wall-up"] = "rbxassetid://10723417356",
	["lucide-landmark"] = "rbxassetid://10723417608",
	["lucide-languages"] = "rbxassetid://10723417703",
	["lucide-laptop"] = "rbxassetid://10723423881",
	["lucide-laptop-2"] = "rbxassetid://10723417797",
	["lucide-lasso"] = "rbxassetid://10723424235",
	["lucide-lasso-select"] = "rbxassetid://10723424058",
	["lucide-laugh"] = "rbxassetid://10723424372",
	["lucide-layers"] = "rbxassetid://10723424505",
	["lucide-layout"] = "rbxassetid://10723425376",
	["lucide-layout-dashboard"] = "rbxassetid://10723424646",
	["lucide-layout-grid"] = "rbxassetid://10723424838",
	["lucide-layout-list"] = "rbxassetid://10723424963",
	["lucide-layout-template"] = "rbxassetid://10723425187",
	["lucide-leaf"] = "rbxassetid://10723425539",
	["lucide-library"] = "rbxassetid://10723425615",
	["lucide-life-buoy"] = "rbxassetid://10723425685",
	["lucide-lightbulb"] = "rbxassetid://10723425852",
	["lucide-lightbulb-off"] = "rbxassetid://10723425762",
	["lucide-line-chart"] = "rbxassetid://10723426393",
	["lucide-link"] = "rbxassetid://10723426722",
	["lucide-link-2"] = "rbxassetid://10723426595",
	["lucide-link-2-off"] = "rbxassetid://10723426513",
	["lucide-list"] = "rbxassetid://10723433811",
	["lucide-list-checks"] = "rbxassetid://10734884548",
	["lucide-list-end"] = "rbxassetid://10723426886",
	["lucide-list-minus"] = "rbxassetid://10723426986",
	["lucide-list-music"] = "rbxassetid://10723427081",
	["lucide-list-ordered"] = "rbxassetid://10723427199",
	["lucide-list-plus"] = "rbxassetid://10723427334",
	["lucide-list-start"] = "rbxassetid://10723427494",
	["lucide-list-video"] = "rbxassetid://10723427619",
	["lucide-list-todo"] = "rbxassetid://17376008003",
	["lucide-list-x"] = "rbxassetid://10723433655",
	["lucide-loader"] = "rbxassetid://10723434070",
	["lucide-loader-2"] = "rbxassetid://10723433935",
	["lucide-locate"] = "rbxassetid://10723434557",
	["lucide-locate-fixed"] = "rbxassetid://10723434236",
	["lucide-locate-off"] = "rbxassetid://10723434379",
	["lucide-lock"] = "rbxassetid://10723434711",
	["lucide-log-in"] = "rbxassetid://10723434830",
	["lucide-log-out"] = "rbxassetid://10723434906",
	["lucide-luggage"] = "rbxassetid://10723434993",
	["lucide-magnet"] = "rbxassetid://10723435069",
	["lucide-mail"] = "rbxassetid://10734885430",
	["lucide-mail-check"] = "rbxassetid://10723435182",
	["lucide-mail-minus"] = "rbxassetid://10723435261",
	["lucide-mail-open"] = "rbxassetid://10723435342",
	["lucide-mail-plus"] = "rbxassetid://10723435443",
	["lucide-mail-question"] = "rbxassetid://10723435515",
	["lucide-mail-search"] = "rbxassetid://10734884739",
	["lucide-mail-warning"] = "rbxassetid://10734885015",
	["lucide-mail-x"] = "rbxassetid://10734885247",
	["lucide-mails"] = "rbxassetid://10734885614",
	["lucide-map"] = "rbxassetid://10734886202",
	["lucide-map-pin"] = "rbxassetid://10734886004",
	["lucide-map-pin-off"] = "rbxassetid://10734885803",
	["lucide-maximize"] = "rbxassetid://10734886735",
	["lucide-maximize-2"] = "rbxassetid://10734886496",
	["lucide-medal"] = "rbxassetid://10734887072",
	["lucide-megaphone"] = "rbxassetid://10734887454",
	["lucide-megaphone-off"] = "rbxassetid://10734887311",
	["lucide-meh"] = "rbxassetid://10734887603",
	["lucide-menu"] = "rbxassetid://10734887784",
	["lucide-message-circle"] = "rbxassetid://10734888000",
	["lucide-message-square"] = "rbxassetid://10734888228",
	["lucide-mic"] = "rbxassetid://10734888864",
	["lucide-mic-2"] = "rbxassetid://10734888430",
	["lucide-mic-off"] = "rbxassetid://10734888646",
	["lucide-microscope"] = "rbxassetid://10734889106",
	["lucide-microwave"] = "rbxassetid://10734895076",
	["lucide-milestone"] = "rbxassetid://10734895310",
	["lucide-minimize"] = "rbxassetid://10734895698",
	["lucide-minimize-2"] = "rbxassetid://10734895530",
	["lucide-minus"] = "rbxassetid://10734896206",
	["lucide-minus-circle"] = "rbxassetid://10734895856",
	["lucide-minus-square"] = "rbxassetid://10734896029",
	["lucide-monitor"] = "rbxassetid://10734896881",
	["lucide-monitor-off"] = "rbxassetid://10734896360",
	["lucide-monitor-speaker"] = "rbxassetid://10734896512",
	["lucide-moon"] = "rbxassetid://10734897102",
	["lucide-more-horizontal"] = "rbxassetid://10734897250",
	["lucide-more-vertical"] = "rbxassetid://10734897387",
	["lucide-mountain"] = "rbxassetid://10734897956",
	["lucide-mountain-snow"] = "rbxassetid://10734897665",
	["lucide-mouse"] = "rbxassetid://10734898592",
	["lucide-mouse-pointer"] = "rbxassetid://10734898476",
	["lucide-mouse-pointer-2"] = "rbxassetid://10734898194",
	["lucide-mouse-pointer-click"] = "rbxassetid://10734898355",
	["lucide-move"] = "rbxassetid://10734900011",
	["lucide-move-3d"] = "rbxassetid://10734898756",
	["lucide-move-diagonal"] = "rbxassetid://10734899164",
	["lucide-move-diagonal-2"] = "rbxassetid://10734898934",
	["lucide-move-horizontal"] = "rbxassetid://10734899414",
	["lucide-move-vertical"] = "rbxassetid://10734899821",
	["lucide-music"] = "rbxassetid://10734905958",
	["lucide-music-2"] = "rbxassetid://10734900215",
	["lucide-music-3"] = "rbxassetid://10734905665",
	["lucide-music-4"] = "rbxassetid://10734905823",
	["lucide-navigation"] = "rbxassetid://10734906744",
	["lucide-navigation-2"] = "rbxassetid://10734906332",
	["lucide-navigation-2-off"] = "rbxassetid://10734906144",
	["lucide-navigation-off"] = "rbxassetid://10734906580",
	["lucide-network"] = "rbxassetid://10734906975",
	["lucide-newspaper"] = "rbxassetid://10734907168",
	["lucide-octagon"] = "rbxassetid://10734907361",
	["lucide-option"] = "rbxassetid://10734907649",
	["lucide-outdent"] = "rbxassetid://10734907933",
	["lucide-package"] = "rbxassetid://10734909540",
	["lucide-package-2"] = "rbxassetid://10734908151",
	["lucide-package-check"] = "rbxassetid://10734908384",
	["lucide-package-minus"] = "rbxassetid://10734908626",
	["lucide-package-open"] = "rbxassetid://10734908793",
	["lucide-package-plus"] = "rbxassetid://10734909016",
	["lucide-package-search"] = "rbxassetid://10734909196",
	["lucide-package-x"] = "rbxassetid://10734909375",
	["lucide-paint-bucket"] = "rbxassetid://10734909847",
	["lucide-paintbrush"] = "rbxassetid://10734910187",
	["lucide-paintbrush-2"] = "rbxassetid://10734910030",
	["lucide-palette"] = "rbxassetid://10734910430",
	["lucide-palmtree"] = "rbxassetid://10734910680",
	["lucide-paperclip"] = "rbxassetid://10734910927",
	["lucide-party-popper"] = "rbxassetid://10734918735",
	["lucide-pause"] = "rbxassetid://10734919336",
	["lucide-pause-circle"] = "rbxassetid://10735024209",
	["lucide-pause-octagon"] = "rbxassetid://10734919143",
	["lucide-pen-tool"] = "rbxassetid://10734919503",
	["lucide-pencil"] = "rbxassetid://10734919691",
	["lucide-percent"] = "rbxassetid://10734919919",
	["lucide-person-standing"] = "rbxassetid://10734920149",
	["lucide-phone"] = "rbxassetid://10734921524",
	["lucide-phone-call"] = "rbxassetid://10734920305",
	["lucide-phone-forwarded"] = "rbxassetid://10734920508",
	["lucide-phone-incoming"] = "rbxassetid://10734920694",
	["lucide-phone-missed"] = "rbxassetid://10734920845",
	["lucide-phone-off"] = "rbxassetid://10734921077",
	["lucide-phone-outgoing"] = "rbxassetid://10734921288",
	["lucide-pie-chart"] = "rbxassetid://10734921727",
	["lucide-piggy-bank"] = "rbxassetid://10734921935",
	["lucide-pin"] = "rbxassetid://10734922324",
	["lucide-pin-off"] = "rbxassetid://10734922180",
	["lucide-pipette"] = "rbxassetid://10734922497",
	["lucide-pizza"] = "rbxassetid://10734922774",
	["lucide-plane"] = "rbxassetid://10734922971",
	["lucide-plane-landing"] = "rbxassetid://17376029914",
	["lucide-play"] = "rbxassetid://10734923549",
	["lucide-play-circle"] = "rbxassetid://10734923214",
	["lucide-plus"] = "rbxassetid://10734924532",
	["lucide-plus-circle"] = "rbxassetid://10734923868",
	["lucide-plus-square"] = "rbxassetid://10734924219",
	["lucide-podcast"] = "rbxassetid://10734929553",
	["lucide-pointer"] = "rbxassetid://10734929723",
	["lucide-pound-sterling"] = "rbxassetid://10734929981",
	["lucide-power"] = "rbxassetid://10734930466",
	["lucide-power-off"] = "rbxassetid://10734930257",
	["lucide-printer"] = "rbxassetid://10734930632",
	["lucide-puzzle"] = "rbxassetid://10734930886",
	["lucide-quote"] = "rbxassetid://10734931234",
	["lucide-radio"] = "rbxassetid://10734931596",
	["lucide-radio-receiver"] = "rbxassetid://10734931402",
	["lucide-rectangle-horizontal"] = "rbxassetid://10734931777",
	["lucide-rectangle-vertical"] = "rbxassetid://10734932081",
	["lucide-recycle"] = "rbxassetid://10734932295",
	["lucide-redo"] = "rbxassetid://10734932822",
	["lucide-redo-2"] = "rbxassetid://10734932586",
	["lucide-refresh-ccw"] = "rbxassetid://10734933056",
	["lucide-refresh-cw"] = "rbxassetid://10734933222",
	["lucide-refrigerator"] = "rbxassetid://10734933465",
	["lucide-regex"] = "rbxassetid://10734933655",
	["lucide-repeat"] = "rbxassetid://10734933966",
	["lucide-repeat-1"] = "rbxassetid://10734933826",
	["lucide-reply"] = "rbxassetid://10734934252",
	["lucide-reply-all"] = "rbxassetid://10734934132",
	["lucide-rewind"] = "rbxassetid://10734934347",
	["lucide-rocket"] = "rbxassetid://10734934585",
	["lucide-rocking-chair"] = "rbxassetid://10734939942",
	["lucide-rotate-3d"] = "rbxassetid://10734940107",
	["lucide-rotate-ccw"] = "rbxassetid://10734940376",
	["lucide-rotate-cw"] = "rbxassetid://10734940654",
	["lucide-rss"] = "rbxassetid://10734940825",
	["lucide-ruler"] = "rbxassetid://10734941018",
	["lucide-russian-ruble"] = "rbxassetid://10734941199",
	["lucide-sailboat"] = "rbxassetid://10734941354",
	["lucide-save"] = "rbxassetid://10734941499",
	["lucide-scale"] = "rbxassetid://10734941912",
	["lucide-scale-3d"] = "rbxassetid://10734941739",
	["lucide-scaling"] = "rbxassetid://10734942072",
	["lucide-scan"] = "rbxassetid://10734942565",
	["lucide-scan-face"] = "rbxassetid://10734942198",
	["lucide-scan-line"] = "rbxassetid://10734942351",
	["lucide-scissors"] = "rbxassetid://10734942778",
	["lucide-screen-share"] = "rbxassetid://10734943193",
	["lucide-screen-share-off"] = "rbxassetid://10734942967",
	["lucide-scroll"] = "rbxassetid://10734943448",
	["lucide-search"] = "rbxassetid://10734943674",
	["lucide-send"] = "rbxassetid://10734943902",
	["lucide-separator-horizontal"] = "rbxassetid://10734944115",
	["lucide-separator-vertical"] = "rbxassetid://10734944326",
	["lucide-server"] = "rbxassetid://10734949856",
	["lucide-server-cog"] = "rbxassetid://10734944444",
	["lucide-server-crash"] = "rbxassetid://10734944554",
	["lucide-server-off"] = "rbxassetid://10734944668",
	["lucide-settings"] = "rbxassetid://10734950309",
	["lucide-settings-2"] = "rbxassetid://10734950020",
	["lucide-share"] = "rbxassetid://10734950813",
	["lucide-share-2"] = "rbxassetid://10734950553",
	["lucide-sheet"] = "rbxassetid://10734951038",
	["lucide-shield"] = "rbxassetid://10734951847",
	["lucide-shield-alert"] = "rbxassetid://10734951173",
	["lucide-shield-check"] = "rbxassetid://10734951367",
	["lucide-shield-close"] = "rbxassetid://10734951535",
	["lucide-shield-off"] = "rbxassetid://10734951684",
	["lucide-shirt"] = "rbxassetid://10734952036",
	["lucide-shopping-bag"] = "rbxassetid://10734952273",
	["lucide-shopping-cart"] = "rbxassetid://10734952479",
	["lucide-shovel"] = "rbxassetid://10734952773",
	["lucide-shower-head"] = "rbxassetid://10734952942",
	["lucide-shrink"] = "rbxassetid://10734953073",
	["lucide-shrub"] = "rbxassetid://10734953241",
	["lucide-shuffle"] = "rbxassetid://10734953451",
	["lucide-sidebar"] = "rbxassetid://10734954301",
	["lucide-sidebar-close"] = "rbxassetid://10734953715",
	["lucide-sidebar-open"] = "rbxassetid://10734954000",
	["lucide-sigma"] = "rbxassetid://10734954538",
	["lucide-signal"] = "rbxassetid://10734961133",
	["lucide-signal-high"] = "rbxassetid://10734954807",
	["lucide-signal-low"] = "rbxassetid://10734955080",
	["lucide-signal-medium"] = "rbxassetid://10734955336",
	["lucide-signal-zero"] = "rbxassetid://10734960878",
	["lucide-siren"] = "rbxassetid://10734961284",
	["lucide-skip-back"] = "rbxassetid://10734961526",
	["lucide-skip-forward"] = "rbxassetid://10734961809",
	["lucide-skull"] = "rbxassetid://10734962068",
	["lucide-slack"] = "rbxassetid://10734962339",
	["lucide-slash"] = "rbxassetid://10734962600",
	["lucide-slice"] = "rbxassetid://10734963024",
	["lucide-sliders"] = "rbxassetid://10734963400",
	["lucide-sliders-horizontal"] = "rbxassetid://10734963191",
	["lucide-smartphone"] = "rbxassetid://10734963940",
	["lucide-smartphone-charging"] = "rbxassetid://10734963671",
	["lucide-smile"] = "rbxassetid://10734964441",
	["lucide-smile-plus"] = "rbxassetid://10734964188",
	["lucide-snowflake"] = "rbxassetid://10734964600",
	["lucide-sofa"] = "rbxassetid://10734964852",
	["lucide-sort-asc"] = "rbxassetid://10734965115",
	["lucide-sort-desc"] = "rbxassetid://10734965287",
	["lucide-speaker"] = "rbxassetid://10734965419",
	["lucide-sprout"] = "rbxassetid://10734965572",
	["lucide-square"] = "rbxassetid://10734965702",
	["lucide-star"] = "rbxassetid://10734966248",
	["lucide-star-half"] = "rbxassetid://10734965897",
	["lucide-star-off"] = "rbxassetid://10734966097",
	["lucide-stethoscope"] = "rbxassetid://10734966384",
	["lucide-sticker"] = "rbxassetid://10734972234",
	["lucide-sticky-note"] = "rbxassetid://10734972463",
	["lucide-stop-circle"] = "rbxassetid://10734972621",
	["lucide-stretch-horizontal"] = "rbxassetid://10734972862",
	["lucide-stretch-vertical"] = "rbxassetid://10734973130",
	["lucide-strikethrough"] = "rbxassetid://10734973290",
	["lucide-subscript"] = "rbxassetid://10734973457",
	["lucide-sun"] = "rbxassetid://10734974297",
	["lucide-sun-dim"] = "rbxassetid://10734973645",
	["lucide-sun-medium"] = "rbxassetid://10734973778",
	["lucide-sun-moon"] = "rbxassetid://10734973999",
	["lucide-sun-snow"] = "rbxassetid://10734974130",
	["lucide-sunrise"] = "rbxassetid://10734974522",
	["lucide-sunset"] = "rbxassetid://10734974689",
	["lucide-superscript"] = "rbxassetid://10734974850",
	["lucide-swiss-franc"] = "rbxassetid://10734975024",
	["lucide-switch-camera"] = "rbxassetid://10734975214",
	["lucide-sword"] = "rbxassetid://10734975486",
	["lucide-swords"] = "rbxassetid://10734975692",
	["lucide-syringe"] = "rbxassetid://10734975932",
	["lucide-table"] = "rbxassetid://10734976230",
	["lucide-table-2"] = "rbxassetid://10734976097",
	["lucide-tablet"] = "rbxassetid://10734976394",
	["lucide-tag"] = "rbxassetid://10734976528",
	["lucide-tags"] = "rbxassetid://10734976739",
	["lucide-target"] = "rbxassetid://10734977012",
	["lucide-tent"] = "rbxassetid://10734981750",
	["lucide-terminal"] = "rbxassetid://10734982144",
	["lucide-terminal-square"] = "rbxassetid://10734981995",
	["lucide-text-cursor"] = "rbxassetid://10734982395",
	["lucide-text-cursor-input"] = "rbxassetid://10734982297",
	["lucide-thermometer"] = "rbxassetid://10734983134",
	["lucide-thermometer-snowflake"] = "rbxassetid://10734982571",
	["lucide-thermometer-sun"] = "rbxassetid://10734982771",
	["lucide-thumbs-down"] = "rbxassetid://10734983359",
	["lucide-thumbs-up"] = "rbxassetid://10734983629",
	["lucide-ticket"] = "rbxassetid://10734983868",
	["lucide-timer"] = "rbxassetid://10734984606",
	["lucide-timer-off"] = "rbxassetid://10734984138",
	["lucide-timer-reset"] = "rbxassetid://10734984355",
	["lucide-toggle-left"] = "rbxassetid://10734984834",
	["lucide-toggle-right"] = "rbxassetid://10734985040",
	["lucide-tornado"] = "rbxassetid://10734985247",
	["lucide-toy-brick"] = "rbxassetid://10747361919",
	["lucide-train"] = "rbxassetid://10747362105",
	["lucide-trash"] = "rbxassetid://10747362393",
	["lucide-trash-2"] = "rbxassetid://10747362241",
	["lucide-tree-deciduous"] = "rbxassetid://10747362534",
	["lucide-tree-pine"] = "rbxassetid://10747362748",
	["lucide-trees"] = "rbxassetid://10747363016",
	["lucide-trending-down"] = "rbxassetid://10747363205",
	["lucide-trending-up"] = "rbxassetid://10747363465",
	["lucide-triangle"] = "rbxassetid://10747363621",
	["lucide-trophy"] = "rbxassetid://10747363809",
	["lucide-truck"] = "rbxassetid://10747364031",
	["lucide-tv"] = "rbxassetid://10747364593",
	["lucide-tv-2"] = "rbxassetid://10747364302",
	["lucide-type"] = "rbxassetid://10747364761",
	["lucide-umbrella"] = "rbxassetid://10747364971",
	["lucide-underline"] = "rbxassetid://10747365191",
	["lucide-undo"] = "rbxassetid://10747365484",
	["lucide-undo-2"] = "rbxassetid://10747365359",
	["lucide-unlink"] = "rbxassetid://10747365771",
	["lucide-unlink-2"] = "rbxassetid://10747397871",
	["lucide-unlock"] = "rbxassetid://10747366027",
	["lucide-upload"] = "rbxassetid://10747366434",
	["lucide-upload-cloud"] = "rbxassetid://10747366266",
	["lucide-usb"] = "rbxassetid://10747366606",
	["lucide-user"] = "rbxassetid://10747373176",
	["lucide-user-check"] = "rbxassetid://10747371901",
	["lucide-user-cog"] = "rbxassetid://10747372167",
	["lucide-user-minus"] = "rbxassetid://10747372346",
	["lucide-user-plus"] = "rbxassetid://10747372702",
	["lucide-user-x"] = "rbxassetid://10747372992",
	["lucide-users"] = "rbxassetid://10747373426",
	["lucide-utensils"] = "rbxassetid://10747373821",
	["lucide-utensils-crossed"] = "rbxassetid://10747373629",
	["lucide-venetian-mask"] = "rbxassetid://10747374003",
	["lucide-verified"] = "rbxassetid://10747374131",
	["lucide-vibrate"] = "rbxassetid://10747374489",
	["lucide-vibrate-off"] = "rbxassetid://10747374269",
	["lucide-video"] = "rbxassetid://10747374938",
	["lucide-video-off"] = "rbxassetid://10747374721",
	["lucide-view"] = "rbxassetid://10747375132",
	["lucide-voicemail"] = "rbxassetid://10747375281",
	["lucide-volume"] = "rbxassetid://10747376008",
	["lucide-volume-1"] = "rbxassetid://10747375450",
	["lucide-volume-2"] = "rbxassetid://10747375679",
	["lucide-volume-x"] = "rbxassetid://10747375880",
	["lucide-wheat"] = "rbxassetid://80877624162595",
	["lucide-wallet"] = "rbxassetid://10747376205",
	["lucide-wand"] = "rbxassetid://10747376565",
	["lucide-wand-2"] = "rbxassetid://10747376349",
	["lucide-watch"] = "rbxassetid://10747376722",
	["lucide-waves"] = "rbxassetid://10747376931",
	["lucide-webcam"] = "rbxassetid://10747381992",
	["lucide-wifi"] = "rbxassetid://10747382504",
	["lucide-wifi-off"] = "rbxassetid://10747382268",
	["lucide-wind"] = "rbxassetid://10747382750",
	["lucide-wrap-text"] = "rbxassetid://10747383065",
	["lucide-wrench"] = "rbxassetid://10747383470",
	["lucide-x"] = "rbxassetid://10747384394",
	["lucide-x-circle"] = "rbxassetid://10747383819",
	["lucide-x-octagon"] = "rbxassetid://10747384037",
	["lucide-x-square"] = "rbxassetid://10747384217",
	["lucide-zoom-in"] = "rbxassetid://10747384552",
	["lucide-zoom-out"] = "rbxassetid://10747384679",
	["lucide-cat"] = "rbxassetid://16935650691",
	["lucide-message-circle-question"] = "rbxassetid://16970049192",
	["lucide-webhook"] = "rbxassetid://17320556264",
	["lucide-dumbbell"] = "rbxassetid://18273453053"
}

function Wisper:CreateWindow(Config)
    Config = Config or {}
    Config.Name = Config.Name or "wisper"
    Config.GameName = Config.GameName or "Unknown Game"
    Config.Version = Config.Version or "1.0.0"
    Config.KeyBind = Config.KeyBind or Enum.KeyCode.RightControl

    local ScreenGui = Create("ScreenGui", {
        Name = ScreenGuiName,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        DisplayOrder = 10
    })
    
    -- Anti-detection: Use protected GUI methods if available
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    elseif gethui then
        ScreenGui.Parent = gethui()
    elseif KRNL_LOADED and getgenv().protect_gui then
        getgenv().protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui
    end

    -- Anti-detection: Store with random key instead of obvious name
    rawset(_G, InstanceKey, ScreenGui)

    local FRAME_WIDTH = 260

    -- Drop Shadow for MainFrame (separate frame in ScreenGui)
    local MainDropShadow = Create("ImageLabel", {
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
        Parent = Header,
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -10),
        Size = UDim2.new(1, 0, 0, 10),
        ZIndex = 6
    })

    -- Title Label in Header (accent color)
    local TitleLabel = Create("TextLabel", {
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
        Parent = Header,
        BackgroundColor3 = Theme.Line,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -1),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 7
    })

    -- Categories Container (between header and footer)
    local CategoriesContainer = Create("Frame", {
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
        Parent = Footer,
        BackgroundColor3 = Theme.Header,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 10),
        ZIndex = 6
    })

    -- Footer top line
    local FooterLine = Create("Frame", {
        Parent = Footer,
        BackgroundColor3 = Theme.Line,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 0, 1),
        ZIndex = 7
    })

    -- Footer placeholder text
    local FooterText = Create("TextLabel", {
        Parent = Footer,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 12, 0, 0),
        Size = UDim2.new(1, -24, 1, 0),
        Font = Enum.Font.Gotham,
        Text = Config.Version,
        TextColor3 = Theme.Text,
        TextTransparency = 0.5,
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

        -- Category Icon (left side) - supports icon name from Icons table or direct rbxassetid
        local iconImage = CategoryConfig.Icon
        if Icons[CategoryConfig.Icon] then
            iconImage = Icons[CategoryConfig.Icon]
        elseif Icons["lucide-" .. CategoryConfig.Icon] then
            iconImage = Icons["lucide-" .. CategoryConfig.Icon]
        end
        
        local CategoryIcon = Create("ImageLabel", {
            Parent = CategoryButton,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 12, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            Image = iconImage,
            ImageColor3 = Theme.Text,
            ImageTransparency = Theme.TextDim,
            ZIndex = 7
        })

        -- Category Label
        local CategoryLabel = Create("TextLabel", {
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

        -- Individual drag for this submenu
        MakeDraggable(SubMenuFrame)

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

        -- Category icon in header (uses same iconImage from above)
        local SubMenuIcon = Create("ImageLabel", {
            Parent = SubMenuHeader,
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0.5, -8),
            Size = UDim2.new(0, 16, 0, 16),
            Image = iconImage,
            ImageColor3 = Theme.Text,
            ZIndex = 7
        })

        -- Category name in header
        local SubMenuTitle = Create("TextLabel", {
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
                -- Collapse: hide modules immediately, rotate arrow 180
                Tween(SubMenuArrowButton, {Rotation = 180}, 0.2)
                ModulesContainer.Visible = false
            else
                -- Expand: show modules, rotate arrow back to 0
                Tween(SubMenuArrowButton, {Rotation = 0}, 0.2)
                ModulesContainer.Visible = true
            end
            -- Update shadow after state change
            task.defer(UpdateThisShadow)
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
                Parent = ModuleFrame,
                BackgroundColor3 = Enabled and Theme.Accent or Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(1, 0, 0, 28),
                LayoutOrder = 0,
                ClipsDescendants = true,
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
                Parent = ModuleHeader,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 10, 0, 0),
                Size = UDim2.new(1, -40, 1, 0),
                Font = Enum.Font.Gotham,
                Text = ModuleConfig.Name,
                TextColor3 = Theme.Text,
                TextTransparency = Enabled and 0 or Theme.TextDim,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 7
            })

            -- Keybind button (left of settings)
            local CurrentKeybind = nil
            local IsListeningForKeybind = false
            
            local KeybindButton = Create("TextButton", {
                Parent = ModuleHeader,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = Enabled and 0.8 or 0.95,
                Position = UDim2.new(1, -58, 0.5, -9),
                Size = UDim2.new(0, 26, 0, 18),
                Font = Enum.Font.Gotham,
                Text = "None",
                TextColor3 = Theme.Text,
                TextSize = 10,
                TextTransparency = 0.3,
                AutoButtonColor = false,
                Visible = false,
                ZIndex = 9
            })
            
            local KeybindCorner = Create("UICorner", {
                CornerRadius = UDim.new(0, 4),
                Parent = KeybindButton
            })

            -- Settings icon button on the right
            local SettingsButton = Create("ImageButton", {
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
                    Tween(KeybindButton, {BackgroundTransparency = 0.8}, 0.15)
                else
                    ModuleHeaderGradient.Enabled = true
                    Tween(ModuleHeader, {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.15)
                    Tween(ModuleLabel, {TextTransparency = Theme.TextDim}, 0.15)
                    Tween(SettingsButton, {ImageTransparency = 0.5}, 0.15)
                    Tween(KeybindButton, {BackgroundTransparency = 0.95}, 0.15)
                end
            end

            -- Function to toggle expand (simple, no delay)
            local function ToggleExpand()
                Expanded = not Expanded
                OptionsContainer.Visible = Expanded
            end
            
            -- Hover state tracking for keybind visibility
            local IsHoveringModule = false
            local IsHoveringKeybind = false
            local IsHoveringSettings = false
            
            -- Function to update keybind visibility
            local function UpdateKeybindVisibility()
                local isHovering = IsHoveringModule or IsHoveringKeybind or IsHoveringSettings
                if CurrentKeybind or IsListeningForKeybind then
                    KeybindButton.Visible = true
                else
                    KeybindButton.Visible = isHovering
                end
            end
            
            -- Keybind button click handler
            local JustSetKeybind = false
            
            KeybindButton.MouseButton1Click:Connect(function()
                if IsListeningForKeybind then return end
                IsListeningForKeybind = true
                KeybindButton.Text = "..."
                
                local connection
                connection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if input.UserInputType == Enum.UserInputType.Keyboard then
                        connection:Disconnect()
                        IsListeningForKeybind = false
                        
                        if input.KeyCode == Enum.KeyCode.Escape or input.KeyCode == Enum.KeyCode.Backspace then
                            CurrentKeybind = nil
                            KeybindButton.Text = "None"
                            UpdateKeybindVisibility()
                        else
                            CurrentKeybind = input.KeyCode
                            KeybindButton.Text = input.KeyCode.Name
                            KeybindButton.Visible = true
                            JustSetKeybind = true
                            task.delay(0.1, function()
                                JustSetKeybind = false
                            end)
                        end
                    end
                end)
            end)
            
            -- Global keybind listener for this module
            UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if IsListeningForKeybind then return end
                if JustSetKeybind then return end
                if CurrentKeybind and input.KeyCode == CurrentKeybind then
                    Enabled = not Enabled
                    UpdateModuleVisual()
                    ModuleConfig.Callback(Enabled)
                end
            end)

            -- Hover effect
            ModuleClickArea.MouseEnter:Connect(function()
                if not Enabled then
                    Tween(ModuleLabel, {TextTransparency = 0.3}, 0.1)
                end
                IsHoveringModule = true
                UpdateKeybindVisibility()
            end)

            ModuleClickArea.MouseLeave:Connect(function()
                if not Enabled then
                    Tween(ModuleLabel, {TextTransparency = Theme.TextDim}, 0.1)
                end
                IsHoveringModule = false
                task.delay(0.05, UpdateKeybindVisibility)
            end)
            
            -- Keybind button hover
            KeybindButton.MouseEnter:Connect(function()
                IsHoveringKeybind = true
                UpdateKeybindVisibility()
            end)
            
            KeybindButton.MouseLeave:Connect(function()
                IsHoveringKeybind = false
                task.delay(0.05, UpdateKeybindVisibility)
            end)

            -- Settings button hover
            SettingsButton.MouseEnter:Connect(function()
                Tween(SettingsButton, {ImageTransparency = 0.2}, 0.1)
                IsHoveringSettings = true
                UpdateKeybindVisibility()
            end)

            SettingsButton.MouseLeave:Connect(function()
                Tween(SettingsButton, {ImageTransparency = Enabled and 0.3 or 0.5}, 0.1)
                IsHoveringSettings = false
                task.delay(0.05, UpdateKeybindVisibility)
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
                    Parent = OptionsContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 24),
                    LayoutOrder = #ModuleAPI.Options + 1,
                    ZIndex = 6
                })

                local OptionLabel = Create("TextLabel", {
                    Parent = OptionFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(1, -45, 1, 0),
                    Font = Enum.Font.Gotham,
                    Text = ToggleConfig.Name,
                    TextColor3 = Theme.Text,
                    TextTransparency = OptionEnabled and 0.2 or 0.5,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 7
                })

                -- Toggle switch background (positioned at end like slider value)
                local ToggleSwitch = Create("Frame", {
                    Parent = OptionFrame,
                    BackgroundColor3 = OptionEnabled and Theme.Accent or Theme.ModuleStroke,
                    Position = UDim2.new(1, -32, 0.5, -7),
                    Size = UDim2.new(0, 32, 0, 14),
                    ZIndex = 7
                })

                local ToggleSwitchCorner = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleSwitch
                })

                -- Toggle circle (white ball) - positioned with more padding from edges
                local ToggleCircle = Create("Frame", {
                    Parent = ToggleSwitch,
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Position = OptionEnabled and UDim2.new(1, -14, 0.5, -5) or UDim2.new(0, 4, 0.5, -5),
                    Size = UDim2.new(0, 10, 0, 10),
                    ZIndex = 8
                })

                local ToggleCircleCorner = Create("UICorner", {
                    CornerRadius = UDim.new(1, 0),
                    Parent = ToggleCircle
                })

                local OptionClickArea = Create("TextButton", {
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
                        Tween(ToggleCircle, {Position = UDim2.new(1, -14, 0.5, -5)}, 0.15)
                        Tween(OptionLabel, {TextTransparency = 0.2}, 0.15)
                    else
                        Tween(ToggleSwitch, {BackgroundColor3 = Theme.ModuleStroke}, 0.15)
                        Tween(ToggleCircle, {Position = UDim2.new(0, 4, 0.5, -5)}, 0.15)
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
                    Parent = OptionsContainer,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 32),
                    LayoutOrder = #ModuleAPI.Options + 1,
                    ZIndex = 6
                })

                local SliderLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0, 0, 0, 0),
                    Size = UDim2.new(0.6, 0, 0, 16),
                    Font = Enum.Font.Gotham,
                    Text = SliderConfig.Name,
                    TextColor3 = Theme.Text,
                    TextTransparency = 0.3,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 7
                })

                local SliderValueLabel = Create("TextLabel", {
                    Parent = SliderFrame,
                    BackgroundTransparency = 1,
                    Position = UDim2.new(0.6, 0, 0, 0),
                    Size = UDim2.new(0.4, 0, 0, 16),
                    Font = Enum.Font.Gotham,
                    Text = tostring(SliderValue),
                    TextColor3 = Theme.Accent,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    ZIndex = 7
                })

                local SliderBar = Create("Frame", {
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
        pcall(function() ScreenGui:Destroy() end)
        rawset(_G, InstanceKey, nil)
    end

    return Window
end

return Wisper
