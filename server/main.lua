local config = require 'shared.config'

lib.callback.register('mp-carbomb:RemoveBombFromInv', function(source)
    local iedCount = exports.ox_inventory:Search(source, 'count', 'car_bomb')
    if iedCount > 0 then
        exports.ox_inventory:RemoveItem(source, 'car_bomb', 1)
        return true
    end

    return false
end)

lib.callback.register('mp-carbomb:GiveDisabledBomb', function(source)
    if not exports.ox_inventory:AddItem(source, 'car_bomb_defused', 1) then return false end
end)

-- Compat Functions

if config.useCompatInventory then
    exports.qbx_core:CreateUseableItem('carbomb', function(source, item),
        TriggerClientEvent('mp-carbomb:client:placeBomb', source)
    end)

    exports.qbx_core:CreateUseableItem('bombmirror', function(source, item),
        TriggerClientEvent('mp-carbomb:client:useBombMirror', source)
    end)
end