<%@ Page Title="管理首页" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminHome.aspx.cs" Inherits="CateringSystem.AdminHome" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        /* 欢迎横幅 - 紫色系代表管理权限 */
        .welcome-banner {
            background: linear-gradient(120deg, #86efac, #22c55e);
            border-radius: 12px;
            padding: 40px;
            color: white;
            margin-bottom: 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 10px 20px rgba(34, 197, 94, 0.2);
        }
        .welcome-text h1 { margin: 0; font-size: 28px; }
        .welcome-text p { margin: 10px 0 0 0; opacity: 0.9; }

        /* 功能卡片网格 */
        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 25px;
        }

        .action-card {
            background: white;
            padding: 30px;
            border-radius: 12px;
            text-align: center;
            text-decoration: none;
            color: inherit;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            border: 1px solid transparent;
            display: block;
        }

        .action-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 30px rgba(0,0,0,0.1);
            border-color: var(--primary-color);
        }

        .icon-box {
            width: 60px;
            height: 60px;
            margin: 0 auto 20px auto;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }

        /* 图标背景色 */
        .bg-purple { background-color: #e9f9ef; color: #22c55e; }
        .bg-blue { background-color: #ecfdf5; color: #16a34a; }
        .bg-green { background-color: #dcfce7; color: #16a34a; }
        .bg-orange { background-color: #fff7ed; color: #ea580c; }

        .card-title { font-size: 18px; font-weight: 700; color: #2d3436; margin-bottom: 8px; }
        .card-desc { font-size: 13px; color: #b2bec3; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- 1. 欢迎横幅 -->
    <div class="welcome-banner">
        <div class="welcome-text">
            <h1 style="color: var(--primary-color)">管理员，您好！ 👋</h1>
            <p>当前系统运行正常，请选择操作。</p>
        </div>
        <div class="weather-icon">
            <i class="fas fa-user-shield fa-3x" style="opacity: 0.8;"></i>
        </div>
    </div>

    <!-- 2. 管理功能入口 -->
    <h3 style="margin-bottom: 10px; color: var(--primary-color);">管理中心</h3>
    
    <div class="dashboard-grid">
        <!-- 营收报表入口 -->
        <a href="AdminDashboard.aspx" class="action-card">
            <div class="icon-box bg-blue">
                <i class="fas fa-chart-line"></i>
            </div>
            <div class="card-title">营收统计</div>
            <div class="card-desc">查看每日流水、销售趋势图表</div>
        </a>

        <!-- 系统设置入口 -->
        <a href="SystemSettings.aspx" class="action-card">
            <div class="icon-box bg-purple">
                <i class="fas fa-cogs"></i>
            </div>
            <div class="card-title">系统基础设置</div>
            <div class="card-desc">菜品、桌台、员工信息的维护</div>
        </a>

        <!-- 前台点餐 (管理员也可以操作前台) -->
        <a href="Default.aspx" class="action-card">
            <div class="icon-box bg-orange">
                <i class="fas fa-store"></i>
            </div>
            <div class="card-title">前台收银</div>
            <div class="card-desc">切换至服务员视角进行点餐操作</div>
        </a>
    </div>

</asp:Content>