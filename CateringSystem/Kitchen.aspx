<%@ Page Title="后厨看板" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Kitchen.aspx.cs" Inherits="CateringSystem.Kitchen" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!-- 自动刷新页面 (每30秒刷新一次，确保厨师看到最新订单) -->
    <meta http-equiv="refresh" content="30" />
    
    <style>
        /* 看板头部 */
        .kitchen-header {
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            margin-bottom: 20px;
        }
        
        .header-top {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .header-title h2 { margin: 0; color: var(--primary-color); display: flex; align-items: center; gap: 10px; }
        .header-info { color: #636e72; font-size: 14px; }

        /* 筛选控制栏 */
        .filter-bar {
            display: flex;
            gap: 15px;
            align-items: center;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 8px;
        }
        .filter-label {
            font-weight: 600;
            color: #636e72;
            font-size: 14px;
        }
        .filter-buttons {
            display: flex;
            gap: 8px;
        }
        .filter-btn {
            padding: 8px 16px;
            border: 2px solid #dfe6e9;
            background: white;
            color: #636e72;
            border-radius: 20px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s;
        }
        .filter-btn:hover { border-color: var(--primary-color); color: var(--primary-color); }
        .filter-btn.active { background: var(--primary-color); border-color: var(--primary-color); color: white; }

        /* 分组标题 */
        .group-header { padding: 12px 20px; background: linear-gradient(135deg, #86efac 0%, #22c55e 100%); color: white; border-radius: 10px; font-weight: 600; font-size: 16px; margin-top: 15px; margin-bottom: 5px; display: flex; align-items: center; gap: 12px; box-shadow: 0 2px 10px rgba(34,197,94,0.3); }
        .group-count {
            background: rgba(255,255,255,0.25);
            padding: 4px 12px;
            border-radius: 12px;
            font-size: 13px;
            font-weight: 600;
        }

        /* 紧急标记 */
        .urgent-badge {
            position: absolute;
            top: 10px;
            right: 10px;
            background: #f97316; /* 保留橙色，便于与绿主题对比，强调紧急 */
            color: white;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 600;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.8; transform: scale(1.05); }
        }

        /* 任务列表布局 */
        .kitchen-grid {
            display: flex;
            flex-direction: column;
            gap: 12px;
            max-width: 1400px;
            margin: 0 auto;
        }

        /* 菜品卡片 - 横向列表样式 */
        .dish-card {
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
            border-left: 5px solid var(--primary-color);
            transition: all 0.3s;
            display: flex;
            align-items: center;
            padding: 16px 20px;
            gap: 20px;
            position: relative;
        }

        .dish-card:hover {
            box-shadow: 0 4px 16px rgba(0,0,0,0.12);
            transform: translateX(5px);
        }

        .dish-card.priority-high { border-left-color: #f97316; }
        .dish-card.priority-medium { border-left-color: #86efac; }
        .dish-card.priority-normal { border-left-color: #22c55e; }

        /* 菜品主信息 */
        .dish-main {
            flex: 0 0 280px;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .dish-icon { width: 48px; height: 48px; background: linear-gradient(135deg, #86efac 0%, #22c55e 100%); border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 24px; flex-shrink: 0; }

        .dish-info h3 {
            margin: 0;
            font-size: 20px;
            font-weight: 700;
            color: #2d3436;
            line-height: 1.3;
        }

        .dish-total {
            font-size: 14px;
            color: #636e72;
            margin-top: 4px;
        }

        .total-badge {
            display: inline-block;
            background: var(--primary-color);
            color: white;
            padding: 2px 10px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 13px;
        }

        /* 订单芯片列表 */
        .order-chips {
            flex: 1;
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            align-items: center;
        }

        .order-chip {
            background: #f8f9fa;
            border: 2px solid #e9ecef;
            border-radius: 20px;
            padding: 8px 16px;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.2s;
            cursor: pointer;
            position: relative;
        }

        .order-chip:hover { border-color: var(--primary-color); background: #e9f9ef; transform: scale(1.05); }
        }

        .order-chip:hover::after {
            content: "✓";
            position: absolute;
            right: -8px;
            top: -8px;
            background: var(--primary-color);
            color: white;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            font-weight: bold;
            box-shadow: 0 2px 8px rgba(34,197,94,0.35);
        }

        .chip-table {
            font-size: 13px;
            font-weight: 600;
            color: #2d3436;
            display: flex;
            align-items: center;
            gap: 4px;
        }

        .chip-qty {
            background: #ff6b6b;
            color: white;
            padding: 2px 8px;
            border-radius: 10px;
            font-size: 12px;
            font-weight: 600;
        }

        .chip-time {
            font-size: 11px;
            color: #95a5a6;
        }

        /* 批量完成按钮 */
        .dish-actions {
            flex: 0 0 auto;
            display: flex;
            gap: 10px;
        }

        .btn-done-all {
            padding: 10px 24px;
            background: linear-gradient(135deg, #86efac 0%, #22c55e 100%);
            color: white;
            border: none;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            white-space: nowrap;
            box-shadow: 0 2px 8px rgba(34,197,94,0.28);
        }

        .btn-done-all:hover {
            background: linear-gradient(135deg, #4ade80 0%, #16a34a 100%);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(34,197,94,0.35);
        }

        .btn-done-all:disabled {
            background: #dfe6e9;
            color: #b2bec3;
            cursor: not-allowed;
            box-shadow: none;
        }

        /* 空状态提示 */
        .empty-state {
            text-align: center;
            color: #b2bec3;
            margin-top: 50px;
            grid-column: 1 / -1;
        }
        .empty-state i { font-size: 60px; margin-bottom: 20px; color: #dfe6e9; }
    </style>

    <script>
        // 按钮样式由服务器端C#代码通过ScriptManager注册，无需额外JavaScript
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:UpdatePanel ID="upKitchen" runat="server">
        <ContentTemplate>
    <div class="kitchen-header">
        <div class="header-top">
            <div class="header-title">
                <h2><i class="fas fa-fire-alt"></i> 后厨制作看板</h2>
            </div>
            <div class="header-info">
                <i class="fas fa-sync-alt"></i> 页面每30秒自动刷新
                &nbsp;|&nbsp;
                待制作任务：<strong style="color:#22c55e"><asp:Label ID="lblCount" runat="server" Text="0"></asp:Label></strong> 个
            </div>
        </div>
        
        
        <div class="filter-bar">
            <span class="filter-label"><i class="fas fa-filter"></i> 分类方式:</span>
            <div class="filter-buttons">
                <asp:LinkButton ID="btnGroupByDish" runat="server" 
                    CssClass="filter-btn" 
                    OnClick="btnGroupBy_Click" CommandArgument="Dish">
                    <i class="fas fa-utensils"></i> 按菜品
                </asp:LinkButton>
                <asp:LinkButton ID="btnGroupByTable" runat="server" 
                    CssClass="filter-btn" 
                    OnClick="btnGroupBy_Click" CommandArgument="Table">
                    <i class="fas fa-chair"></i> 按桌号
                </asp:LinkButton>
                <asp:LinkButton ID="btnGroupByTime" runat="server" 
                    CssClass="filter-btn" 
                    OnClick="btnGroupBy_Click" CommandArgument="Time">
                    <i class="fas fa-clock"></i> 按时间
                </asp:LinkButton>
            </div>
            
            <span class="filter-label" style="margin-left: 20px;"><i class="fas fa-sort"></i> 排序:</span>
            <div class="filter-buttons">
                <asp:LinkButton ID="btnSortAsc" runat="server" 
                    CssClass="filter-btn" 
                    OnClick="btnSort_Click" CommandArgument="ASC">
                    <i class="fas fa-arrow-up"></i> 时间升序
                </asp:LinkButton>
                <asp:LinkButton ID="btnSortDesc" runat="server" 
                    CssClass="filter-btn" 
                    OnClick="btnSort_Click" CommandArgument="DESC">
                    <i class="fas fa-arrow-down"></i> 时间降序
                </asp:LinkButton>
            </div>
        </div>
    </div>

    <div class="kitchen-grid">
        <asp:Repeater ID="rptKitchen" runat="server" OnItemCommand="rptKitchen_ItemCommand" OnItemDataBound="rptKitchen_ItemDataBound">
            <ItemTemplate>
                <!-- 分组标题 -->
                <asp:Panel ID="pnlGroupHeader" runat="server" Visible='<%# IsGroupHeaderRow(Eval("IsGroupHeader")) %>' CssClass="group-header">
                    <i class="fas fa-layer-group"></i>
                    <span><%# Eval("GroupHeader") ?? "" %></span>
                </asp:Panel>

                <!-- 菜品卡片 -->
                <asp:Panel ID="pnlDishCard" runat="server" Visible='<%# !IsGroupHeaderRow(Eval("IsGroupHeader")) %>' 
                    CssClass='<%# "dish-card " + GetPriorityClass(SafeGetWaitMinutes(Eval("最长等待时间"))) %>'>
                    
                    <!-- 紧急标记 -->
                    <asp:Panel ID="pnlUrgent" runat="server" CssClass="urgent-badge" 
                        Visible='<%# IsUrgent(Eval("最长等待时间")) %>'>
                        <i class="fas fa-exclamation-triangle"></i> 紧急
                    </asp:Panel>
                    
                    <!-- 菜品主信息 -->
                    <div class="dish-main">
                        <div class="dish-icon">
                            <i class='<%# CurrentGroupBy == "Table" ? "fas fa-chair" : "fas fa-utensils" %>'></i>
                        </div>
                        <div class="dish-info">
                            <h3><%# Eval("菜品名称") %></h3>
                            <div class="dish-total">
                                共 <span class="total-badge"><%# Eval("总数量") %></span> <%# CurrentGroupBy == "Table" ? "道菜" : "份" %>
                            </div>
                        </div>
                    </div>
                    
                    <!-- 订单芯片列表 -->
                    <div class="order-chips">
                        <asp:Repeater ID="rptOrderChips" runat="server" OnItemCommand="rptOrderChips_ItemCommand">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnChip" runat="server" CssClass="order-chip" 
                                    CommandName="DoneSingle" CommandArgument='<%# Eval("DetailId") %>'
                                    OnClientClick='<%# CurrentGroupBy == "Table" ? "return confirm(\"确认完成这道菜吗？\");" : "return confirm(\"确认完成这份菜吗？\");" %>'>
                                    <span class="chip-table">
                                        <i class='<%# CurrentGroupBy == "Table" ? "fas fa-utensils" : "fas fa-chair" %>'></i>
                                        <%# Eval("TableName") %>
                                    </span>
                                    <span class="chip-qty">×<%# Eval("Quantity") %></span>
                                    <span class="chip-time"><%# Eval("WaitMinutes") %>分</span>
                                </asp:LinkButton>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                    
                    <!-- 操作按钮 -->
                    <div class="dish-actions">
                        <asp:Button ID="btnDoneAll" runat="server" Text="✓ 全部完成" CssClass="btn-done-all" 
                            CommandName="DoneAll" CommandArgument='<%# Eval("订单明细") %>' />
                    </div>
                </asp:Panel>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-state">
            <i class="fas fa-check-circle"></i>
            <h3>所有菜品都做完了！</h3>
            <p>暂时没有新的点单任务</p>
        </asp:Panel>
    </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
