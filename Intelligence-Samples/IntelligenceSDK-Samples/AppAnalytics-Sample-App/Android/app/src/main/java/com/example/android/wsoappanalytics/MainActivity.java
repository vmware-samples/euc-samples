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

package com.example.android.wsoappanalytics;

import android.Manifest;
import android.app.AlertDialog;
import android.app.Dialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.RestrictionsManager;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationManager;
import android.location.LocationListener;
import android.os.Build;
import android.os.Bundle;
import android.support.v4.app.DialogFragment;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentStatePagerAdapter;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.view.ViewPager;
import android.support.v7.app.ActionBar;
import android.annotation.TargetApi;
import android.support.v7.app.AppCompatActivity;


import com.crittercism.app.Crittercism;

import com.example.android.wsoappanalytics.fragments.ErrorFragment;
import com.example.android.wsoappanalytics.fragments.NetworkFragment;
import com.example.android.wsoappanalytics.fragments.OtherFragment;
import com.example.android.wsoappanalytics.fragments.TransactionFragment;

public class MainActivity extends AppCompatActivity implements ActionBar.TabListener, LocationListener {

    protected LocationManager locationManager;
    private ViewPager viewPager;
    private ActionBar actionBar;
    private TabPagerAdapter tabPagerAdapter;
    private String appID = "";
    private boolean locationServiceAvailable;
    private boolean isGPSEnabled;
    private boolean isNetworkEnabled;
    private boolean forceNetwork;
    private Location location;

    //The minimum distance to change updates in meters
    private static final long MIN_DISTANCE_CHANGE_FOR_UPDATES = 0; // 10 meters

    //The minimum time between updates in milliseconds
    private static final long MIN_TIME_BW_UPDATES = 0;//1000 * 60 * 1; // 1 minute



    private String[] tabs = { "Crash", "Network", "User Flows", "Other " };

    @Override
    public void onLocationChanged(Location location) {
        Crittercism.updateLocation(location);
    }

    @Override
    public void onProviderDisabled(String provider) {

    }

    @Override
    public void onProviderEnabled(String provider) {

    }
    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {

    }

    /**
     * Sets up location service after permissions is granted
     */
    @TargetApi(23)
    private void initLocationService(Context context) {


        if ( Build.VERSION.SDK_INT >= 23 &&
                this.checkSelfPermission( android.Manifest.permission.ACCESS_FINE_LOCATION ) != PackageManager.PERMISSION_GRANTED &&
                this.checkSelfPermission( android.Manifest.permission.ACCESS_COARSE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            this.requestPermissions(new String[]{Manifest.permission.ACCESS_FINE_LOCATION}, 1);
        }

        try   {
            this.locationManager = (LocationManager) context.getSystemService(Context.LOCATION_SERVICE);

            // Get GPS and network status
            this.isGPSEnabled = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
            this.isNetworkEnabled = locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER);

            if (forceNetwork) isGPSEnabled = false;

            if (!isNetworkEnabled && !isGPSEnabled)    {
                // cannot get location
                this.locationServiceAvailable = false;
            }
            //else
            {
                this.locationServiceAvailable = true;

                if (isNetworkEnabled) {
                    locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER,
                            MIN_TIME_BW_UPDATES,
                            MIN_DISTANCE_CHANGE_FOR_UPDATES, this);
                    if (locationManager != null)   {
                        this.location = locationManager.getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
                    }
                }//end if

                if (isGPSEnabled)  {
                    locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER,
                            MIN_TIME_BW_UPDATES,
                            MIN_DISTANCE_CHANGE_FOR_UPDATES, this);

                    if (locationManager != null)  {
                        this.location = locationManager.getLastKnownLocation(LocationManager.GPS_PROVIDER);
                    }
                }
            }
        } catch (Exception ex)  {
            android.util.Log.d( "WSO App Analytics", "Error creating location service: " + ex.getMessage() );

        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);


        appID = getAppConfig();
//        appID = "HARD CODE YOUR KEY IN CASE YOU DON''T USE APP CONFIG";


        if (appID.isEmpty()) {
            AppConfigDialog dialog = new AppConfigDialog();
            dialog.show(getSupportFragmentManager(), "AppConfigDialog");
            finishActivity(0);
            return;
        } else {


            Crittercism.setLoggingLevel(Crittercism.LoggingLevel.Debug);
            Crittercism.initialize(getApplicationContext(), appID);

            initLocationService(this);
            Crittercism.updateLocation(location);

            setContentView(R.layout.activity_work);

            this.viewPager = (ViewPager) findViewById(R.id.pager);
            this.actionBar = getSupportActionBar();

            this.tabPagerAdapter = new TabPagerAdapter(getSupportFragmentManager());

            this.viewPager.setAdapter(this.tabPagerAdapter);

            this.actionBar.setHomeButtonEnabled(false);
            this.actionBar.setDisplayShowTitleEnabled(false);
            this.actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_TABS);

            tabs[3] = tabs[3].concat(appID.substring(0,4));

            for (String tabName : this.tabs) {
                actionBar.addTab(actionBar.newTab().setText(tabName).setTabListener(this));
            }
        }
    }

    @Override
    public void onTabSelected(ActionBar.Tab tab, FragmentTransaction fragmentTransaction) {
        this.viewPager.setCurrentItem(tab.getPosition());
    }

    @Override
    public void onTabUnselected(ActionBar.Tab tab, FragmentTransaction fragmentTransaction) {

    }

    @Override
    public void onTabReselected(ActionBar.Tab tab, FragmentTransaction fragmentTransaction) {

    }

    // Application Configuration method
    // Expect from Workspace ONE UEM the AppID and Sandbox parameters
    // AppID - appid created when application is registered in Workspace ONE Intelligence
    // Sandbox - when true app analytics will be sent to the sandbox environment, otherwise goes to production
    protected String getAppConfig() {
        RestrictionsManager appRestrictions =
                (RestrictionsManager) getApplicationContext()
                        .getSystemService(Context.RESTRICTIONS_SERVICE);

        if (appRestrictions.getApplicationRestrictions().containsKey("Sandbox")) {
            if ( appRestrictions.getApplicationRestrictions().getBoolean("Sandbox") ) {
                // Reserved to be able to set Sandbox or Production
            }
        }


        if (appRestrictions.getApplicationRestrictions().containsKey("AppID")) {
            return appRestrictions.getApplicationRestrictions().getString("AppID");
        } else {
            // no appID provided - you may want to consider a default AppID
            return "";
        }

    }

    private static class TabPagerAdapter extends FragmentStatePagerAdapter {
        public TabPagerAdapter(FragmentManager fm) {
            super(fm);
        }

        @Override
        public Fragment getItem(int i) {
            switch (i) {
                case 0:
                    return new ErrorFragment();
                case 1:
                    return new NetworkFragment();
                case 2:
                    return new TransactionFragment();
                case 3:
                    return new OtherFragment();
                default:
                    throw new AssertionError("Unrecognized tab: " + i);
            }
        }

        @Override
        public int getCount() {
            return 4;
        }
    }


    public static class AppConfigDialog extends DialogFragment {
        @Override
        public Dialog onCreateDialog(Bundle savedInstanceState) {

            // Use the Builder class for convenient dialog construction
            AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
            builder.setTitle("AppID not configured in Workspace ONE");
            builder.setMessage("\n1 - Close this App\n\n2 - Add AppID and respective value for this app in Workspace ONE UEM Console\n\n 3 - Redeploy the App");

            builder.setPositiveButton("OK", ((DialogInterface dialog, int which) -> {
                // do something here
            }));

//            builder.setPositiveButton("OK", new DialogInterface.OnClickListener() {
//                public void onClick(DialogInterface dialog, int id) {
//                    // You don't have to do anything here if you just
//                    // want it dismissed when clicked
//                }
//            });

            // Create the AlertDialog object and return it
            return builder.create();
        }
    }
}
