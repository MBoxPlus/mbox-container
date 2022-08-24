//
//  MBCommander+Container.swift
//  MBoxContainer
//
//  Created by Yao Li on 2021/5/31.
//  Copyright © 2021 com.bytedance. All rights reserved.
//

import MBoxCore

extension MBCommander {
    @_dynamicReplacement(for: setupEventParams())
    public func container_setupEventParams() -> [String: Any] {
        var eventParams = self.setupEventParams()
        if let containers = MBProcess.shared.workspace?.config.currentFeature.activatedContainers {
            eventParams["current_containers"] = containers.compactMap {
                [
                    "name": $0.name,
                    "path": $0.path,
                    "tool": $0.tool
                ]
            }
            eventParams["current_container_urls"] = containers.compactMap({ container in
                return container.repo?.gitURL?.toHTTPStyle()
            }).joined(separator: ",")
        }
        return eventParams
    }
}
