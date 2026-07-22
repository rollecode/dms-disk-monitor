import QtQuick
import qs.Common
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "diskMonitor"

    StyledText {
        width: parent.width
        text: "Disk Monitor"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Disk usage as an animated progress bar in your DankBar, refreshed every 30 seconds."
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    Rectangle {
        width: parent.width
        height: 1
        color: Theme.outline
        opacity: 0.3
    }

    ToggleSetting {
        settingKey: "showLabel"
        label: "Show label"
        description: "Display a text label between the icon and the bar"
        defaultValue: true
    }

    StringSetting {
        settingKey: "labelText"
        label: "Label text"
        description: "The label shown next to the icon"
        placeholder: "DISK"
        defaultValue: "DISK"
    }

    ToggleSetting {
        settingKey: "combineAll"
        label: "Combine all disks"
        description: "Show one percentage for every disk together instead of the root disk"
        defaultValue: false
    }

    ToggleSetting {
        settingKey: "includeExternal"
        label: "Show external mounts"
        description: "Include network filesystems like SMB and NFS shares"
        defaultValue: false
    }

    SliderSetting {
        settingKey: "topCount"
        label: "Entries to show"
        description: "How many filesystems the popout lists, biggest first"
        defaultValue: 30
        minimum: 5
        maximum: 60
        unit: ""
    }
}
