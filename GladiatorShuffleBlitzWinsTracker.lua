local GWTVersion, seasonActive, currentGladAchievementId, currentLegendAchievementId, currentBlitzAchievementId, GWT_Button, SWT_Button, BWT_Button

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "GladiatorShuffleBlitzWinsTracker" then
		-- Initialize character and account saved variables if not set
		GWT_HideButton = GWT_HideButton or "default"
		SWT_HideButton = SWT_HideButton or "default"
		BWT_HideButton = BWT_HideButton or "default"
		GWT_LoginIntro = GWT_LoginIntro or "true"

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

		if GWT_LoginIntro == "true" then
			print("|cff33ff99Gladiator, Shuffle & Blitz Wins Tracker|r - use |cffFF4500 /gsbt |r to open options")
		end
	end
end)

-- Recreate the removed global `message` alert using the StaticPopup system
StaticPopupDialogs["GSBT_ALERT_POPUP"] = StaticPopupDialogs["GSBT_ALERT_POPUP"] or {
	text = "%s",
	button1 = OKAY,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

local function showAlertMessage(text)
	if not text then
		return
	end

	StaticPopup_Show("GSBT_ALERT_POPUP", text)
end

function createButton(name, parentFrame, achievementId)
	local button = CreateFrame("Button", name, parentFrame, "UIPanelButtonTemplate")
	button:SetSize(25, 25)
	button:SetText(">")
	button:SetPoint("RIGHT", 10, 0)

	button:SetScript("OnClick", function()
		if not seasonActive then
			showNoActiveSeasonAlert()
		elseif achievementId == 0 then
			showIDMissingForSeasonAlert()
		else
			local id, _, _, completed, _, _, _, _, _, _, _, _, wasEarnedByMe = GetAchievementInfo(
				achievementId)
			if completed and wasEarnedByMe then
				showAlreadyCompletedAlert()
			else
				C_ContentTracking.ToggleTracking(2, achievementId, 2)
			end
		end
	end)

	return button
end

function createButtons()
	-- Create each button with its specific parameters
	GWT_Button = createButton("GWTButton", ConquestFrame.Arena3v3, currentGladAchievementId)
	SWT_Button = createButton("SWTButton", ConquestFrame.RatedSoloShuffle, currentLegendAchievementId)
	BWT_Button = createButton("BWTButton", ConquestFrame.RatedBGBlitz, currentBlitzAchievementId)
end

function showNoActiveSeasonAlert()
	showAlertMessage("|cffffff00No active PVP season found.|r")
end

function showIDMissingForSeasonAlert()
	showAlertMessage("|cffffff00Achievement missing for current season - please update addon.|r")
end

function showAlreadyCompletedAlert()
	showAlertMessage("|cFF00FF00This character has already completed the achievement.|r")
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
	return GWT_HideButton ~= "true"
end

function shouldShowShuffleButton()
	return SWT_HideButton ~= "true"
end

function shouldShowBlitzButton()
	return BWT_HideButton ~= "true"
end

function setGWTVersion()
	local version = C_AddOns.GetAddOnMetadata("GladiatorShuffleBlitzWinsTracker", "Version")
	GWTVersion = version
end

function setCurrentPVPSeasonAchievementIds()
	local currentPVPSeason = GetCurrentArenaSeason()

	seasonActive = currentPVPSeason ~= 0

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

		local hideGladCheckbox = newCheckbox("Hide |cff33ff993v3|r button on this character",
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

		local hideShuffleCheckbox = newCheckbox("Hide |cff33ff99Shuffle|r button on this character",
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

		local hideBlitzCheckbox = newCheckbox("Hide |cff33ff99Blitz|r button on this character",
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
