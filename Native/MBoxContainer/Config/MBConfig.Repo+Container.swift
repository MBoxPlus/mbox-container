//
//  MBRepo+Container.swift
//  MBoxContainer
//
//  Created by Whirlwind on 2021/5/17.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspaceCore
import MBoxDependencyManager

extension MBConfig.Repo {
    public func containers(for tool: MBDependencyTool) -> [MBContainer] {
        return self.containers.filter {
            $0.tool == tool
        }
    }

    public func activatedContainers(for tool: MBDependencyTool) -> [MBContainer] {
        guard let feature = self.feature else { return [] }
        let containers = self.containers(for: tool)
        return containers.filter {
            feature.isActivatedContainer($0)
        }
    }

    dynamic
    open var containers: [MBContainer] {
        return self.workRepository?.containers ?? []
    }
}
