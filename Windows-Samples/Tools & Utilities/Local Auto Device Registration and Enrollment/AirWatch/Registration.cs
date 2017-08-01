namespace LocalDevice
{

extern alias WebHelpers;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
//using System.Web;
using System.Net;
using System.IO;
using System.Runtime.Serialization;
using WebHelpers::System.Web.Helpers;


    public class Registration
    {
        public Registration()
        {
            
        }

        public void initialize(string currentPath)
        {
            this.localsettings = new Dictionary<string, string>();
            string iniFile = @"localdevice.ini";
            if(!string.IsNullOrEmpty(currentPath)){
                iniFile = currentPath + iniFile;
            }
            string[] settings = File.ReadAllLines(iniFile);
            Regex regex = new Regex("([^=]*)=(.*)");
            foreach (string setting in settings)
            {
                Match match = regex.Match(setting);
                if (match.Success)
                {
                    {
                        this.localsettings.Add(match.Groups[1].Value, match.Groups[2].Value);
                    }
                }
            }
        }

        public Dictionary<string, string> localsettings = new Dictionary<string,string>();
        public Dictionary<string, string> tracker = new Dictionary<string, string>();

        public string GetUserID(string username)
        {
            return GetUserID(username, false);
        }

        public string GetUserID(string username, bool createUserOnFailure)
        {
            string path = "/system/users/search";
            string parameters = "username=" + username;
        
            try
            {                
                var responseValue = GetWebResponse(path, parameters);

                if (!responseValue.Contains("Error:"))
                {
                    var userId = -1;
                    if (!string.IsNullOrEmpty(responseValue))
                    {
                        var data = Json.Decode(responseValue);
                        if (data.Total >= 1)
                        {
                            int match = 0;
                            for(match=0;match<data.Total;match++)
                            {
                                //Need to get the exact match
                                if (data.Users[match].UserName == username)
                                {
                                    break;
                                }
                            }
                            //Make sure that this is a domain user
                            if (data.Users[match].SecurityType == 1)
                            {
                                userId = data.Users[match].Id.Value;
                            }
                        }
                        else if (data.Total == 0 && createUserOnFailure)
                        {
                            return CreateUser(username);
                        }
                    }
                    else if (createUserOnFailure)
                    {
                        return CreateUser(username);
                    }
                    return userId.ToString();
                }
                else
                {
                    return responseValue;
                }
            }
            catch (Exception e)
            {
                return "Error: " + e.Message;
            }
        }

        public string CreateUser(string username)
        {
            string path = "/system/users/adduser";
            string parameters = "";

            string userId = "";
            string jsonData = @"{'LocationGroupId':" + localsettings["LocationGroupID"] +
                ",'SecurityType':1" +
                ",'UserName':'" + username +
                "','Status':true}";

            try
            {
                var responseValue2 = GetWebResponse(path, parameters, "POST", jsonData);

                if (!responseValue2.Contains("Error: ") && !string.IsNullOrEmpty(responseValue2))
                {
                    var responseData = Json.Decode(responseValue2);
                    return responseData["Value"].ToString();
                }
                else
                {
                    return responseValue2;
                }
            }
            catch (Exception ex)
            {
                 return "Error: " + ex.Message;
            }
            return userId;
        }

        public bool RegisterDeviceArg(System.Collections.Hashtable simpleArgs)
        {
            Dictionary<string, string> neatArgs = new Dictionary<string,string>();
            foreach (var key in simpleArgs.Keys)
            {
                neatArgs.Add(key.ToString(), simpleArgs[key].ToString());
            }
            tracker.Add("HashtableParse", "1");
            return RegisterDeviceArg(neatArgs);
        }


        public bool RegisterDeviceArg(Dictionary<string, string> simpleArgs)
        {
            var result = "";
            string username = simpleArgs["Username"];
            if (username.Contains('\\'))
            {
                username = username.Substring(username.IndexOf('\\') + 1, username.Length - username.IndexOf('\\') - 1);
            }
            else if (username.Contains('@'))
            {
                username = username.Substring(username.IndexOf('@'));
            }

            if (simpleArgs.ContainsKey("CreateUser") && simpleArgs.ContainsKey("Ownership"))
            {
                result = this.RegisterDevice(username, simpleArgs["SerialNumber"],
                   (simpleArgs["CreateUser"] == "true"), simpleArgs["Ownership"]);
            }
            else if (simpleArgs.ContainsKey("CreateUser"))
            {
                result = this.RegisterDevice(username, simpleArgs["SerialNumber"], (simpleArgs["CreateUser"] == "true"));
            }
            else
            {
                result = this.RegisterDevice(username, simpleArgs["SerialNumber"]);
            }
            //Validate that we have 
            result = this.ValidateDeviceRegistration(username, simpleArgs["SerialNumber"]);
            if (result == "True")
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        public string GetOrganizationGroupByGroupID(string groupID)
        {
            string path = "/system/groups/search";
            string parameters = "groupid=" + groupID;
            try{
                var responseValue = GetWebResponse(path, parameters);

                if (!responseValue.Contains("Error:") && !string.IsNullOrEmpty(responseValue))
                {
                    var userId = -1;
                    var data = Json.Decode(responseValue);
                    if (data.OrganizationGroups.Length > 0)
                    {
                        //Make sure that this is a domain user
                        return data.OrganizationGroups[0].Id.ToString();
                    }
                }
            }
            catch (Exception e)
            {
                return "Error: " + e.Message;
            }
            return "False";
        }


        public string RegisterDevice(string username, string serialNumber, bool createUserOnFailure, string ownership)
        {
            int userId = -1;
            try
            {
                var userIdStr = GetUserID(username, createUserOnFailure);
                if (!userIdStr.Contains("Error:"))
                {
                    if (int.TryParse(userIdStr, out userId))
                    {
                        return RegisterDevice(userId, serialNumber, ownership);
                    }
                }
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
            return "False";
        }

        public string RegisterDevice(string username, string serialNumber)
        {
            return RegisterDevice(username, serialNumber, false, "C");
        }

        public string RegisterDevice(string username, string serialNumber, bool createUserOnFailure)
        {
            return RegisterDevice(username, serialNumber, createUserOnFailure, "C");
        }

        public string RegisterDevice(int userid, string serialNumber, string ownership)
        {
            string path = "/system/users/" + userid.ToString() + "/registerdevice";
            string parameters = "";

            if (!localsettings.ContainsKey("LocationGroupID") && localsettings.ContainsKey("GroupID"))
            {
                var lgid = GetOrganizationGroupByGroupID(localsettings["GroupID"]);
                if (!string.IsNullOrEmpty(lgid.ToString()))
                {
                    localsettings.Add("LocationGroupID", lgid.ToString());
                }
            }

            string jsonData = @"{'LocationGroupID':'" + localsettings["LocationGroupID"] +
                    "','Ownership':'" + ownership + "','PlatformId':12,'FriendlyName':'Pre-registered Device'," + 
                    "'MessageType':'Email','ToEmailAddress':'" + localsettings["AdminEmailAddress"] + 
                    "','SerialNumber':'" + serialNumber + "'}";

            tracker.Add("JSON Data", jsonData);

            try
            {
                var responseValue = GetWebResponse(path, parameters, "POST", jsonData);
                tracker.Add("Registration Response", responseValue);
                return responseValue;
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            }
            return "Error: Did not register";
        }

        public string ValidateDeviceRegistration(string username, string serialnumber)
        {
            string path = "/system/users/enrollmenttoken/search";
            string parameters = "username=" + username + "&organizationgroupid=" + localsettings["LocationGroupID"] + (serialnumber.Contains("+") ?
                "" : "&serialnumber=" + serialnumber);
            try{
                var responseValue = GetWebResponse(path, parameters);

                if (!responseValue.Contains("Error:") && !string.IsNullOrEmpty(responseValue))
                {
                    var userId = -1;
                    var data = Json.Decode(responseValue);
                    if (data.Device.Length > 0)
                    {
                        //reverse lookup to be thourough
                        foreach (var device in data.Device)
                        {
                            if (device.SerialNumber == serialnumber)
                            {
                                return "True";
                            }
                        }
                    }
                }
            }
            catch (Exception e)
            {
                return "Error: " + e.Message;
            }
            return "False";
        }

        private string GetWebResponse(string path, string parameters)
        {
            return GetWebResponse(path, parameters, "GET", "");
        }

        private string GetWebResponse(string path, string parameters, string httpMethod, string data)
        {
            
            HttpWebRequest request = CreateWebRequest(localsettings["API_Server"] + path + "?" + parameters, httpMethod, data);
            
            var responseValue = string.Empty;
            try
            {
                using (var response = (HttpWebResponse)request.GetResponse())
                {

                    if (response.StatusCode != HttpStatusCode.OK)
                    {
                        string message = String.Format("POST failed. Received HTTP {0}", response.StatusCode);
                        //throw new ApplicationException(message);
                    }

                    // grab the response  
                    using (var responseStream = response.GetResponseStream())
                    {
                        using (var reader = new StreamReader(responseStream))
                        {
                            responseValue = reader.ReadToEnd();
                        }
                    }

                }
                return responseValue;
            }
            catch (WebException ex)
            {
                using (var responseStream = ex.Response.GetResponseStream())
                {
                    using (var reader = new StreamReader(responseStream))
                    {
                        responseValue = reader.ReadToEnd();
                    }
                }
                return "Error: " + responseValue;
            }
            catch (Exception ex)
            {
                return "Error: " + ex.Message;
            } 
        }

        private HttpWebRequest CreateWebRequest(string endPoint, string httpMethod, string data)
        {
            var request = (HttpWebRequest)WebRequest.Create(endPoint);

            request.Method = httpMethod;
            request.ContentLength = 0;
            request.ContentType = "application/json;version=2";
            request.Accept = "application/json;version=2";

            request.Headers["Authorization"] = localsettings["Authorization"];
            request.Headers["aw-tenant-code"] = localsettings["API_Key"];

            if (httpMethod == "POST" && !string.IsNullOrEmpty(data))
            {
                request.ContentLength = data.Length;
                using (var RequestStream = request.GetRequestStream())
                {
                    using (var StreamWriter = new StreamWriter(RequestStream))
                    {
                        StreamWriter.Write(data);  
                    }
                }
            }
                 

            return request;
        }

       
    }
}
