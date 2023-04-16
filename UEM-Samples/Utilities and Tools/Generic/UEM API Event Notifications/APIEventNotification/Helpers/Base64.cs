using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace APIEventNotification.Helpers
{
    public class Base64
    {
        public static string Encode(string s)
        {
            Byte[] bytes = System.Text.Encoding.UTF8.GetBytes(s);
            return System.Convert.ToBase64String(bytes);
        }

        public static string Decode(string base64Data)
        {
            if (base64Data == null) return string.Empty;
            var base64Bytes = Convert.FromBase64String(base64Data);
            return Encoding.UTF8.GetString(base64Bytes);
        }
    }
}
