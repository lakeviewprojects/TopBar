local ProximityPromptService = game:GetService("ProximityPromptService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Player = game:GetService("Players").LocalPlayer

--[[ Dependancies ]]
local ReplicadStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicadStorage:WaitForChild("Fusion"))

--[[ API Services ]]

local AvatarEditorService = game:GetService("AvatarEditorService");
local SocialService = game:GetService("SocialService");

local function TopBarButton(props)

    local isHovering = Fusion:Value(false)

    local imageHover = Fusion:Computed(function(use)
        if Fusion:peek(isHovering) then
            return Color3.fromHex("#e6e6e6")
        else 
            return Color3.new("#ffffff")
        end
    end)
    
    local imageSize = Fusion:Spring(Fusion:Computed(function()
        if Fusion:peek(isHovering) == true then 
            return props.MaxImgSize or UDim2.new(0.8, 0, 0.8, 0);
        else 
            if props.MaxImgSize ~= nil then 
                return UDim2.new(props.MaxImgSize.X.Scale*0.8, 0, props.MaxImgSize.Y.Scale*0.8, 0)
            else 
                return UDim2.new(0.6, 0, 0.6, 0);
            end
        end
    end), 0.05, 0.002)

    return Fusion:New "Frame" {
        BackgroundTransparency = 0.4;
        BackgroundColor3 = Color3.new(0,0,0);
        Visible = props.Visible or true;

        Size = UDim2.new(1, 0, 1, 0);
        [Fusion.Children] = {
            Fusion:New "UIAspectRatioConstraint" {};

            Fusion:New "UICorner" {
                CornerRadius = UDim.new(1, 0);
            };

            Fusion:New "ImageButton" {
                BackgroundTransparency = 1;
                Image = props.Image;
                AnchorPoint = Vector2.new(0.5, 0.5);
                Position = UDim2.new(0.5, 0, 0.5, 0);
                ImageColor3 = imageColor;
                Size = imageSize;

                [Fusion.OnEvent "Activated"] = function()
                    if props.OnClick ~= nil then 
                        props.OnClick()
                    end
                end;

                [Fusion.OnEvent "MouseEnter"] = function()
                    isHovering:set(true)
                    --print(Fusion:peek(imageHover))
                end;

                [Fusion.OnEvent "MouseLeave"] = function()
                    isHovering:set(false)
                end;

            }
        }
    }
end

local function CanInviteFriend(sendingPlayer)
	local success, canSend = pcall(function()
		return SocialService:CanSendGameInviteAsync(sendingPlayer)
	end)
	return success and canSend
end

return function (Parent)
    Parent = Parent or script.Parent

    local TopBar = Fusion:New "ScreenGui" {
        Name = "TopBar";
        Parent = Parent;
        ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets;
        
        
        [Fusion.Children] = {
            Fusion:New "Frame" {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 1, 0);
                --
                [Fusion.Children] = {
                    Fusion:New "UIListLayout" {
                        FillDirection = Enum.FillDirection.Horizontal;
                        Padding = UDim.new(0, 10);
                    };

                    Fusion:New "UIPadding" {
                        PaddingTop = UDim.new(0.2, 0);
                        PaddingLeft = UDim.new(0, 10);
                    };

                    TopBarButton {
                        Image = "rbxassetid://4458882827";
                        MaxImgSize = UDim2.new(0.9, 0, 0.9, 0);

                        OnClick = function()
                            AvatarEditorService:PromptSetFavorite(game.PlaceId, 1, true)
                        end
                    };
                    --
                    TopBarButton {
                        Image = "rbxassetid://464353108";
                        MaxImgSize = UDim2.new(0.8, 0, 0.8, 0);

                        Visible = CanInviteFriend(Player);
                        OnClick = function()
                            SocialService:PromptGameInvite(Player)
                        end;
                    };
                    
                };
            };
        }
    }

    --[[ Cleanup ]]
    return function ()
        TopBar:Destroy();
    end

end