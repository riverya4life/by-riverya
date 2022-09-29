script_name("!.byriverya")
script_version("0.8")
script_author('RIVERYA4LIFE.')
require 'lib.moonloader'

-- подключаемые Libs
local samp = require 'lib.samp.events'
local ev = require 'samp.events'
local mem = require 'memory'
local vkeys = require 'vkeys'
local wm = require("windows")

--==[CONFIG DIALOG MOOVE]==--
local dragging = false
local dragX, dragY = 0, 0
local CDialog, CDXUTDialog = 0, 0

local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

--==[config]==--
local inicfg = require 'inicfg'

local directIni = 'ByRiverya4life.ini'
local ini = inicfg.load(inicfg.load({
    main = {
        arizonadialogstyle = true,
		radarandhudpatching = false,
    },
}, directIni))
inicfg.save(ini, directIni)

--==[HUETA]==--
local statedialog = ini.main.arizonadialogstyle
local arizonadialogtag = '{c52c42}Dialog from ARZ Launcher by riverya4life: {ffffff}'
local radarandhudpatchtag = '{42B166}Патч радара: {ffffff}'
local radarandhudpatch = ini.main.radarandhudpatching
-- stats
local onspawned = false
local offspawnchecker = true

-- Config for command
local commands = {'clear', 'threads', 'chatcmds'}
local currentmoney = 0
local nowmymoney = 0

-- info
local author = 'RIVERYA4LIFE.'
local tiktok = 'tiktok.com/@riverya4life'
local vk = 'vk.com/riverya4life'

-- для скрытия описания перса
local active = nil
local pool = {}

local MAX_SAMP_MARKERS = 63

-- Message if the description does not exist:
no_description_text = "* Описание отсутствует *"


function update()
    local raw = 'https://raw.githubusercontent.com/riverya4life/-by-riverya-autoupdate/main/!.byriveryaAutoupdate.json'
    local dlstatus = require('moonloader').download_status
    local requests = require('requests')
    local f = {}
    function f:getLastVersion()
        local response = requests.get(raw)
        if response.status_code == 200 then
            return decodeJson(response.text)['last']
        else
            return 'UNKNOWN'
        end
    end
    function f:download()
        local response = requests.get(raw)
        if response.status_code == 200 then
            downloadUrlToFile(decodeJson(response.text)['url'], thisScript().path, function (id, status, p1, p2)
                print('Скачиваю '..decodeJson(response.text)['url']..' в '..thisScript().path)
                if status == dlstatus.STATUSEX_ENDDOWNLOAD then
                    sampAddChatMessage('Скрипт {42B166}обновлен{ffffff}, перезагрузка...', -1)
                    thisScript():reload()
                end
            end)
        else
            sampAddChatMessage('{dc4747}Ошибка{ffffff}, невозможно установить обновление! Код: '..response.status_code, -1)
        end
    end
    return f
end

function ev.onCreate3DText(id, col, pos, dist, wall, PID, VID, text)
	if PID ~= 65535 and col == -858993409 and pos.z == -1 then
		pool[PID] = {id = id, col = col, pos = pos, dist = dist, wall = wall, PID = PID, VID = VID, text = text }
		return false
	end
end

function ev.onRemove3DTextLabel(id)
	for i, info in ipairs(pool) do
		if info.id == id then
			table.remove(pool, i)
		end
	end
end

function sayhello()
	sampAddChatMessage('{FFFFFF}Сборку сделал {42B166}'..author..' {FFFFFF}| {74adfc}'..vk..' {FFFFFF}I{74adfc} '..tiktok..'', -1)
	sampAddChatMessage('{42B166}[Уютненько :)]{ffffff} Меню скрипта: {dc4747}/riverya{FFFFFF}. Версия скрипта {42B166}' ..thisScript().version, -1)
end

function main()
	repeat wait(100) until isSampAvailable()
	--if not isSampLoaded() or not isSampfuncsLoaded() then return end
	--while not isSampAvailable() do wait(100) end
	
	--sampAddChatMessage('{FFFFFF}Сборку сделал {42B166}'..author..' {FFFFFF}| {74adfc}'..vk..' {FFFFFF}I{74adfc} '..tiktok..'', -1)
	--sampAddChatMessage('{42B166}[Уютненько :)]{ffffff} Меню скрипта: {dc4747}/riverya{FFFFFF}. Версия скрипта {42B166}' ..thisScript().version, -1)
	
	local lastver = update():getLastVersion()
    if thisScript().version ~= lastver then
        sampRegisterChatCommand('riveryaupd', function()
            update():download()
        end)
        sampAddChatMessage('{42B166}[!.by riverya]{ffffff} Вышло обновление скрипта ({dc4747}'..thisScript().version..'{ffffff} -> {42B166}'..lastver..'{ffffff}), введите {dc4747}/riveryaupd{ffffff} для обновления!', -1)
    end
	
	if statedialog then setDialogColor(0xCC38303c, 0xCC363050, 0xCC75373d, 0xCC583d46) end
	if radarandhudpatch then mem.write(sampGetBase() + 643864, 37008, 2, true) end

	--setDialogColor(0xCC38303c, 0xCC363050, 0xCC75373d, 0xCC583d46) -- dialog color by riverya4life

    _, myid = sampGetPlayerIdByCharHandle(playerPed)
    mynick = sampGetPlayerNickname(myid) -- наш ник крч
    -- nick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))

    -- для скрытия описания перса
    local duration = 0.3
    local max_alpha = 255
    local start = os.clock()
    local finish = nil

  	-- Блок памяти
	
	mem.setint8(0xB7CEE4, 1) -- бесконечный бег
	mem.fill(0x58DD1B, 0x90, 2, true) -- звёзды на экране
	mem.setuint8(0x588550, 0xEB, true) -- disable arrow
	mem.setuint32(0x58A4FE + 0x1, 0x0, true) -- disable green rect
	mem.setuint32(0x586A71 + 0x1, 0x0, true) -- disable height indicator
	mem.setuint8(0x58A5D2 + 0x1, 0x0, true)
	mem.setuint32(0x58A73B + 0x1, 0x0, true) -- залупа которая бесит крч фисташки
	mem.write(sampGetBase() + 383732, -1869574000, 4, true) -- блок клавишы Т (рус. Е)
	mem.fill(0x047C8CA, 0x90, 5, true) -- fix cj bug
	mem.setuint8(0x53E94C, 0x0, true) -- RemoveFrameDelay
	mem.fill(0x4217F4, 0x90, 21, true) -- spawn fix
    mem.fill(0x4218D8, 0x90, 17, true)
    mem.fill(0x5F80C0, 0x90, 10, true)
    mem.fill(0x5FBA47, 0x90, 10, true)
	mem.setint8(0x58D3DA, 1, true)
	mem.setfloat(0xCB0725, 0.0, true) -- удаление отрисовки черной рамки вокруг карты
	mem.setfloat(0xCB0730, 1.0, true)
	mem.write(0x5752EE, 0xCB0725, 4, true)
	mem.write(0x575313, 0xCB0730, 4, true)
	mem.write(0x57533E, 0xCB0725, 4, true)
	mem.write(0x575363, 0xCB0730, 4, true)
	mem.fill(0x00531155, 0x90, 5, true) -- shift fix by FYP
	mem.write(0x736F88, 0, 4, false) -- вертолет не взрывается много раз
    mem.write(0x53E94C, 0, 1, false) -- del fps delay 14 ms
    mem.fill(0x555854, 0x90, 5, false) -- InterioRreflections
    mem.write(0x745BC9, 0x9090, 2, false) -- SADisplayResolutions(1920x1080// 16:9)
    mem.fill(0x460773, 0x90, 7, false) -- CJFix
    mem.write(12761548, 1051965045, 4, false) -- car speed fps fix
    mem.fill(0x5557CF, 0x90, 7, true) -- binthesky_by_DK
	mem.setint32(0x866C94, 0x6430302524, true) -- Позитивные деньги с удалением нулей
	mem.setint64(0x866C8C, 0x64303025242D, true) -- Негативные деньги с удалением нулей
	mem.write(12697552, 1, 1, false)-- включает свечение шашки такси
	mem.write(0x058E280, 0xEB, 1, true) -- fix crosshair
	mem.write(0x5109AC, 235, 1, true) -- nocamrestore
	mem.write(0x5109C5, 235, 1, true)
	mem.write(0x5231A6, 235, 1, true)
	mem.write(0x52322D, 235, 1, true)
	mem.write(0x5233BA, 235, 1, true)
	
	--mem.write(sampGetBase() + 643864, 37008, 2, true) -- Патч радара при слежке
	--mem.fill(0x74542B, 0x90, 6, true) -- nop SetCursorPos
	
	--[[mem.fill(0x57E3AE, 0x90, 5, true)-- подсказки
	mem.fill(0x579698, 0x90, 5, true) -- отключает надпись на меню сверху]]--

	--memory.setint32(0x866C94, 0x6438302524, true) -- Позитивные деньги стандартное значение
	--mem.setint32(0x866C94, 0x6430302524, true) -- Позитивные деньги с удалением нулей

	--memory.setint64(0x866C8C, 0x64373025242D, true) -- Негативные деньги стандартное значение
	--mem.setint64(0x866C8C, 0x64303025242D, true) -- Негативные деньги с удалением нулей

	sampHandle = sampGetBase()
	writeMemory(sampHandle + 0x2D3C45, 4, 0, 1) -- фикс задержки в 3 сек при подключении


	for i = 1, #commands do
    	runSampfuncsConsoleCommand(commands[i])
	end

-- Блок зарегестрированных команд
	sampRegisterChatCommand('riverya', riverya)
	sampRegisterChatCommand('riveryahelp', riveryahelp)
	
	sampRegisterChatCommand('kosdmitop', function()
		readMemory(0, 1)
	end)
	sampRegisterChatCommand('riveryalox', function()
		readMemory(0, 1)
	end)
	sampRegisterChatCommand('riveryaloh', function()
		readMemory(0, 1)
	end)

	sampRegisterChatCommand('pivko', cmd_pivko) -- прикол
  	sampRegisterChatCommand('givepivo', cmd_givepivo) -- прикол х2
  	sampRegisterChatCommand('takebich', cmd_takebich) -- не курите в реале
  	sampRegisterChatCommand('mystonks', cmd_getmystonks)

	sampRegisterChatCommand("fps", function() -- зареганные кмд с функцией в main
		runSampfuncsConsoleCommand('fps')
	end)
		
    sampRegisterChatCommand('cc', ClearChat)
	
	sampRegisterChatCommand('riveryarl', function()
		thisScript():reload()
	end)
	
	sampRegisterChatCommand('radarpatch', function()
		radarandhudpatch = not radarandhudpatch
        if radarandhudpatch then
            mem.write(sampGetBase() + 643864, 37008, 2, true)
        else
            mem.write(sampGetBase() + 643864, 3956, 2, true)
        end
        sampAddChatMessage(radarandhudpatch and radarandhudpatchtag..'включен' or radarandhudpatchtag..'выключен', -1)
        save()
    
    end)
	
	sampRegisterChatCommand('dialogarz', function()
        statedialog = not statedialog
        if statedialog then
            setDialogColor(0xCC38303c, 0xCC363050, 0xCC75373d, 0xCC583d46) -- dialog color by riverya4life
        else
            setDialogColor(0xCC000000, 0xCC000000, 0xCC000000, 0xCC000000)
        end
        sampAddChatMessage(statedialog and arizonadialogtag..'цвет включен' or arizonadialogtag..'цвет выключен', -1)
        save()
    
    end)
	
    while true do wait(0)
		
		onspawned = sampGetGamestate() == 3
		if onspawned then
			if offspawnchecker == true then			
				sayhello()
			offspawnchecker = false
			end
		end
		
        local chatstring = sampGetChatString(99)
        if chatstring == "Server closed the connection." or chatstring == "You are banned from this server." or chatstring == "Сервер закрыл соединение." or chatstring == "Вы забанены на этом сервере." then
	    sampDisconnectWithReason(false)
            sampAddChatMessage("Wait reconnecting...", 0xa9c4e4)
            wait(15000) -- задержка
            sampSetGamestate(1)
        end
		
		if author ~= 'RIVERYA4LIFE.' then
			thisScript():unload()
			callFunction(0x823BDB , 3, 3, 0, 0, 0)	
		end
		
		local result, ped = getCharPlayerIsTargeting(PLAYER_HANDLE)
		if result then
			finish = nil
			local id = select(2, sampGetPlayerIdByCharHandle(ped))
			if pool[id] ~= nil then
				if active == nil then start = os.clock() end
				local alpha = saturate(((os.clock() - start) / duration) * max_alpha)
				local color = join_argb((os.clock() - start) <= duration and alpha or max_alpha, 204, 204, 204)
				active = pool[id]
				sampCreate3dTextEx(pool[id].id, pool[id].text, color, pool[id].pos.x, pool[id].pos.y, pool[id].pos.z, pool[id].dist, pool[id].wall, pool[id].PID, -1)
			else
				if active == nil then start = os.clock() end
				local alpha = saturate(((os.clock() - start) / duration) * max_alpha)
				local color = join_argb((os.clock() - start) <= duration and alpha or max_alpha, 204, 204, 204)
				active = {id = 13, text = no_description_text, col = color, pos = {x = 0, y = 0, z = -1}, dist = 3, wall = false, PID = id, VID = -1}
				sampCreate3dTextEx(active.id, active.text, color, active.pos.x, active.pos.y, active.pos.z, active.dist, active.wall, active.PID, active.VID)
			end
		elseif active ~= nil then
			if finish == nil then finish = os.clock() end
			local alpha = saturate(((os.clock() - finish) / duration) * max_alpha)
			local color = join_argb(max_alpha - alpha, 204, 204, 204)
			sampCreate3dTextEx(active.id, active.text, color, active.pos.x, active.pos.y, active.pos.z, active.dist, active.wall, active.PID, active.VID)
			if (os.clock() - finish) >= duration then
				sampDestroy3dText(active.id)
				active, finish = nil, nil
			end
		end
		
		wait(0)
        CDialog = sampGetDialogInfoPtr()
        CDXUTDialog = mem.getuint32(CDialog + 0x1C) -- R1/R3 offset
    end
end

function riverya()
    sampShowDialog(13337,'{dc4747}[Info]','{ffffff}Приветствуем, {dc4747}'..mynick..'!{ffffff}\n\n{ffffff}Сборку сделал Я, {42B166}'..author..' (Риверя).\n\n{ffffff}Я вообще не планировал её сливать из-за своей лени.{ffffff}\nНу что не сделаешь ради просмотров и лайков.\nПодпишись на мой тик ток:\n{dc4747}• '..tiktok..'.\n\n\n{dc4747}*{ffffff}Если ты не мой подписчик, то лучше подпишись, а то мне обидно будет плак плак({dc4747}*{ffffff}\n\n{dc4747}Доступные команды:{ffffff}\n {42B166}•{ffffff} /riverya - Основное окно.\n {42B166}•{ffffff} /dialogarz - Диалоги с лаунчера Arizona RP.\n {42B166}•{ffffff} /riveryatop - Тест команда\n {dc4747}•{ffffff} /riveryahelp - Тут всё подробно описано.','{42B166}Уютненько','{dc4747}Пон',0)
    lua_thread.create(hui)
end

function riveryahelp()
    sampShowDialog(13339,'{dc4747}[Help]','{ffffff}Привет ещё раз, я тебе распишу всё, что есть в скрипте, который я писал для сборки.\n{42B166}Что было добавлено:{ffffff}\n\n   •   Теперь вы не сможете перейти в оконный режим с помощью комбинации {dc4747}Alt + Enter{ffffff} во избежания вылета игры.\n   •   Если сервер стоит под паролем, то будет флудить строкой {dc4747}"Wrong Server Password"{ffffff} до тех пор, пока с сервера не снимут пароль.\n   •   При входе в игру в консоль {dc4747}SampFuncs{ffffff} будут прописаны команды {dc4747}clear, threads и chatcmds{ffffff} автоматически.\n   •   {dc4747}Звёзды{ffffff} теперь отображаются на экране всегда.\n   •   Теперь чтобы вывести счётчик {dc4747}FPS{ffffff} достаточно прописать в чат команду {dc4747}/fps{ffffff} (теперь в консоль {dc4747}SampFuncs{ffffff} заходить не обязательно)\n   •   Убран надоедливый зелёный радар при полетё (осталась только тестура в {dc4747}hud.txd{ffffff}, которая заменяется на которую хотите)\n   •   Добавлена команда {dc4747}/mystonks{ffffff} для для просмотра своего дохода за текущую сессию.\n   •   Добавлена команда {dc4747}/pivko{ffffff} для посиделок с братанами вечерком или для RP ситуаций, так же есть команда {dc4747}/givepivo ID{ffffff} чтобы передать (у вас в руках появиться пивко)\n   •   Добавлена команда {dc4747}/takebich{ffffff} чтобы можно было покурить с братком на районе (всем будет видно)\n   •   Теперь {dc4747}описание{ffffff} не будет видно, пока вы не нацелитесь на игрока (под Аризону как некий FPS UP)\n   •   Теперь клавиша {dc4747}T (рус. Е){ffffff} не открывает чат (по умолчанию теперь клавиша {dc4747}F6{ffffff})\n   •   Исправлен {dc4747}баг{ffffff} с бегом Сиджея после смерти.\n   •   Исправлена проблема, когда после {dc4747}смерти{ffffff} у тебя появляется бутылка пива и т.д.\n   •   {dc4747}Удалена задержка{ffffff} в 14 мс между кадрами.\n   •   Убрана {dc4747}задержка в 3 секунды{ffffff} при подключении на сервер.\n   •   Добавлена команда {dc4747}/dialogarz{ffffff} для возможности включения цвета диалогов как на лаунчере Arizona Role Play.\n   •   При отключении от сервера Вас теперь будет {dc4747}автоматически реконнектить{ffffff}.\n   •   {dc4747}[Arizona]{ffffff} Теперь пин-код банковской карты и код складских помещений скрыт, как при {dc4747}вводе пароля{ffffff}.\n   •   Теперь из за очень большой скорости вас {dc4747}не будет кидать в Загрузку{ffffff}.\n   •   По команде {dc4747}/radarpatch{ffffff} включится патч радара (Будет везде, даже при заходе на сервер)\n   •   Теперь сама игра запускается {dc4747}в 3 раза{ffffff} быстрее.\n   •   При вводе команд {dc4747}/riveryaloh{ffffff} или {dc4747}/riveryalox{ffffff} вас ждёт сюрприз {dc4747}<3{ffffff}','{42B166}Уютненько','',0)
    lua_thread.create(negrtop)
end

function hui()
	while sampIsDialogActive() do
	wait(0)
	local __, button, list, input = sampHasDialogRespond(13337)
	if __ and button == 1 then
        sampAddChatMessage('{42B166}[#riverya4life] {ffffff}Автор сборки ленивая жопа.', -1)
	elseif __ and button == 0 then
		sampShowDialog(13338,'{dc4747}[Реклама]','{ffffff}Играй со мной на {dc4747}Arizona Role Play Scottdale.{ffffff}\n\nРегистрируйся на мой ник {42B166}Tape_Riverya{ffffff} и получай целых {42B166}300.000${FFFFFF} на 5 уровне.\nПо желанию на 6 уровне вводи промокод {42B166}#riverya4life{FFFFFF}\nОт системы получишь {42B166}100.000${FFFFFF} и от меня ещё целый {42B166}МИЛЛИОН ДОЛЛАРОВ!{FFFFFF}\n\n\nНу а так желаю приятной игры {dc4747}<3{FFFFFF}','{42B166}Уютненько','',0)
		end
	end
end

function negrtop()
	while sampIsDialogActive() do
	wait(0)
	local __, button, list, input = sampHasDialogRespond(13339)
	if __ and button == 0 then
		sampAddChatMessage('{42B166}[#riverya4life] {ffffff}Уютненько обед.', -1)
		end
	end
end

function onReceivePacket(id) -- будет флудить wrong server password до тех пор, пока сервер не откроется
	if id == 37 then
		sampSetGamestate(1)
	end
end

function ev.onSendPlayerSync(data) -- банни хоп
	if data.keysData == 40 or data.keysData == 42 then sendOnfootSync(); data.keysData = 32 end
end

function sendOnfootSync()
	local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
	local data = allocateMemory(68)
	sampStorePlayerOnfootData(myId, data)
	setStructElement(data, 4, 1, 0, false)
	sampSendOnfootData(data)
	freeMemory(data)
end -- тут конец уже

function onWindowMessage(msg, wparam, lparam) -- блокировка клавиш alt + tab 
	if msg == 261 and wparam == 13 then consumeWindowMessage(true, true) end

	if not sampIsDialogActive() then
        return
    end

    if msg == wm.msg.WM_LBUTTONDOWN then
        local curX, curY = getCursorPos()
        local x, y = sampGetDialogPos()
        local w = sampGetDialogSize()
        local h = sampGetDialogCaptionHeight()
        if (curX >= x and curX <= x + w and curY >= y and curY <= y + h) then
            dragging = true
            dragX = x - curX
            dragY = y - curY
        end
    elseif msg == wm.msg.WM_LBUTTONUP then
        dragging = false
    elseif msg == wm.msg.WM_MOUSEMOVE and dragging then
        local curX, curY = getCursorPos()
        local _, scrY = getScreenResolution()
        local nextX, nextY = curX + dragX, curY + dragY

        nextY = math.min(math.max(nextY, -15), scrY - 15)

        sampSetDialogPos(nextX, nextY)
    end
end

function cmd_getmystonks()
	local _, myid = sampGetPlayerIdByCharHandle(playerPed)
	mynick = sampGetPlayerNickname(myid)
	
	local result = 0
	nowmymoney = getPlayerMoney(mynick)
	result = nowmymoney - currentmoney
	
	sampAddChatMessage('{dc4747}[#riverya4life]{ffffff} За сессию Вы заработали '..'{5EEE0C}'.. result ..'${FF0000}', -1)
end

function cmd_givepivo(arg1)
	local targetnick = sampGetPlayerNickname(arg1)
	lua_thread.create(function()
		sampSendChat('/me достал из сумки пиво.')
		wait(500)
		runSampfuncsConsoleCommand('0afd:22')
		wait(1500)
		sampSendChat('/me передал пиво '..targetnick)
		wait(1500)
		sampSendChat('Угощяйся бро!')
	end)
end

function cmd_pivko()
	lua_thread.create(function()
		sampSendChat('/me достал из сумки пиво, открыл бутылку, начал пить.')
		wait(500)
		runSampfuncsConsoleCommand('0afd:22')
	end)
end

function cmd_takebich()
	lua_thread.create(function()
		sampSendChat("/me достал с кармана пачку сигарет, закурил.")
		wait(500)
		runSampfuncsConsoleCommand('0afd:21')
	end)
end

function join_argb(a, r, g, b)
    local argb = b
    argb = bit.bor(argb, bit.lshift(g, 8))
    argb = bit.bor(argb, bit.lshift(r, 16))
    argb = bit.bor(argb, bit.lshift(a, 24))
    return argb
end

function saturate(f) 
	return f < 0 and 0 or (f > 255 and 255 or f) 
end

function setNextRequestTime(time)
    local samp = getModuleHandle("samp.dll")
    mem.setuint32(samp + 0x3DBAE, time, true)
end

function ev.onSetVehicleVelocity(turn, velocity)
    if velocity.x ~= velocity.x or velocity.y ~= velocity.y or velocity.z ~= velocity.z then
        sampAddChatMessage("[Warning] ignoring invalid SetVehicleVelocity", 0x00FF00)
        return false
    end
end

function ev.onServerMessage(color, text)
	if text:find("%[Ошибка%] {FFFFFF}Доступно только с мобильного или PC лаунчера!") then
		return false
	end
end

function ev.onSetMapIcon(iconId, position, type, color, style)
    if type > MAX_SAMP_MARKERS then
        return false
    end
end

function samp.onShowDialog(id, style, title, button1, button2, text) -- Скрытие пароля банковской карты
    return {id, text == '{929290}Вы должны подтвердить свой PIN-код к карточке.\nВведите свой код в ниже указаную строку.' and 3 or style, title, button1, button2, text}
end

function samp.onShowDialog(id, style, title, button1, button2, text) -- Скрытие кода складских помещений
    return {id, text == '{ffffff}Чтобы открыть этот склад, введите специальный' and 3 or style, title, button1, button2, text}
end

function setDialogColor(l_up, r_up, l_low, r_bottom) --by stereoliza (https://www.blast.hk/threads/13380/post-621933)
    local CDialog = mem.getuint32(getModuleHandle("samp.dll") + 0x21A0B8)
    local CDXUTDialog = mem.getuint32(CDialog + 0x1C)
    mem.setuint32(CDXUTDialog + 0x12A, l_up, true) -- Левый угол
    mem.setuint32(CDXUTDialog + 0x12E, r_up, true) -- Правый верхний угол
    mem.setuint32(CDXUTDialog + 0x132, l_low, true) -- Нижний левый угол
    mem.setuint32(CDXUTDialog + 0x136, r_bottom, true) -- Правый нижний угол
end

function ClearChat()
    local memory = require "memory"
    mem.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
    mem.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
    mem.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
end

-- Functions Mooving Dialog
function sampGetDialogSize()
    return mem.getint32(CDialog + 0xC, true),
    mem.getint32(CDialog + 0x10, true)
end

function sampGetDialogCaptionHeight()
    return mem.getint32(CDXUTDialog + 0x126, true)
end

function sampGetDialogPos()
    return mem.getint32(CDialog + 0x04, true),
    mem.getint32(CDialog + 0x08, true)
end

function sampSetDialogPos(x, y)
    mem.setint32(CDialog + 0x04, x, true)
    mem.setint32(CDialog + 0x08, y, true)

    mem.setint32(CDXUTDialog + 0x116, x, true)
    mem.setint32(CDXUTDialog + 0x11A, y, true)
end

function patch()
	if mem.getuint8(0x748C2B) == 0xE8 then
		mem.fill(0x748C2B, 0x90, 5, true)
	elseif mem.getuint8(0x748C7B) == 0xE8 then
		mem.fill(0x748C7B, 0x90, 5, true)
	end
	if mem.getuint8(0x5909AA) == 0xBE then
		mem.write(0x5909AB, 1, 1, true)
	end
	if mem.getuint8(0x590A1D) == 0xBE then
		mem.write(0x590A1D, 0xE9, 1, true)
		mem.write(0x590A1E, 0x8D, 4, true)
	end
	if mem.getuint8(0x748C6B) == 0xC6 then
		mem.fill(0x748C6B, 0x90, 7, true)
	elseif mem.getuint8(0x748CBB) == 0xC6 then
		mem.fill(0x748CBB, 0x90, 7, true)
	end
	if mem.getuint8(0x590AF0) == 0xA1 then
		mem.write(0x590AF0, 0xE9, 1, true)
		mem.write(0x590AF1, 0x140, 4, true)
	end
end
patch()

function save()
    ini.main.arizonadialogstyle = statedialog
	ini.main.radarandhudpatching = radarandhudpatch
    inicfg.save(ini, directIni)
end