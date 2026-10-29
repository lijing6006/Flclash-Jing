# 模拟界面 / Mock widget previews

这些PNG是Flutter 3.47.6实际渲染的本项目Widget，采用固定假数据，**不是Windows运行截图或真实代理流量**。四种尺寸/主题已人工检查；文字使用本机Noto CJK字体，没有复制字体文件。仅展示进程代理页面，未伪造系统窗口或侧栏。

Regenerate with `PROCESS_PROXY_PREVIEW_DIR=<output-directory> flutter test test/views/process_proxy_preview_test.dart`. Set `PROCESS_PROXY_PREVIEW_FONT` to an existing local CJK font if needed. No backend/process/CA/capture action occurs. Ordinary CI runs layout assertions without writing images or requiring the local font.
