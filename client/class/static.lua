local shared = require 'config.shared'
local framework = require(('client.framework.%s'):format(shared.framework))

---@class Static : OxClass
---@field generatePoint fun(self)
---@field generateInteraction fun(self)
---@field destroy fun(self)
local Static = lib.class('Static')

local shownTextUI = false

---@param data { owner: number, plate: string, model: number, props: table, type?: string, location: string, fuel: string, fuel: number, body: number, engine: number, temporary: boolean}
---@diagnostic disable-next-line: invisible
function Static:constructor(data)
    self.disable = false
    self.owner = data.owner
    self.plate = data.plate
    self.model = data.model
    self.props = data.props
    self.type = data.type
    self.location = data.location
    self.fuel = data.fuel
    self.body = data.body
    self.engine = data.engine
    self.temporary = data.temporary

    ---@param resource string
    RegisterNetEvent('onResourceStop', function(resource)
        if resource == cache.resource then
            self:destroy()
        end
    end)
end

function Static:generatePoint()
    if self.disable then return end

    local coords = shared.impound.entity.location
    local distance = shared.impound.entity.distance

    ---@type CPoint
    self.point = lib.points.new({
        coords = coords,
        distance = distance,
    })

    function self.point:onEnter()
        self.model = type(shared.impound.entity.model) == 'string' and joaat(shared.impound.entity.model) or shared.impound.entity.model
        lib.requestModel(self.model)
        if not self.model then return end
        self.npc = CreatePed(0, self.model, shared.impound.entity.location.x, shared.impound.entity.location.y, shared.impound.entity.location.z, shared.impound.entity.location.w, false, true)
        SetModelAsNoLongerNeeded(shared.impound.entity.model)
        SetEntityInvincible(self.npc, true)
        FreezeEntityPosition(self.npc, true)
        SetBlockingOfNonTemporaryEvents(self.npc, true)
    end

    function self.point:onExit()
        if DoesEntityExist(self.npc) then
            DeleteEntity(self.npc)
            DeletePed(self.npc)
            self.npc = nil
        end
    end
end

function Static:generateInteraction()
    if GetResourceState('ox_target'):find('start') and shared.impound.useTarget then
        exports.ox_target:addModel(shared.impound.entity.model, {
            {
                label = locale('impound_label'),
                name = 'impound_entity',
                icon = 'fa-solid fa-warehouse',
                distance = 2.5,
                event = 'fivem_parking:client:openImpoundList',
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
                        ---@diagnostic disable-next-line: param-type-mismatch
                        DrawMarker(shared.impound.marker.type, markerLocation.x, markerLocation.y, markerLocation.z, 0.0, 0.0, 0, 0.0, 180.0, 0.0, 1.0, 1.0, 1.0, 20, 200, 20, 50, false, false, 2, true, nil, nil, false)
                        if not shownTextUI then
                            shownTextUI = true
                            framework.showTextUI(locale('impound_show'))
                        end

                        if IsControlJustPressed(0, 38) then
                            TriggerEvent('fivem_parking:client:openImpoundList')
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

function Static:destroy()
    self.disable = true
end

return Static