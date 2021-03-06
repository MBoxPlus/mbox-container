//
//  Disuse.swift
//  MBoxContainer
//
//  Created by Yao Li on 2020/8/11.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxWorkspaceCore
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
        open override func switchContainer(_ container: MBContainer) throws {
            UI.log(info: "Disuse container `\(container.name)` for \(container.tool)")
            self.config.currentFeature.deactivateContainer(container)
            try super.switchContainer(container)
        }
    }
}

