import os
from typing import Optional, List, Dict, Any, Tuple
import pandas as pd
from PySide6.QtCore import QObject, Signal, Slot, QUrl, Property
import arff
from table_model import DataFrameModel

class ARFFController(QObject):
    """Controlador para manipulação de arquivos ARFF.
    
    Este controlador oferece funcionalidades para:
    - Carregar arquivos ARFF existentes
    - Extrair metadados (nomes de atributos, tipos, etc.)
    - Sugerir tipos de atributos baseados nos dados
    - Gerar novos arquivos ARFF
    """
    
    # Sinais para comunicação com o QML
    dataLoaded = Signal()
    fileNameChanged = Signal()
    errorOccurred = Signal(str)
    successOccurred = Signal(str)
    metadataChanged = Signal()
    
    def __init__(self) -> None:
        super().__init__()
        self._data: Optional[List[List[Any]]] = None
        self._attributes: List[Tuple[str, Any]] = []
        self._relation_name: str = ""
        self._file_name: str = ""
        self._suggested_types: Dict[str, str] = {}
        self._dataframe: Optional[pd.DataFrame] = None
        self._table_model: Optional[DataFrameModel] = None
        
        # Mapeamento de tipos ARFF para português
        self._type_translations = {
            'NUMERIC': 'Numérico',
            'STRING': 'Textual',
            'REAL': 'Numérico',
            'INTEGER': 'Numérico',
            'DATE': 'Data',
            'NOMINAL': 'Nominal'
        }
        
        # Tipos disponíveis em português para o dropdown
        self._available_types = [
            'Numérico',
            'Textual', 
            'Nominal',
            'Data',
            'Relacional'
        ]
    
    @Property('QVariant', notify=dataLoaded)
    def tableModel(self):
        """Retorna o modelo da tabela para exibição no QML."""
        return self._table_model
    
    @Property(int, notify=dataLoaded)
    def instanceCount(self):
        """Retorna o número de instâncias (linhas) dos dados."""
        return len(self._data) if self._data else 0
    
    @Property(int, notify=dataLoaded)
    def attributeCount(self):
        """Retorna o número de atributos (colunas) dos dados."""
        return len(self._attributes) if self._attributes else 0
    
    @Property(str, notify=fileNameChanged)
    def fileName(self) -> str:
        """Nome do arquivo carregado."""
        return self._file_name
    
    @Property(str, notify=metadataChanged)
    def relationName(self) -> str:
        """Nome da relação/base de dados."""
        return self._relation_name
    
    @Property(int, notify=dataLoaded)
    def instanceCount(self) -> int:
        """Total de instâncias (linhas)."""
        return len(self._data) if self._data else 0
    
    @Property(int, notify=dataLoaded)
    def attributeCount(self) -> int:
        """Total de atributos (colunas)."""
        return len(self._attributes)
    
    @Property(list, notify=metadataChanged)
    def availableTypes(self) -> List[str]:
        """Tipos disponíveis para seleção no dropdown."""
        return self._available_types
    
    @Slot(QUrl)
    def loadArff(self, file_url: QUrl) -> None:
        """Carrega um arquivo ARFF."""
        try:
            if file_url.scheme() == "file":
                file_path = file_url.toLocalFile()
            else:
                file_path = file_url.toString()
            
            self._file_name = os.path.basename(file_path)
            self.fileNameChanged.emit()
            
            # Carrega o arquivo ARFF
            with open(file_path, 'r', encoding='utf-8') as f:
                dataset = arff.load(f)
            
            # Extrai metadados
            self._relation_name = dataset['relation']
            self._attributes = dataset['attributes']
            # Certifique-se de que os dados são list de lists
            raw_data = dataset.get('data', [])
            if not raw_data:
                self._data = []
            else:
                # Converte cada linha para list explicitamente
                try:
                    self._data = [list(row) if hasattr(row, '__iter__') and not isinstance(row, str) else [row] for row in raw_data]
                    print(f"DEBUG: Dados carregados: {len(self._data)} linhas")
                except Exception as e:
                    print(f"ERRO ao processar linhas: {e}")
                    self._data = []
            
            # Gera sugestões de tipos baseadas nos metadados
            self._generateTypeSuggestions()
            
            # Cria DataFrame para compatibilidade com a interface
            self._createDataFrame()
            
            self.dataLoaded.emit()
            self.metadataChanged.emit()
            
        except Exception as e:
            self._data = None
            self._attributes = []
            self._relation_name = ""
            self.errorOccurred.emit(f"Erro ao carregar arquivo ARFF: {e}")
    
    def _generateTypeSuggestions(self) -> None:
        """Gera sugestões de tipos baseadas nos metadados do ARFF."""
        self._suggested_types = {}
        
        for attr_name, attr_type in self._attributes:

            # attr_type pode vir como string ('NUMERIC', 'STRING', 'DATE') ou lista (nominal)
            if isinstance(attr_type, str):
                attr_type_upper = attr_type.upper().strip()
                print(f"DEBUG: Tipo normalizado: '{attr_type_upper}'")
                
                # Mapeia exatamente conforme ARFF Weka
                if 'STRING' in attr_type_upper:
                    self._suggested_types[attr_name] = 'Textual'
                    print(f"DEBUG: Mapeado como Textual")
                elif any(t in attr_type_upper for t in ('NUMERIC', 'REAL', 'INTEGER')):
                    self._suggested_types[attr_name] = 'Numérico'
                    print(f"DEBUG: Mapeado como Numérico")
                elif 'DATE' in attr_type_upper:
                    self._suggested_types[attr_name] = 'Data'
                    print(f"DEBUG: Mapeado como Data")
                else:
                    # Fallback para texto se não reconhecer
                    self._suggested_types[attr_name] = 'Textual'
                    print(f"DEBUG: Mapeado como Textual (fallback)")
            elif isinstance(attr_type, (list, tuple)):
                self._suggested_types[attr_name] = 'Nominal'
            else:
                self._suggested_types[attr_name] = 'Textual'
        
        print(f"DEBUG: _generateTypeSuggestions finalizado. Tipos finais: {self._suggested_types}")
    
    def _createDataFrame(self) -> None:
        """Cria um DataFrame pandas a partir dos dados ARFF para exibição na interface."""
        try:
            if not self._data or not self._attributes:
                self._dataframe = None
                self._table_model = None
                return
            
            # Extrai nomes das colunas dos atributos
            column_names = [attr[0] for attr in self._attributes]
            
            # Cria DataFrame
            self._dataframe = pd.DataFrame(self._data, columns=column_names)
            
            # Cria o modelo da tabela
            self._table_model = DataFrameModel(self._dataframe)
            
            print(f"DEBUG: DataFrame criado com {len(self._dataframe)} linhas e {len(self._dataframe.columns)} colunas")
            print(f"DEBUG: Colunas: {list(self._dataframe.columns)}")
            
        except Exception as e:
            print(f"ERRO ao criar DataFrame: {e}")
            self._dataframe = None
            self._table_model = None
    
    @Slot(str, result=str)
    def getSuggestedType(self, attribute_name: str) -> str:
        """Retorna o tipo sugerido para um atributo."""
        suggested = self._suggested_types.get(attribute_name, 'Textual')
        print(f"DEBUG: getSuggestedType('{attribute_name}') consultando tipos: {self._suggested_types}")
        print(f"DEBUG: getSuggestedType('{attribute_name}') retornando: '{suggested}'")
        return suggested
    
    @Slot(str, result=list)
    def getAttributeExamples(self, attribute_name: str) -> List[str]:
        """Retorna os primeiros 5 exemplos de um atributo."""
        if not self._data or not self._attributes:
            return []
        
        # Encontra o índice do atributo
        attr_index = None
        for i, (name, _) in enumerate(self._attributes):
            if name == attribute_name:
                attr_index = i
                break
        
        if attr_index is None:
            return []
        
        # Coleta os primeiros 5 exemplos
        examples = []
        for i, row in enumerate(self._data[:5]):
            if attr_index < len(row):
                value = row[attr_index]
                text = "" if value is None else str(value)
                # Limita tamanho para evitar overflow visual
                if len(text) > 30:
                    text = text[:27] + "..."
                examples.append(text)
        
        return examples
    
    @Slot(result=list)
    def getAttributeNames(self) -> List[str]:
        """Retorna a lista de nomes dos atributos."""
        names = [name for name, _ in self._attributes]
        print(f"DEBUG: getAttributeNames() retornando: {names}")
        return names
    
    @Slot(str, str)
    def setAttributeType(self, attribute_name: str, new_type: str) -> None:
        """Define um novo tipo para um atributo."""
        print(f"DEBUG: setAttributeType('{attribute_name}', '{new_type}') chamado")
        print(f"DEBUG: _suggested_types antes: {self._suggested_types}")
        self._suggested_types[attribute_name] = new_type
        print(f"DEBUG: _suggested_types depois: {self._suggested_types}")
    
    @Slot(str)
    def generateArff(self, output_path: str) -> None:
        """Gera um novo arquivo ARFF com os tipos selecionados."""
        try:
            if not self._data or not self._attributes:
                self.errorOccurred.emit("Nenhum dado carregado para gerar ARFF")
                return
            
            # Mapeia tipos em português de volta para ARFF
            reverse_mapping = {
                'Numérico': 'NUMERIC',
                'Textual': 'STRING',
                'Nominal': lambda values: list(set(str(v) for v in values if v is not None)),
                'Data': 'DATE',
                'Relacional': 'STRING'
            }
            
            # Constrói novos atributos com tipos atualizados
            new_attributes = []
            for i, (attr_name, _) in enumerate(self._attributes):
                selected_type = self._suggested_types.get(attr_name, 'Textual')
                
                if selected_type == 'Nominal':
                    # Para nominal, precisamos extrair valores únicos da coluna
                    column_values = [row[i] for row in self._data if i < len(row)]
                    unique_values = list(set(str(v) for v in column_values if v is not None))
                    new_attributes.append((attr_name, unique_values))
                else:
                    arff_type = reverse_mapping.get(selected_type, 'STRING')
                    new_attributes.append((attr_name, arff_type))
            
            # Cria o dataset ARFF
            dataset = {
                'relation': self._relation_name,
                'attributes': new_attributes,
                'data': self._data
            }
            
            # Salva o arquivo
            with open(output_path, 'w', encoding='utf-8') as f:
                arff.dump(dataset, f)
            
            self.successOccurred.emit(f"Arquivo ARFF salvo com sucesso em: {output_path}")
            
        except Exception as e:
            self.errorOccurred.emit(f"Erro ao gerar arquivo ARFF: {e}")

    @Slot(str)
    def saveMetadata(self, output_path: str) -> None:
        """Salva metadados + dados em formato ARFF, seguindo o padrão Weka ARFF.

        Observação: o nome do método permanece 'saveMetadata' porque a ação
        é guiada pela definição dos tipos na UI, mas persistimos também os dados.
        """
        try:
            if not self._attributes:
                self.errorOccurred.emit("Não há metadados carregados")
                return

            # Reaproveita a lógica de mapeamento de tipos escolhidos
            new_attributes = []
            for i, (attr_name, _) in enumerate(self._attributes):
                selected_type = self._suggested_types.get(attr_name, 'Textual')
                if selected_type == 'Nominal' and self._data:
                    # Protege contra linhas com menos colunas do que o cabeçalho
                    column_values = []
                    for row in self._data:
                        if i < len(row):
                            column_values.append(row[i])
                    unique_values = list(set(str(v) for v in column_values if v is not None))
                    if len(unique_values) == 0:
                        unique_values = ['_']
                    new_attributes.append((attr_name, unique_values))
                else:
                    mapping = {
                        'Numérico': 'NUMERIC',
                        'Textual': 'STRING',
                        'Data': 'DATE',
                        'Relacional': 'STRING'
                    }
                    new_attributes.append((attr_name, mapping.get(selected_type, 'STRING')))

            # Salva arquivo completo (metadados + dados)
            dataset = {
                'relation': self._relation_name or 'dataset',
                'attributes': new_attributes,
                'data': self._data or []
            }
            with open(output_path, 'w', encoding='utf-8') as f:
                arff.dump(dataset, f)
            self.successOccurred.emit(f"Arquivo ARFF salvo com sucesso em: {output_path}")
        except Exception as e:
            self.errorOccurred.emit(f"Erro ao salvar metadados: {e}")
