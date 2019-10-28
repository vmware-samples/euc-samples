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

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;

import java.util.Locale;

public class HttpURLConnectionApi implements NetworkApi {

    @Override
    public GenericResponse execute(GenericRequest request) {
        try {
            return doExecute(request);
        } catch (IOException e) {
            return new GenericResponse(e);
        }
    }

    public GenericResponse doExecute(GenericRequest request) throws IOException {

        HttpURLConnection conn = (HttpURLConnection) request.getUrl().openConnection();
        conn.setRequestMethod(request.getMethod());

        if (conn.getRequestMethod().toUpperCase(Locale.getDefault()).equals("POST")) {
            conn.getOutputStream().write(request.getPostData().getBytes());

        }


        BufferedReader in = new BufferedReader(new InputStreamReader(conn.getInputStream()));
        StringBuilder sb = new StringBuilder();
        int c = -1;

        while ((c = in.read()) != -1) {
            sb.append((char) c);
        }

        in.close();

        conn.disconnect();

        return new GenericResponse(conn.getResponseCode(), sb.toString());
    }

}
