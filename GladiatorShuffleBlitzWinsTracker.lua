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
		updateButtonsVisibility()
	end

	-- Setup variables
	if event == "PLAYER_LOGIN" then
		setGWTVersion()

		setCurrentPVPSeasonAchievementIds()

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

		updateButtonsVisibility()
	end
end)

function createButtons()
	-- ConquestFrame is not nil as Blizzard_PVPUI has loaded
	GWT_Button = CreateFrame("Button", "GWTButton", ConquestFrame.Arena3v3, "UIPanelButtonTemplate")
	GWT_Button:SetSize(25, 25)
	GWT_Button:SetText(">")
	GWT_Button:SetPoint("RIGHT", 10, 0)

	GWT_Button:SetScript("OnClick", function()
		-- Check that theres a valid achievement ID and not already obtained
		if currentGladAchievementId == 0 then
			message("|cffffff00No active pvp season found - please check addon is up to date.|r")
		elseif not characterHasObtainedGladAchievement then
			C_ContentTracking.ToggleTracking(2, currentGladAchievementId, 2)
		end
	end)

	-- ConquestFrame is not nil as Blizzard_PVPUI has loaded
	SWT_Button = CreateFrame("Button", "SWTButton", ConquestFrame.RatedSoloShuffle, "UIPanelButtonTemplate")
	SWT_Button:SetSize(25, 25)
	SWT_Button:SetText(">")
	SWT_Button:SetPoint("RIGHT", 10, 0)

	SWT_Button:SetScript("OnClick", function()
		-- Check that theres a valid achievement ID and not already obtained
		if currentLegendAchievementId == 0 then
			message("|cffffff00No active pvp season found - please check addon is up to date.|r")
		elseif not characterHasObtainedLegendAchievement then
			C_ContentTracking.ToggleTracking(2, currentLegendAchievementId, 2)
		end
	end)

	-- ConquestFrame is not nil as Blizzard_PVPUI has loaded
	BWT_Button = CreateFrame("Button", "BWTButton", ConquestFrame.RatedBGBlitz, "UIPanelButtonTemplate")
	BWT_Button:SetSize(25, 25)
	BWT_Button:SetText(">")
	BWT_Button:SetPoint("RIGHT", 10, 0)

	BWT_Button:SetScript("OnClick", function()
		-- Check that theres a valid achievement ID and not already obtained
		if currentBlitzAchievementId == 0 then
			message("|cffffff00No active pvp season found - please check addon is up to date.|r")
		elseif not characterHasObtainedBlitzAchievement then
			C_ContentTracking.ToggleTracking(2, currentBlitzAchievementId, 2)
		end
	end)
end

function updateButtonsVisibility()
	-- Function to update button position based on its visibility
	local function setButtonVisibility(button, show)
		if show then
			button:Show()
		else
			button:Hide()
		end
	end

	-- Position each button based on its visibility
	setButtonVisibility(GWT_Button, shouldShowGladButton())
	setButtonVisibility(SWT_Button, shouldShowShuffleButton())
	setButtonVisibility(BWT_Button, shouldShowBlitzButton())
end

function shouldShowGladButton()
	-- Check if button visibility has been overridden
	if GWT_HideButton == "default" then
		if characterHasObtainedGladAchievement then
			return false
		else
			return true
		end
	elseif GWT_HideButton == "true" then
		return false
	elseif GWT_HideButton == "false" then
		if characterHasObtainedGladAchievement then
			return false
		else
			return true
		end
	end
end

function shouldShowShuffleButton()
	-- Check if button visibility has been overridden
	if SWT_HideButton == "default" then
		if characterHasObtainedLegendAchievement then
			return false
		else
			return true
		end
	elseif SWT_HideButton == "true" then
		return false
	elseif SWT_HideButton == "false" then
		if characterHasObtainedLegendAchievement then
			return false
		else
			return true
		end
	end
end

function shouldShowBlitzButton()
	-- Check if button visibility has been overridden
	if BWT_HideButton == "default" then
		if characterHasObtainedBlitzAchievement then
			return false
		else
			return true
		end
	elseif BWT_HideButton == "true" then
		return false
	elseif BWT_HideButton == "false" then
		if characterHasObtainedBlitzAchievement then
			return false
		else
			return true
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

function setCurrentPVPSeasonAchievementIds()
	local currentPVPSeason = GetCurrentArenaSeason()
	currentGladAchievementId = AchievementIDs.Gladiator[currentPVPSeason] or 0
	currentLegendAchievementId = AchievementIDs.ShuffleLegend[currentPVPSeason] or 0
	currentBlitzAchievementId = AchievementIDs.BlitzStrategist[currentPVPSeason] or 0
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
		updateButtonsVisibility()
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
		updateButtonsVisibility()
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
		updateButtonsVisibility()
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
	SLASH_GSBT1 = "/gsbt"
	SlashCmdList["GSBT"] = function()
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
