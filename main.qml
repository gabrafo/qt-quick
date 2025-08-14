import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Dialogs
import App 1.0

// Janela principal com StackView
ApplicationWindow {
    id: win
    width: 1000
    height: 700
    visible: true
    title: "MIDAS"

    // Backend disponível no QML
    CSVController {
        id: controller
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
                if (item && item.hasOwnProperty("controller")) {
                    item.controller = controller
                }
                if (item && item.hasOwnProperty("onDataLoaded")) {
                    // Se a página 1 expor um callback, conectamos para navegar
                    item.onDataLoaded = function() {
                        nav.push("page2_table.qml", { "controller": controller, "stack": nav })
                    }
                }
            }
        }
    }
}


