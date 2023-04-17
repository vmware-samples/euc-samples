using Microsoft.AspNetCore.Mvc;

using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;

// For more information on enabling Web API for empty projects, visit https://go.microsoft.com/fwlink/?LinkID=397860

namespace APIEventNotification.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class WebhookController : ControllerBase
    {
        [HttpGet]
        public IEnumerable<string> Get()
        {
            return new string[] { "value1", "value2" };
        }

        [HttpPost]
        public async Task<IActionResult> Post(dynamic json)
        {
            JObject jObj = JObject.Parse(json.ToString());
            string eventType = jObj["EventType"].Value<string>();
            IActionResult result = null;

            switch (eventType)
            {
                case "Enrollment Complete":
                    result = await HandleDeviceEnrollment(jObj);
                    break;

                default:
                    result = Ok();
                    break;
            }
            
            return result;
        }

        private async Task<IActionResult> HandleDeviceEnrollment(JObject json)
        {
            try
            {
                // Enrollment Complete event received - get the full device details
                int deviceID = json["DeviceId"].Value<int>();
                JObject deviceJSON = await UEMAPIController.GetDeviceByID(deviceID);

                // Search for applicable tags in this organization group
                int enrolledGroupId = deviceJSON["LocationGroupId"]["Id"]["Value"].Value<int>();
                List<JObject> availableTags = await UEMAPIController.SearchTagsAtOrgGroupID(enrolledGroupId);

                // Apply a tag to the enrolled device based on some logic
                // In this case, all Windows 10 (WinRT) devices get Custom Tag 1 and all other deice types get Custom Tag 2
                string devicePlatform = deviceJSON["Platform"].Value<string>();
                string desiredTagName = string.Empty;
                switch (devicePlatform)
                {
                    case "WinRT":
                        desiredTagName = "Custom Tag 1";
                        break;

                    default:
                        desiredTagName = "Custom Tag 2";
                        break;
                }
                JObject tagJSON = availableTags.Find(x => x["TagName"].Value<string>() == desiredTagName);
                int tagID = tagJSON["Id"]["Value"].Value<int>();
                bool didAddTag = await UEMAPIController.AddDeviceToTag(tagID, deviceID);

                if (didAddTag)
                    return Ok();
                else
                    return NotFound();
            }
            catch (Exception ex)
            {
                // If an exception occurs, report as a 500 response with the exception message and payload body
                return Problem(ex.Message, json.ToString(), 500);
            }
        }
    }
}
