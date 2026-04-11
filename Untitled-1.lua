---------------- CONFIG ----------------

local LOCAL_API_URL = "https://webhook-roblox.josefernandezxd4.workers.dev/"

-- 🔥 RUTAS (AJUSTA SI ES NECESARIO)
local SCAN_ROOTS = {
    game:GetService("Players").LocalPlayer.PlayerGui,
    workspace
}

--------------------------------------

local HttpService = game:GetService("HttpService")

local request =
    (syn and syn.request) or
    (http and http.request) or
    request

if not request then
    warn("❌ No hay request")
    return
end

--------------------------------------------------
-- PARSE
--------------------------------------------------
local function parseProduction(text)
    local n, u = text:match("%$([%d%.]+)%s*([MBT])%s*/s")
    if not n then return end
    n = tonumber(n)
    if u == "M" then return n * 1e6 end
    if u == "B" then return n * 1e9 end
    if u == "T" then return n * 1e12 end
end

--------------------------------------------------
-- SCAN USANDO RUTAS
--------------------------------------------------
local function scan()
    local list = {}

    for _,root in ipairs(SCAN_ROOTS) do
        if root then
            for _,ui in ipairs(root:GetDescendants()) do
                if ui:IsA("TextLabel") then
                    local value = parseProduction(ui.Text)

                    if value then
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
        end
    end

    return list
end

--------------------------------------------------
-- LOOP TEST
--------------------------------------------------
task.spawn(function()
    while true do
        local result = scan()

        print("🔍 SCAN:", #result)

        for _,v in ipairs(result) do
            print("•", v.name, v.value)
        end

        if #result > 0 then
            local v = result[1]

            local payload = {
                name = v.name,
                value = math.floor(v.value),
                jobId = game.JobId,
                placeId = game.PlaceId
            }

            print("📤 Enviando:", payload.name, payload.value)

            local ok, res = pcall(function()
                return request({
                    Url = LOCAL_API_URL,
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json"
                    },
                    Body = HttpService:JSONEncode(payload)
                })
            end)

            print("RESULT:", ok)

            if res then
                print("STATUS:", res.StatusCode)
                print("BODY:", res.Body)
            else
                print("❌ No response")
            end
        end

        task.wait(3)
    end
end)
