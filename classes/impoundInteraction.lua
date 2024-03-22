local EntityCreation = require "classes.entityCreation"
local client = require "config.client"
local shared = require "config.shared".framework
local shownTextUI = false

---@class ImpoundInteraction: EntityCreation
---@field target? boolean
---@field marker? boolean
local ImpoundInteraction = lib.class("ImpoundInteraction", EntityCreation)

function ImpoundInteraction:constructor(data)
    self:super(data)
    self.target = data.target
    self.marker = data.marker
end

function ImpoundInteraction:generateInteraction()
    if GetResourceState("ox_target"):find("start") and client.impound.useTarget then
        exports.ox_target:addModel(client.impound.entity.model, {
            {
                label = locale("impound_label"),
                name = "impound_entity",
                icon = "fa-solid fa-warehouse",
                distance = 2.5,
                event = "bGarage:client:openImpoundList",
            },
        })
    else
        CreateThread(function()
            local sleep = 500
            while true do
                sleep = 500
                local menuOpened = false
                local coords = GetEntityCoords(cache.ped)
                local markerLocation = client.impound.marker.location.xyz
                local markerDistance = client.impound.marker.distance

                if #(coords - markerLocation) < markerDistance then
                    if not menuOpened then
                        sleep = 0
                        DrawMarker(client.impound.marker.type, client.impound.marker.location.x, client.impound.marker.location.y, client.impound.marker.location.z, 0.0, 0.0, 0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 20, 200, 20, 50, false, false, 2, true, nil, nil, false)
                        if not shownTextUI then
                            shownTextUI = true
                            shared.showTextUI(locale("impound_show"))
                        end

                        if IsControlJustPressed(0, 38) then
                            TriggerEvent("bGarage:client:openImpoundList")
                        end
                        menuOpened = true
                    end
                else
                    if menuOpened then
                        menuOpened = false
                        shared.hideContext(false)
                    end

                    if shownTextUI then
                        shownTextUI = false
                        shared.hideTextUI()
                    end
                end
                Wait(sleep)
            end
        end)
    end
end

return ImpoundInteraction
