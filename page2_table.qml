import QtQuick 2.15
import QtQuick.Controls 2.15

// Página 2 (Tabela). Consulta dados ao backend via Slots.
Page {
    id: tablePage
    property var controller: null
    property var stack: null

    header: ToolBar {
        contentItem: Row {
            spacing: 8
            Button {
                text: "Voltar"
                onClicked: {
                    if (tablePage.stack) tablePage.stack.pop()
                    else if (StackView.view) StackView.view.pop()
                }
            }
            Label { text: controller ? (controller.fileName || "Sem arquivo") : "" }
            Label { text: controller ? controller.info : "" }
        }
    }
    
    ScrollView {
        anchors.fill: parent
        clip: true
        TableView {
            id: table
            anchors.fill: parent
            model: controller ? controller.tableModel : null
            clip: true

            delegate: Rectangle {
                implicitWidth: 120
                implicitHeight: 28
                color: (row % 2 === 0) ? "#1E1E1E" : "#181818"
                border.color: "#303030"
                Text { anchors.centerIn: parent; text: display; color: "#D0D0D0"; font.pointSize: 11; elide: Text.ElideRight }
            }
        }
    }
}