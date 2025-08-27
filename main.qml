import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtQuick.Dialogs
import App 1.0

// Janela principal com StackView
ApplicationWindow {
    id: win
    width: 1000
    height: 700
    visible: true
    title: "MIDAS"
    
    // Configuração do Material Design
    Material.theme: Material.Dark
    Material.primary: Material.BlueGrey
    Material.accent: Material.Amber

    // Backends disponíveis no QML
    CSVController {
        id: csvController
        onErrorOccurred: function(message) {
            messageDialog.title = "Erro"
            messageDialog.text = message
            messageDialog.open()
        }
        onSuccessOccurred: function(message) {
            messageDialog.title = "Sucesso"
            messageDialog.text = message
            messageDialog.open()
        }
    }
    
    ARFFController {
        id: arffController
        onErrorOccurred: function(message) {
            messageDialog.title = "Erro" 
            messageDialog.text = message
            messageDialog.open()
        }
    }

    MessageDialog {
        id: messageDialog
        text: ""
        onAccepted: {}
    }

    StackView {
        id: nav
        anchors.fill: parent
        initialItem: Loader {
            source: "page1.qml"
            onLoaded: function() {
                if (item && item.hasOwnProperty("csvController")) {
                    item.csvController = csvController
                }
                if (item && item.hasOwnProperty("arffController")) {
                    item.arffController = arffController
                }
                if (item && item.hasOwnProperty("onDataLoaded")) {
                    // Se a página 1 expor um callback, conectamos para navegar
                    item.onDataLoaded = function(fileType) {
                        if (fileType === "csv") {
                            nav.push("page2.qml", { 
                                "csvController": csvController, 
                                "arffController": arffController,
                                "stack": nav,
                                "fileType": "csv"
                            })
                        } else if (fileType === "arff") {
                            nav.push("page2.qml", { 
                                "csvController": csvController, 
                                "arffController": arffController,
                                "stack": nav,
                                "fileType": "arff"
                            })
                        }
                    }
                }
            }
        }
    }
}


