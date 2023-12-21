# -FIVEM-Standalone-Engine-Stalling
A simple standalone script that stalls your vehicle upon impact and also causes dizziness to the player (U were in an accident it's the least u get)
 You can configure :
 1. Stall Duration
 2. Minimum Speed for Stalling
 3. Minimum Damage for Collision
 4. Dizziness Duration
 5. Dizziness Intensity
in the config.lua

Integration

1. Add the below function to the alerts.lua in the ps-dispatch script
    ```
    local function VehicleAccident()
    local coords = GetEntityCoords(cache.ped)
    local vehicle = GetVehicleData(cache.vehicle)

    local dispatchData = {
        message = locale('accident'),
        codeName = 'accident',
        code = '10-29',
        icon = 'fas fa-car',
        priority = 2,
        coords = coords,
        street = GetStreetAndZone(coords),
        heading = GetPlayerHeading(),
        vehicle = vehicle.name,
        plate = vehicle.plate,
        color = vehicle.color,
        class = vehicle.class,
        doors = vehicle.doors,
        jobs = { 'leo','ems' }
    }

    TriggerServerEvent('ps-dispatch:server:notify', dispatchData)
```
end
exports('VehicleAccident', VehicleAccident)

and then add "  "accident": "Vehicle Collision Occured",  " to the locale file you are using
then add the script to the resources folder and ensure it in the server.cfg or start it via the server console and it should work.

Contact: Discord (badassfalcon)
