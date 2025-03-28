local _G = _G or getfenv(0)

UnitFrameHealthClassColors = CreateFrame("Frame", nil, UIParent);

local function UpdatePlayerHealthBar()
	local _, class = UnitClass("player");
	local classColor = RAID_CLASS_COLORS[class] or { r = 0, g = 1, b = 0, a = 1 };
	PlayerFrameHealthBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b, 1);
end

local function UpdatePartyHealthBars()
	if GetNumPartyMembers() > 0 then
		for idx = 1, MAX_PARTY_MEMBERS do
			local _, class = UnitClass("party"..idx);
			local classColor = RAID_CLASS_COLORS[class] or { r = 0, g = 1, b = 0, a = 1 };
			_G['PartyMemberFrame'..idx.."HealthBar"]:SetStatusBarColor(classColor.r, classColor.g, classColor.b, 1);
		end
	end
end

local function UpdateTargetHealthBar()
	if UnitIsPlayer("target") then
		local _, class = UnitClass("target");
		local classColor = RAID_CLASS_COLORS[class] or { r = 0, g = 1, b = 0, a = 1 };
		TargetFrameHealthBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b, 1);
	end
end

local function UpdateTargetofTargetHealthBar()
	if TargetofTargetFrame:IsShown() then
		if UnitIsPlayer("targettarget") then
			local _, totClass = UnitClass("targettarget");
			local totClassColor = RAID_CLASS_COLORS[totClass] or { r = 0, g = 1, b = 0, a = 1 };
			TargetofTargetHealthBar:SetStatusBarColor(totClassColor.r, totClassColor.g, totClassColor.b, 1);
		else
			-- Restore default green health bar color
			TargetofTargetHealthBar:SetStatusBarColor(0, 1, 0, 1);
		end
	end

	-- Reupdate the player and target's color because sometimes it changes back to normal for some reason
	UpdateTargetHealthBar();
	UpdatePlayerHealthBar();
end

UnitFrameHealthClassColors:SetScript("OnEvent", function()
	if event == "PLAYER_ENTERING_WORLD" then
		UpdatePlayerHealthBar();
		UpdatePartyHealthBars();
	elseif event == "PLAYER_TARGET_CHANGED" then
		UpdateTargetHealthBar();
	elseif event == "PARTY_MEMBERS_CHANGED" then
		UpdatePartyHealthBars();
	elseif event == "UNIT_HEALTH" then
		-- Sometimes health bars get their color reset, it's unclear why but this should help fix it
		if arg1 == "player" then
			UpdatePlayerHealthBar();
		elseif arg1 == "target" or arg1 == "targettarget" then
			UpdateTargetofTargetHealthBar();
		elseif arg1 == "party1" or arg1 == "party2" or arg1 == "party3" or arg1 == "party4" then
			UpdatePartyHealthBars();
		end
	end
end);

local _TargetofTarget_Update = TargetofTarget_Update;
function TargetofTarget_Update()
	_TargetofTarget_Update();
	UpdateTargetofTargetHealthBar();
end

-- This is a bit heavier but really makes sure our colors are overriding the other changes from the normal event
local _HealthBar_OnValueChanged = HealthBar_OnValueChanged;
function HealthBar_OnValueChanged(value, smooth)
	_HealthBar_OnValueChanged(value, smooth);

	local unit = this.unit;
	if unit == "player" then
		UpdatePlayerHealthBar();
	elseif unit == "target" or unit == "targettarget" then
		UpdateTargetofTargetHealthBar();
	elseif unit == "party1" or unit == "party2" or unit == "party3" or unit == "party4" then
		UpdatePartyHealthBars();
	end
end

UnitFrameHealthClassColors:RegisterEvent("PLAYER_ENTERING_WORLD");
UnitFrameHealthClassColors:RegisterEvent("PLAYER_TARGET_CHANGED");
UnitFrameHealthClassColors:RegisterEvent("PARTY_MEMBERS_CHANGED");
UnitFrameHealthClassColors:RegisterEvent("UNIT_HEALTH");