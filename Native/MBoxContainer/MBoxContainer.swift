//
//  MBoxContainer.swift
//  MBoxContainer
//

import Cocoa
@_exported import MBoxWorkspace

@objc(MBoxContainer)
open class MBoxContainer: NSObject, MBPluginProtocol, MBWorkspacePluginProtocol {

    public func registerCommanders() {
        MBCommanderGroup.shared.addCommand(MBCommander.Container.self)
        MBCommanderGroup.shared.addCommand(MBCommander.Container.Use.self)
        MBCommanderGroup.shared.addCommand(MBCommander.Container.Disuse.self)
        MBCommanderGroup.shared.addCommand(MBCommander.Container.List.self)
    }
    
    public func enablePlugin(workspace: MBWorkspace, from version: String?) throws {
        // Migrate `current_containers` to `containers`
        if workspace.config.migrateContainers(feature: nil) {
            workspace.config.save()
        }
    }

    public func disablePlugin(workspace: MBWorkspace) throws {
    }
}
