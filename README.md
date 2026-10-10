# Disk Monitor

Disk usage as an animated progress bar in your [DankBar](https://github.com/AvengeMedia/DankMaterialShell), refreshed every 30 seconds.

Sibling of [RAM Monitor](https://github.com/rollecode/dms-ram-monitor), [VRAM Monitor](https://github.com/rollecode/dms-vram-monitor), [GPU Monitor](https://github.com/rollecode/dms-gpu-monitor) and [CPU Monitor](https://github.com/rollecode/dms-cpu-monitor).

## What it does

- Compact bar pill: icon, optional label, animated progress bar and percentage
- Slow 30 second polls: disks move slowly, frequent polling is wasted work
- Pill shows the root disk by default, or every disk combined as one percentage via a setting
- Fill follows your theme accent, turns orange above 75% and red above 90% by default, both adjustable in settings
- Click the pill for every real filesystem, biggest first: used space and total size with the device name dimmed, threshold-coloured bars
- External mounts (SMB, NFS and other network filesystems) are hidden by default and shown with a toggle
- Zero dependencies

## Installation

From the DMS plugin browser (Settings, Plugins, Browse), or manually:

```bash
git clone https://github.com/rollecode/dms-disk-monitor ~/.config/DankMaterialShell/plugins/diskMonitor
```

Then enable it in Settings, Plugins, and add the widget to your bar layout in Settings, Bar.

## Settings

- **Show label**: toggle the text label between the icon and the bar (on by default)
- **Label text**: customize the label (default `DISK`)
- **Combine all disks**: show one percentage for every disk together instead of the root disk
- **Show external mounts**: include network filesystems like SMB and NFS shares
- **Entries to show**: how many filesystems the popout lists, 5 to 60 (default 30)

## License

MIT
