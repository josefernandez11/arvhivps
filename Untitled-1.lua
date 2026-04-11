---------------- CONFIG ----------------
-- WEBHOOKS
local WEBHOOK_5M = "SERVER"   
local WEBHOOK_SHOWCASE = "AQUI2"

-- API LOCAL
local LOCAL_API_URL = "https://webhook-roblox.josefernandezxd4.workers.dev/"

-- MINIMOS
local MIN_PRODUCTION_5M = 5_000_000

-- PINGS
local PING_HERE_AT = 100_000_000

local SCAN_DELAY = 0.5
--------------------------------------

local HttpService = game:GetService("HttpService")

local http_request =
    (request) or
    (http and http.request) or
    (syn and syn.request)

if not http_request then return end

--------------------------------------------------
-- NORMALIZAR NOMBRES
--------------------------------------------------
local function normalizeName(name)
    return name
        :lower()
        :gsub("^%s+", "")
        :gsub("%s+$", "")
        :gsub("%s+", " ")
end

--------------------------------------------------
-- PRODUCCIÓN
--------------------------------------------------
local function parseProduction(text)
    local n, u = text:match("%$([%d%.]+)%s*([MBT])%s*/s")
    if not n then return end
    n = tonumber(n)
    if u == "M" then return n * 1e6 end
    if u == "B" then return n * 1e9 end
    if u == "T" then return n * 1e12 end
end

local function formatMoney(v)
    local s = tostring(math.floor(v))
    local formatted = s:reverse():gsub("(%d%d%d)", "%1,"):reverse()
    if formatted:sub(1,1) == "," then
        formatted = formatted:sub(2)
    end
    return "$" .. formatted .. "/s"
end

--------------------------------------------------
-- SCAN
--------------------------------------------------
local function scan(minProduction)
    local list = {}

    for _,ui in ipairs(workspace:GetDescendants()) do
        if ui:IsA("TextLabel") then
            local value = parseProduction(ui.Text)
            if value and value >= minProduction then

                local parent = ui.Parent

                for _,c in ipairs(parent:GetChildren()) do
                    if c:IsA("TextLabel") and not c.Text:find("%$") then
                        table.insert(list, {
                            name = c.Text,
                            value = value
                        })
                        break
                    end
                end
            end
        end
    end

    return list
end

--------------------------------------------------
-- API LOCAL
--------------------------------------------------
local activeBrainrots = {}
local activeWebhook = {}
local notifiedCache = {} -- 🔥 NUEVO

local function sendToLocalAPI(main, list)
    if not LOCAL_API_URL or LOCAL_API_URL == "" then return end

    local jobId = game.JobId
    local placeId = game.PlaceId

    local current = {}

    for _,v in ipairs(list) do
        local key = jobId .. "|" .. v.name .. "|" .. math.floor(v.value)
        current[key] = true

        if not activeBrainrots[key] then
            activeBrainrots[key] = true

            local payload = {
                name = v.name,
                value = math.floor(v.value),
                jobId = jobId,
                placeId = placeId
            }

            pcall(function()
                http_request({
                    Url = LOCAL_API_URL,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = HttpService:JSONEncode(payload)
                })
            end)
        end
    end

    for key,_ in pairs(activeBrainrots) do
        if key:find(jobId) and not current[key] then
            activeBrainrots[key] = nil
        end
    end
end

--------------------------------------------------
-- WEBHOOK
--------------------------------------------------

local function send(list, webhook)
    if #list == 0 then return end

    table.sort(list, function(a,b)
        return a.value > b.value
    end)

    local main = list[1]

    sendToLocalAPI(main, list)

    local hash =
        normalizeName(main.name)
        .. "|"
        .. tostring(math.floor(main.value))
        .. "|"
        .. game.JobId

    -- 🚫 evitar duplicado exacto
    if notifiedCache[hash] then
        return
    end

    -- ✅ marcar enviado
    notifiedCache[hash] = true

    -- 🧹 limpieza inteligente
    task.spawn(function()
        task.wait(15)

        local stillExists = false

        for _,v in ipairs(list) do
            local checkHash =
                normalizeName(v.name)
                .. "|"
                .. tostring(math.floor(v.value))
                .. "|"
                .. game.JobId

            if checkHash == hash then
                stillExists = true
                break
            end
        end

        if not stillExists then
            notifiedCache[hash] = nil
        end
    end)

    local jobId = game.JobId
    local placeId = game.PlaceId

    local joinLink =
        "https://chillihub1.github.io/chillihub-joiner/?placeId="
        .. placeId ..
        "&gameInstanceId=" .. jobId

    local embed = {
        title = "💎 **" .. main.name .. "**",
        color = 2829618,
        description = "**(" .. formatMoney(main.value) .. ")**\n\n",
        footer = {
            text = "CIX NOTIFIER"
        },
    }

    embed.description = embed.description ..
        "**Join Server ID**\n```" .. jobId .. "```\n"

    embed.description = embed.description ..
        "**Join Server**\n[**CLICK TO JOIN**](" .. joinLink .. ")\n\n"

    http_request({
        Url = webhook,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode({
            embeds = { embed }
        })
    })
end

--------------------------------------------------
-- LOOP
--------------------------------------------------
task.spawn(function()
    while true do
        send(scan(MIN_PRODUCTION_5M), WEBHOOK_5M)
        task.wait(1)
    end
end)

--------------------------------------------------
-- AUTO REJOIN
--------------------------------------------------
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

task.spawn(function()
    while true do
        task.wait(900)

        local placeId = game.PlaceId
        local jobId = game.JobId

        pcall(function()
            TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
        end)

        task.wait(2)

        pcall(function()
            TeleportService:Teleport(placeId, player)
        end)
    end
end)
