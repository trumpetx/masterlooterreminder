local function isGroupLeader()
	return UnitIsGroupLeader("player")
end

local function sendOutput(msg)
	if isGroupLeader() then
		if IsInRaid() then
  			SendChatMessage(msg, "RAID")
		elseif IsInGroup() then -- this shouldn't run, but here in case this expands to parties
			SendChatMessage(msg, "PARTY")
		end
	end
end

local function isEnteringInstance()
	local mapforunit = C_Map.GetBestMapForUnit("player")
	if not mapforunit then
		return true
	end
	local position = C_Map.GetPlayerMapPosition(mapforunit,"player")
	if not position then
		return true
	end
	local x, y = position
	return x == y and y == 0
end

local function isEnteringRaid()
	inInstance, instanceType = IsInInstance()
	return inInstance and instanceType == "raid" and isEnteringInstance()
end

local function isMasterLooter()
	lootmethod, masterlooterPartyID, masterlooterRaidID = GetLootMethod()
	return lootmethod == "master"
end

local function setLootMaster()
	local playerName = UnitName("player");
	SetLootMethod("master", playerName);
	sendOutput("Setting Master Looter: <" .. playerName .. ">")
end

local function handlePlayerEnteringWorld(self, event, msg)
	if isEnteringRaid() and isGroupLeader() and not isMasterLooter() then
		StaticPopup_Show("MSTR_LOOT_REM_SET")
	end
end

local EventFrame = CreateFrame("Frame", "EventFrame")
EventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
EventFrame:SetScript('OnEvent', handlePlayerEnteringWorld)

StaticPopupDialogs["MSTR_LOOT_REM_SET"] = {
  text = "Would you like to turn Master Looter on?",
  button1 = "Yes",
  button2 = "No",
  OnAccept = function()
		setLootMaster()
  end,
  OnCancel = function (_,reason)
		if reason == "timeout" then
			-- Try again?
		elseif reason == "clicked" then
			-- Cancel message?
		else
			-- ??
		end;
  end,
  timeout = 30,
  whileDead = true,
  hideOnEscape = true,
}
