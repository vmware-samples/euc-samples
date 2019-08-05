#Contributing to EUC-Samples

:+1::tada: First off, thanks for taking the time to contribute! :tada::+1:

#### Table Of Contents
[Getting started with Git and VMware-Samples ](#getting-started-with-Git-and-VMware-Samples)

[How to contribute to EUC-Samples ](#How-to-contribute-to-EUC-Samples )

##Getting started with Git and VMware-Samples 

1. Create your own [git account](https://github.com/join) & sign in 
1. Get your own copy of the VMware-Samples repo ([https://help.github.com/articles/fork-a-repo/](https://help.github.com/articles/fork-a-repo/)) 
	1. Go to [https://github.com/vmware-samples/euc-samples ](https://github.com/vmware-samples/euc-samples )
	1. Fork the repo to your account 
	1. Go to the fork in your Git repository 
	1. Click the Clone button to copy the repo URL 
1. If you don't already have Git on your machine: 
	1. Download and install git on your local machine 
	1. Create a project folder
	2. Open git Bash in that folder
	3. Run: 

			git clone https://github.com/<username>/EUC-samples.git
1. Now you should have the 'EUC-samples' folder in your projects folder. This is the local version of your repository. We'll refer to it as Local. Your fork is a copy of the original repo. We'll refer to it as Remote. The original repository is EUC-Samples in VMware-Samples. We'll refer to this as Main.
2. You will default to the Master branch of your repo. 
3. Verify your Local repo has the remote repo configured.
	1. Run:

			git remote –v 

	1. This will list 2 records pointing to your remote, both nicknamed Origin. Now you can reference the Remote without listing the whole URL, but simply by saying 'origin' in your commands.
2. Now we need to configure Git to sync your fork with Main so you can always get the most current version.
	1. Run  

			git remote add upstream https://github.com/vmware-samples/EUC-samples.git 

			git remote –v 

	1. This will now list 4 records, 2 pointing to your Remote, and 2 pointing to Main, nicknamed 'Upstream'. Now you can reference the Remote without listing the whole URL, but simply by saying 'origin' in your commands.
2. Now you're all set to begin making your changes 

##How to contribute to EUC-Samples 


1. If you already have forked from Main and created a Local copy, fetch from upstream to merge latest changes to your local master branch. You can do this by running: 

		git checkout master 

		git fetch upstream 

1. Create a local feature branch to begin working on your changes. This branch will only be created locally. 

		git branch feature-name 

1. Make your changes (like copying files over, editing files, etc.)
2. Once you're happy with a set of changes, make your commit (be sure to sign your commit) 

		git add . 

		git commit -s -m 'your commit message here' 

1. Continue making changes and committing locally (sign every commit)
2. Once you're ready to push these commits to Remote, run the following command to create the feature branch on your Remote 

		git push origin feature-name 

1. Navigate to your Remote and create a Pull Request (PR) to merge your commits to the Main repo 
1. Someone will review and approve your PR 
	1. Clean up your Local and Remote repos 
	1. Delete your local feature branch (git checkout master; git branch -D feature-name) 
	1. Delete your remote feature branch (do this from the UI) 
	1. Update your local master branch from the main repo master branch (git checkout master; git fetch upstream) 
	1. Push your local master to your remote master (git push origin master) 
