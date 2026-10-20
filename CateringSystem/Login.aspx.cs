using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;              // 数据库核心命名空间
using System.Data.SqlClient;    // SQL Server 专用命名空间
using System.Configuration;     // 读取配置文件用

namespace CateringSystem
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // 页面加载时执行，暂时不需要写东西
        }

        // 当用户点击“登录”按钮时执行这个方法
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            // 1. 获取用户输入
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();

            // 2. 简单校验
            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                lblMessage.Text = "账号或密码不能为空！";
                return;
            }

            // 3. 读取 Web.config 里的连接字符串
            string connStr = ConfigurationManager.ConnectionStrings["CateringConn"].ConnectionString;

            // 4. 连接数据库
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                try
                {
                    conn.Open(); // 尝试打开连接

                    // 5. 准备 SQL 语句 (使用中文列名)
                    // @u 和 @p 是参数占位符，防止 SQL 注入攻击
                    string sql = "SELECT [用户编号], [真实姓名], [角色权限] FROM Staffs WHERE [登录账号] = @u AND [登录密码] = @p";

                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    {
                        // 6. 填入参数
                        cmd.Parameters.AddWithValue("@u", username);
                        cmd.Parameters.AddWithValue("@p", password);

                        // 7. 执行查询
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // 1. 保存登录信息
                                Session["UserID"] = reader["用户编号"];
                                Session["RealName"] = reader["真实姓名"];
                                Session["Role"] = reader["角色权限"];

                                string role = reader["角色权限"].ToString();

                                // 2. 根据角色跳转到不同主页
                                if (role == "Manager")
                                {
                                    // 管理员 -> 管理仪表盘
                                    Response.Redirect("AdminHome.aspx");
                                }
                                else if (role == "Chef")
                                {
                                    // 厨师 -> 后厨看板
                                    Response.Redirect("Kitchen.aspx");
                                }
                                else
                                {
                                    // 服务员 -> 前台点餐主页
                                    Response.Redirect("Default.aspx");
                                }
                            }
                            else
                            {
                                lblMessage.Text = "账号或密码错误，请重试。";
                            }
                        }
                    }
                }
                catch (Exception ex)
                {
                    // 如果数据库连不上，这里会显示具体错误
                    lblMessage.Text = "系统连接失败：" + ex.Message;
                }
            }
        }
    }
}