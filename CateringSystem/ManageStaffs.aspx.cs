using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI.WebControls;

namespace CateringSystem
{
    public partial class ManageStaffs : System.Web.UI.Page
    {
        string connStr = WebConfigurationManager.ConnectionStrings["CateringConn"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Role"]?.ToString() != "Manager") Response.Redirect("Default.aspx");
            if (!IsPostBack) BindGrid();
        }

        private void BindGrid()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT * FROM Staffs";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvStaffs.DataSource = dt;
                gvStaffs.DataBind();
            }
        }

        // 辅助方法：前端调用，显示中文角色名
        public string GetRoleName(object roleObj)
        {
            string role = roleObj.ToString();
            if (role == "Manager") return "管理员";
            if (role == "Chef") return "后厨";
            return "服务员";
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtUser.Text)) return;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                try
                {
                    string sql = "INSERT INTO Staffs ([登录账号], [登录密码], [真实姓名], [角色权限]) VALUES (@u, '123', @n, @r)";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@u", txtUser.Text.Trim());
                    cmd.Parameters.AddWithValue("@n", txtName.Text.Trim());
                    cmd.Parameters.AddWithValue("@r", ddlRole.SelectedValue);
                    cmd.ExecuteNonQuery();
                }
                catch
                {
                    Response.Write("<script>alert('账号已存在！');</script>");
                }
            }
            // 重置表单
            txtUser.Text = ""; txtName.Text = "";
            BindGrid();
        }

        // --- 编辑模式逻辑 ---

        protected void gvStaffs_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvStaffs.EditIndex = e.NewEditIndex;
            BindGrid();
        }

        protected void gvStaffs_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvStaffs.EditIndex = -1;
            BindGrid();
        }

        protected void gvStaffs_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            int id = Convert.ToInt32(gvStaffs.DataKeys[e.RowIndex].Value);

            // 获取编辑框中的值
            // 注意：TemplateField 需要用 FindControl 找控件
            string name = ((TextBox)gvStaffs.Rows[e.RowIndex].FindControl("txtEditName")).Text;
            string pwd = ((TextBox)gvStaffs.Rows[e.RowIndex].FindControl("txtEditPwd")).Text;
            string role = ((DropDownList)gvStaffs.Rows[e.RowIndex].FindControl("ddlEditRole")).SelectedValue;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql = "UPDATE Staffs SET [真实姓名]=@n, [登录密码]=@p, [角色权限]=@r WHERE [用户编号]=@id";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@n", name);
                cmd.Parameters.AddWithValue("@p", pwd);
                cmd.Parameters.AddWithValue("@r", role);
                cmd.Parameters.AddWithValue("@id", id);
                cmd.ExecuteNonQuery();
            }

            gvStaffs.EditIndex = -1;
            BindGrid();
        }

        protected void gvStaffs_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int id = Convert.ToInt32(gvStaffs.DataKeys[e.RowIndex].Value);

            // 禁止删除自己
            if (id.ToString() == Session["UserID"].ToString())
            {
                Response.Write("<script>alert('为了安全，您不能删除自己的账号！');</script>");
                return;
            }

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                try
                {
                    string sql = "DELETE FROM Staffs WHERE [用户编号]=@id";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.ExecuteNonQuery();
                }
                catch
                {
                    Response.Write("<script>alert('该员工有业务记录，无法物理删除。');</script>");
                }
            }
            BindGrid();
        }
    }
}