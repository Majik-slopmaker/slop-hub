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
local SCOOTER_PLACE = 107344344488571
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
        PlaceId = SCOOTER_PLACE,
        Name = "Steal A Scooter",
        Icon = "rbxthumb://type=PlaceIcon&id=" .. SCOOTER_PLACE .. "&w=150&h=150"
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
        Text = "RightShift - hide / show menu",
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

        if input.KeyCode == Enum.KeyCode.RightShift then
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
-- STEAL A SCOOTER
-- =========================================================

if game.PlaceId == SCOOTER_PLACE then
    local function create(class, props, parent)
        local obj = Instance.new(class)
        for k, v in pairs(props) do
            obj[k] = v
        end
        obj.Parent = parent
        return obj
    end

    local function corner(parent, radius)
        create("UICorner", {
            CornerRadius = UDim.new(0, radius)
        }, parent)
    end

    local function tween(obj, properties, duration)
        TweenService:Create(
            obj,
            TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            properties
        ):Play()
    end

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
        Size = UDim2.new(0, 560, 0, 350),
        Position = UDim2.new(0.5, -280, 0.5, -175),
        BackgroundColor3 = Color3.fromRGB(15, 16, 21),
        BorderSizePixel = 0,
        Active = true
    }, gui)
    corner(main, 12)

    create("UIStroke", {
        Color = Color3.fromRGB(48, 52, 65),
        Thickness = 1
    }, main)

    -- TOP BAR
    local top = create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Color3.fromRGB(20, 21, 28),
        BorderSizePixel = 0,
        Active = true
    }, main)
    corner(top, 12)

    create("TextLabel", {
        Size = UDim2.new(1, -100, 1, 0),
        Position = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1,
        Text = "SLOP  |  SCOOTER",
        TextColor3 = Color3.fromRGB(240, 242, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Left
    }, top)

    create("TextLabel", {
        Size = UDim2.new(0, 100, 1, 0),
        Position = UDim2.new(1, -140, 0, 0),
        BackgroundTransparency = 1,
        Text = "V2.0",
        TextColor3 = Color3.fromRGB(110, 115, 135),
        Font = Enum.Font.Gotham,
        TextSize = 11
    }, top)

    local close = create("TextButton", {
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -40, 0, 9),
        BackgroundColor3 = Color3.fromRGB(35, 36, 45),
        Text = "×",
        TextColor3 = Color3.fromRGB(255, 100, 110),
        TextSize = 22,
        Font = Enum.Font.GothamBold,
        BorderSizePixel = 0
    }, top)
    corner(close, 7)

    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- SIDEBAR
    local sidebar = create("Frame", {
        Size = UDim2.new(0, 145, 1, -60),
        Position = UDim2.new(0, 10, 0, 55),
        BackgroundColor3 = Color3.fromRGB(20, 21, 28),
        BorderSizePixel = 0
    }, main)
    corner(sidebar, 9)

    create("TextLabel", {
        Size = UDim2.new(1, -20, 0, 25),
        Position = UDim2.new(0, 10, 0, 10),
        BackgroundTransparency = 1,
        Text = "MENU",
        TextColor3 = Color3.fromRGB(105, 110, 130),
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left
    }, sidebar)

    -- CONTENT
    local content = create("Frame", {
        Size = UDim2.new(1, -175, 1, -65),
        Position = UDim2.new(0, 165, 0, 55),
        BackgroundTransparency = 1
    }, main)

    -- PAGE SYSTEM
    local pages = {}
    local tabs = {}

    local function createPage(name)
        local page = create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false
        }, content)

        pages[name] = page
        return page
    end

    local teleportPage = createPage("Teleport")
    local howToPage = createPage("HOW TO USE")

    local function switchPage(name)
        for pageName, page in pairs(pages) do
            page.Visible = pageName == name
        end

        for tabName, tab in pairs(tabs) do
            if tabName ~= "GAMES LIST" then
                tween(tab, {
                    BackgroundColor3 = tabName == name
                        and Color3.fromRGB(65, 68, 100)
                        or Color3.fromRGB(29, 31, 41)
                })

                tab.TextColor3 = tabName == name
                    and Color3.fromRGB(240, 242, 255)
                    or Color3.fromRGB(170, 175, 195)
            end
        end
    end

    -- TABS
    local function createTab(name, position)
        local tab = create("TextButton", {
            Size = UDim2.new(1, -16, 0, 38),
            Position = UDim2.new(0, 8, 0, position),
            BackgroundColor3 = Color3.fromRGB(29, 31, 41),
            Text = name,
            TextColor3 = Color3.fromRGB(170, 175, 195),
            Font = Enum.Font.GothamSemibold,
            TextSize = 12,
            BorderSizePixel = 0,
            AutoButtonColor = false
        }, sidebar)
        corner(tab, 7)

        tab.MouseButton1Click:Connect(function()
            switchPage(name)
        end)

        tabs[name] = tab
        return tab
    end

    createTab("Teleport", 42)
    createTab("HOW TO USE", 88)

    -- GAMES LIST TAB - zolty, na samym dole
    local gamesPage = createPage("GAMES LIST")

    local gamesTab = create("TextButton", {
        Name = "GamesTab",
        AnchorPoint = Vector2.new(0, 1),
        Size = UDim2.new(1, -16, 0, 40),
        Position = UDim2.new(0, 8, 1, -8),
        BackgroundColor3 = YELLOW,
        Text = "GAMES LIST",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        BorderSizePixel = 0,
        AutoButtonColor = false
    }, sidebar)
    corner(gamesTab, 7)

    tabs["GAMES LIST"] = gamesTab

    gamesTab.MouseButton1Click:Connect(function()
        switchPage("GAMES LIST")
    end)

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        Text = "GAMES LIST",
        TextColor3 = YELLOW,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    }, gamesPage)

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = "Pick a game and press JOIN",
        TextColor3 = Color3.fromRGB(115, 120, 140),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    }, gamesPage)

    buildGamesList(gamesPage, 58)

    -- TELEPORT PAGE
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 35),
        BackgroundTransparency = 1,
        Text = "TELEPORT LOCATIONS",
        TextColor3 = Color3.fromRGB(240, 242, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left
    }, teleportPage)

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = 1,
        Text = "Select a location to teleport",
        TextColor3 = Color3.fromRGB(115, 120, 140),
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left
    }, teleportPage)

    -- TELEPORT FUNCTION
    local function teleportTo(cf)
        local character = player.Character or player.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart")
        root.CFrame = cf
    end

    -- BUTTON CREATOR
    local function createTeleportButton(name, y, cf)
        local button = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 48),
            Position = UDim2.new(0, 0, 0, y),
            BackgroundColor3 = Color3.fromRGB(27, 29, 39),
            Text = "",
            BorderSizePixel = 0,
            AutoButtonColor = false
        }, teleportPage)
        corner(button, 8)

        create("UIStroke", {
            Color = Color3.fromRGB(47, 51, 66),
            Thickness = 1
        }, button)

        create("TextLabel", {
            Size = UDim2.new(1, -45, 1, 0),
            Position = UDim2.new(0, 14, 0, 0),
            BackgroundTransparency = 1,
            Text = name,
            TextColor3 = Color3.fromRGB(225, 228, 242),
            Font = Enum.Font.GothamSemibold,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left
        }, button)

        local arrow = create("TextLabel", {
            Size = UDim2.new(0, 30, 1, 0),
            Position = UDim2.new(1, -35, 0, 0),
            BackgroundTransparency = 1,
            Text = "→",
            TextColor3 = Color3.fromRGB(120, 130, 255),
            Font = Enum.Font.GothamBold,
            TextSize = 19
        }, button)

        button.MouseEnter:Connect(function()
            tween(button, {
                BackgroundColor3 = Color3.fromRGB(42, 45, 62)
            })
        end)

        button.MouseLeave:Connect(function()
            tween(button, {
                BackgroundColor3 = Color3.fromRGB(27, 29, 39)
            })
        end)

        button.MouseButton1Click:Connect(function()
            teleportTo(cf)

            tween(arrow, {
                TextColor3 = Color3.fromRGB(100, 255, 160)
            })

            task.delay(0.4, function()
                if arrow.Parent then
                    tween(arrow, {
                        TextColor3 = Color3.fromRGB(120, 130, 255)
                    })
                end
            end)
        end)
    end

    -- TP LOCATIONS (+5 STUDS)

    -- BASE
    createTeleportButton("TP TO BASE", 70, CFrame.new(
        457.933502, 72.676178, -364.436005,
        1, 0, 0,
        0, 1, 0,
        0, 0, 1
    ))

    -- END
    createTeleportButton("TP TO END", 128, CFrame.new(
        10852, 72.5999985, -364,
        1, 0, 0,
        0, 1, 0,
        0, 0, 1
    ))

    -- HOW TO USE PAGE
    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 55),
        BackgroundTransparency = 1,
        Text = "HOW TO USE",
        TextColor3 = Color3.fromRGB(255, 45, 45),
        Font = Enum.Font.GothamBlack,
        TextSize = 30,
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left
    }, howToPage)

    create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 170),
        Position = UDim2.new(0, 0, 0, 70),
        BackgroundTransparency = 1,
        Text = "To easily drop off what u are holding, click TP TO BASE right before u finish the hold.\n\nUse TP TO END to get to the far end of the map without running.\n\nDon't tp while u are protected cause u will die.",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.Gotham,
        TextSize = 15,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Top
    }, howToPage)

    switchPage("Teleport")

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

    return
end

-- =========================================================
-- STEAL EGGS FROM TSUNAMI
-- =========================================================

if game.PlaceId == EGG_PLACE then
-- REMOVE OLD GUI
local old = playerGui:FindFirstChild("SLOP")
if old then
    old:Destroy()
end

-- SCREEN GUI
local gui = Instance.new("ScreenGui")
gui.Name = "SLOP"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local function tween(obj, duration, props)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

-- MAIN WINDOW
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(530, 380)
main.Position = UDim2.new(0.5, -265, 0.5, -190)
main.BackgroundColor3 = Color3.fromRGB(17, 18, 25)
main.BorderSizePixel = 0
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 75, 210)
stroke.Thickness = 1.5
stroke.Parent = main

-- TOP BAR
local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 48)
top.BackgroundColor3 = Color3.fromRGB(25, 25, 37)
top.BorderSizePixel = 0
top.Parent = main
Instance.new("UICorner", top).CornerRadius = UDim.new(0, 12)

local cover = Instance.new("Frame")
cover.Size = UDim2.new(1, 0, 0, 12)
cover.Position = UDim2.new(0, 0, 1, -12)
cover.BackgroundColor3 = top.BackgroundColor3
cover.BorderSizePixel = 0
cover.Parent = top

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 230, 1, 0)
title.Position = UDim2.fromOffset(16, 0)
title.BackgroundTransparency = 1
title.Text = "SLOP"
title.TextColor3 = Color3.fromRGB(190, 160, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

-- WINDOW BUTTONS
local function windowButton(text, color, x)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(30, 28)
    b.Position = UDim2.new(1, x, 0, 10)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 15
    b.BorderSizePixel = 0
    b.Parent = top
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local minimize = windowButton("-", Color3.fromRGB(65, 65, 90), -76)
local close = windowButton("X", Color3.fromRGB(170, 55, 75), -38)

-- SIDEBAR
local sidebar = Instance.new("Frame")
sidebar.Position = UDim2.fromOffset(0, 48)
sidebar.Size = UDim2.new(0, 145, 1, -48)
sidebar.BackgroundColor3 = Color3.fromRGB(21, 22, 31)
sidebar.BorderSizePixel = 0
sidebar.Parent = main

-- CONTENT
local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(145, 48)
content.Size = UDim2.new(1, -145, 1, -48)
content.BackgroundTransparency = 1
content.Parent = main

-- PAGE SYSTEM
local pages = {}
local tabs = {}

local function createPage(name, order)
    local page = Instance.new("Frame")
    page.Name = name
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = content

    local heading = Instance.new("TextLabel")
    heading.Position = UDim2.fromOffset(22, 17)
    heading.Size = UDim2.new(1, -44, 0, 30)
    heading.BackgroundTransparency = 1
    heading.Text = name
    heading.TextColor3 = Color3.new(1, 1, 1)
    heading.Font = Enum.Font.GothamBold
    heading.TextSize = 21
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.Parent = page

    pages[name] = page

    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(1, -18, 0, 40)
    tab.Position = UDim2.fromOffset(9, 15 + (order - 1) * 49)
    tab.BackgroundColor3 = Color3.fromRGB(40, 38, 57)
    tab.Text = "  " .. string.upper(name)

    if name == "HOW TO USE" then
        tab.TextColor3 = Color3.fromRGB(255, 45, 45)
    else
        tab.TextColor3 = Color3.fromRGB(200, 200, 215)
    end

    tab.Font = Enum.Font.GothamBold
    tab.TextSize = 11
    tab.TextXAlignment = Enum.TextXAlignment.Left
    tab.BorderSizePixel = 0
    tab.Parent = sidebar
    Instance.new("UICorner", tab).CornerRadius = UDim.new(0, 7)

    tabs[name] = tab

    tab.MouseButton1Click:Connect(function()
        for pageName, p in pairs(pages) do
            p.Visible = pageName == name

            if pageName ~= "GAMES LIST" then
                tabs[pageName].TextColor3 =
                    pageName == "HOW TO USE"
                    and Color3.fromRGB(255, 45, 45)
                    or Color3.fromRGB(200, 200, 215)

                tween(tabs[pageName], 0.15, {
                    BackgroundColor3 = pageName == name
                        and Color3.fromRGB(90, 65, 175)
                        or Color3.fromRGB(40, 38, 57)
                })
            end
        end
    end)

    return page
end

local teleportPage = createPage("Teleport", 1)
local eggsPage = createPage("TP TO EGGS", 2)
local autoPage = createPage("AUTO", 3)
local howToPage = createPage("HOW TO USE", 4)

-- GAMES LIST TAB - zolty, na samym dole
local gamesPage = createPage("GAMES LIST", 5)
local gamesTab = tabs["GAMES LIST"]

gamesTab.AnchorPoint = Vector2.new(0, 1)
gamesTab.Position = UDim2.new(0, 9, 1, -12)
gamesTab.BackgroundColor3 = YELLOW
gamesTab.TextColor3 = Color3.new(1, 1, 1)

local gamesHeading = gamesPage:FindFirstChildWhichIsA("TextLabel")
if gamesHeading then
    gamesHeading.TextColor3 = YELLOW
end

buildGamesList(gamesPage, 58)

teleportPage.Visible = true
tabs["Teleport"].BackgroundColor3 = Color3.fromRGB(90, 65, 175)

-- TELEPORT FUNCTION
local function teleportTo(cframe)
    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")

    if root then
        root.CFrame = cframe
    end
end

-- BUTTON CREATOR
local function createButton(parent, text, y)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -44, 0, 48)
    b.Position = UDim2.fromOffset(22, y)
    b.BackgroundColor3 = Color3.fromRGB(40, 38, 57)
    b.Text = text
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    b.Parent = parent

    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(100, 75, 190)
    s.Transparency = 0.55
    s.Parent = b

    b.MouseEnter:Connect(function()
        tween(b, 0.15, {
            BackgroundColor3 = Color3.fromRGB(75, 57, 125)
        })
    end)

    b.MouseLeave:Connect(function()
        tween(b, 0.15, {
            BackgroundColor3 = Color3.fromRGB(40, 38, 57)
        })
    end)

    return b
end

-- TELEPORT PAGE
local description = Instance.new("TextLabel")
description.Position = UDim2.fromOffset(23, 49)
description.Size = UDim2.new(1, -46, 0, 20)
description.BackgroundTransparency = 1
description.Text = "Teleport to your selected location."
description.TextColor3 = Color3.fromRGB(130, 130, 150)
description.Font = Enum.Font.Gotham
description.TextSize = 11
description.TextXAlignment = Enum.TextXAlignment.Left
description.Parent = teleportPage

local baseButton = createButton(teleportPage, "TP TO BASE", 100)
local enchantedButton = createButton(teleportPage, "TP TO ENCHANTED FOREST", 160)
local coralButton = createButton(teleportPage, "TP TO CORAL REEF", 220)

baseButton.MouseButton1Click:Connect(function()
    teleportTo(CFrame.new(449.52002, 72.0762939, -364.095123))
end)

enchantedButton.MouseButton1Click:Connect(function()
    teleportTo(CFrame.new(7224.00342, 72.6004028, -365))
end)

coralButton.MouseButton1Click:Connect(function()
    teleportTo(CFrame.new(752, 72.5999985, -1264))
end)

-- TP TO EGGS PAGE
local eggsDescription = Instance.new("TextLabel")
eggsDescription.Position = UDim2.fromOffset(23, 49)
eggsDescription.Size = UDim2.new(1, -46, 0, 20)
eggsDescription.BackgroundTransparency = 1
eggsDescription.Text = "Select an egg to teleport to it."
eggsDescription.TextColor3 = Color3.fromRGB(130, 130, 150)
eggsDescription.Font = Enum.Font.Gotham
eggsDescription.TextSize = 11
eggsDescription.TextXAlignment = Enum.TextXAlignment.Left
eggsDescription.Parent = eggsPage

local eggList = Instance.new("ScrollingFrame")
eggList.Name = "EggList"
eggList.Position = UDim2.fromOffset(22, 82)
eggList.Size = UDim2.new(1, -44, 1, -100)
eggList.BackgroundColor3 = Color3.fromRGB(23, 23, 34)
eggList.BorderSizePixel = 0
eggList.ScrollBarThickness = 5
eggList.ScrollBarImageColor3 = Color3.fromRGB(130, 95, 220)
eggList.CanvasSize = UDim2.new(0, 0, 0, 0)
eggList.AutomaticCanvasSize = Enum.AutomaticSize.Y
eggList.Parent = eggsPage
Instance.new("UICorner", eggList).CornerRadius = UDim.new(0, 8)

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = eggList

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = eggList

local emptyLabel = Instance.new("TextLabel")
emptyLabel.Size = UDim2.new(1, -20, 0, 40)
emptyLabel.BackgroundTransparency = 1
emptyLabel.Text = "No eggs found!"
emptyLabel.TextColor3 = Color3.fromRGB(140, 140, 160)
emptyLabel.Font = Enum.Font.Gotham
emptyLabel.TextSize = 13
emptyLabel.LayoutOrder = 0
emptyLabel.Parent = eggList

-- LOAD EGGS
local lastSignature = nil

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
        return a.Name < b.Name
    end)

    local names = {}
    for _, model in ipairs(models) do
        table.insert(names, model.Name)
    end

    local signature = table.concat(names, "\0")

    if signature == lastSignature then
        return
    end

    lastSignature = signature

    for _, child in ipairs(eggList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    if #models == 0 then
        emptyLabel.Visible = true
        emptyLabel.Text = folder and "No eggs found!" or "Folder NestEggs not found!"
        return
    end

    emptyLabel.Visible = false

    for index, model in ipairs(models) do
        local button = createButton(
            eggList,
            "TP TO " .. string.upper(model.Name),
            0
        )

        button.Name = "Egg_" .. model.Name
        button.LayoutOrder = index

        button.MouseButton1Click:Connect(function()
            if not model:IsDescendantOf(workspace) then
                return
            end

            local part = model:FindFirstChildWhichIsA("BasePart", true)

            if part then
                teleportTo(part.CFrame + Vector3.new(0, 5, 0))
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

-- AUTO PAGE SCROLLING
local autoScroll = Instance.new("ScrollingFrame")
autoScroll.Name = "AutoScroll"
autoScroll.Position = UDim2.fromOffset(0, 48)
autoScroll.Size = UDim2.new(1, 0, 1, -48)
autoScroll.BackgroundTransparency = 1
autoScroll.BorderSizePixel = 0
autoScroll.ScrollBarThickness = 5
autoScroll.ScrollBarImageColor3 = Color3.fromRGB(130, 95, 220)
autoScroll.CanvasSize = UDim2.new(0, 0, 0, 510)
autoScroll.ScrollingDirection = Enum.ScrollingDirection.Y
autoScroll.Parent = autoPage

local autoContent = Instance.new("Frame")
autoContent.Name = "AutoContent"
autoContent.Size = UDim2.new(1, -5, 0, 510)
autoContent.BackgroundTransparency = 1
autoContent.Parent = autoScroll

-- DROPDOWN CREATOR
local function createDropdown(sectionName, buttonText, y, options, onSelect, listHeight)
    local sectionTitle = Instance.new("TextLabel")
    sectionTitle.Name = sectionName .. "Title"
    sectionTitle.Position = UDim2.fromOffset(22, y)
    sectionTitle.Size = UDim2.new(1, -44, 0, 25)
    sectionTitle.BackgroundTransparency = 1
    sectionTitle.Text = sectionName
    sectionTitle.TextColor3 = Color3.fromRGB(190, 160, 255)
    sectionTitle.Font = Enum.Font.GothamBold
    sectionTitle.TextSize = 16
    sectionTitle.TextXAlignment = Enum.TextXAlignment.Left
    sectionTitle.ZIndex = 2
    sectionTitle.Parent = autoContent

    local dropdownButton = Instance.new("TextButton")
    dropdownButton.Name = buttonText .. "Dropdown"
    dropdownButton.Position = UDim2.fromOffset(22, y + 34)
    dropdownButton.Size = UDim2.new(1, -44, 0, 42)
    dropdownButton.BackgroundColor3 = Color3.fromRGB(40, 38, 57)
    dropdownButton.Text = "SELECT " .. buttonText .. "                         ▼"
    dropdownButton.TextColor3 = Color3.new(1, 1, 1)
    dropdownButton.Font = Enum.Font.GothamBold
    dropdownButton.TextSize = 13
    dropdownButton.BorderSizePixel = 0
    dropdownButton.AutoButtonColor = false
    dropdownButton.ZIndex = 3
    dropdownButton.Parent = autoContent
    Instance.new("UICorner", dropdownButton).CornerRadius = UDim.new(0, 8)

    local dropdownStroke = Instance.new("UIStroke")
    dropdownStroke.Color = Color3.fromRGB(100, 75, 190)
    dropdownStroke.Transparency = 0.55
    dropdownStroke.Parent = dropdownButton

    local list = Instance.new("ScrollingFrame")
    list.Name = buttonText .. "List"
    list.Position = UDim2.fromOffset(22, y + 82)
    list.Size = UDim2.new(1, -44, 0, 0)
    list.BackgroundColor3 = Color3.fromRGB(23, 23, 34)
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 5
    list.ScrollBarImageColor3 = Color3.fromRGB(130, 95, 220)
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.Visible = false
    list.ClipsDescendants = true
    list.ZIndex = 10
    list.Parent = autoContent
    Instance.new("UICorner", list).CornerRadius = UDim.new(0, 8)

    local listPadding = Instance.new("UIPadding")
    listPadding.PaddingTop = UDim.new(0, 8)
    listPadding.PaddingBottom = UDim.new(0, 8)
    listPadding.PaddingLeft = UDim.new(0, 8)
    listPadding.PaddingRight = UDim.new(0, 8)
    listPadding.Parent = list

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = list

    local isOpen = false
    local selectedName = nil

    for index, option in ipairs(options) do
        local displayName = option[1]
        local remoteName = option[2]

        local optionButton = Instance.new("TextButton")
        optionButton.Name = remoteName .. "Button"
        optionButton.Size = UDim2.new(1, -4, 0, 36)
        optionButton.BackgroundColor3 = Color3.fromRGB(40, 38, 57)
        optionButton.Text = displayName
        optionButton.TextColor3 = Color3.fromRGB(220, 220, 230)
        optionButton.Font = Enum.Font.GothamBold
        optionButton.TextSize = 12
        optionButton.BorderSizePixel = 0
        optionButton.LayoutOrder = index
        optionButton.AutoButtonColor = false
        optionButton.ZIndex = 11
        optionButton.Parent = list
        Instance.new("UICorner", optionButton).CornerRadius = UDim.new(0, 6)

        optionButton.MouseEnter:Connect(function()
            tween(optionButton, 0.12, {
                BackgroundColor3 = Color3.fromRGB(75, 57, 125)
            })
        end)

        optionButton.MouseLeave:Connect(function()
            tween(optionButton, 0.12, {
                BackgroundColor3 = Color3.fromRGB(40, 38, 57)
            })
        end)

        optionButton.MouseButton1Click:Connect(function()
            onSelect(remoteName)
            selectedName = displayName
            dropdownButton.Text = displayName .. "                         ▼"
            isOpen = false
            list.Visible = false
            list.Size = UDim2.new(1, -44, 0, 0)
        end)
    end

    dropdownButton.MouseEnter:Connect(function()
        tween(dropdownButton, 0.12, {
            BackgroundColor3 = Color3.fromRGB(75, 57, 125)
        })
    end)

    dropdownButton.MouseLeave:Connect(function()
        if not isOpen then
            tween(dropdownButton, 0.12, {
                BackgroundColor3 = Color3.fromRGB(40, 38, 57)
            })
        end
    end)

    dropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen

        if isOpen then
            list.Visible = true
            dropdownButton.Text = "SELECT " .. buttonText .. "                         ▲"

            tween(list, 0.2, {
                Size = UDim2.new(1, -44, 0, listHeight)
            })
        else
            dropdownButton.Text =
                (selectedName or ("SELECT " .. buttonText)) .. "                         ▼"

            tween(list, 0.2, {
                Size = UDim2.new(1, -44, 0, 0)
            })

            task.wait(0.2)

            if not isOpen then
                list.Visible = false
            end
        end
    end)

    return dropdownButton
end

-- BUY TRAIL
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

local trailRemote = ReplicatedStorage:WaitForChild("TrailAction", 10)

local function buyTrail(trailName)
    if not trailRemote or not trailRemote:IsA("RemoteEvent") then
        warn("SLOP: TrailAction RemoteEvent not found!")
        return
    end

    trailRemote:FireServer("Buy", trailName)
end

-- TRAIL LIST AT THE TOP
createDropdown(
    "BUY TRAIL",
    "TRAIL",
    10,
    trails,
    buyTrail,
    185
)

-- PEN SECTION UNDER TRAILS
local penTitle = Instance.new("TextLabel")
penTitle.Name = "PenTitle"
penTitle.Position = UDim2.fromOffset(22, 145)
penTitle.Size = UDim2.new(1, -44, 0, 25)
penTitle.BackgroundTransparency = 1
penTitle.Text = "PEN"
penTitle.TextColor3 = Color3.fromRGB(190, 160, 255)
penTitle.Font = Enum.Font.GothamBold
penTitle.TextSize = 16
penTitle.TextXAlignment = Enum.TextXAlignment.Left
penTitle.ZIndex = 1
penTitle.Parent = autoContent

local upgradePenButton = createButton(autoContent, "UPGRADE PEN", 179)
upgradePenButton.ZIndex = 1

upgradePenButton.MouseButton1Click:Connect(function()
    local upgradeRemote = ReplicatedStorage:FindFirstChild("UpgradePen")

    if upgradeRemote and upgradeRemote:IsA("RemoteEvent") then
        upgradeRemote:FireServer({})
    else
        warn("SLOP: UpgradePen RemoteEvent not found!")
    end
end)

-- BUY SURFBOARD UNDER PEN
local surfboards = {
    {"Driftwood Board", "Driftwood"},
    {"Coral Board", "Coral"},
    {"Storm Board", "Storm"},
    {"Abyssal Board", "Abyssal"},
    {"Tsunami Board", "Tsunami"}
}

local updateFolder = ReplicatedStorage:WaitForChild("Update", 10)
local updateRemote = updateFolder and updateFolder:WaitForChild("UpdateNet", 10)

local function buySurfboard(surfboardName)
    if not updateRemote or not updateRemote:IsA("RemoteEvent") then
        warn("SLOP: UpdateNet RemoteEvent not found!")
        return
    end

    updateRemote:FireServer("SurfBuy", surfboardName)
end

createDropdown(
    "BUY SURFBOARD",
    "SURFBOARD",
    245,
    surfboards,
    buySurfboard,
    150
)

-- HOW TO USE PAGE
local howToTitle = Instance.new("TextLabel")
howToTitle.Name = "HowToTitle"
howToTitle.Position = UDim2.fromOffset(15, 65)
howToTitle.Size = UDim2.new(1, -30, 0, 55)
howToTitle.BackgroundTransparency = 1
howToTitle.Text = "HOW TO USE"
howToTitle.TextColor3 = Color3.fromRGB(255, 45, 45)
howToTitle.Font = Enum.Font.GothamBlack
howToTitle.TextSize = 30
howToTitle.TextScaled = true
howToTitle.Parent = howToPage

local howToText = Instance.new("TextLabel")
howToText.Name = "Instructions"
howToText.Position = UDim2.fromOffset(22, 135)
howToText.Size = UDim2.new(1, -44, 0, 150)
howToText.BackgroundTransparency = 1
howToText.Text = "To easily steal eggs you have to click TP TO BASE when u almost finish holding the E button while trying to steal an egg"
howToText.TextColor3 = Color3.fromRGB(255, 255, 255)
howToText.Font = Enum.Font.Gotham
howToText.TextSize = 16
howToText.TextWrapped = true
howToText.TextXAlignment = Enum.TextXAlignment.Center
howToText.TextYAlignment = Enum.TextYAlignment.Center
howToText.Parent = howToPage

-- DRAG SYSTEM
local dragging = false
local dragStart
local startPosition

top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPosition = main.Position
    end
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

-- MINIMIZE SYSTEM
local minimized = false

minimize.MouseButton1Click:Connect(function()
    minimized = not minimized

    if minimized then
        sidebar.Visible = false
        content.Visible = false

        tween(main, 0.25, {
            Size = UDim2.fromOffset(530, 48)
        })

        minimize.Text = "+"
    else
        tween(main, 0.25, {
            Size = UDim2.fromOffset(530, 380)
        })

        task.wait(0.25)

        sidebar.Visible = true
        content.Visible = true

        minimize.Text = "-"
    end
end)

-- CLOSE SYSTEM
close.MouseButton1Click:Connect(function()
    tween(main, 0.2, {
        Size = UDim2.fromOffset(0, 0)
    })

    task.wait(0.2)
    gui:Destroy()
end)

-- OPEN ANIMATION
local originalSize = main.Size
main.Size = UDim2.fromOffset(0, 0)

tween(main, 0.35, {
    Size = originalSize
})

return end

-- =========================================================
-- CROSS RIVERS FOR ANIMALS
-- =========================================================

if game.PlaceId == RIVERS_PLACE then
    local function corner(obj, radius)
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, radius or 7)
        c.Parent = obj
    end

    local function makeLabel(parent, text, size, color)
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = color or Color3.new(1, 1, 1)
        label.TextSize = size or 13
        label.Font = Enum.Font.Gotham
        label.Parent = parent
        return label
    end

    local old = playerGui:FindFirstChild("SLOP")
    if old then
        old:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "SLOP"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    -- MAIN WINDOW
    local main = Instance.new("Frame")
    main.Size = UDim2.fromOffset(440, 360)
    main.Position = UDim2.new(0.5, -220, 0.5, -180)
    main.BackgroundColor3 = Color3.fromRGB(19, 19, 25)
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    corner(main, 10)

    -- TOP BAR
    local top = Instance.new("Frame")
    top.Size = UDim2.new(1, 0, 0, 43)
    top.BackgroundColor3 = Color3.fromRGB(29, 29, 37)
    top.BorderSizePixel = 0
    top.Parent = main
    corner(top, 10)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -240, 1, 0)
    title.Position = UDim2.fromOffset(14, 0)
    title.BackgroundTransparency = 1
    title.Text = "SLOP"
    title.TextColor3 = Color3.fromRGB(255, 55, 55)
    title.TextSize = 23
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = top

    local subtitle = Instance.new("TextLabel")
    subtitle.Position = UDim2.fromOffset(200, 0)
    subtitle.Size = UDim2.fromOffset(152, 43)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "cross rivers for animals"
    subtitle.TextColor3 = Color3.fromRGB(130, 130, 150)
    subtitle.TextSize = 10
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextXAlignment = Enum.TextXAlignment.Right
    subtitle.Parent = top

    local minimize = Instance.new("TextButton")
    minimize.Size = UDim2.fromOffset(35, 30)
    minimize.Position = UDim2.new(1, -78, 0, 6)
    minimize.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    minimize.Text = "-"
    minimize.TextColor3 = Color3.new(1, 1, 1)
    minimize.TextSize = 23
    minimize.Font = Enum.Font.GothamBold
    minimize.Parent = top
    corner(minimize, 5)

    local close = Instance.new("TextButton")
    close.Size = UDim2.fromOffset(35, 30)
    close.Position = UDim2.new(1, -39, 0, 6)
    close.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
    close.Text = "X"
    close.TextColor3 = Color3.new(1, 1, 1)
    close.Font = Enum.Font.GothamBold
    close.TextSize = 17
    close.Parent = top
    corner(close, 5)

    close.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    -- SIDEBAR
    local sidebar = Instance.new("Frame")
    sidebar.Position = UDim2.fromOffset(0, 48)
    sidebar.Size = UDim2.new(0, 112, 1, -48)
    sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main

    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(1, -12, 0, 38)
    tab.Position = UDim2.fromOffset(6, 8)
    tab.BackgroundColor3 = Color3.fromRGB(175, 40, 40)
    tab.Text = "TELEPORT"
    tab.TextColor3 = Color3.new(1, 1, 1)
    tab.TextSize = 13
    tab.Font = Enum.Font.GothamBold
    tab.BorderSizePixel = 0
    tab.Parent = sidebar
    corner(tab, 6)

    local gamesTab = Instance.new("TextButton")
    gamesTab.Size = UDim2.new(1, -12, 0, 38)
    gamesTab.AnchorPoint = Vector2.new(0, 1)
    gamesTab.Position = UDim2.new(0, 6, 1, -8)
    gamesTab.BackgroundColor3 = YELLOW
    gamesTab.Text = "GAMES LIST"
    gamesTab.TextColor3 = Color3.new(1, 1, 1)
    gamesTab.TextSize = 11
    gamesTab.Font = Enum.Font.GothamBold
    gamesTab.BorderSizePixel = 0
    gamesTab.Parent = sidebar
    corner(gamesTab, 6)

    -- CONTENT
    local content = Instance.new("Frame")
    content.Position = UDim2.fromOffset(120, 52)
    content.Size = UDim2.new(1, -130, 1, -62)
    content.BackgroundTransparency = 1
    content.Parent = main

    local teleportPage = Instance.new("Frame")
    teleportPage.Name = "Teleport"
    teleportPage.Size = UDim2.fromScale(1, 1)
    teleportPage.BackgroundTransparency = 1
    teleportPage.Parent = content

    local gamesPage = Instance.new("Frame")
    gamesPage.Name = "GamesList"
    gamesPage.Size = UDim2.fromScale(1, 1)
    gamesPage.BackgroundTransparency = 1
    gamesPage.Visible = false
    gamesPage.Parent = content

    local heading = Instance.new("TextLabel")
    heading.Size = UDim2.new(1, -200, 0, 30)
    heading.BackgroundTransparency = 1
    heading.Text = "FIELD EGGS"
    heading.TextColor3 = Color3.fromRGB(255, 60, 60)
    heading.TextSize = 18
    heading.Font = Enum.Font.GothamBold
    heading.TextXAlignment = Enum.TextXAlignment.Left
    heading.TextTruncate = Enum.TextTruncate.AtEnd
    heading.Parent = teleportPage

    local refreshLabel = Instance.new("TextLabel")
    refreshLabel.Size = UDim2.fromOffset(80, 25)
    refreshLabel.Position = UDim2.new(1, -200, 0, 4)
    refreshLabel.BackgroundTransparency = 1
    refreshLabel.Text = "AUTO: 1s"
    refreshLabel.TextColor3 = Color3.fromRGB(130, 220, 130)
    refreshLabel.TextSize = 11
    refreshLabel.Font = Enum.Font.GothamBold
    refreshLabel.Parent = teleportPage

    local refreshButton = Instance.new("TextButton")
    refreshButton.Size = UDim2.fromOffset(80, 27)
    refreshButton.Position = UDim2.new(1, -85, 0, 2)
    refreshButton.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
    refreshButton.Text = "REFRESH"
    refreshButton.TextColor3 = Color3.new(1, 1, 1)
    refreshButton.TextSize = 11
    refreshButton.Font = Enum.Font.GothamBold
    refreshButton.BorderSizePixel = 0
    refreshButton.Parent = teleportPage
    corner(refreshButton, 5)

    -- SCROLL
    local scroll = Instance.new("ScrollingFrame")
    scroll.Position = UDim2.fromOffset(0, 38)
    scroll.Size = UDim2.new(1, 0, 1, -42)
    scroll.BackgroundColor3 = Color3.fromRGB(26, 26, 33)
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 5
    scroll.ScrollBarImageColor3 = Color3.fromRGB(190, 55, 55)
    scroll.CanvasSize = UDim2.new()
    scroll.Parent = teleportPage
    corner(scroll, 7)

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 7)
    padding.PaddingLeft = UDim.new(0, 7)
    padding.PaddingRight = UDim.new(0, 7)
    padding.PaddingBottom = UDim.new(0, 7)
    padding.Parent = scroll

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.fromOffset(
            0,
            layout.AbsoluteContentSize.Y + 15
        )
    end)

    -- GAMES LIST PAGE
    local gamesHeading = Instance.new("TextLabel")
    gamesHeading.Size = UDim2.new(1, 0, 0, 30)
    gamesHeading.BackgroundTransparency = 1
    gamesHeading.Text = "GAMES LIST"
    gamesHeading.TextColor3 = YELLOW
    gamesHeading.TextSize = 18
    gamesHeading.Font = Enum.Font.GothamBold
    gamesHeading.TextXAlignment = Enum.TextXAlignment.Left
    gamesHeading.Parent = gamesPage

    local gamesSubtitle = Instance.new("TextLabel")
    gamesSubtitle.Position = UDim2.fromOffset(0, 28)
    gamesSubtitle.Size = UDim2.new(1, 0, 0, 20)
    gamesSubtitle.BackgroundTransparency = 1
    gamesSubtitle.Text = "Pick a game and press JOIN"
    gamesSubtitle.TextColor3 = Color3.fromRGB(130, 130, 150)
    gamesSubtitle.TextSize = 11
    gamesSubtitle.Font = Enum.Font.Gotham
    gamesSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    gamesSubtitle.Parent = gamesPage

    buildGamesList(gamesPage, 54)

    local function showPage(name)
        teleportPage.Visible = name == "TELEPORT"
        gamesPage.Visible = name == "GAMES LIST"

        tab.BackgroundColor3 = name == "TELEPORT"
            and Color3.fromRGB(175, 40, 40)
            or Color3.fromRGB(38, 38, 48)
    end

    tab.MouseButton1Click:Connect(function()
        showPage("TELEPORT")
    end)

    gamesTab.MouseButton1Click:Connect(function()
        showPage("GAMES LIST")
    end)

    showPage("TELEPORT")

    -- COLLAPSE / EXPAND
    local minimized = false
    local normalSize = UDim2.fromOffset(440, 360)
    local minimizedSize = UDim2.fromOffset(440, 43)

    minimize.MouseButton1Click:Connect(function()
        minimized = not minimized

        if minimized then
            sidebar.Visible = false
            content.Visible = false
            main.Size = minimizedSize
            minimize.Text = "+"
        else
            main.Size = normalSize
            sidebar.Visible = true
            content.Visible = true
            minimize.Text = "-"
        end
    end)

    -- DRAG WINDOW
    local dragging = false
    local dragStart
    local startPosition

    top.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPosition = main.Position
        end
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

    -- FIND MODELS INSIDE NESTED FOLDERS
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
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("Frame") or child.Name == "SpawnButton" then
                child:Destroy()
            end
        end
    end

    -- TP TO SPAWN
    local function createSpawnButton()
        local spawnButton = Instance.new("TextButton")
        spawnButton.Name = "SpawnButton"
        spawnButton.Size = UDim2.new(1, -5, 0, 42)
        spawnButton.BackgroundColor3 = Color3.fromRGB(175, 40, 40)
        spawnButton.BorderSizePixel = 0
        spawnButton.Text = "TP TO SPAWN"
        spawnButton.TextColor3 = Color3.new(1, 1, 1)
        spawnButton.TextSize = 14
        spawnButton.Font = Enum.Font.GothamBold
        spawnButton.LayoutOrder = 0
        spawnButton.Parent = scroll
        corner(spawnButton, 6)

        spawnButton.MouseButton1Click:Connect(function()
            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")

            if root then
                root.CFrame = CFrame.new(-48, 5.5, 13.25)
            end
        end)
    end

    -- EGG ROW
    local function createEggRow(model, order)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -5, 0, 39)
        row.BackgroundColor3 = Color3.fromRGB(43, 43, 52)
        row.BorderSizePixel = 0
        row.LayoutOrder = order
        row.Parent = scroll
        corner(row, 5)

        local name = makeLabel(
            row,
            model.Name,
            12,
            Color3.fromRGB(235, 235, 235)
        )

        name.Position = UDim2.fromOffset(10, 0)
        name.Size = UDim2.new(1, -90, 1, 0)
        name.TextXAlignment = Enum.TextXAlignment.Left
        name.TextTruncate = Enum.TextTruncate.AtEnd

        local tp = Instance.new("TextButton")
        tp.Size = UDim2.fromOffset(58, 27)
        tp.Position = UDim2.new(1, -66, 0.5, -13)
        tp.BackgroundColor3 = Color3.fromRGB(180, 43, 43)
        tp.Text = "TP"
        tp.TextColor3 = Color3.new(1, 1, 1)
        tp.TextSize = 13
        tp.Font = Enum.Font.GothamBold
        tp.BorderSizePixel = 0
        tp.Parent = row
        corner(tp, 5)

        tp.MouseButton1Click:Connect(function()
            if not model:IsDescendantOf(workspace) then
                return
            end

            local character = player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")

            if not root then
                return
            end

            local success, pivot = pcall(function()
                return model:GetPivot()
            end)

            if not success then
                warn("SLOP: Could not get model pivot:", model.Name)
                return
            end

            root.CFrame = pivot + Vector3.new(0, 5, 0)
        end)
    end

    -- FIELD EGGS
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
                createSpawnButton()
                heading.Text = "FIELD EGGS NOT FOUND"
            end

            return
        end

        if not force and signature == lastSignature then
            return
        end

        lastSignature = signature
        clearList()
        createSpawnButton()
        heading.Text = "FIELD EGGS"

        local order = 1

        for _, entry in ipairs(entries) do
            local folder = entry.folder
            local models = entry.models

            order += 1

            local category = Instance.new("Frame")
            category.Size = UDim2.new(1, -5, 0, 38)
            category.BackgroundColor3 = Color3.fromRGB(48, 48, 59)
            category.BorderSizePixel = 0
            category.LayoutOrder = order
            category.Parent = scroll
            corner(category, 6)

            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, 0, 1, 0)
            button.BackgroundTransparency = 1
            button.Text = (expanded[folder.Name] and "▼  " or "▶  ")
                .. folder.Name .. "     (" .. #models .. ")"
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.TextSize = 13
            button.Font = Enum.Font.GothamBold
            button.TextXAlignment = Enum.TextXAlignment.Left
            button.Parent = category

            local leftPadding = Instance.new("UIPadding")
            leftPadding.PaddingLeft = UDim.new(0, 10)
            leftPadding.Parent = button

            button.MouseButton1Click:Connect(function()
                expanded[folder.Name] = not expanded[folder.Name]
                refresh(true)
            end)

            if expanded[folder.Name] then
                for _, model in ipairs(models) do
                    order += 1
                    createEggRow(model, order)
                end
            end
        end

        if #entries == 0 then
            order += 1

            local empty = Instance.new("Frame")
            empty.Size = UDim2.new(1, -5, 0, 40)
            empty.BackgroundTransparency = 1
            empty.LayoutOrder = order
            empty.Parent = scroll

            local label = makeLabel(
                empty,
                "No folders found in FieldEggs",
                12,
                Color3.fromRGB(150, 150, 150)
            )

            label.Size = UDim2.new(1, 0, 1, 0)
        end
    end

    refreshButton.MouseButton1Click:Connect(function()
        refresh(true)
    end)

    refresh(true)

    -- AUTO REFRESH EVERY SECOND (rebuild only when something changed)
    task.spawn(function()
        while gui.Parent do
            task.wait(1)

            if gui.Parent then
                refresh(false)
            end
        end
    end)
end
