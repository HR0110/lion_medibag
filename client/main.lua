local lib <const>, cache <const> = lib, cache ---@diagnostic disable-line: undefined-global
local bags, medibagProp = {}, Config.MedibagProp

-- Functions

local placeMedbag = function()
    TriggerServerEvent('lion_medibag:placeMedbag')
end

-- Events

RegisterNetEvent('lion_medibag:placeMedbag', placeMedbag)

RegisterNetEvent('lion_medibag:pickupMedbag', function()
    local pedCoords = GetEntityCoords(cache.ped)
    lib.playAnim(cache.ped, 'random@domestic', 'pickup_low', 5.0, 1.0, -1, 48, 0, 0, 0, 0)

    if Config.Notifications then
        Notify('Medibag', Config.Locale['pickedupmedbag'], 2000)
    end

    TriggerServerEvent('lion_medibag:canPickupMedbag', NetworkGetNetworkIdFromEntity(GetClosestObjectOfType(pedCoords, 2.0, GetHashKey(medibagProp), false, false, false))) ---@diagnostic disable-line: missing-parameter, param-type-mismatch
end)

RegisterNetEvent('lion_medibag:pickupMedbagResponse', function(canCarry, medibagNetId)
    if canCarry then
        local medibag = NetworkGetEntityFromNetworkId(medibagNetId)
        if medibag ~= 0 then
            DeleteEntity(medibag)
            for i, bag in ipairs(bags) do
                if bag == medibag then
                    table.remove(bags, i)
                    break
                end
            end
        end
    end
end)

RegisterNetEvent('lion_medibag:place', function()
    lib.requestModel(medibagProp)

    local itemCount, pedCoords = lib.callback.await('ox_inventory:getItemCount', false, Config.MedibagItem, {}), GetEntityCoords(cache.ped)
    if itemCount >= 1 then
        if Config.Notifications then
            Notify('Medibag', Config.Locale['placemedbag'], 2000)
        end

        lib.playAnim(cache.ped, 'random@domestic', 'pickup_low', 5.0, 1.0, -1, 48, 0, 0, 0, 0)
        placeMedbag()

        local newMedBag = CreateObject(medibagProp, pedCoords.x, pedCoords.y, pedCoords.z - 1, true, false, false)
        bags[#bags + 1] = newMedBag

        SetEntityHeading(newMedBag, GetEntityHeading(cache.ped))
        PlaceObjectOnGroundProperly(newMedBag)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == cache.resource then
        for i = 1, #bags do
            local bagId = bags[i]
            if DoesEntityExist(bagId) then
                DeleteEntity(bagId)
            end
        end
    end
end)

exports.ox_target:addModel(medibagProp, Config.MedibagTarget)