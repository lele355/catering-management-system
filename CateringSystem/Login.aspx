<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="CateringSystem.Login" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>登录 - 悦食餐饮管理系统</title>
    <!-- 引入图标库 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
    <style>
        /* 全局重置 */
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Segoe UI', 'Microsoft YaHei', sans-serif;
            /* 更偏绿色的主题渐变背景 */
            background: linear-gradient(135deg, #86efac 0%, #22c55e 100%);
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            overflow: hidden;
            position: relative;
        }
        /* 去除丑竹子装饰，使用干净留白 */

        /* 登录卡片 */
        .login-card {
            background: rgba(255,255,255,0.55);
            padding: 50px 40px;
            border-radius: 20px;
            border: 1px solid rgba(255,255,255,.35);
            -webkit-backdrop-filter: saturate(140%) blur(12px);
            backdrop-filter: saturate(140%) blur(12px);
            box-shadow: 0 15px 40px rgba(34,197,94,0.15);
            width: 100%;
            max-width: 400px;
            text-align: center;
            transition: transform 0.3s ease;
            animation: slideUp 0.6s ease-out;
        }

        .login-card:hover {
            transform: translateY(-5px);
        }

        /* 标题样式 */
        .login-header {
            margin-bottom: 40px;
        }

        .logo-icon {
            font-size: 48px;
            color: #22c55e;
            margin-bottom: 15px;
            display: inline-block;
        }

        .login-header h2 {
            color: #22c55e;
            font-weight: 700;
            font-size: 24px;
            letter-spacing: 1px;
        }

        .login-header p {
            color: #166534;
            font-size: 14px;
            margin-top: 5px;
        }

        /* 输入框组 */
        .input-group {
            position: relative;
            margin-bottom: 25px;
            text-align: left;
        }

        .input-group i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #b2bec3;
            font-size: 18px;
            transition: color 0.3s;
        }

        .form-control {
            width: 100%;
            padding: 15px 15px 15px 45px; /* 左边留出图标位置 */
            border: 2px solid rgba(34,197,94,0.15);
            border-radius: 12px;
            font-size: 16px;
            outline: none;
            background: rgba(134,239,172,0.12);
            transition: all 0.2s ease;
            color: #166534;
            box-shadow: inset 0 1px 2px rgba(22,101,52,0.06);
        }

        .form-control::placeholder {
            color: #16a34a;
        }

        /* 聚焦状态 */
        .form-control:focus {
            border-color: #22c55e;
            background: white;
            box-shadow: 0 0 0 4px rgba(34, 197, 94, 0.18);
        }

        .form-control:focus + i {
            color: #22c55e;
        }

        /* 登录按钮 */
        .btn-login {
            width: 100%;
            padding: 15px;
            background: linear-gradient(135deg, #86efac 0%, #22c55e 100%);
            color: white;
            border: none;
            border-radius: 50px;
            font-size: 18px;
            font-weight: 600;
            cursor: pointer;
            box-shadow: 0 8px 20px rgba(34, 197, 94, 0.25);
            transition: all 0.2s ease;
            margin-top: 10px;
        }

        .btn-login:hover {
            transform: scale(1.02);
            box-shadow: 0 8px 20px rgba(34, 197, 94, 0.4);
        }

        .btn-login:active {
            transform: scale(0.98);
        }

        /* 错误提示 */
        .error-container {
            min-height: 24px;
            margin-top: 15px;
        }

        .error-msg {
            color: #e74c3c;
            font-size: 14px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 5px;
            animation: shake 0.4s ease-in-out;
        }

        /* 底部版权 */
        .footer-text {
            margin-top: 30px;
            color: #b2bec3;
            font-size: 12px;
        }

        /* 动画定义 */
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-5px); }
            75% { transform: translateX(5px); }
        }

        /* 响应式调整 */
        @media (max-width: 480px) {
            .login-card {
                padding: 30px 20px;
                width: 90%;
            }
        }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-card">
            <div class="login-header">
                <i class="fas fa-utensils logo-icon"></i>
                <h2>悦食餐饮系统</h2>
                <p>Welcome Back! 请登录您的账号</p>
            </div>
            
            <div class="input-group">
                <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="请输入账号"></asp:TextBox>
                <i class="fas fa-user"></i>
            </div>
            
            <div class="input-group">
                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" placeholder="请输入密码"></asp:TextBox>
                <i class="fas fa-lock"></i>
            </div>

            <asp:Button ID="btnLogin" runat="server" Text="登 录" CssClass="btn-login" OnClick="btnLogin_Click" />
            
            <div class="error-container">
                <asp:Label ID="lblMessage" runat="server" CssClass="error-msg"></asp:Label>
            </div>

            <div class="footer-text">
                &copy; <%: DateTime.Now.Year %> 悦食连锁餐饮管理系统
            </div>
        </div>
    </form>
</body>
</html>