
g_doorSystemStates = { }

local g_doorSystemRoutingTargets = { }

local g_playersRoutedDoors = { }

RegisterCommand('sv_door_debug', function(source, args, raw)

    print('########')
    print('g_doorSystemStates'        , json.encode(g_doorSystemStates        , { indent = true }))

    print('g_doorSystemRoutingTargets', json.encode(g_doorSystemRoutingTargets, { indent = true }))

    print('g_playersRoutedDoors'      , json.encode(g_playersRoutedDoors      , { indent = true }))
end)

CreateThread(function()
    for doorIdx, item in ipairs(DoorDatabase:GetItems()) do
        g_doorSystemStates[doorIdx] = item.state or eDoorState.LOCKED_UNBREAKABLE
    end
end)

function DoorSystem:SetDoorState(doorIdx, state)

    g_doorSystemStates[doorIdx] = state

    local routingTargets = g_doorSystemRoutingTargets[doorIdx] or { }

    local targets = { }

    for player, _ in pairs(routingTargets) do
        targets[player] = true
    end

    local pairDoorIdx = DoorDatabase:GetItemPairItemIndex(doorIdx)

    if pairDoorIdx then
        g_doorSystemStates[pairDoorIdx] = state

        local pairRoutingTargets = g_doorSystemRoutingTargets[pairDoorIdx] or { }

        for player, _ in pairs(pairRoutingTargets) do
            targets[player] = true
        end
    end

    print('doorIdx', doorIdx, state)

    for target, _ in pairs(targets) do
        TriggerClientEvent('doorSystemSetDoorState', target, doorIdx, state)
    end
end

function DoorSystem:IsPlayerRoutingTarget(doorIdx, player)
    local routingTargets = g_doorSystemRoutingTargets[doorIdx] or { }

    if routingTargets then
        return routingTargets[player] ~= nil
    end

    return false
end

-- #TODO We should really add positions checks here!
function DoorSystem:AddRoutingTarget(doorIdx, player, fromClient)
    if not DoorSystem:IsPlayerRoutingTarget(doorIdx, player) then
        if not g_doorSystemRoutingTargets[doorIdx] then
            g_doorSystemRoutingTargets[doorIdx] = { }
        end

        g_doorSystemRoutingTargets[doorIdx][player] = true

        if not g_playersRoutedDoors[player] then
            g_playersRoutedDoors[player] = { }
        end

        g_playersRoutedDoors[player][doorIdx] = true

        if fromClient then
            TriggerClientEvent('doorSystemSetDoorState', player, doorIdx, g_doorSystemStates[doorIdx])
        end

        return true
    end

    return false
end

function DoorSystem:RemoveRoutingTarget(doorIdx, player, fromClient, canRmvPlayerRouted)
    local routingTargets = g_doorSystemRoutingTargets[doorIdx] or { }

    local removed = false
    
    if routingTargets then

        if routingTargets[player] then
            routingTargets[player] = nil

            if not fromClient then
                TriggerClientEvent('doorSystemDisposeDoorState', player, doorIdx)
            end

            removed = true
        end
    end

    if canRmvPlayerRouted then
        local routedDoors = g_playersRoutedDoors[player]

        if routedDoors then
            routedDoors[doorIdx] = nil
        end
    end

    return removed
end

function DoorSystem:MultipleAddRoutingTarget(doorsIdx, player)
    local states = { }

    local numStates = 0

    for _, doorIdx in ipairs(doorsIdx) do
        -- `fromClient` as false because we'll send our own packed event.
        if DoorSystem:AddRoutingTarget(doorIdx, player, false) then
            states[doorIdx] = g_doorSystemStates[doorIdx]

            numStates = numStates +1
        end
    end

    -- print('MultipleAddRoutingTarget', json.encode(states))

    if numStates > 0 then
        TriggerClientEvent('doorSystemSetDoorsState', player, states)
    end
end

function DoorSystem:MultipleRemoveRoutingTarget(doorsIdx, player)
    for _, doorIdx in ipairs(doorsIdx) do
        DoorSystem:RemoveRoutingTarget(doorIdx, player, false, false)
    end
end 

function DoorSystem:GetDoorState(doorIdx)
    return g_doorSystemStates[doorIdx]
end

-- #TODO We should really add positions checks here!
-- Add permissions checks.
-- Commerce owner-ship checks.
RegisterNetEvent('doorSystemPlayerRequestDoorStateChange', function(doorIdx)
    local source = source

    local doorPosition = DoorDatabase:GetItemPosition(doorIdx)

    --[[
    local isPlayerCommerceOwner = false

    local commerceId = Commerce:GetCommerceIdFromPlayer(source)

    if commerceId then
        isPlayerCommerceOwner = Commerce:GetIsCommerceOwnerPlayer(commerceId, source)
    end
    ]]

    local isPlayerAllowedToChangeState = DoorSystem:IsPlayerAllowedToChangeState(doorIdx, source)

    --[[
    if (commerceId and (not isPlayerCommerceOwner and not isPlayerAllowedToChangeState)) or (not commerceId and not isPlayerAllowedToChangeState) then
        return
    end
    ]]

    if not isPlayerAllowedToChangeState then
        TriggerClientEvent("texas:notify:native", source, "Você não pode abrir essa porta!", 4000)
        return
    end

    local doorState = g_doorSystemStates[doorIdx]

    if not doorState then
        return
    end

    if doorState == eDoorState.UNLOCKED then
        doorState = eDoorState.LOCKED_UNBREAKABLE
    elseif doorState == eDoorState.LOCKED_UNBREAKABLE then
        doorState = eDoorState.UNLOCKED
    end

    DoorSystem:SetDoorState(doorIdx, doorState)

    TriggerClientEvent('forceDoorInteractionAnimationOnPlayer', source)
end)

RegisterNetEvent('doorSystemLockipickDoorStateChange', function(doorIdx)
    local source = source

    local doorPosition = DoorDatabase:GetItemPosition(doorIdx)

    local doorState = g_doorSystemStates[doorIdx]

    if not doorState then
        return
    end

    if doorState == eDoorState.UNLOCKED then
        doorState = eDoorState.LOCKED_UNBREAKABLE
    elseif doorState == eDoorState.LOCKED_UNBREAKABLE then
        doorState = eDoorState.UNLOCKED
    end

    DoorSystem:SetDoorState(doorIdx, doorState)
end)

RegisterNetEvent('doorSystemAddRoutingTargetFromDoors', function(doorsIdx)
    local source = source

    DoorSystem:AddRoutingTarget(doorIdx, player, true)
end)

RegisterNetEvent('doorSystemRemoveRoutingTargetFromDoors', function(doorsIdx)
    local source = source

    DoorSystem:RemoveRoutingTarget(doorIdx, player, true)
end)

RegisterNetEvent('doorSystemMultipleAddRoutingTarget', function(doorsIdx)
    local source = source

    DoorSystem:MultipleAddRoutingTarget(doorsIdx, source)
end)

RegisterNetEvent('doorSystemMultipleRemoveRoutingTarget', function(doorsIdx)
    local source = source

    DoorSystem:MultipleRemoveRoutingTarget(doorsIdx, source)
end)

AddEventHandler('playerDropped', function()
    local source = source

    local routedDoors = g_playersRoutedDoors[source]

    if routedDoors then
        for doorIdx, _ in pairs(routedDoors) do
            DoorSystem:RemoveRoutingTarget(doorIdx, source, false, false)
        end

        g_playersRoutedDoors[source] = nil
    end
end)