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
import java.util.LinkedList;


/**
 * This class can be used to throw an exception or crash with a stack trace that is defined at runtime
 */
public class CustomError {

    public static enum StackFrame {
        FUNCTION_A,
        FUNCTION_B,
        FUNCTION_C,
        FUNCTION_D;

        public String toString() {
            char alpha = (char) ((int)'A' + this.ordinal());
            return "function " + alpha;
        }
    }

    private LinkedList<StackFrame> stackFrames = new LinkedList<StackFrame>();

    public CustomError() { }

    public final void addFrame(StackFrame frame) {
        stackFrames.addLast(frame);
    }

    public final void copyFrames(CustomError error) {
        this.stackFrames = new LinkedList<StackFrame>(error.stackFrames);
    }

    public final int numberOfFrames() {
        return stackFrames.size();
    }

    public final StackFrame frameAtIndex(int i) {
        return stackFrames.get(i);
    }

    public final void clear() {
        stackFrames.clear();
    }

    public final void crash() {
        try {
            initiateError();
        } catch (Throwable t) {
            throw new RuntimeException(t.getMessage(), t);
        }
    }

    public final void throwException() {
        try {
            initiateError();
        } catch (Throwable e) {
            Crittercism.logHandledException(e);
        }
    }

    /**
     * This template method allows inheritors to cause an exception in a specific way
     */
    protected void performError() throws Throwable {
        throw new RuntimeException("custom stack trace");
    }

    private void initiateError() throws Throwable {
        if (stackFrames.size() == 0) {
            performError();
        }

        LinkedList<StackFrame> stackFrames = new LinkedList<StackFrame>(this.stackFrames);
        StackFrame frame = stackFrames.pop();

        switch (frame) {
            case FUNCTION_A:
                functionA(stackFrames);
                break;
            case FUNCTION_B:
                functionB(stackFrames);
                break;
            case FUNCTION_C:
                functionC(stackFrames);
                break;
            case FUNCTION_D:
                functionD(stackFrames);
                break;
            default:
                throw new AssertionError("Unrecognized stack frame: " + frame);
        }
    }

    private void functionA(LinkedList<StackFrame> stackFrames) throws Throwable {
        if (stackFrames.size() == 0) {
            performError();
        }

        StackFrame frame = stackFrames.pop();

        switch (frame) {
            case FUNCTION_A:
                functionA(stackFrames);
                break;
            case FUNCTION_B:
                functionB(stackFrames);
                break;
            case FUNCTION_C:
                functionC(stackFrames);
                break;
            case FUNCTION_D:
                functionD(stackFrames);
                break;
            default:
                throw new AssertionError("Unrecognized stack frame: " + frame);
        }
    }

    private void functionB(LinkedList<StackFrame> stackFrames) throws Throwable {
        if (stackFrames.size() == 0) {
            performError();
        }

        StackFrame frame = stackFrames.pop();

        switch (frame) {
            case FUNCTION_A:
                functionA(stackFrames);
                break;
            case FUNCTION_B:
                functionB(stackFrames);
                break;
            case FUNCTION_C:
                functionC(stackFrames);
                break;
            case FUNCTION_D:
                functionD(stackFrames);
                break;
            default:
                throw new AssertionError("Unrecognized stack frame: " + frame);
        }
    }

    private void functionC(LinkedList<StackFrame> stackFrames) throws Throwable {
        if (stackFrames.size() == 0) {
            performError();
        }

        StackFrame frame = stackFrames.pop();

        switch (frame) {
            case FUNCTION_A:
                functionA(stackFrames);
                break;
            case FUNCTION_B:
                functionB(stackFrames);
                break;
            case FUNCTION_C:
                functionC(stackFrames);
                break;
            case FUNCTION_D:
                functionD(stackFrames);
                break;
            default:
                throw new AssertionError("Unrecognized stack frame: " + frame);
        }
    }

    private void functionD(LinkedList<StackFrame> stackFrames) throws Throwable {
        if (stackFrames.size() == 0) {
            performError();
        }

        StackFrame frame = stackFrames.pop();

        switch (frame) {
            case FUNCTION_A:
                functionA(stackFrames);
                break;
            case FUNCTION_B:
                functionB(stackFrames);
                break;
            case FUNCTION_C:
                functionC(stackFrames);
                break;
            case FUNCTION_D:
                functionD(stackFrames);
                break;
            default:
                throw new AssertionError("Unrecognized stack frame: " + frame);
        }
    }

}

