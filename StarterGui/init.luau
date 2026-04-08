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
local Workspace           = game:GetService("Workspace")

local Fusion3   = require(ReplicatedFirst:WaitForChild("Fusion3"))
local Children  = Fusion3.Children
local OnEvent   = Fusion3.OnEvent
local peek      = Fusion3.peek

--[[ Theme ]]
local THEME_IMG                 = "rbxassetid://15197955006"
local THEME_PRIMARY             = Color3.fromHex("#000000")
local THEME_SECONDARY           = Color3.fromHex("#FFFFFF")
local THEME_SECONDARY_HIGHLIGHT = Color3.fromHex("#CCCCCC")

--[[ Compact / Dropdown Constants ]]
local LV_LOGO           = "http://www.roblox.com/asset/?id=15208062328"
local BUTTON_DIAMETER   = 36 -- approx pixel diameter of one button
local BUTTON_GAP        = 10
local BAR_PADDING_LEFT  = 10
local SCREEN_FRACTION   = 1 / 5

--[[ Scope ]]
local scope = Fusion3.scoped(Fusion3)

--[[ State ]]
local TopBarItems    = scope:Value({})
local TopBarVisible  = scope:Value(true)
local Current        = scope:Value(nil) -- close-callback for the currently open panel
local DropdownOpen   = scope:Value(false)
local ViewportWidth  = scope:Value(1920) -- updated from camera ViewportSize

-- Compact mode: true when the bar would exceed 1/3 of screen width
local CompactMode = scope:Computed(function(use)
	local count = #use(TopBarItems)
	local barWidth = BAR_PADDING_LEFT + count * BUTTON_DIAMETER + math.max(0, count - 1) * BUTTON_GAP
	return barWidth > use(ViewportWidth) * SCREEN_FRACTION
end)

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
	Image:          string?,
	Text:           Fusion3.UsedAs<string>?,
	OpenCallback:   (() -> ())?,
	CloseCallback:  (() -> ())?,
	ToggleCallback: (() -> ())?,
	ColorFrom:      Color3?,
	ColorTo:        Color3?,
})
	local isHover   = scope:Value(false)
	local isVisible = scope:Value(true)
	local isOpen    = scope:Value(false)

	-- Icon: TextLabel when Text is provided, ImageLabel otherwise
	local iconSize = scope:Spring(scope:Computed(function(use)
		if use(isHover) then
			return UDim2.new(0.8, 0, 0.8, 0)
		else
			return UDim2.new(0.7, 0, 0.7, 0)
		end
	end), 20)

	local iconColor = scope:Spring(scope:Computed(function(use)
		if use(isHover) then
			return props.ColorTo or THEME_SECONDARY_HIGHLIGHT
		else
			return props.ColorFrom or THEME_SECONDARY
		end
	end))

	local iconElement
	if props.Text ~= nil then
		iconElement = scope:New "TextLabel" {
			BackgroundTransparency = 1;
			Text = props.Text;
			TextScaled = true;
			TextColor3 = iconColor;
			AnchorPoint = Vector2.new(0.5, 0.5);
			Position = UDim2.new(0.5, 0, 0.5, 0);
			ZIndex = 2;
			Size = iconSize;
		}
	else
		iconElement = scope:New "ImageLabel" {
			BackgroundTransparency = 1;
			Image = props.Image;
			ImageColor3 = iconColor;
			AnchorPoint = Vector2.new(0.5, 0.5);
			Position = UDim2.new(0.5, 0, 0.5, 0);
			ZIndex = 2;
			Size = iconSize;
		}
	end

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
			iconElement;

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

--------------------------------------------------------------------------------
-- Optional Music mute button (only if Music module exists in ReplicatedFirst)
--------------------------------------------------------------------------------
local function CreateMuteButton()
	local ReplicatedFirst = game:GetService("ReplicatedFirst")
	local MusicModule = ReplicatedFirst:FindFirstChild("Music")
	if not MusicModule then return end

	local Music = require(MusicModule)
	local MuteText = scope:Value(Music.Muted and "\u{1F508}" or "\u{1F50A}") -- 🔈 / 🔊

	TopBarAPI:TopBarButton {
		Text = MuteText;
		ToggleCallback = function()
			Music:ToggleMute()
			MuteText:set(Music.Muted and "\u{1F508}" or "\u{1F50A}")
		end;
	}
end

--------------------------------------------------------------------------------
-- Compact-mode: LV logo button
--------------------------------------------------------------------------------
local function CreateLVButton()
	local isHover = scope:Value(false)

	return scope:New "Frame" {
		Name = "LVButton";
		BackgroundTransparency = 0.4;
		BackgroundColor3 = THEME_PRIMARY;
		Size = UDim2.new(1, 0, 1, 0);
		LayoutOrder = -1; -- always first in the list
		Visible = CompactMode;

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

			-- LV logo icon
			scope:New "ImageLabel" {
				BackgroundTransparency = 1;
				Image = LV_LOGO;
				ImageColor3 = scope:Spring(scope:Computed(function(use)
					if use(isHover) then
						return THEME_SECONDARY_HIGHLIGHT
					else
						return THEME_SECONDARY
					end
				end));
				AnchorPoint = Vector2.new(0.5, 0.5);
				Position = UDim2.new(0.5, 0, 0.5, 0);
				ZIndex = 2;
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
					DropdownOpen:set(not peek(DropdownOpen))
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
end

local function Construct()
	CreateFavouriteButton()
	CreateMuteButton()

	local lvButton = CreateLVButton()

	-- Track viewport width from the camera
	local camera = Workspace.CurrentCamera
	if camera then
		local function updateViewport()
			ViewportWidth:set(camera.ViewportSize.X)
		end
		updateViewport()
		camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateViewport)
	end

	-- Close dropdown when leaving compact mode
	scope:Observer(CompactMode):onChange(function()
		if not peek(CompactMode) then
			DropdownOpen:set(false)
		end
	end)

	-- Items container — holds all registered buttons, switches between
	-- inline (horizontal, same row as LV) and dropdown (vertical, below LV)
	local itemsFrame = scope:New "Frame" {
		Name = "Items";
		BackgroundTransparency = 1;
		AutomaticSize = Enum.AutomaticSize.XY;
		Size = UDim2.new(0, 0, 0, 0);
		Visible = scope:Computed(function(use)
			return not use(CompactMode) or use(DropdownOpen)
		end);

		[Children] = {
			scope:New "UIListLayout" {
				FillDirection = scope:Computed(function(use)
					if use(CompactMode) then
						return Enum.FillDirection.Vertical
					else
						return Enum.FillDirection.Horizontal
					end
				end);
				Padding = scope:Computed(function(use)
					if use(CompactMode) then
						return UDim.new(0, 6)
					else
						return UDim.new(0, BUTTON_GAP)
					end
				end);
			};

			TopBarItems;
		};
	}

	TopBar = scope:New "ScreenGui" {
		Name = "TopBarGui";
		Parent = GLOBAL_PARENT;
		ResetOnSpawn = true;
		DisplayOrder = 100;
		ScreenInsets = Enum.ScreenInsets.TopbarSafeInsets;

		[Children] = {
			scope:New "Frame" {
				Name = "TopBarFrame";
				BackgroundTransparency = 1;
				Size = UDim2.new(1, 0, 0.75, 0);
				AnchorPoint = Vector2.new(0, 0.5);
				Position = UDim2.new(0, 0, 0.5, 0);
				ClipsDescendants = false;
				Visible = TopBarVisible;

				[Children] = {
					scope:New "UIListLayout" {
						FillDirection = scope:Computed(function(use)
							if use(CompactMode) then
								return Enum.FillDirection.Vertical
							else
								return Enum.FillDirection.Horizontal
							end
						end);
						Padding = scope:Computed(function(use)
							if use(CompactMode) then
								return UDim.new(0, 4)
							else
								return UDim.new(0, BUTTON_GAP)
							end
						end);
						SortOrder = Enum.SortOrder.LayoutOrder;
					};

					scope:New "UIPadding" {
						PaddingLeft = UDim.new(0, BAR_PADDING_LEFT);
					};

					lvButton;
					itemsFrame;
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

