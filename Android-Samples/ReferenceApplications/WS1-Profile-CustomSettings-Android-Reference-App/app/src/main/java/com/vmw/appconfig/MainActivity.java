package com.vmw.appconfig;

import android.os.Bundle;
import android.util.Log;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;
import com.vmw.appconfig.constants.AppConstants;

public class MainActivity extends AppCompatActivity {
    private AppConfig appConfig;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        this.appConfig = new AppConfig(getApplicationContext());

        // System.out.println will print to Logcat
        System.out.println("Here is the Environment: " + appConfig.getEnvironment());
        System.out.println("Here is the URL: " + appConfig.getAddress());
        System.out.println("Here is the Example Value: " + appConfig.getAppConfigValue());
        System.out.println("Here is the Serial Number: " + appConfig.getSerialNumber());
        System.out.println("Here is the User: " + appConfig.getUser());

        // Log.i will print to Logcat and device bugreports
        Log.i(AppConstants.LOG_TAG, "Here is the Environment: " + appConfig.getEnvironment());
        Log.i(AppConstants.LOG_TAG, "Here is the URL: " + appConfig.getAddress());
        Log.i(AppConstants.LOG_TAG, "Here is the Example Value: " + appConfig.getAppConfigValue());
        Log.i(AppConstants.LOG_TAG, "Here is the Serial Number: " + appConfig.getSerialNumber());
        Log.i(AppConstants.LOG_TAG, "Here is the User: " + appConfig.getUser());


        String toastSerial = "Serial Number: " + appConfig.getSerialNumber();
        String toastUrl = "URL: " + appConfig.getAddress();
        String toastEnv = "Environment: " + appConfig.getEnvironment();
        String toastExample = "Example Value: " + appConfig.getAppConfigValue();
        String toastUser = "User: " + appConfig.getUser();

        // Toast messages will temporarily appear on the tablet, showing the values retrieved from
        // Workspace ONE UEM Custom Settings profile payload
        Toast.makeText(getApplicationContext(),toastSerial, Toast.LENGTH_SHORT).show();
        Toast.makeText(getApplicationContext(),toastUrl, Toast.LENGTH_SHORT).show();
        Toast.makeText(getApplicationContext(),toastEnv, Toast.LENGTH_SHORT).show();
        Toast.makeText(getApplicationContext(),toastExample, Toast.LENGTH_SHORT).show();
        Toast.makeText(getApplicationContext(),toastUser, Toast.LENGTH_SHORT).show();

    }
}