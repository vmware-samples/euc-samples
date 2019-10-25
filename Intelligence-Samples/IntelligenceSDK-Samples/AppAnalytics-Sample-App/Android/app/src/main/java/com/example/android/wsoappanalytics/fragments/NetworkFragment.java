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

package com.example.android.wsoappanalytics.fragments;

import android.os.AsyncTask;
import android.support.v4.app.Fragment;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.CheckedTextView;
import android.widget.TextView;

import com.crittercism.app.Crittercism;
import com.example.android.wsoappanalytics.R;
import com.example.android.wsoappanalytics.network.apis.ApacheHttpClientApi;
import com.example.android.wsoappanalytics.network.apis.GenericRequest;
import com.example.android.wsoappanalytics.network.apis.GenericResponse;
import com.example.android.wsoappanalytics.network.apis.HttpURLConnectionApi;
import com.example.android.wsoappanalytics.network.apis.NetworkApi;
import com.example.android.wsoappanalytics.network.apis.OkHttpApi;


import java.net.MalformedURLException;
import java.net.URL;

public class NetworkFragment extends Fragment {

    private View v;
    private TextView responsesTextView;

    private CheckedTextView httpUrlConnectionCheckBox;
    private CheckedTextView apacheHttpClientCheckBox;
    private CheckedTextView okHttpClientCheckBox;

    private CheckedTextView httpCheckBox;
    private CheckedTextView httpsCheckBox;

    private NetworkApi networkApi = new OkHttpApi();
    private String urlScheme = "http";

    @Override
    public View onCreateView(LayoutInflater inflater,
                             ViewGroup container, Bundle savedInstanceState) {

        v = inflater.inflate(R.layout.fragment_network, container, false);

        NetworkApiClickListener netApiClickListener = new NetworkApiClickListener();
        this.httpUrlConnectionCheckBox = (CheckedTextView) v.findViewById(R.id.httpURLConnectionApi);
        this.apacheHttpClientCheckBox = (CheckedTextView) v.findViewById(R.id.apacheHttpClientApi);
        this.okHttpClientCheckBox = (CheckedTextView) v.findViewById(R.id.okHttpApi);
        this.httpUrlConnectionCheckBox.setOnClickListener(netApiClickListener);
        this.apacheHttpClientCheckBox.setOnClickListener(netApiClickListener);
        this.okHttpClientCheckBox.setOnClickListener(netApiClickListener);

        UrlSchemeClickListener schemeClickListener = new UrlSchemeClickListener();
        this.httpCheckBox = (CheckedTextView) v.findViewById(R.id.httpCheckBox);
        this.httpsCheckBox = (CheckedTextView) v.findViewById(R.id.httpsCheckBox);
        this.httpCheckBox.setOnClickListener(schemeClickListener);
        this.httpsCheckBox.setOnClickListener(schemeClickListener);

        setNetworkAction(R.id.get1ByteButton, new NetworkAction("GET", "/bytes/1"));
        setNetworkAction(R.id.get1KbButton, new NetworkAction("GET", "/bytes/1024"));
        setNetworkAction(R.id.get1MbButton, new NetworkAction("GET", "/bytes/1048576"));

        setNetworkAction(R.id.post1ByteButton, new NetworkAction("POST", "/post", 1));
        setNetworkAction(R.id.post1KbButton, new NetworkAction("POST", "/post", 1024));
        setNetworkAction(R.id.post1MbButton, new NetworkAction("POST", "/post", 1024 * 1024));

        setNetworkAction(R.id.latency1SecondButton, new NetworkAction("GET", "/delay/1"));
        setNetworkAction(R.id.latency3SecondButton, new NetworkAction("GET", "/delay/3"));
        setNetworkAction(R.id.latency5SecondButton, new NetworkAction("GET", "/delay/5"));

        setNetworkAction(R.id.status200Button, new NetworkAction("GET", "/status/200"));
        setNetworkAction(R.id.status404Button, new NetworkAction("GET", "/status/404"));
        setNetworkAction(R.id.status500Button, new NetworkAction("GET", "/status/500"));

        this.responsesTextView = (TextView)v.findViewById(R.id.responsesTextView);
        this.responsesTextView.setMovementMethod(new ScrollingMovementMethod());

        return v;
    }

    private void setNetworkAction(int buttonId, NetworkAction action) {
        Button b = (Button) v.findViewById(buttonId);
        b.setOnClickListener(action);
    }

    private class NetworkApiClickListener implements View.OnClickListener {

        @Override
        public void onClick(View v) {
            NetworkFragment.this.httpUrlConnectionCheckBox.setChecked(false);
            NetworkFragment.this.apacheHttpClientCheckBox.setChecked(false);
            NetworkFragment.this.okHttpClientCheckBox.setChecked(false);

            CheckedTextView clicked = (CheckedTextView) v;
            clicked.setChecked(true);

            if (clicked == NetworkFragment.this.httpUrlConnectionCheckBox) {
                NetworkFragment.this.networkApi = new HttpURLConnectionApi();
            } else if (clicked == NetworkFragment.this.apacheHttpClientCheckBox) {
                NetworkFragment.this.networkApi = new ApacheHttpClientApi();
            } else if (clicked == NetworkFragment.this.okHttpClientCheckBox) {
                NetworkFragment.this.networkApi = new OkHttpApi();
            }
        }
    }

    private class UrlSchemeClickListener implements View.OnClickListener {

        @Override
        public void onClick(View v) {
            NetworkFragment.this.httpCheckBox.setChecked(false);
            NetworkFragment.this.httpsCheckBox.setChecked(false);

            CheckedTextView clicked = (CheckedTextView) v;
            clicked.setChecked(true);

            if (clicked == NetworkFragment.this.httpCheckBox) {
                NetworkFragment.this.urlScheme = "http";
            } else if (clicked == NetworkFragment.this.httpsCheckBox) {
                NetworkFragment.this.urlScheme = "https";
            } else {
                throw new AssertionError("Unknown view: " + v.getId());
            }
        }
    }

    private class NetworkAction implements View.OnClickListener {

        private final String HOST = "httpbin.org";  // wikipedia.com
        private String method;
        private String path;
        private int postBytes = 0;

        private NetworkAction(String method, String path) {
            this(method, path, 0);
        }

        private NetworkAction(String method, String path, int postBytes) {
            this.method = method;
            this.path = path;
            this.postBytes = postBytes;
        }

        @Override
        public void onClick(View v) {
            try {
                String scheme = NetworkFragment.this.urlScheme;
                URL url = new URL(scheme + "://" + HOST + path);
                StringBuilder postData = new StringBuilder(postBytes);
                for (int i = 0; i < postBytes; i++) {
                    postData.append('x');
                }

                GenericRequest request = new GenericRequest(this.method, url, postData.toString());

                new RequestExecutor(NetworkFragment.this.networkApi, request).execute();
            } catch (MalformedURLException e) {
                throw new AssertionError(e);
            }
        }
    }

    private class RequestExecutor extends AsyncTask<Void, Void, Void> {

        private NetworkApi api;
        private GenericRequest request;
        private GenericResponse response;
        private long start;
        private long total;

        private RequestExecutor(NetworkApi api, GenericRequest request) {
            this.api = api;
            this.request = request;
        }

        @Override
        protected Void doInBackground(Void... params) {
            start = System.currentTimeMillis();

            this.response = this.api.execute(this.request);

            total =  (System.currentTimeMillis() - start);


            return null;
        }

        @Override
        protected void onPostExecute(Void aVoid) {
            String msg = "(" + this.response.getStatus() + ") " + this.request.getUrl().toExternalForm();
            NetworkFragment.this.responsesTextView.append(msg + "\n");

            if ( ! ( this.api instanceof OkHttpApi ) ) {
                Crittercism.logNetworkRequest(request.getMethod(), request.getUrl(), total,
                        response.getBody().length(),
                        request.getPostData().length(),
                        response.getStatus(), response.getException());
            }
        }
    }
}
