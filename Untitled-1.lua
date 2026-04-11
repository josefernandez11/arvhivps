---------------- CONFIG ----------------
local WEBHOOK_10M = "SERVER"
local WEBHOOK_SHOWCASE = "AQUI2"

local LOCAL_API_URL = "https://webhook-roblox.josefernandezxd4.workers.dev/"

-- 🔥 BAJADO PARA TEST
local MIN_PRODUCTION_10M = 1

local PING_HERE_AT = 100_000_000
local SCAN_DELAY = 0.5
--------------------------------------

local HttpService = game:GetService("HttpService")

local http_request =
    (syn and syn.request) or
    (http and http.request) or
    request

if not http_request then return end

--------------------------------------------------
-- NORMALIZAR
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
-- API LOCAL (SIN BLOQUEOS)
--------------------------------------------------
local function sendToLocalAPI(main, list)
    if not LOCAL_API_URL or LOCAL_API_URL == "" then return end

    local jobId = game.JobId
    local placeId = game.PlaceId

    for _,v in ipairs(list) do
        local payload = {
            name = v.name,
            value = math.floor(v.value),
            jobId = jobId,
            placeId = placeId
        }

        print("📤 API:", v.name, v.value)

        pcall(function()
            local res = http_request({
                Url = LOCAL_API_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = HttpService:JSONEncode(payload)
            })

            if res then
                print("API STATUS:", res.StatusCode)
            else
                print("❌ API sin respuesta")
            end
        end)
    end
end

--------------------------------------------------
-- WEBHOOK (SIN BLOQUEO)
--------------------------------------------------
local function send(list, webhook)
    if #list == 0 then return end

    table.sort(list, function(a,b)
        return a.value > b.value
    end)

    local main = list[1]

    sendToLocalAPI(main, list)

    print("📤 WEBHOOK:", main.name, main.value)

    local jobId = game.JobId
    local placeId = game.PlaceId

    local joinLink =
        "https://chillihub1.github.io/chillihub-joiner/?placeId="
        .. placeId ..
        "&gameInstanceId=" .. jobId

    local embed = {
        title = "💎 " .. main.name,
        description =
            formatMoney(main.value) ..
            "\n\nJobId:\n" .. jobId ..
            "\n\nJoin:\n" .. joinLink,
        color = 2829618
    }

    pcall(function()
        http_request({
            Url = webhook,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({
                embeds = { embed }
            })
        })
    end)
end

--------------------------------------------------
-- LOOP DEBUG
--------------------------------------------------
task.spawn(function()
    while true do
        local result = scan(MIN_PRODUCTION_10M)

        print("🔍 SCAN SIZE:", #result)

        for _,v in ipairs(result) do
            print("•", v.name, v.value)
        end

        send(result, WEBHOOK_10M)

        task.wait(1)
    end
end)
