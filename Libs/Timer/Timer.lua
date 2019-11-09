local f = CreateFrame("Frame", "TimerFrame", UIParent);
Timer = {};
Timer.timers = {};
Timer.onUpdateInterval = 0.1;
Timer.timeSinceLastUpdate = 0;
Timer.loopStarted = false;

local LETTER_LIST = {
  "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z",
  "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
  1, 2, 3, 4, 5, 6, 7, 8, 9, 0, "_", "-"
};

function randomString(len)
  local str, letterList;
  len = len or 25;
  local str = "";
  letterList = LETTER_LIST;
  for i = 1, len do
    str = str..letterList[random(1, 64)];
  end
  return str;
end

function findIndex(tbl, test)
  if (type(tbl) ~= "table") then
    error("bad argument #1 to 'findIndex' (table expected, got " .. type(tbl) .. ")");
  end
  if (type(test) ~= "function") then
    error("bad argument #2 to 'findIndex' (function expected, got " .. type(tbl) .. ")");
  end
  for index, value in pairs(tbl) do
    if (test(index, value)) then
      return index;
    end
  end
  return 0;
end

local function calcExpireAt(interval)
  return time() + interval;
end

local function isItTime(expireAt)
  return time() >= expireAt;
end

local function checkAllTimers()
  for index, timer in pairs(Timer.timers) do
    if (isItTime(timer.expireAt)) then
      if (timer.isInterval) then
        timer.expireAt = calcExpireAt(timer.interval);
        if (timer.argTable) then
          timer.callback(unpack(timer.argTable));
        else
          timer.callback();
        end
      else
        if (timer.argTable) then
          timer.callback(unpack(timer.argTable));
        else
          timer.callback();
        end
        Timer.clearTimer(timer.id);
      end
    end
  end;
end

local function onUpdate(self, elapsed)
  Timer.timeSinceLastUpdate = Timer.timeSinceLastUpdate + elapsed;
  if Timer.timeSinceLastUpdate >= Timer.onUpdateInterval then
    Timer.timeSinceLastUpdate = 0;
    checkAllTimers();
  end
end


local function startLoop()
  if (Timer.loopStarted) then
    return false;
  end
  f:SetScript("OnUpdate", onUpdate);
  Timer.loopStarted = true;
  Timer.onUpdateInterval = 0.1;
  Timer.timeSinceLastUpdate = 0;
end

local function endLoop()
  if (Timer.loopStarted ~= true) then
    return false;
  end
  f:SetScript("OnUpdate", nil);
  Timer.loopStarted = false;
end

local function haveTimers()
  return table.getn(Timer.timers) > 0;
end

local function checkForTimers()
  if (haveTimers()) then
    startLoop();
  else
    endLoop();
  end
end

local function createTableTimer(expireAt, interval, isInterval, callback, argTable)
  return { id = randomString(), expireAt = expireAt; interval = interval; isInterval = isInterval; callback = callback; argTable = argTable };
end

-- public functions
function Timer.setInterval(interval, callback, argTable)
  if (type(interval) ~= "number" or type(callback) ~= "function") then
    return false;
  end
  local expireAt = calcExpireAt(interval);
  local timer = createTableTimer(expireAt, interval, true, callback, argTable);
  table.insert(Timer.timers, timer);
  checkForTimers();
  return timer.id;
end

function Timer.setTimeout(interval, callback, argTable)
  if (type(interval) ~= "number" or type(callback) ~= "function") then
    return false;
  end
  local expireAt = calcExpireAt(interval);
  local timer = createTableTimer(expireAt, interval, false, callback, argTable);
  table.insert(Timer.timers, timer);
  checkForTimers();
  return timer.id;
end

function Timer.clearTimer(timerId)
  local index = findIndex(Timer.timers, function(index, timer) return timer.id == timerId; end);
  if ( index > 0 ) then
    table.remove(Timer.timers, index);
  end
  checkForTimers();
end
