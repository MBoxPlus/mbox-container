//
//  MBConfig.Feature.swift
//  MBoxContainer
//
//  Created by cppluwang on 2020/8/6.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import MBoxCore
import MBoxDependencyManager

extension MBConfig.Feature {

    dynamic
    public func description(for containers: [MBWorkRepo.Container]) -> Row {
        let row = Row()
        var toolString = [String]()
        for container in containers {
            if self.isActivated(container: container) {
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

        for repo in self.workRepos {
            for (_, var containers) in Dictionary(grouping: repo.containers, by: \.name).sorted(by: \.key) {
                for tools in syncTools {
                    var syncContainers = [MBWorkRepo.Container]()
                    for tool in tools.sorted() {
                        if let container = containers.removeFirst(where: { $0.tool == tool
                        }) {
                            syncContainers.append(container)
                        }
                    }
                    if syncContainers.isEmpty {
                        continue
                    }
                    list.append(description(for: syncContainers))
                }
                for container in containers {
                    list.append(description(for: [container]))
                }
            }
        }

        list.sort(by: { (a, b) -> Bool in
            return a.description.joined(separator: "\n") < a.description.joined(separator: "\n")
        })
        return list
    }

    // MARK: - Container Files
    dynamic
    public func allContainerFiles(platformTool: MBDependencyTool) -> [String] {
        return []
    }

    dynamic
    public func clearWorkspaceEnv(platformTool: MBDependencyTool) throws {
    }

    static let ContainerBackupRoot = "containers"

    private func containerBackupDir(repos: [MBConfig.Repo], platformTool: MBDependencyTool) -> String {

        let dir = Workspace.configDir.appending(pathComponent: MBConfig.Feature.ContainerBackupRoot).appending(pathComponent: name).appending(pathComponent: platformTool.name)

        let containers = self.activatedContainers(for: platformTool)

        if containers.isEmpty {
            return dir.appending(pathComponent: "NO_CONTAINER")
        }
        return dir.appending(pathComponent: containers.map { "\($0.repo!.name)-\($0.name)" }.joined(separator: "|"))
    }
    
    public func backupContainerFiles(tool: MBDependencyTool) throws {
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
    
    public func restoreContainerFiles(tool: MBDependencyTool) throws {
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
