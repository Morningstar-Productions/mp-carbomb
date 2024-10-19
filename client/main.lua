local config = require 'shared.config'

local timer = 0

local function DetonateVehicle(veh)
    local vCoords = GetEntityCoords(veh)
    if DoesEntityExist(veh) and Entity(veh).state.hasCarBomb then
        Entity(veh).state.hasCarBomb = false
        AddExplosion(vCoords.x, vCoords.y, vCoords.z, 5, 50.0, true, false, 1)
    end
end

local function RunTimer(veh)
    timer = config.timeUntilDetonation

    while timer > 0 do
        timer = timer - 1
        Wait(1000)
        if timer == 0 then
            DetonateVehicle(veh)
            break
        end
    end
end

local function disableCarBomb(entity)
    if not Entity(entity).state.hasCarBomb then
        return config.Notify(locale('no_bomb_removed'), 'info', 5000)
    end

    if lib.progressCircle({
        label = locale('removing_ied'),
        duration = 10000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, combat = true, move = true },
        anim = { dict = 'anim@gangops@facility@servers@bodysearch@', clip = 'player_search', flag = 49 }
    }) then
        ClearPedTasksImmediately(cache.ped)

        Entity(entity).state.hasCarBomb = false
        local disableBomb = lib.callback.await('mp-carbomb:GiveDisabledBomb', false)
        if not disableBomb then return end

        exports.ox_target:removeGlobalVehicle({ 'yrp_carbomb_removal' })
        config.Notify(locale('bomb_removed'), 'success', 5000)
    else
        ClearPedTasksImmediately(cache.ped)
        config.Notify(locale('canceled'), 'error', 5000)
    end
end

---@param veh number
local function getDetonationType(veh)
    if config.detonateType == 0 then
        config.Notify(locale('timer_det', config.timeUntilDetonation), 'info', 5000)
        RunTimer(veh)
    elseif config.detonateType == 1 then
        config.Notify(locale('speed_det', config.maxSpeed, config.speedType), 'info', 5000 )
    elseif config.detonateType == 2 then
        config.Notify(locale("keybind_det", config.triggerKey), 'info', 5000 )
    elseif config.detonateType == 3 then
        config.Notify(locale('veh_timer_det', config.timeUntilDetonation), 'info', 5000 )
    elseif config.detonateType == 4 then
        config.Notify(locale('veh_enter_det'), 'info', 5000 )
    end
end

local function detonationLoop(veh)
    local hasBomb = Entity(veh).state.hasCarBomb

    while hasBomb do
        Wait(0)
        if config.detonateType == 1 and hasBomb then
            local speed = GetEntitySpeed(veh)
            local SpeedKMH = speed * 3.6
            local SpeedMPH = speed * 2.236936

            if config.speedType == 'mph' then
                if SpeedMPH >= config.maxSpeed then
                    DetonateVehicle(veh)
                end
            elseif config.speedType == 'KPH' then
                if SpeedKMH >= config.maxSpeed then
                    DetonateVehicle(veh)
                end
            end
        elseif config.detonateType == 2 and hasBomb then
            if IsControlJustReleased(0, config.triggerKey) then
                DetonateVehicle(veh)
            end
        elseif config.detonateType == 3 and hasBomb then
            if not IsVehicleSeatFree(veh, -1) then
                RunTimer(veh)
            elseif not IsVehicleSeatFree(veh, 0) then
                RunTimer(veh)
            end
        elseif config.detonateType == 4 and hasBomb then
            if not IsVehicleSeatFree(veh, -1) then
                DetonateVehicle(veh)
            end
        end
    end
end

local function checkItemRequirements()
    local veh = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3.0, false)
    local animDict = "anim@amb@business@weed@weed_inspecting_lo_med_hi@"
    local anim = "weed_spraybottle_crouch_base_inspector"

    if not veh then return config.Notify(locale('no_vehicle'), 'error', 5000) end
    if IsPedInAnyVehicle(cache.ped, false) then
        return config.Notify(locale('no_inside_vehicle'), 'error', 2500)
    end

    lib.requestAnimDict(animDict)
    Wait(1000)
    TaskPlayAnim(cache.ped, animDict, anim, 3.0, 1.0, -1, 0, 1, false, false, false)

    if lib.progressCircle({
        duration = config.timeTakenToArm * 1000,
        label = locale('arming_ied'),
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { move = true, car = true, combat = true }
    }) then
        ClearPedTasksImmediately(cache.ped)
        local removeBomb = lib.callback.await('mp-carbomb:RemoveBombFromInv', false)
        if not removeBomb then return end

        Entity(veh).state.hasCarBomb = true

        getDetonationType(veh)
        detonationLoop(veh)
    else
        ClearPedTasksImmediately(cache.ped)
        config.Notify(locale('canceled'), 'error', 5000)
    end
end exports('placeBomb', checkItemRequirements)

local function createRemovalTarget(entity)
    exports.ox_target:addEntity(entity, {
        {
            name = 'yrp_carbomb_removal',
            label = locale('defuse_bomb'),
            icon = 'fas fa-cut',
            onSelect = function()
                disableCarBomb(entity)
            end,
            canInteract = function(_, distance)
                return Entity(entity).state.hasCarBomb and distance <= 2.5
            end,
        }
    })
    config.Notify(locale('bomb_located'), 'info', 5000)
end

local function useBombMirror()
    local veh = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3.0, false)

    if not veh then return config.Notify(locale('no_vehicle'), 'error', 5000) end
    if IsPedInAnyVehicle(cache.ped, false) then
        return config.Notify(locale('no_inside_vehicle'), 'error', 2500)
    end

    if lib.progressCircle({
        label = locale('checking_for_ied'),
        duration = 10000,
        position = 'bottom',
        useWhileDead = false,
        canCancel = true,
        disable = { car = true, combat = true, move = true },
        anim = { dict = 'mini@golfai', clip = 'wood_idle_a', flag = 49 }
    }) then
        ClearPedTasksImmediately(cache.ped)
        if not Entity(veh).state.hasCarBomb then
            config.Notify(locale('no_bomb_found'), 'info', 5000)
        end

        createRemovalTarget(veh)
    else
        ClearPedTasksImmediately(cache.ped)
        config.Notify(locale('canceled'), 'error', 5000)
    end
end exports('useBombMirror', useBombMirror)
