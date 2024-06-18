-- [doorIdx] = eDoorState
g_routedDoorsState = { }

-- [doorIdx] = markedGameTimer
local g_routedDoorsToDispose = { }

-- [doorIdx] = true
local g_doorsAwaitingRouting = { }

local g_doorInterationThread = false

local g_useGarageDoorDistanceCheck = false

local g_doorEntriesInRange = { }
local g_probeCollidedDoorEntry

local gDoorEntityPositionCacheByIdx = { }

local PRE_INTERACTION_DOOR_AUTH_DISTANCE = 3.10

local DOOR_INTERACTION_RANGE_TPP = 4.25
local DOOR_INTERACTION_RANGE_FPP = 3.0
local DOOR_INTERACTION_RANGE_IN_VEHICLE = 8.5

local DOOR_CONSIDERED_IN_SCOPE_RANGE = 25.0

local DOOR_DISPOSE_GAMETIMER_THRESHOLD_MS = 15000

local prompt_group_open
local prompt_open

local prompt_group_close
local prompt_close

RegisterCommand('cl_door_debug', function(source, args, raw)

    print('########')
    print('g_routedDoorsState'    , json.encode(g_routedDoorsState    , { indent = true }))
    print('g_routedDoorsToDispose', json.encode(g_routedDoorsToDispose, { indent = true }))
    
    print('g_doorsAwaitingRouting', json.encode(g_doorsAwaitingRouting, { indent = true }))
end)

function DoorSystem:GetDoorState(doorIdx)
    local state = g_routedDoorsState[doorIdx] or DoorDatabase:GetItemDefaultState(doorIdx) or eDoorState.LOCKED_UNBREAKABLE

    return state
end

function DoorSystem:PlayDoorInteractionAnimation()
    local dict = "script_common@jail_cell@unlock@key"

    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(10)
        end
    end

    local ped = PlayerPedId()

    local prop = CreateObject("P_KEY02X", GetEntityCoords(ped) + vec3(0, 0, 0.2), true, true, true)
    local boneIndex = GetEntityBoneIndexByName(ped, "SKEL_R_Finger12")

    TaskPlayAnim(ped, "script_common@jail_cell@unlock@key", "action", 8.0, -8.0, 2500, 31, 0, true, 0, false, 0, false)
    Wait(750)
    AttachEntityToEntity(prop, ped, boneIndex, 0.02, 0.0120, -0.00850, 0.024, -160.0, 200.0, true, true, false, true, 1, true)

    while IsEntityPlayingAnim(ped, "script_common@jail_cell@unlock@key", "action", 3) do
        Wait(100)
    end

    DeleteObject(prop)

end

function DoorSystem:SetDoorState(doorIdx, state)
    -- print('DoorSystem:SetDoorState', doorIdx, state)

    g_routedDoorsState[doorIdx] = state

    g_doorsAwaitingRouting[doorIdx] = nil

    local pairDoorIdx = DoorDatabase:GetItemPairItemIndex(doorIdx)

    if pairDoorIdx then
        g_routedDoorsState[pairDoorIdx] = state

        g_doorsAwaitingRouting[pairDoorIdx] = nil

        DoorSystem:UpdateDoorState(pairDoorIdx)
    end

    DoorSystem:UpdateDoorState(doorIdx)
end

function DoorSystem:UpdateDoorState(doorIdx)
    local state = g_routedDoorsState[doorIdx]

    if state then
        local doorDoorHash = DoorDatabase:GetItemDoorHash(doorIdx)

        DoorSystemSetDoorState(doorDoorHash, state, true, false)
    end 
end

function DoorSystem:GetDoorEntityFromHash(doorHash)
    -- GetEntityByDoorhash
    local entity = Citizen.InvokeNative(0xF7424890E4A094C0, doorHash, 0)
    
    -- if not DoesEntityExist(entity) then
    --     return error( ('Não foi encontrada uma entidade para a porta de hash(%X)'):format(doorHash) )
    -- end

    return entity
end

CreateThread(function()
    initPrompts()
    while true do
        local playerPed      = PlayerPedId()
        local playerPosition = GetEntityCoords(playerPed)

        local clDistance    = nil 

        local toRouteDoors = { }

        local localUseGarageDoorDistanceCheck = false
        local localDoorEntriesInRange = { }

        -- Then we have atleast one door of that model near us.

        for doorIdx, door in pairs( DoorDatabase:GetItems() ) do

            --[[ doorId ]]
            local doorHash = door.door_hash

            -- print('door', json.encode(door, { indent = true }))

            local entity = DoorSystem:GetDoorEntityFromHash(doorHash)

            if entity ~= 0 then

                local doorPosition = GetEntityCoords(entity)

                gDoorEntityPositionCacheByIdx[doorIdx] = doorPosition

                local distanceToDoor = #(playerPosition - doorPosition)

                if distanceToDoor <= DOOR_CONSIDERED_IN_SCOPE_RANGE then

                    if not g_routedDoorsState[doorIdx] and not g_doorsAwaitingRouting[doorIdx] then
                        local pairDoorIdx = DoorDatabase:GetItemPairItemIndex(doorIdx)

                        if not pairDoorIdx or not g_doorsAwaitingRouting[pairDoorIdx] then
                            table.insert(toRouteDoors, doorIdx)
                            g_doorsAwaitingRouting[doorIdx] = true
                        end
                    end

                    local doorAuthDistance = PRE_INTERACTION_DOOR_AUTH_DISTANCE

                    --[[
                    local isDoorGarageDoor = DoorDatabase:GetIsItemDoorGarage(doorIdx)
                    
                    if isDoorGarageDoor then
                        doorAuthDistance = PRE_INTERACTION_DOOR_AUTH_DISTANCE * 3.5
                    end
                    ]]

                    -- The that door is the closest one to us

                    if #(playerPosition - doorPosition) <= doorAuthDistance then
                        localDoorEntriesInRange[#localDoorEntriesInRange + 1] =
                        {
                            index = doorIdx,
                            entity = entity,
                        }

                        --[[
                        if isDoorGarageDoor then
                            localUseGarageDoorDistanceCheck = true
                        end
                        ]]

                        -- print('localDoorEntriesInRange', json.encode(localDoorEntriesInRange))
                    end
                else
                    gDoorEntityPositionCacheByIdx[doorIdx] = nil 
                end
            end
        end

        g_useGarageDoorDistanceCheck = localUseGarageDoorDistanceCheck
        g_doorEntriesInRange = localDoorEntriesInRange

        if #g_doorEntriesInRange > 0 then
            if not g_doorInterationThread then
                thread_doorInteraction()
            end
        else
            g_doorInterationThread = false
        end

        -- print('toRouteDoors', json.encode(toRouteDoors))

        if #toRouteDoors > 0 then
            TriggerServerEvent('doorSystemMultipleAddRoutingTarget', toRouteDoors)
        end

        computeDisposableRoutedDoors(playerPosition)

        Wait(1000)
    end
end)

function thread_doorInteraction()
    g_doorInterationThread = true 

    local playerPed = PlayerPedId()

    -- Same as probeCollidedDoorEntry.index, but for faster access.
    local probeCollidedDoorIndex = nil
    local probeCollidedDoorDrawPosition = nil

    CreateThread(function()
        while g_doorInterationThread do
            Wait(100)

            playerPed = PlayerPedId()

            local playerVehicle = GetVehiclePedIsIn(playerPed, true)

            local isPlayerInAnyVehicle = playerVehicle ~= 0

            local INTERACTION_RANGE_THIS_FRAME = isPlayerInAnyVehicle and DOOR_INTERACTION_RANGE_IN_VEHICLE or (Citizen.InvokeNative(0xD1BA66940E94C547) == 4 and DOOR_INTERACTION_RANGE_FPP or DOOR_INTERACTION_RANGE_TPP)
            
            if g_useGarageDoorDistanceCheck then
                INTERACTION_RANGE_THIS_FRAME = INTERACTION_RANGE_THIS_FRAME * 4.0
            end

            local cameraRotation = GetGameplayCamRot()
            local cameraCoord = GetGameplayCamCoord()

            local cameraFwVec = RotationToDirection(cameraRotation)

            local toIgnoreEntity = isPlayerInAnyVehicle and playerVehicle or playerPed

            local shapeTestHnd = StartShapeTestCapsule(cameraCoord, cameraCoord + (cameraFwVec * INTERACTION_RANGE_THIS_FRAME), 0.10, 16, toIgnoreEntity, 4)

            local retval, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(shapeTestHnd)

            while retval == 1 do
                retval, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(shapeTestHnd)

                Wait(0)
            end

            local probeCollidedDoorEntry = nil

            if hit == 1 then
                for _, inRangeDoorEntry in ipairs(g_doorEntriesInRange) do
                    local doorIdx = inRangeDoorEntry.index
                    local doorEntity = inRangeDoorEntry.entity
                    
                    if entityHit == doorEntity then
                        probeCollidedDoorEntry = inRangeDoorEntry
                        break
                    end
                end
            end

            g_probeCollidedDoorEntry = probeCollidedDoorEntry

            local computeDrawPosition = (probeCollidedDoorEntry and probeCollidedDoorIndex ~= probeCollidedDoorEntry.index)

            probeCollidedDoorIndex = probeCollidedDoorEntry and probeCollidedDoorEntry.index or nil

            if computeDrawPosition then
                local pairDoorItemIndex = DoorDatabase:GetItemPairItemIndex(probeCollidedDoorIndex)

                local pointA, pointB

                if pairDoorItemIndex then
                    pointA = gDoorEntityPositionCacheByIdx[probeCollidedDoorIndex]
                    pointB = gDoorEntityPositionCacheByIdx[pairDoorItemIndex]
                else
                    local doorEntity = probeCollidedDoorEntry.entity
                    local doorModel = GetEntityModel(doorEntity)

                    local minimum, maximum = GetModelDimensions(doorModel)

                    pointA = GetOffsetFromEntityInWorldCoords(doorEntity, minimum.x, minimum.y, 0.0)
                    pointB = GetOffsetFromEntityInWorldCoords(doorEntity, maximum.x, maximum.y, 0.0)
                end

                probeCollidedDoorDrawPosition = vec3( (pointA.x + pointB.x) / 2, (pointA.y + pointB.y) / 2, pointA.z)
            end
        end

        g_probeCollidedDoorEntry = nil
    end)

    CreateThread(function()

        while g_doorInterationThread do
            Wait(0)

            if g_probeCollidedDoorEntry then
                local doorState = g_routedDoorsState[probeCollidedDoorIndex]

                -- local doorStateText = doorState == eDoorState.UNLOCKED
                --                     and PromptSetActiveGroupThisFrame(prompt_group_open, CreateVarString(10, "LITERAL_STRING", "Porta"))
                --                     or  PromptSetActiveGroupThisFrame(prompt_group_close, CreateVarString(10, "LITERAL_STRING", "Porta"))

                local doorPromptState 

                if doorState == eDoorState.UNLOCKED then
                    doorPromptState = prompt_close
                    PromptSetActiveGroupThisFrame(prompt_group_close, CreateVarString(10, "LITERAL_STRING", "Porta Aberta"))
                else 
                    doorPromptState = prompt_open
                    PromptSetActiveGroupThisFrame(prompt_group_open, CreateVarString(10, "LITERAL_STRING", "Porta Fechada"))
                end

                -- DrawText3D(probeCollidedDoorDrawPosition, doorStateText)

                if PromptHasHoldModeCompleted(doorPromptState) then

                    PromptSetEnabled(doorPromptState, false)
                    Citizen.CreateThread(
                        function()
                            Citizen.Wait(250)
                            PromptSetEnabled(doorPromptState, true)
                        end
                    )                    
                    local doorIdx = g_probeCollidedDoorEntry.index
                    
                    TriggerServerEvent('doorSystemPlayerRequestDoorStateChange', doorIdx)
                end

                -- if IsControlJustPressed(0, `INPUT_ENTER` --[[ ALT ]]) then
                --     local doorIdx = g_probeCollidedDoorEntry.index
                --     TriggerServerEvent('doorSystemPlayerRequestDoorStateChange', doorIdx)
                -- end
            end
        end
    end)
end

function computeDisposableRoutedDoors(playerPosition)

    local gameTimer = GetGameTimer()

    local toUnrouteDoors = { }

    for doorIdx, disposedGameTimer in pairs(g_routedDoorsToDispose) do

        if gameTimer - disposedGameTimer >= DOOR_DISPOSE_GAMETIMER_THRESHOLD_MS then

            g_routedDoorsToDispose[doorIdx] = nil

            g_routedDoorsState[doorIdx] = nil

            table.insert(toUnrouteDoors, doorIdx)

            -- print( ('(%d) was disposed'):format(doorIdx) )
        end
    end

    -- print('toUnrouteDoors', json.encode(toUnrouteDoors))

    if #toUnrouteDoors > 0 then
        TriggerServerEvent('doorSystemMultipleRemoveRoutingTarget', toUnrouteDoors)
    end

    for doorIdx, state in pairs(g_routedDoorsState) do

        local isDisposable = g_routedDoorsToDispose[doorIdx]

        local doorPosition = gDoorEntityPositionCacheByIdx[doorIdx] -- DoorDatabase:GetItemPosition(doorIdx)

        if not doorPosition then
            return
        end

        if #(playerPosition - doorPosition) > DOOR_CONSIDERED_IN_SCOPE_RANGE then
            if not isDisposable then
                g_routedDoorsToDispose[doorIdx] = GetGameTimer()

                -- print( ('Marking (%d) as disposable'):format(doorIdx) )
            end
        else
            if isDisposable then
                g_routedDoorsToDispose[doorIdx] = nil

                -- print( ('Unmarking (%d) as disposable'):format(doorIdx) )
            end
        end
    end
end

function doorSystemHandleDoorStatesChange(states)
    for doorIdx, state in pairs(states) do
        DoorSystem:SetDoorState(doorIdx, state)
    end
end

function initPrompts()
    prompt_group_open = GetRandomIntInRange(0, 0xffffff)

    prompt_open = PromptRegisterBegin()
    PromptSetControlAction(prompt_open, 0x8AAA0AD4)
    PromptSetText(prompt_open, CreateVarString(10, "LITERAL_STRING", "Abrir"))
    PromptSetEnabled(prompt_open, true)
    PromptSetVisible(prompt_open, true)
    PromptSetHoldMode(prompt_open, true)
    PromptSetGroup(prompt_open, prompt_group_open)
    PromptRegisterEnd(prompt_open)

    prompt_group_close = GetRandomIntInRange(0, 0xffffff)

    prompt_close = PromptRegisterBegin()
    PromptSetControlAction(prompt_close, 0x8AAA0AD4)
    PromptSetText(prompt_close, CreateVarString(10, "LITERAL_STRING", "Fechar"))
    PromptSetEnabled(prompt_close, true)
    PromptSetVisible(prompt_close, true)
    PromptSetHoldMode(prompt_close, true)
    PromptSetGroup(prompt_close, prompt_group_close)
    PromptRegisterEnd(prompt_close)
end


RegisterNetEvent('doorSystemSetDoorsState', doorSystemHandleDoorStatesChange)

RegisterNetEvent('doorSystemSetDoorState', function(doorIdx, state)
    doorSystemHandleDoorStatesChange({ [doorIdx] = state })
end)

RegisterNetEvent('forceDoorInteractionAnimationOnPlayer', function()
    DoorSystem:PlayDoorInteractionAnimation()
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() == resourceName then
        PromptDelete(prompt_open)
        PromptDelete(prompt_close)
    end
end)

RegisterNetEvent('tryLockpickingDoor', function(lockpickHealth)
    if g_probeCollidedDoorEntry then
        local doorIdx = g_probeCollidedDoorEntry.index

        if doorIdx then
            local tryLockpick = exports.lockpicking:lockpick(lockpickHealth, 10, 10, 10)
            if tryLockpick then
                TriggerServerEvent("doorSystemLockipickDoorStateChange", doorIdx)
            end
        end
    end
end)