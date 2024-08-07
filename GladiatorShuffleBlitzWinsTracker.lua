local GWTVersion, currentGladAchievementId, currentLegendAchievementId, currentBlitzAchievementId, characterHasObtainedGladAchievement, characterHasObtainedLegendAchievement, characterHasObtainedBlitzAchievement, GWT_Button, SWT_Button, BWT_Button

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("ACHIEVEMENT_EARNED")
eventFrame:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "GladiatorShuffleBlitzWinsTracker" then
		-- Set character glad saved variable if none
		if not GWT_HideButton then
			GWT_HideButton = "default"
		end

		-- Set character shuffle saved variable if none
		if not SWT_HideButton then
			SWT_HideButton = "default"
		end

		-- Set character blitz saved variable if none
		if not BWT_HideButton then
			BWT_HideButton = "default"
		end

		-- Set account saved variable if none
		if not GWT_LoginIntro then
			GWT_LoginIntro = "true"
		end

		registerOptionsPanel()
	end

	-- Only setup the button once the parent frame has loaded
	if event == "ADDON_LOADED" and arg1 == "Blizzard_PVPUI" then
		createButtons()
		updateGladButtonVisibility()
		updateShuffleButtonVisibility()
		updateBlitzButtonVisibility()
	end

	-- Setup variables
	if event == "PLAYER_LOGIN" then
		setGWTVersion()

		setCurrentPVPSeasonGladAchieveId()
		setCurrentPVPSeasonShuffleLegendAchieveId()
		setCurrentPVPSeasonBlitzStrategistAchieveId()

		setCharacterHasObtainedGladAchievement()
		setCharacterHasObtainedShuffleLegendAchievement()
		setCharacterHasObtainedBlitzStrategistAchievement()

		if GWT_LoginIntro == "true" then
			print("|cff33ff99Gladiator, Shuffle & Blitz Wins Tracker|r - use |cffFF4500 /gwt |r to open options")
		end
	end

	-- Check if button should hide after achievement obtained during session
	if event == "ACHIEVEMENT_EARNED" and arg1 == currentGladAchievementId then
		setCharacterHasObtainedGladAchievement()
		setCharacterHasObtainedShuffleLegendAchievement()
		setCharacterHasObtainedBlitzStrategistAchievement()

		updateGladButtonVisibility()
		updateShuffleButtonVisibility()
		updateBlitzButtonVisibility()
	end
end)

function createButtons()
	-- ConquestFrame is not nil as Blizzard_PVPUI has loaded
	GWT_Button = CreateFrame("Button", "GWTButton", ConquestFrame, "UIPanelButtonTemplate")
	GWT_Button:SetSize(200, 35)
	GWT_Button:SetText("Track 3v3 Gladiator Wins")
	GWT_Button:SetPoint("BOTTOMRIGHT", 168, -34)

	GWT_Button:SetScript("OnClick", function()
		-- Check that theres a valid achievement ID and not already obtained
		if currentGladAchievementId == 0 then
			message("|cffffff00No active pvp season found - please check addon is up to date.|r")
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
			message("|cffffff00No active pvp season found - please check addon is up to date.|r")
		elseif not characterHasObtainedLegendAchievement then
			C_ContentTracking.ToggleTracking(2, currentLegendAchievementId, 2)
		end
	end)

	-- ConquestFrame is not nil as Blizzard_PVPUI has loaded
	BWT_Button = CreateFrame("Button", "BWTButton", ConquestFrame, "UIPanelButtonTemplate")
	BWT_Button:SetSize(200, 35)
	BWT_Button:SetText("Track Blitz Strategist Wins")
	BWT_Button:SetPoint("BOTTOMRIGHT", 168, -106)

	BWT_Button:SetScript("OnClick", function()
		-- Check that theres a valid achievement ID and not already obtained
		if currentBlitzAchievementId == 0 then
			message("|cffffff00No active pvp season found - please check addon is up to date.|r")
		elseif not characterHasObtainedBlitzAchievement then
			C_ContentTracking.ToggleTracking(2, currentBlitzAchievementId, 2)
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

function updateBlitzButtonVisibility()
	-- Check if button visibility has been overridden
	if BWT_HideButton == "default" then
		if characterHasObtainedBlitzAchievement then
			BWT_Button:Hide()
		else
			BWT_Button:Show()
		end
	elseif BWT_HideButton == "true" then
		BWT_Button:Hide()
	elseif BWT_HideButton == "false" then
		if characterHasObtainedBlitzAchievement then
			BWT_Button:Hide()
		else
			BWT_Button:Show()
		end
	end
end

function setGWTVersion()
	local version = C_AddOns.GetAddOnMetadata("GladiatorShuffleBlitzWinsTracker", "Version")
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

function setCharacterHasObtainedBlitzStrategistAchievement()
	if currentBlitzAchievementId ~= 0 then
		local id, _, _, completed, _, _, _, _, _, _, _, _, wasEarnedByMe = GetAchievementInfo(currentBlitzAchievementId)
		if completed and wasEarnedByMe then
			characterHasObtainedBlitzAchievement = true
		else
			characterHasObtainedBlitzAchievement = false
		end
	end
end

function setCurrentPVPSeasonGladAchieveId()
	local currentPVPSeason = GetCurrentArenaSeason()
	if currentPVPSeason == 0 then
		currentGladAchievementId = 0 -- No active arena season
	elseif currentPVPSeason == 30 then
		currentGladAchievementId = 14689 -- Gladiator: Shadowlands Season 1
	elseif currentPVPSeason == 31 then
		currentGladAchievementId = 14972 -- Gladiator: Shadowlands Season 2
	elseif currentPVPSeason == 32 then
		currentGladAchievementId = 15352 -- Gladiator: Shadowlands Season 3
	elseif currentPVPSeason == 33 then
		currentGladAchievementId = 15605 -- Gladiator: Shadowlands Season 4
	elseif currentPVPSeason == 34 then
		currentGladAchievementId = 15957 -- Gladiator: Dragonflight Season 1
	elseif currentPVPSeason == 35 then
		currentGladAchievementId = 17740 -- Gladiator: Dragonflight Season 2
	elseif currentPVPSeason == 36 then
		currentGladAchievementId = 19091 -- Gladiator: Dragonflight Season 3
	elseif currentPVPSeason == 37 then
		currentGladAchievementId = 19490 -- Gladiator: Dragonflight Season 4
	elseif currentPVPSeason == 38 then
		currentGladAchievementId = 40393 -- Gladiator: The War Within Season 1
	else
		currentGladAchievementId = 0
	end -- Default case for if addon very out of date
end

function setCurrentPVPSeasonShuffleLegendAchieveId()
	local currentPVPSeason = GetCurrentArenaSeason()
	if currentPVPSeason == 0 then
		currentLegendAchievementId = 0 -- No active arena season
	elseif currentPVPSeason == 36 then
		currentLegendAchievementId = 19304 -- Legend: Dragonflight Season 3
	elseif currentPVPSeason == 37 then
		currentLegendAchievementId = 19500 -- Legend: Dragonflight Season 4
	elseif currentPVPSeason == 38 then
		currentLegendAchievementId = 40395 -- Legend: The War Within Season 1
	else
		currentLegendAchievementId = 0
	end -- Default case for if addon very out of date
end

function setCurrentPVPSeasonBlitzStrategistAchieveId()
	local currentPVPSeason = GetCurrentArenaSeason()
	if currentPVPSeason == 0 then
		currentBlitzAchievementId = 0 -- No active arena season
	elseif currentPVPSeason == 38 then
		currentBlitzAchievementId = 40233 -- Strategist: The War Within Season 1
	else
		currentBlitzAchievementId = 0
	end -- Default case for if addon very out of date
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

function setCharBlitzSavedVariable(state)
	if state == "hide" then
		BWT_HideButton = "true"
	elseif state == "show" then
		BWT_HideButton = "false"
	elseif state == "reset" then
		BWT_HideButton = "default"
	end
	if BWT_Button then
		updateBlitzButtonVisibility()
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

-- Function to register the options panel
function registerOptionsPanel()
	local optionsPanel = createOptionsPanel()

	-- Register the options panel with the Settings API
	local category, layout = Settings.RegisterCanvasLayoutCategory(optionsPanel,
		"Gladiator, Shuffle & Blitz Wins Tracker")
	Settings.RegisterAddOnCategory(category)

	-- Slash command to open the settings
	SLASH_GWT1 = "/gwt"
	SlashCmdList["GWT"] = function()
		Settings.OpenToCategory(category.ID)
	end
end

function createOptionsPanel()
	local frame = CreateFrame("Frame", "GWTOptionsPanel", UIParent)
	frame.name = "Gladiator, Shuffle & Blitz Wins Tracker"

	local function newCheckbox(label, onClick)
		local check = CreateFrame("CheckButton", "GWTCheck" .. label, frame, "InterfaceOptionsCheckButtonTemplate")
		check:SetScript("OnClick", function(self)
			local tick = self:GetChecked()
			onClick(self, tick and true or false)
		end)
		check.label = _G[check:GetName() .. "Text"]
		check.label:SetText(label)
		return check
	end

	frame:SetScript("OnShow", function()
		local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		title:SetPoint("TOPLEFT", 16, -16)
		title:SetText("Gladiator, Shuffle & Blitz Wins Tracker")

		local charTitle = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		charTitle:SetText("|cffffff00Character Specific Settings|r")
		charTitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", -2, -16)

		local hideGladCheckbox = newCheckbox("Never show GLADIATOR button on this character",
			function(self, value)
				if value == true then
					setCharGladSavedVariable("hide")
				elseif value == false then
					setCharGladSavedVariable("show")
				end
			end
		)
		-- Ensure the checkbox state is set based on the current value
		hideGladCheckbox:SetChecked(GWT_HideButton == "true")
		hideGladCheckbox:SetPoint("TOPLEFT", charTitle, "BOTTOMLEFT", 20, -16)

		local hideShuffleCheckbox = newCheckbox("Never show SHUFFLE LEGEND button on this character",
			function(self, value)
				if value == true then
					setCharShuffleSavedVariable("hide")
				elseif value == false then
					setCharShuffleSavedVariable("show")
				end
			end
		)
		-- Ensure the checkbox state is set based on the current value
		hideShuffleCheckbox:SetChecked(SWT_HideButton == "true")
		hideShuffleCheckbox:SetPoint("TOPLEFT", hideGladCheckbox, "BOTTOMLEFT", 0, -8)

		local hideBlitzCheckbox = newCheckbox("Never show BLITZ STRATEGIST button on this character",
			function(self, value)
				if value == true then
					setCharBlitzSavedVariable("hide")
				elseif value == false then
					setCharBlitzSavedVariable("show")
				end
			end
		)
		-- Ensure the checkbox state is set based on the current value
		hideBlitzCheckbox:SetChecked(BWT_HideButton == "true")
		hideBlitzCheckbox:SetPoint("TOPLEFT", hideShuffleCheckbox, "BOTTOMLEFT", 0, -8)

		local resetButton = CreateFrame("Button", "GTWResetButton", frame, "UIPanelButtonTemplate")
		resetButton:SetText("Reset")
		resetButton:SetWidth(90)
		resetButton:SetHeight(30)
		resetButton:SetPoint("TOPLEFT", hideBlitzCheckbox, "BOTTOMLEFT", -20, -15)
		resetButton:SetScript("OnClick", function()
			setCharGladSavedVariable("reset")
			setCharShuffleSavedVariable("reset")
			setCharBlitzSavedVariable("reset")

			hideGladCheckbox:SetChecked(GWT_HideButton == "true")
			hideShuffleCheckbox:SetChecked(SWT_HideButton == "true")
			hideBlitzCheckbox:SetChecked(BWT_HideButton == "true")
		end)

		local accountSettingsTitle = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		accountSettingsTitle:SetText("|cffffff00Account Settings|r")
		accountSettingsTitle:SetPoint("TOPLEFT", resetButton, "BOTTOMLEFT", -2, -16)

		local hideIntroCheckbox = newCheckbox("Disable login message",
			function(self, value)
				if value == true then
					setAccountSavedVariable("hide")
				elseif value == false then
					setAccountSavedVariable("show")
				end
			end
		)
		-- Ensure the checkbox state is set based on the current value
		hideIntroCheckbox:SetChecked(GWT_LoginIntro ~= "true")
		hideIntroCheckbox:SetPoint("TOPLEFT", accountSettingsTitle, "TOPLEFT", 20, -25)

		local versionText = frame:CreateFontString(nil, "ARTWORK", "GameFontDisable")
		versionText:SetText("|cffffff00Version:|r |cffffffff" .. GWTVersion .. "|r")
		versionText:SetJustifyH("RIGHT")
		versionText:SetSize(600, 40)
		versionText:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -5)

		local authorText = frame:CreateFontString(nil, "ARTWORK", "GameFontDisable")
		authorText:SetText("|cffffff00Author:|r |cffffffffDezopri|r")
		authorText:SetJustifyH("RIGHT")
		authorText:SetSize(600, 40)
		authorText:SetPoint("TOPLEFT", versionText, "TOPLEFT", 0, -20)

		frame:SetScript("OnShow", nil)
	end)
	return frame
end
