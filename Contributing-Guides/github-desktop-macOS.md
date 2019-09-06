# Contributing to EUC Samples from GitHub Desktop for macOS #

## Prerequisites for Contributing ##
1. Create your own [GitHub account](https://github.com/join) & sign in 
2. Download [Github Desktop for macOS](https://desktop.github.com) and install it by copying the `GitHub Desktop.app` to your `/Applications` folder
3. On first launch, sign in to GitHub Desktop with your GitHub credentials and complete the first-run screens

## Forking & Cloning the EUC-Samples Repository ## 
1. Open [EUC-Samples](https://github.com/vmware-samples/euc-samples) in Safari (NOTE:  We'll refer to this as Upstream).   
2. Click the **Fork** Button in the top right corner and select your GitHub account as the location to add the new Fork.

> The GitHub website should change to show your repository as ***GitHubUserName / EUC-Samples** forked from vmware-samples/euc-samples*

3. Click the green button to *Clone or Download* and copy the *Clone with HTTPS* URL

> Note:  If you click *Open in Desktop*, you may get redirected to the GitHub Desktop download site if you're not logged in on both Safari and GitHub Desktop

4. In GitHub Desktop, click *Clone a Repository from the Internet* in the wizard (or click **File > Clone Repository**)
5. Choose the URL tab and paste the link copied in step 1
6. Select the Local Path to store your copy of the repository, and click *Clone*
7. When the clone completes, click the *Current Repository* button and you should see that you're currently viewing the *euc-samples* repository forked to your GitHubUserName account (NOTE:  We'll call this the "Origin").

> Some of the samples in the EUC-Samples repository are large.  Depending on your Internet connection speed and hard disk speed, it may take a while to clone the repository locally

## Syncing Changes from EUC-Samples (Upstream) into your Forked Repo (Origin)
Before you send changes to the vmware-samples/euc-samples (upstream) repository, you'll need to bring any changes there down into your fork/branch to merge so that you know your eventual pull request won't create any merge conflicts.   

1. Click on *Current Repository **euc-samples*** in the top left corner, and right-click the *euc-samples* repository under your GitHubUserName.  Click **Open in Terminal**
2. In Terminal, type `git remote -v` and ensure you have four entries -- two for origin (github.com/GitHubUserName) and two for upstream (github.com/vmware-samples).
3. In Terminal, type `git pull upstream master` to pull changes from the upstream EUC-Samples repository (upstream) into your forked repo's master branch (origin).
4. In GitHub Desktop, with your Origin repo selected and within the master branch, click *Push Origin*

## Syncing Changes from EUC-Samples (Origin) into your Forked Repo's Branch
If you are working on a new change in a branch in your Forked copy of the EUC-Samples repository, you may need to bring changes from the main EUC-Samples fork into your branch.

1. Click on *Current Repository **euc-samples*** in the top left corner, and right-click the *euc-samples* repository under your GitHubUserName.  Click **Open in Terminal**
2. In Terminal, type `git pull origin master` to pull changes from your forked repo's master branch into your local branch (e.g. mynewsample)
3. In GitHub Desktop, with your Origin repo selected and within your sample branch, click *Push Origin*
4. You now have a branch in your fork with all the changes that have been merged into the original **vmware-samples/euc-samples** master repository.

## Creating your own working Branch ##
The best practice for contributing is to create your own branch within the repository and make your changes there.  You then use this branch as a staging area to send pull requests to the main branch in order to request your changes be merged for everyone to see.  When you've completed making changes to the branch, best practice is to delete your branch and create a new one when the need arises.

1. Click the heading that says *Current Branch **master*** when viewing your Forked copy of the respository.
2. Click the *New Branch* button
3. Enter a name for your branch (such as `mynewsample`) and click *Create Branch*
4. Click *Publish Branch* in the main area

> Note that GitHub Desktop changes your "Current Branch" to show *Current Branch **YourBranchName*** (e.g. Current Branch mynewsample).   If you get an error creating a branch, ensure you aren't connected to the vmware-samples/EUC-samples repository where you most likely do not have permissions to create a branch.

5. Start making changes to the files you downloaded to your local path

## Creating a Pull Request From a Branch ##
As you make changes you'd like to share, you'll have to create a request (a "Pull Request") to have your changes merged into the main branch from your own branch.   The following steps show how to do this in your Repository

1. Ensure you're *Current Repository* is set to *GitHubUserName/EUC-Samples* and your *Current Branch* is set to your own branch (such as mynewsample)
2. Go through the process to Sync Changes from the main EUC-Samples (Upstream) into your Forked Repo to ensure any merge conflicts are resolved ahead of time.
3. Click the **Changes** tab and check the box next to any modified files you'd like to push up to GitHub.
4. At the bottom of the change window, enter a Summary for your changes and include a description if desired.   In the description, you **MUST** include your sign off per the VMware DCO requirements.   As an example, enter `Signed-off-by: GitHubUsername <GitHubEmail@domain.com>`
5. Click the button **Commit to (YourBranchName)**
6. Click the button **Push Origin** in the top right corner

> This pushes your changes up to your branch copy in GitHub.  Github will show that you've made changes to the branch and offer to create a pull request to logged-in GitHub users.   This also allows you to collaborate on your changes with other GitHub users by allowing them to see the changes you're attempting to make *before* you attempt to merge them into Main.

7. If you're ready to create the pull request, in GitHub Desktop click the **Create Pull Request** button.  This opens GitHub in your web browser and shows the *Open a pull request* UI.

> If GitHub shows *Able to merge* at the top, there are no merge conflicts and your pull request can be easily merged by contributors.

8. Click **Create Pull Request** to create the pull request to merge the changes from your branch into VMware-Samples/EUC-Samples Main Branch.
9. VMware Employees will review your merge request and either request changes/clarification to your submission, or Merge the pull request into the Main branch.
10.  

## Delete a Branch in Your Forked Repository ##

1. While viewing the branch in GitHub Desktop, click the **View on GitHub** button
2. Click the *Branches* header and view your list of branches.
3. Click the trash can next to your branch that is no longer needed (e.g. mynewsample)
4. In GitHub Desktop, change your *Current Branch* to the master branch and click **Fetch Origin**

> GitHub Desktop should remove deleted branches from the UI after 2 weeks

## Congratulations!  You've just contributed your first sample to EUC-Samples! ##


## Help -- I've totally messed something up! ##
If you've somehow managed to totally mess up your copy of the repository, you have 2 options:
1.  Create a new Branch of the forked repository, move any changes you wish to keep into that repository, then delete your non-working branch
2.  Delete your entire fork of the EUC-Samples repository (from within the Settings of the repository on GitHub) and then start over at the Forking and Cloning step in this guide.