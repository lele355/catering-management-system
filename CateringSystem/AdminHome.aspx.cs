using System;
using System.Web;
using System.Web.UI;

namespace CateringSystem
{
    public partial class AdminHome : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // 严格权限控制
            if (Session["Role"]?.ToString() != "Manager")
            {
                Response.Redirect("Default.aspx");
            }
        }
    }
}