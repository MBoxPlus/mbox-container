//
//  MBConfig.Feature+MBWorkRepo.Container.swift
//  MBoxContainer
//
//  Created by Yao Li on 2020/8/23.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import MBoxCore
import MBoxDependencyManager

var kMBConfigFeatureSyncContainerTools: UInt8 = 0
extension MBConfig.Feature {

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

    // MARK: - All Containers
    dynamic
    public var allContainers: [MBWorkRepo.Container] {
        return workRepos.flatMap { $0.containers }
    }

    public func containers(for tool: MBDependencyTool) -> [MBWorkRepo.Container] {
        return self.allContainers.filter { $0.tool == tool }
    }

    public func containers(named: String) -> [MBWorkRepo.Container] {
        return self.allContainers.filter { $0.isName(named) }
    }

    public func container(named: String, tool: MBDependencyTool) -> MBWorkRepo.Container? {
        return self.allContainers.first { $0.isName(named) && $0.tool == tool }
    }

    // MARK: - Activated Container
    public var activatedContainers: [MBWorkRepo.Container] {
        return MBDependencyTool.allTools.flatMap { self.activatedContainers(for: $0) }.withoutDuplicates()
    }

    public func activatedContainers(for tool: MBDependencyTool) -> [MBWorkRepo.Container] {
        let tools = Self.syncContainerToolsMap[tool] ?? [tool]
        var containers = [MBWorkRepo.Container]()
        for repo in self.repos {
            let names = tools.flatMap { repo.activatedContainers(for: $0) }.map { $0.lowercased() }.withoutDuplicates()
            containers << names.compactMap { name in
                repo.workRepository?.containers.first { $0.tool == tool && $0.isName(name) }
            }
        }
        return containers
    }

    public func activatedContainer(_ name: String, for tool: MBDependencyTool) -> MBWorkRepo.Container? {
        return self.activatedContainers(for: tool).first { $0.isName(name) }
    }

    public func isActivated(container: MBWorkRepo.Container) -> Bool {
        return self.activatedContainer(container.name, for: container.tool) != nil
    }

    // MARK: - Action
    // MARK: Deactivate
    public func deactivateContainer(_ name: String) {
        for container in self.containers(named: name) {
            container.repoConfig.deactivateContainer(container.name, for: container.tool)
        }
    }

    public func deactivateContainer(tool: MBDependencyTool) {
        for container in self.containers(for: tool) {
            container.repoConfig.deactivateContainer(container.name, for: container.tool)
        }
    }

    public func deactivateContainer(_ name: String, tool: MBDependencyTool) {
        guard let container = self.container(named: name, tool: tool) else { return }
        self.deactivateContainer(container)
    }

    public func deactivateContainer(_ container: MBWorkRepo.Container) {
        for tool in containerTools(for: container.tool) {
            container.repoConfig.deactivateContainer(container.name, for: tool)
        }
    }

    // MARK: Activate
    private func shouldDeactivateContainer(for container: MBWorkRepo.Container?, tool: MBDependencyTool) -> [MBWorkRepo.Container] {
        var result = [MBWorkRepo.Container]()
        let allowMultiple = container?.repo.setting.container?.isAllowMultipleContainers(for: tool) == true || MBSetting.merged.container?.isAllowMultipleContainers(for: tool) == true
        if !allowMultiple {
            for container in self.activatedContainers(for: tool) {
                if container.repo.setting.container?.isAllowMultipleContainers(for: tool) != true {
                    result.append(container)
                }
            }
        }
        return result
    }

    public func activateContainer(_ container: MBWorkRepo.Container) {
        self.activateContainers([container])
    }

    public func activateContainers(_ containers: [MBWorkRepo.Container]) {
        let tools = containers.flatMap { containerTools(for: $0.tool) }.withoutDuplicates()
        let containers = containers.flatMap { self.containers(named: $0.name).filter { tools.contains($0.tool) } }.withoutDuplicates()

        var deactivateContainers = [MBWorkRepo.Container]()
        for tool in tools {
            let activateContainers = containers.filter({ $0.tool == tool })
            if activateContainers.isEmpty {
                deactivateContainers.append(contentsOf: self.shouldDeactivateContainer(for: nil, tool: tool))
            } else {
                for container in activateContainers {
                    deactivateContainers.append(contentsOf: self.shouldDeactivateContainer(for: container, tool: tool))
                }
            }
        }
        deactivateContainers.removeDuplicates()
        deactivateContainers.removeAll { containers.contains($0) }


        for container in deactivateContainers {
            container.repoConfig.deactivateContainer(container.name, for: container.tool)
        }
        for container in containers {
            container.repoConfig.activateContainer(container.name, for: container.tool)
        }
    }
}
