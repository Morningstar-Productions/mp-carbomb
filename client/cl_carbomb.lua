local timer = 0

local function DetonateVehicle(veh)
    local vCoords = GetEntityCoords(veh)
    if DoesEntityExist(veh) then
        Entity(veh).state.hasCarBomb = false
        AddExplosion(vCoords.x, vCoords.y, vCoords.z, 5, 50.0, true, false, 1)
    end
end

local function RunTimer(veh)
    timer = Config.TimeUntilDetonation

    while timer > 0 do
        timer = timer - 1
        Wait(1000)
        if timer == 0 then DetonateVehicle(veh) end
    end
end

local function DisableCarBomb()
    local veh = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3.0, false)

    if not veh then return lib.notify({ description = locale('no_vehicle'), type = 'error', duration = 5000 }) end
    if IsPedInAnyVehicle(cache.ped, false) then
        return lib.notify({ description = locale('no_inside_vehicle'), type = 'error', duration = 2500 })
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

        if not Entity(veh).state.hasCarBomb then
            return lib.notify({ description = locale('no_bomb_removed'), type = 'primary', duration = 5000 })
        end

        Entity(veh).state.hasCarBomb = false
        local disableBomb = lib.callback.await('mp-carbomb:GiveDisabledBomb', false)
        if not disableBomb then return end

        exports.ox_target:removeGlobalVehicle({ 'yrp_carbomb_removal' })
        lib.notify({ description = locale('bomb_removed'), type = 'success', duration = 5000 })
    else
        ClearPedTasksImmediately(cache.ped)
        lib.notify({ description = locale('canceled'), type = 'error', duration = 5000 })
    end
end

---@param veh number
local function getDetonationType(veh)
    if Config.DetonationType == 0 then
        lib.notify({ description = locale('timer_det', Config.TimeUntilDetonation), type = 'primary', duration = 5000 })
        RunTimer(veh)
    elseif Config.DetonationType == 1 then
        lib.notify({ description = locale('speed_det', Config.maxSpeed, Config.Speed), type = 'primary', duration = 5000 })
    elseif Config.DetonationType == 2 then
        lib.notify({ description = locale("keybind_det", Config.TriggerKey), type = 'primary', duration = 5000 })
    elseif Config.DetonationType == 3 then
        lib.notify({ description = locale('veh_timer_det', Config.TimeUntilDetonation), type = 'primary', duration = 5000 })
    elseif Config.DetonationType == 4 then
        lib.notify({ description = locale('veh_enter_det'), type = 'primary', duration = 5000 })
    end
end

local function detonationLoop(veh)
    local hasBomb = Entity(veh).state.hasCarBomb

    while hasBomb do
        Wait(0)
        if Config.DetonationType == 1 and hasBomb then
            local speed = GetEntitySpeed(veh)
            local SpeedKMH = speed * 3.6
            local SpeedMPH = speed * 2.236936

            if Config.Speed == 'MPH' then
                if SpeedMPH >= Config.maxSpeed then
                    DetonateVehicle(veh)
                end
            elseif Config.Speed == 'KPH' then
                if SpeedKMH >= Config.maxSpeed then
                    DetonateVehicle(veh)
                end
            end
        elseif Config.DetonationType == 2 and hasBomb then
            if IsControlJustReleased(0, Config.TriggerKey) then
                DetonateVehicle(veh)
            end
        elseif Config.DetonationType == 3 and hasBomb then
            if not IsVehicleSeatFree(veh, -1) then
                RunTimer(veh)
            elseif not IsVehicleSeatFree(veh, 0) then
                RunTimer(veh)
            end
        elseif Config.DetonationType == 4 and hasBomb then
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

    if not veh then return lib.notify({ description = locale('no_vehicle'), type = 'error', duration = 5000 }) end
    if IsPedInAnyVehicle(cache.ped, false) then
        return lib.notify({ description = locale('no_inside_vehicle'), type = 'error', duration = 2500 })
    end

    lib.requestAnimDict(animDict)
    Wait(1000)
    TaskPlayAnim(cache.ped, animDict, anim, 3.0, 1.0, -1, 0, 1, false, false, false)

    if lib.progressCircle({
        duration = Config.TimeTakenToArm * 1000,
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
        lib.notify({ description = locale('canceled'), type = 'error', duration = 5000 })
    end
end exports('placeBomb', checkItemRequirements)

local function createRemovalTarget()
    exports.ox_target:addGlobalVehicle({
        {
            name = 'yrp_carbomb_removal',
            label = locale('defuse_bomb'),
            icon = 'fas fa-cut',
            onSelect = function()
                DisableCarBomb()
            end,
            canInteract = function(entity, distance)
                return Entity(entity).state.hasCarBomb and distance <= 2.5
            end,
        }
    })
    lib.notify({ description = locale('bomb_located'), type = 'info', duration = 5000 })
end

local function useBombMirror()
    local veh = lib.getClosestVehicle(GetEntityCoords(cache.ped), 3.0, false)

    if not veh then return lib.notify({ description = locale('no_vehicle'), type = 'error', duration = 5000 }) end
    if IsPedInAnyVehicle(cache.ped, false) then
        return lib.notify({ description = locale('no_inside_vehicle'), type = 'error', duration = 2500 })
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
            lib.notify({ description = locale('no_bomb_found'), type = 'info', duration = 5000 })
        end

        createRemovalTarget()
    else
        ClearPedTasksImmediately(cache.ped)
        lib.notify({ description = locale('canceled'), type = 'error', duration = 5000 })
    end
end exports('useBombMirror', useBombMirror)
