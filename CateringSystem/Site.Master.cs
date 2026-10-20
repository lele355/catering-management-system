using System;
using System.Web;
using System.Web.UI;

namespace CateringSystem
{
    public partial class SiteMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                string path = Request.Url.AbsolutePath.ToLower();
                if (!path.EndsWith("login.aspx"))
                {
                    Response.Redirect("Login.aspx");
                }
            }

            if (!IsPostBack)
            {
                // 控制菜单显示逻辑
                string role = Session["Role"]?.ToString() ?? "";

                // 1. 首页分流
                phManagerNav.Visible = (role == "Manager");
                phWaiterNav.Visible = (role == "Waiter");

                // 2. 公共功能 (管理员 + 服务员)
                phCommonNav.Visible = (role == "Manager" || role == "Waiter");

                // 3. 后厨功能 (管理员 + 厨师)
                phKitchenNav.Visible = (role == "Manager" || role == "Chef");

                // 4. 系统设置 (管理员)
                phAdminSettings.Visible = (role == "Manager");
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            Response.Redirect("Login.aspx");
        }

        public string IsActive(string pageName)
        {
            string current = System.IO.Path.GetFileName(Request.Url.AbsolutePath);
            return current.Equals(pageName, StringComparison.OrdinalIgnoreCase) ? "active" : "";
        }

        public string GetRoleName()
        {
            if (Session["Role"] == null) return "";
            string r = Session["Role"].ToString();
            if (r == "Manager") return "店长";
            if (r == "Waiter") return "服务员";
            if (r == "Chef") return "厨师";
            return r;
        }

        public string GetInitials()
        {
            if (Session["RealName"] == null) return "?";
            string name = Session["RealName"].ToString();
            return name.Length > 0 ? name.Substring(0, 1) : "?";
        }
    }
}