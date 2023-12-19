local engineStalled = false

RegisterNetEvent("carEngineStalling:checkStalling")
AddEventHandler("carEngineStalling:checkStalling", function()
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)

    if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        local speed = GetEntitySpeed(vehicle) * 2.23694 -- Convert m/s to mph

        if speed >= Config.MinimumSpeedForStalling then
            engineStalled = true

            -- Trigger an event to handle engine stalling and dizzy effect
            TriggerEvent("carEngineStalling:stallEngineAndDizzy")
        end
    end
end)

RegisterNetEvent("carEngineStalling:stallEngineAndDizzy")
AddEventHandler("carEngineStalling:stallEngineAndDizzy", function()
    local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)

    -- Stop the vehicle engine
    SetVehicleEngineOn(vehicle, false, false, true)

    -- Trigger a dizzy effect immediately
    TriggerEvent("carEngineStalling:dizzyEffect")

    -- Trigger a timer to restart the engine after a delay
    SetTimeout(Config.StallingDuration * 1000, function()
        if engineStalled then
            -- Restart the vehicle engine
            SetVehicleEngineOn(vehicle, true, false, true)

            -- Reset the engine stalling flag
            engineStalled = false
        end
    end)
end)

RegisterNetEvent("carEngineStalling:dizzyEffect")
AddEventHandler("carEngineStalling:dizzyEffect", function()
    -- Add your dizzy effect logic here
    local playerPed = GetPlayerPed(-1)

    -- Example: Apply a basic dizzy effect using task sequence
    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_DRUNK_SHAKE", 0, true)
    
    -- Trigger a timer to stop the dizzy effect after a duration
    SetTimeout(Config.DizzyEffectDuration * 1000, function()
        ClearPedTasks(playerPed)
    end)
end)

-- Listen for collisions using OnEntityImpact event
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = GetPlayerPed(-1)
        if IsEntityInWater(playerPed) then
            engineStalled = false
        end

        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)

            local collision, _, _ = GetEntitySpeedVector(vehicle, true)
            if collision > Config.CollisionSpeedThreshold then
                -- Collision detected, trigger the event to check for stalling
                TriggerEvent("carEngineStalling:checkStalling")
            end
        end
    end
end)
