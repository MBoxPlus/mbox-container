//
//  Container.swift
//  MBoxContainer
//
//  Created by Yao Li on 2020/8/6.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import MBoxCore

extension MBCommander {
    open class Container: MBCommander {

        open override func setup() throws {
            try super.setup()
        }

        open class override var description: String? {
            return "Manage Container"
        }

        open override func run() throws {
            try super.run()
            if type(of: self) == MBCommander.Container.self {
                throw ArgumentError.invalidCommand(nil)
            }
        }
    }
}
