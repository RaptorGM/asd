local osclock = os.clock()
if not game:IsLoaded() then
    game.Loaded:Wait()
end

task.wait(5)
-- Cargar el módulo webhookBuilder desde GitHub
local webhookBuilder = loadstring(game:HttpGet("https://raw.githubusercontent.com/lilyscripts/webhook-builder/main/webhookBuilder.lua"))()

-- URL de tu webhook en Discord
local webhookURL = "https://discord.com/api/webhooks/1034543838498398279/TNOa7d4DO_bAwaAn_mz4k3Yljc7MIUkZU99MsmnM2JM0ej6HHdQgk2kFWNWK-kLEeVsI"

-- Crear una instancia del webhook utilizando la URL
local webhook = webhookBuilder(webhookURL)

-- Función para enviar el mensaje a través del webhook
function sendWebhookMessage(itemName, itemCost, quantity, totalCost)
    -- Crear un mensaje para el webhook
    local message = "¡Compra realizada con éxito!\nDetalles:\nItem: " .. itemName .. "\nCantidad: " .. quantity .. "\nCosto Unitario: " .. itemCost .. " gemas\nCosto Total: " .. totalCost .. " gemas"
    
    -- Enviar el mensaje utilizando el webhook
    local embed = webhook:createEmbed()
    embed:setTitle("Compra Realizada")
    embed:setDescription(message)
    embed:setColor(65280)  -- Color verde

    webhook:send()
end

local Player = game.Players.LocalPlayer
local BuyRemote = game.ReplicatedStorage.Network.Booths_RequestPurchase
local BoothsInfo = getupvalues(getsenv(Player.PlayerScripts.Scripts.Game["Trading Plaza"]["Booths Frontend"]).getState)

function getInfo(itemName, itemCost)
    local playerID = 0
    for _,numTables in pairs(BoothsInfo) do
        if typeof(numTables) == "table" then
            for _,plyrTables in pairs(numTables) do
                if typeof(plyrTables) == "table" then
                    for i,v in pairs(plyrTables) do
                        if i == "PlayerID" then playerID = v end
                        if i == "Listings" and typeof(v) == "table" then
                            for UID,values in pairs(v) do
                                local data = values.Item._data
                                if data.id == itemName then
                                    print("")
                                    warn("Unique ID:",UID)
                                    print("Name:",data.id)
                                    if data.tn then
                                        print("Tier:",data.tn)
                                    elseif data.pt then
                                        print("Pet Type", data.pt)
                                    end
                                    print("Amount:",data._am or 1)
                                    print("Listed for "..values.DiamondCost,"gems")
                                    if values.DiamondCost <= itemCost then
                                        warn("Snipe Canditate Found")
                                        local args = {
                                            [1] = playerID,
                                            [2] = {
                                                [UID] = (data._am or 1)
                                            }
                                        }
                                        print("attempting purchase..")
                                        local success = BuyRemote:InvokeServer(unpack(args))
                                        if success then
                                            task.wait(2)
                                            local quantity = data._am or 1
                                            local totalCost = quantity * values.DiamondCost
                                            sendWebhookMessage(data.id, values.DiamondCost, quantity, totalCost)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

if getgenv().KiTTYWARE.boothSniper.autoSnipe then
    for i,v in pairs(getgenv().KiTTYWARE.boothSniper.snipeItem) do
        getInfo(v.Name, v.Price)
    end
end