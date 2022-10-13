//
//  MBConfig.Repo+Container.swift
//  MBoxContainer
//
//  Created by Whirlwind on 2021/5/17.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxDependencyManager

extension MBConfig.Repo {

    open class Container: MBCodableObject {
        @Codable
        open var tool: MBDependencyTool
        @Codable
        open var active: [String]

        convenience init(tool: MBDependencyTool, active: [String] = []) {
            self.init()
            self.tool = tool
            self.active = active
        }

        open var isActivatedAll: Bool {
            return self.active.isEmpty
        }

        open func activateAll() {
            self.active = []
        }

        open func isActivated(_ name: String) -> Bool {
            if self.isActivatedAll { return true }
            let name = name.lowercased()
            return self.active.contains { $0.lowercased() == name }
        }

        @discardableResult
        open func deactivate(name: String) -> Bool {
            let name = name.lowercased()
            let matches = self.active.filter { $0.lowercased() == name}
            if matches.isEmpty { return false }
            self.active.removeAll(matches)
            return true
        }

        open func activate(name: String) {
            if self.isActivated(name) {
                return
            }
            self.active.append(name)
        }

        open func activate(names: [String]) {
            for name in names {
                self.activate(name: name)
            }
        }
    }

    // MARK: - Config
    public var containers: [Container]? {
        set {
            self.setValue(newValue, forPath: "containers")
        }
        get {
            return self.value(forPath: "containers")
        }
    }

    private func container(for tool: MBDependencyTool) -> Container? {
        return self.containers?.first { $0.tool == tool }
    }

    // MARK: - Check Activate
    public var isActivatedAll: Bool {
        return self.containers?.isEmpty == true
    }

    public var isDeactivatedAll: Bool {
        return self.containers == nil
    }

    public func activatedContainers(for tool: MBDependencyTool) -> [String] {
        if self.isDeactivatedAll { return [] }
        if self.isActivatedAll {
            return self.workRepository?.containers(for: tool).map { $0.name } ?? []
        }
        guard let container = self.container(for: tool) else {
            return []
        }
        if !container.active.isEmpty {
            return container.active
        }
        return self.workRepository?.containers(for: tool).map { $0.name } ?? []
    }

    public func isActived(container: String, for tool: MBDependencyTool) -> Bool {
        if self.isDeactivatedAll { return false }
        if self.isActivatedAll { return true }
        let name = container.lowercased()
        let activated = self.container(for: tool)?.active ?? []
        return activated.contains { $0.lowercased() == name }
    }

    // MARK: - Activate
    public func activateContainer(_ name: String) {
        for tool in MBDependencyTool.allTools {
            self.activateContainer(name, for: tool)
        }
    }

    public func activateContainer(_ name: String, for tool: MBDependencyTool, override: Bool = false) {
        UI.log(info: "[\(self)] Activate container `\(name)` for \(tool)") {
            if self.isActived(container: name, for: tool) { return }
            if let container = self.container(for: tool) {
                container.activate(name: name)
            } else {
                self.containers ?= []
                let container = Container(tool: tool, active: [name])
                self.containers!.append(container)
            }
        }
    }

    public func activateContainers(_ names: [String], for tool: MBDependencyTool, override: Bool = false) {
        if self.isActivatedAll {
            UI.log(info: "[\(self)] Activate containers \(names.map { "`\($0)`" }.joined(separator: ", ")) for \(tool)")
            return
        }
        if let container = self.container(for: tool) {
            if override {
                UI.log(info: "[\(self)] (Override) Activate containers \(names.map { "`\($0)`" }.joined(separator: ", ")) for \(tool)") {
                    container.active = names
                }
            } else {
                UI.log(info: "[\(self)] (Append) Activate containers \(names.map { "`\($0)`" }.joined(separator: ", ")) for \(tool)") {
                    container.activate(names: names)
                }
            }
        } else {
            self.containers ?= []
            let container = Container(tool: tool, active: names)
            self.containers!.append(container)
        }
    }

    public func activateAllContainers(for tool: MBDependencyTool) {
        UI.log(info: "[\(self)] Activate all containers for \(tool)") {
            if self.isActivatedAll { return }
            if let container = self.container(for: tool) {
                container.activateAll()
            } else {
                self.containers ?= []
                let container = Container(tool: tool)
                self.containers!.append(container)
            }
        }
    }

    public func activateAllContainers(for tools: [MBDependencyTool]) {
        for tool in tools {
            self.activateAllContainers(for: tool)
        }
    }

    public func activateAllContainers() {
        self.containers = []
    }

    // MARK: - Deactivate
    public func deactivateContainer(_ name: String) {
        for tool in MBDependencyTool.allTools {
            self.deactivateContainer(name, for: tool)
        }
    }

    public func deactivateContainer(_ name: String, for tool: MBDependencyTool) {
        UI.log(info: "[\(self)] Deactivate container `\(name)` for \(tool)") {
            if self.isDeactivatedAll { return }
            defer {
                if self.containers?.isEmpty == true {
                    self.containers = nil
                }
            }
            if self.isActivatedAll {
                self.activateContainers(except: [tool])
                return
            }
            guard let container = self.container(for: tool) else { return }
            defer {
                if container.active.isEmpty {
                    self.containers!.removeAll(container)
                }
            }
            if container.isActivatedAll {
                if let containers = self.workRepository?.containers(for: tool),
                   containers.contains(where: { $0.isName(name) }) {
                    container.active = containers.filter { !$0.isName(name) }.map(\.name)
                }
            } else {
                container.deactivate(name: name)
            }
        }
    }

    public func deactiveAllContainers(for tool: MBDependencyTool) {
        UI.log(info: "[\(self)] Deactivate all containers for \(tool)") {
            if self.isDeactivatedAll { return }
            defer {
                if self.containers?.isEmpty == true {
                    self.containers = nil
                }
            }
            if self.isActivatedAll {
                self.activateContainers(except: [tool])
                return
            }
            guard let container = self.container(for: tool) else { return }
            self.containers!.removeAll(container)
        }
    }

    public func deactiveAllContainers(for tools: [MBDependencyTool]) {
        for tool in tools {
            self.deactiveAllContainers(for: tool)
        }
    }

    // MARK: - Private
    private func activateContainers(except tools: [MBDependencyTool]) {
        var activatedTools = self.workRepository?.containers.map(\.tool).withoutDuplicates() ?? []
        activatedTools.removeAll(tools)
        self.containers ?= []
        for tool in activatedTools {
            if self.container(for: tool) != nil { continue }
            let container = Container(tool: tool)
            self.containers!.append(container)
        }
    }
}
