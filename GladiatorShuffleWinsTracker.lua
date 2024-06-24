local GWTVersion, currentGladAchievementId, currentLegendAchievementId, characterHasObtainedGladAchievement, characterHasObtainedLegendAchievement, GWT_Button, SWT_Button

local GWT = CreateFrame("frame")
GWT:RegisterEvent("ADDON_LOADED")
GWT:RegisterEvent("PLAYER_LOGIN")
GWT:RegisterEvent("ACHIEVEMENT_EARNED")

GWT:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "GladiatorShuffleWinsTracker" then
		-- Set character glad saved variable if none
		if not GWT_HideButton then
			GWT_HideButton = "default"
		end

		-- Set character shuffle saved variable if none
		if not SWT_HideButton then
			SWT_HideButton = "default"
		end

		-- Set account saved variable if none
		if not GWT_LoginIntro then
			GWT_LoginIntro = "true"
		end
	end

	-- Only setup the button once the parent frame has loaded
	if event == "ADDON_LOADED" and arg1 == "Blizzard_PVPUI" then
		setUpButtons()
		updateGladButtonVisibility()
		updateShuffleButtonVisibility()
	end

	-- Setup variables
	if event == "PLAYER_LOGIN" then
		setGWTVersion()
		setCurrentPVPSeasonGladAchieveId()
		setCurrentPVPSeasonShuffleLegendAchieveId()
		setCharacterHasObtainedGladAchievement()
		setCharacterHasObtainedShuffleLegendAchievement()
		createOptions()
		if GWT_LoginIntro == "true" then
			print("|cff33ff99Gladiator & Shuffle Wins Tracker|r - use |cffFF4500 /gwt |r to open options")
		end
	end

	-- Check if button should hide after achievement obtained during session
	if event == "ACHIEVEMENT_EARNED" and arg1 == currentGladAchievementId then
		setCharacterHasObtainedGladAchievement()
		setCharacterHasObtainedShuffleLegendAchievement()
		updateGladButtonVisibility()
		updateShuffleButtonVisibility()
	end
end)

function setUpButtons()
	-- ConquestFrame is not nil as Blizzard_PVPUI has loaded
	GWT_Button = CreateFrame("Button", "GWTButton", ConquestFrame, "UIPanelButtonTemplate")
	GWT_Button:SetSize(200, 35)
	GWT_Button:SetText("Track Gladiator Wins")
	GWT_Button:SetPoint("BOTTOMRIGHT", 168, -34)

	GWT_Button:SetScript("OnClick", function()
		-- Check that theres a valid achievement ID and not already obtained
		if currentGladAchievementId == 0 then
			message("|cffffff00No active pvp season found|r")
		elseif not characterHasObtainedGladAchievement then
			C_ContentTracking.ToggleTracking(2, currentGladAchievementId, 2)
		end
	end)

	-- ConquestFrame is not nil as Blizzard_PVPUI has loaded
	SWT_Button = CreateFrame("Button", "SWTButton", ConquestFrame, "UIPanelButtonTemplate")
	SWT_Button:SetSize(200, 35)
	SWT_Button:SetText("Track Shuffle Legend Wins")
	SWT_Button:SetPoint("BOTTOMRIGHT", 168, -70)

	SWT_Button:SetScript("OnClick", function()
		-- Check that theres a valid achievement ID and not already obtained
		if currentLegendAchievementId == 0 then
			message("|cffffff00No active pvp season found|r")
		elseif not characterHasObtainedLegendAchievement then
			C_ContentTracking.ToggleTracking(2, currentLegendAchievementId, 2)
		end
	end)
end

function updateGladButtonVisibility()
	-- Check if button visibility has been overridden
	if GWT_HideButton == "default" then
		if characterHasObtainedGladAchievement then
			GWT_Button:Hide()
		else
			GWT_Button:Show()
		end
	elseif GWT_HideButton == "true" then
		GWT_Button:Hide()
	elseif GWT_HideButton == "false" then
		if characterHasObtainedGladAchievement then
			GWT_Button:Hide()
		else
			GWT_Button:Show()
		end
	end
end

function updateShuffleButtonVisibility()
	-- Check if button visibility has been overridden
	if SWT_HideButton == "default" then
		if characterHasObtainedLegendAchievement then
			SWT_Button:Hide()
		else
			SWT_Button:Show()
		end
	elseif SWT_HideButton == "true" then
		SWT_Button:Hide()
	elseif SWT_HideButton == "false" then
		if characterHasObtainedLegendAchievement then
			SWT_Button:Hide()
		else
			SWT_Button:Show()
		end
	end
end

function setGWTVersion()
	local version = GetAddOnMetadata("GladiatorShuffleWinsTracker", "Version")
	GWTVersion = version
end

function setCharacterHasObtainedGladAchievement()
	if currentGladAchievementId ~= 0 then
		local id, _, _, completed, _, _, _, _, _, _, _, _, wasEarnedByMe = GetAchievementInfo(currentGladAchievementId)
		if completed and wasEarnedByMe then
			characterHasObtainedGladAchievement = true
		else 
			characterHasObtainedGladAchievement = false
		end
	end
end

function setCharacterHasObtainedShuffleLegendAchievement()
	if currentLegendAchievementId ~= 0 then
		local id, _, _, completed, _, _, _, _, _, _, _, _, wasEarnedByMe = GetAchievementInfo(currentLegendAchievementId)
		if completed and wasEarnedByMe then
			characterHasObtainedLegendAchievement = true
		else 
			characterHasObtainedLegendAchievement = false
		end
	end
end

function setCurrentPVPSeasonGladAchieveId()
	local currentPVPSeason = GetCurrentArenaSeason()
	if currentPVPSeason == 0 then currentGladAchievementId = 0 -- No active arena season
	elseif currentPVPSeason == 30 then currentGladAchievementId = 14689 -- Gladiator: Shadowlands Season 1
	elseif currentPVPSeason == 31 then currentGladAchievementId = 14972 -- Gladiator: Shadowlands Season 2
	elseif currentPVPSeason == 32 then currentGladAchievementId = 15352 -- Gladiator: Shadowlands Season 3
	elseif currentPVPSeason == 33 then currentGladAchievementId = 15605 -- Gladiator: Shadowlands Season 4
	elseif currentPVPSeason == 34 then currentGladAchievementId = 15957 -- Gladiator: Dragonflight Season 1
	elseif currentPVPSeason == 35 then currentGladAchievementId = 17740 -- Gladiator: Dragonflight Season 2
	elseif currentPVPSeason == 36 then currentGladAchievementId = 19091 -- Gladiator: Dragonflight Season 3
	elseif currentPVPSeason == 37 then currentGladAchievementId = 19490 -- Gladiator: Dragonflight Season 4
	elseif currentPVPSeason == 38 then currentGladAchievementId = 40393 -- Gladiator: The War Within Season 1
	else currentGladAchievementId = 0 end -- Default case for if addon very out of date
end

function setCurrentPVPSeasonShuffleLegendAchieveId()
	local currentPVPSeason = GetCurrentArenaSeason()
	if currentPVPSeason == 0 then currentLegendAchievementId = 0 -- No active arena season
	elseif currentPVPSeason == 36 then currentLegendAchievementId = 19304 -- Legend: Dragonflight Season 3
	elseif currentPVPSeason == 37 then currentLegendAchievementId = 19500 -- Legend: Dragonflight Season 4
	elseif currentPVPSeason == 38 then currentLegendAchievementId = 40395 -- Legend: The War Within Season 1
	else currentLegendAchievementId = 0 end -- Default case for if addon very out of date
end

function setCharGladSavedVariable(state)
	if state == "hide" then
		GWT_HideButton = "true"
	elseif state == "show" then
		GWT_HideButton = "false"
	elseif state == "reset" then
		GWT_HideButton = "default"
	end
	if GWT_Button then
		updateGladButtonVisibility()
	end
end

function setCharShuffleSavedVariable(state)
	if state == "hide" then
		SWT_HideButton = "true"
	elseif state == "show" then
		SWT_HideButton = "false"
	elseif state == "reset" then
		SWT_HideButton = "default"
	end
	if SWT_Button then
		updateShuffleButtonVisibility()
	end
end

function setAccountSavedVariable(state)
	if state == "hide" then
		GWT_LoginIntro = "false"
	elseif state == "show" then
		GWT_LoginIntro = "true"
	end
end

--------------------------------------------
-- OPTIONS PANEL
--------------------------------------------

local SimpleOptions = LibStub("LibSimpleOptions-1.01")

function createOptions()
	local panel = SimpleOptions.AddOptionsPanel("Gladiator & Shuffle Wins Tracker", function() end)
    SimpleOptions.AddSlashCommand("Gladiator & Shuffle Wins Tracker","/gwt")
	local title, subText = panel:MakeTitleTextAndSubText("Gladiator & Shuffle Wins Tracker", "")

	local characterSpecificSectionText = panel:CreateFontString(nil, "ARTWORK", "GameFontDisable")
    characterSpecificSectionText:SetText("|cffffff00Character specific settings:|r")
    characterSpecificSectionText:SetJustifyH("LEFT")
    characterSpecificSectionText:SetSize(600, 40)
	characterSpecificSectionText:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -30)

	local hideGladButtonToggle = panel:MakeToggle(
	    'name', 'Never show GLADIATOR button on this character',
	    'description', 'Hide button in Rated PVP tab',
	    'default', false,
	    'getFunc', function()
			if GWT_HideButton == "true" then
				return true
			elseif GWT_HideButton == "false" or GWT_HideButton == "default" then
				return false
			end
		end,
	    'setFunc', function(value)
			if value == true then
				setCharGladSavedVariable("hide")
			elseif value == false then
				setCharGladSavedVariable("show")
			end
		end
	)
	hideGladButtonToggle:SetPoint("TOPLEFT", characterSpecificSectionText, "TOPLEFT", 40, -35)

	local hideShuffleButtonToggle = panel:MakeToggle(
	    'name', 'Never show SHUFFLE LEGEND button on this character',
	    'description', 'Hide button in Rated PVP tab',
	    'default', false,
	    'getFunc', function()
			if SWT_HideButton == "true" then
				return true
			elseif SWT_HideButton == "false" or SWT_HideButton == "default" then
				return false
			end
		end,
	    'setFunc', function(value)
			if value == true then
				setCharShuffleSavedVariable("hide")
			elseif value == false then
				setCharShuffleSavedVariable("show")
			end
		end
	)
	hideShuffleButtonToggle:SetPoint("TOPLEFT", characterSpecificSectionText, "TOPLEFT", 40, -70)

	local noteText = panel:CreateFontString(nil, "ARTWORK", "GameFontDisable")
    noteText:SetText("|cffffff00|r |cffffffffNote: Button hidden automatically if character has obtained achievement this season|r")
    noteText:SetJustifyH("LEFT")
    noteText:SetSize(600, 40)
    noteText:SetPoint("TOPLEFT", hideShuffleButtonToggle, "TOPLEFT", 0, -20)

	local resetButton = panel:MakeButton(
	    'name', 'Reset',
	    'description', 'Restore default settings',
	    'func', function()
			setCharGladSavedVariable("reset")
			setCharShuffleSavedVariable("reset")
			panel:Refresh()
		end
	)
	resetButton:SetPoint("TOPLEFT", noteText, "TOPLEFT", 0, -40)

	local accountSectionText = panel:CreateFontString(nil, "ARTWORK", "GameFontDisable")
    accountSectionText:SetText("|cffffff00Account settings:|r")
    accountSectionText:SetJustifyH("LEFT")
    accountSectionText:SetSize(600, 40)
	accountSectionText:SetPoint("TOPLEFT", resetButton, "TOPLEFT", -40, -30)

	local hideLoginIntro = panel:MakeToggle(
	    'name', 'Disable login message',
	    'description', 'Disable login message for all characters',
	    'default', false,
	    'getFunc', function()
			if GWT_LoginIntro == "true" then
				return false
			elseif GWT_LoginIntro == "false" then
				return true
			end
		end,
	    'setFunc', function(value)
			if value == true then
				setAccountSavedVariable("hide")
			elseif value == false then
				setAccountSavedVariable("show")
			end
		end
	)
    hideLoginIntro:SetPoint("TOPLEFT", accountSectionText, "TOPLEFT", 40, -35)

	local versionText = panel:CreateFontString(nil, "ARTWORK", "GameFontDisable")
    versionText:SetText("|cffffff00Version:|r |cffffffff"..GWTVersion.."|r")
    versionText:SetJustifyH("RIGHT")
    versionText:SetSize(600, 40)
    versionText:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, -5)

	local authorText = panel:CreateFontString(nil, "ARTWORK", "GameFontDisable")
    authorText:SetText("|cffffff00Author:|r |cffffffffDezopri|r")
    authorText:SetJustifyH("RIGHT")
    authorText:SetSize(600, 40)
    authorText:SetPoint("TOPLEFT", versionText, "TOPLEFT", 0, -20)
end