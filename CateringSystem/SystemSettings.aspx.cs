using System;
using System.Web.UI;

namespace CateringSystem
{
    public partial class SystemSettings : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Role"]?.ToString() != "Manager")
            {
                Response.Redirect("Default.aspx");
            }
        }
    }
}