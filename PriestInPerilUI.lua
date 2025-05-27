-- PriestInPerilUI.lua
local API = require("api")
local QUEST = require("recurso.quest")
local PriestInPeril = require("PriestInPeril") -- Carrega o script principal da missão

local PriestInPerilUI = {}

-- Variáveis de estado da UI
local uiState = {
    guiVisible = true,
    startButton = nil,
    missionStepDropdown = nil,
    selectedMissionStep = nil,
    background = nil,
    sortedStepKeys = {}
}

-- Definir as dimensões e posições da UI
local UI_MARGIN = 100
local UI_PADDING_Y = 6
local UI_PADDING_X = 5
local UI_LINE_HEIGHT = 12
local UI_BOX_WIDTH = 340
local UI_BOX_HEIGHT = 130
local UI_BOX_START_Y = 600
local UI_BOX_END_Y = UI_BOX_START_Y + UI_BOX_HEIGHT
local UI_BOX_END_X = UI_MARGIN + UI_BOX_WIDTH + (2 * UI_PADDING_X)
local UI_BUTTON_WIDTH = 120 -- Aumentado para acomodar o texto
local UI_BUTTON_HEIGHT = 30 -- Ligeiramente aumentado para melhor visual
local UI_BUTTON_MARGIN = 8

-- Função para inicializar os elementos da UI
function PriestInPerilUI:InitializeUI()
    API.Log("Initializing UI elements for Priest in Peril", "debug")

    -- Mapear os passos da missão para o dropdown usando a ordem definida em PriestInPeril.stepOrder
    uiState.sortedStepKeys = PriestInPeril.stepOrder

    -- Fundo da GUI
    uiState.background = API.CreateIG_answer()
    uiState.background.box_name = "GuiBackground"
    uiState.background.box_start = FFPOINT.new(UI_MARGIN, UI_BOX_START_Y, 0)
    uiState.background.box_size = FFPOINT.new(UI_BOX_END_X, UI_BOX_END_Y, 0)
    uiState.background.colour = ImColor.new(50, 48, 47)

    -- Dropdown para selecionar o passo da missão
    uiState.missionStepDropdown = API.CreateIG_answer()
    uiState.missionStepDropdown.box_name = "Mission Step"
    uiState.missionStepDropdown.box_start = FFPOINT.new(UI_MARGIN + UI_PADDING_X, UI_BOX_START_Y + UI_PADDING_Y, 0)
    uiState.missionStepDropdown.stringsArr = {}
    for _, key in ipairs(uiState.sortedStepKeys) do
        table.insert(uiState.missionStepDropdown.stringsArr, key)
    end

    -- Botão de Iniciar
    uiState.startButton = API.CreateIG_answer()
    uiState.startButton.box_name = "Start Mission"
    -- Ajuste a posição X para centralizar o botão, caso o tamanho mude muito
    uiState.startButton.box_start = FFPOINT.new(UI_MARGIN + UI_PADDING_X + (UI_BOX_WIDTH / 2) - (UI_BUTTON_WIDTH / 2), UI_BOX_START_Y + UI_PADDING_Y + 40, 0)
    uiState.startButton.box_size = FFPOINT.new(UI_BUTTON_WIDTH, UI_BUTTON_HEIGHT, 0)
    uiState.startButton.colour = ImColor.new(160, 255, 0)

    API.Log("UI elements initialized", "debug")
end

-- Função para lidar com o clique do botão Iniciar
function PriestInPerilUI:HandleStartButton()
    if uiState.guiVisible then
        if uiState.startButton.return_click then
            uiState.startButton.return_click = false
            -- O script será iniciado, então escondemos a GUI
            uiState.guiVisible = false
            uiState.background.remove = true
            uiState.startButton.remove = true
            uiState.missionStepDropdown.remove = true

            -- Obter o passo da missão selecionado
            local selectedKey = uiState.sortedStepKeys[tonumber(uiState.missionStepDropdown.int_value) + 1]
            uiState.selectedMissionStep = selectedKey

            API.Log("Script started from step: " .. (uiState.selectedMissionStep or "None"), "info")
            -- Chama a função StartMission do PriestInPeril, passando o passo selecionado e a lista ordenada de passos
            PriestInPeril.StartMission(uiState.selectedMissionStep, uiState.sortedStepKeys)
        end
    end
end

-- Função para desenhar os botões e elementos da UI
function PriestInPerilUI:DrawButtons()
    API.DrawSquareFilled(uiState.background)
    API.DrawComboBox(uiState.missionStepDropdown, false)
    API.DrawBox(uiState.startButton)
end

-- Função principal para desenhar a GUI
function PriestInPerilUI:DrawGui()
    if uiState.guiVisible then
        self:DrawButtons()
        self:HandleStartButton()
    end
end

-- Bloco de inicialização e loop principal do script
PriestInPerilUI:InitializeUI()
API.Write_LoopyLoop(true) -- Inicia o loop principal do script

while API.Read_LoopyLoop() do
    API.Sleep_tick(1) -- Pequeno atraso para evitar alto uso de CPU
    PriestInPerilUI:DrawGui()
    -- O loop continuará enquanto API.Read_LoopyLoop() retornar true
    -- e uiState.guiVisible for true (durante a exibição da GUI)
    -- ou até que API.Write_LoopyLoop(false) seja chamado (por exemplo, ao final da missão)
end

return PriestInPerilUI
