# /packages/intranet-trans-invoices/upload-prices.tcl
#
# Copyright (C) 2003-2004 Project/Open
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

ad_page_contract {
    Serve the user a form to upload a new file or URL

    @author frank.bergmann@project-open.com
} {
    return_url:notnull
    customer_id:integer
}

set user_id [ad_maybe_redirect_for_registration]
set page_title "Upload Client Prices CSV"

set context_bar [ad_context_bar [list "/intranet/customers/" "Clients"] "Upload CSV"]

set page_content "
<form enctype=multipart/form-data method=POST action=upload-prices-2.tcl>
[export_form_vars customer_id return_url]
                    <table border=0>
                      <tr> 
                        <td align=right>Filename: </td>
                        <td> 
                          <input type=file name=upload_file size=30>
[im_gif help "Use the &quot;Browse...&quot; button to locate your file, then click &quot;Open&quot;."]
                        </td>
                      </tr>
                      <tr> 
                        <td></td>
                        <td> 
                          <input type=submit value=Submit and Upload>
                        </td>
                      </tr>
                    </table>
</form>
"

db_release_unused_handles

doc_return  200 text/html [im_return_template]
