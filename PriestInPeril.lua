-- PriestInPeril.lua
local API = require("api")
local QUEST = require("recurso.quest")

local PriestInPeril = {} -- Garante que a tabela PriestInPeril é criada no início.

------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES DE UTILIDADE
------------------------------------------------------------------------------------------------------------------------

-- Função para pular diálogos
local function pulardialogos()
    local tentativas_atuais = 0
    while API.Read_LoopyLoop() and QUEST.DialogBoxOpen() and tentativas_atuais < 15 do
        API.logDebug("Diálogo ainda aberto. Pressionando espaço para aceitar/avançar... (Tentativa " .. (tentativas_atuais + 1) .. ")")
        QUEST.PressSpace()
        API.Sleep_tick(1) -- Pequena pausa entre cada pressão de espaço
        tentativas_atuais = tentativas_atuais + 1
    end
end

--- Interage com um objeto após verificar sua existência.
--- @param objId number O ID do objeto.
--- @param actionCode number O código da ação (ex: 0x31, 0x34).
--- @param routeAction number O OFF_ACT_GeneralObject_route (ex: API.OFF_ACT_GeneralObject_route0).
--- @param maxDistance number A distância máxima para encontrar o objeto.
--- @param targetWPoint WPOINT O WPOINT do objeto para a interação.
--- @param sleepAfter number O tempo de espera em milissegundos após a interação (padrão 1000).
--- @param randomSleep1 number O primeiro valor de random sleep (padrão 1500).
--- @param randomSleep2 number O segundo valor de random sleep (padrão 1000).
--- @return boolean true se a interação foi bem-sucedida ou se o objeto não foi encontrado mas o script continua, false se algo falhou gravemente.
function QUEST.interagirComObjeto(objId, actionCode, routeAction, maxDistance, targetWPoint, sleepAfter, randomSleep1, randomSleep2)
    sleepAfter = sleepAfter or 1000
    randomSleep1 = randomSleep1 or 1500
    randomSleep2 = randomSleep2 or 1000

    API.Log("Verificando e interagindo com objeto: " .. objId .. " em " .. targetWPoint.x .. "," .. targetWPoint.y .. "," .. targetWPoint.z, "debug")

    if QUEST.DoesObjectExist(objId, maxDistance, 0) then -- 0 é o ObjType para objetos gerais
        API.DoAction_Object2(actionCode, routeAction, {objId}, maxDistance, targetWPoint)
        API.RandomSleep2(sleepAfter, randomSleep1, randomSleep2)
        return true
    else
        API.logWarn("Objeto " .. objId .. " não encontrado. Continuando...")
        return false -- Retorna falso para indicar que o objeto não foi encontrado, mas o script pode continuar
    end
end

--- Interage com um NPC após verificar sua existência.
--- @param npcId number O ID do NPC.
--- @param actionCode number O código da ação (ex: 0x2c para interagir, 0x2a para atacar).
--- @param routeAction number O OFF_ACT_InteractNPC_route (ex: API.OFF_ACT_InteractNPC_route, API.OFF_ACT_AttackNPC_route).
--- @param maxDistance number A distância máxima para encontrar o NPC.
--- @param sleepAfter number O tempo de espera em milissegundos após a interação (padrão 1000).
--- @param randomSleep1 number O primeiro valor de random sleep (padrão 1500).
--- @param randomSleep2 number O segundo valor de random sleep (padrão 1000).
--- @return boolean true se a interação foi bem-sucedida ou se o NPC não foi encontrado mas o script continua, false se algo falhou gravemente.
function QUEST.interagirComNPC(npcId, actionCode, routeAction, maxDistance, sleepAfter, randomSleep1, randomSleep2)
    sleepAfter = sleepAfter or 1000
    randomSleep1 = randomSleep1 or 1500
    randomSleep2 = randomSleep2 or 1000

    API.Log("Verificando e interagindo com NPC: " .. npcId, "debug")

    if QUEST.DoesObjectExist(npcId, maxDistance, 1) then -- 1 é o ObjType para NPCs
        API.DoAction_NPC(actionCode, routeAction, {npcId}, maxDistance)
        API.RandomSleep2(sleepAfter, randomSleep1, randomSleep2)
        return true
    else
        API.logWarn("NPC " .. npcId .. " não encontrado. Continuando...")
        return false
    end
end


------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES DE CADA PASSO DA MISSÃO
------------------------------------------------------------------------------------------------------------------------

-- PARTE 1: A Missing Monk
function PriestInPeril.passo_falarComReiRoaldPrimeiraVez()
    API.Log("Passo: Falando com o Rei Roald pela primeira vez.", "info")
    Inventory:DoAction(8007,1,API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(7000, 2000, 3000)
    QUEST.MoveTo(3217, 3472, 0, 2)
    QUEST.interagirComObjeto(15536, 0x31, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(3218,3472,0))
    API.WaitUntilMovingEnds(15, 20)
    QUEST.interagirComNPC(648, 0x2c, API.OFF_ACT_InteractNPC_route, 50, 4000, 2000, 3000)
    QUEST.OptionSelector({"Greet the king"})
    pulardialogos()
    API.DoAction_Interface(0x24,0xffffffff,1,1500,409,-1,API.OFF_ACT_GeneralInterface_route)
    pulardialogos()
    return true
end

function PriestInPeril.passo_irParaPaterdomus()
    API.Log("Passo: Indo para Paterdomus.", "info")
    QUEST.MoveTo(3258, 3440, 0, 5)
    QUEST.MoveTo(3273, 3428, 0, 5)
    QUEST.MoveTo(3319, 3430, 0, 5)
    QUEST.MoveTo(3362, 3442, 0, 5)
    QUEST.MoveTo(3392, 3485, 0, 5)
    return true
end

function PriestInPeril.passo_interagirComPortaTemplo()
    API.Log("Passo: Interagindo com a porta do templo.", "info")
    QUEST.interagirComObjeto(30707, 0x39, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(3404,3486,0), 4000, 2000, 3000)
    QUEST.OptionSelector({"Knock at the door."})
    return true
end

function PriestInPeril.passo_falarComVozTemplo()
    API.Log("Passo: Falando com a voz do templo.", "info")
    pulardialogos()
    QUEST.OptionSelector({"Roald sent me to check on Drezel."})
    pulardialogos()
    QUEST.OptionSelector({"Yes"})
    pulardialogos()
    return true
end

function PriestInPeril.passo_descerMausoleuCerberus()
    API.Log("Passo: Descendo para o Mausoléu do Cerberus.", "info")
    QUEST.MoveTo(3406, 3505, 0, 5)
    QUEST.interagirComObjeto(30571, 0x39, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(3405,3505,0))
    return true
end

function PriestInPeril.passo_matarCerberus()
    API.Log("Passo: Matando Cerberus.", "info")
    QUEST.interagirComNPC(15255, 0x2a, API.OFF_ACT_AttackNPC_route, 50, 4000, 2000, 3000)
    return true
end

function PriestInPeril.passo_voltarParaPortaTemploDepoisCerberus()
    API.Log("Passo: Voltando para a porta do templo depois de Cerberus.", "info")
    QUEST.interagirComObjeto(30575, 0x34, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(7821,3171,0))
    QUEST.MoveTo(3402, 3485, 0, 5)
    return true
end

function PriestInPeril.passo_falarComVozTemploDepoisCerberus()
    API.Log("Passo: Falando com a voz do templo depois de Cerberus.", "info")
    PriestInPeril.passo_interagirComPortaTemplo()
    pulardialogos()
    return true
end

function PriestInPeril.passo_voltarParaReiRoald()
    API.Log("Passo: Voltando para o Rei Roald.", "info")
    Inventory:DoAction(8007,1,API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(7000, 2000, 3000)
    QUEST.MoveTo(3217, 3472, 0, 2)
    QUEST.interagirComObjeto(15536, 0x31, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(3218,3472,0))
    API.WaitUntilMovingEnds(15, 20)
    pulardialogos() -- Adicionado para garantir que diálogos após o movimento sejam tratados
    return true
end

function PriestInPeril.passo_falarComReiRoaldSegundaVez()
    API.Log("Passo: Falando com o Rei Roald pela segunda vez.", "info")
    QUEST.interagirComNPC(648, 0x2c, API.OFF_ACT_InteractNPC_route, 50, 4000, 2000, 3000)
    QUEST.OptionSelector({"Talk about Priest in Peril."})
    pulardialogos()
    return true
end

-- PARTE 2: The Temple on the Salve
function PriestInPeril.passo_voltarParaTemploPaterdomus()
    API.Log("Passo: Voltando para o templo de Paterdomus e entrando.", "info")
    PriestInPeril.passo_irParaPaterdomus()
    QUEST.interagirComObjeto(30707, 0x39, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(3404,3486,0), 2000, 1000, 500)
    return true
end

function PriestInPeril.passo_subirAndarSuperiorTemplo()
    API.Log("Passo: Subindo para o andar superior do templo.", "info")
    API.RandomSleep2(4000, 2000, 3000) -- Manter esse sleep inicial se for uma animação
    QUEST.interagirComObjeto(102043, 0x34, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(3414,3490,0), 4000, 2000, 3000)
    QUEST.interagirComObjeto(102045, 0x34, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(3406,3482,0), 4000, 2000, 3000)
    return true
end

function PriestInPeril.passo_falarComDrezelPreso()
    API.Log("Passo: Falando com o Drezel preso.", "info")
    QUEST.interagirComObjeto(3463, 0x29, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(3412,3484,0), 1000, 1500, 1000)
    pulardialogos()
    QUEST.OptionSelector({"Tell me anyway."})
    pulardialogos()
    QUEST.OptionSelector({"Yes."})
    pulardialogos()
    return true
end

function PriestInPeril.passo_descerAndarInferiorTemplo()
    API.Log("Passo: Descendo para o andar inferior do templo.", "info")
    QUEST.interagirComObjeto(102048, 0x35, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(3407,3483,0), 4000, 2000, 3000)
    return true
end

function PriestInPeril.passo_matarMongeZamorakEMegastarChave()
    API.Log("Passo: Matando monge de Zamorak e pegando a golden key.", "info")
    QUEST.interagirComNPC(1044, 0x2a, API.OFF_ACT_AttackNPC_route, 50, 4000, 2000, 3000)
    API.DoAction_G_Items1(0x2d,{ 2944 },50); -- Essa ação é de item no chão, mantida como está
    API.RandomSleep2(3000, 1500, 2000)
    API.DoAction_Interface(0x24,0xffffffff,1,1622,22,-1,API.OFF_ACT_GeneralInterface_route)
    return true
end

function PriestInPeril.passo_irParaMausoleuTrocarChave()
    API.Log("Passo: Indo para o Mausoléu para trocar a chave.", "info")
    QUEST.interagirComObjeto(102047, 0x35, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(3414,3480,0), 4000, 3000, 2000)
    QUEST.interagirComObjeto(30707, 0x39, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(3404,3486,0), 4000, 3000, 2000)
    QUEST.MoveTo(3405, 3503, 0, 5)
    QUEST.interagirComObjeto(30571, 0x39, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(3405,3505,0), 4000, 3000, 2000)
    QUEST.interagirComObjeto(3444, 0x31, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(6669,4311,0), 5000, 3000, 2000)
    return true
end

function PriestInPeril.passo_encontrarEtrocarChaves()
    API.Log("Passo: Encontrando e trocando as chaves no Mausoléu.", "info")


    QUEST.interagirComObjeto(3496, 0x32, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(6687,4300,0), 3000, 1500, 2000)
    Inventory:DoAction(2944,0,API.OFF_ACT_Bladed_interface_route)
    API.RandomSleep2(3000, 1500, 2000)
    QUEST.interagirComObjeto(3496, 0x24, API.OFF_ACT_GeneralObject_route00, 50, WPOINT.new(6691,4301,0))

    QUEST.interagirComObjeto(3493, 0x32, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(6681,4306,0), 3000, 1500, 2000)
    Inventory:DoAction(2944,0,API.OFF_ACT_Bladed_interface_route)
    API.RandomSleep2(3000, 1500, 2000)
    QUEST.interagirComObjeto(3493, 0x24, API.OFF_ACT_GeneralObject_route00, 50, WPOINT.new(6691,4301,0))

    QUEST.interagirComObjeto(3499, 0x32, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(6682,4310,0), 3000, 1500, 2000)
    Inventory:DoAction(2944,0,API.OFF_ACT_Bladed_interface_route)
    API.RandomSleep2(3000, 1500, 2000)
    QUEST.interagirComObjeto(3499, 0x24, API.OFF_ACT_GeneralObject_route00, 50, WPOINT.new(6691,4301,0))

    QUEST.interagirComObjeto(3494, 0x32, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(6687,4311,0), 3000, 1500, 2000)
    Inventory:DoAction(2944,0,API.OFF_ACT_Bladed_interface_route)
    API.RandomSleep2(3000, 1500, 2000)
    QUEST.interagirComObjeto(3494, 0x24, API.OFF_ACT_GeneralObject_route00, 50, WPOINT.new(6691,4301,0))

    QUEST.interagirComObjeto(3497, 0x32, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(6691,4310,0), 3000, 1500, 2000)
    Inventory:DoAction(2944,0,API.OFF_ACT_Bladed_interface_route)
    API.RandomSleep2(3000, 1500, 2000)
    QUEST.interagirComObjeto(3497, 0x24, API.OFF_ACT_GeneralObject_route00, 50, WPOINT.new(6691,4301,0))

    QUEST.interagirComObjeto(3495, 0x32, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(6692,4306,0), 3000, 1500, 2000)
    Inventory:DoAction(2944,0,API.OFF_ACT_Bladed_interface_route)
    API.RandomSleep2(3000, 1500, 2000)
    QUEST.interagirComObjeto(3495, 0x24, API.OFF_ACT_GeneralObject_route00, 50, WPOINT.new(6691,4301,0))

    QUEST.interagirComObjeto(3498, 0x32, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(6691,4301,0), 3000, 1500, 2000)
    Inventory:DoAction(2944,0,API.OFF_ACT_Bladed_interface_route)
    API.RandomSleep2(3000, 1500, 2000)
    QUEST.interagirComObjeto(3498, 0x24, API.OFF_ACT_GeneralObject_route00, 50, WPOINT.new(6691,4301,0))
    return true
end

function PriestInPeril.passo_encherBaldeAguaMurky()
    API.Log("Passo: Enchendo o balde com água murky.", "info")
    Inventory:DoAction(1925,0,API.OFF_ACT_Bladed_interface_route)
    API.RandomSleep2(1000, 1500, 1000)
    QUEST.interagirComObjeto(3485, 0x24, API.OFF_ACT_GeneralObject_route00, 50, WPOINT.new(6686,4305,0))
    return true
end

-- PARTE 3: Saradomin's Blessing
function PriestInPeril.passo_voltarParaDrezelComChave()
    API.Log("Passo: Voltando para Drezel com a chave.", "info")
    -- Primeiro Trecho: Drezel e o portão
    QUEST.MoveTo(6667, 4310, 0, 5)
    -- Interagir com o Objeto 3444 (ex: portão/porta)
    QUEST.interagirComObjeto(3444, 0x31, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(6669, 4311, 0))
    -- Interagir com o Objeto 30575 (ex: uma porta/passagem)
    QUEST.interagirComObjeto(30575, 0x34, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(6669, 4323, 0))
    -- Segundo Trecho: Movimento para outra área e interação com objetos
    QUEST.MoveTo(3404, 3486, 0, 5)
    -- Interagir com o Objeto 30708
    QUEST.interagirComObjeto(30708, 0x39, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(3404, 3485, 0))
    -- Interagir com o Objeto 102044
    QUEST.interagirComObjeto(102044, 0x34, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(3414, 3480, 0))
    -- Interagir com o Objeto 102045, com um tempo de espera maior
    QUEST.interagirComObjeto(102045, 0x34, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(3406, 3482, 0), 3000, 1500, 2000)

    return true
end

function PriestInPeril.passo_abrirCelaDrezelEFalar()
    -- A condição if QUEST.DoesObjectExist(1047, 8, 1) é para o NPC, mas a ação é em um objeto.
    -- Ajustei para verificar o objeto 3463, que é a cela/portão de Drezel.
    if QUEST.DoesObjectExist(3463, 50, 0) then -- 0 é o ObjType para objetos gerais
        API.Log("Passo: Abrindo a cela de Drezel e falando com ele.", "info")
        QUEST.interagirComObjeto(3463, 0x29, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(3412,3484,0), 1000, 1500, 1000)
        pulardialogos()
        return true
    else
        API.logWarn("Cela de Drezel (objeto 3463) não encontrada. Não foi possível abrir/falar.")
        return false
    end
end

function PriestInPeril.passo_abencoarAgua()
    -- Aqui, a condição if QUEST.DoesObjectExist(1047, 8, 1) verifica se o NPC (Drezel) está presente.
    -- A primeira ação é no objeto (cela), a segunda é no NPC.
    if QUEST.DoesObjectExist(1047, 8, 1) then -- 1 é o ObjType para NPCs
        API.Log("Passo: Abençoando a água.", "info")
        QUEST.interagirComObjeto(3463, 0x29, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(3412,3484,0), 1000, 1500, 1000)
        QUEST.interagirComNPC(1047, 0x2c, API.OFF_ACT_InteractNPC_route, 50) -- Interage com Drezel (NPC ID 1047)
        QUEST.WaitForDialogBox(5)
        while API.Read_LoopyLoop() and QUEST.DialogBoxOpen() do
            QUEST.PressSpace()
        end
        return true
    else
        API.logWarn("Drezel (NPC 1047) não encontrado para abençoar a água.")
        return false
    end
end

function PriestInPeril.passo_usarAguaNoCaixao()
    API.Log("Passo: Usando a água abençoada no caixão.", "info")
    Inventory:DoAction(2954,0,API.OFF_ACT_Bladed_interface_route) -- Esta é uma ação de inventário, mantida.
    QUEST.interagirComObjeto(30728, 0x24, API.OFF_ACT_GeneralObject_route00, 50, WPOINT.new(3410,3485,0))
    return true
end

function PriestInPeril.passo_falarComDrezelDepoisCaixao()
    if QUEST.DoesObjectExist(1047, 8, 1) then -- 1 é o ObjType para NPCs (Drezel)
        API.Log("Passo: Falando com Drezel depois de selar o caixão.", "info")
        QUEST.interagirComObjeto(3463, 0x29, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(3412,3484,0), 1000, 1500, 1000)
        QUEST.interagirComNPC(1047, 0x2c, API.OFF_ACT_InteractNPC_route, 50) -- Interage com Drezel (NPC ID 1047)
        QUEST.WaitForDialogBox(5)
        while API.Read_LoopyLoop() and QUEST.DialogBoxOpen() do
            QUEST.PressSpace()
        end
        return true
    else
        API.logWarn("Drezel (NPC 1047) não encontrado para falar depois de selar o caixão.")
        return false
    end
end

function PriestInPeril.passo_irParaSalaMonumentosFalarDrezel()
    API.Log("Passo: Indo para a sala dos monumentos e falando com Drezel.", "info")
    QUEST.interagirComObjeto(3463, 0x29, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(3412,3484,0))
    PriestInPeril.passo_irParaMausoleuTrocarChave() -- Reutilizando a função
    -- Ação no objeto 3444 com coordenadas diferentes, indicando uma nova instância ou localização
    QUEST.interagirComObjeto(3444, 0x31, API.OFF_ACT_GeneralObject_route0, 50, WPOINT.new(13773,4887,0), 4000, 3000, 2000)
    QUEST.MoveTo(13791, 4882, 0, 5)
    QUEST.interagirComNPC(1049, 0x2c, API.OFF_ACT_InteractNPC_route, 50) -- Interage com o NPC 1049 (Drezel no novo local?)
    pulardialogos()
    return true
end

function PriestInPeril.passo_darEssenciaParaDrezel()
    API.Log("Passo: Dando as essências para Drezel.", "info")
    QUEST.interagirComNPC(1049, 0x2c, API.OFF_ACT_InteractNPC_route, 50) -- Interage com Drezel (NPC ID 1049)
    QUEST.WaitForDialogBox(5)
    while API.Read_LoopyLoop() and QUEST.DialogBoxOpen() do
        QUEST.PressSpace()
    end
    -- Esta linha de interface parece estar fora do fluxo usual de diálogo para "dar essência".
    -- Verifique se é necessária ou se o diálogo já encerra a interação.
    API.DoAction_Interface(0xffffffff,0xffffffff,1,1244,21,-1,API.OFF_ACT_GeneralInterface_route)
    return true
end

------------------------------------------------------------------------------------------------------------------------
-- MAPEAMENTO DOS PASSOS DA MISSÃO E ORDEM
------------------------------------------------------------------------------------------------------------------------

-- Mapeamento das funções dos passos da missão
PriestInPeril.missionSteps = {
    ["Talk to King Roald (1)"] = PriestInPeril.passo_falarComReiRoaldPrimeiraVez,
    ["Go to Paterdomus"] = PriestInPeril.passo_irParaPaterdomus,
    ["Interact with Temple Door"] = PriestInPeril.passo_interagirComPortaTemplo,
    ["Talk to Temple Voice (1)"] = PriestInPeril.passo_falarComVozTemplo,
    ["Descend to Cerberus Mausoleum"] = PriestInPeril.passo_descerMausoleuCerberus,
    ["Kill Cerberus"] = PriestInPeril.passo_matarCerberus,
    ["Return to Temple Door (after Cerberus)"] = PriestInPeril.passo_voltarParaPortaTemploDepoisCerberus,
    ["Talk to Temple Voice (after Cerberus)"] = PriestInPeril.passo_falarComVozTemploDepoisCerberus,
    ["Return to King Roald"] = PriestInPeril.passo_voltarParaReiRoald,
    ["Talk to King Roald (2)"] = PriestInPeril.passo_falarComReiRoaldSegundaVez,
    ["Return to Paterdomus Temple"] = PriestInPeril.passo_voltarParaTemploPaterdomus,
    ["Go up Temple Upper Floor"] = PriestInPeril.passo_subirAndarSuperiorTemplo,
    ["Talk to Imprisoned Drezel"] = PriestInPeril.passo_falarComDrezelPreso,
    ["Go down Temple Lower Floor"] = PriestInPeril.passo_descerAndarInferiorTemplo,
    ["Kill Zamorak Monk and Get Key"] = PriestInPeril.passo_matarMongeZamorakEMegastarChave,
    ["Go to Mausoleum to Exchange Key"] = PriestInPeril.passo_irParaMausoleuTrocarChave,
    ["Find and Exchange Keys"] = PriestInPeril.passo_encontrarEtrocarChaves,
    ["Fill Bucket with Murky Water"] = PriestInPeril.passo_encherBaldeAguaMurky,
    ["Return to Drezel with Key"] = PriestInPeril.passo_voltarParaDrezelComChave,
    ["Open Drezel's Cell and Talk"] = PriestInPeril.passo_abrirCelaDrezelEFalar,
    ["Bless Water"] = PriestInPeril.passo_abencoarAgua,
    ["Use Water on Coffin"] = PriestInPeril.passo_usarAguaNoCaixao,
    ["Talk to Drezel After Coffin"] = PriestInPeril.passo_falarComDrezelDepoisCaixao,
    ["Go to Monument Room and Talk to Drezel"] = PriestInPeril.passo_irParaSalaMonumentosFalarDrezel,
    ["Give Essence to Drezel"] = PriestInPeril.passo_darEssenciaParaDrezel,
}

-- Definindo a ordem explícita dos passos da missão
PriestInPeril.stepOrder = {
    "Talk to King Roald (1)",
    "Go to Paterdomus",
    "Interact with Temple Door",
    "Talk to Temple Voice (1)",
    "Descend to Cerberus Mausoleum",
    "Kill Cerberus",
    "Return to Temple Door (after Cerberus)",
    "Talk to Temple Voice (after Cerberus)",
    "Return to King Roald",
    "Talk to King Roald (2)",
    "Return to Paterdomus Temple",
    "Go up Temple Upper Floor",
    "Talk to Imprisoned Drezel",
    "Go down Temple Lower Floor",
    "Kill Zamorak Monk and Get Key",
    "Go to Mausoleum to Exchange Key",
    "Find and Exchange Keys",
    "Fill Bucket with Murky Water",
    "Return to Drezel with Key",
    "Open Drezel's Cell and Talk",
    "Bless Water",
    "Use Water on Coffin",
    "Talk to Drezel After Coffin",
    "Go to Monument Room and Talk to Drezel",
    "Give Essence to Drezel",
}

------------------------------------------------------------------------------------------------------------------------
-- FUNÇÃO PRINCIPAL PARA INICIAR A MISSÃO A PARTIR DE UM PASSO ESPECÍFICO
------------------------------------------------------------------------------------------------------------------------

function PriestInPeril.StartMission(startStepName, sortedStepKeys)
    API.Log("Starting 'Priest in Peril' mission from step: " .. (startStepName or "Not specified"), "info")

    local startExecuting = false
    -- Percorre todos os passos na ordem fornecida pela UI
    for _, stepName in ipairs(sortedStepKeys) do
        if stepName == startStepName then
            startExecuting = true
        end

        if startExecuting then
            local success = PriestInPeril.missionSteps[stepName]()
            if not success then
                API.Log("Step '" .. stepName .. "' failed. Stopping mission.", "error")
                API.Write_LoopyLoop(false) -- Parar o script se um passo falhar
                return false
            end
            API.Sleep_tick(5) -- Pequena pausa entre os passos
        end
    end

    API.Log("'Priest in Peril' mission completed successfully!", "info")
    API.Write_LoopyLoop(false) -- Parar o script após a conclusão
    return true
end

return PriestInPeril