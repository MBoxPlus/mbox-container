//
//  MBWorkRepo.Container.swift
//  MBoxContainer
//
//  Created by cppluwang on 2020/12/16.
//  Copyright © 2020 com.bytedance. All rights reserved.
//

import Foundation
import MBoxCore
import MBoxDependencyManager

extension MBWorkRepo {
    open class Container: MBWorkRepo.Component {

        open var lock: Any?
        open var lockPath: String?
        open var lockAbsolutePath: String?
        open var lockParser: ((String) -> Any?)?

        @discardableResult
        public func withLock(_ lock: Any? = nil, path: String? = nil, lockParser: ((String) -> Any?)? = nil) -> Self {
            self.lock = lock
            self.lockPath = path
            self.lockParser = lockParser
            if let lockPath = self.lockPath {
                self.lockAbsolutePath = repo.path.appending(pathComponent: lockPath)
            }
            return self
        }

    }
}
extension MBWorkRepo.Container: CustomStringConvertible {
    public var description: String {
        return "Container `\(self.name)` (\(self.tool))"
    }
}
