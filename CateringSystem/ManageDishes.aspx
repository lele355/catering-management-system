<%@ Page Title="菜品管理" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ManageDishes.aspx.cs" Inherits="CateringSystem.ManageDishes" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        /* 现代化容器 */
        .admin-container {
            background: white;
            padding: 30px;
            border-radius: 16px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.05);
        }

        .page-header {
            display: flex;
            align-items: center;
            margin-bottom: 30px;
            border-bottom: 2px solid #f1f2f6;
            padding-bottom: 15px;
        }
        .page-header h2 { margin: 0; color: #2d3436; font-weight: 800; }
        .page-header i { margin-right: 10px; color: var(--primary-color); font-size: 24px; }

        /* 输入表单区 */
        .form-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
            background: #f8f9fa;
            padding: 20px;
            border-radius: 12px;
            border: 1px solid #eee;
        }

        .form-group label { display: block; font-size: 13px; font-weight: 600; color: #636e72; margin-bottom: 8px; }
        .form-control {
            width: 100%; padding: 10px 15px; border: 1px solid #dfe6e9; border-radius: 8px;
            font-size: 14px; transition: all 0.3s; outline: none;
        }
        .form-control:focus { border-color: var(--primary-color); box-shadow: 0 0 0 3px rgba(0, 191, 165, 0.15); }

        .btn-add {
            background: linear-gradient(135deg, #26c6da, #00bfa5);
            color: white; border: none; padding: 10px 25px; border-radius: 8px;
            font-weight: 600; cursor: pointer; transition: transform 0.2s; height: 42px; margin-top: 24px; width: 100%;
        }
        .btn-add:hover { transform: translateY(-2px); box-shadow: 0 4px 10px rgba(0, 191, 165, 0.3); }

        /* 表格样式 */
        .modern-table { width: 100%; border-collapse: collapse; border-radius: 8px; overflow: hidden; }
        .modern-table th { background: #00bfa5; color: white; padding: 15px; text-align: left; font-size: 14px; }
        .modern-table td { padding: 15px; border-bottom: 1px solid #f1f2f6; color: #2d3436; font-size: 14px; }
        .modern-table tr:last-child td { border-bottom: none; }
        .modern-table tr:hover { background-color: #fdfdfd; }

        /* 操作按钮 */
        .btn-action { padding: 5px 10px; border-radius: 6px; text-decoration: none; font-size: 12px; margin-right: 5px; display: inline-block; }
        .btn-edit { background: #e3f2fd; color: #0984e3; border: 1px solid transparent; }
        .btn-edit:hover { border-color: #0984e3; background: white; }
        
        .btn-del { background: #e0fbf6; color: #00a990; border: 1px solid transparent; }
        .btn-del:hover { border-color: #00a990; background: white; }

        .badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; }
        .badge-on { background: #e0fbf6; color: #00bfa5; }
        .badge-off { background: #ffecec; color: #d63031; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:UpdatePanel ID="upDishes" runat="server">
        <ContentTemplate>
    <div class="admin-container">
        <div class="page-header">
            <i class="fas fa-book"></i>
            <h2 style="color: var(--primary-color)">菜品信息管理</h2>
        </div>
        

        <!-- 新增表单 -->
        <div class="form-grid">
            <div class="form-group">
                <label>菜品名称</label>
                <asp:TextBox ID="txtAddName" runat="server" CssClass="form-control" placeholder="例如：红烧排骨"></asp:TextBox>
            </div>
            <div class="form-group">
                <label>所属分类</label>
                <asp:DropDownList ID="ddlAddCategory" runat="server" CssClass="form-control"></asp:DropDownList>
            </div>
            <div class="form-group">
                <label>单价 (元)</label>
                <asp:TextBox ID="txtAddPrice" runat="server" CssClass="form-control" TextMode="Number" step="0.01"></asp:TextBox>
            </div>
            <div class="form-group">
                <asp:Button ID="btnAdd" runat="server" Text="+ 添加新菜品" CssClass="btn-add" OnClick="btnAdd_Click" />
            </div>
        </div>

        <!-- 数据表格 -->
        <asp:GridView ID="gvDishes" runat="server" CssClass="modern-table" AutoGenerateColumns="False" 
            DataKeyNames="菜品编号" GridLines="None"
            OnRowEditing="gvDishes_RowEditing" 
            OnRowCancelingEdit="gvDishes_RowCancelingEdit" 
            OnRowUpdating="gvDishes_RowUpdating" 
            OnRowDeleting="gvDishes_RowDeleting">
            
            <Columns>
                <%-- 修正处：ItemStyle-Color 改为 ItemStyle-ForeColor --%>
                <asp:BoundField DataField="菜品编号" HeaderText="ID" ReadOnly="True" ItemStyle-Width="50px" ItemStyle-ForeColor="#b2bec3" />
                
                <asp:TemplateField HeaderText="菜品名称">
                    <ItemTemplate><span style="font-weight:600"><%# Eval("菜品名称") %></span></ItemTemplate>
                    <EditItemTemplate><asp:TextBox ID="txtEditName" runat="server" Text='<%# Bind("菜品名称") %>' CssClass="form-control" style="padding:5px;"></asp:TextBox></EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="分类">
                    <ItemTemplate><span style="background:#f1f2f6; padding:4px 8px; border-radius:4px;"><%# Eval("所属分类") %></span></ItemTemplate>
                    <EditItemTemplate><asp:TextBox ID="txtEditCat" runat="server" Text='<%# Bind("所属分类") %>' CssClass="form-control" style="padding:5px;"></asp:TextBox></EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="单价">
                    <ItemTemplate><span style="color:#d63031; font-weight:bold">¥ <%# Eval("单价", "{0:N2}") %></span></ItemTemplate>
                    <EditItemTemplate><asp:TextBox ID="txtEditPrice" runat="server" Text='<%# Bind("单价") %>' CssClass="form-control" style="padding:5px; width:80px;"></asp:TextBox></EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="状态">
                    <ItemTemplate>
                        <span class='<%# (bool)Eval("上架状态") ? "badge badge-on" : "badge badge-off" %>'>
                            <%# (bool)Eval("上架状态") ? "上架中" : "已下架" %>
                        </span>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:CheckBox ID="chkEditStatus" runat="server" Checked='<%# Bind("上架状态") %>' Text=" 上架" />
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="操作" ItemStyle-Width="150px">
                    <ItemTemplate>
                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="Edit" CssClass="btn-action btn-edit"><i class="fas fa-edit"></i> 编辑</asp:LinkButton>
                        <asp:LinkButton ID="btnDel" runat="server" CommandName="Delete" CssClass="btn-action btn-del" OnClientClick="return confirm('确定删除吗？');"><i class="fas fa-trash"></i> 删除</asp:LinkButton>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:LinkButton ID="btnUpdate" runat="server" CommandName="Update" CssClass="btn-action btn-edit"><i class="fas fa-check"></i> 保存</asp:LinkButton>
                        <asp:LinkButton ID="btnCancel" runat="server" CommandName="Cancel" CssClass="btn-action" style="background:#eee; color:#666"><i class="fas fa-times"></i> 取消</asp:LinkButton>
                    </EditItemTemplate>
                </asp:TemplateField>
            </Columns>
            <EmptyDataTemplate>
                <div style="padding:20px; text-align:center; color:#999;">暂无数据</div>
            </EmptyDataTemplate>
        </asp:GridView>
    </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
