import os
from typing import Optional

import pandas as pd
from PySide6.QtCore import QObject, Signal, Slot, QUrl, Property
from table_model import DataFrameModel


class CSVController(QObject):
    """Backend simples para carregar CSV em um DataFrame e expor para QML.

    Regras KISS:
    - Expõe apenas sinais e propriedades necessárias para a tela 1.
    - Usa pandas para leitura do arquivo CSV.
    - Evita acoplamento: QML solicita ações via Slot; atualizações são notificadas por Signal.
    """

    dataframeChanged = Signal()
    fileNameChanged = Signal()
    errorOccurred = Signal(str)
    infoChanged = Signal()

    def __init__(self) -> None:
        super().__init__()
        self._df: Optional[pd.DataFrame] = None
        self._file_name: str = ""
        # Model baseado em QAbstractTableModel para ser usado no QML
        self._model = DataFrameModel()

    @Property(str, notify=fileNameChanged)
    def fileName(self) -> str:
        return self._file_name

    @Property(str, notify=infoChanged)
    def info(self) -> str:
        if self._df is None:
            return "Nenhum dado carregado"
        rows, cols = self._df.shape
        return f"Linhas: {rows} | Colunas: {cols}"

    @Property(QObject, constant=True)
    def tableModel(self) -> QObject:
        """Exposto ao QML para `model: controller.tableModel`."""
        return self._model

    @Slot(QUrl)
    def loadCsv(self, file_url: QUrl) -> None:
        """Recebe um QUrl do QML, carrega CSV com pandas e notifica a UI."""
        try:
            if file_url.scheme() == "file":
                file_path = file_url.toLocalFile()
            else:
                file_path = file_url.toString()

            self._file_name = os.path.basename(file_path)
            self.fileNameChanged.emit()

            self._df = pd.read_csv(file_path)
            # Atualiza o QAbstractTableModel (a view QML se atualiza automaticamente)
            self._model.setDataFrame(self._df)
            self.dataframeChanged.emit()
            self.infoChanged.emit()
        except Exception as e: 
            self._df = None
            self.dataframeChanged.emit()
            self.infoChanged.emit()
            self.errorOccurred.emit(f"Erro ao carregar CSV: {e}")

    # API para a TableView em QML
    @Slot(result=int)
    def rowCount(self) -> int:
        return 0 if self._df is None else int(self._df.shape[0])

    @Slot(result=int)
    def columnCount(self) -> int:
        return 0 if self._df is None else int(self._df.shape[1])

    @Slot(int, result=str)
    def headerForColumn(self, column: int) -> str:
        if self._df is None:
            return ""
        if column < 0 or column >= self._df.shape[1]:
            return ""
        return str(self._df.columns[column])

    @Slot(int, int, result=str)
    def dataAt(self, row: int, column: int) -> str:
        if self._df is None:
            return ""
        if row < 0 or column < 0:
            return ""
        if row >= self._df.shape[0] or column >= self._df.shape[1]:
            return ""
        value = self._df.iat[row, column]
        return "" if pd.isna(value) else str(value)
