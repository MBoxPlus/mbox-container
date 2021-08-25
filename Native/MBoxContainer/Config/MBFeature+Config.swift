//
//  MBConfig.Feature+Repo.swift
//  MBoxContainer
//
//  Created by Yao Li on 2020/8/23.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import MBoxCore
import MBoxWorkspaceCore
import MBoxDependencyManager

var kMBConfigFeatureSyncContainerTools: UInt8 = 0
extension MBConfig.Feature {
    @_dynamicReplacement(for: remove(repo:))
    open func container_remove(repo: MBConfig.Repo) throws {
        try self.remove(repo: repo)
        self.deactivateContainer(repo.name)
    }

    dynamic
    public class var syncContainerTools: [[MBDependencyTool]] { return [] }

    public class var syncContainerToolsMap: [MBDependencyTool: [MBDependencyTool]] {
        var value = [MBDependencyTool: [MBDependencyTool]]()
        let allTools = self.syncContainerTools
        for tool in Set(allTools.flatMap { $0 }) {
            var tools = allTools.filter { $0.contains(tool) }.flatMap { $0 }.withoutDuplicates()
            tools.bringToFirst(tool)
            value[tool] = tools
        }
        return value
    }

    private func containerTools(for tool: MBDependencyTool) -> [MBDependencyTool] {
        if let values = Self.syncContainerToolsMap[tool], !values.isEmpty {
            return values
        }
        return [tool]
    }

    open func deactivateContainer(_ name: String) {
        self.currentContainers.removeAll { $0.isName(name) }
    }

    open func deactivateContainer(tool: MBDependencyTool) {
        guard self.currentContainers.contains(where: { $0.tool == tool }) else { return }
        for tool in containerTools(for: tool) {
            self.currentContainers.removeAll { $0.tool == tool }
        }
    }

    open func deactivateContainer(_ name: String, tool: MBDependencyTool) {
        guard self.currentContainers.contains(where: { $0.tool == tool && $0.isName(name) }) else { return }
        for tool in containerTools(for: tool) {
            self.currentContainers.removeAll { $0.tool == tool && $0.isName(name) }
        }
    }

    open func deactivateContainer(_ container: MBContainer) {
        guard self.currentContainers.contains(container) else { return }
        self.currentContainers.removeAll(container)
        for tool in containerTools(for: container.tool) {
            self.currentContainers.removeAll { $0.tool == tool && $0.isName(container.name) }
        }
    }

    open func activateContainer(_ container: MBContainer) {
        let tools = containerTools(for: container.tool)
        for tool in tools {
            self.currentContainers.removeAll { $0.tool == tool }
        }
        let containers = self.container(named: container.name).filter { tools.contains($0.tool) }
        self.currentContainers.append(contentsOf: containers)
    }
}
