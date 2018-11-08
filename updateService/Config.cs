using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;
using System.Xml.Serialization;

namespace updateService
{
    public class Config
    {
        public static Config LoadConfig(string file)
        {
            XmlSerializer serializer = new XmlSerializer(typeof(Config));
            StreamReader textReader = new StreamReader(file);
            Config config = serializer.Deserialize(textReader) as Config;
            textReader.Close();
            return config;
        }
        private bool enabled = true;
        public bool Enabled
        {
            get
            {
                return this.enabled;
            }
            set
            {
                this.enabled = value;
            }
        }

        private string systemName = string.Empty;
        public string SystemName
        {
            get
            {
                return this.systemName;
            }
            set
            {
                this.systemName = value;
            }
        }

        private string serverUrl = string.Empty;
        public string ServerUrl
        {
            get
            {
                return this.serverUrl;
            }
            set
            {
                this.serverUrl = value;
            }
        }
        private int version = 0;
        public int Version
        {
            get
            {
                return this.version;
            }
            set
            {
                this.version = value;
            }
        }

        private string ftpUser = string.Empty;
        public string FtpUser
        {
            get
            {
                return ftpUser;
            }

            set
            {
                ftpUser = value;
            }
        }

        private string ftpPassW = string.Empty;
        public string FtpPassW
        {
            get
            {
                return ftpPassW;
            }

            set
            {
                ftpPassW = value;
            }
        }

        private string reStart = string.Empty;
        public string ReStart
        {
            get
            {
                return reStart;
            }

            set
            {
                reStart = value;
            }


        }



    }
}