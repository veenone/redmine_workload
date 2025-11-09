# Manual Task Effort Distribution Guide

## Overview

This feature allows users with the **"Manage task effort distribution"** permission (typically project managers) to manually override the automatic equal distribution of task effort across working days.

## Use Case Example

**Scenario:** An engineer has a task with:
- **Effort:** 2 man-days (16 hours)
- **Duration:** 2 weeks
- **Assigned to:** Engineer1

**Default Behavior (Automatic):**
The system automatically distributes 16 hours equally across 10 working days = 1.6 hours per day.

**With Manual Allocation:**
A project manager can now customize the distribution, for example:
- Week 1: Heavy work (4h/day Mon-Fri = 20h)
- Week 2: Light work (0.5h/day Mon-Wed = 1.5h)
- Total: 21.5 hours (showing over-allocation warning)

## Setup

### 1. Grant Permission

Go to **Administration → Roles and permissions** and enable the **"Manage task effort distribution"** permission for:
- Project Manager role
- Or any other role that should be able to manage allocations

### 2. Access the Feature

**From an Issue Page:**
1. Open any issue that has an assigned user
2. Look for the **"Manage Effort"** link in the issue details sidebar
3. Click to access the allocation management page

**Direct URL:**
`/wl_issue_allocations?issue_id=<issue_id>`

## Using Manual Allocations

### Allocation Interface

The interface shows:
- **Issue Information:** Subject, assigned user, dates, estimated hours, progress
- **Calendar Table:** Shows all days in the date range with input fields
- **Status Indicators:**
  - 🟢 **Manual** - Day has manual allocation set
  - 🔵 **Auto** - Day uses automatic distribution (when no manual allocation exists)
  - ⚪ **Weekend** - Non-working day
  - 🔴 **Outside Issue Range** - Date is before start or after due date

### Setting Manual Allocations

1. **Enter hours** in the input fields for each day
   - Use decimal values (e.g., 2.5 for 2.5 hours)
   - Leave blank or set to 0 to remove allocation
   - Disabled fields are outside the issue date range

2. **View Allocation Summary:**
   - **Total Allocated:** Sum of all manual allocations
   - **Remaining Estimate:** (Estimated hours × (100 - Done%)) / 100
   - **Difference:** Shows if over/under-allocated
   - Status badges indicate balance status

3. **Click Save** to apply changes

### Helper Actions

#### Auto-Distribute Button
Automatically distributes remaining estimated hours equally across all working days:
- Calculates remaining hours based on progress
- Identifies working days (excluding weekends/holidays)
- Divides hours equally
- Creates allocations for each day

**Example:**
- Remaining: 10 hours
- Working days: 5
- Result: 2 hours per day

#### Reset to Auto Button
Removes all manual allocations and returns to automatic distribution:
- Deletes all manual allocations for the issue
- System reverts to default equal distribution
- Use when you no longer need custom distribution

### Date Range Selection

Use the date range selector at the bottom to:
- View different time periods
- Extend the range for long-running tasks
- Focus on specific weeks

## How It Affects Workload Calculation

### Automatic Distribution (Default)
```
Issue: 10h remaining, Start: Jan 1, Due: Jan 5 (5 working days)
Result: 2h per day (Jan 1-5)
```

### With Manual Allocation
```
Issue: Same as above
Manual Allocation:
  Jan 1: 4h
  Jan 2: 3h
  Jan 3: 2h
  Jan 4: 1h
  Jan 5: 0h

Result: Uses manual hours (4h, 3h, 2h, 1h, 0h)
Total: 10h (balanced)
```

### Integration with Workload View

- Manual allocations are automatically used in the main **Workload** view
- Hours per day reflect your custom distribution
- Workload thresholds (low/normal/high) apply to manual allocations
- Team members see their updated daily workload

## Best Practices

### When to Use Manual Allocation

✅ **Use when:**
- Task requires variable effort across days
- Front-loaded or back-loaded work
- Specific days have capacity constraints
- Complex dependencies require custom scheduling
- Part-time allocation needed

❌ **Don't use when:**
- Equal distribution works fine
- Task is simple and uniform
- Managing dozens of small tasks (overhead not worth it)

### Tips

1. **Start with Auto-Distribute**
   - Click "Auto-Distribute" to get a baseline
   - Adjust specific days as needed

2. **Monitor the Balance**
   - Keep total allocated close to remaining estimate
   - Over-allocation warnings indicate scheduling issues
   - Under-allocation means work isn't fully planned

3. **Update as Work Progresses**
   - Update issue progress (% Done)
   - Remaining estimate recalculates automatically
   - Adjust future allocations based on new remaining hours

4. **Coordinate with Team**
   - Inform assigned users of custom distribution
   - Custom allocation may differ from their expectations
   - Use description field to document reasoning

## Permissions

### Who Can Manage Allocations

Users who have **ANY** of these:
1. **Global permission:** `manage_issue_allocations`
2. **Project permission:** `manage_issue_allocations` for the issue's project
3. **Admin role:** Always has access

### Who Can View Allocations

- Allocations affect the **Workload** view for all users
- Assigned users see their daily workload totals
- They don't directly see the allocation interface unless they have permission

## Technical Details

### Database

Manual allocations are stored in the `wl_issue_allocations` table:
- One record per issue + date combination
- Includes hours, issue_id, allocation_date, created_by
- Cleared when hours set to 0

### Caching

- System clears Rails cache when allocations change
- Workload calculations update immediately
- No manual cache clearing needed

### Validation Rules

- Hours must be >= 0
- Allocation date must be within issue start/due date range
- One allocation per issue per date (enforced by unique index)
- Issue, date, hours, and creator are required fields

## Troubleshooting

### "Outside Issue Range" Warning
- Dates before start_date or after due_date are disabled
- Update issue dates to expand the range

### "Issue must have start date, due date, and estimated hours"
- Auto-distribute requires all three fields
- Set these on the issue before using auto-distribute

### Allocations Not Showing in Workload
- Clear browser cache
- Verify issue is assigned to a user
- Check date range in workload view includes allocation dates
- Ensure issue has start and due dates

### Permission Denied
- Contact administrator to grant `manage_issue_allocations` permission
- Permission can be global or per-project

## Example Workflow

### Scenario: Sprint Planning

1. **Create Issue**
   - Subject: "Implement user authentication"
   - Assigned: John Doe
   - Estimated: 20 hours
   - Start: Jan 8
   - Due: Jan 19 (2 weeks)

2. **Project Manager Reviews Capacity**
   - Checks John's workload calendar
   - Sees he's overloaded early in sprint
   - Decides to back-load this task

3. **Set Custom Allocation**
   - Navigate to issue → "Manage Effort"
   - Click "Auto-Distribute" (gets 2h/day baseline)
   - Adjust manually:
     - Week 1: 1h/day (5 hours total)
     - Week 2: 3h/day (15 hours total)
   - Save changes

4. **Result**
   - John's workload view shows lighter load Week 1
   - Heavier allocation Week 2
   - Total still matches 20h estimate
   - Team has realistic schedule

## API Integration (Future)

Currently, allocations are managed via web interface only. API support may be added in future versions.

## Support

For issues or questions:
- Check Redmine logs: `log/production.log`
- File bug reports on the plugin's GitHub repository
- Contact your Redmine administrator
