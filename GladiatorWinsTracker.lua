local currentAchievementId
local characterHasObtainedAchievement
local GWT_Button

local frame = CreateFrame("frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ACHIEVEMENT_EARNED")

frame:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "GladiatorWinsTracker" then
	-- Set character saved variable if none
		if not GWT_HideButton then
			GWT_HideButton = "default"
		end
	end
	
	-- Only setup the button once the parent frame has loaded
	if event == "ADDON_LOADED" and arg1 == "Blizzard_PVPUI" then
		setUpButton()
		updateButtonVisibility()
	end
	
	-- Setup variables
	if event == "PLAYER_LOGIN" then
		setCurrentPVPSeasonAchieveId()
		setCharacterHasObtainedAchievement()
	end
	
	-- Check if button should hide after achievement obtained during session
	if event == "ACHIEVEMENT_EARNED" and arg1 == currentAchievementId then
		setCharacterHasObtainedAchievement()
		updateButtonVisibility()
	end
end)

function setUpButton()
	-- ConquestFrame is not nil as Blizzard_PVPUI has loaded
	GWT_Button = CreateFrame("Button", "GWTButton", ConquestFrame, "UIPanelButtonTemplate")
	GWT_Button:SetSize(200, 35)
	GWT_Button:SetText("Track Gladiator Wins")
	GWT_Button:SetPoint("BOTTOMRIGHT", 168, -35)
	
	GWT_Button:SetScript("OnClick", function()
		-- Check that theres a valid achievement ID and not already obtained
		if currentAchievementId ~= 0 and not characterHasObtainedAchievement then
			local trackedAchievements = { GetTrackedAchievements() }
			-- Handle no tracked achievements
			if trackedAchievements[1] == nil then
				RunScript("AddTrackedAchievement(" .. currentAchievementId .. ")")
			end
			-- Iterate over tracked achievements
			for i,v in ipairs(trackedAchievements) do
				if v == currentAchievementId then
					RunScript("RemoveTrackedAchievement(" .. currentAchievementId .. ")")
				-- dont add achieve if 10 tracked already
				elseif GetNumTrackedAchievements() < 10 then
					RunScript("AddTrackedAchievement(" .. currentAchievementId .. ")")
				end
			end
		end
	end)
end

function updateButtonVisibility()
	-- Check if button visibility has been overridden
	if GWT_HideButton ~= "default" then
		if GWT_HideButton == "true" then
			GWT_Button:Hide()
		elseif GWT_HideButton == "false" then
			GWT_Button:Show()
		end
	-- Else check if achievement has been completed on this character
	elseif characterHasObtainedAchievement then
		GWT_Button:Hide()
	else 
		GWT_Button:Show()
	end	
end

function setCharacterHasObtainedAchievement()
	if currentAchievementId ~= 0 then
		local id, _, _, completed, _, _, _, _, _, _, _, _, wasEarnedByMe = GetAchievementInfo(currentAchievementId)
		if completed and wasEarnedByMe then
			characterHasObtainedAchievement = true
		else 
			characterHasObtainedAchievement = false
		end
	end
end

SLASH_GWT1 = "/GWT"
SlashCmdList["GWT"] = function(msg, editbox)
   handleSlashCommand(msg, editbox)
end 

function setCurrentPVPSeasonAchieveId()
	local currentPVPSeason = GetCurrentArenaSeason()
	if currentPVPSeason == 0 then currentAchievementId = 0 -- No active arena season
	elseif currentPVPSeason == 30 then currentAchievementId = 14689 -- Gladiator: Shadowlands Season 1
	elseif currentPVPSeason == 31 then currentAchievementId = 14689 -- Gladiator: Shadowlands Season 2 (when added to game files)
	elseif currentPVPSeason == 32 then currentAchievementId = 14689 -- Gladiator: Shadowlands Season 3 (when added to game files)
	end
end

function handleSlashCommand(msg, editbox)
	-- hide
	-- show
	-- reset
	if msg == "hide" then 
		GWT_HideButton = "true"
		sendHideSlashCommand()
	elseif msg == "show" then
		GWT_HideButton = "false"
		sendShowSlashCommand()
	elseif msg == "reset" then 
		GWT_HideButton = "default"
		sendResetSlashCommand()
	else
		sendHelpSlashCommand()
	end
	if GWT_Button then
		updateButtonVisibility()
	end
end

function sendHelpSlashCommand()
	DEFAULT_CHAT_FRAME:AddMessage(" ", 0.25, 1.0, 0.75)
	DEFAULT_CHAT_FRAME:AddMessage("--- Gladiator Wins Tracker ---", 0.25, 1.0, 0.25)
	DEFAULT_CHAT_FRAME:AddMessage(" ", 0.25, 1.0, 0.75)
	DEFAULT_CHAT_FRAME:AddMessage("|cFFEEEE00/gwt hide|r -- hide button for this character", 0.25, 1.0, 0.75)
	DEFAULT_CHAT_FRAME:AddMessage("|cFFEEEE00/gwt show|r -- show button for this character", 0.25, 1.0, 0.75)
	DEFAULT_CHAT_FRAME:AddMessage("|cFFEEEE00/gwt reset|r -- restore default settings on this character", 0.25, 1.0, 0.75)
end

function sendHideSlashCommand()
	DEFAULT_CHAT_FRAME:AddMessage(" ", 0.25, 1.0, 0.75)
	DEFAULT_CHAT_FRAME:AddMessage("---> GWT button hidden (Run /GWT show to show again)", 0.25, 1.0, 0.75)
end

function sendShowSlashCommand()
	DEFAULT_CHAT_FRAME:AddMessage(" ", 0.25, 1.0, 0.75)
	DEFAULT_CHAT_FRAME:AddMessage("---> GWT button shown in rated PVP tab", 0.25, 1.0, 0.75)
end

function sendResetSlashCommand()
	DEFAULT_CHAT_FRAME:AddMessage(" ", 0.25, 1.0, 0.75)
	DEFAULT_CHAT_FRAME:AddMessage("---> Restored default settings for this character", 0.25, 1.0, 0.75)
end