local shared = require "config.shared"

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

    ---@param resource string
    RegisterNetEvent("onResourceStop", function(resource)
        if data.resource == resource then
            self:destroy()
        end
    end)
end

function EntityCreation:generateStaticEntity()
    local coords = shared.impound.entity.location
    local distance = shared.impound.entity.distance

    ---@type CPoint
    self.point = lib.points.new({
        coords = coords,
        distance = distance,
    })

    function self.point:onEnter()
        self.model = type(shared.impound.entity.model) == "string" and joaat(shared.impound.entity.model) or shared.impound.entity.model
        lib.requestModel(self.model)
        if not self.model then return end
        self.type = ("male" == "male") and 4 or 5
        self.npc = CreatePed(self.type, self.model, shared.impound.entity.location.x, shared.impound.entity.location.y, shared.impound.entity.location.z, shared.impound.entity.location.w, false, true)
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
