# 餐饮管理系统

ASP.NET 连锁餐饮订单处理系统 + 业务分析报告

## 功能模块

| 角色 | 页面 | 功能 |
|---|---|---|
| 顾客 | `Default` / `Menu` / `Cart` | 浏览菜单、点餐、购物车 |
| 厨房 | `Kitchen` | 订单流转与出餐 |
| 员工 | `OrderManagement` | 订单处理 |
| 管理员 | `AdminHome` / `AdminDashboard` | 管理主页与数据概览 |
| 管理员 | `ManageDishes` / `ManageTables` / `ManageStaffs` | 菜品、桌台、员工管理 |
| 通用 | `Login` | 用户认证 |

配套文档：**《服务业：连锁餐饮企业订单处理业务分析报告》**（`.docx`）与 LaTeX 论文（`tex/论文.tex`）。

## 目录结构

```
CateringSystem/            ASP.NET 工程源码
  *.aspx / *.aspx.cs       各业务页面
  Web.config               数据库连接（口令已脱敏）
  CateringSystem.csproj
tex/
  论文.tex / 论文.pdf       课程论文 LaTeX 源与成品
服务业：连锁餐饮企业订单处理业务分析报告.docx
```

## 技术栈

ASP.NET WebForms · C# · SQL Server · ADO.NET · XeLaTeX

## 复现提示

Visual Studio 打开工程还原 NuGet 包；建库后修改 `Web.config` 连接字符串。数据库文件（`.mdf` / `.ldf`）未纳入版本管理。

> **安全说明**：源码与配置中涉及的数据库连接口令，已全部替换为占位符 `YOUR_PASSWORD_HERE`。本地复现时请自行配置数据库账号。



---

**安家乐** · 西安理工大学 机械工程学院 · 工业工程（2023 级 / 2027 届）

GitHub：[@Lele355](https://github.com/Lele355)

*本仓库内容为个人学习成果，仅供学习交流参考。*
