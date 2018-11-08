<%@ WebHandler Language="C#" Class="DownLoadHandler" %>

using System;
using System.Web;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Security.Cryptography;
using updateService;

public class DownLoadHandler : IHttpHandler
{


    private void GetFileInfo(DirectoryInfo TheFolder, string relativePath,Dictionary<string, DateTime> fileUpdateTime)
    {
        //遍历文件
        foreach (FileInfo NextFile in TheFolder.GetFiles())
        {
            fileUpdateTime.Add(relativePath + NextFile.Name, NextFile.LastWriteTime);
        }
        //遍历文件夹
        foreach (DirectoryInfo NextFolder in TheFolder.GetDirectories())
        {
            GetFileInfo(NextFolder, relativePath + NextFolder.Name + @"/",fileUpdateTime);
        }
    }


    public void ProcessRequest (HttpContext context) {

        string path =
                  HttpContext.Current.Server.MapPath("files\\");

        //获取文件的保存路径
        string EditType = context.Request["EditType"];
        if (EditType == "DownLoadFile")
        {
            string filePath = path + context.Request["FileName"];
            DownloadFile(context, filePath, context.Request["FileName"], 0);
        }
        else if (EditType == "UpdateInfo")
        {
            Dictionary<string, DateTime> fileUpdateTime = new Dictionary<string, DateTime>();
            DirectoryInfo TheFolder = new DirectoryInfo(path);
            GetFileInfo(TheFolder, "", fileUpdateTime);
            StringBuilder sb = new StringBuilder();
            sb.AppendLine("<?xml version=\"1.0\"?>");
            sb.AppendLine("<Update>");
            foreach (KeyValuePair<string, DateTime> item in fileUpdateTime)
            {
                sb.Append("<File FileName=\"");
                sb.Append(item.Key);
                sb.Append("\" LastWriteTime=\"");
                sb.Append(item.Value);
                sb.Append("\"/>");
                sb.AppendLine();
            }
            sb.AppendLine("</Update>");
            context.Response.Write(sb.ToString());
        }
        else if (EditType == "getVersion")
        {
            try
            {
                 Config config=Config.LoadConfig(Path.Combine(path, "AppUpdate.config"));
                 string version = config.Version.ToString();
                 StringBuilder sb = new StringBuilder();
                 sb.AppendLine("<?xml version=\"1.0\"?>");
                 sb.AppendLine("<Update>");
         
                sb.Append("<File version=\"");
                sb.Append(version);               
                sb.Append("\"/>");
                sb.AppendLine();           
                sb.AppendLine("</Update>");
                 context.Response.ContentType = "text/plain";
                 context.Response.Write(sb.ToString());

            }
            catch (Exception ex)
            {
                 context.Response.ContentType = "text/plain";
                 context.Response.Write("没有获取到在线配置信息");
            }


           
        }
        else
        {

            context.Response.ContentType = "text/plain";
            context.Response.Write("Hello World,任春旺");
        }

    }

    /**//// <summary>
        /// 下载文件，支持大文件、续传、速度限制。支持续传的响应头Accept-Ranges、ETag，请求头Range 。
        /// Accept-Ranges：响应头，向客户端指明，此进程支持可恢复下载.实现后台智能传输服务（BITS），值为：bytes；
        /// ETag：响应头，用于对客户端的初始（200）响应，以及来自客户端的恢复请求，
        /// 必须为每个文件提供一个唯一的ETag值（可由文件名和文件最后被修改的日期组成），这使客户端软件能够验证它们已经下载的字节块是否仍然是最新的。
        /// Range：续传的起始位置，即已经下载到客户端的字节数，值如：bytes=1474560- 。
        /// 另外：UrlEncode编码后会把文件名中的空格转换中+（+转换为%2b），但是浏览器是不能理解加号为空格的，所以在浏览器下载得到的文件，空格就变成了加号；
        /// 解决办法：UrlEncode 之后, 将 "+" 替换成 "%20"，因为浏览器将%20转换为空格
        /// </summary>
        /// <param name="httpContext">当前请求的HttpContext</param>
        /// <param name="filePath">下载文件的物理路径，含路径、文件名</param>
        /// <param name="speed">下载速度：每秒允许下载的字节数</param>
        /// <returns>true下载成功，false下载失败</returns>
    public static bool DownloadFile(HttpContext httpContext, string filePath, string saveFileName, long speed)
    {
        bool ret = true;
        try
        {
            //--验证：HttpMethod，请求的文件是否存在#region--验证：HttpMethod，请求的文件是否存在
            switch (httpContext.Request.HttpMethod.ToUpper())
            { //目前只支持GET和HEAD方法
                case "GET":
                case "HEAD":
                    break;
                default:
                    httpContext.Response.StatusCode = 501;
                    return false;
            }
            if (!File.Exists(filePath))
            {
                httpContext.Response.StatusCode = 404;
                return false;
            }


            #region 定义局部变量
            long startBytes = 0;
            int packSize = 1024 * 10; //分块读取，每块10K bytes
            string fileName = Path.GetFileName(filePath);
            string fileName2 = "";

            if (string.IsNullOrEmpty(saveFileName))
            {
                fileName2 = Path.GetFileName(filePath);
            }
            else
            {
                fileName2 = saveFileName;
            }

            FileStream myFile = new FileStream(filePath, FileMode.Open, FileAccess.Read, FileShare.ReadWrite);
            BinaryReader br = new BinaryReader(myFile);
            long fileLength = myFile.Length;

            int sleep = 0;
            if (speed >0)
            {
                sleep = (int)Math.Ceiling(1000.0 * packSize / speed);//毫秒数：读取下一数据块的时间间隔
            }
            string lastUpdateTiemStr = File.GetLastWriteTimeUtc(filePath).ToString("r");
            string eTag = HttpUtility.UrlEncode(fileName, Encoding.UTF8) + lastUpdateTiemStr;//便于恢复下载时提取请求头;
            #endregion

            //--验证：文件是否太大，是否是续传，且在上次被请求的日期之后是否被修改过--------------#region--验证：文件是否太大，是否是续传，且在上次被请求的日期之后是否被修改过--------------
            if (myFile.Length > Int32.MaxValue)
            {//-------文件太大了-------
                httpContext.Response.StatusCode = 413;//请求实体太大
                return false;
            }

            if (httpContext.Request.Headers["If-Range"] != null)//对应响应头ETag：文件名+文件最后修改时间
            {
                //----------上次被请求的日期之后被修改过--------------
                if (httpContext.Request.Headers["If-Range"].Replace("\"", "") != eTag)
                {//文件修改过
                    httpContext.Response.StatusCode = 412;//预处理失败
                    return false;
                }
            }


            try
            {
                //-------添加重要响应头、解析请求头、相关验证-------------------#region -------添加重要响应头、解析请求头、相关验证-------------------
                httpContext.Response.Clear();
                httpContext.Response.Buffer = false;
                httpContext.Response.AddHeader("Content-MD5", GetMD5Hash(myFile));//用于验证文件
                httpContext.Response.AddHeader("Accept-Ranges", "bytes");//重要：续传必须
                httpContext.Response.AppendHeader("ETag", "\"" + eTag + "\"");//重要：续传必须
                httpContext.Response.AppendHeader("Last-Modified", lastUpdateTiemStr);//把最后修改日期写入响应                
                httpContext.Response.ContentType = "application/octet-stream";//MIME类型：匹配任意文件类型
                httpContext.Response.AddHeader("Content-Disposition", "attachment;filename=" + HttpUtility.UrlEncode(fileName2, Encoding.UTF8).Replace("+", "%20"));
                httpContext.Response.AddHeader("Content-Length", (fileLength - startBytes).ToString());
                httpContext.Response.AddHeader("Connection", "Keep-Alive");
                httpContext.Response.ContentEncoding = Encoding.UTF8;
                if (httpContext.Request.Headers["Range"] != null)
                {//------如果是续传请求，则获取续传的起始位置，即已经下载到客户端的字节数------
                    httpContext.Response.StatusCode = 206;//重要：续传必须，表示局部范围响应。初始下载时默认为200
                    string[] range = httpContext.Request.Headers["Range"].Split(new char[] { '=', '-' });//"bytes=1474560-"
                    startBytes = Convert.ToInt64(range[1]);//已经下载的字节数，即本次下载的开始位置  
                    if (startBytes < 0 || startBytes >= fileLength)
                    {//无效的起始位置
                        return false;
                    }
                }
                if (startBytes > 0)
                {//------如果是续传请求，告诉客户端本次的开始字节数，总长度，以便客户端将续传数据追加到startBytes位置后----------
                    httpContext.Response.AddHeader("Content-Range", string.Format(" bytes {0}-{1}/{2}", startBytes, fileLength - 1, fileLength));
                }


                //-------向客户端发送数据块-------------------#region -------向客户端发送数据块-------------------
                br.BaseStream.Seek(startBytes, SeekOrigin.Begin);
                int maxCount = (int)Math.Ceiling((fileLength - startBytes + 0.0) / packSize);//分块下载，剩余部分可分成的块数
                for (int i = 0; i < maxCount && httpContext.Response.IsClientConnected; i++)
                {//客户端中断连接，则暂停
                    httpContext.Response.BinaryWrite(br.ReadBytes(packSize));
                    httpContext.Response.Flush();
                    if (sleep > 1) System.Threading.Thread.Sleep(sleep);
                }

            }
            catch
            {
                ret = false;
            }
            finally
            {
                br.Close();
                myFile.Close();
            }
        }
        catch
        {
            ret = false;
        }
        return ret;
    }

    /* 
哈希函数将任意长度的二进制字符串映射为固定长度的小型二进制字符串。加密哈希函数有这样一个属性：在计算上不大可能找到散列为相同的值的两个不同的输入；也就是说，两组数据的哈希值仅在对应的数据也匹配时才会匹配。数据的少量更改会在哈希值中产生不可预知的大量更改。 
MD5 算法的哈希值大小为 128 位。 
MD5 类的 ComputeHash 方法将哈希作为 16 字节的数组返回。请注意，某些 MD5 实现会生成 32 字符的十六进制格式哈希。若要与此类实现进行互操作，请将 ComputeHash 方法的返回值格式化为十六进制值。 
*/
    /// <summary> 
    /// 获取输入流的由MD5计算的Hash值，不可逆转 
    /// <param name="inputStream"></param> 
    /// <returns></returns> 
    public static string GetMD5Hash(Stream inputStream)
    {
        // Create a new instance of the MD5CryptoServiceProvider object. 
        MD5 md5Hasher = MD5.Create();//不可逆转 
        byte[] data = md5Hasher.ComputeHash(inputStream);
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < data.Length; i++)
        {
            sb.Append(data[i].ToString("x2"));//十六进 
        }
        // 返回十六进制的字符串 
        return sb.ToString();
    }

    /// <summary> 
    /// 验证输入流由MD5计算的Hash值 
    /// </summary> 
    /// <param name="inputStream"></param> 
    /// <param name="hash"></param> 
    /// <returns></returns> 
    public static bool VerifyMD5Hash(Stream inputStream, string hash)
    {
        string hashOfInputStream = GetMD5Hash(inputStream);
        StringComparer comparer = StringComparer.OrdinalIgnoreCase;
        if (comparer.Compare(hashOfInputStream, hash) == 0)
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    public bool IsReusable {
        get {
            return false;
        }
    }

}