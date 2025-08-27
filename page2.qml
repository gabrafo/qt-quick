import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Layouts 1.15

// Página 2 - Visualização dos dados (Versão Simplificada)
Page {
    id: dataPage
    property var csvController: null
    property var arffController: null
    property var stack: null
    property string fileType: "csv"
    
    property var activeController: fileType === "csv" ? csvController : arffController
    property string baseName: {
        if (fileType === "csv") {
            return csvController ? csvController.fileName : "Sem nome"
        } else {
            return arffController ? arffController.relationName : "Sem nome"
        }
    }
    property int totalInstances: {
        if (fileType === "csv") {
            return csvController ? csvController.rowCount() : 0
        } else {
            return arffController ? arffController.instanceCount : 0
        }
    }
    property int totalAttributes: {
        if (fileType === "csv") {
            return csvController ? csvController.columnCount() : 0
        } else {
            return arffController ? arffController.attributeCount : 0
        }
    }
    
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
                    if (dataPage.stack) dataPage.stack.pop()
                }
            }
            
            Label {
                text: qsTr("Base carregada!")
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
        
        // Lado esquerdo - Tabela
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: Material.backgroundColor
            border.color: Material.frameColor
            border.width: 1
            radius: 8
            
            Column {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 12
                
                Text {
                    text: baseName
                    font.pointSize: 16
                    font.weight: Font.Medium
                    color: Material.foreground
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                
                ScrollView {
                    width: parent.width
                    height: parent.height - 40
                    clip: true
                    
                    TableView {
                        anchors.fill: parent
                        model: activeController ? activeController.tableModel : null
                        clip: true
                        
                        delegate: Rectangle {
                            implicitWidth: 100
                            implicitHeight: 32
                            color: (row % 2 === 0) ? Material.backgroundColor : Qt.darker(Material.backgroundColor, 1.05)
                            border.color: Material.frameColor
                            border.width: 0.5
                            
                            Text {
                                anchors.centerIn: parent
                                text: display || ""
                                color: Material.foreground
                                font.pointSize: 9
                                elide: Text.ElideRight
                                width: parent.width - 4
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }
                    }
                }
            }
        }
        
        // Lado direito - Informações
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
                
                Text {
                    text: qsTr("Dados da base")
                    font.pointSize: 16
                    font.weight: Font.Medium
                    color: Material.foreground
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                
                Column {
                    width: parent.width
                    spacing: 12
                    
                    Row {
                        width: parent.width
                        spacing: 8
                        
                        Text {
                            text: qsTr("Total de instâncias:")
                            color: Material.foreground
                            font.pointSize: 11
                        }
                        
                        Text {
                            text: totalInstances
                            color: Material.accent
                            font.pointSize: 11
                            font.weight: Font.Medium
                        }
                    }
                    
                    Row {
                        width: parent.width
                        spacing: 8
                        
                        Text {
                            text: qsTr("Total de atributos:")
                            color: Material.foreground
                            font.pointSize: 11
                        }
                        
                        Text {
                            text: totalAttributes
                            color: Material.accent
                            font.pointSize: 11
                            font.weight: Font.Medium
                        }
                    }
                }
                
                Item {
                    width: parent.width
                    height: 40
                }
                
                Column {
                    width: parent.width
                    spacing: 12
                    
                    Button {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        text: qsTr("Carregar outra base")
                        Material.elevation: 2
                        onClicked: {
                            if (dataPage.stack) dataPage.stack.pop()
                        }
                    }
                    
                    Button {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        text: qsTr("Avançar")
                        Material.background: Material.accent
                        Material.foreground: "#000000"
                        font.weight: Font.Medium
                        Material.elevation: 4
                        onClicked: {
                            if (dataPage.stack) {
                                dataPage.stack.push("page3.qml", {
                                    "csvController": csvController,
                                    "arffController": arffController,
                                    "stack": dataPage.stack,
                                    "fileType": fileType
                                })
                            }
                        }
                    }
                }
            }
        }
    }
}