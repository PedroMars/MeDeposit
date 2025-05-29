-- PriestInPeril.lua
local API = require("api")
local QUEST = require("recurso.quest")

local PriestInPeril = {} -- Garante que a tabela PriestInPeril é criada no início.
local API = require("api") --

local API = require("api")

local function encodeJSON(val, level)
    level = level or 0
    local indent = string.rep("  ", level)
    local nextIndent = string.rep("  ", level + 1)

    if val == nil then return "null"
    elseif type(val) == "number" then return tostring(val)
    elseif type(val) == "string" then
        local escaped = val:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\t", "\\t")
        return '"' .. escaped .. '"'
    elseif type(val) == "boolean" then return val and "true" or "false"
    elseif type(val) == "table" then
        local isArray = true
        local count = 0
        for k, _ in pairs(val) do
            count = count + 1
            if type(k) ~= "number" or k ~= math.floor(k) or k < 1 or k > count then
                isArray = false
                break
            end
        end

        if isArray then
            if #val == 0 then return "[]" end
            local items = {}
            for i, v in ipairs(val) do
                items[i] = nextIndent .. encodeJSON(v, level + 1)
            end
            return "[\n" .. table.concat(items, ",\n") .. "\n" .. indent .. "]"
        else
            local items = {}
            for k, v in pairs(val) do
                if type(k) == "string" and v ~= nil and not tostring(v):find("sol::") then
                    items[#items+1] = nextIndent .. '"' .. k .. '": ' .. encodeJSON(v, level + 1)
                end
            end
            if #items == 0 then return "{}" end
            return "{\n" .. table.concat(items, ",\n") .. "\n" .. indent .. "}"
        end
    else
        return '"' .. tostring(val) .. '"'
    end
end

local function extractProperties(interface)
    local props = {}
    local propNames = {
        "OP", "box_x", "box_y", "fullIDpath", "fullpath", "hov",
        "id1", "id2", "id3", "index", "itemid1", "itemid1_size",
        "itemid2", "memloc", "memloctop", "notvisible",
        "scroll_y", "textids", "textitem", "x", "xs", "y", "ys"
    }

    for _, name in ipairs(propNames) do
        local success, value = pcall(function() return interface[name] end)
        if success then props[name] = value end
    end

    return props
end


local scannedPaths = {}
local allInterfaces = {}

local function pathToKey(path)
    local parts = {}
    for i, segment in ipairs(path) do
        table.insert(parts, segment[1] .. "," .. segment[2])
    end
    return table.concat(parts, ";")
end

local function scanInterfaces(path, depth, maxDepth, seenMemlocs)
    path = path or { { 1672, 0, -1, 0 } }
    depth = depth or 0
    maxDepth = maxDepth or 10
    seenMemlocs = seenMemlocs or {}

    local pathKey = pathToKey(path)
    if scannedPaths[pathKey] then return end
    scannedPaths[pathKey] = true

    print(string.rep("=", 40))
    print("Scanning path at depth " .. depth .. ":")
    for i, pathItem in ipairs(path) do
        print("  Path segment " .. i .. ": {" .. table.concat(pathItem, ", ") .. "}")
    end

    local success, interfaces_scanned = pcall(function()
        return API.ScanForInterfaceTest2Get(true, path)
    end)

    if not success then
        print("Error scanning path: " .. tostring(interfaces_scanned))
        return
    end

    print("Found " .. #interfaces_scanned .. " interfaces at this path")

    for i = 1, #interfaces_scanned do
        local interface = interfaces_scanned[i]

        if interface.memloc and seenMemlocs[interface.memloc] then
            print("Skipping duplicate interface at memloc: " .. interface.memloc)
            goto continue
        end

        if interface.memloc then seenMemlocs[interface.memloc] = true end

        local pathStr = ""
        for j, segment in ipairs(path) do
            pathStr = pathStr .. "[" .. segment[2] .. "]"
        end
        if interface.id2 then pathStr = pathStr .. "[" .. interface.id2 .. "]" end

        local extractedInterface = extractProperties(interface)

        table.insert(allInterfaces, {
            pathString = pathStr,
            depth = depth,
            properties = extractedInterface
        })

        print("-----------------")
        print("Interface #" .. i .. " at depth " .. depth)
        print("Path: " .. pathStr)
        print("ID2: " .. tostring(interface.id2))

        if depth < maxDepth and interface.id2 ~= nil then
            local childPath = {}
            for j = 1, #path do
                local pathSegment = {}
                for k, v in ipairs(path[j]) do
                    pathSegment[k] = v
                end
                table.insert(childPath, pathSegment)
            end

            local pathIdentifier = path[1][1]
            table.insert(childPath, { pathIdentifier, interface.id2, -1, 0 })

            scanInterfaces(childPath, depth + 1, maxDepth, seenMemlocs)
        end

        ::continue::
    end

    collectgarbage("collect")
end

-- Nova função para buscar nos resultados
local function searchInterfaces(keyword)
    local foundInterfaces = {}
    local lowerKeyword = string.lower(tostring(keyword))

    for _, iface_data in ipairs(allInterfaces) do
        local props = iface_data.properties
        local match = false
        -- Verifica se a keyword está em qualquer valor de propriedade (string ou número)
        for _, value in pairs(props) do
            if type(value) == "string" and string.lower(value):find(lowerKeyword) then
                match = true
                break
            elseif type(value) == "number" and tostring(value):find(lowerKeyword) then
                match = true
                break
            end
        end
        -- Verifica se a keyword está no pathString
        if not match and string.lower(iface_data.pathString):find(lowerKeyword) then
            match = true
        end

        if match then
            table.insert(foundInterfaces, iface_data)
        end
    end
    return foundInterfaces
end

local function interfaces(options)
    options = options or {}
    local startPath = options.startPath
    local maxDepth = options.maxDepth or 15

    scannedPaths = {}
    allInterfaces = {}

    print("Starting interface scan with max depth: " .. maxDepth)

    local startTime = os.time()

    scanInterfaces(startPath, 0, maxDepth, {})

    local totalInterfaces = #allInterfaces

    print("\nScan completed in " .. (os.time() - startTime) .. " seconds")
    print("Total unique interfaces scanned: " .. totalInterfaces)

    return {
        count = totalInterfaces,
        interfaces = allInterfaces, -- Retorna a tabela completa de interfaces
        search = searchInterfaces -- Adiciona a função de busca
    }
end

local function buscar_palavra(keywordToSearch)
    local result = interfaces({
        startPath = { { 272,4,-1,0 }, { 272,6,-1,0 } },
        maxDepth = 20
    })
    local filteredInterfaces = result.search(keywordToSearch)
    local found = #filteredInterfaces > 0
    return found -- Retorna true se encontrou, false caso contrário
end

local function try_interact_and_find_key(object_id, keyword)
    print("Tentando interagir com o objeto ID: " .. object_id, "info")
    API.DoAction_Object1(0x32, API.OFF_ACT_GeneralObject_route0, { object_id }, 50)
    API.RandomSleep2(8000, 1500, 1000) -- Ajuste os tempos de espera conforme necessário

    if buscar_palavra(keyword) then
        print("Achei a chave ao interagir com o objeto ID: " .. object_id)
        return true
    else
        print("Palavra-chave não encontrada após interagir com o objeto ID: " .. object_id)
        return false
    end
end





------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES DE CADA PASSO DA MISSÃO
------------------------------------------------------------------------------------------------------------------------

-- PARTE 1: A Missing Monk
function PriestInPeril.passo_falarComReiRoaldPrimeiraVez()
    print("Passo: Falando com o Rei Roald pela primeira vez.", "info")
    API.DoAction_Interface(0x2e,0xffffffff,1,1430,233,-1,API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(15000, 5000, 3000)
    QUEST.MoveTo(3217, 3472, 0, 1)
    Interact:Object("Door", "Open", 5)
    API.RandomSleep2(3000, 1000, 2000)
    Interact:NPC("King Roald", "Talk to", 12)
    QUEST.gerenciarDialogo({"Greet the king"})
    if API.DoAction_Interface(0x24,0xffffffff,1,1500,409,-1,API.OFF_ACT_GeneralInterface_route) then
        QUEST.gerenciarDialogo({})
        return true
    else
        return false
    end
end

function PriestInPeril.passo_irParaPaterdomus()
    print("Passo: Indo para Paterdomus.", "info")
    API.DoAction_Tile(WPOINT.new(3216,3472,0))
    QUEST.MoveTo(3392, 3485, 0, 5)
    if QUEST.IsPlayerInArea(3392,3485,0,10) then
        return true
    else
        return false
    end
end

function PriestInPeril.passo_interagirComPortaTemplo()
    print("Passo: Interagindo com a porta do templo.", "info")
    Interact:Object("Large door", "Enter", 15)
    API.RandomSleep2(4000, 2000, 3000)
    if QUEST.gerenciarDialogo({"Knock at the door."}) then
        return true
    else
        return false
    end
end

function PriestInPeril.passo_falarComVozTemplo()
    print("Passo: Falando com a voz do templo.", "info")
    if QUEST.gerenciarDialogo({
        "Roald sent me to check on Drezel.",
        "Yes"
    })then
        return true
    else
        return false
    end
end

function PriestInPeril.passo_descerMausoleuCerberus()
    print("Passo: Descendo para o Mausoléu do Cerberus.", "info")
    if Interact:Object("Mausoleum", "Enter", 30) then
        API.RandomSleep2(7000, 2000, 3000)
        return true
    else
        print("Nao desceu man")
        return false
    end
end

function PriestInPeril.passo_matarCerberus()
    print("Passo: Matando Cerberus.", "info")
    if API.DoAction_NPC(0x2a, API.OFF_ACT_AttackNPC_route, { 15255 }, 13) then
        API.RandomSleep2(15000, 2000, 3000)
        return true
    else
        return false
    end


end

function PriestInPeril.passo_voltarParaPortaTemploDepoisCerberus()
    print("Passo: Voltando para a porta do templo depois de Cerberus.", "info")
    Interact:Object("Ladder", "Climb-up", 5)
    API.RandomSleep2(1500,1000,500)
    print("subi a escada", "info")
    API.DoAction_Tile(WPOINT.new(3404,3485,0))
    print("to andando bro.", "info")
    API.RandomSleep2(15000,1000,500)
    if QUEST.IsPlayerInArea(3402,3485,0,10) then
        return true
    else
        return false
    end
end

function PriestInPeril.passo_falarComVozTemploDepoisCerberus()
    print("Passo: Falando com a voz do templo depois de Cerberus.", "info")
    PriestInPeril.passo_interagirComPortaTemplo()
    if QUEST.gerenciarDialogo({}) then
        return true
    else
        return false
    end

end

function PriestInPeril.passo_voltarParaReiRoald()
    print("Passo: Voltando para o Rei Roald.", "info")
    API.DoAction_Interface(0x2e,0xffffffff,1,1430,233,-1,API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(15000, 5000, 3000)
    API.DoAction_Tile(WPOINT.new(3216,3474,0))
    QUEST.MoveTo(3217, 3472, 0, 2)
    Interact:Object("Door", "Open", 5)
    API.RandomSleep2(3000, 1000, 2000)
    if QUEST.IsPlayerInArea(3218,3472,0,15) then
        return true
    else
        return false
    end
end

function PriestInPeril.passo_falarComReiRoaldSegundaVez()
    print("Passo: Falando com o Rei Roald pela segunda vez.", "info")
    Interact:NPC("King Roald", "Talk to", 12)
    API.RandomSleep2(4000, 2000, 3000)
    if QUEST.gerenciarDialogo({"Talk about Priest in Peril."})then
        return true
    else
        return false
    end
end

-- PARTE 2: The Temple on the Salve
function PriestInPeril.passo_voltarParaTemploPaterdomus()
    print("Passo: Voltando para o templo de Paterdomus e entrando.", "info")
    PriestInPeril.passo_irParaPaterdomus()
    if Interact:Object("Large door", "Enter", 40) then
        API.RandomSleep2(2000, 500, 500)
        return true
    else
        return false
    end

end

function PriestInPeril.passo_subirAndarSuperiorTemplo()
    print("Passo: Subindo para o andar superior do templo.", "info")
        Interact:Object("Staircase", "Climb up", 15)
        API.RandomSleep2(7000, 500, 500)
    if QUEST.DoesObjectExist(1044,7,1) then
        API.DoAction_Tile(WPOINT.new(3406,3485,0))
        API.RandomSleep2(3000, 1000, 500)
        Interact:Object("Staircase", "Climb up", 5)
        API.RandomSleep2(2000, 500, 500)
    end
    return true
end

function PriestInPeril.passo_falarComDrezelPreso()
    print("Passo: Falando com o Drezel preso.", "info")
    Interact:Object("Cell door", "Interact", 6)
    API.RandomSleep2(2000, 500, 500)
    Interact:Object("Drezel", "Talk-to", 6)
    API.RandomSleep2(2000, 500, 500)
    --- MODIFICAÇÃO: Consolidado para uma única chamada gerenciarDialogo com todas as opções.
    QUEST.gerenciarDialogo({
        "Tell me anyway.",
        "Yes."
    })
end

function PriestInPeril.passo_descerAndarInferiorTemplo()
    print("Passo: Descendo para o andar inferior do templo.", "info")
    if Interact:Object("Staircase", "Climb down", 6) then
        API.RandomSleep2(4000, 2000, 3000)
        return true
    else
        return false
    end

end

function PriestInPeril.passo_matarMongeZamorakEMegastarChave()
    print("Passo: Matando monge de Zamorak e pegando a golden key.", "info")
    API.DoAction_NPC(0x2a, API.OFF_ACT_AttackNPC_route, { 1044 }, 20)
    API.RandomSleep2(40000, 2000, 3000)
    API.DoAction_G_Items1(0x2d,{ 2944 },20)
    API.RandomSleep2(1000, 2000, 3000)
    if  API.DoAction_LootAll_Button() then
        return true
   else
        return false
    end
    end


function PriestInPeril.passo_irParaMausoleuTrocarChave()
    print("Passo: Indo para o Mausoléu para trocar a chave.", "info")
    API.DoAction_Tile(WPOINT.new(3415,3489,0))
    API.RandomSleep2(2000, 500, 500)
    if Interact:Object("Staircase", "Climb down", 4)then
        API.RandomSleep2(3000, 500, 500)
        if Interact:Object("Large door", "Enter", 15) then
            API.RandomSleep2(8000, 500, 500)
            if Interact:Object("Mausoleum", "Enter", 30)then
                API.RandomSleep2(20000, 500, 500)

            end
        end
    end
    if Interact:Object("Gate", "Open", 13) then
        API.RandomSleep2(5000, 500, 500)
        return true
    else
        return false
    end
end

function PriestInPeril.passo_encontrarEtrocarChaves()
    print("Passo: Encontrando e trocando as chaves no Mausoléu.", "info")


    local function trocarchave(object_id)
        Inventory:DoAction(2944,0,API.OFF_ACT_Bladed_interface_route)
        API.RandomSleep2(3000, 1500, 2000)
        API.DoAction_Object1(0x24,API.OFF_ACT_GeneralObject_route00,{ object_id },10)

    end

    -- Lista de IDs dos objetos a serem tentados
    local object_ids_to_check = { 3496, 3498, 3495, 3497, 3494, 3499, 3493 }
    local keyword = "the<br>key" -- A palavra-chave a ser buscada

    for _, object_id in ipairs(object_ids_to_check) do
        if try_interact_and_find_key(object_id, keyword) then
            -- Se a palavra-chave foi encontrada, troque a chave e termine a função
            trocarchave(object_id)
            return true -- Retorna true indicando que a chave foi encontrada e trocada
        end
    end

    -- Se o loop terminar e a chave não tiver sido encontrada, significa que todas as tentativas falharam
    print("A chave não foi encontrada após tentar todos os objetos.", "warn")
    return false -- Retorna false indicando que a chave não foi encontrada
end



    function PriestInPeril.passo_encherBaldeAguaMurky()
    print("Passo: Enchendo o balde com água murky.", "info")
    Inventory:DoAction(1925,0,API.OFF_ACT_Bladed_interface_route)
    API.RandomSleep2(1000, 1500, 1000)
    API.DoAction_Object2(0x24,API.OFF_ACT_GeneralObject_route00,{ 3485 },12,WPOINT.new(6686,4305,0));
        if Inventory:Contains("Bucket of murky water")then
            return true
        else
            return false
        end
    end

    -- PARTE 3: Saradomin's Blessing
    function PriestInPeril.passo_voltarParaDrezelComChave()
        print("Passo: Voltando para Drezel com a chave.", "info")
        Interact:Object("Ladder", "Climb-up", 50)
        API.RandomSleep2(10000, 500, 500)
        Interact:Object("Gate", "Open", 15)
        API.RandomSleep2(12000, 500, 500)
        Interact:Object("Ladder", "Climb-up", 13)
        API.RandomSleep2(10000, 500, 500)
        Interact:Object("Large door", "Enter", 50)
        API.RandomSleep2(20000, 500, 500)
        if PriestInPeril.passo_subirAndarSuperiorTemplo() then

            return true
        else
            return false
        end
        end

    function PriestInPeril.passo_abrirCelaDrezelEFalar()
    print("Passo: Abrindo a cela de Drezel e falando com ele.", "info")
        Interact:Object("Cell door", "Interact", 6)
        API.RandomSleep2(2000, 500, 500)
        Interact:Object("Drezel", "Talk-to", 6)
        API.RandomSleep2(2000, 500, 500)
        QUEST.gerenciarDialogo({})
    return false
    end

    function PriestInPeril.passo_abencoarAgua()
    --Drezel
    print("Passo: Abençoando a água.", "info")
    API.DoAction_Object2(0x29,API.OFF_ACT_GeneralObject_route0,{ 3463 },12,WPOINT.new(3412,3484,0));
    API.RandomSleep2(1000, 1500, 1000)
    Interact:NPC("Drezel", "Talk-to", 12)
    
    QUEST.gerenciarDialogo({})
    return true
    end

    function PriestInPeril.passo_usarAguaNoCaixao()
    print("Passo: Usando a água abençoada no caixão.", "info")
    Inventory:DoAction(2954,0,API.OFF_ACT_Bladed_interface_route)
    API.DoAction_Object2(0x24,API.OFF_ACT_GeneralObject_route00,{ 30728 },12,WPOINT.new(3410,3485,0));
    return true
    end

    function PriestInPeril.passo_falarComDrezelDepoisCaixao()
    print("Passo: Falando com Drezel depois de selar o caixão.", "info")
    API.DoAction_Object2(0x29,API.OFF_ACT_GeneralObject_route0,{ 3463 },12,WPOINT.new(3412,3484,0));
    API.RandomSleep2(1000, 1500, 1000)
    Interact:NPC("Drezel", "Talk-to", 12)
    
    QUEST.gerenciarDialogo({})
    return true
    end

    function PriestInPeril.passo_irParaSalaMonumentosFalarDrezel()
    print("Passo: Indo para a sala dos monumentos e falando com Drezel.", "info")
    API.DoAction_Object2(0x35,API.OFF_ACT_GeneralObject_route0,{ 102048 },50,WPOINT.new(3407,3483,0))
        API.RandomSleep2(5000, 500, 500)

    PriestInPeril.passo_irParaMausoleuTrocarChave() -- Reutilizando a função
    Interact:NPC("Drezel", "Talk-to", 12)
        API.RandomSleep2(15000, 500, 500)
    
    QUEST.gerenciarDialogo({})
    return true
    end

    function PriestInPeril.passo_darEssenciaParaDrezel()
    print("Passo: Dando as essências para Drezel.", "info")
    Interact:NPC("Drezel", "Talk-to", 12)
        API.RandomSleep2(5000, 500, 500)
    QUEST.gerenciarDialogo({})
    API.DoAction_Interface(0xffffffff,0xffffffff,1,1244,21,-1,API.OFF_ACT_GeneralInterface_route)
    return true
    end

    ------------------------------------------------------------------------------------------------------------------------
    -- MAPEAMENTO DOS PASSOS DA MISSÃO E ORDEM
    ------------------------------------------------------------------------------------------------------------------------

    -- Mapeamento das funções dos passos da missão
    PriestInPeril.missionSteps = {
    ["Talk-to to King Roald (1)"] = PriestInPeril.passo_falarComReiRoaldPrimeiraVez,
    ["Go to Paterdomus"] = PriestInPeril.passo_irParaPaterdomus,
    ["Interact with Temple Door"] = PriestInPeril.passo_interagirComPortaTemplo,
    ["Talk-to to Temple Voice (1)"] = PriestInPeril.passo_falarComVozTemplo,
    ["Descend to Cerberus Mausoleum"] = PriestInPeril.passo_descerMausoleuCerberus,
    ["Kill Cerberus"] = PriestInPeril.passo_matarCerberus,
    ["Return to Temple Door (after Cerberus)"] = PriestInPeril.passo_voltarParaPortaTemploDepoisCerberus,
    ["Talk-to to Temple Voice (after Cerberus)"] = PriestInPeril.passo_falarComVozTemploDepoisCerberus,
    ["Return to King Roald"] = PriestInPeril.passo_voltarParaReiRoald,
    ["Talk-to to King Roald (2)"] = PriestInPeril.passo_falarComReiRoaldSegundaVez,
    ["Return to Paterdomus Temple"] = PriestInPeril.passo_voltarParaTemploPaterdomus,
    ["Go up Temple Upper Floor"] = PriestInPeril.passo_subirAndarSuperiorTemplo,
    ["Talk-to to Imprisoned Drezel"] = PriestInPeril.passo_falarComDrezelPreso,
    ["Go down Temple Lower Floor"] = PriestInPeril.passo_descerAndarInferiorTemplo,
    ["Kill Zamorak Monk and Get Key"] = PriestInPeril.passo_matarMongeZamorakEMegastarChave,
    ["Go to Mausoleum to Exchange Key"] = PriestInPeril.passo_irParaMausoleuTrocarChave,
    ["Find and Exchange Keys"] = PriestInPeril.passo_encontrarEtrocarChaves,
    ["Fill Bucket with Murky Water"] = PriestInPeril.passo_encherBaldeAguaMurky,
    ["Return to Drezel with Key"] = PriestInPeril.passo_voltarParaDrezelComChave,
    ["Open Drezel's Cell and Talk-to"] = PriestInPeril.passo_abrirCelaDrezelEFalar,
    ["Bless Water"] = PriestInPeril.passo_abencoarAgua,
    ["Use Water on Coffin"] = PriestInPeril.passo_usarAguaNoCaixao,
    ["Talk-to to Drezel After Coffin"] = PriestInPeril.passo_falarComDrezelDepoisCaixao,
    ["Go to Monument Room and Talk-to to Drezel"] = PriestInPeril.passo_irParaSalaMonumentosFalarDrezel,
    ["Give Essence to Drezel"] = PriestInPeril.passo_darEssenciaParaDrezel,
    }

    -- Definindo a ordem explícita dos passos da missão
    PriestInPeril.stepOrder = {
    "Talk-to to King Roald (1)",
    "Go to Paterdomus",
    "Interact with Temple Door",
    "Talk-to to Temple Voice (1)",
    "Descend to Cerberus Mausoleum",
    "Kill Cerberus",
    "Return to Temple Door (after Cerberus)",
    "Talk-to to Temple Voice (after Cerberus)",
    "Return to King Roald",
    "Talk-to to King Roald (2)",
    "Return to Paterdomus Temple",
    "Go up Temple Upper Floor",
    "Talk-to to Imprisoned Drezel",
    "Go down Temple Lower Floor",
    "Kill Zamorak Monk and Get Key",
    "Go to Mausoleum to Exchange Key",
    "Find and Exchange Keys",
    "Fill Bucket with Murky Water",
    "Return to Drezel with Key",
    "Open Drezel's Cell and Talk-to",
    "Bless Water",
    "Use Water on Coffin",
    "Talk-to to Drezel After Coffin",
    "Go to Monument Room and Talk-to to Drezel",
    "Give Essence to Drezel",
    }

    ------------------------------------------------------------------------------------------------------------------------
    -- FUNÇÃO PRINCIPAL PARA INICIAR A MISSÃO A PARTIR DE UM PASSO ESPECÍFICO
    ------------------------------------------------------------------------------------------------------------------------

    function PriestInPeril.StartMission(startStepName, sortedStepKeys)
    print("Starting 'Priest in Peril' mission from step: " .. (startStepName or "Not specified"), "info")

    local startExecuting = false
    -- Percorre todos os passos na ordem fornecida pela UI
    for _, stepName in ipairs(sortedStepKeys) do
    if stepName == startStepName then
    startExecuting = true
    end

    if startExecuting then
    local success = PriestInPeril.missionSteps[stepName]()
    if not success then
    print("Step '" .. stepName .. "' failed. Stopping mission.", "error")
    API.Write_LoopyLoop(false) -- Parar o script se um passo falhar
    return false
    end
    API.Sleep_tick(5) -- Pequena pausa entre os passos
    end
    end

    print("'Priest in Peril' mission completed successfully!", "info")
    API.Write_LoopyLoop(false) -- Parar o script após a conclusão
    return true
    end

    return PriestInPeril