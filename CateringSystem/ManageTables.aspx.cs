using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI.WebControls;

namespace CateringSystem
{
    public partial class ManageTables : System.Web.UI.Page
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
                string sql = "SELECT * FROM DiningTables";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                gvTables.DataSource = dt;
                gvTables.DataBind();
            }
        }

        protected void btnAdd_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtTableName.Text)) return;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql = "INSERT INTO DiningTables ([桌台名称], [当前状态]) VALUES (@name, 'Free')";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@name", txtTableName.Text.Trim());
                cmd.ExecuteNonQuery();
            }
            txtTableName.Text = "";
            BindGrid();
        }

        protected void gvTables_RowDeleting(object sender, GridViewDeleteEventArgs e)
        {
            int id = Convert.ToInt32(gvTables.DataKeys[e.RowIndex].Value);
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                try
                {
                    string sql = "DELETE FROM DiningTables WHERE [桌台编号]=@id";
                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@id", id);
                    cmd.ExecuteNonQuery();
                }
                catch
                {
                    Response.Write("<script>alert('无法删除：该桌台有历史订单关联。');</script>");
                }
            }
            BindGrid();
        }
    }
}