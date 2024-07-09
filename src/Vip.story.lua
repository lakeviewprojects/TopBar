local Player = game:GetService("Players").LocalPlayer

--[[ Dependancies ]]
local ReplicadStorage = game:GetService("ReplicatedStorage")
local Fusion = require(ReplicadStorage:WaitForChild("Fusion"))
local Children,OnEvent = Fusion.Children, Fusion.OnEvent

local VIP_Message = "Like the game and Join LakeView Games on Roblox for FREE VIP!"

return function (Parent : userdata?)
    Parent = Parent or script.Parent

    local isOpen = Fusion:Value(true)

    local GetVipGui = Fusion:New "ScreenGui" {
        Name = "GetVipGui";
        Parent = Parent;

        [Children] = {
            --[[ Container ]]
            Fusion:New "Frame" {
                BackgroundTransparency = 0.6;
                Size = UDim2.new(0.6, 0, 0.5, 0);
                AnchorPoint = Vector2.new(0.5, 0.5);
                Position = Fusion:Spring(Fusion:Computed(function(use)
                    if use(isOpen) == true then 
                        return UDim2.new(0.5, 0, 0.5, 0);
                    else 
                        return UDim2.new(-1.3, 0, 0.5, 0);
                    end
                end), 10);

                [Children] = {

                    Fusion:New "UIAspectRatioConstraint" {
                        AspectRatio = 16/9;
                    };

                    Fusion:New "UISizeConstraint" {
                        MaxSize = Vector2.new(500, 500);
                        MinSize = Vector2.new(300, 300);
                    };
                    Fusion:New "UICorner" {
                        CornerRadius = UDim.new(0, 10);
                    };

                    Fusion:New "ImageLabel" {
                        Name = "BG";
                        Image = "rbxassetid://15197955006";
                        ImageColor3 = Color3.fromHex("#FFFFFF");
                        AnchorPoint = Vector2.new(0.5, 0.5);
                        Position = UDim2.new(0.5, 0, 0.5, 0);
                        Size = UDim2.new(0.98, 0, 0.98, 0);
                        BackgroundTransparency = 1;
                        ImageTransparency = 0.3;
                        BorderSizePixel = 0;
                
                        [Fusion.Children] = {
                            Fusion:New "UICorner" {
                                CornerRadius = UDim.new(0, 10)
                            },
                            Fusion:New "UIGradient" {
                                Color = ColorSequence.new {
                                    ColorSequenceKeypoint.new(0, Color3.fromHex("#2E3192")),
                                    ColorSequenceKeypoint.new(1, Color3.fromHex("#1BFFFF"))
                                };
                                Rotation = -60;
                            },
                        };
                    };

                    --[[ Close Button]]
                    Fusion:New "Frame" {
                        Name = "CloseButton";
                        Size = UDim2.new(0.075, 0, 0.075, 0);
                        BackgroundColor3 = Color3.fromHex("#FF0000");
                        BackgroundTransparency = 0.8;
                        AnchorPoint = Vector2.new(1, 0);
                        Position = UDim2.new(0.98,0,0.02, 0);
                        ZIndex = 2;

                        [Children] = {
                            Fusion:New "UIAspectRatioConstraint" {};
                            Fusion:New "UICorner" {
                                CornerRadius = UDim.new(1, 0);
                            };

                            Fusion:New "TextButton" {
                                Size = UDim2.new(0.8, 0, 0.8, 0);
                                AnchorPoint = Vector2.new(0.5, 0.5);
                                Position = UDim2.new(0.5, 0, 0.5, 0);
                                BackgroundColor3 = Color3.fromHex("#b30000");
                                TextColor3 = Color3.fromHex("#FFFFFF");
                                Font = Enum.Font.SourceSansBold;
                                TextScaled = true;
                                Text = "X";

                                [Children] = {
                                    Fusion:New "UICorner" {
                                        CornerRadius = UDim.new(1, 0);
                                    };
                                };

                                [OnEvent "Activated"] = function()
                                    isOpen:set(false);
                                end;

                            }
                        }
                    };

                    --[[ Container ]]
                    Fusion:New "Frame" {
                        Name = "Container";
                        BackgroundTransparency = 1; 
                        AnchorPoint = Vector2.new(0.5, 0.5);
                        Position = UDim2.new(0.5, 0, 0.5, 0);
                        Size = UDim2.new(0.9, 0, 0.9, 0);
                        ClipsDescendants = true;
                        
                        [Children] = {
                            Fusion:New "TextLabel" {
                                Name = "Header";
                                Size = UDim2.new(0.4, 0, 0.15, 0);
                                AnchorPoint = Vector2.new(0.5, 0);
                                Position = UDim2.new(0.5, 0, 0, 0);
                                Text = "Free VIP";
                                Font = Enum.Font.LuckiestGuy;
                                --FontWeight = Enum.FontWeight.Bold;
                                TextColor3 = Color3.fromHex("#00ff00");
                                TextStrokeTransparency = 0.5;
                                TextScaled = true;
                                BackgroundTransparency = 1;
                            };

                            Fusion:New "Frame" {
                                Name = "Seperator";
                                Size = UDim2.new(1, 0, 0, 2);
                                Position = UDim2.new(0, 0, 0.125, 0);
                                BackgroundColor3 = Color3.fromHex("#FFFFFF");
                                BackgroundTransparency = 0.2
                            };

                            Fusion:New "TextLabel" {
                                Name = "Body";
                                Size = UDim2.new(0.8, 0, 0.6, 0);
                                AnchorPoint = Vector2.new(0.5, 0);
                                Position = UDim2.new(0.5, 0, 0.25, 0);
                                BackgroundTransparency = 1;
                                TextStrokeTransparency = 0.5;
                                TextScaled = true;
                                Font = Enum.Font.SourceSansBold;
                                TextColor3 = Color3.fromHex("#FFFFFF");
                                Text = VIP_Message;
                            }
                        }
                    };

                }
            }
        }


    }

    return GetVipGui;

end 