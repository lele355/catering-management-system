using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI.WebControls;

namespace CateringSystem
{
    public partial class ManageDishes : System.Web.UI.Page
    {
        string connStr = WebConfigurationManager.ConnectionStrings["CateringConn"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // 权限验证
            if (Session["Role"]?.ToString() != "Manager")
            {
                Response.Redirect("Default.aspx");
            }

            if (!IsPostBack)
            {
                LoadCategories();
                BindGrid();
            }
        }

        // 绑定数据
        private void BindGrid()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT * FROM Dishes ORDER BY [菜品编号] DESC";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvDishes.DataSource = dt;
                gvDishes.DataBind();
            }
        }

        // 1. 新增菜品
        protected void btnAdd_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtAddName.Text) || string.IsNullOrWhiteSpace(txtAddPrice.Text)) return;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql = "INSERT INTO Dishes ([菜品名称], [所属分类], [单价], [上架状态]) VALUES (@name, @cat, @price, 1)";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@name", txtAddName.Text);
                cmd.Parameters.AddWithValue("@cat", ddlAddCategory.SelectedValue);
                cmd.Parameters.AddWithValue("@price", Convert.ToDecimal(txtAddPrice.Text));
                cmd.ExecuteNonQuery();
            }

            // 清空并刷新
            txtAddName.Text = "";
            txtAddPrice.Text = "";
            LoadCategories();
            BindGrid();
        }

        // 加载去重后的分类列表
        private void LoadCategories()
        {
            ddlAddCategory.Items.Clear();
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT DISTINCT [所属分类] FROM Dishes ORDER BY [所属分类]";
                SqlCommand cmd = new SqlCommand(sql, conn);
                conn.Open();
                SqlDataReader dr = cmd.ExecuteReader();
                while (dr.Read())
                {
                    string cat = dr[0].ToString();
                    ddlAddCategory.Items.Add(new ListItem(cat, cat));
                }
            }
        }

        // 2. 进入编辑模式
        protected void gvDishes_RowEditing(object sender, GridViewEditEventArgs e)
        {
            gvDishes.EditIndex = e.NewEditIndex;
            BindGrid();
        }

        // 3. 取消编辑
        protected void gvDishes_RowCancelingEdit(object sender, GridViewCancelEditEventArgs e)
        {
            gvDishes.EditIndex = -1;
            BindGrid();
        }

        // 4. 保存更新 (此处已修复)
        protected void gvDishes_RowUpdating(object sender, GridViewUpdateEventArgs e)
        {
            // 获取主键 ID
            int id = Convert.ToInt32(gvDishes.DataKeys[e.RowIndex].Value);

            // 修复：使用 FindControl 根据 ID 查找控件，而不是用索引 Controls[0]
            // 这种方式非常稳健，不会因为 HTML 里的空格或换行而报错
            TextBox txtName = (TextBox)gvDishes.Rows[e.RowIndex].FindControl("txtEditName");
            TextBox txtCat = (TextBox)gvDishes.Rows[e.RowIndex].FindControl("txtEditCat");
            TextBox txtPrice = (TextBox)gvDishes.Rows[e.RowIndex].FindControl("txtEditPrice");
            CheckBox chkStatus = (CheckBox)gvDishes.Rows[e.RowIndex].FindControl("chkEditStatus");

            // 获取值
            string name = txtName.Text;
            string category = txtCat.Text;
            decimal price = Convert.ToDecimal(txtPrice.Text);
            bool isAvailable = chkStatus.Checked;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql = "UPDATE Dishes SET [菜品名称]=@n, [所属分类]=@c, [单价]=@p, [上架状态]=@s WHERE [菜品编号]=@id";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@n", name);
                cmd.Parameters.AddWithValue("@c", category);
                cmd.Parameters.AddWithValue("@p", price);
                cmd.Parameters.AddWithValue("@s", isAvailable);
                cmd.Parameters.AddWithValue("@id", id);
                cmd.ExecuteNonQuery();
            }

            gvDishes.EditIndex = -1;
            BindGrid();
        }

        // 5. 删除菜品
        protected void gvDishes_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int id = Convert.ToInt32(gvDishes.DataKeys[e.RowIndex].Value);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                try
                {
                    string sql = "DELETE FROM Dishes WHERE [菜品编号]=@id";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.ExecuteNonQuery();
                }
                catch
                {
                    // 如果删不掉（因为被订单引用），就改状态为下架
                    string sql = "UPDATE Dishes SET [上架状态]=0 WHERE [菜品编号]=@id";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.ExecuteNonQuery();
                    Response.Write("<script>alert('该菜品有历史订单，已自动转为下架状态，未物理删除。');</script>");
                }
            }
            BindGrid();
        }
    }
}