import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.plasma5support 2.0 as Plasma5Support


PlasmoidItem {
    id: root

    // Property to track if we've initialized models from config
    property bool modelsInitialized: false

    // Dynamic ListModels that will be populated from configuration
    property ListModel quantumModel: ListModel {
        ListElement { text: ""; value: "-1"; isCurrent: false }
        ListElement { text: "Default"; value: "0"; isCurrent: false }
    }

    property ListModel sampleRateModel: ListModel {
        ListElement { text: ""; value: "-1"; isCurrent: false }
        ListElement { text: "Default"; value: "0"; isCurrent: false }
    }

    property int currentQuantum: 0
    property int currentSampleRate: 0
    property real calculatedLatency: 0

    // Function to initialize models from configuration
    function initializeModels() {
        if (modelsInitialized) return;
        
        // Add quantum values from config and sort them
        let quantumValues = [...plasmoid.configuration.customQuantumValues];
        quantumValues.sort((a, b) => parseInt(a) - parseInt(b));
        for (let i = 0; i < quantumValues.length; i++) {
            let value = quantumValues[i];
            quantumModel.append({ 
                text: value, 
                value: value, 
                isCurrent: false 
            });
        }
        
        // Add sample rate values from config and sort them
        let sampleRateValues = [...plasmoid.configuration.customSampleRateValues];
        sampleRateValues.sort((a, b) => parseInt(a) - parseInt(b));
        for (let i = 0; i < sampleRateValues.length; i++) {
            let value = sampleRateValues[i];
            sampleRateModel.append({ 
                text: value, 
                value: value, 
                isCurrent: false 
            });
        }
        
        modelsInitialized = true;
    }

    // Initialize models when plasmoid is ready
    Component.onCompleted: {
        initializeModels();
    }

    // Update models when configuration changes
    Connections {
        target: plasmoid.configuration
        function onCustomQuantumValuesChanged() {
            // Clear existing custom values but keep current/default
            while (quantumModel.count > 2) {
                quantumModel.remove(2);
            }
            
            // Sort and add new values from configuration
            let quantumValues = [...plasmoid.configuration.customQuantumValues];
            quantumValues.sort((a, b) => parseInt(a) - parseInt(b));
            for (let i = 0; i < quantumValues.length; i++) {
                let value = quantumValues[i];
                quantumModel.append({
                    text: value,
                    value: value,
                    isCurrent: false
                });
            }
        }
        
        function onCustomSampleRateValuesChanged() {
            // Clear existing custom values but keep current/default
            while (sampleRateModel.count > 2) {
                sampleRateModel.remove(2);
            }
            
            // Sort and add new values from configuration
            let sampleRateValues = [...plasmoid.configuration.customSampleRateValues];
            sampleRateValues.sort((a, b) => parseInt(a) - parseInt(b));
            for (let i = 0; i < sampleRateValues.length; i++) {
                let value = sampleRateValues[i];
                sampleRateModel.append({
                    text: value,
                    value: value,
                    isCurrent: false
                });
            }
        }
    }

    function updateLatency() {
        if (currentQuantum > 0 && currentSampleRate > 0) {
            calculatedLatency = (currentQuantum / currentSampleRate) * 1000;
        } else {
            calculatedLatency = 0;
        }
    }

    Plasmoid.icon: Qt.resolvedUrl("../jack-plug(4).svg")

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: function(source, data) {
            if (source === quantumSource) {
                if (data.stdout.trim() === "0") {
                    executable.exec(quantumAlternativeSource);
                } else {
                    var quantum = data.stdout.trim();
                    quantumModel.setProperty(0, "text", quantum);
                    quantumModel.setProperty(0, "value", quantum);
                    quantumModel.setProperty(0, "isCurrent", true);
                    currentQuantum = parseInt(quantum);
                    updateLatency();
                }
            } else if (source === quantumAlternativeSource) {
                var quantum = data.stdout.trim();
                quantumModel.setProperty(0, "text", quantum);
                quantumModel.setProperty(0, "value", quantum);
                quantumModel.setProperty(0, "isCurrent", true);
                currentQuantum = parseInt(quantum);
                updateLatency();
            } else if (source === sampleRateSource) {
                if (data.stdout.trim() === "0") {
                    executable.exec(sampleRateAlternativeSource);
                } else {
                    var sampleRate = data.stdout.trim();
                    sampleRateModel.setProperty(0, "text", sampleRate);
                    sampleRateModel.setProperty(0, "value", sampleRate);
                    sampleRateModel.setProperty(0, "isCurrent", true);
                    currentSampleRate = parseInt(sampleRate);
                    updateLatency();
                }
            } else if (source === sampleRateAlternativeSource) {
                var sampleRate = data.stdout.trim();
                sampleRateModel.setProperty(0, "text", sampleRate);
                sampleRateModel.setProperty(0, "value", sampleRate);
                sampleRateModel.setProperty(0, "isCurrent", true);
                currentSampleRate = parseInt(sampleRate);
                updateLatency();
            }
            executable.disconnectSource(source);
        }

        function exec(cmd) {
            executable.connectSource(cmd);
        }
    }

    function executeCommand(command) {
        executable.exec(command);
    }

    property string quantumSource: `pw-metadata -n settings | awk -F"'" '/force-quantum/ {print $4}'`
    property string quantumAlternativeSource: `pw-metadata -n settings | awk -F"'" '/clock.quantum/ {print $4}'`
    property string sampleRateSource: `pw-metadata -n settings | awk -F"'" '/clock.force-rate/ {print $4}'`
    property string sampleRateAlternativeSource: `pw-metadata -n settings | awk -F"'" '/clock.rate/ {print $4}'`

    toolTipMainText: i18n("PipeWire Settings")

    fullRepresentation: ColumnLayout {

        spacing: Kirigami.Units.largeSpacing
        Layout.minimumWidth: 240
        Layout.minimumHeight: 100
        Layout.preferredWidth: 240
        Layout.preferredHeight: 100

        ColumnLayout {
            spacing: Kirigami.Units.smallSpacing
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop

            RowLayout {
                spacing: Kirigami.Units.smallSpacing

                Label {
                    text: i18n("Quantum:")
                    font.bold: true
                    Layout.leftMargin: 25
                }

                ComboBox {
                    id: quantumComboBox
                    Layout.fillWidth: true
                    Layout.preferredWidth: 150
                    Layout.leftMargin: -3
                    model: root.quantumModel
                    textRole: "text"
                    valueRole: "value"
                    padding: 20
                    onActivated: {
                        if (currentValue === "-1") {
                            return;
                        }
                        root.executeCommand("pw-metadata -n settings 0 clock.force-quantum " + currentValue)
                        if (currentValue === "0") {
                            quantumComboBox.currentIndex = 0
                        }
                        currentQuantum = parseInt(currentValue);
                        updateLatency();
                    }
                    Component.onCompleted: {
                        executable.exec(quantumSource);
                    }
                    onCurrentIndexChanged: {
                        executable.exec(quantumSource);
                    }

                    delegate: ItemDelegate {
                        width: quantumComboBox.width
                        height: quantumComboBox.height
                        contentItem: RowLayout {
                            spacing: 5
                            Text {
                                text: model.isCurrent ? "Current: " : ""
                                color: quantumComboBox.pressed ? quantumComboBox.palette.highlightedText : quantumComboBox.palette.text
                            }
                            Text {
                                text: model.text
                                color: quantumComboBox.pressed ? quantumComboBox.palette.highlightedText : quantumComboBox.palette.text
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            }
                        }
                        highlighted: quantumComboBox.highlightedIndex === index
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Label {
                    text: i18n("Sample Rate:")
                    font.bold: true
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                }

                ComboBox {
                    id: sampleRateComboBox
                    Layout.fillWidth: true
                    Layout.preferredWidth: 150
                    model: root.sampleRateModel
                    textRole: "text"
                    valueRole: "value"
                    padding: 20
                    onActivated: {
                        if (currentValue === "-1") {
                            return;
                        }
                        root.executeCommand("pw-metadata -n settings 0 clock.force-rate " + currentValue)
                        if (currentValue === "0") {
                            sampleRateComboBox.currentIndex = 0
                        }
                        currentSampleRate = parseInt(currentValue);
                        updateLatency();
                    }
                    Component.onCompleted: {
                        executable.exec(sampleRateSource);
                    }
                    onCurrentIndexChanged: {
                        executable.exec(sampleRateSource);
                    }

                    delegate: ItemDelegate {
                        width: sampleRateComboBox.width
                        height: sampleRateComboBox.height
                        contentItem: RowLayout {
                            spacing: 5
                            Text {
                                text: model.isCurrent ? "Current: " : ""
                                color: sampleRateComboBox.pressed ? sampleRateComboBox.palette.highlightedText : sampleRateComboBox.palette.text
                            }
                            Text {
                                text: model.text
                                color: sampleRateComboBox.pressed ? sampleRateComboBox.palette.highlightedText : sampleRateComboBox.palette.text
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                            }
                        }
                        highlighted: sampleRateComboBox.highlightedIndex === index
                    }
                }
            }

            Item {
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
        }
        RowLayout {
            spacing: Kirigami.Units.smallSpacing
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignBottom | Qt.AlignHCenter
            Button {
                text: "Refresh"
                onClicked: {
                    // Force refresh by directly executing commands
                    executable.exec(quantumSource);
                    executable.exec(sampleRateSource);
                    
                    // Reset combo box selection to show current values
                    quantumComboBox.currentIndex = 0;
                    sampleRateComboBox.currentIndex = 0;
                }
            }
            Item {
                Layout.fillWidth: true
            }

            Label {
                text: i18n("Latency:")
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                font.pointSize: Kirigami.Theme.smallFont.pointSize
            }

            Label {
                text: calculatedLatency.toFixed(2) + " ms"
                Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                Layout.rightMargin: 5
                font.pointSize: Kirigami.Theme.smallFont.pointSize
            }
        }
    }
}
