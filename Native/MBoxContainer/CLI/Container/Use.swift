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

        dynamic
        open override func validate() throws {
            try super.validate()
        }

        dynamic
        open override func switchContainer(_ container: MBContainer) throws {
            try super.switchContainer(container)
            let currentFeature = self.config.currentFeature
            UI.log(info: "Use container `\(container.name)` for \(container.tool)")
            currentFeature.activateContainer(container)
            self.config.save()
        }
    }
}
