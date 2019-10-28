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
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;


import com.example.android.wsoappanalytics.R;
import com.crittercism.app.Crittercism;

public class TransactionFragment extends Fragment {

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

        View v = inflater.inflate(R.layout.fragment_transaction, container, false);


        ListView listView = (ListView) v.findViewById(R.id.transactionsListView);
        final String labels[] = { "Login", "Browse", "Reserve", "Confirm" };

        ArrayAdapter arrayAdapter = new ArrayAdapter<String>(
                getActivity(),
                R.layout.transaction_buttons,
                R.id.transactionName,
                labels)
        {
            @Override
            public View getView(int position, View convertView, ViewGroup parent) {
                View view = super.getView(position, convertView, parent);
                String txnName = labels[position];

                Button begin = (Button) view.findViewById(R.id.beginButton);
                begin.setOnClickListener(new BeginTransactionButtonAction(txnName));

                Button end = (Button) view.findViewById(R.id.endButton);
                end.setOnClickListener(new EndTransactionButtonAction(txnName));

                Button fail = (Button) view.findViewById(R.id.failButton);
                fail.setOnClickListener(new FailTransactionButtonAction(txnName));

                Button increment = (Button) view.findViewById(R.id.valueIncrementButton);
                increment.setOnClickListener(new IncrementTransactionButtonAction(txnName));

                return view;
            }
        };

        listView.setAdapter(arrayAdapter);

        return v;
    }

    private static class BeginTransactionButtonAction extends TransactionButtonAction {

        private BeginTransactionButtonAction(String transactionName) {
            super(transactionName);
        }

        @Override
        public void onClick(View v) {
            Crittercism.beginUserflow(this.transactionName);
        }
    }

    private static class EndTransactionButtonAction extends TransactionButtonAction {

        private EndTransactionButtonAction(String transactionName) {
            super(transactionName);
        }

        @Override
        public void onClick(View v) {
            Crittercism.endUserflow(this.transactionName);
        }
    }

    private static class FailTransactionButtonAction extends TransactionButtonAction {

        private FailTransactionButtonAction(String transactionName) {
            super(transactionName);
        }

        @Override
        public void onClick(View v) {
            Crittercism.failUserflow(this.transactionName);
        }
    }

    private static class IncrementTransactionButtonAction extends TransactionButtonAction {

        private IncrementTransactionButtonAction(String transactionName) {
            super(transactionName);
        }

        @Override
        public void onClick(View v) {
            int value = Crittercism.getUserflowValue(this.transactionName);
            if (value == -1) {
                // The value wasn't set
                value = 1;
            }

            Crittercism.setUserflowValue(this.transactionName, value + 1);
        }
    }

    private static abstract class TransactionButtonAction implements View.OnClickListener {
        protected String transactionName;

        private TransactionButtonAction(String transactionName) {
            this.transactionName = transactionName;
        }
    }

}
