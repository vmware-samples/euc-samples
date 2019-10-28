/*
 * Copyright 2019 VMware
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.example.android.wsoappanalytics.network.apis;

import java.net.URL;

public class GenericRequest {

    private String method = "GET";
    private URL url = null;
    private String postData = null;

    public GenericRequest(URL url) {
        this("GET", url, null);
    }

    public GenericRequest(String method, URL url, String postData) {
        this.method = method;
        this.url = url;
        this.postData = postData;
    }

    public String getMethod() {
        return method;
    }

    public URL getUrl() {
        return url;
    }

    public String getPostData() {
        return postData;
    }

    public void setMethod(String method) {
        this.method = method;
    }

    public void setUrl(URL url) {
        this.url = url;
    }

    public void setPostData(String postData) {
        this.postData = postData;
    }
}
