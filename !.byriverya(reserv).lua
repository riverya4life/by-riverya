script_name("!.byriverya")
script_version("0.8")
script_author('RIVERYA4LIFE.')
require 'lib.moonloader'

-- ïîäêëþ÷àåìûå Libs
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
local radarandhudpatchtag = '{42B166}Ïàò÷ ðàäàðà: {ffffff}'
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

-- äëÿ ñêðûòèÿ îïèñàíèÿ ïåðñà
local active = nil
local pool = {}

local MAX_SAMP_MARKERS = 63

-- Message if the description does not exist:
no_description_text = "* Îïèñàíèå îòñóòñòâóåò *"


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
                print('Ñêà÷èâàþ '..decodeJson(response.text)['url']..' â '..thisScript().path)
                if status == dlstatus.STATUSEX_ENDDOWNLOAD then
                    sampAddChatMessage('Ñêðèïò {42B166}îáíîâëåí{ffffff}, ïåðåçàãðóçêà...', -1)
                    thisScript():reload()
                end
            end)
        else
            sampAddChatMessage('{dc4747}Îøèáêà{ffffff}, íåâîçìîæíî óñòàíîâèòü îáíîâëåíèå! Êîä: '..response.status_code, -1)
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
	sampAddChatMessage('{FFFFFF}Ñáîðêó ñäåëàë {42B166}'..author..' {FFFFFF}| {74adfc}'..vk..' {FFFFFF}I{74adfc} '..tiktok..'', -1)
	sampAddChatMessage('{42B166}[Óþòíåíüêî :)]{ffffff} Ìåíþ ñêðèïòà: {dc4747}/riverya{FFFFFF}. Âåðñèÿ ñêðèïòà {42B166}' ..thisScript().version, -1)
end

function main()
	repeat wait(100) until isSampAvailable()
	--if not isSampLoaded() or not isSampfuncsLoaded() then return end
	--while not isSampAvailable() do wait(100) end
	
	--sampAddChatMessage('{FFFFFF}Ñáîðêó ñäåëàë {42B166}'..author..' {FFFFFF}| {74adfc}'..vk..' {FFFFFF}I{74adfc} '..tiktok..'', -1)
	--sampAddChatMessage('{42B166}[Óþòíåíüêî :)]{ffffff} Ìåíþ ñêðèïòà: {dc4747}/riverya{FFFFFF}. Âåðñèÿ ñêðèïòà {42B166}' ..thisScript().version, -1)
	
	local lastver = update():getLastVersion()
    if thisScript().version ~= lastver then
        sampRegisterChatCommand('riveryaupd', function()
            update():download()
        end)
        sampAddChatMessage('{42B166}[!.by riverya]{ffffff} Âûøëî îáíîâëåíèå ñêðèïòà ({dc4747}'..thisScript().version..'{ffffff} -> {42B166}'..lastver..'{ffffff}), ââåäèòå {dc4747}/riveryaupd{ffffff} äëÿ îáíîâëåíèÿ!', -1)
    end
	
	if statedialog then setDialogColor(0xCC38303c, 0xCC363050, 0xCC75373d, 0xCC583d46) end
	if radarandhudpatch then mem.write(sampGetBase() + 643864, 37008, 2, true) end

	--setDialogColor(0xCC38303c, 0xCC363050, 0xCC75373d, 0xCC583d46) -- dialog color by riverya4life

    _, myid = sampGetPlayerIdByCharHandle(playerPed)
    mynick = sampGetPlayerNickname(myid) -- íàø íèê êð÷
    -- nick = sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)))

    -- äëÿ ñêðûòèÿ îïèñàíèÿ ïåðñà
    local duration = 0.3
    local max_alpha = 255
    local start = os.clock()
    local finish = nil

  	-- Áëîê ïàìÿòè
	
	mem.setint8(0xB7CEE4, 1) -- áåñêîíå÷íûé áåã
	mem.fill(0x58DD1B, 0x90, 2, true) -- çâ¸çäû íà ýêðàíå
	mem.setuint8(0x588550, 0xEB, true) -- disable arrow
	mem.setuint32(0x58A4FE + 0x1, 0x0, true) -- disable green rect
	mem.setuint32(0x586A71 + 0x1, 0x0, true) -- disable height indicator
	mem.setuint8(0x58A5D2 + 0x1, 0x0, true)
	mem.setuint32(0x58A73B + 0x1, 0x0, true) -- çàëóïà êîòîðàÿ áåñèò êð÷ ôèñòàøêè
	mem.write(sampGetBase() + 383732, -1869574000, 4, true) -- áëîê êëàâèøû Ò (ðóñ. Å)
	mem.fill(0x047C8CA, 0x90, 5, true) -- fix cj bug
	mem.setuint8(0x53E94C, 0x0, true) -- RemoveFrameDelay
	mem.fill(0x4217F4, 0x90, 21, true) -- spawn fix
    mem.fill(0x4218D8, 0x90, 17, true)
    mem.fill(0x5F80C0, 0x90, 10, true)
    mem.fill(0x5FBA47, 0x90, 10, true)
	mem.setint8(0x58D3DA, 1, true)
	mem.setfloat(0xCB0725, 0.0, true) -- óäàëåíèå îòðèñîâêè ÷åðíîé ðàìêè âîêðóã êàðòû
	mem.setfloat(0xCB0730, 1.0, true)
	mem.write(0x5752EE, 0xCB0725, 4, true)
	mem.write(0x575313, 0xCB0730, 4, true)
	mem.write(0x57533E, 0xCB0725, 4, true)
	mem.write(0x575363, 0xCB0730, 4, true)
	mem.fill(0x00531155, 0x90, 5, true) -- shift fix by FYP
	mem.write(0x736F88, 0, 4, false) -- âåðòîëåò íå âçðûâàåòñÿ ìíîãî ðàç
    mem.write(0x53E94C, 0, 1, false) -- del fps delay 14 ms
    mem.fill(0x555854, 0x90, 5, false) -- InterioRreflections
    mem.write(0x745BC9, 0x9090, 2, false) -- SADisplayResolutions(1920x1080// 16:9)
    mem.fill(0x460773, 0x90, 7, false) -- CJFix
    mem.write(12761548, 1051965045, 4, false) -- car speed fps fix
    mem.fill(0x5557CF, 0x90, 7, true) -- binthesky_by_DK
	mem.setint32(0x866C94, 0x6430302524, true) -- Ïîçèòèâíûå äåíüãè ñ óäàëåíèåì íóëåé
	mem.setint64(0x866C8C, 0x64303025242D, true) -- Íåãàòèâíûå äåíüãè ñ óäàëåíèåì íóëåé
	mem.write(12697552, 1, 1, false)-- âêëþ÷àåò ñâå÷åíèå øàøêè òàêñè
	mem.write(0x058E280, 0xEB, 1, true) -- fix crosshair
	mem.write(0x5109AC, 235, 1, true) -- nocamrestore
	mem.write(0x5109C5, 235, 1, true)
	mem.write(0x5231A6, 235, 1, true)
	mem.write(0x52322D, 235, 1, true)
	mem.write(0x5233BA, 235, 1, true)
	
	--mem.write(sampGetBase() + 643864, 37008, 2, true) -- Ïàò÷ ðàäàðà ïðè ñëåæêå
	--mem.fill(0x74542B, 0x90, 6, true) -- nop SetCursorPos
	
	--[[mem.fill(0x57E3AE, 0x90, 5, true)-- ïîäñêàçêè
	mem.fill(0x579698, 0x90, 5, true) -- îòêëþ÷àåò íàäïèñü íà ìåíþ ñâåðõó]]--

	--memory.setint32(0x866C94, 0x6438302524, true) -- Ïîçèòèâíûå äåíüãè ñòàíäàðòíîå çíà÷åíèå
	--mem.setint32(0x866C94, 0x6430302524, true) -- Ïîçèòèâíûå äåíüãè ñ óäàëåíèåì íóëåé

	--memory.setint64(0x866C8C, 0x64373025242D, true) -- Íåãàòèâíûå äåíüãè ñòàíäàðòíîå çíà÷åíèå
	--mem.setint64(0x866C8C, 0x64303025242D, true) -- Íåãàòèâíûå äåíüãè ñ óäàëåíèåì íóëåé

	sampHandle = sampGetBase()
	writeMemory(sampHandle + 0x2D3C45, 4, 0, 1) -- ôèêñ çàäåðæêè â 3 ñåê ïðè ïîäêëþ÷åíèè


	for i = 1, #commands do
    	runSampfuncsConsoleCommand(commands[i])
	end

-- Áëîê çàðåãåñòðèðîâàííûõ êîìàíä
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

	sampRegisterChatCommand('pivko', cmd_pivko) -- ïðèêîë
  	sampRegisterChatCommand('givepivo', cmd_givepivo) -- ïðèêîë õ2
  	sampRegisterChatCommand('takebich', cmd_takebich) -- íå êóðèòå â ðåàëå
  	sampRegisterChatCommand('mystonks', cmd_getmystonks)

	sampRegisterChatCommand("fps", function() -- çàðåãàííûå êìä ñ ôóíêöèåé â main
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
        sampAddChatMessage(radarandhudpatch and radarandhudpatchtag..'âêëþ÷åí' or radarandhudpatchtag..'âûêëþ÷åí', -1)
        save()
    
    end)
	
	sampRegisterChatCommand('dialogarz', function()
        statedialog = not statedialog
        if statedialog then
            setDialogColor(0xCC38303c, 0xCC363050, 0xCC75373d, 0xCC583d46) -- dialog color by riverya4life
        else
            setDialogColor(0xCC000000, 0xCC000000, 0xCC000000, 0xCC000000)
        end
        sampAddChatMessage(statedialog and arizonadialogtag..'öâåò âêëþ÷åí' or arizonadialogtag..'öâåò âûêëþ÷åí', -1)
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
        if chatstring == "Server closed the connection." or chatstring == "You are banned from this server." or chatstring == "Ñåðâåð çàêðûë ñîåäèíåíèå." or chatstring == "Âû çàáàíåíû íà ýòîì ñåðâåðå." then
	    sampDisconnectWithReason(false)
            sampAddChatMessage("Wait reconnecting...", 0xa9c4e4)
            wait(15000) -- çàäåðæêà
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
    sampShowDialog(13337,'{dc4747}[Info]','{ffffff}Ïðèâåòñòâóåì, {dc4747}'..mynick..'!{ffffff}\n\n{ffffff}Ñáîðêó ñäåëàë ß, {42B166}'..author..' (Ðèâåðÿ).\n\n{ffffff}ß âîîáùå íå ïëàíèðîâàë å¸ ñëèâàòü èç-çà ñâîåé ëåíè.{ffffff}\nÍó ÷òî íå ñäåëàåøü ðàäè ïðîñìîòðîâ è ëàéêîâ.\nÏîäïèøèñü íà ìîé òèê òîê:\n{dc4747} '..tiktok..'.\n\n\n{dc4747}*{ffffff}Åñëè òû íå ìîé ïîäïèñ÷èê, òî ëó÷øå ïîäïèøèñü, à òî ìíå îáèäíî áóäåò ïëàê ïëàê({dc4747}*{ffffff}\n\n{dc4747}Äîñòóïíûå êîìàíäû:{ffffff}\n {42B166}{ffffff} /riverya - Îñíîâíîå îêíî.\n {42B166}{ffffff} /dialogarz - Äèàëîãè ñ ëàóí÷åðà Arizona RP.\n {42B166}{ffffff} /riveryatop - Òåñò êîìàíäà\n {dc4747}{ffffff} /riveryahelp - Òóò âñ¸ ïîäðîáíî îïèñàíî.','{42B166}Óþòíåíüêî','{dc4747}Ïîí',0)
    lua_thread.create(hui)
end

function riveryahelp()
    sampShowDialog(13339,'{dc4747}[Help]','{ffffff}Ïðèâåò åù¸ ðàç, ÿ òåáå ðàñïèøó âñ¸, ÷òî åñòü â ñêðèïòå, êîòîðûé ÿ ïèñàë äëÿ ñáîðêè.\n{42B166}×òî áûëî äîáàâëåíî:{ffffff}\n\n      Òåïåðü âû íå ñìîæåòå ïåðåéòè â îêîííûé ðåæèì ñ ïîìîùüþ êîìáèíàöèè {dc4747}Alt + Enter{ffffff} âî èçáåæàíèÿ âûëåòà èãðû.\n      Åñëè ñåðâåð ñòîèò ïîä ïàðîëåì, òî áóäåò ôëóäèòü ñòðîêîé {dc4747}"Wrong Server Password"{ffffff} äî òåõ ïîð, ïîêà ñ ñåðâåðà íå ñíèìóò ïàðîëü.\n      Ïðè âõîäå â èãðó â êîíñîëü {dc4747}SampFuncs{ffffff} áóäóò ïðîïèñàíû êîìàíäû {dc4747}clear, threads è chatcmds{ffffff} àâòîìàòè÷åñêè.\n      {dc4747}Çâ¸çäû{ffffff} òåïåðü îòîáðàæàþòñÿ íà ýêðàíå âñåãäà.\n      Òåïåðü ÷òîáû âûâåñòè ñ÷¸ò÷èê {dc4747}FPS{ffffff} äîñòàòî÷íî ïðîïèñàòü â ÷àò êîìàíäó {dc4747}/fps{ffffff} (òåïåðü â êîíñîëü {dc4747}SampFuncs{ffffff} çàõîäèòü íå îáÿçàòåëüíî)\n      Óáðàí íàäîåäëèâûé çåë¸íûé ðàäàð ïðè ïîëåò¸ (îñòàëàñü òîëüêî òåñòóðà â {dc4747}hud.txd{ffffff}, êîòîðàÿ çàìåíÿåòñÿ íà êîòîðóþ õîòèòå)\n      Äîáàâëåíà êîìàíäà {dc4747}/mystonks{ffffff} äëÿ äëÿ ïðîñìîòðà ñâîåãî äîõîäà çà òåêóùóþ ñåññèþ.\n      Äîáàâëåíà êîìàíäà {dc4747}/pivko{ffffff} äëÿ ïîñèäåëîê ñ áðàòàíàìè âå÷åðêîì èëè äëÿ RP ñèòóàöèé, òàê æå åñòü êîìàíäà {dc4747}/givepivo ID{ffffff} ÷òîáû ïåðåäàòü (ó âàñ â ðóêàõ ïîÿâèòüñÿ ïèâêî)\n      Äîáàâëåíà êîìàíäà {dc4747}/takebich{ffffff} ÷òîáû ìîæíî áûëî ïîêóðèòü ñ áðàòêîì íà ðàéîíå (âñåì áóäåò âèäíî)\n      Òåïåðü {dc4747}îïèñàíèå{ffffff} íå áóäåò âèäíî, ïîêà âû íå íàöåëèòåñü íà èãðîêà (ïîä Àðèçîíó êàê íåêèé FPS UP)\n      Òåïåðü êëàâèøà {dc4747}T (ðóñ. Å){ffffff} íå îòêðûâàåò ÷àò (ïî óìîë÷àíèþ òåïåðü êëàâèøà {dc4747}F6{ffffff})\n      Èñïðàâëåí {dc4747}áàã{ffffff} ñ áåãîì Ñèäæåÿ ïîñëå ñìåðòè.\n      Èñïðàâëåíà ïðîáëåìà, êîãäà ïîñëå {dc4747}ñìåðòè{ffffff} ó òåáÿ ïîÿâëÿåòñÿ áóòûëêà ïèâà è ò.ä.\n      {dc4747}Óäàëåíà çàäåðæêà{ffffff} â 14 ìñ ìåæäó êàäðàìè.\n      Óáðàíà {dc4747}çàäåðæêà â 3 ñåêóíäû{ffffff} ïðè ïîäêëþ÷åíèè íà ñåðâåð.\n      Äîáàâëåíà êîìàíäà {dc4747}/dialogarz{ffffff} äëÿ âîçìîæíîñòè âêëþ÷åíèÿ öâåòà äèàëîãîâ êàê íà ëàóí÷åðå Arizona Role Play.\n      Ïðè îòêëþ÷åíèè îò ñåðâåðà Âàñ òåïåðü áóäåò {dc4747}àâòîìàòè÷åñêè ðåêîííåêòèòü{ffffff}.\n      {dc4747}[Arizona]{ffffff} Òåïåðü ïèí-êîä áàíêîâñêîé êàðòû è êîä ñêëàäñêèõ ïîìåùåíèé ñêðûò, êàê ïðè {dc4747}ââîäå ïàðîëÿ{ffffff}.\n      Òåïåðü èç çà î÷åíü áîëüøîé ñêîðîñòè âàñ {dc4747}íå áóäåò êèäàòü â Çàãðóçêó{ffffff}.\n      Ïî êîìàíäå {dc4747}/radarpatch{ffffff} âêëþ÷èòñÿ ïàò÷ ðàäàðà (Áóäåò âåçäå, äàæå ïðè çàõîäå íà ñåðâåð)\n      Òåïåðü ñàìà èãðà çàïóñêàåòñÿ {dc4747}â 3 ðàçà{ffffff} áûñòðåå.\n      Ïðè ââîäå êîìàíä {dc4747}/riveryaloh{ffffff} èëè {dc4747}/riveryalox{ffffff} âàñ æä¸ò ñþðïðèç {dc4747}<3{ffffff}','{42B166}Óþòíåíüêî','',0)
    lua_thread.create(negrtop)
end

function hui()
	while sampIsDialogActive() do
	wait(0)
	local __, button, list, input = sampHasDialogRespond(13337)
	if __ and button == 1 then
        sampAddChatMessage('{42B166}[#riverya4life] {ffffff}Àâòîð ñáîðêè ëåíèâàÿ æîïà.', -1)
	elseif __ and button == 0 then
		sampShowDialog(13338,'{dc4747}[Ðåêëàìà]','{ffffff}Èãðàé ñî ìíîé íà {dc4747}Arizona Role Play Scottdale.{ffffff}\n\nÐåãèñòðèðóéñÿ íà ìîé íèê {42B166}Tape_Riverya{ffffff} è ïîëó÷àé öåëûõ {42B166}300.000${FFFFFF} íà 5 óðîâíå.\nÏî æåëàíèþ íà 6 óðîâíå ââîäè ïðîìîêîä {42B166}#riverya4life{FFFFFF}\nÎò ñèñòåìû ïîëó÷èøü {42B166}100.000${FFFFFF} è îò ìåíÿ åù¸ öåëûé {42B166}ÌÈËËÈÎÍ ÄÎËËÀÐÎÂ!{FFFFFF}\n\n\nÍó à òàê æåëàþ ïðèÿòíîé èãðû {dc4747}<3{FFFFFF}','{42B166}Óþòíåíüêî','',0)
		end
	end
end

function negrtop()
	while sampIsDialogActive() do
	wait(0)
	local __, button, list, input = sampHasDialogRespond(13339)
	if __ and button == 0 then
		sampAddChatMessage('{42B166}[#riverya4life] {ffffff}Óþòíåíüêî îáåä.', -1)
		end
	end
end

function onReceivePacket(id) -- áóäåò ôëóäèòü wrong server password äî òåõ ïîð, ïîêà ñåðâåð íå îòêðîåòñÿ
	if id == 37 then
		sampSetGamestate(1)
	end
end

function ev.onSendPlayerSync(data) -- áàííè õîï
	if data.keysData == 40 or data.keysData == 42 then sendOnfootSync(); data.keysData = 32 end
end

function sendOnfootSync()
	local _, myId = sampGetPlayerIdByCharHandle(PLAYER_PED)
	local data = allocateMemory(68)
	sampStorePlayerOnfootData(myId, data)
	setStructElement(data, 4, 1, 0, false)
	sampSendOnfootData(data)
	freeMemory(data)
end -- òóò êîíåö óæå

function onWindowMessage(msg, wparam, lparam) -- áëîêèðîâêà êëàâèø alt + tab 
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
	
	sampAddChatMessage('{dc4747}[#riverya4life]{ffffff} Çà ñåññèþ Âû çàðàáîòàëè '..'{5EEE0C}'.. result ..'${FF0000}', -1)
end

function cmd_givepivo(arg1)
	local targetnick = sampGetPlayerNickname(arg1)
	lua_thread.create(function()
		sampSendChat('/me äîñòàë èç ñóìêè ïèâî.')
		wait(500)
		runSampfuncsConsoleCommand('0afd:22')
		wait(1500)
		sampSendChat('/me ïåðåäàë ïèâî '..targetnick)
		wait(1500)
		sampSendChat('Óãîùÿéñÿ áðî!')
	end)
end

function cmd_pivko()
	lua_thread.create(function()
		sampSendChat('/me äîñòàë èç ñóìêè ïèâî, îòêðûë áóòûëêó, íà÷àë ïèòü.')
		wait(500)
		runSampfuncsConsoleCommand('0afd:22')
	end)
end

function cmd_takebich()
	lua_thread.create(function()
		sampSendChat("/me äîñòàë ñ êàðìàíà ïà÷êó ñèãàðåò, çàêóðèë.")
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
	if text:find("%[Îøèáêà%] {FFFFFF}Äîñòóïíî òîëüêî ñ ìîáèëüíîãî èëè PC ëàóí÷åðà!") then
		return false
	end
end

function ev.onSetMapIcon(iconId, position, type, color, style)
    if type > MAX_SAMP_MARKERS then
        return false
    end
end

function samp.onShowDialog(id, style, title, button1, button2, text) -- Ñêðûòèå ïàðîëÿ áàíêîâñêîé êàðòû
    return {id, text == '{929290}Âû äîëæíû ïîäòâåðäèòü ñâîé PIN-êîä ê êàðòî÷êå.\nÂâåäèòå ñâîé êîä â íèæå óêàçàíóþ ñòðîêó.' and 3 or style, title, button1, button2, text}
end

function samp.onShowDialog(id, style, title, button1, button2, text) -- Ñêðûòèå êîäà ñêëàäñêèõ ïîìåùåíèé
    return {id, text == '{ffffff}×òîáû îòêðûòü ýòîò ñêëàä, ââåäèòå ñïåöèàëüíûé' and 3 or style, title, button1, button2, text}
end

function setDialogColor(l_up, r_up, l_low, r_bottom) --by stereoliza (https://www.blast.hk/threads/13380/post-621933)
    local CDialog = mem.getuint32(getModuleHandle("samp.dll") + 0x21A0B8)
    local CDXUTDialog = mem.getuint32(CDialog + 0x1C)
    mem.setuint32(CDXUTDialog + 0x12A, l_up, true) -- Ëåâûé óãîë
    mem.setuint32(CDXUTDialog + 0x12E, r_up, true) -- Ïðàâûé âåðõíèé óãîë
    mem.setuint32(CDXUTDialog + 0x132, l_low, true) -- Íèæíèé ëåâûé óãîë
    mem.setuint32(CDXUTDialog + 0x136, r_bottom, true) -- Ïðàâûé íèæíèé óãîë
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
