using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

using APIEventNotification.Helpers;

namespace APIEventNotification.Controllers
{
    public class UEMAPIController
    {
        public static readonly string UEM_API_URL = "https://{UEM API URL}/api/";
        public static readonly string UEM_API_USERNAME = "{UEM ADMIN USERNAME}";
	public static readonly string UEM_API_PASSWORD = "{UEM ADMIN PASSWORD}";
        public static readonly string UEM_API_KEY = "{UEM API KEY}";

        public static readonly Dictionary<string, string> DEFAULT_HEADERS = new Dictionary<string, string>()
        {
            { "Accept", "application/json" },
            { "Content-Type", "application/json" },
            { "Authorization", string.Format("{0} {1}", "Basic", Base64.Encode(string.Format("{0}:{1}", UEM_API_USERNAME, UEM_API_PASSWORD))) },
            { "aw-tenant-code", UEM_API_KEY }
        };

        #region REQUEST METHODS
        public static async Task<HttpResponseMessage> Request(string endpoint, HttpMethod verb, string postParams = null, Dictionary<string, string> headers = default(Dictionary<string, string>))
        {
            if (headers == null) headers = new Dictionary<string, string>();
            HttpResponseMessage response = null;
            HttpRequestMessage request = null;

            try
            {
                using (HttpClient client = new HttpClient())
                {
                    client.BaseAddress = new Uri(UEM_API_URL);
                    SetupHeaders(client, headers);

                    string resultString = string.Empty;
                    string contentType = (headers.ContainsKey("Content-Type")) ? headers["Content-Type"] : "application/json";

                    if (verb == HttpMethod.Get)
                    {
                        response = await client.GetAsync(endpoint);
                    }
                    else if (verb == HttpMethod.Post)
                    {
                        request = new HttpRequestMessage(HttpMethod.Post, endpoint);
                        request.Content = new StringContent(postParams, Encoding.UTF8, contentType);
                        response = await client.SendAsync(request);
                    }
                    else if (verb == HttpMethod.Put)
                    {
                        request = new HttpRequestMessage(HttpMethod.Put, endpoint);
                        request.Content = new StringContent(postParams, Encoding.UTF8, contentType);
                        response = await client.SendAsync(request);
                    }
                    else if (verb == HttpMethod.Delete)
                    {
                        response = await client.DeleteAsync(endpoint);
                    }

                    return response;
                }
            }
            catch (Exception ex)
            {
                return response;
            }
        }
        #endregion

        #region Public Methods
        public static async Task<JObject> GetDeviceByID(int deviceID)
        {
            JObject device = null;
            HttpResponseMessage response = await Request(string.Format("mdm/devices/{0}", deviceID), HttpMethod.Get);
            string responseString = await response.Content.ReadAsStringAsync();

            try {
                device = JObject.Parse(responseString);
            }
            catch (Exception ex) {
                device = null;
            }
            return device;
        }

        public static async Task<List<JObject>> SearchTagsAtOrgGroupID(int orgGroupID)
        {
            List<JObject> tags = new List<JObject>();
            string endpoint = string.Format("mdm/tags/search?organizationgroupid={0}", orgGroupID);
            HttpResponseMessage response = await Request(endpoint, HttpMethod.Get);
            string responseString = await response.Content.ReadAsStringAsync();

            try
            {
                JToken jsonResponse = JToken.Parse(responseString);
                JArray tagsArray = jsonResponse["Tags"].Value<JArray>();
                if (tagsArray != null && tagsArray.Count > 0)
                {
                    tags = tagsArray.ToObject<List<JObject>>();
                }
            }
            catch (Exception ex) {
                tags = new List<JObject>();
            }

            return tags;
        }

        public static async Task<bool> AddDeviceToTag(int tagID, int deviceID)
        {
            bool added = false;
            string endpoint = string.Format("mdm/tags/{0}/adddevices", tagID);
            JObject postBodyJSON = JObject.Parse(string.Format(
                @"{{
                    'BulkValues': {{
                        'Value': [
                            '{0}'
                        ]
                    }}
                }}", deviceID));
            HttpResponseMessage response = await Request(endpoint, HttpMethod.Post, postBodyJSON.ToString());
            string responseString = await response.Content.ReadAsStringAsync();

            try {
                switch (response.StatusCode)
                {
                    case HttpStatusCode.OK:
                        JObject jsonResponse = JObject.Parse(responseString);
                        int acceptedItems = jsonResponse["AcceptedItems"].Value<int>();
                        if (acceptedItems == 1)
                            added = true;
                        break;
                }
            }
            catch (Exception ex) {

            }

            return added;
        }
        #endregion

        #region Private Methods
        private static void SetupHeaders(HttpClient client, Dictionary<string, string> headers)
        {
            foreach (KeyValuePair<string, string> kvp in DEFAULT_HEADERS)
            {
                if (!headers.ContainsKey(kvp.Key))
                    headers.Add(kvp.Key, kvp.Value);
            }

            if (headers.Count > 0)
            {
                foreach (KeyValuePair<string, string> kvp in headers)
                {
                    client.DefaultRequestHeaders.TryAddWithoutValidation(kvp.Key, kvp.Value);
                }
            }
        }
        #endregion
    }
}
