RegisterNuiCallback('hideFrame', function(_, cb)
  ToggleNuiFrame(false)
  cb({})
end)

---@param cb function
RegisterNuiCallback("bgarage:cb:get:vehicle", function(data, cb)
  if not data then return end

  HandleVehicleSelect(data.plate, data)
  print("[bgarage:cb:get:vehicle] data: ", json.encode(data))
  cb({})
end)

---@param data Vehicle
---@param cb function
RegisterNuiCallback("bgarage:cb:impound:get:vehicle", function(data, cb)
  local canPay, reason = lib.callback.await("bgarage:server:payment", false, Impound.price, false)

  if #(Impound.entityLocation.xyz - GetEntityCoords(PlayerPedId())) > 15.0 then
    return print(
      "[bgarage:cb:impound:get:vehicle] Distance is too far")
  end

  if not canPay then
    lib.callback.await("bgarage:server:retrieveVehicleFromImpound", false)
    Notify(reason, 5000, "center-right", "error", "circle-info", "#7f1d1d")
    return
  end

  local success, spawnReason = SpawnVehicle(data.plate, data, Impound.location)
  Notify(spawnReason, 5000, "center-right", "success", "car", "#14532d")

  if not success then return print("not success") end

  lib.callback.await("bgarage:server:payment", false, Impound.price, true)
  cb({})
end)

---@param data any
---@param cb function
RegisterNuiCallback("bgarage:cb:get:location", function(data, cb)
  if not data then return print("[bgarage:cb:get:location] data is nil") end

  if data.location == "impound" then
    SetNewWaypoint(Impound.location.x, Impound.location.y)
    return
  end

  local location = lib.callback.await("bgarage:server:getParkingSpot", false)

  local coords = data.location == "parked" and location?.xy or
      data.location == "outside" and
      lib.callback.await("bgarage:server:getVehicleCoords", false, data.plate)?.xy or
      nil

  if not coords then
    Notify(
      data .. location == "outside" and locale("vehicle_doesnt_exist") or locale("no_parking_spot"),
      5000,
      "center-right", "inform", "car" or "circle-info", "#3b82f6")
    return
  end

  if coords then
    SetNewWaypoint(coords.x, coords.y)
    Notify(locale("set_waypoint"), 5000, "center-right", "inform", "circle-info", "#3b82f6")
    return
  end

  cb({})
end)
