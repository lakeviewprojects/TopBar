local HttpService = game:GetService("HttpService")
local Player = game:GetService("Players").LocalPlayer
local TopBarAPI = require(script.Parent)()

--[[ Buttons from the factory ]]

-- Favourite
local AvatarEditorService = game:GetService("AvatarEditorService");

local function AddToFavourites()
    pcall(function()
        AvatarEditorService:PromptSetFavorite(game.PlaceId, 1, true)
    end)
end

TopBarAPI:TopBarButton {
    Image = "rbxassetid://80940953305634";
    ToggleCallback = AddToFavourites;
    ColorFrom = Color3.fromHex("#c50000");
    ColorTo = Color3.fromHex("#ff0000");
}

-- Invite Friends
local SocialService = game:GetService("SocialService");

local function CanInviteFriend(sendingPlayer : Player)
	local success, canSend = pcall(function()
		return SocialService:CanSendGameInviteAsync(sendingPlayer)
	end)
	return success and canSend
end

if CanInviteFriend(Player) == true then 
    -- Reward purposes
    local inviteOptions = Instance.new("ExperienceInviteOptions")
    local _launchData = {
        InviteOrigin = Player.UserId 
    }
    inviteOptions.LaunchData = HttpService:JSONEncode(_launchData);
    --
    TopBarAPI:TopBarButton {

        Image = "rbxassetid://464353108";
        ToggleCallback = function()
            pcall(function()
                SocialService:PromptGameInvite(Player, inviteOptions)
            end)
        end;

        ColorFrom = Color3.fromHex("#FFFFFF");
        ColorTo = Color3.fromHex("#ffff00");
    }
end