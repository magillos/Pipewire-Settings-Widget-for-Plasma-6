import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.kquickcontrols 2.0 as KQuickControls
import org.kde.plasma.components 3.0 as PlasmaComponents

Item {
    id: root
    
    // Double the height of the configuration window
    Layout.preferredHeight: 800
    implicitHeight: 1600
    
    property var cfg_customQuantumValues: []
    property var cfg_customSampleRateValues: []
    property bool cfg_applySettingsAtStart
    property int cfg_quickQuantum: 128
    property int cfg_quickSampleRate: 48000
    
    // Standard values for quick restore
    property var defaultQuantumValues: [32, 48, 64, 96, 128, 144, 256, 512, 1024, 8192]
    property var defaultSampleRateValues: [44100, 48000, 96000, 192000]
    
    // Helper function to check if the input is numeric
    function isNumeric(value, min, max) {
        return !isNaN(parseFloat(value)) && isFinite(value) && Number.isInteger(Number(value)) && parseInt(value) >= min && parseInt(value) <= max;
    }

    // Convert string list to array for model
    function updateQuantumModel() {
        quantumListModel.clear();
        for (var i = 0; i < cfg_customQuantumValues.length; i++) {
            quantumListModel.append({ value: cfg_customQuantumValues[i], enabled: true });
        }
        
        // Also add default values that aren't already in the list (but marked as disabled)
        for (var i = 0; i < defaultQuantumValues.length; i++) {
            var value = defaultQuantumValues[i].toString();
            var exists = false;
            
            // Check if value already exists in the model
            for (var j = 0; j < quantumListModel.count; j++) {
                if (quantumListModel.get(j).value === value) {
                    exists = true;
                    break;
                }
            }
            
            if (!exists) {
                quantumListModel.append({ value: value, enabled: false });
            }
        }
        
        // Sort the model by numeric value
        sortQuantumModel();
    }
    
    function updateSampleRateModel() {
        sampleRateListModel.clear();
        for (var i = 0; i < cfg_customSampleRateValues.length; i++) {
            sampleRateListModel.append({ value: cfg_customSampleRateValues[i], enabled: true });
        }
        
        // Also add default values that aren't already in the list (but marked as disabled)
        for (var i = 0; i < defaultSampleRateValues.length; i++) {
            var value = defaultSampleRateValues[i].toString();
            var exists = false;
            
            // Check if value already exists in the model
            for (var j = 0; j < sampleRateListModel.count; j++) {
                if (sampleRateListModel.get(j).value === value) {
                    exists = true;
                    break;
                }
            }
            
            if (!exists) {
                sampleRateListModel.append({ value: value, enabled: false });
            }
        }
        
        // Sort the model by numeric value
        sortSampleRateModel();
    }
    
    // Sort models by numeric value
    function sortQuantumModel() {
        // Create a temporary array to hold all model items
        var items = [];
        for (var i = 0; i < quantumListModel.count; i++) {
            items.push({
                value: quantumListModel.get(i).value,
                enabled: quantumListModel.get(i).enabled,
                numericValue: parseInt(quantumListModel.get(i).value)
            });
        }
        
        // Sort the array numerically
        items.sort(function(a, b) {
            return a.numericValue - b.numericValue;
        });
        
        // Clear and rebuild the model
        quantumListModel.clear();
        for (var i = 0; i < items.length; i++) {
            quantumListModel.append({
                value: items[i].value,
                enabled: items[i].enabled
            });
        }
    }
    
    function sortSampleRateModel() {
        // Create a temporary array to hold all model items
        var items = [];
        for (var i = 0; i < sampleRateListModel.count; i++) {
            items.push({
                value: sampleRateListModel.get(i).value,
                enabled: sampleRateListModel.get(i).enabled,
                numericValue: parseInt(sampleRateListModel.get(i).value)
            });
        }
        
        // Sort the array numerically
        items.sort(function(a, b) {
            return a.numericValue - b.numericValue;
        });
        
        // Clear and rebuild the model
        sampleRateListModel.clear();
        for (var i = 0; i < items.length; i++) {
            sampleRateListModel.append({
                value: items[i].value,
                enabled: items[i].enabled
            });
        }
    }
    
    // Save model values back to config (only save enabled values)
    function saveQuantumValues() {
        var values = [];
        for (var i = 0; i < quantumListModel.count; i++) {
            var item = quantumListModel.get(i);
            if (item.enabled) {
                values.push(item.value);
            }
        }
        cfg_customQuantumValues = values;
    }
    
    function saveSampleRateValues() {
        var values = [];
        for (var i = 0; i < sampleRateListModel.count; i++) {
            var item = sampleRateListModel.get(i);
            if (item.enabled) {
                values.push(item.value);
            }
        }
        cfg_customSampleRateValues = values;
    }
    
    ListModel {
        id: quantumListModel
        Component.onCompleted: {
            updateQuantumModel();
        }
    }
    
    ListModel {
        id: sampleRateListModel
        Component.onCompleted: {
            updateSampleRateModel();
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing
        
        Kirigami.InlineMessage {
            id: infoMessage
            Layout.fillWidth: true
            visible: true
            text: i18n("Customize the quantum and sample rate values shown in the dropdown menus.")
            type: Kirigami.MessageType.Information
            showCloseButton: false
        }
        
        Kirigami.Separator {
            Layout.fillWidth: true
        }
        
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Kirigami.Units.largeSpacing
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                
                Kirigami.Heading {
                    level: 2
                    text: i18n("Quantum Values")
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing
                    
                    PlasmaComponents.TextField {
                        id: quantumInput
                        Layout.fillWidth: true
                        placeholderText: i18n("Add new quantum value (16-8192)")
                        validator: IntValidator { bottom: 16; top: 8192 }
                    }

                    PlasmaComponents.Button {
                        text: i18n("Add")
                        enabled: quantumInput.text.length > 0 && isNumeric(quantumInput.text, 16, 8192)
                        onClicked: {
                            if (isNumeric(quantumInput.text, 16, 8192)) {
                                // Check if value already exists
                                var newValue = quantumInput.text;
                                var exists = false;

                                for (var i = 0; i < quantumListModel.count; i++) {
                                    if (quantumListModel.get(i).value === newValue) {
                                        // If it exists but is disabled, enable it
                                        if (!quantumListModel.get(i).enabled) {
                                            quantumListModel.setProperty(i, "enabled", true);
                                            saveQuantumValues();
                                        }
                                        exists = true;
                                        break;
                                    }
                                }

                                if (!exists) {
                                    quantumListModel.append({ value: newValue, enabled: true });
                                    // Re-sort the entire model after adding new value
                                    sortQuantumModel();
                                    saveQuantumValues();
                                }

                                quantumInput.text = "";
                            }
                        }
                    }
                }

                Flickable {
                    id: quantumFlickable
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 100
                    Layout.maximumHeight: 600
                    contentHeight: quantumColumn.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    
                    ScrollBar.vertical: ScrollBar {
                        id: quantumScrollBar
                        policy: ScrollBar.AsNeeded
                        visible: quantumFlickable.contentHeight > quantumFlickable.height
                        active: visible
                    }
                    
                    Column {
                        id: quantumColumn
                        width: parent.width
                        
                        Repeater {
                            model: quantumListModel
                            
                            delegate: RowLayout {
                                width: quantumColumn.width
                                height: 30
                                
                                PlasmaComponents.CheckBox {
                                    checked: model.enabled
                                    onClicked: {
                                        quantumListModel.setProperty(index, "enabled", checked);
                                        saveQuantumValues();
                                    }
                                }
                                
                                PlasmaComponents.Label {
                                    Layout.fillWidth: true
                                    text: model.value
                                    opacity: model.enabled ? 1.0 : 0.5
                                }
                            }
                        }
                    }
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                
                Kirigami.Heading {
                    level: 2
                    text: i18n("Sample Rate Values")
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing
                    
                    PlasmaComponents.TextField {
                        id: sampleRateInput
                        Layout.fillWidth: true
                        placeholderText: i18n("Add new sample rate value (44100-768000)")
                        validator: IntValidator { bottom: 44100; top: 768000 }
                    }

                    PlasmaComponents.Button {
                        text: i18n("Add")
                        enabled: sampleRateInput.text.length > 0 && isNumeric(sampleRateInput.text, 44100, 768000)
                        onClicked: {
                            if (isNumeric(sampleRateInput.text, 44100, 768000)) {
                                // Check if value already exists
                                var newValue = sampleRateInput.text;
                                var exists = false;

                                for (var i = 0; i < sampleRateListModel.count; i++) {
                                    if (sampleRateListModel.get(i).value === newValue) {
                                        // If it exists but is disabled, enable it
                                        if (!sampleRateListModel.get(i).enabled) {
                                            sampleRateListModel.setProperty(i, "enabled", true);
                                            saveSampleRateValues();
                                        }
                                        exists = true;
                                        break;
                                    }
                                }

                                if (!exists) {
                                    sampleRateListModel.append({ value: newValue, enabled: true });
                                    // Re-sort the entire model after adding new value
                                    sortSampleRateModel();
                                    saveSampleRateValues();
                                }

                                sampleRateInput.text = "";
                            }
                        }
                    }
                }

                Flickable {
                    id: sampleRateFlickable
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 100
                    Layout.maximumHeight: 600
                    contentHeight: sampleRateColumn.height
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    
                    ScrollBar.vertical: ScrollBar {
                        id: sampleRateScrollBar
                        policy: ScrollBar.AsNeeded
                        visible: sampleRateFlickable.contentHeight > sampleRateFlickable.height
                        active: visible
                    }
                    
                    Column {
                        id: sampleRateColumn
                        width: parent.width
                        
                        Repeater {
                            model: sampleRateListModel
                            
                            delegate: RowLayout {
                                width: sampleRateColumn.width
                                height: 30
                                
                                PlasmaComponents.CheckBox {
                                    checked: model.enabled
                                    onClicked: {
                                        sampleRateListModel.setProperty(index, "enabled", checked);
                                        saveSampleRateValues();
                                    }
                                }
                                
                                PlasmaComponents.Label {
                                    Layout.fillWidth: true
                                    text: model.value
                                    opacity: model.enabled ? 1.0 : 0.5
                                }
                            }
                        }
                    }
                }
            }
        }
        
        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.largeSpacing
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Heading {
                level: 2
                text: i18n("Quick Settings Button")
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Heading {
                    level: 3
                    text: i18n("Quantum:")
                }

                PlasmaComponents.ComboBox {
                    id: quickQuantumCombo
                    Layout.fillWidth: true
                    model: {
                        var values = [ "Default" ];
                        for (var i = 0; i < quantumListModel.count; i++) {
                            if (quantumListModel.get(i).enabled) {
                                values.push(quantumListModel.get(i).value);
                            }
                        }
                        return values;
                    }
                    currentIndex: findIndexForValue(root.cfg_quickQuantum)
                    onActivated: {
                        if (currentValue === "Default") {
                            root.cfg_quickQuantum = -1;
                        } else {
                            root.cfg_quickQuantum = parseInt(currentValue);
                        }
                    }

                    function findIndexForValue(value) {
                        if (value == -1) return 0;
                        var values = [ "Default" ];
                        for (var i = 0; i < quantumListModel.count; i++) {
                            if (quantumListModel.get(i).enabled) {
                                values.push(quantumListModel.get(i).value);
                            }
                        }
                        for (var i = 1; i < values.length; i++) {
                            if (values[i] == value) return i;
                        }
                        return 0;
                    }
                }

                Kirigami.Heading {
                    level: 3
                    text: i18n("Sample Rate:")
                }

                PlasmaComponents.ComboBox {
                    id: quickSampleRateCombo
                    Layout.fillWidth: true
                    model: {
                        var values = [ "Default" ];
                        for (var i = 0; i < sampleRateListModel.count; i++) {
                            if (sampleRateListModel.get(i).enabled) {
                                values.push(sampleRateListModel.get(i).value);
                            }
                        }
                        return values;
                    }
                    currentIndex: findIndexForValue(root.cfg_quickSampleRate)
                    onActivated: {
                        if (currentValue === "Default") {
                            root.cfg_quickSampleRate = -1;
                        } else {
                            root.cfg_quickSampleRate = parseInt(currentValue);
                        }
                    }

                    function findIndexForValue(value) {
                        if (value == -1) return 0;
                        var values = [ "Default" ];
                        for (var i = 0; i < sampleRateListModel.count; i++) {
                            if (sampleRateListModel.get(i).enabled) {
                                values.push(sampleRateListModel.get(i).value);
                            }
                        }
                        for (var i = 1; i < values.length; i++) {
                            if (values[i] == value) return i;
                        }
                        return 0;
                    }
                }
            }
        }

        Kirigami.Separator {
            Layout.fillWidth: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Heading {
                level: 2
                text: i18n("Startup Settings")
            }

            PlasmaComponents.CheckBox {
                id: applySettingsAtStartCheckBox
                text: i18n("Remember Quantum and Sample Rate at start")
                checked: root.cfg_applySettingsAtStart
                onCheckedChanged: root.cfg_applySettingsAtStart = checked

                PlasmaComponents.ToolTip {
                    text: i18n("When enabled, automatically applies the last used quantum and sample rate settings when the widget starts")
                }
            }
        }
    }
}
