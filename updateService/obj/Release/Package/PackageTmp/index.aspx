<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="index.aspx.cs" Inherits="updateService.WebForm1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
    <style type="text/css">
        .auto-style1 {
            height: 98px;
            width: 381px;
            font-size: x-large;
        }
        .auto-style4 {
            height: 98px;
            width: 371px;
        }
        .auto-style5 {
            width: 829px;
            margin-left: 0px;
        }
        .auto-style7 {
            height: 98px;
            width: 271px;
        }
        .auto-style9 {
            width: 271px;
            height: 143px;
        }
        .auto-style10 {
            width: 381px;
            height: 143px;
        }
        .auto-style11 {
            height: 143px;
            width: 371px;
        }
        .auto-style16 {
            width: 271px;
            height: 43px;
        }
        .auto-style17 {
            width: 381px;
            height: 43px;
        }
        .auto-style18 {
            height: 43px;
            width: 371px;
        }
        .auto-style19 {
            height: 144px;
            width: 271px;
        }
        .auto-style20 {
            height: 144px;
            width: 381px;
        }
        .auto-style21 {
            height: 144px;
            width: 371px;
        }
        .auto-style22 {
            font-size: xx-large;
        }
        .auto-style23 {
            width: 1258px;
            height: 577px;
        }
    </style>
</head>
<body style="width: 1184px; height: 576px ; background-image: url('bgm.png')">
    <form id="form1" runat="server" >
    <div>
        <br>
        &nbsp;<br />
        <br />
        <br />
        <br />
        </div>
       
        <div align="center" class="auto-style23">

          <table class="auto-style5" border="1" style="border-style: inset; border-width: thin; border-collapse: collapse; border-spacing: inherit; table-layout: fixed;" >
            <tr>
                <td class="auto-style16">&nbsp;&nbsp;1.更新的文件：</td>
                <td class="auto-style17" align="left">（将要更新的文件放到files文件夹下）</td>
                <td class="auto-style18" ></td>
            </tr>
            <tr>
                <td class="auto-style19">
                    2.更新原理<br />
                </td>
                <td class="auto-style20" align="left">
                    <br />
                    1.先检查本地配置是否允许远程更新
         
                     
                    <br />
         
                    <br />
                    2.检查本地与远程版本号是否一样
         
                    <br />
                    <br />
                    3.检查不一样的文件进行更新
        
                    <br />
                    <br />
                    注意：有本地设备时， 更新文件时，不要将配置文件不能将其在服务器，<br />
                    <br />
                    <br />
                </td>
                <td class="auto-style21" > <a href="./DownLoadHandler.ashx?EditType=getVersion">查看当前服务版本</a></td>
            </tr>
            <tr>
                <td class="auto-style7"><span class="auto-style22"><strong>3.下载程序</strong></span></td>
                <td class="auto-style1" >
                    <br />
                    <a href="./win7客户端.rar">炼铁智能系统下载安装</a></td>
                <td class="auto-style4">
                    <br />
                    <br />
                    window 7 以上系统（win7客户端.rar）</td>
            </tr>

               <tr>
                <td class="auto-style9">
                   
                    <br />
                </td>
                <td class="auto-style10" >                  
                     <a href="./xp客户端.rar">炼铁智能系统下载安装</a>
                </td>
                <td class="auto-style11" >XP系统（xp客户端.rar）</td>
            </tr>
        </table>
        </div>
       
    </form>
</body>
</html>

