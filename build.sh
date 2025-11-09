#!/bin/bash

echo "=== 鸿蒙日记应用构建脚本 ==="
echo ""

# 检查是否在正确的目录
if [ ! -f "oh-package.json5" ]; then
    echo "错误: 请在项目根目录运行此脚本"
    exit 1
fi

echo "1. 清理项目..."
hpm clean

echo ""
echo "2. 安装依赖..."
hpm install

echo ""
echo "3. 构建项目..."
hpm build

echo ""
echo "4. 构建完成！"
echo ""
echo "下一步操作："
echo "- 在DevEco Studio中打开项目"
echo "- 连接鸿蒙设备或启动模拟器"
echo "- 点击运行按钮部署应用"
echo ""
echo "应用功能："
echo "- 用户注册和登录"
echo "- 日记的增删改查"
echo "- 本地数据库存储"
echo ""
echo "祝您使用愉快！"
