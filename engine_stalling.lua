-- engine_stalling.lua

local engineStalled = false
local lastVehicleHealth = 0
local dizzyEffectActive = false
local dizzyEffectTimer = 0

-- Function to clear screen effects
function ClearScreenEffects()
    ClearTimecycleModifier()
    StopGameplayCamShaking(true)
end

RegisterNetEvent("carEngineStalling:checkStalling")
AddEventHandler("carEngineStalling:checkStalling", function(vehicle)
    if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        local currentHealth = GetVehicleBodyHealth(vehicle)
        local healthDifference = lastVehicleHealth - currentHealth

        if healthDifference > Config.MinHealthDifference then
            -- Collision detected, trigger the event to check for stalling
            TriggerEvent("carEngineStalling:stallEngineAndDizzy", vehicle)
        end

        -- Update last vehicle health
        lastVehicleHealth = currentHealth
    end
end)

RegisterNetEvent("carEngineStalling:stallEngineAndDizzy")
AddEventHandler("carEngineStalling:stallEngineAndDizzy", function(vehicle)
    if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
        -- Stop the vehicle engine
        SetVehicleEngineOn(vehicle, false, false, true)

        -- Trigger a dizzy effect immediately
        TriggerEvent("carEngineStalling:dizzyEffect")

        -- Trigger a timer to restart the engine after a delay
        SetTimeout(Config.StallingDuration * 1000, function()
            -- Restart the vehicle engine
            SetVehicleEngineOn(vehicle, true, false, true)

            -- Reset the engine stalling flag
            engineStalled = false
        end)
    end
end)

RegisterNetEvent("carEngineStalling:dizzyEffect")
AddEventHandler("carEngineStalling:dizzyEffect", function()
    if not dizzyEffectActive then
        dizzyEffectActive = true

        -- Add your dizzy effect logic here
        local playerPed = GetPlayerPed(-1)

        if playerPed then
            -- Example: Apply a dizzy effect using screen effects
            SetTimecycleModifier("DRUNK", true)
            ShakeGameplayCam("DRUNK_SHAKE", Config.DizzyEffectIntensity)  -- Adjust intensity as needed

            -- Set a timer to clear the screen effects after the specified duration
            dizzyEffectTimer = GetGameTimer() + Config.DizzyEffectDuration * 1000
        end
    end
end)

-- Listen for vehicle damage changes when the player enters a vehicle
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = GetPlayerPed(-1)
        if playerPed and IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            
            if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
                local currentHealth = GetVehicleBodyHealth(vehicle)

                -- Initialize last vehicle health if it's the first time
                if lastVehicleHealth == 0 then
                    lastVehicleHealth = currentHealth
                end
            end
        end
    end
end)

-- Listen for vehicle damage changes
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = GetPlayerPed(-1)
        if playerPed and IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed, false)
            
            if DoesEntityExist(vehicle) and IsEntityAVehicle(vehicle) then
                local currentHealth = GetVehicleBodyHealth(vehicle)
                local healthDifference = lastVehicleHealth - currentHealth

                if healthDifference > Config.MinHealthDifference then
                    -- Collision detected, trigger the event to check for stalling
                    TriggerEvent("carEngineStalling:checkStalling", vehicle)
                end

                -- Update last vehicle health
                lastVehicleHealth = currentHealth
            end
        end
    end
end)

-- Continuous check for clearing the screen effects after the dizzy effect duration
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)  -- Check every second

        if dizzyEffectActive and GetGameTimer() > dizzyEffectTimer then
            -- Clear the screen effects after the specified duration
            ClearScreenEffects()

            -- Reset flags and timer
            dizzyEffectActive = false
            dizzyEffectTimer = 0
        end
    end
end)
