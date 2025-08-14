from __future__ import annotations

import pandas as pd
from PySide6.QtCore import QAbstractTableModel, Qt, QModelIndex


class DataFrameModel(QAbstractTableModel):
    """QAbstractTableModel simples baseado em pandas.DataFrame.

    - Exposto ao QML como um model de tabela.
    - Usa o papel "display" para exibir células (Qt.DisplayRole).
    - Atualizações usam beginResetModel()/endResetModel() para manter KISS.
    """

    def __init__(self, dataframe: pd.DataFrame | None = None) -> None:
        super().__init__()
        self._df: pd.DataFrame = dataframe.copy() if dataframe is not None else pd.DataFrame()

    # API de configuração
    def setDataFrame(self, dataframe: pd.DataFrame) -> None:
        self.beginResetModel()
        self._df = dataframe.copy()
        self.endResetModel()

    # Tamanho
    def rowCount(self, parent: QModelIndex = QModelIndex()) -> int:  # type: ignore[override]
        return int(self._df.shape[0])

    def columnCount(self, parent: QModelIndex = QModelIndex()) -> int:  # type: ignore[override]
        return int(self._df.shape[1])

    # Dados por célula
    def data(self, index: QModelIndex, role: int = Qt.DisplayRole):  # type: ignore[override]
        if not index.isValid() or role != Qt.DisplayRole:
            return None
        value = self._df.iat[index.row(), index.column()]
        if pd.isna(value):
            return ""
        return str(value)

    # Cabeçalhos
    def headerData(self, section: int, orientation: Qt.Orientation, role: int = Qt.DisplayRole):  # type: ignore[override]
        if role != Qt.DisplayRole:
            return None
        if orientation == Qt.Horizontal:
            if 0 <= section < self._df.shape[1]:
                return str(self._df.columns[section])
            return ""
        # Linhas: 1..N
        return str(section + 1)

    # Nome do papel para o QML ("display")
    def roleNames(self):  # type: ignore[override]
        return {Qt.DisplayRole: b"display"}
