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

    public var allContainerDescriptions: [Row] {
        let containers = self.allContainers
        guard !containers.isEmpty else {
            return [Row(column: "It is empty!")]
        }
        var list = [Row]()
        containers.forEach { container in
            list.append(container.description(feature: self))
        }

        list.sort(by: { (a, b) -> Bool in
            return a.description.joined(separator: "\n") < a.description.joined(separator: "\n")
        })
        return list
    }

    // MARK: - Activated Container
    public var activatedContainers: [MBContainer] {
        let containers = currentContainers
        if !containers.isEmpty {
            return containers
        }
        return self.allContainers
    }

    public var activatedContainerRepos: [MBConfig.Repo] {
        return activatedContainers.compactMap(\.repo).withoutDuplicates()
    }

    public func activatedContainers(for tool: MBDependencyTool) -> [MBContainer] {
        let containers = currentContainers(for: tool)
        if !containers.isEmpty {
            return containers
        }
        return self.containers(for: tool)
    }

    public func activatedContainerRepos(for tool: MBDependencyTool) -> [MBConfig.Repo] {
        return activatedContainers(for: tool).compactMap(\.repo).withoutDuplicates()
    }

    public func isActivatedContainer(_ container: MBContainer) -> Bool {
        let containers = self.currentContainers(for: container.tool)
        if containers.isEmpty { return true }
        return containers.contains(container)
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

        var containers = self.currentContainers(for: platformTool)
        if containers.isEmpty {
            containers = self.containers(for: platformTool)
        }

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
