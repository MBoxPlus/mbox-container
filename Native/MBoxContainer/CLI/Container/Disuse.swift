//
//  Disuse.swift
//  MBoxContainer
//
//  Created by Yao Li on 2020/8/11.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxDependencyManager

extension MBCommander.Container {
    open class Disuse: Switch {

        open class override var description: String? {
            return "Deactive container in current feature"
        }

        dynamic
        open override func validate() throws {
            try super.validate()
        }

        dynamic
        open override func switchContainers(_ containers: [MBWorkRepo.Container]) throws {
            UI.log(info: "Disuse containers:") {
                for container in containers {
                    self.config.currentFeature.deactivateContainer(container)
                }
            }
            try super.switchContainers(containers)
        }
    }
}

