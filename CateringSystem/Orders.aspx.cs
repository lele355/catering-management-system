using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CateringSystem
{
    public partial class Orders : System.Web.UI.Page
    {
        string connStr = WebConfigurationManager.ConnectionStrings["CateringConn"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadStats();       // 加载统计数据
                LoadOrders("Pending"); // 默认加载进行中订单
            }
        }

        // 1. 加载统计数据
        private void LoadStats()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                // 统计进行中订单数
                string sqlPending = "SELECT COUNT(*) FROM Orders WHERE [订单状态] = 'Pending'";
                SqlCommand cmdPending = new SqlCommand(sqlPending, conn);
                lblPendingCount.Text = cmdPending.ExecuteScalar().ToString();

                // 统计今日营收 (状态为 Paid 且 下单时间是今天)
                string sqlRevenue = "SELECT ISNULL(SUM([订单总额]), 0) FROM Orders WHERE [订单状态] = 'Paid' AND DATEDIFF(day, [下单时间], GETDATE()) = 0";
                SqlCommand cmdRevenue = new SqlCommand(sqlRevenue, conn);
                decimal revenue = Convert.ToDecimal(cmdRevenue.ExecuteScalar());
                lblTodayRevenue.Text = revenue.ToString("N2"); // N2 表示保留两位小数
            }
        }

        // 2. 加载订单列表
        private void LoadOrders(string status)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // 关联查询：订单 -> 桌台 -> 员工
                string sql = @"
                    SELECT O.[订单编号], O.[下单时间], O.[订单总额], O.[订单状态], 
                           T.[桌台名称], S.[真实姓名]
                    FROM Orders O
                    JOIN DiningTables T ON O.[关联桌号] = T.[桌台编号]
                    JOIN Staffs S ON O.[开单员工] = S.[用户编号]
                    WHERE O.[订单状态] = @status
                    ORDER BY O.[下单时间] DESC";

                // 如果是历史记录，显示最近50条即可
                if (status == "Paid")
                {
                    sql = sql.Replace("SELECT", "SELECT TOP 50");
                }

                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@status", status);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);

                rptOrders.DataSource = dt;
                rptOrders.DataBind();
            }
        }

        // 3. 嵌套绑定：加载每个订单的明细
        // 每次 Repeater 加载一行数据时，都会触发这个事件
        protected void rptOrders_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                // 找到当前行的 订单ID
                DataRowView row = (DataRowView)e.Item.DataItem;
                int orderId = Convert.ToInt32(row["订单编号"]);

                // 找到内层的 Repeater 控件
                Repeater rptDetails = (Repeater)e.Item.FindControl("rptDetails");

                // 查询该订单的菜品明细（包含制作状态）
                using (SqlConnection conn = new SqlConnection(connStr))
                {
                    string sql = @"
                        SELECT D.[菜品名称], OD.[点菜数量], OD.[制作状态], (OD.[点菜数量] * OD.[锁定单价]) AS 小计
                        FROM OrderDetails OD
                        JOIN Dishes D ON OD.[关联菜品] = D.[菜品编号]
                        WHERE OD.[所属订单] = @oid";

                    SqlCommand cmd = new SqlCommand(sql, conn);
                    cmd.Parameters.AddWithValue("@oid", orderId);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    rptDetails.DataSource = dt;
                    rptDetails.DataBind();
                }
            }
        }

        // 4. 选项卡切换事件
        protected void SwitchTab_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            string status = btn.CommandArgument == "History" ? "Paid" : "Pending";

            // 切换按钮样式
            btnTabPending.CssClass = status == "Pending" ? "tab-btn active" : "tab-btn";
            btnTabHistory.CssClass = status == "Paid" ? "tab-btn active" : "tab-btn";

            LoadOrders(status);
        }

        // 5. 结账操作
        protected void rptOrders_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Checkout")
            {
                int orderId = Convert.ToInt32(e.CommandArgument);
                CheckoutOrder(orderId);

                // 刷新页面数据
                LoadStats();
                LoadOrders("Pending");

                // 弹出提示
                ScriptManager.RegisterStartupScript(this, GetType(), "alert", "alert('结账成功！桌台已释放。');", true);
            }
        }

        // 核心逻辑：结账事务
        private void CheckoutOrder(int orderId)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                SqlTransaction trans = conn.BeginTransaction(); // 开启事务，确保数据一致性

                try
                {
                    // A. 更新订单状态为 Paid
                    string sqlUpdateOrder = "UPDATE Orders SET [订单状态] = 'Paid' WHERE [订单编号] = @oid";
                    SqlCommand cmd1 = new SqlCommand(sqlUpdateOrder, conn, trans);
                    cmd1.Parameters.AddWithValue("@oid", orderId);
                    cmd1.ExecuteNonQuery();

                    // B. 查找该订单关联的桌号
                    string sqlFindTable = "SELECT [关联桌号] FROM Orders WHERE [订单编号] = @oid";
                    SqlCommand cmd2 = new SqlCommand(sqlFindTable, conn, trans);
                    cmd2.Parameters.AddWithValue("@oid", orderId);
                    int tableId = Convert.ToInt32(cmd2.ExecuteScalar());

                    // C. 释放桌台 (状态改回 Free)
                    string sqlReleaseTable = "UPDATE DiningTables SET [当前状态] = 'Free' WHERE [桌台编号] = @tid";
                    SqlCommand cmd3 = new SqlCommand(sqlReleaseTable, conn, trans);
                    cmd3.Parameters.AddWithValue("@tid", tableId);
                    cmd3.ExecuteNonQuery();

                    trans.Commit(); // 提交事务
                }
                catch
                {
                    trans.Rollback(); // 出错回滚
                    throw; // 抛出异常供上层处理（实际项目中应记录日志）
                }
            }
        }
    }
}