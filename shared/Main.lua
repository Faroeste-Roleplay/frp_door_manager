IS_FXSERVER = GetGameName() == 'fxserver'
IS_CLIENT = not IS_FXSERVER

DoorSystem = { }


if IS_FXSERVER then
    local Tunnel = module("frp_lib", "lib/Tunnel")
    local Proxy = module("frp_lib", "lib/Proxy")
    
    Business = Proxy.getInterface("business")
    API = Proxy.getInterface("API")
    cAPI = Tunnel.getInterface("API")
else
    local Tunnel = module("frp_lib", "lib/Tunnel")
    local Proxy = module("frp_lib", "lib/Proxy")
    
    API = Tunnel.getInterface("API")
    cAPI = Proxy.getInterface("API")
end

function DoorSystem:IsPlayerAllowedToChangeState(doorIdx, player)
    
    local doorHandle = DoorDatabase:GetItemHandleByIndex(doorIdx)

    local allowedGroups = DoorDatabase:GetItemAllowedGroups(doorIdx)

    local playerPermission

    if IS_FXSERVER then
        local p = promise.new()
        
        local User = API.GetUserFromSource( tonumber( player ) )
        local charId = User:GetCharacterId()

        local isDoorOfProperty = DoorDatabase:CheckIfDoorIsFromProperty(doorIdx)
        
        if isDoorOfProperty then
            local playerHasPermission = exports['properties']:GetPersonaPermissionOnProperty(charId, doorHandle) or false
            return playerHasPermission
        end
    end

    local ret = #allowedGroups <= 0

    for _, allowGroup in ipairs(allowedGroups) do

        if IS_FXSERVER then
            local User = API.GetUserFromSource( tonumber( player ) )
            local Character = User:GetCharacter()
            local citizenId = Character:GetCitizenId()

            playerPermission = Business.hasClassePermission(citizenId, allowGroup) or API.IsPlayerAceAllowedGroup(player, allowGroup)
        else
            playerPermission = API.IsPlayerAceAllowedGroup(allowGroup)
        end

        if playerPermission then
            ret = true
            break
        end
    end

    return playerPermission
end