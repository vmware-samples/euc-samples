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

package com.example.android.wsoappanalytics.errors;

import com.crittercism.app.Crittercism;

import org.json.JSONException;
import org.json.JSONObject;

public class JsonCustomError extends CustomError {

    @Override
    protected void performError() throws Throwable {
        super.performError();                try {
            new JSONObject("{ invalid object");
        } catch (JSONException e) {
            Crittercism.logHandledException(e);
        }
    }

}
