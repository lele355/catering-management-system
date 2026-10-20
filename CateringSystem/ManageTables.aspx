<%@ Page Title="桌台管理" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ManageTables.aspx.cs" Inherits="CateringSystem.ManageTables" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        /* 复用通用样式 */
        .admin-container { background: white; padding: 30px; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); }
        .page-header { display: flex; align-items: center; margin-bottom: 30px; border-bottom: 2px solid #f1f2f6; padding-bottom: 15px; }
        .page-header h2 { margin: 0; color: #2d3436; font-weight: 800; }
        .page-header i { margin-right: 10px; color: var(--primary-color); font-size: 24px; }

        .add-box { background: #f8f9fa; padding: 20px; margin-bottom: 30px; border-radius: 12px; border: 1px solid #eee; display: flex; gap: 15px; align-items: flex-end; }
        .form-control { padding: 10px 15px; border: 1px solid #dfe6e9; border-radius: 8px; outline: none; }
        .btn-save { background: var(--primary-color); color: white; border: none; padding: 10px 20px; border-radius: 8px; font-weight: 600; cursor: pointer; transition: 0.2s; }
        .btn-save:hover { background: #00a990; }

        .modern-table { width: 100%; border-collapse: collapse; border-radius: 8px; overflow: hidden; }
        .modern-table th { background: #00bfa5; color: white; padding: 15px; text-align: left; }
        .modern-table td { padding: 15px; border-bottom: 1px solid #f1f2f6; color: #2d3436; }
        
        .status-dot { display: inline-block; width: 8px; height: 8px; border-radius: 50%; margin-right: 5px; }
        .status-free { background: #00bfa5; box-shadow: 0 0 0 2px rgba(0,191,165,0.2); }
        .status-occupied { background: #26c6da; box-shadow: 0 0 0 2px rgba(38, 198, 218, 0.2); }
        
        .btn-del { background: #e0fbf6; color: #00a990; padding: 5px 10px; border-radius: 6px; text-decoration: none; font-size: 12px; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:UpdatePanel ID="upTables" runat="server">
        <ContentTemplate>
    <div class="admin-container">
        <div class="page-header">
            <i class="fas fa-chair"></i>
            <h2 style="color: var(--primary-color)">桌台与包间管理</h2>
        </div>
        

        <div class="add-box">
            <div style="flex: 1; max-width: 300px;">
                <div style="margin-bottom:5px; font-weight:600; color:#666; font-size:13px;">新增桌台/包间名称</div>
                <asp:TextBox ID="txtTableName" runat="server" CssClass="form-control" placeholder="例如：8号桌 / 豪华包间" style="width:100%"></asp:TextBox>
            </div>
            <asp:Button ID="btnAdd" runat="server" Text="+ 立即添加" CssClass="btn-save" OnClick="btnAdd_Click" />
        </div>

        <asp:GridView ID="gvTables" runat="server" CssClass="modern-table" AutoGenerateColumns="False" DataKeyNames="桌台编号"
            GridLines="None" OnRowDeleting="gvTables_RowDeleting">
            <Columns>
                <%-- 修正处：ItemStyle-Color 改为 ItemStyle-ForeColor --%>
                <asp:BoundField DataField="桌台编号" HeaderText="ID" ReadOnly="True" ItemStyle-Width="80px" ItemStyle-ForeColor="#b2bec3" />
                
                <%-- 修正处：ItemStyle-Font-Weight="Bold" 改为 ItemStyle-Font-Bold="true" --%>
                <asp:BoundField DataField="桌台名称" HeaderText="桌台名称" ItemStyle-Font-Bold="true" />
                
                <asp:TemplateField HeaderText="当前状态">
                    <ItemTemplate>
                        <span class="status-dot <%# Eval("当前状态").ToString() == "Free" ? "status-free" : "status-occupied" %>"></span>
                        <%# Eval("当前状态").ToString() == "Free" ? "空闲中" : "使用中" %>
                    </ItemTemplate>
                </asp:TemplateField>
                
                <asp:TemplateField HeaderText="操作" ItemStyle-Width="100px">
                    <ItemTemplate>
                        <asp:LinkButton ID="btnDel" runat="server" CommandName="Delete" CssClass="btn-del" OnClientClick="return confirm('确认删除该桌台吗？');">
                            <i class="fas fa-trash-alt"></i> 删除
                        </asp:LinkButton>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
            <EmptyDataTemplate>暂无桌台数据</EmptyDataTemplate>
        </asp:GridView>
    </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
