# Arquitetura (KISS)

Objetivo: abrir CSV, armazenar em DataFrame (pandas) e exibir na UI, com poucas peças e responsabilidades claras.

## Camadas

- View (QML)
  - `main.qml`: janela e StackView; injeta o backend.
  - `page1.qml`: aparência da página inicial; escolhe o arquivo; dispara leitura.
  - `page2_table.qml`: aparência da tabela; consulta dados via Slots.
- Backend (Python)
  - `csv_controller.py`: carrega CSV (pandas) e expõe API mínima ao QML.
- Ligador
  - `main.py`: registra o backend para o QML e carrega `main.qml`.

## Fluxo

1. page1: usuário clica no botão; abre `FileDialog`.
2. `CSVController.loadCsv(QUrl)` lê o CSV e atualiza estado interno (DataFrame).
3. Backend emite `dataframeChanged`; `main.qml` navega para `page2_table`.
4. page2: tabela consulta `rowCount`, `columnCount`, `headerForColumn`, `dataAt`.

## Decisões

- Sem `QAbstractTableModel` inicialmente para manter KISS.
- API mínima para consulta célula-a-célula.
- StackView já preparado para futuras páginas.

