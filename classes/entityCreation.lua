local client = require "config.client"

---@class EntityCreation: OxClass
---@field model number | string
---@field coords vector4
---@field distance number
---@field disable? boolean
local EntityCreation = lib.class("EntityCreation")

function EntityCreation:constructor(data)
    RegisterNetEvent("onResourceStop", function(resource)
        if data.resource == resource then
            self:destroy()
        end
    end)

    self.coords = data.coords
    self.distance = data.distance

    self.disable = false

    self.model = data.model
    self.target = data.target
    self.marker = data.marker
end

function EntityCreation:generateStaticEntity()
    ---@type CPoint
    self.point = lib.points.new({
        coords = client.impound.entity.location,
        distance = client.impound.entity.distance,
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
        DeletePed(self.npc)
        lib.print.info(("entity %s has been deleted"):format(self.npc))
        self.npc = nil
    end
end

function EntityCreation:destroy()
    self.disable = true
end

return EntityCreation
