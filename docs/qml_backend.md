# QML ↔ Backend (PySide6)

## Registro de tipos

`main.py` registra o backend no namespace `App 1.0`:

```python
qmlRegisterType(CSVController, "App", 1, 0, "CSVController")
```

No QML:

```qml
import App 1.0
CSVController { id: controller }
```

## Comunicação

- Properties: dados observáveis
  - `fileName: string`, `info: string`
- Signals: eventos emitidos pelo backend
  - `dataframeChanged()`, `fileNameChanged()`, `infoChanged()`, `errorOccurred(message)`
- Slots: funções chamáveis pelo QML
  - `loadCsv(fileUrl: QUrl)`, `rowCount()`, `columnCount()`, `headerForColumn(col)`, `dataAt(row, col)`

## Exemplo – abrir arquivo

```qml
FileDialog {
  onAccepted: controller.loadCsv(selectedFile)
}
```

## Exemplo – reagir a sinais

```qml
Connections {
  target: controller
  function onDataframeChanged() {
    // navegar, atualizar, etc.
  }
}
```

