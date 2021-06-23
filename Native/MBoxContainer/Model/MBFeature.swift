//
//  MBConfig.Feature.swift
//  MBoxContainer
//
//  Created by 詹迟晶 on 2020/9/2.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspaceCore

extension MBConfig.Feature {
    @_dynamicReplacement(for: plugins(for:))
    public func container_plugins(for repo: MBConfig.Repo) -> [String: MBSetting.PluginDescriptor] {
        let plugins = self.plugins(for: repo)
        if self.currentContainers.isEmpty || self.currentContainerRepos.contains(repo) {
            return plugins
        }
        return plugins.filter { (name, plugin) -> Bool in
            !plugin.onlyContainer
        }
    }

    @_dynamicReplacement(for: reposDidChanged)
    public func container_reposDidChanged() {
        self.reposDidChanged()
        let repoNames = self.repos.map(\.name)
        self.currentContainers.removeAll {
            !repoNames.contains($0.repoName)
        }
    }

    @_dynamicReplacement(for: exportKeys)
    open var container_exportKeys: [String] {
        var keys = self.exportKeys
        keys.append("current_containers")
        return keys
    }
}
