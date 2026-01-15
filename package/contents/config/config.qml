/*
 *  Pipewire Settings Widget for Plasma 6
 *  SPDX-License-Identifier: GPL-3.0-or-later
 *  © 2025 Magillos
 */
import QtQuick 2.15
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "configure"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: i18n("Support")
        icon: "help-donate"
        source: "configSupport.qml"
    }
} 
