//
//  MBContainer.swift
//  MBoxContainer
//
//  Created by cppluwang on 2020/8/10.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import MBoxCore
import MBoxWorkspaceCore
import MBoxDependencyManager

extension MBWorkRepo {
    dynamic
    open func fetchContainers() -> [MBContainer] {
        return []
    }

    open var containers: [MBContainer] {
        let value = self.fetchContainers()
        for container in value {
            container.feature = self.model.feature
            container.repo = self.model
        }
        return value
    }

}
