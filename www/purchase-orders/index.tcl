# /packages/intranet-trans-invoices/www/purchase-orders/index.tcl
#
# Copyright (C) 2003-2004 Project/Open
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

ad_page_contract {
    Show assigned translation tasks by user and allow to
    create purchase orders.

    @author frank.bergmann@project-open.com
} {
    { project_id:integer 0 }
    { target_cost_type_id:integer "[im_cost_type_po]" }
    { target_cost_status_id:integer "[im_cost_status_created]" }
    { return_url "" }
}


# -------------------------------------------------------------------------
# Security & Default
# -------------------------------------------------------------------------

set user_id [ad_maybe_redirect_for_registration]
set page_title "[_ intranet-trans-invoices.lt_Generate_Purchase_Ord]"
set context_bar [im_context_bar [list /intranet/projects/ "[_ intranet-trans-invoices.Projects]"] [list "/intranet/projects/view?project_id=$project_id" "[_ intranet-trans-invoices.One_project]"] $page_title]

set current_url [im_url_with_query]
if {"" == $return_url} { set return_url $current_url }

set bgcolor(0) " class=roweven"
set bgcolor(1) " class=rowodd"

if {![im_permission $user_id add_costs]} {
    ad_return_complaint 1 "<li>You don't have sufficient privileges to view this page"
    return
}


# No Project defined? Then we need to redirect to a
# page to select a project.
#
if {0 == $project_id } {
    # This page selects the project_id and appends it to the return_url
    # before returning to _this_ page again.
    ad_returnredirect project-select?[export_url_vars return_url]
}

# ---------------------------------------------------------------------
# Select and format the list of tasks
# ---------------------------------------------------------------------


set task_sql "
select
	pe.person_id as freelance_id,
	im_name_from_user_id (pe.person_id) as freelance_name,
	im_category_from_id(m.object_role_id) as role,
	im_category_from_id(tt.source_language_id) as source_language,
	im_category_from_id(tt.target_language_id) as target_language,
	im_category_from_id(tt.task_uom_id) as task_uom,
	im_category_from_id(tt.task_status_id) as task_status,
	tt.*
from
	acs_rels r,
	im_biz_object_members m,
	(
		select
			tt.trans_id as freelance_id,
			'trans' as action,
			[im_project_type_trans] as po_task_type_id,
			im_category_from_id([im_project_type_trans]) as po_task_type,
			tt.*
		  from	im_trans_tasks tt
		  where	tt.project_id = :project_id
			and tt.trans_id is not null
	  UNION
		select
			tt.edit_id as freelance_id,
			'edit' as action,
			[im_project_type_edit] as po_task_type_id,
			im_category_from_id([im_project_type_edit]) as po_task_type,
			tt.*
		  from	im_trans_tasks tt
		  where	tt.project_id = :project_id
			and tt.edit_id is not null
	  UNION
		select
			tt.proof_id as freelance_id,
			'proof' as action,
			[im_project_type_proof] as po_task_type_id,
			im_category_from_id([im_project_type_proof]) as po_task_type,
			tt.*
		  from	im_trans_tasks tt
		  where	tt.project_id = :project_id
			and tt.proof_id is not null
	  UNION
		select
			tt.other_id as freelance_id,
			'other' as action,
			[im_project_type_other] as po_task_type_id,
			im_category_from_id([im_project_type_other]) as po_task_type,
			tt.*
		  from	im_trans_tasks tt
		  where	tt.project_id = :project_id
			and tt.other_id is not null
	) tt,
	persons pe,
	group_distinct_member_map fmem
where
	r.object_id_one = :project_id
	and r.rel_id = m.rel_id
	and r.object_id_two = pe.person_id
	and fmem.group_id = [im_freelance_group_id]
	and pe.person_id = fmem.member_id
	and pe.person_id = tt.freelance_id
order by
	tt.freelance_id
"

set task_colspan 8
set task_html ""

set ctr 1
set task_list [array names tasks_id]
set old_freelance_id 0
db_foreach task_tasks $task_sql {
    
    # introduce spaces after "/" (by "/ ") to allow for graceful rendering
    regsub {/} $task_name "/ " task_name
    ns_log Notice "/purchase-orders/index: task_name=$task_name"

    # Calculate the provider_select_widget 
    # that allows to choose the provider company
    # related to the freelancer
    set provider_sql "
	select	c.*
	from	acs_rels r,
		im_companies c
	where	r.object_id_one = c.company_id
		and r.object_id_two = :freelance_id"

    set freelance_company_html ""
    set freelance_ctr 0
    db_foreach freelance_providers $provider_sql {
	set checked ""
	if {$freelance_ctr == 0} { set checked "checked" }
	append freelance_company_html "
	<tr>
	  <td>
	    <input type=radio name=provider_id value=$company_id $checked>
	  </td>
	  <td>
	    <A href=/intranet/companies/view?company_id=$company_id>
		$company_name
	    </A>
	  </td>
	</tr>\n"
	incr freelance_ctr
    }
    if {"" == $freelance_company_html} {
	set user_id $freelance_id
	set freelance_company_html "
	<i>[_ intranet-trans-invoices.No_company_found]</i><br>
	<a href=/intranet/companies/new-company-from-user?[export_url_vars user_id]>
	  [_ intranet-trans-invoices.lt_Create_a_new_company_]
	</a>"
    }
    set freelance_company_html "
	<table border=0 cellspacing=0 cellpadding=0>
	$freelance_company_html
	</table>\n"

    if {$freelance_id != $old_freelance_id} {

	if {$ctr > 1} {
	    append task_html "
		<tr class=rowplain>
		  <td colspan=$task_colspan align=right>
		    <input type=submit value=Submit>  
		  </td>
		</tr>
              </table>
              </form>\n"
	}

	append task_html "
	<form method=POST action=new-2>
	[export_form_vars freelance_id target_cost_type_id target_cost_status_id return_url]
	<table border=0>
	  <tr>
	    <td class=rowtitle align=center>[_ intranet-trans-invoices.Task_Name]</td>
	    <td class=rowtitle align=center>[_ intranet-trans-invoices.Source]</td>
	    <td class=rowtitle align=center>[_ intranet-trans-invoices.Target]</td>
	    <td class=rowtitle align=center>[_ intranet-trans-invoices.Status]</td>
	    <td class=rowtitle align=center>[_ intranet-trans-invoices.Type]</td>
	    <td class=rowtitle align=center>[_ intranet-trans-invoices.Units]</td>
	    <td class=rowtitle align=center>[_ intranet-trans-invoices.UoM]</td>
	    <td class=rowtitle align=center>[_ intranet-trans-invoices.Sel]</td>
	  </tr>
	  <tr class=rowtitle>
	    <td>
              <A href=/intranet/users/view?user_id=$freelance_id>$freelance_name</a>
	    </td>
            <td colspan=[expr $task_colspan-1] align=left>
	      $freelance_company_html
            </td>
          </tr>
         "

	set old_freelance_id $freelance_id
    }
    append task_html "
	<tr $bgcolor([expr $ctr % 2])>
	  <td>$task_name</td>
	  <td>$source_language</td>
	  <td>$target_language</td>
	  <td>
	    $task_status
          </td>
	  <td>
	    $po_task_type
          </td>
	  <td>$task_units</td>
	  <td>$task_uom</td>
	  <td><input type=checkbox name=\"$action.$task_id\" value=1 checked></td>
        </tr>\n"
    incr ctr    
}

if {$ctr > 1} {

    append task_html "
	<tr>
	  <td colspan=$task_colspan align=right>
	    <input type=submit value=\"[_ intranet-trans-invoices.Submit]\">  
	  </td>
	</tr>\n"

} else {

    # Generate a reasonable message that there are no trans tasks
    append task_html "
	<tr>
	  <td colspan=$task_colspan align=center>
            &nbsp;<br>
	    [_ intranet-trans-invoices.No_Trans_Tasks]
            <br>&nbsp;
	  </td>
	</tr>\n"


}

append task_html "
	</table>
	</form>
"

# -------------------------------------------------------------------
# Project Subnavbar
# -------------------------------------------------------------------

set bind_vars [ns_set create]
ns_set put $bind_vars project_id $project_id
set parent_menu_id [db_string parent_menu "select menu_id from im_menus where label='project'" -default 0]
set project_menu [im_sub_navbar $parent_menu_id $bind_vars]

