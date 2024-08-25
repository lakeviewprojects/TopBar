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
    Callback = AddToFavourites;
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
    TopBarAPI:TopBarButton {
        Image = "rbxassetid://464353108";
        Callback = function()
            pcall(function()
                SocialService:PromptGameInvite(Player)
            end)
        end;
        ColorFrom = Color3.fromHex("#FFFFFF");
        ColorTo = Color3.fromHex("#ffff00");
    }
end