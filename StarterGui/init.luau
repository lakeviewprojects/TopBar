--[[
	TopBar — Fusion 3

	Horizontal button strip rendered inside Roblox's topbar-safe inset area.
	Ships with a built-in **Favourite / Like+Join** button whose default
	action is `AvatarEditorService:PromptSetFavorite`.  Call
	`TopBarAPI:SetFavouriteAction(open, close, isOpenValue)` to replace
	that default with a custom panel (e.g. the Like & Join prompt).

	API returned by the factory:
	  • :SetVisible(bool)               — show / hide the entire bar
	  • :SetFavouriteAction(open, close, isOpen?)
	                                     — replace the favourite button action
	  • :TopBarButton(props)             — add a custom button (returns a
	                                       Fusion3 Value controlling visibility)

	Dependencies:
	  • ReplicatedFirst.Fusion3
]]

GLOBAL_PARENT = script

--[[ Dependencies ]]
local AvatarEditorService = game:GetService("AvatarEditorService")
local ReplicatedFirst     = game:GetService("ReplicatedFirst")

local Fusion3   = require(ReplicatedFirst:WaitForChild("Fusion3"))
local Children  = Fusion3.Children
local OnEvent   = Fusion3.OnEvent
local peek      = Fusion3.peek

--[[ Theme ]]
local THEME_IMG                 = "rbxassetid://15197955006"
local THEME_PRIMARY             = Color3.fromHex("#000000")
local THEME_SECONDARY           = Color3.fromHex("#FFFFFF")
local THEME_SECONDARY_HIGHLIGHT = Color3.fromHex("#CCCCCC")

--[[ Scope ]]
local scope = Fusion3.scoped(Fusion3)

--[[ State ]]
local TopBarItems   = scope:Value({})
local TopBarVisible = scope:Value(true)
local Current       = scope:Value(nil) -- close-callback for the currently open panel

--[[ Favourite Button — replaceable action ]]
local FavouriteAction = {
	Toggle = function()
		pcall(function()
			AvatarEditorService:PromptSetFavorite(game.PlaceId, 1, true)
		end)
	end,
	Open  = nil,
	Close = nil,
}
local FavouriteIsOpen = scope:Value(false)

--------------------------------------------------------------------------------
-- TopBar API
--------------------------------------------------------------------------------
local TopBarAPI = {}

--[[ Show / hide the entire TopBar strip. ]]
function TopBarAPI:SetVisible(visible: boolean)
	TopBarVisible:set(visible)
end

--[[
	Replace the built-in favourite button action.

	By default clicking the heart button calls
	`AvatarEditorService:PromptSetFavorite`.  Call this method to turn
	it into a toggle that opens / closes a custom panel instead.

	Parameters:
	  openCallback   — called when the button should open the panel
	  closeCallback  — called when the button should close the panel
	  externalIsOpen — (optional) a Fusion3 Value<boolean> that tracks
	                   whether the panel is open.  Keeps TopBar in sync
	                   when the panel is dismissed by other means (e.g. a
	                   "close" button inside the panel itself).
]]
function TopBarAPI:SetFavouriteAction(
	openCallback:   () -> (),
	closeCallback:  () -> (),
	externalIsOpen: Fusion3.UsedAs<boolean>?
)
	FavouriteAction.Toggle = nil
	FavouriteAction.Open   = openCallback
	FavouriteAction.Close  = closeCallback

	if externalIsOpen then
		scope:Observer(externalIsOpen):onChange(function()
			local extOpen = peek(externalIsOpen)
			if peek(FavouriteIsOpen) ~= extOpen then
				FavouriteIsOpen:set(extOpen)
				if not extOpen and peek(Current) == FavouriteAction.Close then
					Current:set(nil)
				end
			end
		end)
	end
end

--[[
	Add a custom button to the TopBar.

	Props:
	  Image          — asset id for the icon
	  ToggleCallback — fire-and-forget action (mutually exclusive with Open/Close)
	  OpenCallback   — called when button opens
	  CloseCallback  — called when button closes
	  ColorFrom      — icon colour at rest  (default white)
	  ColorTo        — icon colour on hover (default light grey)
	  InitialState   — if true, the button starts in the "open" state

	Returns a Fusion3 Value<boolean> controlling the button's visibility.
]]
function TopBarAPI:TopBarButton(props: {
	InitialState:   boolean?,
	Image:          string,
	OpenCallback:   (() -> ())?,
	CloseCallback:  (() -> ())?,
	ToggleCallback: (() -> ())?,
	ColorFrom:      Color3?,
	ColorTo:        Color3?,
})
	local isHover   = scope:Value(false)
	local isVisible = scope:Value(true)
	local isOpen    = scope:Value(false)

	local _button = scope:New "Frame" {
		BackgroundTransparency = 0.4;
		BackgroundColor3 = THEME_PRIMARY;
		Size = UDim2.new(1, 0, 1, 0);
		Visible = isVisible;

		[Children] = {
			scope:New "UIAspectRatioConstraint" {};

			scope:New "UICorner" {
				CornerRadius = UDim.new(1, 0);
			};

			-- Background texture
			scope:New "ImageLabel" {
				Name = "BG";
				Image = THEME_IMG;
				ImageColor3 = THEME_SECONDARY;
				Size = UDim2.new(1, 0, 1, 0);
				BackgroundTransparency = 1;
				ImageTransparency = 0.9;

				[Children] = {
					scope:New "UICorner" {
						CornerRadius = UDim.new(1, 0);
					};
				};
			};

			-- Icon
			scope:New "ImageLabel" {
				BackgroundTransparency = 1;
				Image = props.Image;
				AnchorPoint = Vector2.new(0.5, 0.5);
				Position = UDim2.new(0.5, 0, 0.5, 0);
				ZIndex = 2;

				ImageColor3 = scope:Spring(scope:Computed(function(use)
					if use(isHover) then
						return props.ColorTo or THEME_SECONDARY_HIGHLIGHT
					else
						return props.ColorFrom or THEME_SECONDARY
					end
				end));

				Size = scope:Spring(scope:Computed(function(use)
					if use(isHover) then
						return UDim2.new(0.8, 0, 0.8, 0)
					else
						return UDim2.new(0.7, 0, 0.7, 0)
					end
				end), 20);
			};

			-- Hit area
			scope:New "TextButton" {
				BackgroundTransparency = 1;
				TextTransparency = 1;
				Size = UDim2.new(1, 0, 1, 0);

				[OnEvent "Activated"] = function()
					if props.ToggleCallback ~= nil then
						props.ToggleCallback()
					else
						if peek(isOpen) then
							if props.CloseCallback then
								props.CloseCallback()
							end
							isOpen:set(false)
						else
							if peek(Current) ~= nil then
								peek(Current)()
							end
							if props.OpenCallback then
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
			};
		};
	}

	local items = peek(TopBarItems)
	table.insert(items, _button)
	TopBarItems:set(items)

	if props.InitialState == true then
		if props.OpenCallback ~= nil then
			props.OpenCallback()
			isOpen:set(true)
		end
	end

	return isVisible
end

--------------------------------------------------------------------------------
-- Internal: built-in Favourite / Like+Join button
--------------------------------------------------------------------------------
local function CreateFavouriteButton()
	local isHover = scope:Value(false)

	local _button = scope:New "Frame" {
		BackgroundTransparency = 0.4;
		BackgroundColor3 = THEME_PRIMARY;
		Size = UDim2.new(1, 0, 1, 0);

		[Children] = {
			scope:New "UIAspectRatioConstraint" {};

			scope:New "UICorner" {
				CornerRadius = UDim.new(1, 0);
			};

			scope:New "ImageLabel" {
				Name = "BG";
				Image = THEME_IMG;
				ImageColor3 = THEME_SECONDARY;
				Size = UDim2.new(1, 0, 1, 0);
				BackgroundTransparency = 1;
				ImageTransparency = 0.9;

				[Children] = {
					scope:New "UICorner" {
						CornerRadius = UDim.new(1, 0);
					};
				};
			};

			scope:New "ImageLabel" {
				BackgroundTransparency = 1;
				Image = "rbxassetid://80940953305634";
				AnchorPoint = Vector2.new(0.5, 0.5);
				Position = UDim2.new(0.5, 0, 0.5, 0);
				ZIndex = 2;

				ImageColor3 = scope:Spring(scope:Computed(function(use)
					if use(isHover) then
						return Color3.fromHex("#ff0000")
					else
						return Color3.fromHex("#c50000")
					end
				end));

				Size = scope:Spring(scope:Computed(function(use)
					if use(isHover) then
						return UDim2.new(0.8, 0, 0.8, 0)
					else
						return UDim2.new(0.7, 0, 0.7, 0)
					end
				end), 20);
			};

			scope:New "TextButton" {
				BackgroundTransparency = 1;
				TextTransparency = 1;
				Size = UDim2.new(1, 0, 1, 0);

				[OnEvent "Activated"] = function()
					if FavouriteAction.Toggle ~= nil then
						FavouriteAction.Toggle()
					else
						if peek(FavouriteIsOpen) then
							if FavouriteAction.Close then
								FavouriteAction.Close()
							end
							FavouriteIsOpen:set(false)
						else
							if peek(Current) ~= nil then
								peek(Current)()
							end
							if FavouriteAction.Open then
								FavouriteAction.Open()
							end
							FavouriteIsOpen:set(true)
							Current:set(FavouriteAction.Close)
						end
					end
				end;

				[OnEvent "MouseEnter"] = function()
					isHover:set(true)
				end;

				[OnEvent "MouseLeave"] = function()
					isHover:set(false)
				end;
			};
		};
	}

	local items = peek(TopBarItems)
	table.insert(items, 1, _button)
	TopBarItems:set(items)
end

--------------------------------------------------------------------------------
-- Top Bar Construction
--------------------------------------------------------------------------------
local TopBar = nil

local function Construct()
	CreateFavouriteButton()

	TopBar = scope:New "ScreenGui" {
		Name = "TopBar";
		Parent = GLOBAL_PARENT;
		ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets;

		[Children] = {
			scope:New "Frame" {
				BackgroundTransparency = 1;
				Size = UDim2.new(1, 0, 1, 0);
				Visible = TopBarVisible;

				[Children] = {
					scope:New "UIListLayout" {
						FillDirection = Enum.FillDirection.Horizontal;
						Padding = UDim.new(0, 10);
					};

					scope:New "UIPadding" {
						PaddingTop = UDim.new(0.2, 0);
						PaddingLeft = UDim.new(0, 10);
					};

					TopBarItems;
				};
			};
		};
	}
end

--------------------------------------------------------------------------------
-- Factory — returns the API
--------------------------------------------------------------------------------
return function(parent: Instance?)
	if parent ~= nil then
		GLOBAL_PARENT = parent
	end

	if TopBar == nil then
		Construct()
	end

	return TopBarAPI
end

