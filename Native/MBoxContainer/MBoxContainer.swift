//
//  MBoxContainer.swift
//  MBoxContainer
//

import Cocoa
import MBoxCore
import MBoxWorkspaceCore

@objc(MBoxContainer)
open class MBoxContainer: NSObject, MBPluginProtocol {

    public func registerCommanders() {
        MBCommanderGroup.shared.addCommand(MBCommander.Container.self)
        MBCommanderGroup.shared.addCommand(MBCommander.Container.Use.self)
        MBCommanderGroup.shared.addCommand(MBCommander.Container.Disuse.self)
        MBCommanderGroup.shared.addCommand(MBCommander.Container.List.self)
    }
    
    public func enablePlugin(workspace: MBWorkspace, from version: String?) throws {
    }

    public func disablePlugin(workspace: MBWorkspace) throws {
    }
}
