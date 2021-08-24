//
//  MBConfig.Feature.swift
//  MBoxContainer
//
//  Created by cppluwang on 2020/8/6.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import MBoxCore
import MBoxWorkspaceCore
import MBoxDependencyManager

extension MBConfig.Feature {

    // MARK: - Current Container
    public var currentContainers: [MBContainer] {
        set {
            self.dictionary["current_containers"] = newValue
        }
        get {
            let v: [MBContainer] = self.value(forPath: "current_containers")
            v.forEach {
                $0.feature = self
            }
            return v
        }
    }

    public func currentContainers(for tool: MBDependencyTool) -> [MBContainer] {
        return currentContainers.filter {
            $0.tool == tool
        }
    }

    public func currentContainer(name: String, for tool: MBDependencyTool) -> MBContainer? {
        return currentContainers.first {
            $0.tool == tool && $0.isName(name)
        }
    }

    public func currentContainer(named: String) -> MBContainer? {
        return self.currentContainers.first { $0.isName(named) }
    }

    public func isCurrentContainer(_ container: MBContainer) -> Bool {
        return self.currentContainers.contains(container)
    }

    public func isCurrentContainer(name: String, for tool: MBDependencyTool? = nil) -> Bool {
        return currentContainers.contains { (container) -> Bool in
            if let tool = tool, container.tool != tool {
                return false
            }
            return container.isName(name)
        }
    }

    public var currentContainerRepos: [MBConfig.Repo] {
        return self.currentContainers.compactMap(\.repo).withoutDuplicates()
    }

    public func currentContainerRepos(for tool: MBDependencyTool) -> [MBConfig.Repo] {
        return currentContainers(for: tool).compactMap(\.repo).withoutDuplicates()
    }

    // MARK: - All Containers
    public func containers(for tool: MBDependencyTool) -> [MBContainer] {
        return self.allContainers.filter {
            $0.tool == tool
        }
    }

    public func container(for tool: MBDependencyTool) -> MBContainer? {
        let value = self.currentContainers(for: tool)
        if value.count > 0 {
            return value.first!
        }
        return self.containers(for: tool).first
    }

    public func container(named: String) -> [MBContainer] {
        return self.allContainers.filter { $0.isName(named) }
    }

    public func container(named: String, tool: MBDependencyTool? = nil) -> MBContainer? {
        let all: [MBContainer]
        if let tool = tool {
            all = self.containers(for: tool)
        } else {
            all = self.allContainers
        }
        return all.first { $0.isName(named) }
    }

    public func containerRepos(for tool: MBDependencyTool) -> [MBConfig.Repo] {
        return containers(for: tool).compactMap(\.repo).withoutDuplicates()
    }

    dynamic
    public var allContainers: [MBContainer] {
        return repos.compactMap { $0.containers }.flatMap { $0 }.then {
            $0.feature = self
        }
    }

    dynamic
    public func description(for containers: [MBContainer]) -> Row {
        let row = Row()
        var toolString = [String]()
        for container in containers {
            if self.isActivatedContainer(container) {
                row.selected = true
                toolString.append(container.tool.name.ANSI(.yellow))
            } else {
                toolString.append(container.tool.name)
            }
        }
        var name = containers.first!.name
        if row.selected {
            name = name.ANSI(.yellow)
        }
        row.columns = [name, toolString.joined(separator: " + ")]
        return row
    }

    public var allContainerDescriptions: [Row] {
        let containers = self.allContainers
        guard !containers.isEmpty else {
            return [Row(column: "It is empty!")]
        }
        var list = [Row]()
        let syncTools = Self.syncContainerToolsMap.values

        for repo in self.repos {
            var containers = Dictionary(uniqueKeysWithValues: repo.containers.map { ($0.tool, $0) })
            for tools in syncTools {
                var syncContainers = [MBContainer]()
                for tool in tools.sorted() {
                    if let container = containers.removeValue(forKey: tool) {
                        syncContainers.append(container)
                    }
                }
                if syncContainers.isEmpty {
                    continue
                }
                list.append(description(for: syncContainers))
            }
            for container in containers.values {
                list.append(description(for: [container]))
            }
        }

        list.sort(by: { (a, b) -> Bool in
            return a.description.joined(separator: "\n") < a.description.joined(separator: "\n")
        })
        return list
    }

    // MARK: - Activated Container
    public var activatedContainers: [MBContainer] {
        let containers = MBDependencyTool.allTools.flatMap { self.activatedContainers(for: $0) }.withoutDuplicates()
        if !containers.isEmpty {
            return containers
        }
        return self.allContainers
    }

    public var activatedContainerRepos: [MBConfig.Repo] {
        return activatedContainers.compactMap(\.repo).withoutDuplicates()
    }

    public func activatedContainers(for tool: MBDependencyTool) -> [MBContainer] {
        for t in Self.syncContainerToolsMap[tool] ?? [tool] {
            var containers = currentContainers(for: t)
            if containers.isEmpty { continue }
            if tool == t {
                return containers
            }
            containers = containers.compactMap {
                self.container(named: $0.name, tool: tool)
            }
            if !containers.isEmpty {
                return containers
            }
        }
        return self.containers(for: tool)
    }

    public func activatedContainer(_ name: String, for tool: MBDependencyTool) -> MBContainer? {
        for t in Self.syncContainerToolsMap[tool] ?? [tool] {
            let containers = currentContainers(for: t)
            if containers.isEmpty { continue }
            guard let container = containers.first(where: { $0.isName(name) }) else {
                return nil
            }
            if tool == t {
                return container
            }
            if let container = self.container(named: name, tool: tool) {
                return container
            }
        }
        return self.container(named: name, tool: tool)
    }

    public func activatedContainerRepos(for tool: MBDependencyTool) -> [MBConfig.Repo] {
        return activatedContainers(for: tool).compactMap(\.repo).withoutDuplicates()
    }

    public func isActivatedContainer(_ container: MBContainer) -> Bool {
        return self.activatedContainer(container.name, for: container.tool) != nil
    }

    // MARK: - Container Files
    dynamic
    open func allContainerFiles(platformTool: MBDependencyTool) -> [String] {
        return []
    }

    dynamic
    open func clearWorkspaceEnv(platformTool: MBDependencyTool) throws {
    }

    static let ContainerBackupRoot = "containers"

    private func containerBackupDir(repos: [MBConfig.Repo], platformTool: MBDependencyTool) -> String {

        let dir = Workspace.configDir.appending(pathComponent: MBConfig.Feature.ContainerBackupRoot).appending(pathComponent: name).appending(pathComponent: platformTool.name)

        let containers = self.activatedContainers(for: platformTool)

        if containers.isEmpty {
            return dir.appending(pathComponent: "NO_CONTAINER")
        }
        return dir.appending(pathComponent: containers.map { "\($0.repoName)-\($0.name)" }.joined(separator: "|"))
    }
    
    open func backupContainerFiles(tool: MBDependencyTool) throws {
        let containerFiles = allContainerFiles(platformTool: tool)
        if containerFiles.isEmpty {
            return
        }

        let backupDir = containerBackupDir(repos: repos, platformTool: tool)
        if backupDir.isDirectory {
            try FileManager.default.removeItem(atPath: backupDir)
        }
        try FileManager.default.createDirectory(atPath: backupDir, withIntermediateDirectories: true, attributes: nil)

        try containerFiles.forEach { file in
            let path = Workspace.rootPath.appending(pathComponent: file)
            if path.isExists {
                let target = backupDir.appending(pathComponent: file)
                try FileManager.default.moveItem(atPath: path, toPath: target)
            }
        }
    }
    
    open func restoreContainerFiles(tool: MBDependencyTool) throws {
        let containerFiles = allContainerFiles(platformTool: tool)
        if containerFiles.isEmpty {
            return
        }

        let backupDir = containerBackupDir(repos: repos, platformTool: tool)
        if !backupDir.isDirectory {
            return
        }

        try FileManager.default.contentsOfDirectory(atPath: backupDir).forEach { (file) in
            let path = backupDir.appending(pathComponent: file)
            if path.isExists {
                let target = Workspace.rootPath.appending(pathComponent: file)
                if target.isExists {
                    try FileManager.default.removeItem(atPath: target)
                }
                try FileManager.default.moveItem(atPath: path, toPath: target)
            }
        }

        try FileManager.default.removeItem(atPath: backupDir)
    }
}
