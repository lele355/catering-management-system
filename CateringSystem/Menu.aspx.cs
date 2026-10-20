using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace CateringSystem
{
    public partial class Menu : System.Web.UI.Page
    {
        string connStr = WebConfigurationManager.ConnectionStrings["CateringConn"].ConnectionString;

        // 购物车属性，封装对 Session 的访问
        protected List<CartItem> CurrentCart
        {
            get
            {
                if (Session["MyCart"] == null)
                {
                    Session["MyCart"] = new List<CartItem>();
                }
                return (List<CartItem>)Session["MyCart"];
            }
            set
            {
                Session["MyCart"] = value;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadTables();
                LoadCategories();
                LoadDishes("All");
                BindCart(); // 绑定购物车

                // 设置“全部”按钮为激活状态
                btnAll.CssClass = "cat-btn active";
            }
        }

        // 1. 加载桌台
        private void LoadTables()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                // 只显示空闲或占用的桌子
                string sql = "SELECT [桌台编号], [桌台名称] FROM DiningTables";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                ddlTables.DataSource = dt;
                ddlTables.DataTextField = "桌台名称";
                ddlTables.DataValueField = "桌台编号";
                ddlTables.DataBind();
            }
        }

        // 2. 加载分类
        private void LoadCategories()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT DISTINCT [所属分类] AS Category FROM Dishes WHERE [上架状态] = 1";
                SqlDataAdapter da = new SqlDataAdapter(sql, conn);
                DataTable dt = new DataTable();
                da.Fill(dt);
                rptCategories.DataSource = dt;
                rptCategories.DataBind();
            }
        }

        // 3. 加载菜品
        private void LoadDishes(string category)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string sql = "SELECT * FROM Dishes WHERE [上架状态] = 1";
                if (category != "All") sql += " AND [所属分类] = @cat";

                SqlCommand cmd = new SqlCommand(sql, conn);
                if (category != "All") cmd.Parameters.AddWithValue("@cat", category);

                SqlDataAdapter da = new SqlDataAdapter(cmd);
                DataTable dt = new DataTable();
                da.Fill(dt);
                rptDishes.DataSource = dt;
                rptDishes.DataBind();
            }
            ViewState["CurrentCat"] = category;
        }

        // 4. 点击左侧菜品 -> 加入购物车
        protected void rptDishes_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Add")
            {
                string[] args = e.CommandArgument.ToString().Split('|');
                int id = int.Parse(args[0]);
                string name = args[1];
                decimal price = decimal.Parse(args[2]);

                var cart = CurrentCart;
                var existingItem = cart.FirstOrDefault(x => x.DishId == id);

                if (existingItem != null)
                {
                    existingItem.Quantity++;
                }
                else
                {
                    cart.Add(new CartItem { DishId = id, DishName = name, Price = price, Quantity = 1 });
                }

                BindCart();
            }
        }

        // 5. 右侧购物车操作 (+ / -)
        protected void rptCart_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int id = int.Parse(e.CommandArgument.ToString());
            var cart = CurrentCart;
            var item = cart.FirstOrDefault(x => x.DishId == id);

            if (item != null)
            {
                if (e.CommandName == "Plus")
                {
                    item.Quantity++;
                }
                else if (e.CommandName == "Minus")
                {
                    item.Quantity--;
                    if (item.Quantity <= 0) cart.Remove(item);
                }
                BindCart();
            }
        }

        // 绑定并刷新购物车显示
        private void BindCart()
        {
            var cart = CurrentCart;
            rptCart.DataSource = cart;
            rptCart.DataBind();

            decimal total = cart.Sum(x => x.SubTotal);
            lblTotal.Text = total.ToString("N2");

            pnlEmptyCart.Visible = (cart.Count == 0);
            btnSubmit.Enabled = (cart.Count > 0);
            // 按钮变灰逻辑可加CSS，这里简化处理
        }

        // 6. 提交订单 (批量入库)
        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            var cart = CurrentCart;
            if (cart.Count == 0) return;

            string tableId = ddlTables.SelectedValue;
            // 获取当前用户ID (防止 Session 过期报错，默认给 1)
            int userId = Convert.ToInt32(Session["UserID"] ?? 1);

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // 1. 查找该桌是否有进行中的订单
                string checkSql = "SELECT [订单编号] FROM Orders WHERE [关联桌号] = @tid AND [订单状态] = 'Pending'";
                SqlCommand checkCmd = new SqlCommand(checkSql, conn);
                checkCmd.Parameters.AddWithValue("@tid", tableId);

                object result = checkCmd.ExecuteScalar();
                int orderId;

                if (result != null)
                {
                    orderId = Convert.ToInt32(result);
                }
                else
                {
                    // 2. 新建订单
                    string createSql = "INSERT INTO Orders ([关联桌号], [开单员工], [订单总额], [订单状态]) VALUES (@tid, @uid, 0, 'Pending'); SELECT SCOPE_IDENTITY();";
                    SqlCommand createCmd = new SqlCommand(createSql, conn);
                    createCmd.Parameters.AddWithValue("@tid", tableId);
                    createCmd.Parameters.AddWithValue("@uid", userId);
                    orderId = Convert.ToInt32(createCmd.ExecuteScalar());

                    // 更新桌台状态
                    string updateTable = "UPDATE DiningTables SET [当前状态] = 'Occupied' WHERE [桌台编号] = @tid";
                    SqlCommand updateCmd = new SqlCommand(updateTable, conn);
                    updateCmd.Parameters.AddWithValue("@tid", tableId);
                    updateCmd.ExecuteNonQuery();
                }

                // 3. 循环插入明细
                foreach (var item in cart)
                {
                    string insertDetail = "INSERT INTO OrderDetails ([所属订单], [关联菜品], [点菜数量], [锁定单价], [制作状态]) VALUES (@oid, @did, @qty, @price, 'Waiting')";
                    SqlCommand cmd = new SqlCommand(insertDetail, conn);
                    cmd.Parameters.AddWithValue("@oid", orderId);
                    cmd.Parameters.AddWithValue("@did", item.DishId);
                    cmd.Parameters.AddWithValue("@qty", item.Quantity);
                    cmd.Parameters.AddWithValue("@price", item.Price);
                    cmd.ExecuteNonQuery();
                }

                // 4. 更新订单总额
                string updateTotal = @"UPDATE Orders SET [订单总额] = (SELECT SUM([点菜数量] * [锁定单价]) FROM OrderDetails WHERE [所属订单] = @oid) WHERE [订单编号] = @oid";
                SqlCommand sumCmd = new SqlCommand(updateTotal, conn);
                sumCmd.Parameters.AddWithValue("@oid", orderId);
                sumCmd.ExecuteNonQuery();
            }

            // 清空购物车并提示
            CurrentCart = new List<CartItem>();
            BindCart();

            // 异步回发下使用 ScriptManager 注入提示与跳转脚本
            ScriptManager.RegisterStartupScript(this, GetType(), "orderSuccess", "alert('下单成功！后厨已接单。');window.location='Orders.aspx';", true);
        }

        // 辅助样式
        public string IsActiveCategory(string catName)
        {
            string current = ViewState["CurrentCat"] as string ?? "All";
            return current == catName ? "cat-btn active" : "cat-btn";
        }

        protected void btnFilter_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            LoadDishes(btn.CommandArgument);
            // 筛选后重新绑定分类按钮和全部按钮
            LoadCategories();
            // 重置所有分类按钮样式
            btnAll.CssClass = "cat-btn";
            foreach (RepeaterItem item in rptCategories.Items)
            {
                LinkButton btnCat = item.FindControl("btnCat") as LinkButton;
                if (btnCat != null)
                    btnCat.CssClass = "cat-btn";
            }

            // 设置当前激活分类
            if (btn.CommandArgument == "All")
            {
                btnAll.CssClass = "cat-btn active";
            }
            else
            {
                foreach (RepeaterItem item in rptCategories.Items)
                {
                    LinkButton btnCat = item.FindControl("btnCat") as LinkButton;
                    if (btnCat != null && btnCat.CommandArgument == btn.CommandArgument)
                        btnCat.CssClass = "cat-btn active";
                }
            }
        }
    }
}