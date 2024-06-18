
local g_doorDatabaseNumItems = 0
local g_doorDatabaseItems    = { }

-- Quick model lookup
local g_doorModelToDoors = { }

local g_handleToItemIndex = { }

function door(data)
    if #data <= 0 then
        return
    end

    g_doorDatabaseNumItems = g_doorDatabaseNumItems + 1
    local itemIdx = g_doorDatabaseNumItems

    local handle = nil
    local doorHashAsString = nil

    for _, t in ipairs(data) do
        for property, value in pairs(t) do
            data[property] = value

            if property == 'handle' then
                handle = value
            elseif property == 'door_hash' then
                doorHashAsString = value
            elseif property == 'model' then
                if not g_doorModelToDoors[value] then
                    g_doorModelToDoors[value] = { }
                end

                -- Model to doors lookup.
                table.insert(g_doorModelToDoors[value], itemIdx)
            end
        end

        data[_] = nil
    end

    if IS_CLIENT then
        local doorHash = tonumber(doorHashAsString)
        
        data.door_hash = doorHash

        -- AddDoorToSystemNew
        Citizen.InvokeNative(0xD99229FE93B46286, doorHash, true, false --[[ bIsNetworked ]], false, 0 --[[ iThreadId ]], 0, false)
    end

    table.insert(g_doorDatabaseItems, data)

    if handle then
        data.handle = handle

        if g_handleToItemIndex[handle] then
            print('Duplicate door handle! They should be unique!', handle)
        end

        g_handleToItemIndex[handle] = itemIdx
    end

    return itemIdx
end

function commerce_door(data)
    local itemIdx = door(data) 

    g_doorDatabaseItems[itemIdx].is_commerce_door = true
end

function garage_door(data)
    local itemIdx = door(data) 

    g_doorDatabaseItems[itemIdx].is_garage_door = true
end

function handle(hnd)
    return {
        handle = hnd
    }
end

function door_hash(v)
    return {
        door_hash = v
    }
end

function model(mdl)
    local isHex = string.sub(mdl, 0, 2) == '0x'

    if isHex then
        mdl = tonumber(string.sub(mdl, 2, string.len(mdl)))
    else
        mdl = tonumber(mdl) or GetHashKey(mdl)
    end

    return {
        model = mdl
    }
end

function position(data)
    return {
        position = vec3(table.unpack(data))
    }
end

function state(str)
    return {
        state = eDoorState[str]
    }
end

function allowed_groups(data)
    return {
        allowed_groups = data
    }
end

function pair(hnd)
    return {
        pair = hnd
    }
end

function property(data)
    return {
        property = data
    }
end

DoorDatabase = { }

function DoorDatabase:GetItems()
    return g_doorDatabaseItems
end

function DoorDatabase:ModelToItemsLookup()
    return g_doorModelToDoors
end

function DoorDatabase:GetItemPosition(itemIdx)
    return g_doorDatabaseItems[itemIdx].position
end

function DoorDatabase:GetItemModel(itemIdx)
    return g_doorDatabaseItems[itemIdx].model
end

function DoorDatabase:GetItemDefaultState(itemIdx)
    return g_doorDatabaseItems[itemIdx].state
end

function DoorDatabase:GetItemDoorHash(itemIdx)
    return g_doorDatabaseItems[itemIdx].door_hash
end

function DoorDatabase:GetItemAllowedGroups(itemIdx)
    return g_doorDatabaseItems[itemIdx].allowed_groups or { }
end

function DoorDatabase:GetIsItemDoorGarage(itemIdx)
    return g_doorDatabaseItems[itemIdx].is_garage_door ~= nil
end

function DoorDatabase:GetItemPairHandle(itemIdx)
    return g_doorDatabaseItems[itemIdx].pair
end

function DoorDatabase:GetItemHasPair(itemIdx)
    return DoorDatabaseGetItemPairHandle(itemIdx) ~= nil
end

function DoorDatabase:GetItemPairItemIndex(itemIdx)
    return g_handleToItemIndex[DoorDatabase:GetItemPairHandle(itemIdx)]
end

function DoorDatabase:GetItemPairItem(itemIdx)
    return g_doorDatabaseItems[DoorDatabase:GetItemPairItemIndex(itemIdx)]
end

function DoorDatabase:GetItemIndexByHandle(doorItemHandle)
    return g_handleToItemIndex[doorItemHandle]
end

function DoorDatabase:GetItemHandleByIndex(itemIdx)
    for doorHandle, doorIdx in pairs(g_handleToItemIndex) do
        if doorIdx == itemIdx then
            return doorHandle
        end
    end
end

function DoorDatabase:CheckIfDoorIsFromProperty(itemIdx)
    return g_doorDatabaseItems[itemIdx].property
end

exports('RegisterDoorAtDatabaseByExternal', function(data)
    local door_data = {
        handle(data.handle),
        door_hash(data.door_hash),
        allowed_groups(data.allowed_groups),
        state(data.state),
    }

    if data.property then
        table.insert(door_data, property(data.property))
    end

    if data.position then
        table.insert(door_data, position(data.position))
    end

    if data.pair then
        table.insert(door_data, pair(data.pair))
    end

    local itemIdx = door(door_data)

    if not IS_CLIENT then
        g_doorSystemStates[itemIdx] = data.state or eDoorState.LOCKED_UNBREAKABLE
    end
end)

if IS_CLIENT then
    AddEventHandler('onResourceStop', function(resource)
        if resource == GetCurrentResourceName() then
            for _, item in ipairs(g_doorDatabaseItems) do
                RemoveDoorFromSystem(item.door_hash)
            end
        end
    end)

    RegisterCommand('_debug_entity_coords', function(source, args, raw)

        local entityHnd = tonumber(args[1])

        if entityHnd then
            print('_debug_entity_coords', GetEntityCoords(entityHnd))
        end
    end)
end