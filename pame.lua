script_name('PAME')
script_author('akionka')
script_version('1.0')
script_version_number(1)
script_description([[Теперь вместо нагружающих 3D текстов с описанием персонажа у вас будет удобненький pame.]])

local sampev = require 'lib.samp.events'
local encoding = require 'encoding'
local inicfg = require('inicfg')
encoding.default = 'cp1251'
u8 = encoding.UTF8

pames = {}

local ini = inicfg.load({
	settings = {
		enable = true
	}
}, "pame")

function sampev.onPlayerQuit(id, reason)
	pames[id] = nil
end

function sampev.onCreate3DText(id, color, pos, dist, testLOS, attplayer, attveh, text)
	if color == -1347440658 and attplayer ~= 65535 and ini.settings.enable then
		pames[attplayer] = text:gsub("\n", " ")
		return false
	end
end

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(0) end
	sampAddChatMessage(u8:decode("[PAME]: Скрипт {00FF00}успешно{FFFFFF} загружен. Версия: {2980b9}"..thisScript().version.."{FFFFFF}."), -1)
	update()
	while updateinprogess ~= false do wait(0) end
	sampRegisterChatCommand("pametog", function()
		ini.settings.enable = not ini.settings.enable
		inicfg.save(ini, "pame")
		sampAddChatMessage(ini.settings.enable and u8:decode("[PAME]: Скрипт {00FF00}включен{FFFFFF}.") or u8:decode("[PAME]: Скрипт {FF0000}выключен{FFFFFF}."), -1)
	end)
	sampRegisterChatCommand("pame", function(params)
		if not ini.settings.enable then return true end
		params = tonumber(params)
		if params == nil then sampAddChatMessage(u8:decode("[PAME]: {FF0000}Error!{FFFFFF} Используйте: /pame [ID]."), -1) return true end
		if pames[params] == nil then sampAddChatMessage(u8:decode("[PAME]: {FF0000}Error!{FFFFFF} Скрипт не знает описание данного игрока, либо его у него нет."), -1) return true end
		if sampIsDialogActive() then sampAddChatMessage(u8:decode("[PAME]: {FF0000}Error!{FFFFFF} Закройте диалоговое окно."), -1) return true end
		sampShowDialog(31415, u8:decode("{FFFFFF}Описание {2980b9}"..sampGetPlayerNickname(params)), "{FFFFFF}"..pames[params], u8:decode("Закрыть"), "", DIALOG_STYLE_MSGBOX)
	end)
end

function update(auto)
	local fpath = os.getenv('TEMP') .. '\\pame-version.json'
	downloadUrlToFile('https://raw.githubusercontent.com/Akionka/pame/master/version.json', fpath, function(id, status, p1, p2)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			local f = io.open(fpath, 'r')
			if f then
				local info = decodeJson(f:read('*a'))
				if info and info.version then
					version = info.version
					version_num = info.version_num
					if version_num > thisScript().version_num then
						sampAddChatMessage(u8:decode("[PAME]: Найдено объявление. Текущая версия: {2980b9}"..thisScript().version.."{FFFFFF}, новая версия: {2980b9}"..version.."{FFFFFF}. Начинаю закачку"), -1)
						lua_thread.create(goupdate)
					else
						updateinprogess = false
					end
				end
			end
		end
	end)
end

function goupdate()
	wait(300)
	downloadUrlToFile("https://raw.githubusercontent.com/Akionka/pame/master/pame.lua", thisScript().path, function(id3, status1, p13, p23)
		if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
			sampAddChatMessage((u8:decode('[PAME]: Новая версия установлена! Чтобы скрипт обновился нужно либо перезайти в игру, либо ...')), -1)
			sampAddChatMessage((u8:decode('[PAME]: ... если у вас есть автоперезагрузка скриптов, то новая версия уже готова и снизу вы увидите приветственное сообщение')), -1)
			sampAddChatMessage((u8:decode('[PAME]: Если что-то пошло не так, то сообщите мне об этом в VK или Telegram > vk.com/akionka tele.run/akionka')), -1)
		end
	end)
end
