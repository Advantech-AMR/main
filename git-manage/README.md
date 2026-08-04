# 專案 Git 管理方式
> 此專案使用 vcstool 管理外部 sub-modules，主要包含 zed_packages 下面的 zed ROS2 相關套件，因此相關 git modules 拉下來的套件都會在主專案的 Git 被 ignore 掉

## 初始化
```bash
# 進入 git-manage/

# 同步 zed 相關的 repos
vcs import ../zed_packages/src < zed_packages.repos

# 同步其他自訂義 package repos
vcs import ../custom_packages/src < custom_packages.repos

# 同步機器人基礎 packages
vcs import ../robot_base < robot_base.repos
```

## 更新
```bash
# 進入 git-manage/
vcs pull ../zed_packages/src
vcs pull ../custom_packages/src
vcs pull ../robot_base
```

## 將某個資料夾內的所有倉庫加入管理 (For Reference)
```bash
# 進入 git-manage/
vcs export <path> > <name>.repos
```
