//
//  MBCMD+Container.swift
//  MBoxContainer
//
//  Created by cppluwang on 2020/12/16.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import MBoxCore
import MBoxWorkspace
import MBoxDependencyManager

extension MBCMD {
    @_dynamicReplacement(for: setupEnvironment(_:))
    open func container_setupEnvironment(_ base: [String: String]? = nil) -> [String: String] {
        let env = self.setupEnvironment(base)

        // inject different envs for different platform
        // CocoaPods | Gradle | Flutter
        // MBOX_$_CONTAINER_REPOS
        // MBOX_COCOAPODS_CURRENT_CONTAINERS
        // MBOX_COCOAPODS_CURRENT_CONTAINERS_PATHS

        var containerEnvs: [String: String] = [:]
        let currentFeature = workspace.config.currentFeature

        let allContainerRepos = Dictionary(grouping: currentFeature.allContainers) { $0.tool }.mapValues { $0.map(\.repoName).withoutDuplicates() }
        for (tool, repos) in allContainerRepos {
            containerEnvs["MBOX_\(tool.description.uppercased())_CONTAINER_REPOS"] = repos.toJSONString(pretty: false)!
        }

        let activatedContainerRepos = Dictionary(grouping: currentFeature.currentContainers) { $0.tool }
        for (tool, containers) in activatedContainerRepos {
            let tool = tool.description.uppercased()
            containerEnvs["MBOX_\(tool)_CURRENT_CONTAINERS"] = containers.map(\.name).withoutDuplicates().toJSONString(pretty: false)!
            containerEnvs["MBOX_\(tool)_CURRENT_CONTAINER_REPOS"] = containers.map(\.repoName).withoutDuplicates().toJSONString(pretty: false)!
            containerEnvs["MBOX_\(tool)_CURRENT_CONTAINERS_PATHS"] = containers.compactMap { $0.repo?.workingPath }.withoutDuplicates().toJSONString(pretty: false)!
        }
        return env.merging(containerEnvs, uniquingKeysWith: { $1 })
    }
}
