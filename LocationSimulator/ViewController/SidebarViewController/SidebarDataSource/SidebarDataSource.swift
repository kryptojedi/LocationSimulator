//
//  SidebarDataSource.swift
//  LocationSimulator
//
//  Created by David Klopp on 23.12.20.
//  Copyright © 2020 David Klopp. All rights reserved.
//

import AppKit

/// This class is responsible for managing the devices.
class SidebarDataSource: NSObject {
    public weak var sidebarView: NSOutlineView?

    /// List with all currently detected devices.
    public var devices: [Device] = []

    /// The currently selected device.
    public var selectedDevice: Device? {
        let row = (self.sidebarView?.selectedRow ?? 0) - 1
        return row >= 0 ? self.devices[row] : nil
    }

    // MARK: - Constructor

    init(sidebarView: NSOutlineView) {
        self.sidebarView = sidebarView
        super.init()

        // Register ourself to setup the sidebar
        self.sidebarView?.dataSource = self
        self.sidebarView?.delegate = self
    }

    // MARK: - Public functions

    /// Update the text and image for the cell at the specific index.
    func updateCell(atIndex index: Int) {
        guard let cell = self.sidebarView?.view(atColumn: 0, row: index, makeIfNecessary: false) as? NSTableCellView,
              index < self.devices.count+1, index > 0 else { return }

        let device = self.devices[index-1]
        cell.textField?.stringValue = device.name
        cell.imageView?.image = device.image
    }
}

// MARK: - NSOutlineViewDataSource

extension SidebarDataSource: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        return index == 0 ? DeviceHeader() : self.devices[index-1]
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return false
    }

    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        return 1 + self.devices.count
    }
}

// MARK: - NSOutlineViewDelegate

extension SidebarDataSource: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor viewForTableColumn: NSTableColumn?, item: Any) -> NSView? {
        // Weird swift bug:
        // https://stackoverflow.com/questions/42033735/failing-cast-in-swift-from-any-to-protocol
        guard let item = (item as AnyObject) as? SidebarItem else { return nil }
        // Create the NSTableView cell for the outline view.
        let cell = self.sidebarView?.makeView(withIdentifier: item.identifier, owner: self) as? NSTableCellView
        cell?.textField?.stringValue = item.name
        cell?.imageView?.image = item.image

        return cell
    }

    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        // Do not allow selecting a header cell.
        if (item as AnyObject) as? DeviceHeader != nil {
            return false
        }
        // Allow selecting a device, if it is not already selected.
        if let device = (item as AnyObject) as? Device {
            return self.selectedDevice != device
        }
        // Default, should never be the case.
        return false
    }

    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        // The header cell is a group cell
        guard let item = (item as AnyObject) as? SidebarItem else { return false }
        return item.isGroupItem
    }

    //func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
    //    return 28
    //}
}
