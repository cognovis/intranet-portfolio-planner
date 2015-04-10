-- /packages/intranet-portfolio-planner/sql/postgresql/intranet-portfolio-planner-drop.sql
--
-- Copyright (c) 2010 ]project-open[
--
-- All rights reserved. Please check
-- http://www.project-open.com/license/ for details.
--
-- @author frank.bergmann@project-open.com


select im_component_plugin__del_module('intranet-portfolio-planner');
select im_menu__del_module('intranet-portfolio-planner');


-- Disabled - This is part of intranet-workflow
--
-- Delete notifications
-- delete from notification_types where short_name = 'wf_assignment_notif';
-- delete from acs_sc_impls where impl_name = 'wf_assignment_notif_type';
-- delete from acs_sc_impl_aliases where impl_name = 'wf_assignment_notif_type';
-- delete from notification_types where short_name = 'wf_portfolio_planner_change_wf_assignment_notif';
-- delete from acs_sc_impls where impl_name = 'wf_portfolio_planner_change_wf_assignment_notif_type';
-- delete from acs_sc_impl_aliases where impl_name = 'wf_portfolio_planner_change_wf_assignment_notif_type';
-- delete from acs_objects 
-- where object_type = 'notification_type' and object_id not in (select type_id from notification_types);

