-- /packages/intranet-trans-invoices/sql/oracle/intranet-trans-invoices-drop.sql
--
-- Copyright (c) 2003-2004 Project/Open
--
-- All rights reserved. Please check
-- http://www.project-open.com/license/ for details.
--
-- @author frank.bergmann@project-open.com

BEGIN
    im_component_plugin.del_module(module_name => 'intranet-trans-invoices');
    im_menu.del_module(module_name => 'intranet-trans-invoices');
END;
/

drop function im_trans_prices_calc_relevancy;
drop function im_trans_prices_calc_price;
drop function im_trans_prices_calc_currency;

drop sequence im_trans_prices_seq;
drop table im_trans_prices;




