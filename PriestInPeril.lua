local API = require("api")

local QUEST = require("recurso.quest")

-- Função principal que orquestra toda a missão
local function iniciarMissaoAMissingMonk()
    print("Iniciando a missão 'A Missing Monk'...")

    -- Parte 1: A Missing Monk
    if not passo_falarComReiRoaldPrimeiraVez() then return false end
    if not passo_irParaPaterdomus() then return false end
    if not passo_interagirComPortaTemplo() then return false end
    if not passo_falarComVozTemplo() then return false end
    if not passo_descerMausoleuCerberus() then return false end
    if not passo_matarCerberus() then return false end
    if not passo_voltarParaPortaTemploDepoisCerberus() then return false end
    if not passo_falarComVozTemploDepoisCerberus() then return false end
    if not passo_voltarParaReiRoald() then return false end
    if not passo_falarComReiRoaldSegundaVez() then return false end

    -- Parte 2: The Temple on the Salve
    if not passo_voltarParaTemploPaterdomus() then return false end
    if not passo_subirAndarSuperiorTemplo() then return false end
    if not passo_falarComDrezelPreso() then return false end
    if not passo_descerAndarInferiorTemplo() then return false end
    if not passo_matarMongeZamorakEMegastarChave() then return false end
    if not passo_irParaMausoleuTrocarChave() then return false end
    if not passo_encontrarEtrocarChaves() then return false end
    if not passo_encherBaldeAguaMurky() then return false end

    -- Parte 3: Saradomin's Blessing
    if not passo_voltarParaDrezelComChave() then return false end
    if not passo_abrirCelaDrezelEFalar() then return false end
    if not passo_abencoarAgua() then return false end
    if not passo_usarAguaNoCaixao() then return false end
    if not passo_falarComDrezelDepoisCaixao() then return false end
    if not passo_irParaSalaMonumentosFalarDrezel() then return false end
    if not passo_darEssenciaParaDrezel() then return false end

    print("Missão 'A Missing Monk' concluída com sucesso!")
    return true
end

------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES DE CADA PASSO DA MISSÃO
------------------------------------------------------------------------------------------------------------------------

-- PARTE 1: A Missing Monk


local function pulardialogos()
    local tentativas_atuais = 0
    while API.Read_LoopyLoop() and QUEST.DialogBoxOpen() and 0 < 15 do
        API.logDebug("Diálogo ainda aberto. Pressionando espaço para aceitar/avançar... (Tentativa " .. (tentativas_atuais + 1) .. ")")
        QUEST.PressSpace()
        QUEST.Sleep(0.8) -- Pequena pausa entre cada pressão de espaço
        tentativas_atuais = tentativas_atuais + 1
    end
end

local function passo_falarComReiRoaldPrimeiraVez()
    Inventory:DoAction(8007,1,API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(7000, 2000, 3000)
    QUEST.MoveTo(3217, 3472, 0, 2)
    API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{ 15536 },50,WPOINT.new(3218,3472,0));
    API.WaitUntilMovingEnds(15, 20)
    API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{ 648 },50)
    API.RandomSleep2(4000, 2000, 3000)
    QUEST.OptionSelector({"Greet the king"})
    pulardialogos()
    API.DoAction_Interface(0x24,0xffffffff,1,1500,409,-1,API.OFF_ACT_GeneralInterface_route)
    pulardialogos()
end


local function passo_irParaPaterdomus()
    QUEST.MoveTo(3258, 3440, 0, 5)
    QUEST.MoveTo(3273, 3428, 0, 5)
    QUEST.MoveTo(3319, 3430, 0, 5)
    QUEST.MoveTo(3362, 3442, 0, 5)
    QUEST.MoveTo(3392, 3485, 0, 5)
    return true -- Placeholder
end


local function passo_interagirComPortaTemplo()
    API.DoAction_Object2(0x39,API.OFF_ACT_GeneralObject_route0,{ 30707 },50,WPOINT.new(3404,3486,0))
    API.RandomSleep2(4000, 2000, 3000)
    QUEST.OptionSelector({"Knock at the door."})
    return true -- Placeholder
end

local function passo_falarComVozTemplo()
    pulardialogos()
    QUEST.OptionSelector({"Roald sent me to check on Drezel."})
    pulardialogos()
    QUEST.OptionSelector({"Yes"})
    pulardialogos()
    return true -- Placeholder
end

local function passo_descerMausoleuCerberus()
    QUEST.MoveTo(3406, 3505, 0, 5)
    API.DoAction_Object2(0x39,API.OFF_ACT_GeneralObject_route0,{ 30571 },50,WPOINT.new(3405,3505,0))

    return true -- Placeholder
end

local function passo_matarCerberus()

    API.DoAction_NPC(0x2a,API.OFF_ACT_AttackNPC_route,{ ids },50)
    API.RandomSleep2(4000, 2000, 3000)

    --apos o fim da quest voltar para pegar id do cachorro
    return true -- Placeholder
end

local function passo_voltarParaPortaTemploDepoisCerberus()
    API.DoAction_Object2(0x34,API.OFF_ACT_GeneralObject_route0,{ 30575 },50,WPOINT.new(7821,3171,0))
    QUEST.MoveTo(3402, 3485, 0, 5)
    return true -- Placeholder
end

local function passo_falarComVozTemploDepoisCerberus()
    passo_interagirComPortaTemplo()
    pulardialogos()
    return true -- Placeholder
end
local function passo_voltarParaReiRoald()
    Inventory:DoAction(8007,1,API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(7000, 2000, 3000)
    QUEST.MoveTo(3217, 3472, 0, 2)
    API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{ 15536 },50,WPOINT.new(3218,3472,0));
    API.WaitUntilMovingEnds(15, 20)
    return true -- Placeholder
end

local function passo_falarComReiRoaldSegundaVez()
    print("Passo: Falando com o Rei Roald pela segunda vez.")
    API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{ 648 },50)
    API.RandomSleep2(4000, 2000, 3000)
    QUEST.OptionSelector({"Talk about Priest in Peril."})
    pulardialogos()
    return true -- Placeholder
end


-- PARTE 2: The Temple on the Salve

local function passo_voltarParaTemploPaterdomus()
    print("Passo: Voltando para o templo de Paterdomus e entrando.")
    passo_irParaPaterdomus()
    API.DoAction_Object2(0x39,API.OFF_ACT_GeneralObject_route0,{ 30707 },50,WPOINT.new(3404,3486,0))
    return true -- Placeholder
end


local function passo_subirAndarSuperiorTemplo()
    print("Passo: Subindo para o andar superior do templo.")
    API.RandomSleep2(4000, 2000, 3000)
    API.DoAction_Object2(0x34,API.OFF_ACT_GeneralObject_route0,{ 102043 },50,WPOINT.new(3414,3490,0))
    API.RandomSleep2(4000, 2000, 3000)
    API.DoAction_Object2(0x34,API.OFF_ACT_GeneralObject_route0,{ 102045 },50,WPOINT.new(3406,3482,0));
    API.RandomSleep2(4000, 2000, 3000)
    return true -- Placeholder
end

local function passo_falarComDrezelPreso()
    print("Passo: Falando com o Drezel preso.")
    API.DoAction_Object2(0x29,API.OFF_ACT_GeneralObject_route0,{ 3463 },50,WPOINT.new(3412,3484,0))
    pulardialogos()
    QUEST.OptionSelector({"Tell me anyway."})
    pulardialogos()
    QUEST.OptionSelector({"Yes."})
    pulardialogos()
    return true -- Placeholder
end


local function passo_descerAndarInferiorTemplo()
    print("Passo: Descendo para o andar inferior do templo.")
    API.DoAction_Object2(0x35,API.OFF_ACT_GeneralObject_route0,{ 102048 },50,WPOINT.new(3407,3483,0))
    API.RandomSleep2(4000, 2000, 3000)
    return true -- Placeholder
end

local function passo_matarMongeZamorakEMegastarChave()
    print("Passo: Matando monge de Zamorak e pegando a golden key.")
    API.DoAction_NPC(0x2a,API.OFF_ACT_AttackNPC_route,{ 1044 },50)
    API.RandomSleep2(4000, 2000, 3000)
    API.DoAction_G_Items1(0x2d,{ 2944 },50);
    API.RandomSleep2(3000, 1500, 2000)
    API.DoAction_Interface(0x24,0xffffffff,1,1622,22,-1,API.OFF_ACT_GeneralInterface_route)

    return true -- Placeholder
end


local function passo_irParaMausoleuTrocarChave()
    print("Passo: Indo para o Mausoléu para trocar a chave.")
    API.DoAction_Object2(0x35,API.OFF_ACT_GeneralObject_route0,{ 102047 },50,WPOINT.new(3414,3480,0));
    API.RandomSleep2(4000, 3000, 2000)
    API.DoAction_Object2(0x39,API.OFF_ACT_GeneralObject_route0,{ 30707 },50,WPOINT.new(3404,3486,0));
    API.RandomSleep2(4000, 3000, 2000)
    QUEST.MoveTo(3405, 3503, 0, 5)
    API.DoAction_Object2(0x39,API.OFF_ACT_GeneralObject_route0,{ 30571 },50,WPOINT.new(3405,3505,0));
    API.RandomSleep2(4000, 3000, 2000)
    API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{ 3444 },50,WPOINT.new(6669,4311,0));
    API.RandomSleep2(5000, 3000, 2000)
    return true -- Placeholder
end


local function passo_encontrarEtrocarChaves()
    print("Passo: Encontrando e trocando as chaves no Mausoléu.")
    API.DoAction_Object2(0x32,API.OFF_ACT_GeneralObject_route0,{ 3496 },50,WPOINT.new(6687,4300,0));
    API.RandomSleep2(3000, 1500, 2000)
    Inventory:DoAction(2944,0,API.API.OFF_ACT_Bladed_interface_route)
    API.RandomSleep2(3000, 1500, 2000)
    API.DoAction_Object2(0x24,API.OFF_ACT_GeneralObject_route00,{ 3496 },50,WPOINT.new(6691,4301,0));
    API.DoAction_Object2(0x32,API.OFF_ACT_GeneralObject_route0,{ 3493 },50,WPOINT.new(6681,4306,0));
    API.RandomSleep2(3000, 1500, 2000)
    Inventory:DoAction(2944,0,API.API.OFF_ACT_Bladed_interface_route)
    API.RandomSleep2(3000, 1500, 2000)
    API.DoAction_Object2(0x24,API.OFF_ACT_GeneralObject_route00,{ 3493 },50,WPOINT.new(6691,4301,0));
    API.DoAction_Object2(0x32,API.OFF_ACT_GeneralObject_route0,{ 3499 },50,WPOINT.new(6682,4310,0));
    API.RandomSleep2(3000, 1500, 2000)
    Inventory:DoAction(2944,0,API.API.OFF_ACT_Bladed_interface_route)
    API.RandomSleep2(3000, 1500, 2000)
    API.DoAction_Object2(0x24,API.OFF_ACT_GeneralObject_route00,{ 3499 },50,WPOINT.new(6691,4301,0));
    API.DoAction_Object2(0x32,API.OFF_ACT_GeneralObject_route0,{ 3494 },50,WPOINT.new(6687,4311,0));
    API.RandomSleep2(3000, 1500, 2000)
    Inventory:DoAction(2944,0,API.API.OFF_ACT_Bladed_interface_route)
    API.RandomSleep2(3000, 1500, 2000)
    API.DoAction_Object2(0x24,API.OFF_ACT_GeneralObject_route00,{ 3494 },50,WPOINT.new(6691,4301,0));
    API.DoAction_Object2(0x32,API.OFF_ACT_GeneralObject_route0,{ 3497 },50,WPOINT.new(6691,4310,0));
    API.RandomSleep2(3000, 1500, 2000)
    Inventory:DoAction(2944,0,API.API.OFF_ACT_Bladed_interface_route)
    API.RandomSleep2(3000, 1500, 2000)
    API.DoAction_Object2(0x24,API.OFF_ACT_GeneralObject_route00,{ 3497 },50,WPOINT.new(6691,4301,0));
    API.DoAction_Object2(0x32,API.OFF_ACT_GeneralObject_route0,{ 3495 },50,WPOINT.new(6692,4306,0));
    API.RandomSleep2(3000, 1500, 2000)
    Inventory:DoAction(2944,0,API.API.OFF_ACT_Bladed_interface_route)
    API.RandomSleep2(3000, 1500, 2000)
    API.DoAction_Object2(0x24,API.OFF_ACT_GeneralObject_route00,{ 3495 },50,WPOINT.new(6691,4301,0));
    API.DoAction_Object2(0x32,API.OFF_ACT_GeneralObject_route0,{ 3498 },50,WPOINT.new(6691,4301,0));
    API.RandomSleep2(3000, 1500, 2000)
    Inventory:DoAction(2944,0,API.API.OFF_ACT_Bladed_interface_route)
    API.RandomSleep2(3000, 1500, 2000)
    API.DoAction_Object2(0x24,API.OFF_ACT_GeneralObject_route00,{ 3498 },50,WPOINT.new(6691,4301,0));
    return true -- Placeholder
end

local function passo_encherBaldeAguaMurky()
    print("Passo: Enchendo o balde com água murky.")
    Inventory:DoAction(1925,0,API.API.OFF_ACT_Bladed_interface_route)
    API.RandomSleep2(1000, 1500, 1000)
    API.DoAction_Object2(0x24,API.OFF_ACT_GeneralObject_route00,{ 3485 },50,WPOINT.new(6686,4305,0));
    return true -- Placeholder
end


local function passo_voltarParaDrezelComChave()
    print("Passo: Voltando para Drezel com a chave.")
    QUEST.MoveTo(6667, 4310, 0, 5)
    API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{ 3444 },50,WPOINT.new(6669,4311,0))
    API.RandomSleep2(1000, 1500, 1000)
    API.DoAction_Object2(0x34,API.OFF_ACT_GeneralObject_route0,{ 30575 },50,WPOINT.new(6669,4323,0));
    API.RandomSleep2(1000, 1500, 1000)
    QUEST.MoveTo(3404, 3486, 0, 5)
    API.DoAction_Object2(0x39,API.OFF_ACT_GeneralObject_route0,{ 30708 },50,WPOINT.new(3404,3485,0));
    API.RandomSleep2(1000, 1500, 1000)
    API.DoAction_Object2(0x34,API.OFF_ACT_GeneralObject_route0,{ 102044 },50,WPOINT.new(3414,3480,0));
    API.RandomSleep2(1000, 1500, 1000)
    API.DoAction_Object2(0x34,API.OFF_ACT_GeneralObject_route0,{ 102045 },50,WPOINT.new(3406,3482,0));
    API.RandomSleep2(3000, 1500, 2000)
    return true -- Placeholder
end


local function passo_abrirCelaDrezelEFalar()
    print("Passo: Abrindo a cela de Drezel e falando com ele.")
    API.DoAction_Object2(0x29,API.OFF_ACT_GeneralObject_route0,{ 3463 },50,WPOINT.new(3412,3484,0));
    API.RandomSleep2(1000, 1500, 1000)
    pulardialogos()
    return true -- Placeholder
end

local function passo_abencoarAgua()
print("Passo: Abençoando a água.")
    API.DoAction_Object2(0x29,API.OFF_ACT_GeneralObject_route0,{ 3463 },50,WPOINT.new(3412,3484,0));
    API.RandomSleep2(1000, 1500, 1000)
    API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{ 1047 },50)
    pulardialogos()
return true -- Placeholder
end


local function passo_usarAguaNoCaixao()
print("Passo: Usando a água abençoada no caixão.")
    Inventory:DoAction(2954,0,API.API.OFF_ACT_Bladed_interface_route)
    API.DoAction_Object2(0x24,API.OFF_ACT_GeneralObject_route00,{ 30728 },50,WPOINT.new(3410,3485,0));
return true -- Placeholder
end


local function passo_falarComDrezelDepoisCaixao()
print("Passo: Falando com Drezel depois de selar o caixão.")
    API.DoAction_Object2(0x29,API.OFF_ACT_GeneralObject_route0,{ 3463 },50,WPOINT.new(3412,3484,0));
    API.RandomSleep2(1000, 1500, 1000)
    API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{ 1047 },50)
    pulardialogos()
return true -- Placeholder
end


local function passo_irParaSalaMonumentosFalarDrezel()
print("Passo: Indo para a sala dos monumentos e falando com Drezel.")
    API.DoAction_Object2(0x29,API.OFF_ACT_GeneralObject_route0,{ 3463 },50,WPOINT.new(3412,3484,0));
    passo_irParaMausoleuTrocarChave()
    API.DoAction_Object2(0x31,API.OFF_ACT_GeneralObject_route0,{ 3444 },50,WPOINT.new(13773,4887,0));
    API.RandomSleep2(4000, 3000, 2000)
    QUEST.MoveTo(13791, 4882, 0, 5)
    API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{ 1049 },50)
    pulardialogos()
return true -- Placeholder
end


local function passo_darEssenciaParaDrezel()
print("Passo: Dando as essências para Drezel.")
    API.DoAction_NPC(0x2c,API.OFF_ACT_InteractNPC_route,{ 1049 },50)
    pulardialogos()
    API.DoAction_Interface(0xffffffff,0xffffffff,1,1244,21,-1,API.OFF_ACT_GeneralInterface_route)
return true -- Placeholder
end

-- Chamada da função principal para iniciar o script
iniciarMissaoAMissingMonk()