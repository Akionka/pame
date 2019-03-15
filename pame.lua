script_name('PAME')
script_author('akionka')
script_version('1.5.1')
script_version_number(7)

local sampev   = require 'lib.samp.events'
local encoding = require 'encoding'
local inicfg   = require('inicfg')
local dlstatus = require('moonloader').download_status
encoding.default = 'cp1251'
u8 = encoding.UTF8

local updatesavaliable = false
local pames = {}

local ini = inicfg.load({
	settings = {
		enable = true
	}
}, "pame")

function sampev.onPlayerQuit(id, reason)
	pames[id] = nil
end

function sampev.onCreate3DText(id, color, pos, dist, testLOS, attplayer, attveh, text)
	if color == -1347440658 and attplayer ~= 65535 and ini.settings.enable and attplayer ~= select(2, sampGetPlayerIdByCharHandle(PLAYER_HANDLE)) then
		pames[attplayer] = text:gsub("\n", " ")
		return false
	end
end

function main()
	if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(0) end
	sampAddChatMessage(u8:decode("[PAME]: Скрипт {00FF00}успешно{FFFFFF} загружен. Версия: {2980b9}"..thisScript().version.."{FFFFFF}."), -1)

	checkupdates('https://raw.githubusercontent.com/Akionka/pame/master/version.json')

	sampRegisterChatCommand('pameupdate', function()
		if updatesavaliable then
			update('https://raw.githubusercontent.com/Akionka/pame/master/pame.lua')
		end
	end)

	sampRegisterChatCommand('pamecheck', function()
		checkupdates('https://raw.githubusercontent.com/Akionka/pame/master/version.json')
	end)

	sampRegisterChatCommand("pametog", function()
		ini.settings.enable = not ini.settings.enable
		inicfg.save(ini, "pame")
		sampAddChatMessage(ini.settings.enable and u8:decode("[PAME]: Скрипт {00FF00}включен{FFFFFF}.") or u8:decode("[PAME]: Скрипт {FF0000}выключен{FFFFFF}."), -1)
	end)
	sampRegisterChatCommand("pame", function(params)
		print(pames)
		if not ini.settings.enable then return true end
		params = tonumber(params)
		if params == nil then sampAddChatMessage(u8:decode("[PAME]: {FF0000}Error!{FFFFFF} Используйте: /pame [ID]."), -1) return true end
		if pames[params] == nil then sampAddChatMessage(u8:decode("[PAME]: {FF0000}Error!{FFFFFF} Скрипт не знает описание данного игрока, либо его у него нет."), -1) return true end
		if sampIsDialogActive() then sampAddChatMessage(u8:decode("[PAME]: {FF0000}Error!{FFFFFF} Закройте диалоговое окно."), -1) return true end
		sampShowDialog(31415, u8:decode("{FFFFFF}Описание {2980b9}"..sampGetPlayerNickname(params)), "{FFFFFF}"..pames[params], u8:decode("Закрыть"), "", DIALOG_STYLE_MSGBOX)
	end)
end

function checkupdates(json)
	local fpath = os.getenv('TEMP')..'\\'..thisScript().name..'-version.json'
	if doesFileExist(fpath) then os.remove(fpath) end
	downloadUrlToFile(json, fpath, function(_, status, _, _)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if doesFileExist(fpath) then
				local f = io.open(fpath, 'r')
				if f then
					local info = decodeJson(f:read('*a'))
					local updateversion = info.version_num
					f:close()
					os.remove(fpath)
					if updateversion > thisScript().version_num then
						updatesavaliable = true
						sampAddChatMessage(u8:decode("[PAME]: Найдено объявление. Текущая версия: {2980b9}"..thisScript().version.."{FFFFFF}, новая версия: {2980b9}"..info.version.."{FFFFFF}."), -1)
						sampAddChatMessage(u8:decode("[PAME]: Используйте команду {2980b0}/pameupdate{FFFFFF}, чтобы обновиться до последней версии."), -1)
						return true
					else
						updatesavaliable = false
						sampAddChatMessage(u8:decode("[PAME]: У вас установлена самая свежая версия скрипта."), -1)
					end
				else
					updatesavaliable = false
					sampAddChatMessage(u8:decode("[PAME]: Что-то пошло не так, упс. Попробуйте позже."), -1)
				end
			end
		end
	end)
end

function update(url)
	downloadUrlToFile(url, thisScript().path, function(_, status1, _, _)
		if status1 == dlstatus.STATUS_ENDDOWNLOADDATA then
			sampAddChatMessage(u8:decode('[PAME]: Новая версия установлена! Чтобы скрипт обновился нужно либо перезайти в игру, либо ...'), -1)
			sampAddChatMessage(u8:decode('[PAME]: ... если у вас есть автоперезагрузка скриптов, то новая версия уже готова и снизу вы увидите приветственное сообщение.'), -1)
			sampAddChatMessage(u8:decode('[PAME]: Если что-то пошло не так, то сообщите мне об этом в VK или Telegram > {2980b0}vk.com/akionka teleg.run/akionka{FFFFFF}.'), -1)
			thisScript():reload()
		end
	end)
end
