//
//  Use.swift
//  MBoxContainer
//
//  Created by Yao Li on 2020/8/6.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspaceCore
import MBoxDependencyManager

extension MBCommander.Container {
    open class Use: Switch {

        open class override var description: String? {
            return "Active container in current feature"
        }

        dynamic
        open override func validate() throws {
            try super.validate()
        }

        dynamic
        open override func switchContainer(_ container: MBContainer) throws {
            try super.switchContainer(container)
            UI.log(info: "Use container `\(container.name)` for \(container.tool)") {
                let currentFeature = self.config.currentFeature
                currentFeature.activateContainer(container)
            }
        }
    }
}
