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

import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.client.methods.HttpUriRequest;
import org.apache.http.entity.ByteArrayEntity;
import org.apache.http.impl.client.DefaultHttpClient;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.URISyntaxException;
import java.util.Locale;

public class ApacheHttpClientApi implements NetworkApi {

    @Override
    public GenericResponse execute(GenericRequest request) {
        try {
            return doExecute(request);
        } catch (URISyntaxException e) {
            throw new AssertionError(e);
        } catch (IOException e) {
            return new GenericResponse(e);
        }
    }

    public GenericResponse doExecute(GenericRequest request) throws IOException, URISyntaxException {
        HttpClient client = new DefaultHttpClient();
        HttpUriRequest apacheRequest = null;

        if (request.getMethod().toUpperCase(Locale.getDefault()).equals("GET")) {
            apacheRequest = new HttpGet(request.getUrl().toURI());
        } else if (request.getMethod().toUpperCase(Locale.getDefault()).equals("POST")) {
            HttpPost post = new HttpPost(request.getUrl().toURI());
            post.setEntity(new ByteArrayEntity(request.getPostData().getBytes("UTF8")));
            apacheRequest = post;
        }

        HttpResponse response = client.execute(apacheRequest);
        BufferedReader in = new BufferedReader(new InputStreamReader(response.getEntity().getContent()));
        StringBuilder sb = new StringBuilder();
        int c;

        while ((c = in.read()) != -1) {
            sb.append((char) c);
        }

        return new GenericResponse(response.getStatusLine().getStatusCode(), sb.toString());
    }

}
