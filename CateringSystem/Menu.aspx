<%@ Page Title="电子菜单" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Menu.aspx.cs" Inherits="CateringSystem.Menu" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        /* 左右分栏布局 */
        .menu-layout {
            display: flex;
            gap: 20px;
            height: calc(100vh - 100px); /* 占满剩余高度 */
            overflow: hidden;
        }

        /* 左侧：菜品区 */
        .menu-left {
            flex: 1;
            display: flex;
            flex-direction: column;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            padding: 20px;
            overflow: hidden;
        }

        /* 分类筛选条 */
        .category-bar {
            display: flex;
            gap: 10px;
            overflow-x: auto;
            padding-bottom: 10px;
            margin-bottom: 15px;
            border-bottom: 1px solid #eee;
        }
        
        .cat-btn {
            padding: 8px 16px;
            background: #e9f9ef;
            border: none;
            border-radius: 20px;
            color: #166534;
            cursor: pointer;
            white-space: nowrap;
            font-weight: 600;
            transition: 0.3s;
            text-decoration: none;
        }
        .cat-btn:hover, .cat-btn.active {
            background: var(--primary-color);
            color: #fff;
        }

        /* 菜品网格 */
        .dish-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
            gap: 15px;
            overflow-y: auto;
            padding-right: 5px;
            flex: 1;
            /* 统一卡片高度 */
            grid-auto-rows: 200px;
            align-items: start;
        }
        
        /* 滚动条美化 */
        .dish-grid::-webkit-scrollbar {
            width: 6px;
        }
        .dish-grid::-webkit-scrollbar-thumb {
            background: #ddd;
            border-radius: 3px;
        }
        .dish-grid::-webkit-scrollbar-thumb:hover {
            background: #bbb;
        }

        .dish-card {
            border: 1px solid #eee;
            border-radius: 8px;
            padding: 10px;
            text-align: center;
            transition: 0.3s;
            height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: flex-start;
        }
        .dish-card:hover { border-color: var(--primary-color); box-shadow: 0 5px 15px rgba(34, 197, 94, 0.18); }
        
        .dish-icon { font-size: 32px; color: var(--primary-color); margin-bottom: 10px; }
        .dish-name { font-weight: bold; color: #2d3436; margin-bottom: 5px; font-size: 14px; }
        .dish-price { color: #16a34a; font-weight: bold; }
        
        .btn-add-cart {
            margin-top: 10px;
            width: 100%;
            padding: 6px;
            background: var(--primary-color);
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
        }

        /* 右侧：订单栏 */
        .menu-right {
            width: 350px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            display: flex;
            flex-direction: column;
            border-top: 5px solid #2d3436;
        }

        .order-header {
            padding: 20px;
            border-bottom: 1px solid #eee;
            background: #f8f9fa;
        }

        .order-list {
            flex: 1;
            overflow-y: auto;
            padding: 15px;
        }

        .order-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 0;
            border-bottom: 1px dashed #eee;
        }
        .item-info { font-size: 14px; color: #333; font-weight: 600; }
        .item-price { font-size: 12px; color: #999; }
        
        .qty-control { display: flex; align-items: center; gap: 5px; }
        .btn-qty {
            width: 24px; height: 24px;
            border-radius: 50%;
            border: 1px solid #ddd;
            background: white;
            cursor: pointer;
            font-size: 12px;
            color: #666;
        }
        .btn-qty:hover { border-color: var(--primary-color); color: var(--primary-color); }

        .order-footer {
            padding: 20px;
            border-top: 1px solid #eee;
            background: #fff;
        }

        .total-row {
            display: flex;
            justify-content: space-between;
            font-size: 18px;
            font-weight: bold;
            margin-bottom: 15px;
            color: #2d3436;
        }

        .btn-submit {
            width: 100%;
            padding: 12px;
            background: var(--primary-color);
            color: white;
            border: none;
            border-radius: 6px;
            font-size: 16px;
            cursor: pointer;
            transition: 0.3s;
        }
        .btn-submit:hover { background: #16a34a; box-shadow: 0 5px 15px rgba(34, 197, 94, 0.28); }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:UpdatePanel ID="upMenu" runat="server">
        <ContentTemplate>
    <div class="menu-layout">
        <!-- 左侧：菜品选择区 -->
        <div class="menu-left">
            <!-- 分类筛选 -->
            <div class="category-bar">
                <asp:LinkButton ID="btnAll" runat="server" CssClass="cat-btn" OnClick="btnFilter_Click" CommandArgument="All">全部</asp:LinkButton>
                <asp:Repeater ID="rptCategories" runat="server">
                    <ItemTemplate>
                        <asp:LinkButton ID="btnCat" runat="server" CssClass='<%# IsActiveCategory(Eval("Category").ToString()) %>' 
                            OnClick="btnFilter_Click" CommandArgument='<%# Eval("Category") %>'>
                            <%# Eval("Category") %>
                        </asp:LinkButton>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
            

            <!-- 菜品列表 -->
            <div class="dish-grid">
                <asp:Repeater ID="rptDishes" runat="server" OnItemCommand="rptDishes_ItemCommand">
                    <ItemTemplate>
                        <div class="dish-card">
                            <div class="dish-icon"><i class="fas fa-utensils"></i></div>
                            <div class="dish-name"><%# Eval("菜品名称") %></div>
                            <div class="dish-price">¥<%# Eval("单价", "{0:N0}") %></div>
                            <asp:Button ID="btnAdd" runat="server" Text="+ 加入列表" CssClass="btn-add-cart" 
                                CommandName="Add" CommandArgument='<%# Eval("菜品编号") + "|" + Eval("菜品名称") + "|" + Eval("单价") %>' />
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <!-- 右侧：点单列表 (购物车) -->
        <div class="menu-right">
            <div class="order-header">
                <div style="margin-bottom:10px; font-weight:bold; color:#636e72;">当前桌台</div>
                <asp:DropDownList ID="ddlTables" runat="server" CssClass="form-control" style="width:100%; padding:8px; border-radius:6px; border:1px solid #ddd;">
                </asp:DropDownList>
            </div>

            <div class="order-list">
                <asp:Repeater ID="rptCart" runat="server" OnItemCommand="rptCart_ItemCommand">
                    <ItemTemplate>
                        <div class="order-item">
                            <div>
                                <div class="item-info"><%# Eval("DishName") %></div>
                                <div class="item-price">¥<%# Eval("Price", "{0:N0}") %> x <%# Eval("Quantity") %></div>
                            </div>
                            <div class="qty-control">
                                <asp:Button ID="btnMinus" runat="server" Text="-" CssClass="btn-qty" CommandName="Minus" CommandArgument='<%# Eval("DishId") %>' />
                                <span style="font-weight:bold; width:20px; text-align:center;"><%# Eval("Quantity") %></span>
                                <asp:Button ID="btnPlus" runat="server" Text="+" CssClass="btn-qty" CommandName="Plus" CommandArgument='<%# Eval("DishId") %>' />
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                
                <asp:Panel ID="pnlEmptyCart" runat="server" Visible="false" style="text-align:center; color:#ccc; margin-top:50px;">
                    <i class="fas fa-shopping-basket" style="font-size:40px; margin-bottom:10px;"></i>
                    <div>还没有选择菜品</div>
                </asp:Panel>
            </div>

            <div class="order-footer">
                <div class="total-row">
                    <span>合计</span>
                    <span style="color:#ff6b6b">¥ <asp:Label ID="lblTotal" runat="server" Text="0.00"></asp:Label></span>
                </div>
                <asp:Button ID="btnSubmit" runat="server" Text="确认下单" CssClass="btn-submit" OnClick="btnSubmit_Click" OnClientClick="return confirm('确定要提交订单吗？');" />
            </div>
        </div>

    </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
