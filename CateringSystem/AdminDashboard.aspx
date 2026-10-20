<%@ Page Title="管理控制台" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="CateringSystem.AdminDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        /* 页面标题 */
        .admin-header {
            margin-bottom: 25px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .admin-header h2 { color: #2d3436; font-weight: 800; font-size: 24px; margin: 0; }
        .admin-header .date-badge {
            background: #dfe6e9; color: #636e72;
            padding: 5px 12px; border-radius: 20px; font-size: 13px; font-weight: 600;
        }

        /* 核心指标卡片 (Top Row) */
        .stat-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-box {
            background: white;
            padding: 25px;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.04);
            display: flex;
            justify-content: space-between;
            align-items: center;
            transition: transform 0.3s ease;
            border: 1px solid #f1f2f6;
        }
        .stat-box:hover { transform: translateY(-5px); border-color: #26c6da; }
        
        .stat-content h3 { font-size: 32px; font-weight: 800; margin: 0; color: #2d3436; letter-spacing: -1px; }
        .stat-content p { margin: 5px 0 0; color: #b2bec3; font-size: 13px; font-weight: 600; text-transform: uppercase; }
        
        .stat-icon {
            width: 55px; height: 55px;
            border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 24px;
        }
        .icon-purple { background: #e0f7fa; color: #00acc1; }
        .icon-blue { background: #e0f2f1; color: #009688; }
        .icon-orange { background: #e0fbf6; color: #00bfa5; }

        /* 主体布局 (Grid Layout) */
        .main-dashboard-layout {
            display: grid;
            grid-template-columns: 2fr 1fr; /* 左侧占2份，右侧占1份 */
            gap: 25px;
        }

        /* 左侧：图表容器 */
        .chart-card {
            background: white;
            border-radius: 16px;
            padding: 25px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.04);
            height: 100%;
            min-height: 450px;
            display: flex;
            flex-direction: column;
        }
        
        .chart-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .chart-title { font-size: 18px; font-weight: 700; color: #2d3436; }

        /* 图表切换按钮组 */
        .chart-toggles {
            background: #f1f2f6;
            padding: 4px;
            border-radius: 8px;
            display: flex;
            gap: 5px;
        }
        .chart-btn {
            border: none;
            background: transparent;
            padding: 6px 12px;
            border-radius: 6px;
            font-size: 12px;
            font-weight: 600;
            color: #636e72;
            cursor: pointer;
            transition: all 0.2s;
        }
        .chart-btn.active {
            background: white;
            color: var(--primary-color);
            box-shadow: 0 2px 5px rgba(0,0,0,0.05);
        }

        .canvas-container {
            flex: 1;
            position: relative;
            width: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* 右侧：管理快捷入口 */
        .quick-actions {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }

        .action-card {
            background: var(--glass-bg);
            border-radius: 16px;
            padding: 25px;
            text-decoration: none;
            color: inherit;
            box-shadow: 0 8px 24px rgba(34,197,94,.08);
            transition: all 0.3s;
            display: flex;
            align-items: center;
            gap: 20px;
            border-left: 5px solid transparent;
        }
        
        .action-card:hover { transform: translateX(5px); }

        .action-card.purple { border-left-color: #26c6da; }
        .action-card.green { border-left-color: #00bfa5; }
        .action-card.blue { border-left-color: #00acc1; }

        .action-icon {
            width: 50px; height: 50px;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 20px;
            background: #f8f9fa;
            color: #636e72;
            transition: 0.3s;
        }
        
        .action-card:hover .action-icon { background: var(--primary-color); color: white; }
        .action-card.green:hover .action-icon { background: #00bfa5; }
        .action-card.blue:hover .action-icon { background: #26c6da; }

        .action-text h4 { margin: 0 0 5px 0; font-size: 16px; color: #2d3436; }
        .action-text p { margin: 0; font-size: 12px; color: #b2bec3; }

        /* 响应式 */
        @media (max-width: 768px) {
            .main-dashboard-layout { grid-template-columns: 1fr; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="admin-header">
        <h2 style="color: var(--primary-color)">管理控制台</h2>
        <div class="date-badge"><i class="far fa-calendar-alt"></i> <%= DateTime.Now.ToString("yyyy-MM-dd") %></div>
    </div>
    

    <!-- 1. 核心指标 -->
    <div class="stat-grid">
        <div class="stat-box">
            <div class="stat-content">
                <h3>¥ <asp:Label ID="lblTotalSales" runat="server" Text="0.00"></asp:Label></h3>
                <p>总销售额 (历史)</p>
            </div>
            <div class="stat-icon icon-orange"><i class="fas fa-coins"></i></div>
        </div>
        <div class="stat-box">
            <div class="stat-content">
                <h3><asp:Label ID="lblOrderCount" runat="server" Text="0"></asp:Label></h3>
                <p>总完成订单</p>
            </div>
            <div class="stat-icon icon-blue"><i class="fas fa-receipt"></i></div>
        </div>
        <div class="stat-box">
            <div class="stat-content">
                <h3><asp:Label ID="lblDishCount" runat="server" Text="0"></asp:Label></h3>
                <p>在售菜品数</p>
            </div>
            <div class="stat-icon icon-purple"><i class="fas fa-utensils"></i></div>
        </div>
    </div>

    <div class="main-dashboard-layout">
        
        <!-- 2. 左侧：交互式图表 -->
        <div class="chart-card">
            <div class="chart-header">
                <div class="chart-title"><i class="fas fa-chart-pie"></i> 经营数据分析</div>
                <div class="chart-toggles">
                    <button type="button" class="chart-btn active" onclick="switchChart('category')">分类占比</button>
                    <button type="button" class="chart-btn" onclick="switchChart('top5')">热销 Top5</button>
                    <button type="button" class="chart-btn" onclick="switchChart('trend')">营收趋势</button>
                </div>
            </div>
            <div class="canvas-container">
                <canvas id="mainChart"></canvas>
            </div>
        </div>

        <!-- 3. 右侧：快捷管理入口 -->
        <div class="quick-actions">
            <h4 style="margin:0 0 10px 0; color:#636e72; font-size:14px;">系统设置直达</h4>
            
            <a href="ManageDishes.aspx" class="action-card purple">
                <div class="action-icon"><i class="fas fa-book"></i></div>
                <div class="action-text">
                    <h4>菜品管理</h4>
                    <p>修改价格、上架新品</p>
                </div>
            </a>

            <a href="ManageTables.aspx" class="action-card green">
                <div class="action-icon"><i class="fas fa-chair"></i></div>
                <div class="action-text">
                    <h4>桌台管理</h4>
                    <p>设置包间、管理座位</p>
                </div>
            </a>

            <a href="ManageStaffs.aspx" class="action-card blue">
                <div class="action-icon"><i class="fas fa-user-tie"></i></div>
                <div class="action-text">
                    <h4>员工管理</h4>
                    <p>账号注册、权限分配</p>
                </div>
            </a>
        </div>

    </div>

    <!-- JS 逻辑 -->
    <script>
        // 从后端获取的 JSON 数据字符串
        // 必须用单引号包裹，防止 HTML 实体转码问题
        var rawData = {
            catLabels: '<%= CatLabels %>',
            catData: '<%= CatData %>',
            topLabels: '<%= TopDishLabels %>',
            topData: '<%= TopDishData %>',
            trendLabels: '<%= TrendLabels %>',
            trendData: '<%= TrendData %>'
        };

        var myChart = null;

        // 页面加载完成后执行
        document.addEventListener('DOMContentLoaded', function () {
            switchChart('category'); // 默认显示分类饼图
        });

        function switchChart(type) {
            // 1. 切换按钮样式
            document.querySelectorAll('.chart-btn').forEach(btn => btn.classList.remove('active'));
            event.target.classList.add('active');

            // 2. 解析数据
            var ctx = document.getElementById('mainChart').getContext('2d');
            var config = {};

            try {
                if (type === 'category') {
                    // --- 饼状图：分类占比 ---
                    var labels = JSON.parse(rawData.catLabels);
                    var data = JSON.parse(rawData.catData);

                    config = {
                        type: 'doughnut', // 甜甜圈图 (比纯饼图更好看)
                        data: {
                            labels: labels.length ? labels : ['无数据'],
                            datasets: [{
                                data: data.length ? data : [1],
                                backgroundColor: ['#22c55e', '#4ade80', '#86efac', '#bbf7d0', '#dcfce7'],
                                borderWidth: 0
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                legend: { position: 'right' },
                                title: { display: true, text: '各分类销量占比' }
                            }
                        }
                    };
                } else if (type === 'top5') {
                    // --- 柱状图：热销 Top 5 ---
                    var labels = JSON.parse(rawData.topLabels);
                    var data = JSON.parse(rawData.topData);

                    config = {
                        type: 'bar',
                        data: {
                            labels: labels,
                            datasets: [{
                                label: '销量 (份)',
                                data: data,
                                backgroundColor: '#22c55e',
                                borderRadius: 5
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: { legend: { display: false } },
                            scales: { y: { beginAtZero: true } }
                        }
                    };
                } else if (type === 'trend') {
                    // --- 折线图：营收趋势 ---
                    var labels = JSON.parse(rawData.trendLabels);
                    var data = JSON.parse(rawData.trendData);

                    config = {
                        type: 'line',
                        data: {
                            labels: labels,
                            datasets: [{
                                label: '每日营收 (元)',
                                data: data,
                                borderColor: '#22c55e',
                                backgroundColor: 'rgba(34, 197, 94, 0.15)',
                                fill: true,
                                tension: 0.4
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: { legend: { display: false } },
                            scales: { y: { beginAtZero: true } }
                        }
                    };
                }

                // 3. 销毁旧图表并绘制新图表
                if (myChart) myChart.destroy();
                myChart = new Chart(ctx, config);

            } catch (e) {
                console.error("图表渲染失败:", e);
            }
        }
    </script>

</asp:Content>