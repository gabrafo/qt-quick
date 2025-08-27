import os
from typing import Optional, List

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
    successOccurred = Signal(str)
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
    
    # Métodos para compatibilidade com ARFF
    @Slot(result=list)
    def getAttributeNames(self) -> List[str]:
        """Retorna lista de nomes das colunas (para compatibilidade com ARFF)."""
        if self._df is None:
            return []
        return list(self._df.columns)
    
    @Slot(str, result=str) 
    def getSuggestedType(self, attribute_name: str) -> str:
        """Sugere tipo ARFF baseado no tipo de dados do pandas."""
        if self._df is None or attribute_name not in self._df.columns:
            return "Textual"
        
        dtype = self._df[attribute_name].dtype
        if pd.api.types.is_numeric_dtype(dtype):
            return "Numérico"
        elif pd.api.types.is_datetime64_any_dtype(dtype):
            return "Data"
        else:
            # Verifica se parece com dados nominais (poucos valores únicos)
            unique_count = self._df[attribute_name].nunique()
            total_count = len(self._df[attribute_name])
            if unique_count <= 10 and unique_count / total_count < 0.1:
                return "Nominal"
            return "Textual"
    
    @Slot(str, result=list)
    def getAttributeExamples(self, attribute_name: str) -> List[str]:
        """Retorna os primeiros 5 exemplos de uma coluna."""
        if self._df is None or attribute_name not in self._df.columns:
            return []
        
        examples: List[str] = []
        series = self._df[attribute_name].head(5)
        for value in series:
            text = "" if pd.isna(value) else str(value)
            if len(text) > 30:
                text = text[:27] + "..."
            examples.append(text)
        return examples
    
    @Property(list, constant=True)
    def availableTypes(self) -> List[str]:
        """Tipos disponíveis para seleção no dropdown."""
        return ['Numérico', 'Textual', 'Nominal', 'Data', 'Relacional']
    
    @Slot(str, str)
    def setAttributeType(self, attribute_name: str, new_type: str) -> None:
        """Define um novo tipo para um atributo (armazenado internamente)."""
        # Para CSV, só armazenamos a informação para eventual conversão
        pass
    
    @Slot(str)
    def generateArff(self, output_path: str) -> None:
        """Gera arquivo ARFF a partir dos dados CSV."""
        try:
            if self._df is None:
                self.errorOccurred.emit("Nenhum dado carregado para gerar ARFF")
                return
            
            # Para simplificar, vamos gerar com tipos básicos
            import arff
            
            # Constrói atributos
            attributes = []
            for col in self._df.columns:
                dtype = self._df[col].dtype
                if pd.api.types.is_numeric_dtype(dtype):
                    attributes.append((col, 'NUMERIC'))
                else:
                    attributes.append((col, 'STRING'))
            
            # Converte dados
            data = []
            for _, row in self._df.iterrows():
                data_row = []
                for col in self._df.columns:
                    value = row[col]
                    if pd.isna(value):
                        data_row.append(None)
                    else:
                        data_row.append(value)
                data.append(data_row)
            
            # Dataset ARFF
            dataset = {
                'relation': self._file_name.replace('.csv', ''),
                'attributes': attributes,
                'data': data
            }
            
            # Salva arquivo
            with open(output_path, 'w', encoding='utf-8') as f:
                arff.dump(dataset, f)
            
            self.successOccurred.emit(f"Arquivo ARFF salvo com sucesso em: {output_path}")
            
        except Exception as e:
            self.errorOccurred.emit(f"Erro ao gerar arquivo ARFF: {e}")

    @Slot(str)
    def saveMetadata(self, output_path: str) -> None:
        """Salva metadados + dados do CSV em formato ARFF (compatível Weka)."""
        try:
            if self._df is None:
                self.errorOccurred.emit("Nenhum dado carregado para salvar metadados")
                return

            import arff

            attributes = []
            for col in self._df.columns:
                suggested = self.getSuggestedType(col)
                if suggested == 'Numérico':
                    attributes.append((col, 'NUMERIC'))
                elif suggested == 'Data':
                    attributes.append((col, 'DATE'))
                elif suggested == 'Nominal':
                    uniques = list(set(str(v) for v in self._df[col].dropna().unique().tolist()))[:50]
                    attributes.append((col, uniques if uniques else 'STRING'))
                else:
                    attributes.append((col, 'STRING'))

            # Converte os dados do DataFrame para lista de listas
            data = []
            for _, row in self._df.iterrows():
                row_list = []
                for col in self._df.columns:
                    v = row[col]
                    row_list.append(None if pd.isna(v) else v)
                data.append(row_list)

            dataset = {
                'relation': self._file_name.replace('.csv', '') or 'dataset',
                'attributes': attributes,
                'data': data
            }

            with open(output_path, 'w', encoding='utf-8') as f:
                arff.dump(dataset, f)

            self.successOccurred.emit(f"Arquivo ARFF salvo em: {output_path}")
        except Exception as e:
            self.errorOccurred.emit(f"Erro ao salvar metadados: {e}")