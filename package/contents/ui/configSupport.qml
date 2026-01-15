/*
 *  Pipewire Settings Widget for Plasma 6
 *  SPDX-License-Identifier: GPL-3.0-or-later
 *  © 2025 Magillos
 */
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: supportPage
    
    ColumnLayout {
        anchors.centerIn: parent
        spacing: Kirigami.Units.largeSpacing
        width: parent.width * 0.8
        
        Kirigami.Icon {
            source: "help-donate"
            Layout.preferredWidth: Kirigami.Units.iconSizes.enormous
            Layout.preferredHeight: Kirigami.Units.iconSizes.enormous
            Layout.alignment: Qt.AlignHCenter
        }
        
        
        QQC2.Button {
            icon.name: "help-donate"
            text: i18n("Buy me a coffee")
            onClicked: Qt.openUrlExternally("https://buymeacoffee.com/magillos")
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Kirigami.Units.largeSpacing
        }
    }
}
