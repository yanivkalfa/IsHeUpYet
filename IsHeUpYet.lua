IsHeUpYet = CreateFrame("Frame", "IsHeUpYetFrame", UIParent);
IsHeUpYet.addonName = "IsHeUpYet";
IsHeUpYet.Constants = {};
IsHeUpYet.initiated = nil;
IsHeUpYet.interval = nil;
IsHeUpYet.isAfk = false;

IsHeUpYetSaved = IsHeUpYetSaved or {
  lookFor = {
    mobOne = nil,
    mobTwo = nil,
    mobTree = nil,
  },
  interval = true,
  soundAlarm = true,
  minimap = {
    hide = false,
  },
};

function IsHeUpYet:toggleOptions()
  if ( IHUYMainFrame:IsShown() ) then
    IHUYMainFrame:Hide();
  else
    IHUYMainFrame:Show();
  end
end

function IsHeUpYet:OnEvent(event, ...)
  local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13 = ...;

  if ( event == "PLAYER_ENTERING_WORLD") then
    IsHeUpYet:init();
  end
end

function IsHeUpYet:updateSoundAlarmIcon()
  if ( IsHeUpYetSaved.soundAlarm ) then
    IsHeUpYetSoundAlarm:SetButtonState("PUSHED", true);
  else
    IsHeUpYetSoundAlarm:SetButtonState("NORMAL");
  end
end

function IsHeUpYet:updateSoundAlarm()
  DEFAULT_CHAT_FRAME:AddMessage(IsHeUpYetSaved.soundAlarm);
  if ( IsHeUpYetSaved.soundAlarm == true ) then
    StopMusic();
    IsHeUpYetSaved.soundAlarm = false;
  else
    IsHeUpYetSaved.soundAlarm = true;
  end
  IsHeUpYet:updateSoundAlarmIcon();
end

function IsHeUpYet:playAlarm()
  if ( IsHeUpYetSaved.soundAlarm ) then
    StopMusic();
    PlayMusic("Interface\\AddOns\\IsHeUpYet\\Assets\\alarm_tone.mp3")
  end
end

function IsHeUpYet:checkForMob(mobName)
  local total = GetObjectCount(true);
  for i = 1,total do
    local objectId = GetObjectWithIndex(i);
    if ( ObjectExists(objectId) ) then
      local objectName = ObjectName(objectId);
      if ( type(objectName) == "string" and strlower(objectName) == strlower(mobName) ) then
        IsHeUpYet:playAlarm();
        RunMacroText("/target "..objectName);
        break;
      end
    end
  end
end

function IsHeUpYet:checkMobs()
  if ( IsHeUpYetSaved.soundAlarm ) then
    if ( IsHeUpYetSaved.lookFor.mobOne and string.len(IsHeUpYetSaved.lookFor.mobOne) > 0 ) then
      IsHeUpYet:checkForMob(IsHeUpYetSaved.lookFor.mobOne);
    end

    if ( IsHeUpYetSaved.lookFor.mobTwo and string.len(IsHeUpYetSaved.lookFor.mobTwo) > 0 ) then
      IsHeUpYet:checkForMob(IsHeUpYetSaved.lookFor.mobTwo);
    end

    if ( IsHeUpYetSaved.lookFor.mobTree and string.len(IsHeUpYetSaved.lookFor.mobTree) > 0 ) then
      IsHeUpYet:checkForMob(IsHeUpYetSaved.lookFor.mobTree);
    end
  end
end

function IsHeUpYet:updateInterval()
  if (IsHeUpYet.interval) then
    Timer.clearTimer(IsHeUpYet.interval);
  end
  IsHeUpYet.interval = Timer.setInterval(IsHeUpYetSaved.interval, function() IsHeUpYet:checkMobs(); end );
end

function IsHeUpYet:init()
  if ( not self.initiated ) then
    local IsHeUpYetLDB, icon;
    IsHeUpYetLDB = LibStub("LibDataBroker-1.1"):NewDataObject(IsHeUpYet.addonName, {
      type = "data source",
      icon = "Interface\\AddOns\\IsHeUpYet\\Assets\\BattlenetWorking0",
      OnClick = IsHeUpYet.toggleOptions,
    });

    icon = LibStub("LibDBIcon-1.0");
    icon:Register(IsHeUpYet.addonName, IsHeUpYetLDB, IsHeUpYetSaved.minimap);
    IsHeUpYet:updateInterval();
    IsHeUpYet.initiated = true;
  end
end

function IsHeUpYet:bindEvents()
  self:RegisterEvent("PLAYER_ENTERING_WORLD");
  self:SetScript("OnEvent", self.OnEvent);
end

function IsHeUpYet:RegisterSlashCommands()
  SLASH_IHUY1 = "/IHUY";
  SLASH_IHUY2 = "/IsHeUpYet";
  SlashCmdList["IHUY"] = function(msg)
    IsHeUpYet:toggleOptions()
  end
end

IsHeUpYet:RegisterSlashCommands();
IsHeUpYet:bindEvents();