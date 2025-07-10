# Changelog for Redmine Workload

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 3.1.0 - 2025-07-10

### Added

* **UI Modernization**: Applied easy_gantt design patterns to workload tables for consistent UI experience
* **Horizontal Scrolling**: Added horizontal scroll functionality with sticky first column for better navigation of wide workload tables
* **Theme Color Integration**: Workload tables now inherit Redmine theme colors for consistent appearance across different themes
* **User Preference System**: Added configuration to display all users by default instead of only own workload
  - Global admin setting for default behavior
  - Individual user preference override via Display Options in filters
  - Permission-based access control
* **Menu Scope Configuration**: Added option to display workload menu in either global (top menu) or project scope
  - Configurable via Administration → Plugins → Redmine Workload Plugin
  - Project-scoped access with proper permission handling
* **Modern Collapsible Icons**: Updated fieldset toggle icons to modern chevron-style icons with smooth transitions

### Enhanced

* **Controller Authorization**: Improved authorization logic to handle both global and project contexts
* **Project Context Support**: Added full project-scoped workload functionality with proper routing and permissions
* **User Selection Logic**: Enhanced WlUserSelection model to support project context and user preferences
* **CSS Styling**: Added modern hover effects and transitions for better user experience

### Fixed

* **Database Configuration**: Fixed compatibility issues with different Rails versions for database configuration access
* **Missing Constants**: Resolved Zeitwerk naming errors for proper class loading
* **Syntax Errors**: Fixed controller syntax issues for proper error handling
* **Permission Handling**: Improved permission checking for both global and project-scoped access

### Technical Improvements

* Added database migrations for new settings and preferences
* Enhanced JavaScript functionality for collapsible fieldsets
* Improved error handling and validation
* Added comprehensive localization support for new features
* Updated routing to support both global and project-scoped access

## 3.0.2 - 2023-07-24

### Deletes

* second border-right css for .controller-workloads .data .holiday.today

## 3.0.1 - 2023-07-19

### Fixed

* CSS styling for today line when user has holiday today

## 3.0.0 - 2023-07-18

### Added

* api support for csv export of workloads

### Fixed

* general workday setting what leads to a breaking change for postgres user
since they need to use ruby > 3.1.z

## 2.2.2 - 2023-05-05

### Added

* github actions for automated tests
* github pull request template

### Fixed

* zeitwerk issues
* postgres default keyword error
* test errors

## 2.2.1 - 2023-02-17

### Fixed

* nil error in data.keys.sort for very large time spans

## 2.2.0 - 2023-01-19

### Changed

* how to decide when an issue is overdue by comparing with a given date

## 2.1.0 - 2022-12-09

### Added

* Plugin setting 'workload_of_parent_issues' as option to include parent issues 
  in the workload calculation

## 2.0.2 - 2022-11-14

### Added

* support for Redmine 5 with backward compatability to Redmine 4
* translations for some permissions

### Fixed

* nil error in WorkloadsHelper#load_class_for_hour 
* nil error when user enters conflicting dates

## 2.0.1 - 2022-06-21

### Fixed

* undefined method 'id' in GroupWorkload#total_availabilities_of

## 2.0.0 - 2022-06-07

### Added

* week numbers to workload table header
* group issues to workload table if a group is selected
* calculation of group workload based on user main group setting
* presentation of summarized group workload in workload table
* additional infos about unscheduled issues
* permissions :view_all_workloads, :view_own_group_workloads, :view_own_workloads
* csv export of users or groups

### Changed

* using of dynamic action segments in routes due to deprecation warning
* styling of workload table to look similar as gantt diagram
* user and group selection to be in a separate class to make it reusable
* permissions to be global again, i.e., not dependend of project module enabled
* display of current user to show only if visited workload index page or when
selected explicitly
* error messages to translate field names

### Fixed

* broken unit test
* missing closing selectors in some views causing the site footer to be displayed
not at the bottom of the page

---

**NOTE** Changes prior and equal to version 1.1.0 are not reported.