Salesforce Slack Integration
=======================
Provides a way to integrate Salesforce with Slack. Example usage includes posting a message to a Slack channel when a post is submitted to a chatter group. This integration can post as the current user which leverages OAuth on a per-user basis or as a Slack Bot that you can configure in a custom Slack application.

Installation
------------
You can easily install these components to your Salesforce org straight from github or as an unmanaged package.

* [Deploy from Github](https://githubsfdeploy.herokuapp.com)

Setup
--------
Initial setup includes the following steps with details further below

 - Configure a new Slack application
 - Setup *Auth. Provider* in Salesforce org
 - Setup *Named Credentials* in Salesforce org
 - Authorize Salesforce to Slack integration

*Configure Slack Application*

*Setup Auth. Provider in Salesforce*

*Setup Named Credentials in Salesforce*

*Authorize Salesforce to Slack Integration*

Supported Slack API Calls
------------
Slack API - https://api.slack.com/methods

*Currently Supported Methods*

**chat.postMessage**

Example Usage
------------
So how can I utilize the Slack API from within Salesforce? Well... for starters we can configure a new Process Builder flow to automatically post a message to a Slack channel every time a post is made to a certain Chatter group.
