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


import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.Request;

import java.io.IOException;
import java.util.Locale;

public class OkHttpApi implements NetworkApi {
    public static final MediaType PLAIN_TEXT = MediaType.parse("text/plain; charset=utf-8");

    @Override
    public GenericResponse execute(GenericRequest request) {
        try {
            return doExecute(request);
        } catch (IOException e) {
            return new GenericResponse(e);
        }
    }

    public GenericResponse doExecute(GenericRequest request) throws IOException {
        OkHttpClient uninstrumentedClient = new okhttp3.OkHttpClient();

        Response okResponse;
        Request okRequest;
        int status = -1;

        OkHttpClient client = com.crittercism.app.Crittercism.instrumentOkHttpClient(uninstrumentedClient);

        Request.Builder builder = new Request.Builder();
        builder.url(request.getUrl());

        if (request.getMethod().toUpperCase(Locale.getDefault()).equals("POST")) {
            RequestBody body = RequestBody.create(PLAIN_TEXT, request.getPostData());
            builder.post(body);
        }

        okResponse = client.newCall(builder.build()).execute();

        return new GenericResponse(okResponse.code(), okResponse.body().string());
    }

}
