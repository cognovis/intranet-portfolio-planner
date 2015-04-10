-- /packages/intranet-portfolio-planner/sql/postgresql/intranet-portfolio-planner-workflow-create.sql
--
-- Copyright (c) 2010 ]project-open[
--
-- All rights reserved. Please check
-- http://www.project-open.com/license/ for details.
--
-- @author frank.bergmann@project-open.com

-- A workflow to notify project managers that a supervisor
-- or supervisor panel has change moved the project back
-- or forth in time during Project Porfolio Planning.
-- The WF takes the modified (main) project as object.
-- The PMs now need to update the project documentation,
-- including the project plan when maintained outside of
-- ]po[ (in Microsoft Project).
-- So all PMs (project administrators...) are assigned to
-- the main "update" transition. One PA may grab the task,
-- update the project documentation and confirm the work.
-- As an alternative, the PA may reject the change. In 
-- this case the workflow proceeds to the "reject"
-- transition, notifying the project director (or whoever
-- changed the project) about the rejection.
--
-- So "update" is assigned to all project admins using
-- a unassigned callback generically in the WF, but the
-- "reject" is manually assigned to the initiator of the
-- change.


-- Make sure workflow localization of workflow messages works
select workflow_case__notify_l10n_lookup ('prefix', 'unknown', 'portfolio_planner_change', 'update', 'en_US', 0);



-- Cases table
-- This table lists notifications to project managers who 
-- need to acknowledge that their project has been moved
-- and that they have updated all project information.
create table portfolio_planner_change_cases (
	case_id		integer
			constraint portfolio_planner_change_cases_pk
			primary key
			constraint portfolio_planner_change_cases_case_fk
			references wf_cases on delete cascade
);

-- Declare the object type
SELECT workflow__create_workflow (
	'portfolio_planner_change_wf',
	'Portfolio Planner Change',
	'Portfolio Planner Change',
	'Notify PMs if their projects were moved by the Portfolio Planner',
	'portfolio_planner_change_cases',
	'case_id'
);

-- Places
SELECT workflow__add_place('portfolio_planner_change_wf','start','Ready to Modify', null);
SELECT workflow__add_place('portfolio_planner_change_wf','before_update','Ready to Update',null);
SELECT workflow__add_place('portfolio_planner_change_wf','before_updated','Ready to Updated',null);
SELECT workflow__add_place('portfolio_planner_change_wf','before_reject','Ready to Reject',null);
SELECT workflow__add_place('portfolio_planner_change_wf','before_rejected','Ready to Rejected',null);
SELECT workflow__add_place('portfolio_planner_change_wf','end','Process finished',	null);

-- Roles
SELECT workflow__add_role ('portfolio_planner_change_wf','modify','Modify',1);
SELECT workflow__add_role ('portfolio_planner_change_wf','update','Update',2);
SELECT workflow__add_role ('portfolio_planner_change_wf','updated','Updated',3);
SELECT workflow__add_role ('portfolio_planner_change_wf','reject','Reject',4);
SELECT workflow__add_role ('portfolio_planner_change_wf','rejected','Rejected',5);

-- Transitions
SELECT workflow__add_transition ('portfolio_planner_change_wf','modify','Modify','modify',1,'user');
SELECT workflow__add_transition ('portfolio_planner_change_wf','update','Update','update',2,'user');
SELECT workflow__add_transition ('portfolio_planner_change_wf','updated','Updated','updated',3,'automatic');
SELECT workflow__add_transition ('portfolio_planner_change_wf','reject','Reject','reject',4,'user');
SELECT workflow__add_transition ('portfolio_planner_change_wf','rejected','Rejected','rejected',5,'automatic');

-- Arcs
SELECT workflow__add_arc ('portfolio_planner_change_wf','modify','start','in','','','');
SELECT workflow__add_arc ('portfolio_planner_change_wf','modify','before_update','out','','','');
SELECT workflow__add_arc ('portfolio_planner_change_wf','reject','before_update','out','wf_callback__guard_attribute_true','retry_update_p','Retry');
SELECT workflow__add_arc ('portfolio_planner_change_wf','reject','before_reject','in','','','');
SELECT workflow__add_arc ('portfolio_planner_change_wf','reject','before_rejected','out','#','','Rejected');
SELECT workflow__add_arc ('portfolio_planner_change_wf','rejected','end','out','','','');
SELECT workflow__add_arc ('portfolio_planner_change_wf','rejected','before_rejected','in','','','');
SELECT workflow__add_arc ('portfolio_planner_change_wf','updated','before_updated','in','','','');
SELECT workflow__add_arc ('portfolio_planner_change_wf','updated','end','out','','','');
SELECT workflow__add_arc ('portfolio_planner_change_wf','update','before_reject','out','#','','Not Updated');
SELECT workflow__add_arc ('portfolio_planner_change_wf','update','before_updated','out','wf_callback__guard_attribute_true','update_finished_p','Updated');
SELECT workflow__add_arc ('portfolio_planner_change_wf','update','before_update','in','','','');

-- Attributes
SELECT workflow__create_attribute('portfolio_planner_change_wf','update_finished_p','boolean','Update Finished?',null,null,null,'t',1,1,null,'generic');
SELECT workflow__add_trans_attribute_map('portfolio_planner_change_wf','update','update_finished_p',1);

SELECT workflow__create_attribute('portfolio_planner_change_wf','retry_update_p','boolean','Retry Update?',null,null,null,'',1,1,null,'generic');
SELECT workflow__add_trans_attribute_map('portfolio_planner_change_wf','reject','retry_update_p',1);


-- Context/Transition info
insert into wf_context_transition_info (context_key,workflow_key,transition_key,estimated_minutes,instructions,enable_callback,enable_custom_arg,fire_callback,fire_custom_arg,time_callback,time_custom_arg,deadline_callback,deadline_custom_arg,deadline_attribute_name,hold_timeout_callback,hold_timeout_custom_arg,notification_callback,notification_custom_arg,unassigned_callback,unassigned_custom_arg)
values ('default','portfolio_planner_change_wf','modify',1,'','','','','','','','','','','','','','','','');

insert into wf_context_transition_info (context_key,workflow_key,transition_key,estimated_minutes,instructions,enable_callback,enable_custom_arg,fire_callback,fire_custom_arg,time_callback,time_custom_arg,deadline_callback,deadline_custom_arg,deadline_attribute_name,hold_timeout_callback,hold_timeout_custom_arg,notification_callback,notification_custom_arg,unassigned_callback,unassigned_custom_arg)
values ('default','portfolio_planner_change_wf','update',30,'','','','','','','','','','','','','','','im_workflow__assign_to_project_admins','');

insert into wf_context_transition_info (context_key,workflow_key,transition_key,estimated_minutes,instructions,enable_callback,enable_custom_arg,fire_callback,fire_custom_arg,time_callback,time_custom_arg,deadline_callback,deadline_custom_arg,deadline_attribute_name,hold_timeout_callback,hold_timeout_custom_arg,notification_callback,notification_custom_arg,unassigned_callback,unassigned_custom_arg)
values ('default','portfolio_planner_change_wf','updated',1,'','','','','','','','','','','','','','','','');

insert into wf_context_transition_info (context_key,workflow_key,transition_key,estimated_minutes,instructions,enable_callback,enable_custom_arg,fire_callback,fire_custom_arg,time_callback,time_custom_arg,deadline_callback,deadline_custom_arg,deadline_attribute_name,hold_timeout_callback,hold_timeout_custom_arg,notification_callback,notification_custom_arg,unassigned_callback,unassigned_custom_arg)
values ('default','portfolio_planner_change_wf','reject',30,'','','','','','','','','','','','','','','','');

insert into wf_context_transition_info (context_key,workflow_key,transition_key,estimated_minutes,instructions,enable_callback,enable_custom_arg,fire_callback,fire_custom_arg,time_callback,time_custom_arg,deadline_callback,deadline_custom_arg,deadline_attribute_name,hold_timeout_callback,hold_timeout_custom_arg,notification_callback,notification_custom_arg,unassigned_callback,unassigned_custom_arg)
values ('default','portfolio_planner_change_wf','rejected',1,'','','','','','','','','','','','','','','','');
