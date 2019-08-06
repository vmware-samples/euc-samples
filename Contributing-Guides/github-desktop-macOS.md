# Contributing to EUC Samples from GitHub Desktop for macOS #

## Prerequisites for Contributing ##
1. Create your own [GitHub account](https://github.com/join) & sign in 
2. Download [Github Desktop for macOS](https://desktop.github.com) and install it by copying the `GitHub Desktop.app` to your `/Applications` folder
3. On first launch, sign in to GitHub Desktop with your GitHub credentials and complete the first-run screens

## Forking & Cloning the EUC-Samples Repository ## 
1. Open [EUC-Samples](https://github.com/vmware-samples/euc-samples) in Safari.   
2. Click the **Fork** Button in the top right corner and select your GitHub account as the location to add the new Fork.

> The GitHub website should change to show your repository as ***GitHubUserName / EUC-Samples** forked from vmware-samples/euc-samples*

3. Click the green button to *Clone or Download* and copy the *Clone with HTTPS* URL

> Note:  If you click *Open in Desktop*, you may get redirected to the GitHub Desktop download site if you're not logged in on both Safari and GitHub Desktop

4. In GitHub Desktop, click *Clone a Repository from the Internet* in the wizard (or click **File > Clone Repository**)
5. Choose the URL tab and paste the link copied in step 1
6. Select the Local Path to store your copy of the repository, and click *Clone*
7. When the clone completes, click the *Current Repository* button and you should see that you're currently viewing the *euc-samples* repository forked to your GitHubUserName account.

> Some of the samples in the EUC-Samples repository are large.  Depending on your Internet connection speed and hard disk speed, it may take a while to clone the repository locally

## Creating your own working Branch ##
The best practice for contributing is to create your own branch within the repository and add your work there.  You then use this branch as a staging area to send pull requests to the main branch in order to request your changes be merged for everyone to see

1. Click the heading that says *Current Branch **master***
2. Click the *New Branch* button
3. Enter a name for your branch and click *Create Branch*
4. Click *Publish Branch* in the main area

> Note that GitHub Desktop changes your "Current Branch" to show *Current Branch **YourBranchName***

5. Start making changes to the files you downloaded to your local path

## Creating a Pull Request ##
As you make changes you'd like to share, you'll have to create a request (a "Pull Request") to have your changes merged into the main branch from your own branch.   The following steps show how to do this in your Repository

1. Ensure you're *Current Repository* is set to *EUC-Samples* and your *Current Branch* is set to your own branch
2. Click **Fetch Origin** to pull any changes from others from the Main branch into your branch.  It is best if you resolve any Merge conflicts locally before you attempt to push changes upstream
3. Click the **Changes** tab and check the box next to any modified files you'd like to push up to GitHub.
4. At the bottom of the change window, enter a Summary for your changes and include a description if desired.   In the description, you **MUST** include your sign off per the VMware DCO requirements.   As an example, enter `Signed-off-by: GitHubUsername <GitHubEmail@domain.com>`
5. Click the button **Commit to (YourBranchName)**
6. Click the button **Push Origin** in the top right corner

> This pushes your changes up to your branch copy in GitHub.  Github will show that you've made changes to the branch and offer to create a pull request to logged-in GitHub users.   This also allows you to collaborate on your changes with other GitHub users by allowing them to see the changes you're attempting to make *before* you attempt to merge them into Main.

7. If you're ready to create the pull request, in GitHub Desktop click the **Create Pull Request** button.  This opens GitHub in your web browser and shows the *Open a pull request* UI.

> If GitHub shows *Able to merge* at the top, there are no merge conflicts and your pull request can be easily merged by contributors.

8. Click **Create Pull Request** to create the pull request to merge the changes from your branch into Main.
9. VMware Employees will review your merge request and either request changes/clarification to your submission, or Merge the pull request into the Main branch.

## Congratulations!  You've just contributed your first sample to EUC-Samples! ##

## Help -- I've totally messed something up! ##
If you've somehow managed to totally mess up your copy of the repository, you have 2 options:
1.  Create a new Branch of the forked repository, move any changes you wish to keep into that repository, then delete your non-working branch
2.  Delete your entire fork of the EUC-Samples repository (from within the Settings of the repository on GitHub) and then start over at the Forking and Cloning step in this guide.