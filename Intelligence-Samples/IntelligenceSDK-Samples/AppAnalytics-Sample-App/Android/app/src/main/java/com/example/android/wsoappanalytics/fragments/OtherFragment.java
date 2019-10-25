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

import android.support.v4.app.Fragment;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;
import com.example.android.wsoappanalytics.R;
import com.crittercism.app.Crittercism;

import org.json.JSONException;
import org.json.JSONObject;

public class OtherFragment extends Fragment {

    private View v;

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        this.v = inflater.inflate(R.layout.fragment_other, container, false);

        setButtonAction(v, R.id.usernameBobButton, new UserNameButtonAction("Bob"));
        setButtonAction(v, R.id.usernameSueButton, new UserNameButtonAction("Sue"));
        setButtonAction(v, R.id.usernameJoeButton, new UserNameButtonAction("Joe"));

        setButtonAction(v, R.id.level1Button, new MetadataButtonAction("Game Level", "Level 1"));
        setButtonAction(v, R.id.level5Button, new MetadataButtonAction("Game Level", "Level 5"));
        setButtonAction(v, R.id.level7Button, new MetadataButtonAction("Game Level", "Level 7"));

        setButtonAction(v, R.id.breadcrumbUserInputButton, new BreadcrumbButtonAction("registration started"));
        setButtonAction(v, R.id.breadcrumbSendDataButton, new BreadcrumbButtonAction("user input"));
        setButtonAction(v, R.id.breadcrumbRegStartButton, new BreadcrumbButtonAction("send data (API call)"));
        setButtonAction(v, R.id.breadcrumbEndRegButton, new BreadcrumbButtonAction("registration ended"));

        setButtonAction(v, R.id.optInButton, new OptOutButtonAction(false));
        setButtonAction(v, R.id.optOutButton, new OptOutButtonAction(true));

        updateOptOutStatusLabel();

        return v;
    }

    private void setButtonAction(View v, int id, View.OnClickListener listener) {
        Button button = (Button) v.findViewById(id);
        button.setOnClickListener(listener);
    }

    private void updateOptOutStatusLabel() {
        TextView textView = (TextView)this.v.findViewById(R.id.statusText);
        boolean currentStatus = Crittercism.getOptOutStatus();
        textView.setText("OPT-OUT STATUS: " + currentStatus);
    }

    private class UserNameButtonAction implements View.OnClickListener {

        private String username;

        private UserNameButtonAction(String username) {
            this.username = username;
        }

        @Override
        public void onClick(View v) {
            Crittercism.setUsername(this.username);
        }
    }

    private class MetadataButtonAction implements View.OnClickListener {
        private String key;
        private String value;

        private MetadataButtonAction(String key, String value) {
            this.key = key;
            this.value = value;
        }

        @Override
        public void onClick(View v) {
            JSONObject json = new JSONObject();

            try {
                json.putOpt(key, value);
            } catch (JSONException e) {
                throw new AssertionError("Bad key/value: " + key + " " + value);
            }

            Crittercism.setMetadata(json);
        }
    }

    private class BreadcrumbButtonAction implements View.OnClickListener {

        private String breadrumb;

        private BreadcrumbButtonAction(String breadrumb) {
            this.breadrumb = breadrumb;
        }

        @Override
        public void onClick(View v) {
            Crittercism.leaveBreadcrumb(this.breadrumb);
        }
    }

    private class OptOutButtonAction implements View.OnClickListener {
        private boolean shouldOptOut;

        private OptOutButtonAction(boolean shouldOptOut) {
            this.shouldOptOut = shouldOptOut;
        }

        @Override
        public void onClick(View v) {
            Crittercism.setOptOutStatus(this.shouldOptOut);
            OtherFragment.this.updateOptOutStatusLabel();
        }
    }

}
