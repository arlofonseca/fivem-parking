local client = require "config.client"

---@class EntityCreation: OxClass
---@field model number | string
---@field coords vector4
---@field distance number
---@field disable? boolean
local EntityCreation = lib.class("EntityCreation")

function EntityCreation:constructor(data)
    self.model = data.model
    self.coords = data.coords
    self.distance = data.distance
    self.disable = false

    self.target = data.target
    self.marker = data.marker

    RegisterNetEvent("onResourceStop", function(resource)
        if data.resource == resource then
            self:destroy()
        end
    end)
end

function EntityCreation:generateStaticEntity()
    local coords = client.impound.entity.location
    local distance = client.impound.entity.distance

    ---@type CPoint
    self.point = lib.points.new({
        coords = coords,
        distance = distance,
    })

    function self.point:onEnter()
        self.model = type(client.impound.entity.model) == "string" and joaat(client.impound.entity.model) or client.impound.entity.model
        lib.requestModel(self.model)
        if not self.model then return end
        self.type = ("male" == "male") and 4 or 5
        self.npc = CreatePed(self.type, self.model, client.impound.entity.location.x, client.impound.entity.location.y, client.impound.entity.location.z, client.impound.entity.location.w, false, true)
        lib.print.info(("entity %s has been created"):format(self.npc))
        FreezeEntityPosition(self.npc, true)
        SetEntityInvincible(self.npc, true)
        SetBlockingOfNonTemporaryEvents(self.npc, true)
    end

    function self.point:onExit()
        if DoesEntityExist(self.npc) then
            DeleteEntity(self.npc)
            DeletePed(self.npc)
            lib.print.info(("entity %s has been deleted"):format(self.npc))
            self.npc = nil
        end
    end
end

function EntityCreation:destroy()
    self.disable = true

    if self.point then
        self.point:remove()
    end
end

return EntityCreation
