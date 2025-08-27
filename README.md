# MIDAS - Sistema de Manipulação de Dados Tabulares

## Visão Geral

O MIDAS é uma aplicação Qt Quick que permite carregar, visualizar e converter dados entre formatos CSV e ARFF. O sistema oferece uma interface moderna baseada no Material Design da Google, permitindo ao usuário selecionar tipos de atributos e gerar arquivos ARFF personalizados.

## Características Principais

- **Interface Material Design**: Interface moderna e minimalista
- **Suporte a múltiplos formatos**: CSV e ARFF
- **Visualização de dados**: Tabela interativa com dados carregados
- **Seleção de tipos**: Interface intuitiva para configurar tipos de atributos ARFF
- **Geração de ARFF**: Criação de novos arquivos ARFF com tipos personalizados
- **Sugestões automáticas**: Tipos sugeridos baseados nos dados originais

## Instalação

### Pré-requisitos

- Python 3.8 ou superior
- Qt 6.0 ou superior

### Dependências

```bash
pip install -r requirements.txt
```

As dependências incluem:
- PySide6: Interface Qt para Python
- pandas: Manipulação de dados CSV
- scipy: Suporte científico
- liac-arff: Manipulação de arquivos ARFF

## Como Usar

### 1. Executar a Aplicação

```bash
python main.py
```

### 2. Fluxo de Uso

#### Página 1 - Carregamento
- Clique em "CARREGAR ARQUIVO CSV" para arquivos CSV
- Clique em "CARREGAR ARQUIVO ARFF" para arquivos ARFF existentes
- O sistema automaticamente navega para a próxima página

#### Página 2 - Visualização
- Visualize os dados carregados na tabela à esquerda
- Confira estatísticas da base (instâncias e atributos) à direita
- Clique em "Avançar" para configurar tipos de dados

#### Página 3 - Configuração de Tipos
- Revise os tipos sugeridos para cada atributo
- Modifique tipos usando os dropdowns disponíveis
- Visualize exemplos de cada atributo
- Clique em "Gerar ARFF" para salvar o arquivo final

### 3. Tipos de Dados Disponíveis

- **Numérico**: Valores contínuos ou discretos
- **Textual**: Strings livres
- **Nominal**: Conjunto predefinido de valores
- **Data**: Valores de data/tempo
- **Relacional**: Atributos que contêm outros atributos

## Arquivos de Exemplo

O projeto inclui arquivos de exemplo:
- `teste.csv`: Dados em formato CSV
- `exemplo.arff`: Dados em formato ARFF (complexo)
- `teste_simples.arff`: Dados ARFF simples para testes

## Estrutura do Projeto

```
qt-quick/
├── main.py              # Ponto de entrada da aplicação
├── main.qml             # Interface principal
├── page1.qml            # Página de carregamento
├── page2.qml            # Página de visualização
├── page3.qml            # Página de configuração de tipos
├── csv_controller.py    # Controlador para arquivos CSV
├── arff_controller.py   # Controlador para arquivos ARFF
├── table_model.py       # Modelo de dados para tabelas
├── requirements.txt     # Dependências Python
├── docs/                # Documentação detalhada
│   └── SISTEMA_COMPLETO.md
├── teste.csv            # Arquivo CSV de exemplo
└── exemplo.arff         # Arquivo ARFF de exemplo
```

## Documentação Técnica

Para informações detalhadas sobre a arquitetura, fluxo de execução e componentes do sistema, consulte:
- `docs/SISTEMA_COMPLETO.md`: Documentação técnica completa

## Tecnologias Utilizadas

- **Frontend**: Qt Quick (QML) com Material Design
- **Backend**: Python com PySide6
- **Manipulação de dados**: pandas, liac-arff
- **Interface**: Material Design Components

## Desenvolvimento

O sistema foi desenvolvido seguindo princípios de arquitetura limpa:
- Separação clara entre frontend (QML) e backend (Python)
- Comunicação via sinais/slots do Qt
- Controladores especializados para cada formato
- Interface responsiva e moderna

Para mais detalhes sobre o desenvolvimento e arquitetura, consulte a documentação técnica completa.