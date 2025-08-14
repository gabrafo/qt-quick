# MIDAS – CSV Viewer (KISS)

Aplicativo desktop simples: abre um CSV, carrega em um DataFrame (pandas) e exibe em tabela com QML.

## Como executar

```bash
pip install -r requirements.txt
python main.py
```

## Visão rápida do fluxo

- Em `page1.qml`, o usuário clica em “ESCOLHER ARQUIVO CSV” → `FileDialog`.
- Ao aceitar, o QML chama `controller.loadCsv(selectedFile)`.
- O backend lê com pandas e emite `dataframeChanged`.
- `main.qml` navega para `page2_table.qml`, passando o mesmo `controller`.
- `page2_table.qml` consulta dados via Slots do backend para desenhar a tabela.

## API exposta ao QML (csv_controller.py)

- Propriedades:
  - `fileName: string` — nome do arquivo carregado
  - `info: string` — resumo (Linhas/Colunas)
- Sinais:
  - `dataframeChanged()`, `fileNameChanged()`, `infoChanged()`, `errorOccurred(message)`
- Slots:
  - `loadCsv(fileUrl: QUrl)`
  - `rowCount() -> int`
  - `columnCount() -> int`
  - `headerForColumn(col: int) -> str`
  - `dataAt(row: int, col: int) -> str`

## Dicas

- KISS: sem `QAbstractTableModel` por enquanto. O QML consulta célula/cabeçalho sob demanda.
- Para datasets grandes ou roles/edição, evolua para `QAbstractTableModel`.
