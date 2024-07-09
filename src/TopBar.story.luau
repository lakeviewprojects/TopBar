local Player = game:GetService("Players").LocalPlayer

--[[ Dependancies ]]
local ReplicadStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicadStorage:WaitForChild("Fusion"))
local Children,OnEvent = Fusion.Children, Fusion.OnEvent

--[[ API Services ]]

local AvatarEditorService = game:GetService("AvatarEditorService");
local SocialService = game:GetService("SocialService");

local function TopBarButton(props)

    local isHovering = Fusion:Value(false)
    props.MaxImgSize = props.MaxImgSize or UDim2.new(0.8, 0, 0.8, 0)

    return Fusion:New "Frame" {
        BackgroundTransparency = 0.4;
        BackgroundColor3 = Color3.new(0,0,0);
        Visible = props.Visible or true;

        Size = UDim2.new(1, 0, 1, 0);
        [Children] = {
            Fusion:New "UIAspectRatioConstraint" {};

            Fusion:New "UICorner" {
                CornerRadius = UDim.new(1, 0);
            };

            Fusion:New "ImageButton" {
                BackgroundTransparency = 1;
                Image = props.Image;
                AnchorPoint = Vector2.new(0.5, 0.5);
                Position = UDim2.new(0.5, 0, 0.5, 0);

                --# Hover Color
                ImageColor3 = Fusion:Spring(Fusion:Computed(function(use)
                    if use(isHovering) == true then
                        return Color3.fromHex("#e6e6e6")
                    else 
                        return Color3.fromHex("#FFFFFF")
                    end
                end));
                
                --# Hover Size
                Size = Fusion:Spring(Fusion:Computed(function(use)
                    if use(isHovering) == true then 
                        return props.MaxImgSize or UDim2.new(0.8, 0, 0.8, 0);
                    else 
                        return UDim2.new(props.MaxImgSize.X.Scale*0.85, 0, props.MaxImgSize.Y.Scale*0.85, 0)
                    end
                end), 20);

                [OnEvent "Activated"] = function()
                    if props.OnClick ~= nil then 
                        props.OnClick()
                    end
                end;

                [OnEvent "MouseEnter"] = function()
                    isHovering:set(true)
                    --print(Fusion:peek(imageHover))
                end;

                [OnEvent "MouseLeave"] = function()
                    isHovering:set(false)
                end;

            }
        }
    }
end

local function CanInviteFriend(sendingPlayer : userdata)
	local success, canSend = pcall(function()
		return SocialService:CanSendGameInviteAsync(sendingPlayer)
	end)
	return success and canSend
end

local ShopModuleInstalled = function(Parent : userdata)
    local _shop = Parent:FindFirstChild("Shop")
    return _shop ~= nil and _shop:IsA("ModuleScript") == true
end

local VIPImage = function()
    local vip = Player:FindFirstChild("VIP")
    if vip ~= nil then 
        if vip.Value == true then 
            return "rbxassetid://18400213004"
        end 
    end 
    return "rbxassetid://18400214733"
end

return function (Parent : userdata?)
    Parent = Parent or script.Parent

    local TopBar = Fusion:New "ScreenGui" {
        Name = "TopBar";
        Parent = Parent;
        ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets;
    
        [Children] = {
            Fusion:New "Frame" {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 1, 0);
                --
                [Children] = {
                    Fusion:New "UIListLayout" {
                        FillDirection = Enum.FillDirection.Horizontal;
                        Padding = UDim.new(0, 10);
                    };

                    Fusion:New "UIPadding" {
                        PaddingTop = UDim.new(0.2, 0);
                        PaddingLeft = UDim.new(0, 10);
                    };

                    -- VIP
                    TopBarButton {
                        Visible = Player:FindFirstChild("VIP") ~= nil;
                        Image = VIPImage();
                        MaxImgSize = UDim2.new(0.8, 0, 0.8, 0);
                    };
                    
                    -- Favourite
                    TopBarButton {
                        Image = "rbxassetid://4458882827";
                        MaxImgSize = UDim2.new(0.9, 0, 0.9, 0);

                        OnClick = function()
                            pcall(function()
                                AvatarEditorService:PromptSetFavorite(game.PlaceId, 1, true)
                            end)
                            
                        end
                    };
                    
                    -- Friend Invite
                    TopBarButton {
                        Image = "rbxassetid://464353108";
                        MaxImgSize = UDim2.new(0.8, 0, 0.8, 0);

                        Visible = CanInviteFriend(Player);
                        OnClick = function()
                            pcall(function()
                                SocialService:PromptGameInvite(Player)
                            end)
                        end;
                    };

                    -- Shop
                    TopBarButton {
                        Image = "rbxassetid://11385419674";
                        MaxImgSize = UDim2.new(0.8, 0, 0.8, 0);

                        Visible = ShopModuleInstalled(Player.PlayerGui);
                        OnClick = function()
                            print("Shop")
                            if Player.PlayerGui:FindFirstChild("Shop") then
                                Player.PlayerGui.Shop.State:Fire()
                            end
                        end;
                    }
                };
            };
        }
    }

    --[[ module ]]

    return function ()
        TopBar:Destroy();
    end

end