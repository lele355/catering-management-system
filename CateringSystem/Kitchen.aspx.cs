using System;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CateringSystem
{
    public partial class Kitchen : System.Web.UI.Page
    {
        string connStr = WebConfigurationManager.ConnectionStrings["CateringConn"].ConnectionString;

        // 保存当前分组和排序设置
        protected string CurrentGroupBy
        {
            get { return ViewState["GroupBy"]?.ToString() ?? "Dish"; }
            set { ViewState["GroupBy"] = value; }
        }

        protected string CurrentSortOrder
        {
            get { return ViewState["SortOrder"]?.ToString() ?? "ASC"; }
            set { ViewState["SortOrder"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // 权限验证：只有 厨师(Chef) 或 店长(Manager) 能看
                string role = Session["Role"]?.ToString();
                if (role != "Chef" && role != "Manager")
                {
                    // Response.Write("<script>alert('您没有权限访问后厨！');window.location='Default.aspx';</script>");
                    // return;
                }

                CurrentGroupBy = "Dish";
                CurrentSortOrder = "ASC";
                LoadKitchenTasks();
            }
            
            // 每次加载都更新按钮样式（包括PostBack）
            UpdateButtonStyles();
        }
        
        // 更新按钮样式的方法
        private void UpdateButtonStyles()
        {
            // 在UpdatePanel中查找控件
            UpdatePanel upKitchen = (UpdatePanel)this.FindControl("upKitchen");
            if (upKitchen != null)
            {
                LinkButton btnDish = (LinkButton)upKitchen.FindControl("btnGroupByDish");
                LinkButton btnTable = (LinkButton)upKitchen.FindControl("btnGroupByTable");
                LinkButton btnTime = (LinkButton)upKitchen.FindControl("btnGroupByTime");
                LinkButton btnAsc = (LinkButton)upKitchen.FindControl("btnSortAsc");
                LinkButton btnDesc = (LinkButton)upKitchen.FindControl("btnSortDesc");
                
                if (btnDish != null && btnTable != null && btnTime != null && btnAsc != null && btnDesc != null)
                {
                    string script = $@"
                        Sys.Application.add_load(function() {{
                            // 移除所有按钮的active类
                            document.querySelectorAll('.filter-btn').forEach(function(btn) {{
                                btn.classList.remove('active');
                            }});
                            
                            // 根据当前状态添加active类
                            var groupBy = '{CurrentGroupBy}';
                            var sortOrder = '{CurrentSortOrder}';
                            
                            if(groupBy === 'Dish') {{
                                document.getElementById('{btnDish.ClientID}').classList.add('active');
                            }} else if(groupBy === 'Table') {{
                                document.getElementById('{btnTable.ClientID}').classList.add('active');
                            }} else if(groupBy === 'Time') {{
                                document.getElementById('{btnTime.ClientID}').classList.add('active');
                            }}
                            
                            if(sortOrder === 'ASC') {{
                                document.getElementById('{btnAsc.ClientID}').classList.add('active');
                            }} else {{
                                document.getElementById('{btnDesc.ClientID}').classList.add('active');
                            }}
                        }});
                    ";
                    ScriptManager.RegisterStartupScript(this, GetType(), "initButtonStyles", script, true);
                }
            }
        }

        // 1. 加载待制作任务（支持分组和排序）
        private void LoadKitchenTasks()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // 基础查询
                string orderBy = CurrentSortOrder == "ASC" ? "ASC" : "DESC";
                
                string sql = $@"
                    SELECT OD.[明细编号], OD.[点菜数量], 
                           D.[菜品名称], 
                           T.[桌台名称], 
                           O.[下单时间],
                           O.[订单编号]
                    FROM OrderDetails OD
                    JOIN Dishes D ON OD.[关联菜品] = D.[菜品编号]
                    JOIN Orders O ON OD.[所属订单] = O.[订单编号]
                    JOIN DiningTables T ON O.[关联桌号] = T.[桌台编号]
                    WHERE OD.[制作状态] = 'Waiting'
                    ORDER BY O.[下单时间] {orderBy}";

                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);

                // 更新统计
                lblCount.Text = dt.Rows.Count.ToString();

                if (dt.Rows.Count > 0)
                {
                    // 根据分组方式处理数据
                    DataTable groupedData = GroupData(dt);
                    rptKitchen.DataSource = groupedData;
                    rptKitchen.DataBind();
                    pnlEmpty.Visible = false;
                }
                else
                {
                    rptKitchen.DataSource = null;
                    rptKitchen.DataBind();
                    pnlEmpty.Visible = true;
                }
            }
        }

        // 2. 数据分组处理（改为按菜品聚合）
        private DataTable GroupData(DataTable source)
        {
            // 创建新的结果表结构
            DataTable result = new DataTable();
            result.Columns.Add("菜品名称", typeof(string));
            result.Columns.Add("总数量", typeof(int));
            result.Columns.Add("订单明细", typeof(string)); // JSON格式存储所有订单信息
            result.Columns.Add("最长等待时间", typeof(int));
            result.Columns.Add("GroupHeader", typeof(string));
            result.Columns.Add("IsGroupHeader", typeof(bool));

            if (CurrentGroupBy == "Dish")
            {
                // 按菜品聚合
                var groups = source.AsEnumerable()
                    .GroupBy(row => row.Field<string>("菜品名称"))
                    .OrderBy(g => g.Key);

                foreach (var group in groups)
                {
                    DataRow dishRow = result.NewRow();
                    dishRow["菜品名称"] = group.Key;
                    dishRow["总数量"] = group.Sum(r => Convert.ToInt32(r["点菜数量"]));
                    dishRow["IsGroupHeader"] = false;
                    dishRow["GroupHeader"] = DBNull.Value;

                    // 计算最长等待时间
                    var now = DateTime.Now;
                    int maxWaitMinutes = group.Max(r => (int)(now - r.Field<DateTime>("下单时间")).TotalMinutes);
                    dishRow["最长等待时间"] = maxWaitMinutes;

                    // 构建订单明细JSON
                    var orderDetails = group.Select(r => new
                    {
                        DetailId = r["明细编号"],
                        TableName = r["桌台名称"],
                        Quantity = r["点菜数量"],
                        WaitMinutes = (int)(now - r.Field<DateTime>("下单时间")).TotalMinutes
                    }).ToList();

                    // 简单的拼接字符串（实际项目可用JSON序列化）
                    dishRow["订单明细"] = string.Join(";", orderDetails.Select(o => 
                        $"{o.DetailId}|{o.TableName}|{o.Quantity}|{o.WaitMinutes}"));

                    result.Rows.Add(dishRow);
                }
            }
            else if (CurrentGroupBy == "Table")
            {
                // 按桌号分组 - 每桌一个大卡片
                var groups = source.AsEnumerable()
                    .GroupBy(row => row.Field<string>("桌台名称"))
                    .OrderBy(g => g.Key);

                foreach (var group in groups)
                {
                    // 创建桌台卡片（包含该桌所有菜品）
                    DataRow tableRow = result.NewRow();
                    tableRow["菜品名称"] = group.Key; // 桌台名称
                    tableRow["IsGroupHeader"] = false;
                    tableRow["GroupHeader"] = DBNull.Value;

                    var now = DateTime.Now;
                    
                    // 计算该桌的最长等待时间
                    int maxWaitMinutes = group.Max(r => (int)(now - r.Field<DateTime>("下单时间")).TotalMinutes);
                    tableRow["最长等待时间"] = maxWaitMinutes;

                    // 计算该桌的总菜品数
                    int totalQty = group.Sum(r => Convert.ToInt32(r["点菜数量"]));
                    tableRow["总数量"] = totalQty;

                    // 构建该桌所有菜品明细（每个菜品一条记录）
                    var dishDetails = group.Select(r => new
                    {
                        DetailId = r["明细编号"],
                        DishName = r["菜品名称"],
                        Quantity = r["点菜数量"],
                        WaitMinutes = (int)(now - r.Field<DateTime>("下单时间")).TotalMinutes
                    }).ToList();

                    // 格式：DetailId|DishName|Quantity|WaitMinutes
                    tableRow["订单明细"] = string.Join(";", dishDetails.Select(d => 
                        $"{d.DetailId}|{d.DishName}|{d.Quantity}|{d.WaitMinutes}"));

                    result.Rows.Add(tableRow);
                }
            }
            else if (CurrentGroupBy == "Time")
            {
                // 按等待时间分组
                var now = DateTime.Now;
                var groups = source.AsEnumerable()
                    .Select(row => new
                    {
                        Row = row,
                        WaitMinutes = (int)(now - row.Field<DateTime>("下单时间")).TotalMinutes,
                        TimeGroup = GetTimeGroup((int)(now - row.Field<DateTime>("下单时间")).TotalMinutes)
                    })
                    .GroupBy(x => x.TimeGroup)
                    .OrderBy(g => GetTimeGroupOrder(g.Key));

                foreach (var group in groups)
                {
                    // 添加时间分组标题
                    DataRow headerRow = result.NewRow();
                    headerRow["GroupHeader"] = group.Key;
                    headerRow["菜品名称"] = group.Key;
                    headerRow["IsGroupHeader"] = true;
                    result.Rows.Add(headerRow);

                    // 按菜品聚合该时间段的订单
                    var dishGroups = group.GroupBy(x => x.Row.Field<string>("菜品名称"));
                    foreach (var dishGroup in dishGroups)
                    {
                        DataRow dishRow = result.NewRow();
                        dishRow["菜品名称"] = dishGroup.Key;
                        dishRow["总数量"] = dishGroup.Sum(x => Convert.ToInt32(x.Row["点菜数量"]));
                        dishRow["IsGroupHeader"] = false;
                        dishRow["GroupHeader"] = DBNull.Value;

                        int maxWaitMinutes = dishGroup.Max(x => x.WaitMinutes);
                        dishRow["最长等待时间"] = maxWaitMinutes;

                        var orderDetails = dishGroup.Select(x => new
                        {
                            DetailId = x.Row["明细编号"],
                            TableName = x.Row["桌台名称"],
                            Quantity = x.Row["点菜数量"],
                            WaitMinutes = x.WaitMinutes
                        }).ToList();

                        dishRow["订单明细"] = string.Join(";", orderDetails.Select(o => 
                            $"{o.DetailId}|{o.TableName}|{o.Quantity}|{o.WaitMinutes}"));

                        result.Rows.Add(dishRow);
                    }
                }
            }

            return result;
        }

        // 3. 时间分组辅助方法
        private string GetTimeGroup(int minutes)
        {
            if (minutes < 10) return "⚡ 10分钟内";
            if (minutes < 20) return "⏰ 10-20分钟";
            if (minutes < 30) return "⚠️ 20-30分钟";
            return "🔥 超过30分钟";
        }

        private int GetTimeGroupOrder(string group)
        {
            if (group.Contains("10分钟内")) return 1;
            if (group.Contains("10-20")) return 2;
            if (group.Contains("20-30")) return 3;
            return 4;
        }

        // 2. 处理“出餐”点击
        protected void rptKitchen_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DoneAll")
            {
                // 批量完成该菜品的所有订单
                string orderDetails = e.CommandArgument.ToString();
                string[] details = orderDetails.Split(';');
                
                foreach (string detail in details)
                {
                    int detailId = Convert.ToInt32(detail.Split('|')[0]);
                    UpdateStatus(detailId);
                }
                
                LoadKitchenTasks(); // 刷新列表
                ScriptManager.RegisterStartupScript(this, GetType(), "success", 
                    "alert('已完成该菜品的所有订单！');", true);
            }
        }

        // 更新数据库状态
        private void UpdateStatus(int detailId)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();
                string sql = "UPDATE OrderDetails SET [制作状态] = 'Done' WHERE [明细编号] = @did";
                SqlCommand cmd = new SqlCommand(sql, conn);
                cmd.Parameters.AddWithValue("@did", detailId);
                cmd.ExecuteNonQuery();
            }
        }

        // 前端辅助方法：计算已等待时间
        public int GetWaitMinutes(object orderTimeObj)
        {
            if (orderTimeObj == null || orderTimeObj == DBNull.Value) return 0;
            DateTime orderTime = Convert.ToDateTime(orderTimeObj);
            TimeSpan span = DateTime.Now - orderTime;
            return (int)span.TotalMinutes;
        }

        // 4. 分组按钮点击事件
        protected void btnGroupBy_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            CurrentGroupBy = btn.CommandArgument;
            LoadKitchenTasks();
            // UpdateButtonStyles() 会在Page_Load中自动调用
        }

        // 5. 排序按钮点击事件
        protected void btnSort_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            CurrentSortOrder = btn.CommandArgument;
            LoadKitchenTasks();
            // UpdateButtonStyles() 会在Page_Load中自动调用
        }

        // 辅助方法：判断是否为分组标题行
        public bool IsGroupHeaderRow(object isHeader)
        {
            return isHeader != null && isHeader != DBNull.Value && Convert.ToBoolean(isHeader);
        }

        // 辅助方法：根据等待时间返回优先级样式
        public string GetPriorityClass(int waitMinutes)
        {
            if (waitMinutes >= 30) return "priority-high";
            if (waitMinutes >= 15) return "priority-medium";
            return "priority-normal";
        }

        // 辅助方法：安全获取等待时间
        public int SafeGetWaitMinutes(object value)
        {
            if (value == null || value == DBNull.Value)
                return 0;
            return Convert.ToInt32(value);
        }

        // 辅助方法：安全判断是否紧急
        public bool IsUrgent(object value)
        {
            if (value == null || value == DBNull.Value)
                return false;
            return Convert.ToInt32(value) >= 30;
        }

        // 嵌套Repeater数据绑定
        protected void rptKitchen_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView row = (DataRowView)e.Item.DataItem;
                
                // 跳过分组标题行
                if (row["IsGroupHeader"] != DBNull.Value && Convert.ToBoolean(row["IsGroupHeader"]))
                    return;

                // 绑定订单芯片
                Repeater rptOrderChips = (Repeater)e.Item.FindControl("rptOrderChips");
                if (rptOrderChips != null && row["订单明细"] != DBNull.Value)
                {
                    string orderDetails = row["订单明细"].ToString();
                    
                    // 判断是按桌号分类还是按菜品分类
                    if (CurrentGroupBy == "Table")
                    {
                        // 按桌号：显示菜品名称
                        var chips = orderDetails.Split(';')
                            .Select(detail => {
                                var parts = detail.Split('|');
                                return new {
                                    DetailId = parts[0],
                                    TableName = parts[1], // 这里存的是菜品名称
                                    Quantity = parts[2],
                                    WaitMinutes = parts[3]
                                };
                            }).ToList();
                        
                        rptOrderChips.DataSource = chips;
                        rptOrderChips.DataBind();
                    }
                    else
                    {
                        // 按菜品/时间：显示桌号
                        var chips = orderDetails.Split(';')
                            .Select(detail => {
                                var parts = detail.Split('|');
                                return new {
                                    DetailId = parts[0],
                                    TableName = parts[1],
                                    Quantity = parts[2],
                                    WaitMinutes = parts[3]
                                };
                            }).ToList();
                        
                        rptOrderChips.DataSource = chips;
                        rptOrderChips.DataBind();
                    }
                }
            }
        }

        // 单个订单芯片点击事件
        protected void rptOrderChips_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "DoneSingle")
            {
                int detailId = Convert.ToInt32(e.CommandArgument);
                UpdateStatus(detailId);
                LoadKitchenTasks();
                ScriptManager.RegisterStartupScript(this, GetType(), "singleSuccess", 
                    "alert('该订单已完成！');", true);
            }
        }
    }
}