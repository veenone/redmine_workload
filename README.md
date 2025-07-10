# Workload Plugin for Redmine

![Redmine Workload Version](https://img.shields.io/badge/Redmine_Plugin-v3.1.0-red) ![Redmine Version](https://img.shields.io/badge/Redmine-v5.0.z_|_v6.0.z-blue) ![Language Support](https://img.shields.io/badge/Languages-en,_de,_fr,_es,_it-green) ![Version Stage](https://img.shields.io/badge/Stage-release-important) ![ci](https://github.com/xmera-circle/redmine_workload/actions/workflows/5-0-stable.yml/badge.svg)

A complete rewrite of the original workload-plugin from Rafael Calleja.
The plugin calculates how much work each user would have to do per day in order to hit the deadlines for all his issues.

It also calculates this information for a [group](https://www.redmine.org/projects/redmine/wiki/RedmineGroups).
It calculates issues (number and hours) that are behind schedule and calculates issues that are unplanned (number and hours) so far.

To be able to do all this calculations, the issues start date, due date and estimated time must be filled in.
Issues that have not filled in one of these fields will be shown in the overview, but the workload resulting from these issues will be ignored.

![Group Workload](screenshots/group-workload-example.png?raw=true "Group Workload Example")

## New Features in Version 3.1.0

### UI Modernization and Enhanced User Experience

* **Modern Table Design**: Applied easy_gantt design patterns for consistent UI experience across Redmine plugins
* **Horizontal Scrolling**: Navigate wide workload tables with smooth horizontal scrolling and sticky first column
* **Theme Integration**: Automatic inheritance of Redmine theme colors for consistent appearance
* **Modern Icons**: Updated collapsible fieldset icons with smooth transitions and hover effects

### Enhanced Configuration and Flexibility

* **User Preference System**: Configure default user view behavior
  - Global admin setting to show all users by default
  - Individual user preference override via "Display Options" in filters
  - Permission-based access control

* **Menu Scope Configuration**: Choose where the workload menu appears
  - **Global Menu**: Traditional top navigation placement
  - **Project Menu**: Project-specific workload access with proper permissions
  - Configurable via Administration → Plugins → Redmine Workload Plugin

### Project-Scoped Workload Management

* **Project Context Support**: Full workload functionality within project scope
* **Enhanced Permissions**: New `view_project_workloads` permission for project-specific access
* **Improved Authorization**: Proper handling of both global and project-scoped permissions

### Technical Improvements

* **Enhanced Controller Logic**: Better error handling and project context support
* **Improved User Selection**: Smart user filtering based on context and permissions
* **Database Compatibility**: Fixed compatibility issues with different Rails versions
* **Modern JavaScript**: Updated collapsible functionality with better user feedback

## New Features in Version 3.0.0

:warning: **[Possible Breaking Change for PostgreSQL user](#workday-settings)**

### API support for workload CSV export

When you have your API enabled in `Administration » Settings » API » Rest web service` then you can download your CSV export via CronJob for example. 

With `curl` you would get your data with:

```shell
curl -X GET -H "X-Redmine-API-Key: <your-api-token>" https://<domain.tld>/workloads.csv?encoding=<encoding> > workloads.csv
```

The encoding options are the same as on the page itself and might depend on your language choice.

### workday settings

Workday settings are fixed now (see [#27](https://github.com/xmera-circle/redmine_workload/issues/27)) but lead to restrictions for PostgreSQL user.

 :warning: **With PostgreSQL installed you need to run Ruby 3.1.z!**

## New Features in Version 2.2.0

### how to decide if an issue is overdue

Redefines the overdue state of an issue. Instead of comparing issue.due_date with the User.current.today (as in Issue#overdue?) it will compare by the
date given by the user.

This change allows a workload analysis independent of the current date leading to more meaningful scenarios.

## New Features in Version 2.1.0

### consider workload of parent issues

By default parent issues are ignored when calculating workloads. With this setting the administrator can change the default behaviour by considering also all parent issues in the calculation.

## New Features in Version 2.0.x

Fortunately the German company [MENTOR GmbH & Co. Präzisions-Bauteile KG](https://www.mentor.de.com/) invested in this project to make these features possible:

### support of Redmine 5

Version 2.0.2 supports Redmine 5 and is backward compatible with Redmine 4.

### style-rework

The actual table has been a bit bulky and sticked out from the formatting of other areas. Especially when using themes like [Purplemine](https://github.com/mrliptontea/PurpleMine2).
Now the css has been reworked to make the style more compact and gantt-like.

### workload per group

This introduces a new level of information for issues adressed to [groups](https://www.redmine.org/projects/redmine/wiki/RedmineGroups).
It now can show informations about issues adressed to a group and calculates the workload of this group.
To avoid missleading informations therefore each user needs to define the group where he/she puts his/her effort in.

### unplanned issues

The Plugin now calculates "unplanned" issues. This applys to issues that dont have a `start date` or a `due date`.
The result now is shown close to overdue issues.

### export

The only way to have a look on the data was the workload page.
There has been no way to transfer data, e.g. to excel, to draw some charts.
Now there is a feature to export the workload per user and per role to build charts external.

## Changelog

See [CHANGELOG](/CHANGELOG.md) for a comprehensive overview of all changes.

## Installation / Uninstallation

Please refer to [redmine.org -> Plugins](https://www.redmine.org/projects/redmine/wiki/Plugins)

## How it Works

![Workload Calculation Process](screenshots/workload_calculation.png?raw=true "Workload Caclulation Process")

## Configuration

There are several places where this plugin can be configured:

### 1. Plugin Settings (Administration → Plugins → Redmine Workload Plugin)

* **Working Days**: Configure which days of the week are considered working days
* **Workload Thresholds**: Set low, normal, and high workload limits
* **Parent Tasks**: Choose whether to include parent task workload in calculations
* **Display Settings**: 
  - Default to show all users instead of only own workload
  - Choose menu location (Global Menu vs Project Menu)
* **Holidays**: Set global holidays

### 2. User Preferences (Display Options in Workload Filters)

* **View All Users by Default**: Individual users can override the global setting to view all users' workloads by default

### 3. Roles and Permissions (Administration → Roles and Permissions)

The plugin adds new permissions as described below. Configure these based on your organization's needs.

### 4. User Personal Settings (My Account → Workload)

* **Vacations**: Setup personal vacation dates
* **Custom Thresholds**: Set personal workload thresholds that override global settings
* **Main Group**: Configure the primary group for workload calculations


## Permissions

The plugin provides flexible permission system for workload access:

### Global Permissions
* **Admin users** can see the workload of everyone and configure all plugin settings
* **view own workloads**: Users can see their own workload
* **view own group workloads**: Users can see workloads of all users in their configured main group  
* **view all workloads**: Users can see workloads of all users globally

### Project-Specific Permissions (when Menu Scope is set to "Project Menu")
* **view project workloads**: Users can see workloads within specific project context

### Management Permissions
* **edit national holiday**: Manage global holidays
* **edit user vacations**: Manage personal vacation settings  
* **edit user data**: Manage personal workload thresholds and settings

### Important Notes
* When showing issues that contribute to workload, only issues visible to the current user are displayed. Invisible issues are summarized.
* Users can configure their own settings based on the permissions assigned to their role.

## Holidays, Vacation and User Workload Data

National holidays and user vacation is counted as day off (like weekend).
Admins can setup National Holidays in plugin settings.
Users can get permissions to setup their vacations and workload data with 'Roles and permissions'.
You can specify user(s), who should be able to setup national holidays with 'Roles and permissions'.

## CSV-Export

Here you can export the values that are shown in the browser to use it in other systems (e.g. draw charts).

|Column|possible values|description|
|------|---------------|-----------|
|Status|planned, available|Describes if this Line shows planned workload or available hours per day.|
|Type|aggregation, group, user|Describes if this Line shows hours for one `user`, hours that assigned to a `group` or hours that are `aggregated` for the group.|
|Main group|*group-name*|Reports the configured `main group` for a `user` and (implicit) for a `group`. Is empty in case of aggregation.|
|Number of overdue issues|*number*|Number of issues that are behind schedule.|
|Hours of overdue issues|*hours*|Aggregated hours of issues that are behind schedule.|
|Number of unplanned issues|*number*|Number of issues that are unplanned.|
|Hours of unplanned issues|*hours*|Aggregated hours of issues that are unplanned.|
|..date..|*datum* and *hours*|Column is named from the belonging datum. Lists per line the hours per day.|