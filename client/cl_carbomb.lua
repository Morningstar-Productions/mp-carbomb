lib.locale()
local qbCore = exports['qb-core']:GetCoreObject()
local timer = 0
local armedVeh = nil
local ped = cache.ped

local function DetonateVehicle(veh)
    local vCoords = GetEntityCoords(veh)
    if DoesEntityExist(veh) then
        armedVeh = nil
        AddExplosion(vCoords.x, vCoords.y, vCoords.z, 5, 50.0, true, false, true)
    end
end

local function RunTimer(veh)
    timer = Config.TimeUntilDetonation
    while timer > 0 do
        timer = timer - 1
        Wait(1000)
        if timer == 0 then
            DetonateVehicle(veh)
        end
    end
end

local function DisableCarBomb()
    local veh, dist
    if GetResourceState('qbx_core') ~= 'started' then veh, dist = qbCore.Functions.GetClosestVehicle() else veh, dist = GetClosestVehicle() end
    if not IsPedInAnyVehicle(cache.ped, false) then
        if veh and dist < 3.0 then
            if lib.progressCircle({
                label = locale('removing_ied'),
                duration = 10000,
                position = 'bottom',
                useWhileDead = false,
                canCancel = true,
                disable = { car = true, combat = true, move = true },
                anim = { dict = 'anim@gangops@facility@servers@bodysearch@', clip = 'player_search', flag = 49 }
            }) then
                ClearPedTasksImmediately(ped)
                if veh ~= armedVeh then
                    qbCore.Functions.Notify(locale('no_bomb_removed') 'primary', 5000)
                else
                    armedVeh = nil
                    TriggerServerEvent('carbomb:GiveDisabledBomb')
                    exports.ox_target:removeGlobalVehicle({ 'yrp_carbomb_removal' })
                    qbCore.Functions.Notify(locale('bomb_removed'), 'success', 5000)
                end
            else
                ClearPedTasksImmediately(ped)
                qbCore.Functions.Notify(locale('canceled'), 'error', 5000)
            end
        else
            qbCore.Functions.Notify(locale('no_vehicle'), 'error', 5000)
        end
    else
        qbCore.Functions.Notify(locale('no_inside_vehicle'), 'error', 5000)
    end
end

RegisterNetEvent('carbomb:CheckIfRequirementsAreMet', function()
    local veh, dist
    if GetResourceState('qbx_core') ~= 'started' then veh, dist = qbCore.Functions.GetClosestVehicle() else veh, dist = GetClosestVehicle() end
    local animDict = "anim@amb@business@weed@weed_inspecting_lo_med_hi@"
    local anim = "weed_spraybottle_crouch_base_inspector"

    if not IsPedInAnyVehicle(ped, false) then
        if veh and (dist < 3.0) then
            lib.requestAnimDict(animDict)
            Wait(1000)
            TaskPlayAnim(ped, animDict, anim, 3.0, 1.0, -1, 0, 1, false, false, false)
            if lib.progressCircle({
                duration = Config.TimeTakenToArm*1000,
                label = locale('arming_ied'),
                position = 'bottom',
                useWhileDead = false,
                canCancel = true,
                disable = { move = true, car = true, combat = true }
            }) then
                ClearPedTasksImmediately(ped)
                TriggerServerEvent('carbomb:RemoveBombFromInv')

                if Config.DetonationType == 0 then
                    qbCore.Functions.Notify(locale('timer_det', Config.TimeUntilDetonation), 'primary', 5000)
                    RunTimer(veh)
                elseif Config.DetonationType == 1 then
                    qbCore.Functions.Notify(locale('speed_det', Config.maxSpeed, Config.Speed), 'primary', 5000)
                    armedVeh = veh
                elseif Config.DetonationType == 2 then
                    qbCore.Functions.Notify(locale("keybind_det", Config.TriggerKey), 'primary', 5000)
                    armedVeh = veh
                elseif Config.DetonationType == 3 then
                    qbCore.Functions.Notify(locale('veh_timer_det', Config.TimeUntilDetonation), 'primary', 5000)
                    armedVeh = veh
                elseif Config.DetonationType == 4 then
                    qbCore.Functions.Notify(locale('veh_enter_det'), 'primary', 5000)
                    armedVeh = veh
                end

                while armedVeh do
                    Wait(0)
                    if Config.DetonationType == 1 and armedVeh then
                        local speed = GetEntitySpeed(armedVeh)
                        local SpeedKMH = speed * 3.6
                        local SpeedMPH = speed * 2.236936

                        if Config.Speed == 'MPH' then
                            if SpeedMPH >= Config.maxSpeed then
                                DetonateVehicle(armedVeh)
                            end
                        elseif Config.Speed == 'KPH' then
                            if SpeedKMH >= Config.maxSpeed then
                                DetonateVehicle(armedVeh)
                            end 
                        end        
                    elseif Config.DetonationType == 2 and armedVeh then
                        if IsControlJustReleased(0, Config.TriggerKey) then
                            DetonateVehicle(armedVeh)
                        end
                    elseif Config.DetonationType == 3 and armedVeh then
                        if not IsVehicleSeatFree(armedVeh, -1)  then
                            RunTimer(armedVeh)
                        elseif not IsVehicleSeatFree(armedVeh, 0) then   
                            RunTimer(armedVeh)
                        end
                    elseif Config.DetonationType == 4 and armedVeh then
                        if not IsVehicleSeatFree(armedVeh, -1) then
                            DetonateVehicle(armedVeh)
                        end
                    end
                end
            else
                ClearPedTasksImmediately(ped)
                qbCore.Functions.Notify(locale('canceled'), 'error', 5000)
            end
        else
            qbCore.Functions.Notify(locale('no_vehicle'), 'error', 5000)
        end
    else
        qbCore.Functions.Notify(locale('no_inside_vehicle'), 'error', 5000)
    end
end)

RegisterNetEvent('carbomb:CheckForCarBomb', function()
    local veh, dist
    if GetResourceState('qbx_core') ~= 'started' then veh, dist = qbCore.Functions.GetClosestVehicle() else veh, dist = GetClosestVehicle() end
    if not IsPedInAnyVehicle(cache.ped, false) then
        if veh and dist < 3.0 then
            if lib.progressCircle({
                label = locale('checking_for_ied'),
                duration = 10000,
                position = 'bottom',
                useWhileDead = false,
                canCancel = true,
                disable = { car = true, combat = true, move = true },
                anim = { dict = 'mini@golfai', clip = 'wood_idle_a', flag = 49 }
            }) then
                ClearPedTasksImmediately(ped)
                if veh ~= armedVeh then
                    qbCore.Functions.Notify(locale('no_bomb_found'), 'primary', 5000)
                else
                    exports.ox_target:addGlobalVehicle({
                        {
                            name = 'yrp_carbomb_removal',
                            label = locale('defuse_bomb'),
                            icon = 'fas fa-cut',
                            onSelect = function()
                                DisableCarBomb()
                            end,
                            canInteract = function(_, distance)
                                return armedVeh and distance <= 2.5
                            end,
                        }
                    })
                    qbCore.Functions.Notify(locale('bomb_located'), 'primary', 5000)
                end
            else
                ClearPedTasksImmediately(ped)
                qbCore.Functions.Notify(locale('canceled'), 'error', 5000)
            end
        else
            qbCore.Functions.Notify(locale('no_vehicle'), 'error', 5000)
        end
    else
        qbCore.Functions.Notify(locale('no_inside_vehicle'), 'error', 5000)
    end
end)