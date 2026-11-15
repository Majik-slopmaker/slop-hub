-- SLOP HUB
-- LocalScript | StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- executor ubija skrypt przy teleporcie. Loader ustawia to sam,
-- ale mozesz tez wpisac URL recznie (raw github / loadstring.net).
local AUTO_RELOAD_URL = (getgenv and getgenv().SLOP_LOADER_URL)
    or _G.SLOP_LOADER_URL
    or ""

if AUTO_RELOAD_URL ~= "" then
    local env = (getgenv and getgenv()) or _G
    env.SLOP_LOADER_URL = AUTO_RELOAD_URL
end

-- SLOP GAME SUPPORT SYSTEM
local EGG_PLACE = 99838015219458
local PRISON_PLACE = 155615604
local RIVERS_PLACE = 87043539966079

local SUPPORTED_GAMES = {
    {
        PlaceId = EGG_PLACE,
        Name = "Steal Eggs From Tsunami!",
        Icon = "rbxthumb://type=PlaceIcon&id=" .. EGG_PLACE .. "&w=150&h=150"
    },
    {
        PlaceId = PRISON_PLACE,
        Name = "Prison Life",
        Icon = "rbxthumb://type=PlaceIcon&id=" .. PRISON_PLACE .. "&w=150&h=150"
    },
    {
        PlaceId = RIVERS_PLACE,
        Name = "Cross Rivers for Animals",
        Icon = "rbxthumb://type=PlaceIcon&id=" .. RIVERS_PLACE .. "&w=150&h=150"
    }
}

local currentGameSupported = false
for _, gameInfo in ipairs(SUPPORTED_GAMES) do
    if gameInfo.PlaceId == game.PlaceId then
        currentGameSupported = true
        break
    end
end

-- =========================================================
-- GAMES LIST - wspolne dla kazdej gry
-- =========================================================

local YELLOW = Color3.fromRGB(255, 199, 44)

local function slopJoin(placeId)
    if placeId == game.PlaceId then
        return false
    end

    local queue = queue_on_teleport
        or (syn and syn.queue_on_teleport)
        or (fluxus and fluxus.queue_on_teleport)

    if queue and AUTO_RELOAD_URL ~= "" then
        pcall(queue, ('loadstring(game:HttpGet("%s"))()'):format(AUTO_RELOAD_URL))
    end

    local ok = pcall(TeleportService.Teleport, TeleportService, placeId, player)

    if ok then
        return true
    end

    local remote = ReplicatedStorage:FindFirstChild("SLOP_JoinGame")
    if remote and remote:IsA("RemoteEvent") then
        remote:FireServer(placeId)
        return true
    end

    return false
end

local function buildGamesList(parent, topInset)
    local list = Instance.new("ScrollingFrame")
    list.Name = "GamesList"
    list.Position = UDim2.fromOffset(0, topInset)
    list.Size = UDim2.new(1, 0, 1, -topInset)
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 4
    list.ScrollBarImageColor3 = YELLOW
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.Parent = parent

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 0)
    padding.PaddingBottom = UDim.new(0, 4)
    padding.Parent = list

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = list

    for index, gameInfo in ipairs(SUPPORTED_GAMES) do
        local here = gameInfo.PlaceId == game.PlaceId

        local card = Instance.new("Frame")
        card.Name = "Game_" .. tostring(gameInfo.PlaceId)
        card.Size = UDim2.new(1, -4, 0, 50)
        card.BackgroundColor3 = Color3.fromRGB(40, 38, 57)
        card.BorderSizePixel = 0
        card.LayoutOrder = index
        card.Parent = list
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

        local icon = Instance.new("ImageLabel")
        icon.Position = UDim2.fromOffset(8, 8)
        icon.Size = UDim2.fromOffset(34, 34)
        icon.BackgroundColor3 = Color3.fromRGB(23, 23, 34)
        icon.BorderSizePixel = 0
        icon.Image = gameInfo.Icon
        icon.ScaleType = Enum.ScaleType.Crop
        icon.Parent = card
        Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 7)

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Position = UDim2.fromOffset(50, 6)
        nameLabel.Size = UDim2.new(1, -120, 0, 16)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = gameInfo.Name
        nameLabel.TextColor3 = Color3.fromRGB(235, 230, 255)
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 12
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
        nameLabel.Parent = card

        local idLabel = Instance.new("TextLabel")
        idLabel.Position = UDim2.fromOffset(50, 23)
        idLabel.Size = UDim2.new(1, -120, 0, 14)
        idLabel.BackgroundTransparency = 1
        idLabel.Text = "Place ID: " .. tostring(gameInfo.PlaceId)
        idLabel.TextColor3 = Color3.fromRGB(145, 145, 165)
        idLabel.Font = Enum.Font.Gotham
        idLabel.TextSize = 9
        idLabel.TextXAlignment = Enum.TextXAlignment.Left
        idLabel.Parent = card

        local joinButton = Instance.new("TextButton")
        joinButton.Name = "JoinButton"
        joinButton.AnchorPoint = Vector2.new(1, 0.5)
        joinButton.Position = UDim2.new(1, -8, 0.5, 0)
        joinButton.Size = UDim2.fromOffset(58, 26)
        joinButton.BackgroundColor3 = here and Color3.fromRGB(52, 50, 62) or YELLOW
        joinButton.Text = here and "IN GAME" or "JOIN"
        joinButton.TextColor3 = here
            and Color3.fromRGB(140, 140, 160)
            or Color3.fromRGB(28, 22, 4)
        joinButton.Font = Enum.Font.GothamBold
        joinButton.TextSize = 10
        joinButton.BorderSizePixel = 0
        joinButton.AutoButtonColor = false
        joinButton.Parent = card
        Instance.new("UICorner", joinButton).CornerRadius = UDim.new(0, 7)

        if not here then
            joinButton.MouseEnter:Connect(function()
                joinButton.BackgroundColor3 = Color3.fromRGB(255, 219, 105)
            end)

            joinButton.MouseLeave:Connect(function()
                if joinButton.Text == "JOIN" then
                    joinButton.BackgroundColor3 = YELLOW
                end
            end)

            joinButton.MouseButton1Click:Connect(function()
                if joinButton.Text ~= "JOIN" then
                    return
                end

                joinButton.Text = "JOINING"
                joinButton.BackgroundColor3 = Color3.fromRGB(200, 150, 25)

                if not slopJoin(gameInfo.PlaceId) then
                    joinButton.Text = "FAILED"
                    joinButton.BackgroundColor3 = Color3.fromRGB(170, 55, 75)
                    joinButton.TextColor3 = Color3.new(1, 1, 1)

                    task.delay(3, function()
                        if joinButton.Parent then
                            joinButton.Text = "JOIN"
                            joinButton.TextColor3 = Color3.fromRGB(28, 22, 4)
                            joinButton.BackgroundColor3 = YELLOW
                        end
                    end)
                    return
                end

                -- skrypt dalej zyje = teleport odrzucony (773)
                task.delay(6, function()
                    if joinButton.Parent then
                        joinButton.Text = "BLOCKED"
                        joinButton.BackgroundColor3 = Color3.fromRGB(170, 55, 75)
                        joinButton.TextColor3 = Color3.new(1, 1, 1)
                    end
                end)
            end)
        end
    end

    return list
end

-- =========================================================
-- AKIRI UI LIBRARY - wspolne okno dla kazdej gry
-- =========================================================

local AKIRI = {
    ACCENT = Color3.fromHex("#c37be5"),
    OUTLINE = Color3.fromHex("#000005"),
    INLINE = Color3.fromHex("#3c3c3c"),
    LIGHT = Color3.fromHex("#231946"),
    DARK = Color3.fromHex("#191432"),
    HOVER = Color3.fromHex("#1f1737"),
    TEXT = Color3.fromHex("#c8c8ff"),
    TEXT_OFF = Color3.fromHex("#afafaf"),
    WARN = Color3.fromHex("#fc9803"),
    GOOD = Color3.fromHex("#7dff9b"),
    FONT = Enum.Font.RobotoMono
}

local function createAkiriWindow(subtitle)
    local C = AKIRI

    local function create(class, props, parent)
        local obj = Instance.new(class)
        for k, v in pairs(props) do
            obj[k] = v
        end
        obj.Parent = parent
        return obj
    end

    local function tween(obj, properties, duration)
        TweenService:Create(
            obj,
            TweenInfo.new(duration or 0.15, Enum.EasingStyle.Linear),
            properties
        ):Play()
    end

    local old = playerGui:FindFirstChild("SLOP")
    if old then
        old:Destroy()
    end

    local gui = create("ScreenGui", {
        Name = "SLOP",
        ResetOnSpawn = false
    }, playerGui)

    local main = create("Frame", {
        Size = UDim2.new(0, 560, 0, 380),
        Position = UDim2.new(0.5, -280, 0.5, -190),
        BackgroundColor3 = C.DARK,
        BorderSizePixel = 0,
        Active = true
    }, gui)

    create("UIStroke", {
        Color = C.ACCENT,
        Thickness = 1
    }, main)

    create("Frame", {
        Size = UDim2.new(1, -2, 0, 2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = C.ACCENT,
        BorderSizePixel = 0
    }, main)

    -- TOP BAR
    local top = create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0, 3),
        BackgroundTransparency = 1,
        Active = true
    }, main)

    create("TextLabel", {
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = "SLOP",
        TextColor3 = C.TEXT,
        Font = C.FONT,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    }, top)

    create("TextLabel", {
        Size = UDim2.new(0, 280, 1, 0),
        Position = UDim2.new(1, -312, 0, 0),
        BackgroundTransparency = 1,
        Text = subtitle,
        TextColor3 = C.TEXT_OFF,
        Font = C.FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right
    }, top)

    local close = create("TextButton", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -26, 0.5, -10),
        BackgroundColor3 = C.DARK,
        Text = "x",
        TextColor3 = C.TEXT_OFF,
        Font = C.FONT,
        TextSize = 12,
        BorderSizePixel = 0,
        AutoButtonColor = false
    }, top)

    create("UIStroke", {
        Color = C.INLINE,
        Thickness = 1
    }, close)

    close.MouseEnter:Connect(function()
        close.TextColor3 = Color3.fromHex("#c82828")
    end)

    close.MouseLeave:Connect(function()
        close.TextColor3 = C.TEXT_OFF
    end)

    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 31),
        BackgroundColor3 = C.INLINE,
        BorderSizePixel = 0
    }, main)

    -- SIDEBAR
    local sidebar = create("Frame", {
        Size = UDim2.new(0, 132, 1, -40),
        Position = UDim2.new(0, 1, 0, 32),
        BackgroundTransparency = 1
    }, main)

    create("Frame", {
        Size = UDim2.new(0, 1, 1, -40),
        Position = UDim2.new(0, 133, 0, 32),
        BackgroundColor3 = C.INLINE,
        BorderSizePixel = 0
    }, main)

    -- CONTENT
    local content = create("Frame", {
        Size = UDim2.new(1, -153, 1, -45),
        Position = UDim2.new(0, 143, 0, 35),
        BackgroundTransparency = 1
    }, main)

    local pages = {}
    local tabs = {}
    local activeTab = nil

    local function paintTab(tab, active, hover)
        if tab.games then
            tab.button.BackgroundColor3 = hover and Color3.fromRGB(255, 214, 90) or YELLOW
            tab.label.TextColor3 = Color3.new(1, 1, 1)
            return
        end

        tab.button.BackgroundColor3 = active and C.LIGHT or (hover and C.HOVER or C.DARK)
        tab.label.TextColor3 = (active or hover) and C.TEXT or C.TEXT_OFF
        tab.bar.Visible = active
    end

    local function open(name)
        activeTab = name

        for pageName, page in pairs(pages) do
            page.Visible = pageName == name
        end

        for tabName, tab in pairs(tabs) do
            paintTab(tab, tabName == name, false)
        end
    end

    local function page(name)
        local frame = create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false
        }, content)

        pages[name] = frame
        return frame
    end

    local function tab(name, order, games)
        local button = create("TextButton", {
            Size = UDim2.new(1, -8, 0, 28),
            Position = UDim2.new(0, 4, 0, 6 + (order - 1) * 30),
            BackgroundColor3 = games and YELLOW or C.DARK,
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false
        }, sidebar)

        local bar = create("Frame", {
            Size = UDim2.new(0, 2, 0, 14),
            Position = UDim2.new(0, 0, 0.5, -7),
            BackgroundColor3 = C.ACCENT,
            BorderSizePixel = 0,
            Visible = false
        }, button)

        local label = create("TextLabel", {
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 14, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = games and Color3.new(1, 1, 1) or C.TEXT_OFF,
            Font = C.FONT,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        }, button)

        local data = {
            button = button,
            bar = bar,
            label = label,
            games = games
        }

        tabs[name] = data

        button.MouseEnter:Connect(function()
            if activeTab ~= name then
                paintTab(data, false, true)
            end
        end)

        button.MouseLeave:Connect(function()
            paintTab(data, activeTab == name, false)
        end)

        button.MouseButton1Click:Connect(function()
            open(name)
        end)

        return data
    end

    local function section(parent, title, y, height)
        local box = create("Frame", {
            Size = UDim2.new(1, 0, 0, height),
            Position = UDim2.new(0, 0, 0, y),
            BackgroundColor3 = C.LIGHT,
            BorderSizePixel = 0
        }, parent)

        create("UIStroke", {
            Color = C.INLINE,
            Thickness = 1
        }, box)

        create("Frame", {
            Size = UDim2.new(0, 3, 0, 12),
            Position = UDim2.new(0, 8, 0, 8),
            BackgroundColor3 = C.ACCENT,
            BorderSizePixel = 0
        }, box)

        create("TextLabel", {
            Size = UDim2.new(1, -24, 0, 14),
            Position = UDim2.new(0, 17, 0, 7),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = C.TEXT,
            Font = C.FONT,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        }, box)

        create("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0, 26),
            BackgroundColor3 = C.INLINE,
            BorderSizePixel = 0
        }, box)

        return box
    end

    local function row(parent, text, y, callback)
        local button = create("TextButton", {
            Size = UDim2.new(1, -16, 0, 26),
            Position = UDim2.new(0, 8, 0, y),
            BackgroundColor3 = C.DARK,
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false
        }, parent)

        local stroke = create("UIStroke", {
            Color = C.INLINE,
            Thickness = 1
        }, button)

        create("TextLabel", {
            Size = UDim2.new(1, -32, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = C.TEXT,
            Font = C.FONT,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        }, button)

        local arrow = create("TextLabel", {
            Size = UDim2.new(0, 16, 1, 0),
            Position = UDim2.new(1, -20, 0, 0),
            BackgroundTransparency = 1,
            Text = ">",
            TextColor3 = C.ACCENT,
            Font = C.FONT,
            TextSize = 11
        }, button)

        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = C.HOVER
            stroke.Color = C.ACCENT
        end)

        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = C.DARK
            stroke.Color = C.INLINE
        end)

        button.MouseButton1Click:Connect(function()
            if callback then
                callback(arrow)
            end
        end)

        return button
    end

    local function listRow(parent, text, order, callback)
        local button = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = C.DARK,
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false,
            LayoutOrder = order
        }, parent)

        local stroke = create("UIStroke", {
            Color = C.INLINE,
            Thickness = 1
        }, button)

        create("TextLabel", {
            Size = UDim2.new(1, -32, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = C.TEXT,
            Font = C.FONT,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd
        }, button)

        local arrow = create("TextLabel", {
            Size = UDim2.new(0, 16, 1, 0),
            Position = UDim2.new(1, -20, 0, 0),
            BackgroundTransparency = 1,
            Text = ">",
            TextColor3 = C.ACCENT,
            Font = C.FONT,
            TextSize = 11
        }, button)

        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = C.HOVER
            stroke.Color = C.ACCENT
        end)

        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = C.DARK
            stroke.Color = C.INLINE
        end)

        button.MouseButton1Click:Connect(function()
            if callback then
                callback(arrow)
            end
        end)

        return button
    end

    local function toggle(parent, title, y, initial, callback)
        local button = create("TextButton", {
            Size = UDim2.new(1, -16, 0, 24),
            Position = UDim2.new(0, 8, 0, y),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false
        }, parent)

        local box = create("Frame", {
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(0, 0, 0.5, -6),
            BackgroundColor3 = C.DARK,
            BorderSizePixel = 0
        }, button)

        local stroke = create("UIStroke", {
            Color = C.INLINE,
            Thickness = 1
        }, box)

        create("TextLabel", {
            Size = UDim2.new(1, -22, 1, 0),
            Position = UDim2.new(0, 20, 0, 0),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = C.TEXT,
            Font = C.FONT,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        }, button)

        local state = initial

        local function paint()
            box.BackgroundColor3 = state and C.ACCENT or C.DARK
            stroke.Color = state and C.ACCENT or C.INLINE
        end

        paint()

        button.MouseEnter:Connect(function()
            if not state then
                box.BackgroundColor3 = C.HOVER
            end
        end)

        button.MouseLeave:Connect(paint)

        button.MouseButton1Click:Connect(function()
            state = not state
            paint()

            if callback then
                callback(state)
            end
        end)

        return function(value)
            state = value
            paint()
        end
    end

    local function scrollList(parent, topInset)
        local list = create("ScrollingFrame", {
            Position = UDim2.fromOffset(0, topInset),
            Size = UDim2.new(1, 0, 1, -topInset),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = C.ACCENT,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y
        }, parent)

        create("UIPadding", {
            PaddingTop = UDim.new(0, 0),
            PaddingBottom = UDim.new(0, 4)
        }, list)

        create("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder
        }, list)

        return list
    end

    -- DRAGGING
    local dragging = false
    local dragStart
    local startPosition

    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = main.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart

            main.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- LEFT ALT / RIGHT SHIFT = HIDE / SHOW
    UIS.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end

        if input.KeyCode == Enum.KeyCode.LeftAlt
        or input.KeyCode == Enum.KeyCode.RightShift then
            main.Visible = not main.Visible
        end
    end)

    return {
        gui = gui,
        main = main,
        sidebar = sidebar,
        content = content,
        create = create,
        tween = tween,
        page = page,
        tab = tab,
        open = open,
        section = section,
        row = row,
        toggle = toggle,
        listRow = listRow,
        scrollList = scrollList
    }
end

-- UNSUPPORTED GAME: SHOW GAMES LIST
if not currentGameSupported then
    local oldGui = playerGui:FindFirstChild("SLOP")
    if oldGui then
        oldGui:Destroy()
    end

    local gamesGui = Instance.new("ScreenGui")
    gamesGui.Name = "SLOP"
    gamesGui.ResetOnSpawn = false
    gamesGui.Parent = playerGui

    local main = Instance.new("Frame")
    main.Name = "GamesWindow"
    main.Size = UDim2.fromOffset(530, 460)
    main.Position = UDim2.new(0.5, -265, 0.5, -230)
    main.BackgroundColor3 = Color3.fromRGB(17, 18, 25)
    main.BorderSizePixel = 0
    main.Parent = gamesGui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local outline = Instance.new("UIStroke")
    outline.Color = Color3.fromRGB(100, 75, 210)
    outline.Thickness = 1.5
    outline.Parent = main

    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, 48)
    top.BackgroundColor3 = Color3.fromRGB(25, 25, 37)
    top.BorderSizePixel = 0
    top.Parent = main
    Instance.new("UICorner", top).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -80, 1, 0)
    title.Position = UDim2.fromOffset(16, 0)
    title.BackgroundTransparency = 1
    title.Text = "SLOP  |  GAMES LIST"
    title.TextColor3 = Color3.fromRGB(190, 160, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 17
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = top

    local close = Instance.new("TextButton")
    close.Name = "Close"
    close.AnchorPoint = Vector2.new(1, 0)
    close.Position = UDim2.new(1, -10, 0, 10)
    close.Size = UDim2.fromOffset(30, 28)
    close.BackgroundColor3 = Color3.fromRGB(170, 55, 75)
    close.Text = "X"
    close.TextColor3 = Color3.new(1, 1, 1)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 15
    close.BorderSizePixel = 0
    close.Parent = top
    Instance.new("UICorner", close).CornerRadius = UDim.new(0, 6)

    local status = Instance.new("TextLabel")
    status.Position = UDim2.fromOffset(22, 62)
    status.Size = UDim2.new(1, -44, 0, 28)
    status.BackgroundTransparency = 1
    status.Text = "GAME NOT SUPPORTED"
    status.TextColor3 = Color3.fromRGB(255, 65, 75)
    status.Font = Enum.Font.GothamBlack
    status.TextSize = 18
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.Parent = main

    local subtitle = Instance.new("TextLabel")
    subtitle.Position = UDim2.fromOffset(22, 91)
    subtitle.Size = UDim2.new(1, -44, 0, 22)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "Join one of the " .. tostring(#SUPPORTED_GAMES) .. " games supported by SLOP."
    subtitle.TextColor3 = Color3.fromRGB(145, 145, 165)
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 12
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = main

    local list = Instance.new("ScrollingFrame")
    list.Name = "SupportedGames"
    list.Position = UDim2.fromOffset(22, 125)
    list.Size = UDim2.new(1, -44, 1, -147)
    list.BackgroundColor3 = Color3.fromRGB(23, 23, 34)
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 5
    list.ScrollBarImageColor3 = Color3.fromRGB(130, 95, 220)
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.Parent = main
    Instance.new("UICorner", list).CornerRadius = UDim.new(0, 8)

    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 10)
    listPadding.PaddingBottom = UDim.new(0, 10)
    listPadding.PaddingLeft = UDim.new(0, 10)
    listPadding.PaddingRight = UDim.new(0, 10)
    listPadding.Parent = list

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = list

    -- executor: TeleportService.Teleport dziala bezposrednio, bez zadnego serwera.
    -- published hub: jesli to padnie, leci fallback na remote z SLOP_Server.
    local joinRemote = ReplicatedStorage:FindFirstChild("SLOP_JoinGame")
    local resultRemote = ReplicatedStorage:FindFirstChild("SLOP_JoinResult")

    local function queueReload()
        if AUTO_RELOAD_URL == "" then
            return
        end

        local queue = queue_on_teleport
            or (syn and syn.queue_on_teleport)
            or (fluxus and fluxus.queue_on_teleport)

        if queue then
            pcall(queue, ('loadstring(game:HttpGet("%s"))()'):format(AUTO_RELOAD_URL))
        end
    end

    local function joinPlace(placeId)
        queueReload()

        -- kropka + service jako pierwszy argument, tak samo jak w dzialajacych hubach
        local ok, err = pcall(TeleportService.Teleport, TeleportService, placeId, player)

        if ok then
            return true
        end

        if joinRemote and joinRemote:IsA("RemoteEvent") then
            joinRemote:FireServer(placeId)
            return true
        end

        return false, tostring(err)
    end

    local joining = {}

    local function resetButton(button)
        if not button.Parent then
            return
        end

        button.Text = "JOIN"
        button.BackgroundColor3 = Color3.fromRGB(90, 65, 175)
    end

    if resultRemote and resultRemote:IsA("RemoteEvent") then
        resultRemote.OnClientEvent:Connect(function(state, placeId, message)
            local card = list:FindFirstChild("Game_" .. tostring(placeId))
            local button = card and card:FindFirstChild("JoinButton")

            if not button then
                return
            end

            joining[placeId] = nil

            if state == "Failed" then
                button.Text = "FAILED"
                button.BackgroundColor3 = Color3.fromRGB(170, 55, 75)
                status.Text = "TELEPORT FAILED"
                status.TextColor3 = Color3.fromRGB(255, 65, 75)

                if message then
                    warn("SLOP: join failed -> " .. tostring(message))
                end

                task.delay(3, function()
                    if button.Parent and not joining[placeId] then
                        resetButton(button)
                    end
                end)
            end
        end)
    end

    for index, gameInfo in ipairs(SUPPORTED_GAMES) do
        local card = Instance.new("Frame")
        card.Name = "Game_" .. tostring(gameInfo.PlaceId)
        card.Size = UDim2.new(1, -4, 0, 64)
        card.BackgroundColor3 = Color3.fromRGB(40, 38, 57)
        card.BorderSizePixel = 0
        card.LayoutOrder = index
        card.Parent = list
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

        local icon = Instance.new("ImageLabel")
        icon.Name = "GameIcon"
        icon.Position = UDim2.fromOffset(10, 12)
        icon.Size = UDim2.fromOffset(40, 40)
        icon.BackgroundColor3 = Color3.fromRGB(23, 23, 34)
        icon.BorderSizePixel = 0
        icon.Image = gameInfo.Icon
        icon.ScaleType = Enum.ScaleType.Crop
        icon.Parent = card
        Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 7)

        local gameName = Instance.new("TextLabel")
        gameName.Name = "GameName"
        gameName.Position = UDim2.fromOffset(62, 8)
        gameName.Size = UDim2.new(1, -190, 0, 20)
        gameName.BackgroundTransparency = 1
        gameName.Text = gameInfo.Name
        gameName.TextColor3 = Color3.fromRGB(235, 230, 255)
        gameName.Font = Enum.Font.GothamBold
        gameName.TextSize = 13
        gameName.TextXAlignment = Enum.TextXAlignment.Left
        gameName.TextTruncate = Enum.TextTruncate.AtEnd
        gameName.Parent = card

        local gameId = Instance.new("TextLabel")
        gameId.Position = UDim2.fromOffset(62, 29)
        gameId.Size = UDim2.new(1, -190, 0, 16)
        gameId.BackgroundTransparency = 1
        gameId.Text = "Place ID: " .. tostring(gameInfo.PlaceId)
        gameId.TextColor3 = Color3.fromRGB(145, 145, 165)
        gameId.Font = Enum.Font.Gotham
        gameId.TextSize = 9
        gameId.TextXAlignment = Enum.TextXAlignment.Left
        gameId.Parent = card

        local joinButton = Instance.new("TextButton")
        joinButton.Name = "JoinButton"
        joinButton.AnchorPoint = Vector2.new(1, 0.5)
        joinButton.Position = UDim2.new(1, -10, 0.5, 0)
        joinButton.Size = UDim2.fromOffset(80, 30)
        joinButton.BackgroundColor3 = Color3.fromRGB(90, 65, 175)
        joinButton.Text = "JOIN"
        joinButton.TextColor3 = Color3.new(1, 1, 1)
        joinButton.Font = Enum.Font.GothamBold
        joinButton.TextSize = 11
        joinButton.BorderSizePixel = 0
        joinButton.AutoButtonColor = false
        joinButton.Parent = card
        Instance.new("UICorner", joinButton).CornerRadius = UDim.new(0, 7)

        local openButton = Instance.new("TextButton")
        openButton.Name = "OpenButton"
        openButton.AnchorPoint = Vector2.new(1, 0.5)
        openButton.Position = UDim2.new(1, -96, 0.5, 0)
        openButton.Size = UDim2.fromOffset(30, 30)
        openButton.BackgroundColor3 = Color3.fromRGB(55, 52, 78)
        openButton.Text = "↗"
        openButton.TextColor3 = Color3.fromRGB(190, 160, 255)
        openButton.Font = Enum.Font.GothamBold
        openButton.TextSize = 16
        openButton.BorderSizePixel = 0
        openButton.AutoButtonColor = false
        openButton.Parent = card
        Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 7)

        openButton.MouseButton1Click:Connect(function()
            local url = "https://www.roblox.com/games/" .. tostring(gameInfo.PlaceId)

            local copyFn = setclipboard or toclipboard or set_clipboard
            if copyFn then
                pcall(copyFn, url)
            end

            -- GuiService:OpenBrowserWindow jest RobloxScriptSecurity, w executorze czesto przechodzi
            pcall(function()
                game:GetService("GuiService"):OpenBrowserWindow(url)
            end)

            status.Text = "LINK COPIED - " .. tostring(gameInfo.PlaceId)
            status.TextColor3 = Color3.fromRGB(190, 160, 255)
        end)

        joinButton.MouseEnter:Connect(function()
            if not joining[gameInfo.PlaceId] then
                joinButton.BackgroundColor3 = Color3.fromRGB(115, 85, 205)
            end
        end)

        joinButton.MouseLeave:Connect(function()
            if not joining[gameInfo.PlaceId] then
                joinButton.BackgroundColor3 = Color3.fromRGB(90, 65, 175)
            end
        end)

        joinButton.MouseButton1Click:Connect(function()
            if joining[gameInfo.PlaceId] then
                return
            end

            joining[gameInfo.PlaceId] = true
            joinButton.Text = "JOINING..."
            joinButton.BackgroundColor3 = Color3.fromRGB(120, 90, 200)

            local ok, err = joinPlace(gameInfo.PlaceId)

            if ok then
                status.Text = "TELEPORTING TO " .. string.upper(gameInfo.Name)
                status.TextColor3 = Color3.fromRGB(110, 255, 150)

                -- udany teleport zabija ten skrypt, wiec jesli ten callback w ogole
                -- odpalil, to join zostal odrzucony (773 i spolka nie leca przez pcall)
                task.delay(6, function()
                    joining[gameInfo.PlaceId] = nil
                    joinButton.Text = "BLOCKED"
                    joinButton.BackgroundColor3 = Color3.fromRGB(170, 55, 75)
                    -- 773 = gra ZRODLOWA blokuje teleporty na zewnatrz
                    -- (Game Settings > Security > Allow Third Party Teleports)
                    status.Text = "THIS GAME BLOCKS TP OUT - USE ↗"
                    status.TextColor3 = Color3.fromRGB(255, 65, 75)

                    local copyFn = setclipboard or toclipboard or set_clipboard
                    if copyFn then
                        pcall(copyFn, tostring(gameInfo.PlaceId))
                    end

                    task.delay(3, function()
                        resetButton(joinButton)
                    end)
                end)
                return
            end

            joining[gameInfo.PlaceId] = nil
            joinButton.Text = "FAILED"
            joinButton.BackgroundColor3 = Color3.fromRGB(170, 55, 75)
            status.Text = "TELEPORT FAILED"
            status.TextColor3 = Color3.fromRGB(255, 65, 75)
            warn("SLOP: teleport failed -> " .. tostring(err))

            local copyFn = setclipboard or toclipboard or set_clipboard
            if copyFn then
                pcall(copyFn, tostring(gameInfo.PlaceId))
            end

            task.delay(3, function()
                resetButton(joinButton)
            end)
        end)
    end

    -- DRAG
    local dragging = false
    local dragStart
    local startPosition

    top.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
            return
        end

        if input.Position.X >= close.AbsolutePosition.X then
            return
        end

        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart

            main.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    close.MouseButton1Click:Connect(function()
        gamesGui:Destroy()
    end)

    return
end

-- =========================================================
-- PRISON LIFE
-- =========================================================

if game.PlaceId == PRISON_PLACE then
    local function create(class, props, parent)
        local obj = Instance.new(class)
        for k, v in pairs(props) do
            obj[k] = v
        end
        obj.Parent = parent
        return obj
    end

    local function tween(obj, properties, duration)
        TweenService:Create(
            obj,
            TweenInfo.new(duration or 0.15, Enum.EasingStyle.Linear),
            properties
        ):Play()
    end

    -- Akiri theme (credit: Akiri Lib)
    local ACCENT = Color3.fromHex("#c37be5")
    local OUTLINE = Color3.fromHex("#000005")
    local INLINE = Color3.fromHex("#3c3c3c")
    local LIGHT = Color3.fromHex("#231946")
    local DARK = Color3.fromHex("#191432")
    local HOVER = Color3.fromHex("#1f1737")
    local TEXT = Color3.fromHex("#c8c8ff")
    local TEXT_OFF = Color3.fromHex("#afafaf")
    local WARN = Color3.fromHex("#fc9803")
    local GOOD = Color3.fromHex("#7dff9b")
    local FONT = Enum.Font.RobotoMono

    -- GUI
    local old = playerGui:FindFirstChild("SLOP")
    if old then
        old:Destroy()
    end

    local gui = create("ScreenGui", {
        Name = "SLOP",
        ResetOnSpawn = false
    }, playerGui)

    -- MAIN WINDOW
    local main = create("Frame", {
        Size = UDim2.new(0, 560, 0, 380),
        Position = UDim2.new(0.5, -280, 0.5, -190),
        BackgroundColor3 = DARK,
        BorderSizePixel = 0,
        Active = true
    }, gui)

    create("UIStroke", {
        Color = ACCENT,
        Thickness = 1
    }, main)

    create("Frame", {
        Size = UDim2.new(1, -2, 0, 2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = ACCENT,
        BorderSizePixel = 0
    }, main)

    -- TOP BAR
    local top = create("Frame", {
        Size = UDim2.new(1, 0, 0, 28),
        Position = UDim2.new(0, 0, 0, 3),
        BackgroundTransparency = 1,
        Active = true
    }, main)

    create("TextLabel", {
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = "SLOP",
        TextColor3 = TEXT,
        Font = FONT,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    }, top)

    create("TextLabel", {
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(1, -232, 0, 0),
        BackgroundTransparency = 1,
        Text = "prison life",
        TextColor3 = TEXT_OFF,
        Font = FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right
    }, top)

    local close = create("TextButton", {
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -26, 0.5, -10),
        BackgroundColor3 = DARK,
        Text = "x",
        TextColor3 = TEXT_OFF,
        Font = FONT,
        TextSize = 12,
        BorderSizePixel = 0,
        AutoButtonColor = false
    }, top)

    create("UIStroke", {
        Color = INLINE,
        Thickness = 1
    }, close)

    close.MouseEnter:Connect(function()
        close.TextColor3 = Color3.fromHex("#c82828")
    end)

    close.MouseLeave:Connect(function()
        close.TextColor3 = TEXT_OFF
    end)

    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    create("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 31),
        BackgroundColor3 = INLINE,
        BorderSizePixel = 0
    }, main)

    -- SIDEBAR
    local sidebar = create("Frame", {
        Size = UDim2.new(0, 132, 1, -40),
        Position = UDim2.new(0, 1, 0, 32),
        BackgroundTransparency = 1
    }, main)

    create("Frame", {
        Size = UDim2.new(0, 1, 1, -40),
        Position = UDim2.new(0, 133, 0, 32),
        BackgroundColor3 = INLINE,
        BorderSizePixel = 0
    }, main)

    -- CONTENT
    local content = create("Frame", {
        Size = UDim2.new(1, -153, 1, -45),
        Position = UDim2.new(0, 143, 0, 35),
        BackgroundTransparency = 1
    }, main)

    local pages = {}
    local tabs = {}
    local activeTab = nil

    local function createPage(name)
        local page = create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false
        }, content)

        pages[name] = page
        return page
    end

    local function switchPage(name)
        for pageName, page in pairs(pages) do
            page.Visible = pageName == name
        end
    end

    local function paintTab(tab, active, hover)
        if tab.games then
            tab.button.BackgroundColor3 = hover and Color3.fromRGB(255, 214, 90) or YELLOW
            tab.label.TextColor3 = Color3.new(1, 1, 1)
            return
        end

        tab.button.BackgroundColor3 = active and LIGHT or (hover and HOVER or DARK)
        tab.label.TextColor3 = (active or hover) and TEXT or TEXT_OFF
        tab.bar.Visible = active
    end

    local function createTab(name, order, games)
        local button = create("TextButton", {
            Size = UDim2.new(1, -8, 0, 28),
            Position = UDim2.new(0, 4, 0, 6 + (order - 1) * 30),
            BackgroundColor3 = games and YELLOW or DARK,
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false
        }, sidebar)

        local bar = create("Frame", {
            Size = UDim2.new(0, 2, 0, 14),
            Position = UDim2.new(0, 0, 0.5, -7),
            BackgroundColor3 = ACCENT,
            BorderSizePixel = 0,
            Visible = false
        }, button)

        local label = create("TextLabel", {
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 14, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = games and Color3.new(1, 1, 1) or TEXT_OFF,
            Font = FONT,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        }, button)

        local tab = {
            button = button,
            bar = bar,
            label = label,
            games = games
        }

        tabs[name] = tab

        button.MouseEnter:Connect(function()
            if activeTab ~= name then
                paintTab(tab, false, true)
            end
        end)

        button.MouseLeave:Connect(function()
            paintTab(tab, activeTab == name, false)
        end)

        button.MouseButton1Click:Connect(function()
            activeTab = name
            switchPage(name)

            for tabName, other in pairs(tabs) do
                paintTab(other, tabName == name, false)
            end
        end)

        return tab
    end

    local movementPage = createPage("MOVEMENT")
    local teleportPage = createPage("TELEPORTS")
    local infoPage = createPage("INFO")
    local doorsPage = createPage("DOORS")
    local gamesPage = createPage("GAMES LIST")

    createTab("MOVEMENT", 1)
    createTab("TELEPORTS", 2)
    createTab("DOORS", 3)
    createTab("INFO", 4)

    -- GAMES LIST - zolty, na samym dole
    local gamesTab = createTab("GAMES LIST", 0, true)
    gamesTab.button.AnchorPoint = Vector2.new(0, 1)
    gamesTab.button.Position = UDim2.new(0, 4, 1, -6)
    gamesTab.bar.Visible = false

    activeTab = "MOVEMENT"
    switchPage("MOVEMENT")

    for tabName, tab in pairs(tabs) do
        paintTab(tab, tabName == "MOVEMENT", false)
    end

    local function section(parent, title, y, height)
        local box = create("Frame", {
            Size = UDim2.new(1, 0, 0, height),
            Position = UDim2.new(0, 0, 0, y),
            BackgroundColor3 = LIGHT,
            BorderSizePixel = 0
        }, parent)

        create("UIStroke", {
            Color = INLINE,
            Thickness = 1
        }, box)

        create("Frame", {
            Size = UDim2.new(0, 3, 0, 12),
            Position = UDim2.new(0, 8, 0, 8),
            BackgroundColor3 = ACCENT,
            BorderSizePixel = 0
        }, box)

        create("TextLabel", {
            Size = UDim2.new(1, -24, 0, 14),
            Position = UDim2.new(0, 17, 0, 7),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = TEXT,
            Font = FONT,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        }, box)

        create("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0, 26),
            BackgroundColor3 = INLINE,
            BorderSizePixel = 0
        }, box)

        return box
    end

    local function row(parent, text, y, callback)
        local button = create("TextButton", {
            Size = UDim2.new(1, -16, 0, 26),
            Position = UDim2.new(0, 8, 0, y),
            BackgroundColor3 = DARK,
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false
        }, parent)

        local stroke = create("UIStroke", {
            Color = INLINE,
            Thickness = 1
        }, button)

        create("TextLabel", {
            Size = UDim2.new(1, -32, 1, 0),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = TEXT,
            Font = FONT,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        }, button)

        local arrow = create("TextLabel", {
            Size = UDim2.new(0, 16, 1, 0),
            Position = UDim2.new(1, -20, 0, 0),
            BackgroundTransparency = 1,
            Text = ">",
            TextColor3 = ACCENT,
            Font = FONT,
            TextSize = 11
        }, button)

        button.MouseEnter:Connect(function()
            button.BackgroundColor3 = HOVER
            stroke.Color = ACCENT
        end)

        button.MouseLeave:Connect(function()
            button.BackgroundColor3 = DARK
            stroke.Color = INLINE
        end)

        button.MouseButton1Click:Connect(function()
            if callback then
                callback(arrow)
            end
        end)

        return button
    end

    local function toggle(parent, title, y, initial, callback)
        local button = create("TextButton", {
            Size = UDim2.new(1, -16, 0, 24),
            Position = UDim2.new(0, 8, 0, y),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false
        }, parent)

        local box = create("Frame", {
            Size = UDim2.new(0, 12, 0, 12),
            Position = UDim2.new(0, 0, 0.5, -6),
            BackgroundColor3 = DARK,
            BorderSizePixel = 0
        }, button)

        local stroke = create("UIStroke", {
            Color = INLINE,
            Thickness = 1
        }, box)

        create("TextLabel", {
            Size = UDim2.new(1, -22, 1, 0),
            Position = UDim2.new(0, 20, 0, 0),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = TEXT,
            Font = FONT,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left
        }, button)

        local state = initial

        local function paint()
            box.BackgroundColor3 = state and ACCENT or DARK
            stroke.Color = state and ACCENT or INLINE
        end

        paint()

        button.MouseEnter:Connect(function()
            if not state then
                box.BackgroundColor3 = HOVER
            end
        end)

        button.MouseLeave:Connect(paint)

        button.MouseButton1Click:Connect(function()
            state = not state
            paint()

            if callback then
                callback(state)
            end
        end)

        return function(value)
            state = value
            paint()
        end
    end

    local function slider(parent, title, y, min, max, step, initial, callback)
        create("TextLabel", {
            Size = UDim2.new(1, -80, 0, 14),
            Position = UDim2.new(0, 8, 0, y),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = TEXT,
            Font = FONT,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left
        }, parent)

        local valueLabel = create("TextLabel", {
            Size = UDim2.new(0, 64, 0, 14),
            Position = UDim2.new(1, -72, 0, y),
            BackgroundTransparency = 1,
            Text = "",
            TextColor3 = ACCENT,
            Font = FONT,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Right
        }, parent)

        local track = create("Frame", {
            Size = UDim2.new(1, -16, 0, 4),
            Position = UDim2.new(0, 8, 0, y + 20),
            BackgroundColor3 = DARK,
            BorderSizePixel = 0
        }, parent)

        create("UIStroke", {
            Color = INLINE,
            Thickness = 1
        }, track)

        local fill = create("Frame", {
            Size = UDim2.new(0, 0, 1, 0),
            BackgroundColor3 = ACCENT,
            BorderSizePixel = 0
        }, track)

        local knob = create("Frame", {
            Size = UDim2.new(0, 8, 0, 8),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = TEXT,
            BorderSizePixel = 0,
            ZIndex = 2
        }, track)

        local value = initial

        local function format(v)
            if step >= 1 then
                return tostring(math.floor(v + 0.5))
            end

            return string.format("%.1f", v)
        end

        local function setValue(v, fire)
            v = math.clamp(v, min, max)

            if step > 0 then
                v = math.floor((v - min) / step + 0.5) * step + min
                v = math.clamp(v, min, max)
            end

            value = v

            local alpha = max > min and (v - min) / (max - min) or 0
            fill.Size = UDim2.new(alpha, 0, 1, 0)
            knob.Position = UDim2.new(alpha, 0, 0.5, 0)
            valueLabel.Text = format(v)

            if fire and callback then
                callback(v)
            end
        end

        local dragging = false

        local function updateFromInput(input)
            local relative = (input.Position.X - track.AbsolutePosition.X)
                / track.AbsoluteSize.X

            setValue(min + math.clamp(relative, 0, 1) * (max - min), true)
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateFromInput(input)
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if not dragging then
                return
            end

            if input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch then
                updateFromInput(input)
            end
        end)

        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)

        setValue(initial, false)

        return setValue, function()
            return value
        end
    end

    -- MOVEMENT
    local function getHumanoid()
        local character = player.Character

        if not character then
            return nil
        end

        return character:FindFirstChildOfClass("Humanoid")
    end

    local walkSpeed = 16

    local speedSection = section(movementPage, "walkspeed", 0, 92)

    local currentSpeed = getHumanoid()

    if currentSpeed and currentSpeed.WalkSpeed > 0 then
        walkSpeed = currentSpeed.WalkSpeed
    end

    slider(speedSection, "speed", 32, 16, 300, 1, walkSpeed, function(v)
        walkSpeed = v

        local humanoid = getHumanoid()

        if humanoid then
            humanoid.WalkSpeed = v
        end
    end)

    player.CharacterAdded:Connect(function(character)
        local humanoid = character:WaitForChild("Humanoid")

        if humanoid then
            humanoid.WalkSpeed = walkSpeed
        end
    end)

    -- FLY
    local flySpeed = 50
    local flying = false
    local flyConnection = nil
    local flyVelocity = nil
    local flyGyro = nil

    local function stopFly()
        flying = false

        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end

        if flyVelocity then
            flyVelocity:Destroy()
            flyVelocity = nil
        end

        if flyGyro then
            flyGyro:Destroy()
            flyGyro = nil
        end

        local humanoid = getHumanoid()

        if humanoid then
            humanoid.PlatformStand = false
        end
    end

    local function startFly()
        stopFly()

        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")

        if not root then
            return
        end

        local humanoid = character:FindFirstChildOfClass("Humanoid")

        if humanoid then
            humanoid.PlatformStand = true
        end

        flying = true

        local velocity = Instance.new("BodyVelocity")
        velocity.Name = "SLOP_FlyVelocity"
        velocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        velocity.Velocity = Vector3.zero
        velocity.Parent = root

        local gyro = Instance.new("BodyGyro")
        gyro.Name = "SLOP_FlyGyro"
        gyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        gyro.P = 2500
        gyro.D = 250
        gyro.CFrame = root.CFrame
        gyro.Parent = root

        flyVelocity = velocity
        flyGyro = gyro

        flyConnection = RunService.RenderStepped:Connect(function()
            local camera = workspace.CurrentCamera

            if not flying or not camera or not root.Parent then
                return
            end

            local direction = Vector3.zero

            if UIS:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + camera.CFrame.LookVector
            end

            if UIS:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - camera.CFrame.LookVector
            end

            if UIS:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + camera.CFrame.RightVector
            end

            if UIS:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - camera.CFrame.RightVector
            end

            if UIS:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end

            if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then
                direction = direction - Vector3.new(0, 1, 0)
            end

            if direction.Magnitude > 0 then
                direction = direction.Unit * flySpeed
            end

            velocity.Velocity = direction
            gyro.CFrame = camera.CFrame
        end)
    end

    local flySection = section(movementPage, "fly", 100, 116)

    local setFlyToggle = toggle(flySection, "enable fly", 36, false, function(on)
        if on then
            startFly()
        else
            stopFly()
        end
    end)

    slider(flySection, "fly speed", 66, 10, 300, 1, flySpeed, function(v)
        flySpeed = v
    end)

    player.CharacterAdded:Connect(function()
        stopFly()

        if setFlyToggle then
            setFlyToggle(false)
        end
    end)

    gui.Destroying:Connect(function()
        stopFly()
    end)

    local flyNote = section(movementPage, "fly controls", 224, 50)

    create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 14),
        Position = UDim2.new(0, 8, 0, 33),
        BackgroundTransparency = 1,
        Text = "WASD move // space up // left ctrl down",
        TextColor3 = TEXT_OFF,
        Font = FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    }, flyNote)

    -- TELEPORTS
    local locations = section(teleportPage, "locations", 0, 164)

    local function teleportTo(cf)
        local character = player.Character or player.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart")
        root.CFrame = cf
    end

    local function teleportRow(name, y, cf)
        row(locations, name, y, function(arrow)
            teleportTo(cf)
            arrow.TextColor3 = GOOD

            task.delay(0.4, function()
                if arrow.Parent then
                    arrow.TextColor3 = ACCENT
                end
            end)
        end)
    end

    -- LOCATIONS (+5 STUDS)
    teleportRow("TP TO CRIMINALS TABLE", 34, CFrame.new(
        -935.622314, 98.728363, 2035.10559,
        -1.1920929e-07, 0, 1.00000012,
        0, 1, 0,
        -1.00000012, 0, -1.1920929e-07
    ))

    teleportRow("TP TO DINNER", 66, CFrame.new(
        915.549622, 100.9899597, 2294.04639,
        0, 0, 1,
        0, 1, 0,
        -1, 0, 0
    ))

    teleportRow("TP TO POLICE LOCKER", 98, CFrame.new(
        828.749756, 100.9766693, 2241.35938,
        1, 0, 0,
        0, 1, 0,
        0, 0, 1
    ))

    teleportRow("TP TO YARD", 130, CFrame.new(
        777.250305, 100.0900116, 2511.6001,
        1, 0, 0,
        0, 1, 0,
        0, 0, 1
    ))

    local note = section(teleportPage, "note", 172, 50)

    create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 14),
        Position = UDim2.new(0, 8, 0, 33),
        BackgroundTransparency = 1,
        Text = "don't tp while protected - you will die",
        TextColor3 = TEXT_OFF,
        Font = FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    }, note)

    -- INFO
    local about = section(infoPage, "about", 0, 96)

    create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 60),
        Position = UDim2.new(0, 8, 0, 34),
        BackgroundTransparency = 1,
        Text = "SLOP hub // prison life\nmovement, teleports, doors, fences and game list\nakiri style ui",
        TextColor3 = TEXT_OFF,
        Font = FONT,
        TextSize = 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    }, about)

    local keys = section(infoPage, "keys", 104, 58)

    create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 20),
        Position = UDim2.new(0, 8, 0, 34),
        BackgroundTransparency = 1,
        Text = "LeftAlt / RightShift - hide / show menu",
        TextColor3 = TEXT_OFF,
        Font = FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    }, keys)

    -- DOORS
    local doorsSection = section(doorsPage, "doors", 0, 116)

    local doorsStatus = create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 36),
        Position = UDim2.new(0, 8, 0, 68),
        BackgroundTransparency = 1,
        Text = "doors are solid",
        TextColor3 = TEXT_OFF,
        Font = FONT,
        TextSize = 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    }, doorsSection)

    -- DOORS ON/OFF SYSTEM
    local doorsStorage = ReplicatedStorage:FindFirstChild("LocalDoorsStorage")

    if not doorsStorage then
        doorsStorage = Instance.new("Folder")
        doorsStorage.Name = "LocalDoorsStorage"
        doorsStorage.Parent = ReplicatedStorage
    end

    local savedDoors = nil
    local setDoorsToggle

    setDoorsToggle = toggle(doorsSection, "disable doors", 36, false, function(on)
        if on then
            local doors = workspace:FindFirstChild("Doors")

            if not doors then
                doorsStatus.Text = "workspace.Doors not found"
                doorsStatus.TextColor3 = WARN
                setDoorsToggle(false)
                return
            end

            savedDoors = doors
            doors.Parent = doorsStorage
            doorsStatus.Text = "doors deleted"
            doorsStatus.TextColor3 = GOOD
        else
            if savedDoors and savedDoors.Parent == doorsStorage then
                savedDoors.Parent = workspace
                savedDoors = nil
                doorsStatus.Text = "doors restored"
                doorsStatus.TextColor3 = TEXT_OFF
            else
                doorsStatus.Text = "saved doors not found"
                doorsStatus.TextColor3 = WARN
                setDoorsToggle(true)
            end
        end
    end)

    -- FENCES
    local fencesSection = section(doorsPage, "fences", 124, 116)

    local fencesStatus = create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 36),
        Position = UDim2.new(0, 8, 0, 68),
        BackgroundTransparency = 1,
        Text = "fences are solid",
        TextColor3 = TEXT_OFF,
        Font = FONT,
        TextSize = 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    }, fencesSection)

    local savedFences = nil
    local savedFencesParent = nil
    local setFencesToggle

    setFencesToggle = toggle(fencesSection, "delete fences", 36, false, function(on)
        if on then
            local fences = workspace:FindFirstChild("Prison_Fences", true)

            if not fences then
                fencesStatus.Text = "workspace.Prison_Fences not found"
                fencesStatus.TextColor3 = WARN
                setFencesToggle(false)
                return
            end

            savedFences = fences
            savedFencesParent = fences.Parent
            fences.Parent = doorsStorage
            fencesStatus.Text = "fences deleted"
            fencesStatus.TextColor3 = GOOD
        else
            if savedFences and savedFences.Parent == doorsStorage then
                savedFences.Parent = savedFencesParent or workspace
                savedFences = nil
                savedFencesParent = nil
                fencesStatus.Text = "fences restored"
                fencesStatus.TextColor3 = TEXT_OFF
            else
                fencesStatus.Text = "saved fences not found"
                fencesStatus.TextColor3 = WARN
                setFencesToggle(true)
            end
        end
    end)

    -- GAMES LIST
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = "GAMES LIST",
        TextColor3 = YELLOW,
        Font = FONT,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    }, gamesPage)

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = "pick a game and press JOIN",
        TextColor3 = TEXT_OFF,
        Font = FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    }, gamesPage)

    buildGamesList(gamesPage, 42)

    -- DRAGGING
    local dragging = false
    local dragStart
    local startPosition

    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = main.Position
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            local delta = input.Position - dragStart

            main.Position = UDim2.new(
                startPosition.X.Scale,
                startPosition.X.Offset + delta.X,
                startPosition.Y.Scale,
                startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UIS.InputBegan:Connect(function(input, processed)
        if processed then
            return
        end

        if input.KeyCode == Enum.KeyCode.RightShift
        or input.KeyCode == Enum.KeyCode.LeftAlt then
            main.Visible = not main.Visible
        end
    end)

    -- AKIRI LOADER
    local loaderGui = create("ScreenGui", {
        Name = "SLOP_Loader",
        ResetOnSpawn = false,
        DisplayOrder = 10
    }, playerGui)

    local loader = create("Frame", {
        Size = UDim2.new(0, 300, 0, 250),
        Position = UDim2.new(0.5, -150, 0.5, -125),
        BackgroundColor3 = OUTLINE,
        BorderSizePixel = 0
    }, loaderGui)

    create("UIStroke", {
        Color = ACCENT,
        Thickness = 1
    }, loader)

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 88),
        BackgroundTransparency = 1,
        Text = "SLOP",
        TextColor3 = TEXT,
        Font = FONT,
        TextSize = 24
    }, loader)

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0, 122),
        BackgroundTransparency = 1,
        Text = "hub // prison life",
        TextColor3 = TEXT_OFF,
        Font = FONT,
        TextSize = 10
    }, loader)

    local track = create("Frame", {
        Size = UDim2.new(0, 200, 0, 4),
        Position = UDim2.new(0.5, -100, 0, 168),
        BackgroundColor3 = LIGHT,
        BorderSizePixel = 0
    }, loader)

    local fill = create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = ACCENT,
        BorderSizePixel = 0
    }, track)

    task.delay(0.1, function()
        tween(fill, {
            Size = UDim2.new(1, 0, 1, 0)
        }, 0.9)
    end)

    local function fadeAway(obj)
        if obj:IsA("TextLabel") then
            tween(obj, {
                TextTransparency = 1,
                BackgroundTransparency = 1
            }, 0.25)
        elseif obj:IsA("Frame") then
            tween(obj, {
                BackgroundTransparency = 1
            }, 0.25)
        elseif obj:IsA("UIStroke") then
            tween(obj, {
                Transparency = 1
            }, 0.25)
        end
    end

    task.delay(1.15, function()
        for _, obj in pairs(loaderGui:GetDescendants()) do
            fadeAway(obj)
        end

        fadeAway(loader)

        task.delay(0.3, function()
            loaderGui:Destroy()
        end)
    end)

    return
end

-- =========================================================
-- STEAL EGGS FROM TSUNAMI
-- =========================================================

if game.PlaceId == EGG_PLACE then
    local C = AKIRI
    local ui = createAkiriWindow("steal eggs from tsunami")
    local create = ui.create
    local gui = ui.gui

    local teleportPage = ui.page("TELEPORTS")
    local eggsPage = ui.page("EGGS")
    local trailsPage = ui.page("TRAILS")
    local howToPage = ui.page("HOW TO USE")
    local gamesPage = ui.page("GAMES LIST")

    ui.tab("TELEPORTS", 1)
    ui.tab("EGGS", 2)
    ui.tab("TRAILS", 3)
    ui.tab("HOW TO USE", 4)

    local gamesTab = ui.tab("GAMES LIST", 0, true)
    gamesTab.button.AnchorPoint = Vector2.new(0, 1)
    gamesTab.button.Position = UDim2.new(0, 4, 1, -6)
    gamesTab.bar.Visible = false

    ui.open("TELEPORTS")

    local function teleportTo(cf)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")

        if root then
            root.CFrame = cf
        end
    end

    -- TELEPORTS
    local locations = ui.section(teleportPage, "locations", 0, 130)

    local function teleportRow(name, y, cf)
        ui.row(locations, name, y, function(arrow)
            teleportTo(cf)
            arrow.TextColor3 = C.GOOD

            task.delay(0.4, function()
                if arrow.Parent then
                    arrow.TextColor3 = C.ACCENT
                end
            end)
        end)
    end

    teleportRow("TP TO BASE", 34, CFrame.new(
        449.52002, 72.0762939, -364.095123
    ))

    teleportRow("TP TO ENCHANTED FOREST", 66, CFrame.new(
        7224.00342, 72.6004028, -365
    ))

    teleportRow("TP TO CORAL REEF", 98, CFrame.new(
        752, 72.5999985, -1264
    ))

    local note = ui.section(teleportPage, "note", 138, 50)

    create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 14),
        Position = UDim2.new(0, 8, 0, 33),
        BackgroundTransparency = 1,
        Text = "hold E on an egg, then tp right before the bar fills",
        TextColor3 = C.TEXT_OFF,
        Font = C.FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    }, note)

    -- EGGS
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = "EGGS",
        TextColor3 = C.ACCENT,
        Font = C.FONT,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    }, eggsPage)

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = "tp to nests // auto refresh 1s",
        TextColor3 = C.TEXT_OFF,
        Font = C.FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    }, eggsPage)

    local eggList = ui.scrollList(eggsPage, 38)

    local eggEmpty = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Text = "no eggs found",
        TextColor3 = C.TEXT_OFF,
        Font = C.FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        LayoutOrder = 0
    }, eggList)

    local lastEggSignature = nil

    local function loadEggs()
        local folder = workspace:FindFirstChild("NestEggs")
        local models = {}

        if folder then
            for _, object in ipairs(folder:GetChildren()) do
                if object:IsA("Model") then
                    table.insert(models, object)
                end
            end
        end

        table.sort(models, function(a, b)
            return a.Name:lower() < b.Name:lower()
        end)

        local signature = {}

        for _, model in ipairs(models) do
            table.insert(signature, model.Name)
        end

        signature = table.concat(signature, "\0")

        if signature == lastEggSignature then
            return
        end

        lastEggSignature = signature

        for _, child in ipairs(eggList:GetChildren()) do
            if child:IsA("GuiObject") and child ~= eggEmpty then
                child:Destroy()
            end
        end

        if #models == 0 then
            eggEmpty.Visible = true
            eggEmpty.Text = folder and "no eggs found" or "folder NestEggs not found"
            return
        end

        eggEmpty.Visible = false

        for index, model in ipairs(models) do
            ui.listRow(eggList, "TP TO " .. string.upper(model.Name), index, function(arrow)
                if not model:IsDescendantOf(workspace) then
                    return
                end

                local part = model:FindFirstChildWhichIsA("BasePart", true)

                if part then
                    teleportTo(part.CFrame + Vector3.new(0, 5, 0))
                    arrow.TextColor3 = C.GOOD

                    task.delay(0.4, function()
                        if arrow.Parent then
                            arrow.TextColor3 = C.ACCENT
                        end
                    end)
                end
            end)
        end
    end

    task.spawn(function()
        while gui.Parent do
            loadEggs()
            task.wait(1)
        end
    end)

    -- TRAILS
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = "TRAILS",
        TextColor3 = C.ACCENT,
        Font = C.FONT,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    }, trailsPage)

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = "trails, boards and pen // straight to server",
        TextColor3 = C.TEXT_OFF,
        Font = C.FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    }, trailsPage)

    local trailsList = ui.scrollList(trailsPage, 38)

    local trails = {
        {"Green Trail", "Green"},
        {"Cyan Trail", "Cyan"},
        {"Purple Trail", "Purple"},
        {"Golden Trail", "Golden"},
        {"Red Trail", "Red"},
        {"Galaxy Trail", "Galaxy"},
        {"Pink Trail", "Pink"},
        {"Shadow Trail", "Shadow"},
        {"Angel Trail", "Angel"},
        {"Rainbow Trail", "Rainbow"},
        {"Divine Trail", "Divine"},
        {"Emerald Trail", "Emerald"},
        {"Ocean Trail", "Ocean"},
        {"Inferno Trail", "Inferno"},
        {"Frost Trail", "Frost"},
        {"Toxic Trail", "Toxic"},
        {"Sakura Trail", "Sakura"},
        {"Cyber Trail", "Cyber"},
        {"Solar Trail", "Solar"},
        {"Void Trail", "Void"},
        {"Celestial Trail", "Celestial"}
    }

    local surfboards = {
        {"Driftwood Board", "Driftwood"},
        {"Coral Board", "Coral"},
        {"Storm Board", "Storm"},
        {"Abyssal Board", "Abyssal"},
        {"Tsunami Board", "Tsunami"}
    }

    local trailRemote = ReplicatedStorage:WaitForChild("TrailAction", 10)
    local updateFolder = ReplicatedStorage:WaitForChild("Update", 10)
    local updateRemote = updateFolder and updateFolder:WaitForChild("UpdateNet", 10)

    local function flashArrow(arrow, good)
        arrow.TextColor3 = good and C.GOOD or C.WARN

        task.delay(0.6, function()
            if arrow.Parent then
                arrow.TextColor3 = C.ACCENT
            end
        end)
    end

    local order = 0

    local function groupLabel(text)
        order += 1

        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 16),
            BackgroundTransparency = 1,
            Text = text,
            TextColor3 = C.TEXT,
            Font = C.FONT,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = order
        }, trailsList)
    end

    groupLabel("trails")

    for _, trail in ipairs(trails) do
        order += 1

        ui.listRow(trailsList, trail[1], order, function(arrow)
            if not trailRemote or not trailRemote:IsA("RemoteEvent") then
                flashArrow(arrow, false)
                return
            end

            trailRemote:FireServer("Buy", trail[2])
            flashArrow(arrow, true)
        end)
    end

    groupLabel("pen")

    order += 1

    ui.listRow(trailsList, "UPGRADE PEN", order, function(arrow)
        local upgradeRemote = ReplicatedStorage:FindFirstChild("UpgradePen")

        if not upgradeRemote or not upgradeRemote:IsA("RemoteEvent") then
            flashArrow(arrow, false)
            return
        end

        upgradeRemote:FireServer({})
        flashArrow(arrow, true)
    end)

    groupLabel("surfboards")

    for _, board in ipairs(surfboards) do
        order += 1

        ui.listRow(trailsList, board[1], order, function(arrow)
            if not updateRemote or not updateRemote:IsA("RemoteEvent") then
                flashArrow(arrow, false)
                return
            end

            updateRemote:FireServer("SurfBuy", board[2])
            flashArrow(arrow, true)
        end)
    end

    -- HOW TO USE
    local howTo = ui.section(howToPage, "how to use", 0, 96)

    create("TextLabel", {
        Size = UDim2.new(1, -16, 0, 56),
        Position = UDim2.new(0, 8, 0, 33),
        BackgroundTransparency = 1,
        Text = "hold E on an egg and press TP TO BASE right before the bar fills.\nbuy trails, boards and the pen upgrade from the TRAILS tab.",
        TextColor3 = C.TEXT_OFF,
        Font = C.FONT,
        TextSize = 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top
    }, howTo)

    -- GAMES LIST
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = "GAMES LIST",
        TextColor3 = YELLOW,
        Font = C.FONT,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    }, gamesPage)

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = "pick a game and press JOIN",
        TextColor3 = C.TEXT_OFF,
        Font = C.FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    }, gamesPage)

    buildGamesList(gamesPage, 40)

    return
end

-- =========================================================
-- CROSS RIVERS FOR ANIMALS
-- =========================================================

if game.PlaceId == RIVERS_PLACE then
    local C = AKIRI
    local ui = createAkiriWindow("cross rivers for animals")
    local create = ui.create
    local gui = ui.gui

    local eggsPage = ui.page("FIELD EGGS")
    local shopPage = ui.page("SHOP")
    local gamesPage = ui.page("GAMES LIST")

    ui.tab("FIELD EGGS", 1)
    ui.tab("SHOP", 2)

    local gamesTab = ui.tab("GAMES LIST", 0, true)
    gamesTab.button.AnchorPoint = Vector2.new(0, 1)
    gamesTab.button.Position = UDim2.new(0, 4, 1, -6)
    gamesTab.bar.Visible = false

    ui.open("FIELD EGGS")

    local function teleportTo(cf)
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")

        if root then
            root.CFrame = cf
        end
    end

    -- FIELD EGGS
    local heading = create("TextLabel", {
        Size = UDim2.new(1, -90, 0, 16),
        BackgroundTransparency = 1,
        Text = "FIELD EGGS",
        TextColor3 = Color3.fromRGB(255, 60, 60),
        Font = C.FONT,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd
    }, eggsPage)

    local refreshButton = create("TextButton", {
        Size = UDim2.fromOffset(76, 22),
        Position = UDim2.new(1, -76, 0, -2),
        BackgroundColor3 = C.DARK,
        Text = "REFRESH",
        TextColor3 = C.TEXT,
        Font = C.FONT,
        TextSize = 10,
        BorderSizePixel = 0,
        AutoButtonColor = false
    }, eggsPage)

    create("UIStroke", {
        Color = C.INLINE,
        Thickness = 1
    }, refreshButton)

    refreshButton.MouseEnter:Connect(function()
        refreshButton.BackgroundColor3 = C.HOVER
    end)

    refreshButton.MouseLeave:Connect(function()
        refreshButton.BackgroundColor3 = C.DARK
    end)

    local eggList = ui.scrollList(eggsPage, 30)

    local function getModels(folder)
        local result = {}

        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("Model") then
                table.insert(result, obj)
            elseif obj:IsA("Folder") then
                for _, model in ipairs(getModels(obj)) do
                    table.insert(result, model)
                end
            end
        end

        table.sort(result, function(a, b)
            return a.Name:lower() < b.Name:lower()
        end)

        return result
    end

    local function clearList()
        for _, child in ipairs(eggList:GetChildren()) do
            if child:IsA("GuiObject") then
                child:Destroy()
            end
        end
    end

    local function createSpawnRow()
        ui.listRow(eggList, "TP TO SPAWN", 0, function(arrow)
            teleportTo(CFrame.new(-48, 5.5, 13.25))
            arrow.TextColor3 = C.GOOD

            task.delay(0.4, function()
                if arrow.Parent then
                    arrow.TextColor3 = C.ACCENT
                end
            end)
        end)
    end

    local function createEggRow(model, order)
        local row = create("Frame", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = C.DARK,
            BorderSizePixel = 0,
            LayoutOrder = order
        }, eggList)

        create("UIStroke", {
            Color = C.INLINE,
            Thickness = 1
        }, row)

        create("TextLabel", {
            Size = UDim2.new(1, -72, 1, 0),
            Position = UDim2.fromOffset(8, 0),
            BackgroundTransparency = 1,
            Text = model.Name,
            TextColor3 = C.TEXT,
            Font = C.FONT,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd
        }, row)

        local tp = create("TextButton", {
            Size = UDim2.fromOffset(52, 18),
            Position = UDim2.new(1, -60, 0.5, -9),
            BackgroundColor3 = C.ACCENT,
            Text = "TP",
            TextColor3 = C.OUTLINE,
            Font = C.FONT,
            TextSize = 10,
            BorderSizePixel = 0,
            AutoButtonColor = false
        }, row)

        tp.MouseButton1Click:Connect(function()
            if not model:IsDescendantOf(workspace) then
                return
            end

            local success, pivot = pcall(function()
                return model:GetPivot()
            end)

            if success then
                teleportTo(pivot + Vector3.new(0, 5, 0))
            end
        end)
    end

    local expanded = {}
    local lastSignature = nil

    local function collectFolders()
        local fieldEggs = workspace:FindFirstChild("FieldEggs")

        if not fieldEggs then
            return nil
        end

        local folders = {}

        for _, obj in ipairs(fieldEggs:GetChildren()) do
            if obj:IsA("Folder") then
                table.insert(folders, obj)
            end
        end

        table.sort(folders, function(a, b)
            return a.Name:lower() < b.Name:lower()
        end)

        local entries = {}
        local signature = {}

        for _, folder in ipairs(folders) do
            local models = getModels(folder)

            table.insert(entries, {
                folder = folder,
                models = models
            })

            table.insert(signature, folder.Name)

            for _, model in ipairs(models) do
                table.insert(signature, model.Name)
            end
        end

        return entries, table.concat(signature, "\0")
    end

    local function refresh(force)
        local entries, signature = collectFolders()

        if not entries then
            if lastSignature ~= "<missing>" then
                lastSignature = "<missing>"
                clearList()
                createSpawnRow()
                heading.Text = "FIELD EGGS NOT FOUND"
            end

            return
        end

        if not force and signature == lastSignature then
            return
        end

        lastSignature = signature
        clearList()
        createSpawnRow()
        heading.Text = "FIELD EGGS"

        local order = 0

        for _, entry in ipairs(entries) do
            local folder = entry.folder
            local models = entry.models

            order += 1

            local category = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundColor3 = C.LIGHT,
                Text = "",
                BorderSizePixel = 0,
                AutoButtonColor = false,
                LayoutOrder = order
            }, eggList)

            create("UIStroke", {
                Color = C.INLINE,
                Thickness = 1
            }, category)

            local isOpen = expanded[folder.Name]

            create("TextLabel", {
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.fromOffset(8, 0),
                BackgroundTransparency = 1,
                Text = (isOpen and "v  " or ">  ") .. folder.Name .. "  (" .. #models .. ")",
                TextColor3 = C.TEXT,
                Font = C.FONT,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd
            }, category)

            category.MouseButton1Click:Connect(function()
                expanded[folder.Name] = not expanded[folder.Name]
                refresh(true)
            end)

            if isOpen then
                for _, model in ipairs(models) do
                    order += 1
                    createEggRow(model, order)
                end
            end
        end

        if #entries == 0 then
            order += 1

            create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 26),
                BackgroundTransparency = 1,
                Text = "no folders in FieldEggs",
                TextColor3 = C.TEXT_OFF,
                Font = C.FONT,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = order
            }, eggList)
        end
    end

    refreshButton.MouseButton1Click:Connect(function()
        refresh(true)
    end)

    refresh(true)

    task.spawn(function()
        while gui.Parent do
            task.wait(1)

            if gui.Parent then
                refresh(false)
            end
        end
    end)

    -- SHOP
    create("TextLabel", {
        Size = UDim2.new(1, -110, 0, 16),
        BackgroundTransparency = 1,
        Text = "SHOP",
        TextColor3 = C.ACCENT,
        Font = C.FONT,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    }, shopPage)

    local shopStatus = create("TextLabel", {
        Size = UDim2.new(0, 190, 0, 16),
        Position = UDim2.new(1, -190, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = C.TEXT_OFF,
        Font = C.FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd
    }, shopPage)

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = "trails // instant buy",
        TextColor3 = C.TEXT_OFF,
        Font = C.FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    }, shopPage)

    local shopList = ui.scrollList(shopPage, 40)

    local shopTrails = {
        {"Grey Trail", "GreyTrail"},
        {"Green Trail", "GreenTrail"},
        {"Blue Trail", "BlueTrail"},
        {"Purple Trail", "PurpleTrail"},
        {"Golden Trail", "GoldenTrail"},
        {"Galaxy Trail", "GalaxyTrail"},
        {"Secret Trail", "SecretTrail"},
        {"Eternal Trail", "EternalTrail"},
        {"Divine Trail", "DivineTrail"}
    }

    local function getBuyRemote()
        local packages = ReplicatedStorage:FindFirstChild("Packages")
        local knit = packages and packages:FindFirstChild("Knit")
        local services = knit and knit:FindFirstChild("Services")
        local trailService = services and services:FindFirstChild("TrailService")
        local rf = trailService and trailService:FindFirstChild("RF")
        local buy = rf and rf:FindFirstChild("Buy")

        if buy and buy:IsA("RemoteFunction") then
            return buy
        end

        return nil
    end

    local shopOpen = false
    local trailRows = {}

    local category = create("TextButton", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = C.LIGHT,
        Text = "",
        BorderSizePixel = 0,
        AutoButtonColor = false,
        LayoutOrder = 0
    }, shopList)

    create("UIStroke", {
        Color = C.INLINE,
        Thickness = 1
    }, category)

    local categoryLabel = create("TextLabel", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.fromOffset(8, 0),
        BackgroundTransparency = 1,
        Text = ">  TRAILS  (" .. #shopTrails .. ")",
        TextColor3 = C.TEXT,
        Font = C.FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    }, category)

    local function paintCategory()
        categoryLabel.Text = (shopOpen and "v  " or ">  ")
            .. "TRAILS  (" .. #shopTrails .. ")"

        for _, row in ipairs(trailRows) do
            row.Visible = shopOpen
        end
    end

    for index, trail in ipairs(shopTrails) do
        local row = create("Frame", {
            Size = UDim2.new(1, -8, 0, 26),
            Position = UDim2.fromOffset(8, 0),
            BackgroundColor3 = C.DARK,
            BorderSizePixel = 0,
            LayoutOrder = index,
            Visible = false
        }, shopList)

        create("UIStroke", {
            Color = C.INLINE,
            Thickness = 1
        }, row)

        create("TextLabel", {
            Size = UDim2.new(1, -66, 1, 0),
            Position = UDim2.fromOffset(8, 0),
            BackgroundTransparency = 1,
            Text = trail[1],
            TextColor3 = C.TEXT,
            Font = C.FONT,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd
        }, row)

        local buy = create("TextButton", {
            Size = UDim2.fromOffset(46, 18),
            Position = UDim2.new(1, -54, 0.5, -9),
            BackgroundColor3 = C.ACCENT,
            Text = "BUY",
            TextColor3 = C.OUTLINE,
            Font = C.FONT,
            TextSize = 10,
            BorderSizePixel = 0,
            AutoButtonColor = false
        }, row)

        buy.MouseButton1Click:Connect(function()
            local remote = getBuyRemote()

            if not remote then
                shopStatus.Text = "trail remote not found"
                shopStatus.TextColor3 = C.WARN
                return
            end

            local ok = pcall(function()
                remote:InvokeServer(trail[2])
            end)

            if ok then
                shopStatus.Text = trail[1] .. " bought"
                shopStatus.TextColor3 = C.GOOD
            else
                shopStatus.Text = "buy failed"
                shopStatus.TextColor3 = C.WARN
            end
        end)

        table.insert(trailRows, row)
    end

    category.MouseButton1Click:Connect(function()
        shopOpen = not shopOpen
        paintCategory()
    end)

    paintCategory()

    -- GAMES LIST
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 16),
        BackgroundTransparency = 1,
        Text = "GAMES LIST",
        TextColor3 = YELLOW,
        Font = C.FONT,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left
    }, gamesPage)

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 18),
        BackgroundTransparency = 1,
        Text = "pick a game and press JOIN",
        TextColor3 = C.TEXT_OFF,
        Font = C.FONT,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    }, gamesPage)

    buildGamesList(gamesPage, 40)
end
