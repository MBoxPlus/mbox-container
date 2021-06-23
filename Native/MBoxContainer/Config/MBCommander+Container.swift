//
//  MBCommander+Container.swift
//  MBoxContainer
//
//  Created by Yao Li on 2021/5/31.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import MBoxCore

extension MBCommander {
    @_dynamicReplacement(for:setupEventParams())
    open func container_setupEventParams() -> [String: Any] {
        var eventParams = self.setupEventParams()
        if let containers = UI.workspace?.config.currentFeature.currentContainers {
            eventParams["current_containers"] = containers.compactMap { container in
                return container.toCodableObject()
            }
        }
        return eventParams
    }
}
