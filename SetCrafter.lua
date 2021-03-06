-- Dolgubon's Lazy Set Crafter
-- Created December 2016
-- Last Modified: December 23 2016
-- 
-- Created by Dolgubon (Joseph Heinzle)
-----------------------------------
--
------------------------------------
-- Namespace and variable initialization
DolgubonSetCrafter = DolgubonSetCrafter or {}
DolgubonSetCrafter.initializeFunctions = DolgubonSetCrafter.initializeFunctions or {}
--77 81 91
DolgubonSetCrafter.defaultCharacter = 
{
	["OpenAtCraftStation"] = true,
	["autocraft"] = true,
	["closeOnExit"] = true,
	["useCharacterSettings"] = false,
	["showToggle"] = false,
}
DolgubonSetCrafter.default = {
	["queue"] = {},
	["xPos"] = 0,
	["yPos"] = 0,
	["counter"] = 0,
	[6697110] = false,
	["saveLastChoice"] = true,
	["accountWideProfile"] = DolgubonSetCrafter.defaultCharacter,
	["notifyWiped"] = true,
	['autoCraft'] = true,
	['toggleXPos'] = 50,
	['toggleYPost'] = 50,
	['width'] = 1050,
	['height'] = 650,
}



DolgubonSetCrafter.version = 5
DolgubonSetCrafter.name = "DolgubonsLazySetCrafter"


local out = DolgubonSetCrafter.out


--Takes in a number, determines if it's a simple integer with no exponents
local function isInteger(text)
	return not string.find(text,"d") and string.find(text,"e") and string.find(text,".",1,true) 
end

local previousText = ""
function DolgubonSetCrafter.onTextChanged()
	local text = DolgubonSetCrafterWindowInputBox:GetText()
	if tonumber(text) and not isInteger(text) then --if the string can be converted to a number then
		--updatePreview() --update the preview to the new level
		previousText = text
	elseif text=="" then --Do nothing if it is empty
		previousText = text
	else --else remove the most recently added item
		
		DolgubonSetCrafterWindowInputBox:SetText(previousText)
	end
end

function DolgubonSetCrafter.onEnter()
	--d(DolgubonsGuildBlacklistWindowInputBox:GetText())
end

function DolgubonSetCrafter:GetSettings()
	if self.charSavedVars.useCharacterSettings then
		return self.charSavedVars
	else
		return self.savedvars.accountWideProfile
	end
end


function DolgubonSetCrafter:Initialize()
	--[[LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
	LAM:RegisterAddonPanel("DolgubonsWritCrafter", DolgubonSetCrafter.settings["panel"])
	DolgubonSetCrafter.settings["options"] = DolgubonSetCrafter.langOptions()
	LAM:RegisterOptionControls("DolgubonsWritCrafter", DolgubonSetCrafter.settings["options"])]]
	

	DolgubonSetCrafter.savedvars = ZO_SavedVars:NewAccountWide("dolgubonslazysetcraftersavedvars", 
		DolgubonSetCrafter.version, nil, DolgubonSetCrafter.default)

	DolgubonSetCrafter.charSavedVars = ZO_SavedVars:NewCharacterIdSettings("dolgubonslazysetcraftersavedvars",
		DolgubonSetCrafter.version, nil, DolgubonSetCrafter.savedvars.accountWideProfile) 
		-- Use the account Wide profile as the default

	--[[EVENT_MANAGER:RegisterForEvent(DolgubonSetCrafter.name, EVENT_PLAYER_ACTIVATED, function() 
		if DolgubonSetCrafter.savedvars.notifyWiped then 
			d("Dolgubon's Lazy Set Crafter settings have been wiped with this update")
			DolgubonSetCrafter.savedvars.notifyWiped = false
		end end)]]

	LLC = LibStub:GetLibrary("LibLazyCrafting")
	if DolgubonSetCrafter.savedvars.debug then
		DolgubonSetCrafterWindow:SetHidden(false)
	end

	--if pcall(DolgubonSetCrafter.initializeFunctions.initializeSettingsMenu) then else d("Dolgubon's Lazy Set Crafter: USettings not loaded") end
	DolgubonSetCrafter.initializeFunctions.initializeSettingsMenu()
	--if pcall(DolgubonSetCrafter.initializeFunctions.initializeCrafting) then else d("Dolgubon's Lazy Set Crafter: UCrafting not loaded") end
	DolgubonSetCrafter.initializeFunctions.initializeCrafting()
	--if pcall(DolgubonSetCrafter.initializeFunctions.setupUI) then else d("Dolgubon's Lazy Set Crafter: UI not loaded") end
	DolgubonSetCrafter.initializeFunctions.setupUI()
	
	DolgubonSetCrafter.initializeFeedbackWindow()
end

local function closeWindow (optionalOverride)
	if optionalOverride==nil then optionalOverride = not DolgubonSetCrafterWindow:IsHidden() end
	DolgubonSetCrafterWindow:SetHidden(optionalOverride) 
	CraftingQueueScroll:SetHidden(optionalOverride)

end

DolgubonSetCrafter.close = closeWindow

local function slashcommand (input)closeWindow () end



function DolgubonSetCrafter.OnAddOnLoaded(event, addonName)
	--closeWindow()
	if addonName == DolgubonSetCrafter.name then
		DolgubonSetCrafter:Initialize()
	end
end 

EVENT_MANAGER:RegisterForEvent(DolgubonSetCrafter.name, EVENT_CRAFTING_STATION_INTERACT, 
	function(event, station) 
		if station <3 or station >5 then
			if not DolgubonSetCrafter:GetAutocraft() then
				DolgubonSetCrafter.toggleCraftButton(true)
			end
			if DolgubonSetCrafter:GetSettings().OpenAtCraftStation then 
				closeWindow(false) 
			else
				DolgubonSetCrafterToggle:SetHidden(false )
			end
		end 
	end)

EVENT_MANAGER:RegisterForEvent(DolgubonSetCrafter.name, EVENT_END_CRAFTING_STATION_INTERACT, 
	function(event, station) 
		if (station <3 or station >5) then
			DolgubonSetCrafter.toggleCraftButton(false)
			if DolgubonSetCrafter:GetSettings().closeOnExit then closeWindow(true) 
			end 
			if not DolgubonSetCrafter:GetSettings().showToggle then
				DolgubonSetCrafterToggle:SetHidden(true)
			end
		end
	end)
EVENT_MANAGER:RegisterForEvent(DolgubonSetCrafter.name, EVENT_ADD_ON_LOADED, DolgubonSetCrafter.OnAddOnLoaded)
--EVENT_MANAGER:RegisterForEvent(DolgubonSetCrafter.name, EVENT_CRAFT_COMPLETED , d)


SLASH_COMMANDS["/dlsc"] = slashcommand
SLASH_COMMANDS["/dsc"] = slashcommand
SLASH_COMMANDS["/setcrafter"] = slashcommand
SLASH_COMMANDS["/setcrafterdebugmode"] =
function() 
	DolgubonSetCrafter.savedvars.debug = not DolgubonSetCrafter.savedvars.debug 
	d("Debug mode toggled "..tostring(DolgubonSetCrafter.savedvars.debug)) closeWindow(not DolgubonSetCrafter.savedvars.debug )
	DolgubonSetCrafter.debugFunctions()

end
