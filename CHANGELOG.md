# 2022/02/22

[Added] 新增单仓库多容器模型支持

[Optimize] 如果没有激活的容器，则不尝试分析 `checkout-from-commit` 信息

[Changed] 切换容器后(`mbox container use`)将只打印容器状态，不再打印所有的 `mbox status` 信息

[Changed] 重新设计 Container 模型，现在支持禁用所有容器

[Fixed] 修复当配置中存在相同依赖管理工具的容器时导致 Crash
