# MIDAS – Documentação Didática e Funcional

## Visão macro (o que é, para quem é, como funciona)

O MIDAS é uma aplicação desktop construída com Python (backend) e Qt Quick/QML (frontend) via PySide6. A missão do sistema é: carregar arquivos CSV e ARFF, exibir os dados em uma tabela e permitir que o usuário gere um arquivo ARFF com tipificação adequada por atributo.

- "Frontend" (QML): define a interface visual, navegação e componentes (botões, tabelas, diálogos). QML é declarativo: você descreve o que a UI é, e o Qt cuida de desenhar e reagir a mudanças.
- "Backend" (Python + PySide6): implementa a lógica de negócio, lê arquivos, monta modelos de dados e expõe métodos e propriedades para o QML via sinais/slots e propriedades Qt.
- Conexão entre frontend e backend: o Python registra classes como tipos importáveis no QML (`qmlRegisterType`). No QML, instâncias desses tipos são criadas e suas funções são chamadas (Slots), enquanto o Python notifica a UI sobre mudanças (Signals/Property notify).

Referências úteis:
- PySide6 Qt for Python: `https://doc.qt.io/qtforpython-6.7/`
- QML/Qt Quick: `https://doc.qt.io/qt-6/qtquick-index.html`
- Sinais e Slots (Qt): `https://doc.qt.io/qt-6/signalsandslots.html`
- liac-arff (formato ARFF em Python): `https://pypi.org/project/liac-arff/`


## Arquitetura em camadas (como as peças se conectam)

- `main.py`: ponto de entrada. Cria a aplicação Qt, registra os controladores Python para uso no QML e carrega `main.qml`.
- QML (UI): `main.qml` define a janela principal e navegação entre páginas; `page1.qml` carrega arquivos; `page2.qml` mostra a tabela e estatísticas; `page3.qml` permite sugerir/ajustar tipos e salvar ARFF.
- Controladores especializados:
  - `csv_controller.py` (`CSVController`): carrega CSV com pandas, expõe um `DataFrameModel` para a UI e utilitários (nomes de colunas, exemplos, tipo sugerido por coluna, etc.).
  - `arff_controller.py` (`ARFFController`): carrega ARFF com `liac-arff`, calcula sugestões de tipo por atributo, monta um `DataFrameModel` e salva ARFF com metadados atualizados.
- `table_model.py` (`DataFrameModel`): implementação de `QAbstractTableModel` baseada em `pandas.DataFrame` para alimentar o `TableView` do QML.

Imagem conceitual do fluxo:

- Usuário clica em “Carregar CSV/ARFF” → QML abre `FileDialog` → chama `CSVController.loadCsv(url)` ou `ARFFController.loadArff(url)` → Python lê, monta modelo, emite sinais → QML atualiza a interface com a tabela e estatísticas → usuário avança e pode ajustar tipos → salva ARFF.


## Função e características de cada arquivo

### `main.py`
- Função: inicializa a aplicação e expõe os tipos do backend ao QML.
- Pontos-chave:
  - `qmlRegisterType(CSVController, "App", 1, 0, "CSVController")`: torna `CSVController` usável no QML via `import App 1.0` e o tipo `CSVController`.
  - `QQmlApplicationEngine().load(qml_path)`: carrega o arquivo QML raiz.
  - Verificação `engine.rootObjects()`: se vazio, indica falha no carregamento do QML.

### `main.qml`
- Função: janela principal (ApplicationWindow) com tema Material e um `StackView` para navegação.
- Características:
  - Instancia `CSVController` e `ARFFController` diretamente no QML e conecta seus sinais a um `MessageDialog` para feedback ao usuário.
  - `StackView` carrega `page1.qml` como primeira tela e injeta referências aos controladores para a página.
  - Quando a página 1 notifica que dados foram carregados, faz `push` para `page2.qml`, passando `csvController`, `arffController`, `stack` e `fileType`.

### `page1.qml`
- Função: tela inicial com dois botões para carregar arquivo CSV ou ARFF.
- Características:
  - Dois `FileDialog` (um para CSV, outro para ARFF). Ao aceitar, chama `csvController.loadCsv(selectedFile)` ou `arffController.loadArff(selectedFile)`.
  - Usa `Connections` para escutar `dataframeChanged` (CSV) e `dataLoaded` (ARFF). Ao ocorrer, chama o callback `onDataLoaded("csv"|"arff")` que a `main.qml` configurou, acionando a navegação.

### `page2.qml`
- Função: exibe a tabela de dados e estatísticas básicas.
- Características:
  - Escolhe `activeController` conforme `fileType` (CSV ou ARFF).
  - Para CSV: nome base usa `csvController.fileName`, instâncias com `rowCount()`, atributos com `columnCount()`.
  - Para ARFF: nome base usa `arffController.relationName`, instâncias `instanceCount` (Property), atributos `attributeCount` (Property).
  - `TableView.model: activeController.tableModel` (o QML consome o `QAbstractTableModel`).

### `page2_table.qml`
- Função: variante simplificada da tela de tabela (não usada no fluxo principal atual), demonstra consumo direto de `tableModel`, `fileName` e `info`.

### `page3.qml`
- Função: tela para sugerir/ajustar o tipo de cada atributo e salvar um ARFF.
- Características:
  - Obtém nomes de atributos via `activeController.getAttributeNames()`.
  - Para cada atributo, mostra um `ComboBox` com os tipos disponíveis. Na criação, consulta `activeController.getSuggestedType(attrName)` e posiciona o índice inicial.
  - Ao trocar o tipo, chama `activeController.setAttributeType(attrName, currentText)`.
  - Mostra exemplos por coluna com `activeController.getAttributeExamples(attrName)`.
  - Botão “Salvar” abre `FileDialog` e chama `activeController.saveMetadata(path)`.

### `csv_controller.py` (classe `CSVController`)
- Função: carregar CSV, expor metadados e dados ao QML.
- API exposta ao QML:
  - Properties: `fileName` (str), `info` (str), `tableModel` (QObject constante).
  - Signals: `dataframeChanged`, `fileNameChanged`, `errorOccurred(str)`, `successOccurred(str)`, `infoChanged`.
  - Slots principais:
    - `loadCsv(QUrl)`: converte `QUrl` em caminho e lê CSV com `pandas.read_csv`. Atualiza `DataFrameModel` via `setDataFrame` e emite sinais para a UI.
    - `rowCount()`, `columnCount()`, `headerForColumn(int)`, `dataAt(int,int)`: utilitários para UI e compatibilidade.
    - `getAttributeNames()`: nomes das colunas do DataFrame.
    - `getSuggestedType(attribute_name)`: heurística simples baseada no dtype do pandas: numérico → "Numérico"; datetime → "Data"; colunas com poucos valores únicos relativos → "Nominal"; senão → "Textual".
    - `getAttributeExamples(attribute_name)`: primeiros 5 valores da coluna formatados para exibição.
    - `setAttributeType(...)`: placeholder (não persiste tipos customizados para CSV nesta versão).
    - `generateArff(output_path)` e `saveMetadata(output_path)`: exporta dados para ARFF (a segunda usa os tipos sugeridos para montar os atributos, inclusive nominais com valores únicos limitados).
- Particularidades:
  - Mantém `_model` sempre vivo e o expõe como `tableModel` constante para que o QML possa referenciar o mesmo objeto de modelo.
  - Ao ler CSV, atualiza o `DataFrameModel` com `beginResetModel()/endResetModel()` internos do modelo para que o `TableView` reflita as mudanças automaticamente.

### `arff_controller.py` (classe `ARFFController`)
- Função: carregar, inspecionar e exportar ARFF.
- API exposta ao QML:
  - Properties: `tableModel` (QVariant), `instanceCount` (int), `attributeCount` (int), `fileName` (str), `relationName` (str), `availableTypes` (list).
  - Signals: `dataLoaded`, `fileNameChanged`, `errorOccurred(str)`, `successOccurred(str)`, `metadataChanged`.
  - Slots principais:
    - `loadArff(QUrl)`: lê ARFF via `liac-arff.load`, extrai `relation`, `attributes` e `data`, normaliza linhas para `list`, gera sugestões de tipos, cria `DataFrame`/`DataFrameModel` e emite `dataLoaded`/`metadataChanged`.
    - `getSuggestedType(attribute_name)`: mapeia tipos ARFF para português: STRING→Textual, NUMERIC/REAL/INTEGER→Numérico, DATE→Data, lista/tupla→Nominal.
    - `getAttributeExamples(attribute_name)`: primeiros 5 valores da coluna.
    - `getAttributeNames()`: retorna nomes dos atributos.
    - `setAttributeType(attribute_name, new_type)`: ajusta o tipo selecionado internamente, afetando a geração posterior.
    - `generateArff(output_path)` e `saveMetadata(output_path)`: escreve ARFF com tipos escolhidos/sugeridos. Para “Nominal”, deriva o conjunto de valores únicos da coluna.
- Particularidades e detalhes importantes:
  - Constrói `_type_translations` e `_available_types` em português para a UI.
  - Ao criar o DataFrame, usa os nomes dos atributos como colunas (ordem preservada) e empacota em `DataFrameModel` para a UI.
  - Contém depuração com `print("DEBUG: ...")` que ajuda a entender o fluxo de carregamento e tipificação.

### `table_model.py` (classe `DataFrameModel`)
- Função: adaptar um `pandas.DataFrame` para o modelo de dados que o QML entende (`QAbstractTableModel`).
- Métodos-chave:
  - `setDataFrame(df)`: reseta o modelo para o novo DataFrame, disparando a atualização para as views.
  - `rowCount`, `columnCount`: tamanhos.
  - `data(index, Qt.DisplayRole)`: fornece o dado textual de cada célula, convertendo `NaN` para string vazia.
  - `headerData(section, orientation, role)`: títulos das colunas no cabeçalho horizontal; nas linhas, retorna 1..N.
  - `roleNames()`: mapeia `Qt.DisplayRole` para o papel `display` que o `TableView` do QML usa no `delegate`.

### Outros arquivos
- `requirements.txt`: dependências Python (PySide6, pandas, scipy, liac-arff).
- `dataset.svg`: ícone SVG simples (usado como recurso visual opcional).
- `teste.csv`, `teste.arff`: arquivos de exemplo para testes locais.


## Conceitos básicos de Qt/QML essenciais para entender o código

- ApplicationWindow: janela principal da aplicação em QML. Em `main.qml`, define tema Material, dimensões e um `StackView` para navegação.
- StackView: gerencia uma pilha de páginas. `initialItem` é `page1.qml`; a navegação usa `push` e `pop`.
- FileDialog: componente que abre um seletor de arquivos. Emite `onAccepted` com `selectedFile` (um `QUrl`).
- Signals/Slots/Properties (integração Python↔QML):
  - No Python, decoradores `Signal`, `Slot` e `Property` expõem eventos, funções chamáveis e propriedades observáveis ao QML.
  - No QML, você chama um Slot como se fosse um método (`controller.loadCsv(url)`) e reage a Signals via `Connections { function onAlgoMudou(...) { ... } }`.
- QAbstractTableModel no QML: o `TableView` consome `model` que implementa `roleNames()` e fornece dados para o papel `display`. O `delegate` lê `display` para exibir cada célula.


## Fluxo principal de carregamento – CSV

1) Página 1 (QML): usuário clica em “CARREGAR ARQUIVO CSV” → `FileDialog` abre → ao aceitar, chama `csvController.loadCsv(selectedFile)`.
2) `CSVController.loadCsv(QUrl)` (Python):
   - Converte `QUrl` em caminho local.
   - Lê CSV com `pandas.read_csv` para `_df`.
   - Atualiza `_model` (`DataFrameModel.setDataFrame(_df)`), emite `dataframeChanged` e `infoChanged`.
3) Página 1 (QML): via `Connections` escuta `onDataframeChanged()` e chama o callback `onDataLoaded("csv")`.
4) `main.qml`: navega para `page2.qml` com `fileType: "csv"` e injeta `csvController`.
5) `page2.qml`: exibe a tabela (`model: csvController.tableModel`) e estatísticas (instâncias com `rowCount()`, atributos com `columnCount()`). Botão “Avançar” abre `page3.qml`.
6) `page3.qml`: monta lista de atributos de `csvController.getAttributeNames()`, obtém tipo sugerido com `getSuggestedType(nome)`, aceita alteração manual (não persistida em `CSVController` nesta versão) e permite salvar via `saveMetadata(path)` gerando um ARFF compatível.


## Fluxo principal de carregamento – ARFF

1) Página 1 (QML): usuário clica em “CARREGAR ARQUIVO ARFF” → `FileDialog` abre → ao aceitar, chama `arffController.loadArff(selectedFile)`.
2) `ARFFController.loadArff(QUrl)` (Python):
   - Converte `QUrl` em caminho local.
   - Lê ARFF com `arff.load(f)` (liac-arff) → obtém `relation`, `attributes`, `data`.
   - Normaliza linhas para listas, gera sugestões de tipo por atributo (`_generateTypeSuggestions`) e cria `_dataframe` + `_table_model` (`DataFrameModel`). Emite `dataLoaded` e `metadataChanged`.
3) Página 1 (QML): via `Connections` escuta `onDataLoaded()` e chama o callback `onDataLoaded("arff")`.
4) `main.qml`: navega para `page2.qml` com `fileType: "arff"` e injeta `arffController`.
5) `page2.qml`: exibe a tabela (`model: arffController.tableModel`) e estatísticas de `instanceCount`/`attributeCount`. Botão “Avançar” abre `page3.qml`.
6) `page3.qml`: monta lista de atributos via `arffController.getAttributeNames()`, lê tipo sugerido com `getSuggestedType(nome)`, permite ajustar com `setAttributeType(nome, tipo)` e salva via `saveMetadata(path)` gerando ARFF com metadados + dados.


## Zoom em pontos cruciais do código (linha a linha comentada)

- Registro de tipos Python no QML (em `main.py`):
```12:16:/home/gabrafo/Repositórios/qt-quick/main.py
    # Disponibiliza controladores no QML via: import App 1.0
    qmlRegisterType(CSVController, "App", 1, 0, "CSVController")
    qmlRegisterType(ARFFController, "App", 1, 0, "ARFFController")
```
- Carregamento do QML (em `main.py`):
```17:23:/home/gabrafo/Repositórios/qt-quick/main.py
    engine = QQmlApplicationEngine()
    qml_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "main.qml")
    engine.load(qml_path)

    if not engine.rootObjects():
        print("Erro: não foi possível carregar a interface QML.")
```
- Disparo da navegação após carregar dados (em `page1.qml`):
```124:136:/home/gabrafo/Repositórios/qt-quick/page1.qml
    Connections {
        target: firstWindow.csvController
        function onDataframeChanged() {
            if (firstWindow.onDataLoaded) firstWindow.onDataLoaded("csv")
        }
    }
    
    Connections {
        target: firstWindow.arffController
        function onDataLoaded() {
            if (firstWindow.onDataLoaded) firstWindow.onDataLoaded("arff")
        }
    }
```
- Tabela consumindo o `QAbstractTableModel` (em `page2.qml`):
```100:108:/home/gabrafo/Repositórios/qt-quick/page2.qml
                    TableView {
                        anchors.fill: parent
                        model: activeController ? activeController.tableModel : null
                        clip: true
                        
                        delegate: Rectangle {
                            implicitWidth: 100
                            implicitHeight: 32
```
- Sugerindo e alterando tipos por atributo (em `page3.qml`):
```282:301:/home/gabrafo/Repositórios/qt-quick/page3.qml
                                            Component.onCompleted: {
                                                if (activeController && attrName) {
                                                    var suggested = activeController.getSuggestedType(attrName)
                                                    console.log("QML: Atributo '" + attrName + "' tipo sugerido: '" + suggested + "'")
                                                    for (var i = 0; i < model.length; i++) {
                                                        if (model[i] === suggested) {
                                                            currentIndex = i
                                                            break
                                                        }
                                                    }
                                                    initialized = true
                                                }
                                            }

                                            onCurrentTextChanged: {
                                                if (initialized && activeController && attrName && currentText) {
                                                    console.log("QML: Alterando tipo de '" + attrName + "' para '" + currentText + "'")
                                                    activeController.setAttributeType(attrName, currentText)
                                                }
                                            }
```
- Criação do modelo de tabela a partir de DataFrame (em `arff_controller.py`):
```181:189:/home/gabrafo/Repositórios/qt-quick/arff_controller.py
            # Extrai nomes das colunas dos atributos
            column_names = [attr[0] for attr in self._attributes]
            
            # Cria DataFrame
            self._dataframe = pd.DataFrame(self._data, columns=column_names)
            
            # Cria o modelo da tabela
            self._table_model = DataFrameModel(self._dataframe)
```


## Dicas de entendimento para quem vem de Python puro

- QML é reativo: quando um `Signal` é emitido no Python (por exemplo, `dataframeChanged`), o QML que está "escutando" via `Connections` pode reagir instantaneamente.
- `Property(..., notify=...)`: ao alterar o valor no Python e emitir o sinal de notify, o QML reflete a mudança automaticamente quando usa a propriedade em expressões.
- `QUrl` no QML representa caminhos como `file:///caminho/para/arquivo.csv`. O backend geralmente converte para caminho local com `toLocalFile()` quando `scheme()=="file"`.
- Modelos de dados no QML esperam papéis (roles). Nosso `DataFrameModel.roleNames()` mapeia `Qt.DisplayRole` para o papel `display`, que o `delegate` usa via `text: display`.


## Limitações e oportunidades de evolução

- `CSVController.setAttributeType(...)` é um placeholder: ainda não armazena alterações manuais feitas na UI. Evolução: manter um dicionário de escolhas do usuário e aplicá-las em `saveMetadata()`.
- Validação de ARFF: hoje confiamos no `liac-arff`. Poderíamos validar coerência entre tipos escolhidos e dados reais antes de salvar.
- Performance com bases grandes: o uso de `DataFrame.copy()` no `DataFrameModel` é simples e seguro, mas pode custar memória. Evolução: evitar cópias quando possível.
- Internacionalização: strings estão em português. Qt oferece `qsTr()` e ferramentas para i18n.


## Execução e dependências

- Instalação: `pip install -r requirements.txt`
- Execução: `python main.py`
- Dependências principais:
  - PySide6: ponte Qt↔Python (UI e integração QML)
  - pandas: leitura e manipulação de CSV
  - liac-arff: leitura/gravação de ARFF
  - scipy (no requirements): opcional aqui, mas útil em cenários científicos


## Apêndice – Conceitos ARFF em 2 minutos

- ARFF (Attribute-Relation File Format) é um formato textual usado por ferramentas como o Weka.
- Estrutura típica:
  - `@RELATION nome` (nome da base)
  - `@ATTRIBUTE coluna TIPO` (por coluna; TIPOS: `NUMERIC`, `REAL`, `INTEGER`, `STRING`, `DATE` ou lista de valores para nominal)
  - `@DATA` seguido das linhas com valores, na mesma ordem dos atributos.
- Em nominais, os valores são um conjunto fechado: `@ATTRIBUTE classe {sim,nao}`.
- Nosso código mapeia tipos em português para ARFF na hora de salvar e deriva valores únicos para atributos nominais quando necessário.
