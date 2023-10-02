local qbCore = exports['qb-core']:GetCoreObject()

qbCore.Functions.CreateUseableItem('car_bomb', function(source)
    local src = source
    local iedCount = exports.ox_inventory:Search(src, 'count', 'car_bomb')
    if iedCount > 0 then
        TriggerClientEvent('mp-carbomb:CheckIfRequirementsAreMet', source)
    end
end)

RegisterServerEvent('mp-carbomb:RemoveBombFromInv', function()
    local src = source
    local iedCount = exports.ox_inventory:Search(src, 'count', 'car_bomb')
    if iedCount > 0 then
        exports.ox_inventory:RemoveItem(src, 'car_bomb', 1)
    end
end)

RegisterNetEvent('mp-carbomb:GiveDisabledBomb', function()
    local src = source
    if not exports.ox_inventory:AddItem(src, 'car_bomb_defused', 1) then return end
end)

qbCore.Functions.CreateUseableItem('bombmirror', function(source)
    local src = source
    local mirrorCount = exports.ox_inventory:Search(src, 'count', 'bombmirror')
    if mirrorCount > 0 then
        TriggerClientEvent('mp-carbomb:CheckForCarBomb', source)
    end
end)