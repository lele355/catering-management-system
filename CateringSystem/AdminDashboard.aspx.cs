using System;
using System.Data.SqlClient;
using System.Web.Configuration;
using System.Web.Script.Serialization;
using System.Collections.Generic;

namespace CateringSystem
{
    public partial class AdminDashboard : System.Web.UI.Page
    {
        string connStr = WebConfigurationManager.ConnectionStrings["CateringConn"].ConnectionString;

        // 定义供前端调用的属性
        public string CatLabels { get; set; }
        public string CatData { get; set; }
        public string TopDishLabels { get; set; }
        public string TopDishData { get; set; }
        public string TrendLabels { get; set; }
        public string TrendData { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Role"]?.ToString() != "Manager")
            {
                Response.Redirect("Default.aspx");
            }

            if (!IsPostBack)
            {
                LoadStats();
                LoadAllChartData();
            }
        }

        // 1. 加载顶部数字卡片
        private void LoadStats()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // 总销售额 (只算已付款)
                string sql1 = "SELECT ISNULL(SUM([订单总额]), 0) FROM Orders WHERE [订单状态] = 'Paid'";
                SqlCommand cmd1 = new SqlCommand(sql1, conn);
                lblTotalSales.Text = Convert.ToDecimal(cmd1.ExecuteScalar()).ToString("N2");

                // 总完成订单数
                string sql2 = "SELECT COUNT(*) FROM Orders WHERE [订单状态] = 'Paid'";
                SqlCommand cmd2 = new SqlCommand(sql2, conn);
                lblOrderCount.Text = cmd2.ExecuteScalar().ToString();

                // 在售菜品数
                string sql3 = "SELECT COUNT(*) FROM Dishes WHERE [上架状态] = 1";
                SqlCommand cmd3 = new SqlCommand(sql3, conn);
                lblDishCount.Text = cmd3.ExecuteScalar().ToString();
            }
        }

        // 2. 加载所有图表数据
        private void LoadAllChartData()
        {
            JavaScriptSerializer js = new JavaScriptSerializer();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // --- A. 分类销量占比 (饼图数据) ---
                // 从 Dishes 获取去重分类，左连接销量，确保无销量的类目也能显示（0）
                List<string> cLabels = new List<string>();
                List<int> cData = new List<int>();
                string sqlCat = @"
                    WITH Cats AS (
                        SELECT DISTINCT [所属分类] AS Category
                        FROM Dishes
                    ), Sales AS (
                        SELECT D.[所属分类] AS Category,
                               ISNULL(SUM(OD.[点菜数量]), 0) AS TotalQty
                        FROM Dishes D
                        LEFT JOIN OrderDetails OD ON D.[菜品编号] = OD.[关联菜品]
                        LEFT JOIN Orders O ON OD.[所属订单] = O.[订单编号]
                        WHERE O.[订单状态] = 'Paid'
                        GROUP BY D.[所属分类]
                    )
                    SELECT C.Category, ISNULL(S.TotalQty, 0) AS TotalQty
                    FROM Cats C
                    LEFT JOIN Sales S ON S.Category = C.Category
                    ORDER BY C.Category";

                using (SqlCommand cmd = new SqlCommand(sqlCat, conn))
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        cLabels.Add(r["Category"].ToString());
                        cData.Add(Convert.ToInt32(r["TotalQty"]));
                    }
                }
                if (cLabels.Count == 0)
                {
                    cLabels.Add("暂无分类");
                    cData.Add(0);
                }
                CatLabels = js.Serialize(cLabels);
                CatData = js.Serialize(cData);


                // --- B. 热销 Top 5 (柱状图数据) ---
                List<string> tLabels = new List<string>();
                List<int> tData = new List<int>();
                string sqlTop = @"
                    SELECT TOP 5 D.[菜品名称], ISNULL(SUM(OD.[点菜数量]), 0) as TotalQty
                    FROM Dishes D
                    LEFT JOIN OrderDetails OD ON D.[菜品编号] = OD.[关联菜品]
                    LEFT JOIN Orders O ON OD.[所属订单] = O.[订单编号]
                    WHERE O.[订单状态] = 'Paid'
                    GROUP BY D.[菜品名称]
                    ORDER BY TotalQty DESC";

                using (SqlCommand cmd = new SqlCommand(sqlTop, conn))
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        tLabels.Add(r["菜品名称"].ToString());
                        tData.Add(Convert.ToInt32(r["TotalQty"]));
                    }
                }
                TopDishLabels = js.Serialize(tLabels);
                TopDishData = js.Serialize(tData);


                // --- C. 近7天营收趋势 (折线图数据) ---
                List<string> dLabels = new List<string>();
                List<decimal> dData = new List<decimal>();
                string sqlTrend = @"
                    SELECT FORMAT([下单时间], 'MM-dd') AS DateDay, SUM([订单总额]) AS Total
                    FROM Orders
                    WHERE [订单状态] = 'Paid' AND [下单时间] >= DATEADD(day, -7, GETDATE())
                    GROUP BY FORMAT([下单时间], 'MM-dd')
                    ORDER BY DateDay";

                using (SqlCommand cmd = new SqlCommand(sqlTrend, conn))
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    while (r.Read())
                    {
                        dLabels.Add(r["DateDay"].ToString());
                        dData.Add(Convert.ToDecimal(r["Total"]));
                    }
                }
                // 防止空数据报错
                if (dLabels.Count == 0) { dLabels.Add("暂无"); dData.Add(0); }

                TrendLabels = js.Serialize(dLabels);
                TrendData = js.Serialize(dData);
            }
        }
    }
}