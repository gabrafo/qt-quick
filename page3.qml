import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15
import QtQuick.Dialogs

// Página 3 - Seleção de tipos (layout inspirado no protótipo)
Page {
    id: typePage
    property var csvController: null
    property var arffController: null
    property var stack: null
    property string fileType: "csv"
    
    property var activeController: fileType === "csv" ? csvController : arffController
    
    background: Rectangle {
        color: Material.backgroundColor
    }
    
    header: ToolBar {
        Material.primary: Material.BlueGrey
        
        RowLayout {
            anchors.fill: parent
            anchors.margins: 8
            
            Button {
                text: qsTr("Voltar")
                flat: true
                onClicked: {
                    if (typePage.stack) typePage.stack.pop()
                }
            }
            
            Label {
                text: qsTr("Selecionando tipos...")
                font.pointSize: 16
                font.weight: Font.Medium
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                color: Material.foreground
            }
        }
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 24
        
        // Painel esquerdo - Informações
        Rectangle {
            Layout.preferredWidth: 280
            Layout.fillHeight: true
            color: Material.backgroundColor
            border.color: Material.frameColor
            border.width: 1
            radius: 8
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 20
                
                // Aviso principal
                Rectangle {
                    id: typesCard
                    width: parent.width
                    height: Math.max(200, typesContent.implicitHeight + 24)
                    color: "transparent"
                    border.color: Material.accent
                    border.width: 2
                    radius: 8
                    
                    Column {
                        id: typesContent
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 10

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: qsTr("Atenção")
                            font.pointSize: 14
                            font.weight: Font.DemiBold
                            color: Material.accent
                        }
                        
                        Text {
                            text: qsTr("É hora de escolher!")
                            font.pointSize: 12
                            font.weight: Font.Bold
                            color: Material.foreground
                            width: parent.width
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                        
                        Text {
                            text: qsTr("Iremos sugerir uma tipificação para cada um dos atributos. Você pode alterá-los manualmente.")
                            font.pointSize: 9
                            color: Material.foreground
                            width: parent.width
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                        
                        Text {
                            text: qsTr("OBS: Isso só poderá ser feito agora.")
                            font.pointSize: 9
                            font.weight: Font.Bold
                            color: Material.accent
                            width: parent.width
                            wrapMode: Text.WordWrap
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
                
                // Seção de tipos
                Rectangle {
                    width: parent.width
                    height: 220
                    color: Material.backgroundColor
                    border.color: Material.frameColor
                    border.width: 1
                    radius: 8
                    
                    Column {
                        anchors.fill: parent
                        anchors.margins: 16
                        spacing: 10
                        
                        Row {
                            spacing: 8
                            Text {
                                text: qsTr("Tipos")
                                font.pointSize: 14
                                font.weight: Font.Medium
                                color: Material.foreground
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        
                        Text {
                            text: qsTr("Nominal: Valores predefinidos.")
                            font.pointSize: 9
                            color: Material.foreground
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            text: qsTr("Numérico: Valores contínuos.")
                            font.pointSize: 9
                            color: Material.foreground
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            text: qsTr("Textual: Valores em formato de texto.")
                            font.pointSize: 9
                            color: Material.foreground
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            text: qsTr("Data: Valores em formato de data.")
                            font.pointSize: 9
                            color: Material.foreground
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            text: qsTr("Relacional: Valores contêm outros atributos.")
                            font.pointSize: 9
                            color: Material.foreground
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
        
        // Painel principal - Lista de atributos
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Material.backgroundColor
            border.color: Material.frameColor
            border.width: 1
            radius: 8
            
            Column {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 16
                
                Text {
                    id: headerTitle
                    text: qsTr("Selecionando os tipos...")
                    font.pointSize: 20
                    font.weight: Font.Medium
                    color: Material.foreground
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                ScrollView {
                    width: parent.width
                    height: parent.height - headerTitle.implicitHeight - footerBar.height - 40
                    clip: true
                    
                    Column {
                        width: parent.width
                        spacing: 16
                        
                        Repeater {
                            id: attributeRepeater
                            model: {
                                if (activeController) {
                                    var names = activeController.getAttributeNames()
                                    return names ? names.length : 0
                                }
                                return 0
                            }
                            
                            delegate: Rectangle {
                                width: parent.width - 40
                                height: attributeColumn.implicitHeight + 24
                                color: Material.backgroundColor
                                border.color: Material.frameColor
                                border.width: 1
                                radius: 6
                                anchors.horizontalCenter: parent.horizontalCenter
                                
                                property string attrName: {
                                    if (activeController) {
                                        var names = activeController.getAttributeNames()
                                        return names && index < names.length ? names[index] : ""
                                    }
                                    return ""
                                }
                                
                                Column {
                                    id: attributeColumn
                                    anchors.fill: parent
                                    anchors.margins: 16
                                    spacing: 10
                                    
                                    // Nome da coluna
                                    Text {
                                        text: qsTr("Coluna ") + (index + 1) + ":  " + attrName
                                        font.pointSize: 14
                                        font.weight: Font.Medium
                                        color: Material.foreground
                                        width: parent.width
                                        wrapMode: Text.WordWrap
                                        elide: Text.ElideRight
                                    }
                                    
                                    // Linha dropdown de tipos
                                    RowLayout {
                                        spacing: 12
                                        
                                        Text {
                                            text: qsTr("Tipo sugerido")
                                            font.pointSize: 11
                                            color: Material.foreground
                                            opacity: 0.8
                                            Layout.alignment: Qt.AlignVCenter
                                        }

                                        ComboBox {
                                            id: typeCombo
                                            Layout.fillWidth: true
                                            height: 34
                                            model: ["Numérico", "Textual", "Nominal", "Data", "Relacional"]
                                            
                                            property bool initialized: false

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
                                        }
                                    }
                                    
                                    // Exemplos (lado a lado)
                                    Row {
                                        width: parent.width
                                        spacing: 8
                                        
                                        Repeater {
                                            model: {
                                                if (activeController && attrName) {
                                                    var examples = activeController.getAttributeExamples(attrName)
                                                    return examples ? Math.min(examples.length, 5) : 0
                                                }
                                                return 0
                                            }
                                            
                                            delegate: Rectangle {
                                                width: Math.min(exText.implicitWidth + 14, 120)
                                                height: 26
                                                color: Qt.darker(Material.backgroundColor, 1.2)
                                                border.color: Material.frameColor
                                                border.width: 1
                                                radius: 3
                                                
                                                Text {
                                                    id: exText
                                                    anchors.centerIn: parent
                                                    text: {
                                                        if (activeController && attrName) {
                                                            var examples = activeController.getAttributeExamples(attrName)
                                                            return examples && index < examples.length ? examples[index] : ""
                                                        }
                                                        return ""
                                                    }
                                                    font.pointSize: 9
                                                    color: Material.foreground
                                                    elide: Text.ElideRight
                                                    width: parent.width - 8
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                // Footer fixo com botão Salvar
                Rectangle {
                    id: footerBar
                    width: parent.width
                    height: 56
                    color: Material.backgroundColor
                    border.color: Material.frameColor
                    border.width: 1

                    Button {
                        id: saveBtn
                        text: qsTr("Salvar")
                        Material.background: Material.accent
                        Material.foreground: "#000000"
                        font.weight: Font.Medium
                        width: 200
                        height: 40
                        anchors.centerIn: parent
                        onClicked: {
                            if (activeController && activeController.saveMetadata) {
                                saveFileDialog.open()
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Dialog para salvar
    FileDialog {
        id: saveFileDialog
        title: qsTr("Salvar ARFF")
        fileMode: FileDialog.SaveFile
        nameFilters: ["Arquivos ARFF (*.arff)", "Todos os arquivos (*)"]
        defaultSuffix: "arff"
        
        onAccepted: {
            if (activeController) {
                var path = selectedFile.toString()
                if (path.startsWith("file://")) {
                    path = path.substring(7)
                }
                if (activeController.saveMetadata) {
                    activeController.saveMetadata(path)
                }
            }
        }
    }
    
    // Dialog para mensagens
    MessageDialog {
        id: messageDialog
        title: "Informação"
        text: ""
        buttons: MessageDialog.Ok
    }
    
    // Para indicar status de sucesso/erro nas operações
    Connections {
        target: activeController
        function onErrorOccurred(message) {
            messageDialog.title = "Erro"
            messageDialog.text = message
            messageDialog.open()
        }
        
        function onSuccessOccurred(message) {
            messageDialog.title = "Sucesso"
            messageDialog.text = message
            messageDialog.open()
        }
        
        function onMetadataChanged() {
            console.log("QML: Metadata changed, forçando atualização do Repeater")
            // Força o Repeater a se atualizar
            attributeRepeater.model = 0
            attributeRepeater.model = Qt.binding(function() {
                if (activeController) {
                    var names = activeController.getAttributeNames()
                    return names ? names.length : 0
                }
                return 0
            })
        }
    }
}