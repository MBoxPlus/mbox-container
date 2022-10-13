//
//  MBConfig.swift
//  MBoxContainer
//
//  Created by 詹迟晶 on 2021/10/21.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspace
import MBoxDependencyManager

extension MBConfig {
    @discardableResult
    public func migrateContainers(feature: MBConfig.Feature? = nil) -> Bool {
        var changed = false
        let features = feature == nil ? Array(self.features.values) : [feature!]
        for feature in features {
            guard let currentContainers = feature.dictionary.removeValue(forKey: "current_containers") as? [[String: String]] else {
                continue
            }

            changed = true
            var containerGroups = [String: [MBDependencyTool: [String]]]()
            var tools = [MBDependencyTool]()
            for info in currentContainers {
                guard let repoName = info["repo_name"] ?? info["name"],
                      let toolName = info["tool"] else {
                    continue
                }
                let tool = MBDependencyTool(toolName)
                if !tools.contains(tool) {
                    tools << tool
                }
                let name = (info["name"] ?? repoName).lowercased()
                var values = containerGroups[name] ?? [:]
                var names = values[tool] ?? []
                if !names.contains(name) {
                    names << name
                }
                values[tool] = names
                containerGroups[name] = values
            }

            for repo in feature.repos {
                guard repo.containers == nil else {
                    continue
                }
                let infos = containerGroups[repo.name.lowercased()] ?? [:]
                for tool in tools {
                    if let names = infos[tool], !names.isEmpty {
                        repo.activateContainers(names, for: tool, override: true)
                    } else {
                        repo.deactiveAllContainers(for: tool)
                    }
                }
            }
        }
        return changed
    }
}
