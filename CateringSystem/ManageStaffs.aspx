<%@ Page Title="员工管理" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ManageStaffs.aspx.cs" Inherits="CateringSystem.ManageStaffs" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        /* 青绿色主题 */
        .admin-container { background: white; padding: 30px; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); }
        .page-header { display: flex; align-items: center; margin-bottom: 30px; border-bottom: 2px solid #f1f2f6; padding-bottom: 15px; }
        .page-header h2 { margin: 0; color: #2d3436; font-weight: 800; }
        .page-header i { margin-right: 10px; color: var(--primary-color); font-size: 24px; }

        .form-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; background: #f8f9fa; padding: 20px; border-radius: 12px; border: 1px solid #eee; margin-bottom: 30px; align-items: end; }
        .form-control { width: 100%; padding: 10px; border: 1px solid #dfe6e9; border-radius: 6px; }
        .btn-save { background: var(--primary-color); color: white; border: none; padding: 10px; border-radius: 6px; cursor: pointer; width: 100%; font-weight: 600; }
        .btn-save:hover { background: #00a990; }

        .modern-table { width: 100%; border-collapse: collapse; }
        .modern-table th { background: #00bfa5; color: white; padding: 15px; text-align: left; }
        .modern-table td { padding: 12px 15px; border-bottom: 1px solid #eee; }
        
        .role-badge { padding: 3px 8px; border-radius: 4px; font-size: 12px; background: #e0f2f1; color: #00796b; }
        .role-Manager { background: #e0fbf6; color: #00bfa5; }
        .role-Chef { background: #fff3e0; color: #ff7043; }
        .role-Waiter { background: #e3f2fd; color: #26c6da; }

        /* 按钮样式同上 */
        .btn-action { padding: 5px 10px; border-radius: 6px; text-decoration: none; font-size: 12px; margin-right: 5px; display: inline-block; cursor: pointer;}
        .btn-edit { background: #e0fbf6; color: #00a990; }
        .btn-del { background: #fff3e0; color: #ff7043; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:UpdatePanel ID="upStaffs" runat="server">
        <ContentTemplate>
    <div class="admin-container">
        <div class="page-header">
            <i class="fas fa-user-tie"></i>
            <h2 style="color: var(--primary-color)">员工信息管理</h2>
        </div>
        

        <!-- 新增员工表单 -->
        <div class="form-grid">
            <div>
                <div style="margin-bottom:5px; color:#666; font-size:13px;">登录账号</div>
                <asp:TextBox ID="txtUser" runat="server" CssClass="form-control" placeholder="English Only"></asp:TextBox>
            </div>
            <div>
                <div style="margin-bottom:5px; color:#666; font-size:13px;">真实姓名</div>
                <asp:TextBox ID="txtName" runat="server" CssClass="form-control" placeholder="员工姓名"></asp:TextBox>
            </div>
            <div>
                <div style="margin-bottom:5px; color:#666; font-size:13px;">角色权限</div>
                <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-control">
                    <asp:ListItem Value="Waiter">服务员 (Waiter)</asp:ListItem>
                    <asp:ListItem Value="Chef">后厨 (Chef)</asp:ListItem>
                    <asp:ListItem Value="Manager">管理员 (Manager)</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div>
                <asp:Button ID="btnAdd" runat="server" Text="+ 注册员工 (默认密码123)" CssClass="btn-save" OnClick="btnAdd_Click" />
            </div>
        </div>

        <!-- 员工列表 -->
        <asp:GridView ID="gvStaffs" runat="server" CssClass="modern-table" AutoGenerateColumns="False" 
            DataKeyNames="用户编号" GridLines="None"
            OnRowEditing="gvStaffs_RowEditing"
            OnRowCancelingEdit="gvStaffs_RowCancelingEdit"
            OnRowUpdating="gvStaffs_RowUpdating"
            OnRowDeleting="gvStaffs_RowDeleting">
            
            <Columns>
                <asp:BoundField DataField="用户编号" HeaderText="ID" ReadOnly="True" ItemStyle-Width="50px" ItemStyle-ForeColor="#b2bec3" />
                <asp:BoundField DataField="登录账号" HeaderText="账号" ReadOnly="True" ItemStyle-Font-Bold="true" />
                
                <asp:TemplateField HeaderText="姓名">
                    <ItemTemplate><%# Eval("真实姓名") %></ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditName" runat="server" Text='<%# Bind("真实姓名") %>' CssClass="form-control" style="padding:5px;"></asp:TextBox>
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="密码">
                    <ItemTemplate>******</ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtEditPwd" runat="server" Text='<%# Bind("登录密码") %>' CssClass="form-control" style="padding:5px; width:100px;"></asp:TextBox>
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="角色">
                    <ItemTemplate>
                        <span class='role-badge role-<%# Eval("角色权限") %>'>
                            <%# GetRoleName(Eval("角色权限")) %>
                        </span>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:DropDownList ID="ddlEditRole" runat="server" CssClass="form-control" style="padding:5px;" SelectedValue='<%# Bind("角色权限") %>'>
                            <asp:ListItem Value="Waiter">服务员</asp:ListItem>
                            <asp:ListItem Value="Chef">后厨</asp:ListItem>
                            <asp:ListItem Value="Manager">管理员</asp:ListItem>
                        </asp:DropDownList>
                    </EditItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="操作" ItemStyle-Width="160px">
                    <ItemTemplate>
                        <asp:LinkButton ID="btnEdit" runat="server" CommandName="Edit" CssClass="btn-action btn-edit"><i class="fas fa-pen"></i> 编辑</asp:LinkButton>
                        <asp:LinkButton ID="btnDel" runat="server" CommandName="Delete" CssClass="btn-action btn-del" OnClientClick="return confirm('确定要开除该员工吗？');"><i class="fas fa-user-minus"></i> 删除</asp:LinkButton>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:LinkButton ID="btnUpdate" runat="server" CommandName="Update" CssClass="btn-action btn-edit"><i class="fas fa-check"></i> 保存</asp:LinkButton>
                        <asp:LinkButton ID="btnCancel" runat="server" CommandName="Cancel" CssClass="btn-action" style="background:#eee; color:#666"><i class="fas fa-times"></i> 取消</asp:LinkButton>
                    </EditItemTemplate>
                </asp:TemplateField>
            </Columns>
            <EmptyDataTemplate>暂无员工数据</EmptyDataTemplate>
        </asp:GridView>
    </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
