//
//  MBConfig.Feature.swift
//  MBoxContainer
//
//  Created by Whirlwind on 2020/9/2.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore

extension MBConfig.Feature {
    @_dynamicReplacement(for: plugins(for:))
    public func container_plugins(for repo: MBConfig.Repo) -> [String: MBSetting.PluginDescriptor] {
        let plugins = self.plugins(for: repo)
        let plugins2 = plugins.filter { (name, plugin) -> Bool in
            !plugin.onlyContainer
        }
        if plugins.count == plugins2.count {
            return plugins
        }

        defer {
            for repo in self.workRepos {
                repo.resetContainerCache()
            }
        }

        if self.containers(named: repo.name).contains(where: {
            self.isActivated(container: $0)
        }) {
            return plugins
        }
        return plugins2
    }
}
