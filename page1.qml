import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs

// Página 1 (UI). Apenas aparência e sinais/slots.
Rectangle {
    id: firstWindow
    property var controller: null
    property var onDataLoaded: null
    width: 1000
    height: 700
    anchors.fill: parent

    gradient: Gradient {
        GradientStop { position: 0.0; color: "#0A0A0A" }
        GradientStop { position: 1.0; color: "#1A1A1A" }
    }

    FileDialog {
        id: fileDialog
        title: "Selecione um arquivo CSV"
        nameFilters: ["Arquivos CSV (*.csv)", "Todos os arquivos (*)"]
        onAccepted: {
            if (controller) controller.loadCsv(selectedFile)
        }
    }

    Column {
        id: mainContent
        anchors.centerIn: parent
        spacing: 24
        width: parent.width

        Text {
            id: mainTitle
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("MIDAS")
            color: "#B8860B"
            font.pointSize: 42
            font.weight: Font.Bold
            font.letterSpacing: 4
            style: Text.Outline
            styleColor: "#33000000"
        }

        Text {
            id: subtitle
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Dê um toque de ouro nos seus dados")
            font.pointSize: 16
            color: "#E5E5E5"
            opacity: 0.9
        }

        Rectangle {
            id: goldLine
            anchors.horizontalCenter: parent.horizontalCenter
            width: 80
            height: 2
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: "#FFD700" }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        Button {
            id: loadDataBase
            anchors.horizontalCenter: parent.horizontalCenter
            width: 320
            height: 64
            text: qsTr("ESCOLHER ARQUIVO CSV")
            display: AbstractButton.TextBesideIcon
            icon.source: "dataset.svg"
            icon.width: 20
            icon.height: 20
            onClicked: fileDialog.open()

            background: Rectangle {
                gradient: Gradient {
                    GradientStop { position: 0.0; color: parent.pressed ? "#B8860B" : parent.hovered ? "#DAA520" : "#1F1F1F" }
                    GradientStop { position: 1.0; color: parent.pressed ? "#DAA520" : parent.hovered ? "#FFD700" : "#2A2A2A" }
                }
                radius: 6
                border.color: (parent.hovered || parent.pressed) ? "#FFD700" : "#444444"
                border.width: 1
            }

            contentItem: Row {
                spacing: 12
                anchors.centerIn: parent
                Image {
                    source: loadDataBase.icon.source
                    width: loadDataBase.icon.width
                    height: loadDataBase.icon.height
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: loadDataBase.text
                    color: (loadDataBase.hovered || loadDataBase.pressed) ? "#000000" : "#FFD700"
                    font: loadDataBase.font
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        Column {
            id: formatsSection
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16

            Text {
                id: helpText
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("FORMATOS SUPORTADOS")
                font.pointSize: 11
                font.weight: Font.Medium
                font.letterSpacing: 2
                color: "#888888"
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 24
                Text { text: qsTr("CSV"); font.pointSize: 13; color: "#B8860B" }
                Rectangle { width: 1; height: 16; color: "#444444"; anchors.verticalCenter: parent.verticalCenter }
                Text { text: qsTr("EXCEL"); font.pointSize: 13; color: "#B8860B" }
            }
        }
    }

    // Reage ao sinal do backend quando o DataFrame muda
    Connections {
        target: firstWindow.controller
        function onDataframeChanged() {
            if (firstWindow.onDataLoaded) firstWindow.onDataLoaded()
        }
    }
}

