# /packages/intranet-trans-invoices/tcl/intranet-trans-invoices-converter-procs.tcl

ad_library {
    Converter for translation invoice counting.

    @author frank.bergmann@project-open.com
    @creation-date  27 September 2017
}


# ------------------------------------------------------
# 
# ------------------------------------------------------

ad_proc im_trans_invoices_converter_options { 
    
} {
    Returns a list of available/applicable converters
    for translation tasks
} {
    return [list \
		none [_ intranet-core.None] \
		to_hour [lang::message::lookup "" intranet-trans-invoices.Convert_everything_to_hours "Convert everything to hours"] \
    ]
}

ad_proc im_trans_invoices_converter_none { 
    -project_id:required
    -task_id:required
    -uom_id:required
    -units:required
} {
    Converts uom/units into target uom/units.
    This "none" converter just returns the original values
} {
    return [list $uom_id $units]
}

ad_proc im_trans_invoices_converter_to_hour { 
    -project_id:required
    -task_id:required
    -uom_id:required
    -units:required
} {
    Converts uom/units into target uom/units.
    This "to_hour" converter tries to convert everything to hours.
    Division factor:
	320 | Hour		1.0
	321 | Day		0.125
	322 | Unit		-
	323 | Page		1.0
	324 | S-Word		187
	325 | T-Word		-
	326 | S-Line		25
	327 | T-Line		-
	328 | Week		0.025
	329 | Month		0.00416666666666
} {
    switch $uom_id {
	320 { return [list 320 [expr $units / 1.0]] }
	321 { return [list 320 [expr $units / 0.125]] }
	323 { return [list 320 [expr $units / 1.0]] }
	324 { return [list 320 [expr $units / 187]] }
	326 { return [list 320 [expr $units / 25]] }
	328 { return [list 320 [expr $units / 0.025]] }
	329 { return [list 320 [expr $units / 0.00416666666666]] }
	default {
	    return [list $uom $units]
	}
    }
}
