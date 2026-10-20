<%@ Page Title="订单管理" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Orders.aspx.cs" Inherits="CateringSystem.Orders" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        /* 状态概览栏 */
        .stats-bar {
            display: flex;
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            flex: 1;
            background: white;
            padding: 20px;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 12px;
            background: #ffeaa7;
            color: #fdcb6e;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 24px;
        }
        .stat-info h3 { margin: 0; font-size: 24px; color: #2d3436; }
        .stat-info p { margin: 0; color: #636e72; font-size: 14px; }

        /* 选项卡样式 */
        .tabs {
            display: flex;
            border-bottom: 2px solid #eee;
            margin-bottom: 20px;
        }
        .tab-btn {
            padding: 10px 20px;
            cursor: pointer;
            font-weight: 600;
            color: #636e72;
            border: none;
            background: none;
            border-bottom: 3px solid transparent;
            transition: all 0.3s;
        }
        .tab-btn.active { color: var(--primary-color); border-bottom-color: var(--primary-color); }

        /* 订单网格 */
        .orders-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(380px, 1fr));
            gap: 20px;
        }

        /* 订单卡片 - 紧凑模式 */
        .order-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            overflow: hidden;
            border-top: 4px solid #b2bec3;
            transition: all 0.3s;
            padding: 18px;
        }
        .order-card:hover { transform: translateY(-2px); box-shadow: 0 6px 20px rgba(0,0,0,0.12); }
        .order-card.pending { border-top-color: #86efac; }
        .order-card.paid { border-top-color: #22c55e; }

        .order-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 12px;
        }
        .table-badge {
            background: #2d3436;
            color: white;
            padding: 6px 14px;
            border-radius: 8px;
            font-weight: bold;
            font-size: 15px;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }
        .order-time { font-size: 11px; color: #999; margin-top: 4px; }
        .order-number { font-weight: 600; font-size: 13px; color: #2d3436; }
        .order-meta { text-align: right; }
        .order-waiter { font-size: 11px; color: #636e72; margin-top: 3px; }

        .order-summary {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0 0 0;
            border-top: 1px dashed #e8e8e8;
            margin-top: 12px;
        }
        .total-price {
            font-size: 26px;
            font-weight: bold;
            color: var(--primary-color);
            line-height: 1;
        }
        .order-actions {
            display: flex;
            gap: 8px;
            align-items: center;
        }
        .btn-pay {
            background: var(--primary-color);
            color: white;
            border: none;
            padding: 10px 18px;
            border-radius: 20px;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: 0.3s;
        }
        .btn-pay:hover { background: #16a34a; box-shadow: 0 4px 10px rgba(34,197,94,0.3); }
        .btn-disabled { background: #dfe6e9; color: #b2bec3; cursor: not-allowed; pointer-events: none; }
        .btn-view {
            background: #86efac;
            color: white;
            border: none;
            padding: 8px 14px;
            border-radius: 18px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 500;
            transition: 0.3s;
        }
        .btn-view:hover { background: #22c55e; }

        /* 模态窗口 */
        .modal-overlay {
            display: none;
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: rgba(0,0,0,0.5);
            z-index: 9998;
            animation: fadeIn 0.3s;
        }
        .modal-content {
            display: none;
            position: fixed;
            top: 50%; left: 50%;
            transform: translate(-50%, -50%);
            background: white;
            border-radius: 16px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            z-index: 9999;
            max-width: 500px;
            width: 90%;
            max-height: 80vh;
            overflow: hidden; /* 让滚动条在内部，从而保持圆角 */
            animation: slideUp 0.3s;
        }
        @keyframes slideUp {
            from { opacity: 0; transform: translate(-50%, -45%); }
            to { opacity: 1; transform: translate(-50%, -50%); }
        }
        .modal-header {
            padding: 20px;
            border-bottom: 2px solid #f1f2f6;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .modal-title { font-size: 20px; font-weight: bold; color: #2d3436; }
        .modal-close {
            background: none;
            border: none;
            font-size: 24px;
            color: #999;
            cursor: pointer;
            padding: 0;
            width: 30px;
            height: 30px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 50%;
            transition: 0.2s;
        }
        .modal-close:hover { background: #f1f2f6; color: #2d3436; }
        .modal-body { 
            padding: 20px; 
            max-height: calc(80vh - 120px); /* 减去头部/底部空间 */
            overflow-y: auto; /* 滚动条在内容区域内部 */
        }
        .dish-list {
            margin-bottom: 20px;
        }
        .dish-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px dashed #eee;
            font-size: 14px;
        }
        .dish-item:last-child { border-bottom: none; }
        .dish-info { flex: 1; }
        .dish-name { font-weight: 600; color: #2d3436; }
        .dish-price { color: #636e72; }
        .dish-status {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 12px;
            font-size: 11px;
            font-weight: 600;
            margin-left: 10px;
        }
        .status-waiting { background: #ecfdf5; color: #16a34a; }
        .status-done { background: #e9f9ef; color: #22c55e; }
        .modal-stats {
            display: flex;
            gap: 15px;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 8px;
            margin-bottom: 15px;
        }
        .stat-item {
            flex: 1;
            text-align: center;
        }
        .stat-value {
            font-size: 20px;
            font-weight: bold;
            color: #2d3436;
        }
        .stat-label {
            font-size: 12px;
            color: #636e72;
            margin-top: 4px;
        }
        .stat-item.waiting .stat-value { color: #16a34a; }
        .stat-item.done .stat-value { color: #22c55e; }
        .modal-footer {
            padding: 20px;
            background: #f8f9fa;
            border-top: 1px solid #f1f2f6;
            text-align: right;
        }

    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:UpdatePanel ID="upOrders" runat="server">
        <ContentTemplate>
    
    <!-- 1. 状态概览 -->
    <div class="stats-bar">
        <div class="stat-card">
            <div class="stat-icon" style="background:#fff4e6; color:#fdcb6e"><i class="fas fa-clock"></i></div>
            <div class="stat-info">
                <h3><asp:Label ID="lblPendingCount" runat="server" Text="0"></asp:Label></h3>
                <p>进行中订单</p>
            </div>
        </div>
        <div class="stat-card">
            <div class="stat-icon" style="background:#e6fcf5; color:#00b894"><i class="fas fa-check-circle"></i></div>
            <div class="stat-info">
                <h3><asp:Label ID="lblTodayRevenue" runat="server" Text="0"></asp:Label></h3>
                <p>今日已结账金额 (元)</p>
            </div>
        </div>
    </div>

    <!-- 2. 选项卡切换 -->
    <div class="tabs">
        <asp:LinkButton ID="btnTabPending" runat="server" CssClass="tab-btn active" OnClick="SwitchTab_Click" CommandArgument="Pending">进行中</asp:LinkButton>
        <asp:LinkButton ID="btnTabHistory" runat="server" CssClass="tab-btn" OnClick="SwitchTab_Click" CommandArgument="History">历史记录</asp:LinkButton>
    </div>

    <!-- 3. 订单列表 -->
    <div class="orders-grid">
        <asp:Repeater ID="rptOrders" runat="server" OnItemDataBound="rptOrders_ItemDataBound" OnItemCommand="rptOrders_ItemCommand">
            <ItemTemplate>
                <div class='order-card <%# Eval("订单状态").ToString() == "Pending" ? "pending" : "paid" %>'>
                    <div class="order-header">
                        <div>
                            <span class="table-badge"><i class="fas fa-chair"></i> <%# Eval("桌台名称") %></span>
                            <div class="order-time"><%# Eval("下单时间", "{0:MM-dd HH:mm}") %></div>
                        </div>
                        <div class="order-meta">
                            <div class="order-number">单号: #<%# Eval("订单编号") %></div>
                            <div class="order-waiter">服务员: <%# Eval("真实姓名") %></div>
                        </div>
                    </div>
                    
                    <div class="order-summary">
                        <span class="total-price">¥ <%# Eval("订单总额", "{0:N2}") %></span>
                        <div class="order-actions">
                            <button type="button" class="btn-view" onclick='showOrderDetail(<%# Eval("订单编号") %>)'>
                                <i class="fas fa-list"></i> 详情
                            </button>
                            <!-- 只有进行中的订单才显示结账按钮 -->
                            <asp:Button ID="btnCheckout" runat="server" Text="结账" CssClass="btn-pay" 
                                CommandName="Checkout" CommandArgument='<%# Eval("订单编号") %>'
                                Visible='<%# Eval("订单状态").ToString() == "Pending" %>' 
                                OnClientClick="return confirm('确认要结账并释放桌台吗？');" />
                            
                            <asp:Label ID="lblStatus" runat="server" Text="已完成" CssClass="btn-pay btn-disabled" 
                                Visible='<%# Eval("订单状态").ToString() == "Paid" %>'></asp:Label>
                        </div>
                    </div>

                    <!-- 隐藏的明细数据，供模态窗口使用 -->
                    <div class="order-details" style="display:none;" data-order-id='<%# Eval("订单编号") %>'>
                        <asp:Repeater ID="rptDetails" runat="server">
                            <ItemTemplate>
                                <div class="dish-item" data-status='<%# Eval("制作状态") %>'>
                                    <div class="dish-info">
                                        <span class="dish-name"><%# Eval("菜品名称") %> x<%# Eval("点菜数量") %></span>
                                        <span class='dish-status status-<%# Eval("制作状态").ToString().ToLower() %>'>
                                            <%# Eval("制作状态").ToString() == "Waiting" ? "制作中" : "已完成" %>
                                        </span>
                                    </div>
                                    <span class="dish-price">¥<%# Eval("小计", "{0:N2}") %></span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>

    <!-- 模态窗口 -->
    <div class="modal-overlay" id="modalOverlay" onclick="closeModal()"></div>
    <div class="modal-content" id="modalContent">
        <div class="modal-header">
            <div class="modal-title"><i class="fas fa-receipt"></i> 订单详情</div>
            <button class="modal-close" onclick="closeModal()">&times;</button>
        </div>
        <div class="modal-body" id="modalBody">
            <!-- 动态加载订单明细 -->
        </div>
    </div>

    <script>
        function showOrderDetail(orderId) {
            // 查找对应订单的明细
            var detailsDiv = document.querySelector('[data-order-id="' + orderId + '"]');
            if (!detailsDiv) return;
            
            // 统计菜品状态
            var allItems = detailsDiv.querySelectorAll('.dish-item');
            var waitingCount = 0;
            var doneCount = 0;
            
            allItems.forEach(function(item) {
                var status = item.getAttribute('data-status');
                if (status === 'Waiting') waitingCount++;
                else if (status === 'Done') doneCount++;
            });
            
            // 构建统计信息
            var statsHtml = '<div class="modal-stats">' +
                '<div class="stat-item">' +
                    '<div class="stat-value">' + (waitingCount + doneCount) + '</div>' +
                    '<div class="stat-label">总菜品数</div>' +
                '</div>' +
                '<div class="stat-item waiting">' +
                    '<div class="stat-value">' + waitingCount + '</div>' +
                    '<div class="stat-label">制作中</div>' +
                '</div>' +
                '<div class="stat-item done">' +
                    '<div class="stat-value">' + doneCount + '</div>' +
                    '<div class="stat-label">已完成</div>' +
                '</div>' +
            '</div>';
            
            // 复制明细内容到模态窗口
            var modalBody = document.getElementById('modalBody');
            modalBody.innerHTML = statsHtml + '<div class="dish-list">' + detailsDiv.innerHTML + '</div>';
            
            // 显示模态窗口
            document.getElementById('modalOverlay').style.display = 'block';
            document.getElementById('modalContent').style.display = 'block';
        }

        function closeModal() {
            document.getElementById('modalOverlay').style.display = 'none';
            document.getElementById('modalContent').style.display = 'none';
        }

        // ESC键关闭
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') closeModal();
        });
    </script>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
