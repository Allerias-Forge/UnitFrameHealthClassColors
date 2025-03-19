local _G = _G or getfenv(0)

UnitFrameHealthClassColors = CreateFrame("Frame", nil, UIParent);

local function UpdatePartyHealthBars()
	if GetNumPartyMembers() > 0 then
		for idx = 1, MAX_PARTY_MEMBERS do
			local _, class = UnitClass("party"..idx);
			local classColor = RAID_CLASS_COLORS[class] or { r = 0, g = 1, b = 0, a = 1 };
			_G['PartyMemberFrame'..idx.."HealthBar"]:SetStatusBarColor(classColor.r, classColor.g, classColor.b, 1);
		end
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
end

local function UpdatePlayerHealthBar()
	local _, class = UnitClass("player");
	local classColor = RAID_CLASS_COLORS[class] or { r = 0, g = 1, b = 0, a = 1 };
	PlayerFrameHealthBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b, 1);
end

UnitFrameHealthClassColors:SetScript("OnEvent", function()
	if event == "PLAYER_ENTERING_WORLD" then
		UpdatePlayerHealthBar();
		UpdatePartyHealthBars();
	elseif event == "PLAYER_TARGET_CHANGED" then
		if UnitIsPlayer("target") then
			local _, class = UnitClass("target");
			local classColor = RAID_CLASS_COLORS[class] or { r = 0, g = 1, b = 0, a = 1 };
			TargetFrameHealthBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b, 1);

			UpdateTargetofTargetHealthBar();
		end
	elseif event == "PARTY_MEMBERS_CHANGED" then
		UpdatePartyHealthBars();
	end
end);

local _TargetofTarget_Update = TargetofTarget_Update;
function TargetofTarget_Update()
	_TargetofTarget_Update();
	UpdateTargetofTargetHealthBar();
end

UnitFrameHealthClassColors:RegisterEvent("PLAYER_ENTERING_WORLD");
UnitFrameHealthClassColors:RegisterEvent("PLAYER_TARGET_CHANGED");
UnitFrameHealthClassColors:RegisterEvent("PARTY_MEMBERS_CHANGED");
