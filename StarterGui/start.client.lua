--[[
	TopBar — Client Bootstrap

	Initialises the TopBar module.  The favourite / like+join button is
	built into TopBar itself (see init.luau).  Other modules can call
	TopBarAPI:SetFavouriteAction() to replace the default PromptSetFavorite
	behaviour with a custom panel.
]]

local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

require(script.Parent)(PlayerGui)