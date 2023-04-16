package com.vmw.appconfig;

import android.content.Context;
import android.content.RestrictionsManager;
import android.os.Bundle;

public class AppConfig {

    private static final String AppConfigValue = "VALUE1";
    private static final String AppConfigURL = "URL";
    private static final String AppConfigEnvironment = "ENVIRONMENT";
    private static final String SerialNumber = "SERIALNUM";
    private static final String UserName = "USERNAME";

    private String env;
    private String address;
    private String exampleValue;
    private String serialNum;
    private String user;

    public AppConfig(Context context) {
        RestrictionsManager restrictionsManager = (RestrictionsManager) context.getSystemService(Context.RESTRICTIONS_SERVICE);
        Bundle appRestrictions = restrictionsManager.getApplicationRestrictions();
        getApplicationRestrictions(appRestrictions);
    }

    private void getApplicationRestrictions(Bundle appRestrictions) {
        if (appRestrictions.containsKey(AppConfigValue)) {
            exampleValue = appRestrictions.getString(AppConfigValue);
        }
        if (appRestrictions.containsKey(AppConfigURL)) {
            address = appRestrictions.getString(AppConfigURL);
        }
        if (appRestrictions.containsKey(AppConfigEnvironment)) {
            env = appRestrictions.getString(AppConfigEnvironment);
        }
        if (appRestrictions.containsKey(SerialNumber)) {
            serialNum = appRestrictions.getString(SerialNumber);
        }
        if (appRestrictions.containsKey(UserName)) {
            user = appRestrictions.getString(UserName);
        }
    }

    public String getAddress() {
        return address;
    }
    public String getAppConfigValue() {
        return exampleValue;
    }
    public String getEnvironment() {
        return env;
    }
    public String getSerialNumber() {
        return serialNum;
    }
    public String getUser() {
        return user;
    }
}

