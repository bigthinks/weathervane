# NPSP Extention Template
Want to extend the functionality of the [Nonprofit Starter Pack](https://github.com/SalesforceFoundation/Cumulus)?  This template provides a basic project skeleton so you can hit the ground running.  The main goal is to get you up and running with [CumulusCI](https://github.com/SalesforceFoundation/CumulusCI), the  process built and used by the Salesforce Foundation's development team to manage the development and release process for the Nonprofit Starter Pack.

Our hope is that by making it easier to share your contribution to the Nonprofit Starter Pack community, you can spend your time focusing on the business logic that adds value to the community.  This template should make it easy to automate much of the time consuming part of building and releasing an managed package which extends the Nonprofit Starter Pack.

# Quick Start
This section assumes you are somewhat familiar working with metadata in Salesforce from your local computer and have some basic familiarity with Git and GitHub.  The examples below show git commandline commands but you can accomplish the same functionality through most GUI git tools as well.

## Step 1: Setup
The first step is to set up version control and test the build scripts against a fresh Developer Edition org.  This section should take about 30 minutes to complete.

* Create a Repository for your project in GitHub
* Clone the GitHub repository to your local computer
* Unzip the NPSP-Extension-Template.zip file into your cloned local repository
* Edit cumulusci.properties
	* **cumulusci.package.name**: The name of your package
	* **cumulusci.package.namespace**: Your package's namespace.  You can leave blank if you don't know this yet
	* **cumulusci.github.url.raw**: For example, *https://raw.github.com/SalesforceFoundation/Cumulus*
* [Create a Developer Edition](https://developer.salesforce.com/signup) org to use as your personal dev org for the project
    * Log into your Developer Edition org and reset your security token, you'll need it later.  
    * Make sure you have Chatter and Chatter Publisher Actions enabled in the org
    * Create a directory on your computer to store org credential files (`mkdir ~/orgs`)
    * Create a file in the credentials directory for your Developer Edition org (name it however you want to refer to your personal dev org).  The file should contain the following:
    
        sf.username=YOUR@USER_HERE
        sf.password=PASSWORDSECURITYTOKEN
        sf.serverurl=https://login.salesforce.com
        
* Now, we need to set up the build scripts:
	* Clone the CumulusCI repository: 
	    
	    `git clone git@github.com:SalesforceFoundation/CumulusCI ../CumulusCI`
	* Run `ant updatePackageXml` to test that the build scripts work and to update your package.xml
    * In your local repository, create a link to the org credentials file as `build.properties`.  This tells the build scripts to use your personal dev org as the default target org
* Now, run the build: `ant deployCI` and watch as your new org is set up for development
* When the build completes, check the Installed Packages in the org
* Go to Setup -> Create -> Packages and you should see your package, ready for development
* If all goes well, add all the files, commit them, and push to GitHub:

    git add .gitignore
    git add --all
    git commit
    git push

At this point, anyone can check out your repository, create an org, and set up a free development environment to contribute to your package!

## Step 2: Develop
Now that we have our development environment ready, it's time to start writing the great new idea that inspired you to go through that setup in the first place :)

* Create a new branch in GitHub.  The name should start with `feature/` and you can put whatever you want after that (i.e. `feature/secondary-contact-on-account`).  The CumulusCI process isolates all your changes into branches.  It's easy to do and invaluable to helping multiple people work on the same project or a single person to work on multiple features without them interferring with eachother.
* Check out the branch in your local repository:
    * git fetch --all
    * git checkout -b feature/your-branch-name-here
* Develop your changes to the metadata under the src directory
* If you added any metadata, you should run `ant updatePackageXml` to regenerate `src/package.xml`
* Run `ant deployCI` again to run the entire build against your Developer Edition org to ensure all your tests are passing
* Commit and push your changes to GitHub
* Submit a Pull Request to merge your branch into master when the feature is ready
* Merge the Pull Request
* Repeat...

## Step 3: Package
After you've merged your first feature branch, it's time to think about building a beta managed package.  This will allow you to ensure that your metadata will work in a managed package and since it's a beta there is no risk of locking you into anything like a release version would.

This should take about 30 minutes to get your first beta managed package

* Create a new Developer Edition org to serve as your packaging org
	* Repeat the same process as in Step 1 to configure the org and create a credentials file
* Run the build against the packaging org: `ant -propertyfile PATH/TO/CREDENTIALS deployCI`
* Log into the packaging org and go to Setup -> Create -> Packages.  Edit the configuration to assign the org a namespace and then assign your package as the managed package.
* Edit `cumulusci.properties` and ensure that `cumulusci.package.namespace` is correct
* Run `ant -propertyfile PATH/TO/CREDENTIALS deployCIPackageOrg`
* In the packaging org, go to Setup -> Create -> Packages and click on your package.  Click the Upload button and upload a beta version of your package
* Create a new Developer Edition org to test beta packages
 	* Repeat the same process as in Step 1 to configure the org and create a credentials file
* Install the beta package in the org then run the tests by running `ant -propertyfile PATH/TO/CREDENTIALS runAllTests`

## Step 4: Automate
Now comes the real payoff!  We're going to set up everything needed to automate the entire process for you so all you have to do is write code, commit and push to Github, and submit and merge Pull Requests to continue developing.

To get you going quickly, we're going to use CumulusCI's integration with [Codeship](https://codeship.com), a cloud hosted continuous integration service which can be used for free to build your public GitHub repository.

We'll also need one more Developer Edition org which will be used to run apex tests against all feature branch commits pushed to the repository.

* Sign in to Codeship using your GitHub account
* Click **Create New Project**
* Select your GitHub repository
* Configure the project commands:
    * **Modify your Setup Commands**: leave blank
    * **Modify your Test Commands**: `bash codeship.sh`
* Set up Environment variables
	* SF_USERNAME_FEATURE - Username for the DE used to test feature branches
	* SF_PASSWORD_FEATURE - Password and security token concatenated
	* SF_SERVERURL_FEATURE - Server login url (usually https://login.salesforce.com)
	* SF_USERNAME_PACKAGING - Packaging org credentials
	* SF_PASSWORD_PACKAGING
	* SF_SERVERURL_PACKAGING
	* SF_USERNAME_BETA - Username for the DE org used to test beta packages
	* SF_PASSWORD_BETA
	* SF_SERVERURL_BETA
	* GITHUB_ORG_NAME
	* GITHUB_REPO_NAME
	* GITHUB_USERNAME
	* GITHUB_PASSWORD - This can be an API Token instead of your personal password
* Now, try to do a push into a feature branch and see if Codeship builds the project for you
* Next up, we want to automatically build and test a beta managed package after any commit to master (which should only be from a merged Pull Request!)
    * Get the environment variables and values to enter into your Codeship project from the []CumulusCI OAuth Tool](https://cumulusci-oauth-tool.herokuapp.com/)
    * Enter the values
    * Merge a pull request…
    * Codeship should kick off a build which will upload a beta managed package and then install the package in the beta org and run all tests against it.  It should also create a pre-release Release in your GitHub project for the beta.

