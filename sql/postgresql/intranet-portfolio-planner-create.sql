-- /packages/intranet-portfolio-planner/sql/postgresql/intranet-portfolio-planner-create.sql
--
-- Copyright (c) 2010 ]project-open[
--
-- All rights reserved. Please check
-- http://www.project-open.com/license/ for details.
--
-- @author frank.bergmann@project-open.com

SELECT im_menu__new (
	null,						-- p_menu_id
	'im_menu',					-- object_type
	now(),						-- creation_date
	null,						-- creation_user
	null,						-- creation_ip
	null,						-- context_id
	'intranet-portfolio-planner',			-- package_name
	'portfolio_planner',				-- label
	'Portfolio Planner',				-- name
	'/intranet-portfolio-planner/',			-- url
	0,						-- sort_order
	(select menu_id from im_menus where label = 'projects'),
	null						-- p_visible_tcl
);

\i intranet-portfolio-planner-workflow-create.sql
