<master>
<property name="title">@page_title@</property>
<property name="context">@context_bar@</property>
<property name="main_navbar_label">finance</property>
<property name="sub_navbar">@cost_navbar;noquote@</property>
<property name="left_navbar">@left_navbar_html;noquote@</property>

<form method=POST action='new-2'>
<%= [export_vars -form {target_cost_type_id}] %>
  <table width="100%" cellpadding=2 cellspacing=2 border=0>
    @table_header_html;noquote@
    @table_body_html;noquote@
    @table_continuation_html;noquote@
    @submit_button;noquote@
  </table>
</form>
