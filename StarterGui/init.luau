GLOBAL_PARENT = script

--[[ Dependancies ]]
local Player = game:GetService("Players").LocalPlayer

local ReplicadStorage = game:GetService("ReplicatedStorage")

local Fusion = require(ReplicadStorage:WaitForChild("Fusion"))
local Children,OnEvent = Fusion.Children, Fusion.OnEvent

--[[ Theme Stuff ]]

local THEME_IMG = "rbxassetid://15197955006"
local THEME_PRIMARY = Color3.fromHex("#000000")
local THEME_SECONDARY = Color3.fromHex("#FFFFFF")
local THEME_SECONDARY_HIGHLIGHT = Color3.fromHex("#CCCCCC")

--[[ TopBar API ]]

local TopBarItems = Fusion:Value({})

local TopBarAPI = {}

local TopBarVisible = Fusion:Value(true)

-- For buttons with open/close 
local Current = Fusion:Value(nil)

--[[ Change TopBar Visible State ]]

function TopBarAPI:SetVisible(visible : boolean)
    TopBarVisible:set(visible)
end

--[[
    Construct top bar buttons
    Cannot be destroyed once created, however they can be made visible or invisible. 
    Returns Fusion.Value
--]]
function TopBarAPI:TopBarButton(props : {InitialState : Boolean?, Image : string, OpenCallback : Callback?, CloseCallback : Callback?, ToggleCallback : Callback?, ColorFrom : Color3?, ColorTo : Color3?}) : Fusion.Value
    -- Mouse or press
    local isHover = Fusion:Value(false) 
    -- Hide or show
    local isVisible = Fusion:Value(true)

    -- for things with open and close 
    local isOpen = Fusion:Value(false)

    local _button = Fusion:New "Frame" {
        BackgroundTransparency = 0.4;
        BackgroundColor3 = THEME_PRIMARY;
        Size = UDim2.new(1, 0, 1, 0);
        Visible = isVisible;

        [Children] = {
            Fusion:New "UIAspectRatioConstraint" {};

            Fusion:New "UICorner" {
                CornerRadius = UDim.new(1, 0);
            };

            -- Background
            Fusion:New "ImageLabel" {
                Name = "BG";
                Image = THEME_IMG;
                ImageColor3 = THEME_SECONDARY;
                Size = UDim2.new(1, 0, 1, 0);
                BackgroundTransparency = 1;
                ImageTransparency = 0.9;

                [Children] = {
                    Fusion:New "UICorner" {
                        CornerRadius = UDim.new(1, 0);
                    };
                }

            };
            
            Fusion:New "ImageLabel" {
                BackgroundTransparency = 1;
                Image = props.Image;
                AnchorPoint = Vector2.new(0.5, 0.5);
                Position = UDim2.new(0.5, 0, 0.5, 0);
                ZIndex = 2;

                --# Hover Color
                ImageColor3 = Fusion:Spring(Fusion:Computed(function(use)
                    if use(isHover) == true then
                        return props.ColorTo or THEME_SECONDARY_HIGHLIGHT
                    else 
                        return props.ColorFrom or THEME_SECONDARY
                    end
                end));
                
                --# Hover Size
                Size = Fusion:Spring(Fusion:Computed(function(use)
                    if use(isHover) == true then 
                        return UDim2.new(0.8, 0, 0.8, 0)
                    else 
                        return UDim2.new(0.7, 0, 0.7, 0)
                    end
                end), 20);
            };

            Fusion:New "TextButton" {
                BackgroundTransparency = 1;
                TextTransparency = 1;
                Size = UDim2.new(1, 0, 1, 0);
                
                [OnEvent "Activated"] = function()
                    if props.ToggleCallback ~= nil then 
                        props.ToggleCallback()
                    else 
                        if Fusion.peek(isOpen) == true then 
                            if props.Force ~= nil then 
                                props.Force(false)
                            else 
                                props.CloseCallback()
                            end 
                            isOpen:set(false)
                        else 
                            if Fusion.peek(Current) ~= nil then 
                                Fusion.peek(Current)()
                            end
                            if props.Force ~= nil then 
                                props.Force(false)
                            else 
                                props.OpenCallback()
                            end
                            isOpen:set(true)
                            Current:set(props.CloseCallback)
                        end
                    end
                
                end;

                [OnEvent "MouseEnter"] = function()
                    isHover:set(true)
                end;

                [OnEvent "MouseLeave"] = function()
                    isHover:set(false)
                end;
            }
        }
    }

    --[[ Append button to the top bar ]]
    local items = Fusion.peek(TopBarItems)
    table.insert(items, _button);
    TopBarItems:set(items)

    if props.InitialState == true then 
        if props.OpenCallback ~= nil then 
            props.OpenCallback()
            isOpen:set(true)
        end 
    end

    --
    return isVisible
end

--[[ Top Bar Construction ]]
local TopBar = nil

local function Construct()
    TopBar = Fusion:New "ScreenGui" {
        Name = "TopBar";
        Parent = GLOBAL_PARENT;
        ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets;
        
        [Children] = {
            Fusion:New "Frame" {
                BackgroundTransparency = 1;
                Size = UDim2.new(1, 0, 1, 0);
                Visible = TopBarVisible;
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

                    -- TopBar Items
                    TopBarItems;
                }
            }
        }
    }
end

--[[ Return the API ]]

return function (parent : Instance)
    if parent ~= nil then 
        GLOBAL_PARENT = parent
    end 

    if TopBar == nil then 
        Construct()
    end 

    return TopBarAPI
end

