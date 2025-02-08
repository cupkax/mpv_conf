# mpv-scipts

## adevice-list.lua

OSD 交互式音频设备菜单，依赖 [scroll-list.lua](https://github.com/CogentRedTester/mpv-scroll-list)

## chapter-list.lua

OSD 交互式章节菜单，依赖 [scroll-list.lua](https://github.com/CogentRedTester/mpv-scroll-list)

修改自 [CogentRedTester/mpv-scroll-list/chapter-list.lua](https://github.com/CogentRedTester/mpv-scroll-list/blob/master/examples/chapter-list.lua)

## chapter-make-read.lua

实现自动读取并加载视频文件同目录或指定的子目录（默认：`chapters`）下的同名 + 标识扩展的外部章节文件，默认扩展名：`.chp`

示例：`video.mp4.chp` 用于 `video.mp4`.

- 子目录和标识扩展名的更改可在`script-opts`下的脚本同名配置文件`chapter_make_read.conf`中设置
- 外部章节文件的时间戳尽可能使用`hh:mm:ss.sss`的 12 位格式
- 外部章节文件的文件编码应为 UTF-8，换行符为 Unix(LF)

以下几种外部章节文件的内容格式均被该脚本支持

```
00:00:00.000 A part
00:00:40.312 OP
00:02:00.873 B part
00:10:44.269 C part
00:22:40.146 ED
```

```
00:00:00.000
00:00:40.312
00:02:00.873
00:10:44.269
00:22:40.146
```

```
0:00:00 A part
0:00:40 OP
0:02:00 B part
0:10:44 C part
0:22:40 ED
```

```
0:00:00.000,Title1
0:17:02.148,Title2
0:28:10.114,Title3
```
 OGM format (`ogm`)

```
CHAPTER01=00:00:00.000
CHAPTER01NAME=Intro
CHAPTER02=00:02:30.000
CHAPTER02NAME=Baby prepares to rock
CHAPTER03=00:02:42.300
CHAPTER03NAME=Baby rocks the house
```
MediaInfo format (`mediainfo`)

```
Menu
00:00:00.000                : en:Contours
00:02:49.624                : en:From the Sea
00:08:41.374                : en:Bread and Wine
00:12:18.041                : en:Faceless
```

该脚本同时支持手动加载/刷新外部章节文件、标记新章节、编辑当前章节标题、删除当前章节和创建外部章节文件（也可用于导出已有的章节信息），用法如下：

在 mpv 的 input.conf 中绑定以下功能键位

```ini
# 手动加载/刷新外部章节文件
key script-message-to chapter_make_read load_chapter
# 标记章节时间
key script-message-to chapter_make_read create_chapter
# 删除当前章节
key script-message-to chapter_make_read remove_chapter
# 编辑当前章节标题
key script-message-to chapter_make_read edit_chapter
# 创建 mpv 可读的外部章节文件
key script-message-to chapter_make_read write_chapter chp
# 创建 mpv 可读的 ogm 格式章节文件
key script-message-to chapter_make_read write_chapter ogm
```
- 如果你想能够命名/重命名章节，mpv 版本的最低要求为 0.39.0 ，或者选择安装
  <https://github.com/CogentRedTester/mpv-user-input>

- 其他推荐
   -  另一个类似的 mpv 章节脚本：[mar04/chapters_for_mpv](https://github.com/mar04/chapters_for_mpv)
   -  章节格式转换工具：https://github.com/fireattack/chapter_converter
## drcbox.lua

动态调节各通道音增益的 dynnorm 滤镜菜单脚本

修改自 https://gist.github.com/richardpl/0c8011dc23d7ac7b7831b2e6d680114f

## edition-list.lua

OSD 交互式 edition 菜单，如果检测到播放文件存在多个 edition 则在 OSD 上提示。依赖 [scroll-list.lua](https://github.com/CogentRedTester/mpv-scroll-list)

修改自 [CogentRedTester/mpv-scripts/editions-notification.lua](https://github.com/CogentRedTester/mpv-scripts/blob/master/editions-notification.lua)


## mpv-animated.lua

使用 mpv 热键创建高质量的 webp/gif 动图，基于`ffmpeg`

修改自 [DonCanjas/mpv-webp-generator](https://github.com/DonCanjas/mpv-webp-generator)

## open_dialog.lua

快捷键载入文件夹/文件/ISO 文件/剪贴板（支持 URL）/其他字幕或音轨或视频轨（Windows）

**友情提醒**：Windows 10/11 用户建议配合 PowerShell 7 使用，优点：更好的性能，更现代化的对话框样式

- 官方安装命令：`winget install Microsoft.PowerShell`

灵感来自：[rossy/mpv-open-file-dialog](https://github.com/rossy/mpv-open-file-dialog), [tsl0922/dialog.lua](https://github.com/tsl0922/mpv-menu-plugin/blob/main/lua/dialog.lua)

## sub_export.lua

导出当前内封字幕，依赖 ffmpeg，脚本支持 srt、ass 和 sup 格式的字幕

修改自 [kelciour/mpv-scripts/sub-export.lua](https://github.com/kelciour/mpv-scripts/blob/master/sub-export.lua)

## track-list.lua

OSD 交互式轨道菜单，依赖 [scroll-list.lua](https://github.com/CogentRedTester/mpv-scroll-list)


## 更多 mpv 实用脚本请移步 [dyphire/mpv-config/scripts](https://github.com/dyphire/mpv-config/tree/master/scripts)