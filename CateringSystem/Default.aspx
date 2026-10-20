<%@ Page Title="工作台" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="CateringSystem.Default" %>

<%-- 这里的代码会被塞进母版页的 <head> 里 --%>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .welcome-card {
            background: white;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.05);
            text-align: center;
            margin-bottom: 30px;
        }
        .welcome-card h1 { margin: 0; color: #333; }
        .welcome-card p { color: #666; margin-top: 10px; }

        .dashboard-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 25px;
        }

        .action-card {
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            transition: transform 0.3s, box-shadow 0.3s;
            cursor: pointer;
            text-decoration: none;
            color: inherit;
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
        }

        .action-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
        }

        .card-icon {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: rgba(0,191,165,0.1);
            color: var(--primary-color);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
            margin-bottom: 20px;
        }

        .card-title { font-weight: 700; font-size: 18px; margin-bottom: 10px; }
        .card-desc { color: #888; font-size: 14px; }
    </style>
</asp:Content>

<%-- 这里的代码会被塞进母版页的 MainContent 区域 --%>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- 欢迎区 -->
    <div class="welcome-card">
        <h1 style="color: var(--primary-color)">👋 你好，<%= Session["RealName"] %>！</h1>
        <p>今天是 <%= DateTime.Now.ToString("yyyy年MM月dd日 dddd") %>，祝你工作顺利。</p>
    </div>
    

    <!-- 功能入口区 -->
    <div class="dashboard-grid">
        <!-- 点餐入口 -->
        <a href="Menu.aspx" class="action-card">
            <div class="card-icon"><i class="fas fa-book-open"></i></div>
            <div class="card-title">开始点餐</div>
            <div class="card-desc">为顾客开台、浏览菜单并下单</div>
        </a>

        <!-- 订单入口 -->
        <a href="Orders.aspx" class="action-card">
            <div class="card-icon"><i class="fas fa-list-alt"></i></div>
            <div class="card-title">订单管理</div>
            <div class="card-desc">查看桌台状态和历史订单详情</div>
        </a>

        <!-- 后厨入口 (简单模拟权限控制) -->
        <% if (Session["Role"]?.ToString() == "Manager" || Session["Role"]?.ToString() == "Chef") { %>
        <a href="Kitchen.aspx" class="action-card">
            <div class="card-icon"><i class="fas fa-fire"></i></div>
            <div class="card-title">后厨看板</div>
            <div class="card-desc">查看待制作的菜品，并在出餐后点击确认</div>
        </a>
        <% } %>
    </div>

</asp:Content>