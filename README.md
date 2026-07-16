# 昆明全市 · GIS 建筑 Demo

昆明区县 / 街道 / 小区三维建筑演示站点（静态页面，可 GitHub Pages 部署）。

## 在线入口

- GIS 地图：`index.html`
- 工具导航：`product.html`

## 本地预览

```bash
python3 -m http.server 8765
```

打开 http://127.0.0.1:8765/index.html

## 功能概要

- 点选区县展开真实小区名与栋数标注
- Demo 楼栋形态（围合 / 行列 / U 形）
- 卫星 / 浅色 / 深色底图切换
- 手机底部面板自适应

## 数据说明

- `communities.geojson` / `buildings.geojson`：金江路样板本地数据
- 全市小区名来自公开名录；街道来自 OSM；栋数优先 OSM 统计，否则 Demo 估算
