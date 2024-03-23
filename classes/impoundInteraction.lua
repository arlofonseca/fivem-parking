local EntityCreation = require "classes.entityCreation"
local shared = require "config.shared"
local framework = require(("modules.bridge.%s.client"):format(shared.framework))

---@class ImpoundInteraction: EntityCreation
---@field target? boolean
---@field marker? boolean
local ImpoundInteraction = lib.class("ImpoundInteraction", EntityCreation)

local shownTextUI = false
local GetEntityCoords = GetEntityCoords
local DrawMarker = DrawMarker
local IsControlJustPressed = IsControlJustPressed

function ImpoundInteraction:constructor(data)
    self:super(data)
    self.target = data.target
    self.marker = data.marker
end

function ImpoundInteraction:generateInteraction()
    if GetResourceState("ox_target"):find("start") and shared.impound.useTarget then
        exports.ox_target:addModel(shared.impound.entity.model, {
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
                local markerLocation = shared.impound.marker.location.xyz
                local markerDistance = shared.impound.marker.distance

                if #(coords - markerLocation) < markerDistance then
                    if not menuOpened then
                        sleep = 0
                        DrawMarker(shared.impound.marker.type, markerLocation.x, markerLocation.y, markerLocation.z, 0.0, 0.0, 0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 20, 200, 20, 50, false, false, 2, true, nil, nil, false)
                        if not shownTextUI then
                            shownTextUI = true
                            framework.showTextUI(locale("impound_show"))
                        end

                        if IsControlJustPressed(0, 38) then
                            TriggerEvent("bGarage:client:openImpoundList")
                        end
                        menuOpened = true
                    end
                else
                    if menuOpened then
                        menuOpened = false
                        framework.hideContext(false)
                    end

                    if shownTextUI then
                        shownTextUI = false
                        framework.hideTextUI()
                    end
                end
                Wait(sleep)
            end
        end)
    end
end

return ImpoundInteraction
