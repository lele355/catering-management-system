<%@ Page Title="系统基础设置" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SystemSettings.aspx.cs" Inherits="CateringSystem.SystemSettings" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .settings-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 30px;
            margin-top: 20px;
        }

        .setting-card {
            background: white;
            border-radius: 15px;
            padding: 30px;
            text-align: center;
            text-decoration: none;
            color: #2d3436;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            transition: all 0.3s ease;
            border: 1px solid #eee;
            display: flex;
            flex-direction: column;
            align-items: center;
        }

        .setting-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 30px rgba(0,0,0,0.1);
            border-color: green;
        }

        .setting-icon {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: #f8f9fa;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 32px;
            margin-bottom: 20px;
            color: #636e72;
            transition: all 0.3s;
        }

        .setting-card:hover .setting-icon {
            background: var(--primary-color);
            color: white;
        }

        .setting-title { font-size: 20px; font-weight: 700; margin-bottom: 10px; }
        .setting-desc { color: #b2bec3; font-size: 14px; line-height: 1.5; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <h2 style="color: var(--primary-color); border-left: 5px solid var(--primary-color); padding-left: 15px; margin-bottom: 20px;">系统基础信息设置</h2>
    <div class="settings-grid">
        <!-- 1. 菜品管理 -->
        <a href="ManageDishes.aspx" class="setting-card">
            <div class="setting-icon"><i class="fas fa-utensils"></i></div>
            <div class="setting-title">菜品信息管理</div>
            <div class="setting-desc">添加新菜品、修改价格、设置分类、上架或下架菜品。</div>
        </a>

        <!-- 2. 桌台管理 -->
        <a href="ManageTables.aspx" class="setting-card">
            <div class="setting-icon"><i class="fas fa-chair"></i></div>
            <div class="setting-title">桌台/包间管理</div>
            <div class="setting-desc">新增餐厅桌位、设置包间名称、管理桌台状态。</div>
        </a>

        <!-- 3. 员工管理 -->
        <a href="ManageStaffs.aspx" class="setting-card">
            <div class="setting-icon"><i class="fas fa-user-tie"></i></div>
            <div class="setting-title">员工信息管理</div>
            <div class="setting-desc">注册新员工账号、重置密码、分配角色权限（店长/厨师/服务员）。</div>
        </a>
    </div>

    <div style="margin-top: 30px;">
        <a href="AdminHome.aspx" style="color: var(--primary-color); text-decoration: none;"><i class="fas fa-arrow-left"></i> 返回管理首页</a>
    </div>

</asp:Content>