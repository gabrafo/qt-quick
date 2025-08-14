# QAbstractTableModel (guia rápido e didático)

## O que é
Classe base do Qt para representar dados tabulares para Views (ex.: TableView). Ela abstrai o acesso aos dados (linhas/colunas/células) e notifica a UI quando algo muda.

- Documentação Qt6: https://doc.qt.io/qt-6/qabstracttablemodel.html
- Model/View no Qt: https://doc.qt.io/qt-6/model-view-programming.html
- QML TableView: https://doc.qt.io/qt-6/qml-qtquick-tableview.html

## Por que usar
- Escala bem com muitos dados
- Atualizações reativas (sinais beginResetModel/endResetModel/dataChanged)
- Suporte a cabeçalhos, edição, ordenação/filtragem com proxys
- Desacopla UI dos dados (MVC/MVVM)

## Ciclo básico
Implemente no seu model:
- `rowCount()` e `columnCount()`
- `data(index, role)` para o conteúdo da célula (geralmente `Qt.DisplayRole`)
- `headerData(section, orientation, role)` para nomes de colunas/linhas

Atualize a UI notificando:
- `beginResetModel()` / `endResetModel()` quando trocar todo o dataset
- `dataChanged()` quando alterar um intervalo pequeno

## Exemplo usado aqui (resumo)
Python (PySide6):
```python
class DataFrameModel(QAbstractTableModel):
    def __init__(self, dataframe=None):
        super().__init__()
        self._df = dataframe.copy() if dataframe is not None else pd.DataFrame()

    def setDataFrame(self, dataframe):
        self.beginResetModel()
        self._df = dataframe.copy()
        self.endResetModel()

    def rowCount(self, parent=QModelIndex()):
        return int(self._df.shape[0])

    def columnCount(self, parent=QModelIndex()):
        return int(self._df.shape[1])

    def data(self, index, role=Qt.DisplayRole):
        if not index.isValid() or role != Qt.DisplayRole:
            return None
        value = self._df.iat[index.row(), index.column()]
        return "" if pd.isna(value) else str(value)

    def headerData(self, section, orientation, role=Qt.DisplayRole):
        if role != Qt.DisplayRole:
            return None
        if orientation == Qt.Horizontal:
            return str(self._df.columns[section])
        return str(section + 1)
```

QML (TableView consumindo o model):
```qml
TableView {
  anchors.fill: parent
  model: controller.tableModel // vindo do backend
  delegate: Rectangle {
    implicitWidth: 120; implicitHeight: 28
    color: (row % 2 === 0) ? "#1E1E1E" : "#181818"
    Text { anchors.centerIn: parent; text: display }
  }
}
```

## Boas práticas
- Não manipule dados no QML; mantenha no model/backend
- Para datasets enormes: considere paginação/filtros/proxys
- Se for editar células: implemente `setData()` e `flags()` no model
- Exponha apenas o necessário ao QML (KISS)

