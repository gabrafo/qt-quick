import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Dialogs

// Página 1 (UI). Apenas aparência e sinais/slots.
Rectangle {
    id: firstWindow
    property var csvController: null
    property var arffController: null
    property var onDataLoaded: null
    width: 1000
    height: 700
    anchors.fill: parent
    color: Material.backgroundColor

    FileDialog {
        id: csvFileDialog
        title: "Selecione um arquivo CSV"
        nameFilters: ["Arquivos CSV (*.csv)", "Todos os arquivos (*)"]
        onAccepted: {
            if (csvController) {
                csvController.loadCsv(selectedFile)
            }
        }
    }
    
    FileDialog {
        id: arffFileDialog
        title: "Selecione um arquivo ARFF"
        nameFilters: ["Arquivos ARFF (*.arff)", "Todos os arquivos (*)"]
        onAccepted: {
            if (arffController) {
                arffController.loadArff(selectedFile)
            }
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
            color: Material.accent
            font.pointSize: 42
            font.weight: Font.Bold
            font.letterSpacing: 4
        }

        Text {
            id: subtitle
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Dê um toque de ouro nos seus dados")
            font.pointSize: 16
            color: Material.foreground
            opacity: 0.7
        }

        Rectangle {
            id: accentLine
            anchors.horizontalCenter: parent.horizontalCenter
            width: 80
            height: 2
            color: Material.accent
            opacity: 0.6
        }

        Column {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16
            
            Button {
                id: loadCsvButton
                anchors.horizontalCenter: parent.horizontalCenter
                width: 320
                height: 64
                text: qsTr("CARREGAR ARQUIVO CSV")
                Material.elevation: 6
                onClicked: csvFileDialog.open()
            }
            
            Button {
                id: loadArffButton
                anchors.horizontalCenter: parent.horizontalCenter
                width: 320
                height: 64
                text: qsTr("CARREGAR ARQUIVO ARFF")
                Material.elevation: 6
                onClicked: arffFileDialog.open()
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
                color: Material.foreground
                opacity: 0.6
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 24
                Text { text: qsTr("CSV"); font.pointSize: 13; color: Material.accent }
                Rectangle { width: 1; height: 16; color: Material.foreground; opacity: 0.3; anchors.verticalCenter: parent.verticalCenter }
                Text { text: qsTr("ARFF"); font.pointSize: 13; color: Material.accent }
            }
        }
    }

    // Reage aos sinais dos backends
    Connections {
        target: firstWindow.csvController
        function onDataframeChanged() {
            if (firstWindow.onDataLoaded) firstWindow.onDataLoaded("csv")
        }
    }
    
    Connections {
        target: firstWindow.arffController
        function onDataLoaded() {
            if (firstWindow.onDataLoaded) firstWindow.onDataLoaded("arff")
        }
    }
}

