import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.plasma5support 2.0 as Plasma5Support

PlasmoidItem {
    id: root
    width: 290
    height: 130

    property ListModel quantumModel: ListModel {
        ListElement { text: ""; value: "-1" }
        ListElement { text: "Default"; value: "0" }
        ListElement { text: "16"; value: "16" }
        ListElement { text: "32"; value: "32" }
        ListElement { text: "48"; value: "48" }
        ListElement { text: "64"; value: "64" }
        ListElement { text: "96"; value: "96" }
        ListElement { text: "128"; value: "128" }
        ListElement { text: "144"; value: "144" }
        ListElement { text: "192"; value: "192" }
        ListElement { text: "240"; value: "240" }
        ListElement { text: "256"; value: "256" }
        ListElement { text: "512"; value: "512" }
        ListElement { text: "1024"; value: "1024" }
        ListElement { text: "2048"; value: "2048" }
    }

    property ListModel sampleRateModel: ListModel {
        ListElement { text: ""; value: "-1" }
        ListElement { text: "Default"; value: "0" }
        ListElement { text: "44100"; value: "44100" }
        ListElement { text: "48000"; value: "48000" }
        ListElement { text: "88200"; value: "88200" }
        ListElement { text: "96000"; value: "96000" }
        ListElement { text: "176400"; value: "176400" }
        ListElement { text: "192000"; value: "192000" }
    }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: function(source, data) {
            if (source === quantumSource) {
                if (data.stdout.trim() === "0") {
                    executable.exec(quantumAlternativeSource);
                } else {
                    quantumModel.setProperty(0, "text", "Current: " + data.stdout);
                }
            } else if (source === quantumAlternativeSource) {
                quantumModel.setProperty(0, "text", "Current: " + data.stdout);
            } else if (source === sampleRateSource) {
                if (data.stdout.trim() === "0") {
                    executable.exec(sampleRateAlternativeSource);
                } else {
                    sampleRateModel.setProperty(0, "text", "Current: " + data.stdout);
                }
            } else if (source === sampleRateAlternativeSource) {
                sampleRateModel.setProperty(0, "text", "Current: " + data.stdout);
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

    property string quantumSource: `pw-metadata -n settings | grep clock.force-quantum | awk -F"'" '{print $4}' | cut -d' ' -f1`
    property string quantumAlternativeSource: `pw-metadata -n settings | grep clock.quantum | awk -F"'" '{print $4}' | cut -d' ' -f1`
    property string sampleRateSource: `pw-metadata -n settings | grep clock.force-rate | awk -F"'" '{print $4}' | cut -d' ' -f1`
    property string sampleRateAlternativeSource: `pw-metadata -n settings | grep clock.rate | awk -F"'" '{print $4}' | cut -d' ' -f1`

    toolTipMainText: i18n("Your Widget")

    fullRepresentation: Column {
        spacing: Kirigami.Units.largeSpacing

        RowLayout {
            spacing: Kirigami.Units.smallSpacing

            Label {
                text: i18n("Quantum:")
                Layout.alignment: Qt.AlignVCenter
                font.bold: true
                Layout.leftMargin: 21
            }

            Item {
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
                }
                Component.onCompleted: {
                    executable.exec(quantumSource);
                }
                onCurrentIndexChanged: {
                    executable.exec(quantumSource);
                }
            }
        }

        RowLayout {
            spacing: Kirigami.Units.smallSpacing

            Label {
                text: i18n("Sample Rate:")
                Layout.alignment: Qt.AlignVCenter
                font.bold: true
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
                }
                Component.onCompleted: {
                    executable.exec(sampleRateSource);
                }
                onCurrentIndexChanged: {
                    executable.exec(sampleRateSource);
                }
            }
        }
    }
}
