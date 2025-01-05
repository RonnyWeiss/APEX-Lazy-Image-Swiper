prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_210200 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2021.10.15'
,p_release=>'21.2.5'
,p_default_workspace_id=>100000
,p_default_application_id=>103428
,p_default_id_offset=>0
,p_default_owner=>'RONNY'
);
end;
/
 
prompt APPLICATION 103428 - Ronny's Demo App
--
-- Application Export:
--   Application:     103428
--   Name:            Ronny's Demo App
--   Date and Time:   14:05 Sunday January 5, 2025
--   Exported By:     RONNY
--   Flashback:       0
--   Export Type:     Component Export
--   Manifest
--     PLUGIN: 36846774386193140128
--   Manifest End
--   Version:         21.2.5
--   Instance ID:     900134127207897
--

begin
  -- replace components
  wwv_flow_api.g_mode := 'REPLACE';
end;
/
prompt --application/shared_components/plugins/region_type/apex_lazy_image_swiper
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(36846774386193140128)
,p_plugin_type=>'REGION TYPE'
,p_name=>'APEX.LAZY.IMAGE.SWIPER'
,p_display_name=>'APEX Lazy Image Swiper'
,p_supported_ui_types=>'DESKTOP:JQM_SMARTPHONE'
,p_javascript_file_urls=>'#PLUGIN_FILES#script#MIN#.js'
,p_css_file_urls=>'#PLUGIN_FILES#style#MIN#.css'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
'procedure download_file (',
'    p_in_blob      blob,',
'    p_in_file_name varchar2,',
'    p_in_mime_type varchar2',
') as',
'    l_blob blob := p_in_blob;',
'begin',
'    htp.init;',
'    owa_util.mime_header(coalesce(p_in_mime_type, ''application/octet''), false, ''UTF-8'');',
'    htp.p(''Content-length: '' || dbms_lob.getlength(p_in_blob));',
'    htp.p(''Content-Disposition: attachment; filename="'' || p_in_file_name || ''"'');',
'    owa_util.http_header_close;',
'    wpg_docload.download_file(l_blob);',
'end;',
'',
'function sql_to_sys_refcursor (',
'    p_in_sql_statement clob,',
'    p_in_binds         sys.dbms_sql.varchar2_table',
') return sys_refcursor as',
'    l_curs       binary_integer;',
'    l_ref_cursor sys_refcursor;',
'    l_exec       binary_integer;',
'    /* TODO make size dynamic */',
'    l_binds      varchar(32767);',
'begin',
'    l_curs       := sys.dbms_sql.open_cursor;',
'    sys.dbms_sql.parse(l_curs, p_in_sql_statement, sys.dbms_sql.native);',
'    if p_in_binds.count > 0 then',
'        for i in 1..p_in_binds.count loop',
'            /* TODO find out how to prevent ltrim */',
'            l_binds := ltrim(p_in_binds(i), '':'');',
'            sys.dbms_sql.bind_variable(l_curs, l_binds, v(l_binds));',
'        end loop;',
'    end if;',
'',
'    l_exec       := sys.dbms_sql.execute(l_curs);',
'    l_ref_cursor := sys.dbms_sql.to_refcursor(l_curs);',
'    return l_ref_cursor;',
'exception',
'    when others then',
'        if sys.dbms_sql.is_open(l_curs) then',
'            sys.dbms_sql.close_cursor(l_curs);',
'        end if;',
'        raise;',
'end;',
'',
'function f_ajax (',
'    p_region in apex_plugin.t_region,',
'    p_plugin in apex_plugin.t_plugin',
') return apex_plugin.t_region_ajax_result is',
'',
'    l_result     apex_plugin.t_region_ajax_result;',
'    l_cur        sys_refcursor;',
'    l_bind_names sys.dbms_sql.varchar2_table;',
'    l_pk         varchar2(32767) := apex_application.g_x02;',
'    l_file_name  varchar2(200);',
'    l_blob       blob;',
'    l_mime_type  varchar2(200);',
'begin',
'    if',
'        apex_application.g_x01 = ''GET_IMAGE'' and p_region.attribute_02 = ''Y''',
'    then',
'        declare',
'            c_plsql constant varchar2(32767) := p_region.attribute_03;',
'            l_curs       binary_integer;',
'            l_exec       binary_integer;',
'            l_binds      varchar2(32767);',
'        begin',
'            /* undocumented function of APEX for get all bindings */',
'            l_bind_names := wwv_flow_utilities.get_binds(c_plsql);',
'',
'            /* execute binding*/',
'            l_curs := sys.dbms_sql.open_cursor;',
'            sys.dbms_sql.parse(l_curs, c_plsql, sys.dbms_sql.native);',
'',
'            for i in 1..l_bind_names.count loop',
'                /* TODO find out how to prevent ltrim */',
'                l_binds := ltrim(l_bind_names(i), '':'');',
'                case l_binds',
'                    when ''PK'' then',
'                        sys.dbms_sql.bind_variable(l_curs, l_binds, l_pk);',
'                    when ''FILE_NAME'' then',
'                        sys.dbms_sql.bind_variable(l_curs, l_binds, l_file_name, 4000);',
'                    when ''MIME_TYPE'' then',
'                        sys.dbms_sql.bind_variable(l_curs, l_binds, l_mime_type, 4000);',
'                    when ''BINARY_FILE'' then',
'                        sys.dbms_sql.bind_variable(l_curs, l_binds, l_blob);',
'                    else',
'                        /* get values for APEX items */',
'                        sys.dbms_sql.bind_variable(l_curs, l_binds, v(l_binds));',
'                end case;',
'',
'            end loop;',
'',
'            l_exec := sys.dbms_sql.execute(l_curs);',
'            sys.dbms_sql.variable_value(l_curs, ''FILE_NAME'', l_file_name);',
'            sys.dbms_sql.variable_value(l_curs, ''MIME_TYPE'', l_mime_type);',
'            sys.dbms_sql.variable_value(l_curs, ''BINARY_FILE'', l_blob);',
'',
'        exception',
'            when others then',
'                if sys.dbms_sql.is_open(l_curs) then',
'                    sys.dbms_sql.close_cursor(l_curs);',
'                end if;',
'                apex_debug.error(''APEX Image Slider - Error while executing dynamic PL/SQL Block to get Blob Source for Image Download.'');',
'                apex_debug.error(sqlerrm);',
'                apex_debug.error(dbms_utility.format_error_backtrace);',
'                raise;',
'        end;',
'',
'        if l_file_name is not null then',
'            download_file(',
'                p_in_blob => l_blob,',
'                p_in_file_name => l_file_name,',
'                p_in_mime_type => l_mime_type',
'            );',
'        end if;',
'',
'    elsif apex_application.g_x01 = ''GET_SQL_SOURCE'' then',
'        begin',
'            /* undocumented function of APEX for get all bindings */',
'            l_bind_names := wwv_flow_utilities.get_binds(p_region.source);',
'',
'            /* execute binding*/',
'            l_cur        := sql_to_sys_refcursor(rtrim(p_region.source, '';''), l_bind_names);',
'',
'            /* create json */',
'            apex_json.open_object;',
'            apex_json.write(''row'', l_cur);',
'            apex_json.close_object;',
'',
'        exception when others then',
'            if l_cur%isopen then',
'                close l_cur;',
'            end if;',
'            apex_debug.error(''APEX Image Slider - Error while executing SQL Source.'');',
'            apex_debug.error(sqlerrm);',
'            apex_debug.error(dbms_utility.format_error_backtrace);',
'        end;',
'    else',
'        apex_debug.error(''APEX Image Slider - Function Type does not exists'');',
'    end if;',
'',
'    return l_result;',
'end;',
'',
'function f_render (',
'    p_region              in apex_plugin.t_region,',
'    p_plugin              in apex_plugin.t_plugin,',
'    p_is_printer_friendly in boolean',
') return apex_plugin.t_region_render_result is',
'',
'    l_result            apex_plugin.t_region_render_result;',
'    c_img_height        constant apex_application_page_regions.attribute_04%type := p_region.attribute_04;',
'    c_img_size          constant apex_application_page_regions.attribute_05%type := p_region.attribute_05;',
'    c_bg_color          constant apex_application_page_regions.attribute_06%type := p_region.attribute_06;',
'    c_controls          constant apex_application_page_regions.attribute_07%type := p_region.attribute_07;',
'    c_first_image_item  constant apex_application_page_regions.attribute_08%type := p_region.attribute_08;',
'    c_items2submit      constant apex_application_page_regions.ajax_items_to_submit%type := apex_plugin_util.page_item_names_to_jquery(p_region.ajax_items_to_submit);',
'    c_items2submitblob  constant apex_application_page_regions.ajax_items_to_submit%type := apex_plugin_util.page_item_names_to_jquery(p_region.attribute_01);',
'begin',
'',
'    sys.htp.p(''<div id="'' || apex_escape.html_attribute(p_region.static_id) || ''-is"></div>'');',
'',
'    apex_javascript.add_onload_code(''apexImageSlider(apex, $).initialize('' ||',
'        apex_javascript.add_value(p_region.static_id, true) ||',
'        apex_javascript.add_value(apex_plugin.get_ajax_identifier, true) ||',
'        apex_javascript.add_value(p_region.no_data_found_message, true) ||',
'        apex_javascript.add_value(c_img_height, true) ||',
'        apex_javascript.add_value(c_img_size, true) ||',
'        apex_javascript.add_value(c_bg_color, true) ||',
'        apex_javascript.add_value(c_controls, true) ||',
'        apex_javascript.add_value(c_items2submit, true) ||',
'        apex_javascript.add_value(c_items2submitblob, true) ||',
'        apex_javascript.add_value(c_first_image_item, true) ||',
'        apex_javascript.add_value(p_region.escape_output, false) ||',
'    '');'');',
'',
'    return l_result;',
'end;'))
,p_api_version=>1
,p_render_function=>'f_render'
,p_ajax_function=>'f_ajax'
,p_standard_attributes=>'SOURCE_SQL:AJAX_ITEMS_TO_SUBMIT:NO_DATA_FOUND_MESSAGE:ESCAPE_OUTPUT'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_help_text=>'This plug-in is a cool image slider for Oracle APEX. It loads the images only when they are needed (Lazy Load) and can load images from a BLOB table or from a URL. The list of images is passed by SQL statement. URL and download of blob tables can be '
||'mixed. In addition, a link URL can be passed, which is called if you double click on the displayed image.'
,p_version_identifier=>'25.01.05'
,p_about_url=>'https://github.com/RonnyWeiss/APEX-Lazy-Image-Swiper'
,p_files_version=>1508
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(72903384179552902)
,p_plugin_id=>wwv_flow_api.id(36846774386193140128)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>31
,p_prompt=>'Item to Submit'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(37037137748430986586)
,p_plugin_id=>wwv_flow_api.id(36846774386193140128)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>10
,p_prompt=>'Use Image source from BLOB Column (PLEASE Check Help)'
,p_attribute_type=>'CHECKBOX'
,p_is_required=>false
,p_default_value=>'N'
,p_is_translatable=>false
,p_help_text=>'Choose ''No'' if in your SQL Source are only SRC_TYPE with ''url'' or ''Yes'' when in your SQL Source is also SRC_TYPE with ''blob''. When use SRC_TYPE = ''blob'' then SRC_VALUE is the primary key from the PL/SQL block. Please do not load BLOB Column in SQL Re'
||'gion. The BLOB will be downloaded in PL/SQL block below!'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(37037210704763989770)
,p_plugin_id=>wwv_flow_api.id(36846774386193140128)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Execute to get Image Sources'
,p_attribute_type=>'PLSQL'
,p_is_required=>true
,p_default_value=>wwv_flow_string.join(wwv_flow_t_varchar2(
'/* This PL/SQL block is called when SRC_TYPE in SQL Source is ''blob'' */',
'/* The SRC_VALUE is the Key for calling this PL/SQL Block. So this PL/SQL downloads image when required by the plug-in */',
'/* Please check help for more information */',
'/* When Plug-in is not working then check APEX Debug */',
'declare',
'    l_file_name   varchar2(255);',
'    l_mime_type   varchar2(255);',
'    l_binary_file blob;',
'    l_pk          varchar2(32767) := :PK; /* :PK is the SRC_VALUE from SQL Source, if it''s a number change L_PK to number */',
'begin',
'    select',
'        #your_file_name_col#,',
'        #your_mime_type_col#,',
'        #your_blob_col#',
'    into',
'        l_file_name,',
'        l_mime_type,',
'        l_binary_file',
'    from',
'        #your_table#',
'    where',
'        #your_primary_key_column# = l_pk;',
'',
'    :FILE_NAME   := l_file_name;',
'    :MIME_TYPE   := l_mime_type;',
'     /* Please ignore PLS-00382: expression is of wrong type',
'       because binding of :BLOB is not supported by current',
'       APEX PL/SQL Validator ',
'     */',
'    :BINARY_FILE := l_binary_file;',
'exception',
'    when others then',
'        apex_debug.error(sqlerrm);',
'        apex_debug.error(dbms_utility.format_error_stack);',
'end;'))
,p_is_translatable=>false
,p_depending_on_attribute_id=>wwv_flow_api.id(37037137748430986586)
,p_depending_on_has_to_exist=>true
,p_depending_on_condition_type=>'EQUALS'
,p_depending_on_expression=>'Y'
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<pre>',
'/* This PL/SQL block is called when SRC_TYPE in SQL Source is ''blob'' */',
'/* The SRC_VALUE is the Key for calling this PL/SQL Block. So this PL/SQL downloads image when required by the plug-in */',
'/* Please check help for more information */',
'/* When Plug-in is not working then check APEX Debug */',
'declare',
'    l_file_name   varchar2(255);',
'    l_mime_type   varchar2(255);',
'    l_binary_file blob;',
'    l_pk          varchar2(32767) := :PK; /* :PK is the SRC_VALUE from SQL Source, if it''s a number change L_PK to number */',
'begin',
'    select',
'        #your_file_name_col#,',
'        #your_mime_type_col#,',
'        #your_blob_col#',
'    into',
'        l_file_name,',
'        l_mime_type,',
'        l_binary_file',
'    from',
'        #your_table#',
'    where',
'        #your_primary_key_column# = l_pk;',
'',
'    :FILE_NAME   := l_file_name;',
'    :MIME_TYPE   := l_mime_type;',
'     /* Please ignore PLS-00382: expression is of wrong type',
'       because binding of :BLOB is not supported by current',
'       APEX PL/SQL Validator ',
'     */',
'    :BINARY_FILE := l_binary_file;',
'exception',
'    when others then',
'        apex_debug.error(sqlerrm);',
'        apex_debug.error(dbms_utility.format_error_stack);',
'end;',
'</pre>'))
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(12125819969615822144)
,p_plugin_id=>wwv_flow_api.id(36846774386193140128)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Image Height'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'480px'
,p_is_translatable=>false
,p_help_text=>'Set the height of the images e.g. 480px oder 50vh'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(12126709641008363126)
,p_plugin_id=>wwv_flow_api.id(36846774386193140128)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>5
,p_display_sequence=>50
,p_prompt=>'Image Sizing'
,p_attribute_type=>'SELECT LIST'
,p_is_required=>true
,p_default_value=>'cover'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
,p_help_text=>'Set sizing of the images'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(12126712392111364272)
,p_plugin_attribute_id=>wwv_flow_api.id(12126709641008363126)
,p_display_sequence=>10
,p_display_value=>'Cover'
,p_return_value=>'cover'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(12125355381638396134)
,p_plugin_attribute_id=>wwv_flow_api.id(12126709641008363126)
,p_display_sequence=>20
,p_display_value=>'Contain'
,p_return_value=>'contain'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(12136089964514821490)
,p_plugin_id=>wwv_flow_api.id(36846774386193140128)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>6
,p_display_sequence=>60
,p_prompt=>'Background Color'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'black'
,p_is_translatable=>false
,p_help_text=>'Set background color of image swiper'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(12138162906371987033)
,p_plugin_id=>wwv_flow_api.id(36846774386193140128)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>7
,p_display_sequence=>70
,p_prompt=>'Set Controls'
,p_attribute_type=>'CHECKBOXES'
,p_is_required=>false
,p_default_value=>'keyboard:mousewheel:arrows'
,p_is_translatable=>false
,p_lov_type=>'STATIC'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(12138228165216019765)
,p_plugin_attribute_id=>wwv_flow_api.id(12138162906371987033)
,p_display_sequence=>10
,p_display_value=>'Keyboard Navigation Keys (Left/Right)'
,p_return_value=>'keyboard'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(12138373699109990397)
,p_plugin_attribute_id=>wwv_flow_api.id(12138162906371987033)
,p_display_sequence=>20
,p_display_value=>'Mousewheel'
,p_return_value=>'mousewheel'
);
wwv_flow_api.create_plugin_attr_value(
 p_id=>wwv_flow_api.id(12138394042703993861)
,p_plugin_attribute_id=>wwv_flow_api.id(12138162906371987033)
,p_display_sequence=>30
,p_display_value=>'Visual Next and Previous Buttons'
,p_return_value=>'arrows'
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(72925712610883165)
,p_plugin_id=>wwv_flow_api.id(36846774386193140128)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>8
,p_display_sequence=>80
,p_prompt=>'First Image ID'
,p_attribute_type=>'PAGE ITEM'
,p_is_required=>false
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_std_attribute(
 p_id=>wwv_flow_api.id(37022647824907561597)
,p_plugin_id=>wwv_flow_api.id(36846774386193140128)
,p_name=>'SOURCE_SQL'
,p_default_value=>wwv_flow_string.join(wwv_flow_t_varchar2(
'SELECT',
'    /* Required Source Type',
'       When SRC_TYPE is static string: ''blob'' and "Use Image source from BLOB Column" in Attributes is activated then you can show images directly from a table',
'       When SRC_TYPE is static string: ''url'' then SRC_VALUE should be a url to the image in web or e.g. static files */',
'    ''url'' AS SRC_TYPE,',
'    /* Required Source Value',
'       When SRC_TYPE is ''blob'' then the SRC_VALUE should be the Primary Key for the blob file. ',
'       This is not the blob file column. This Key is needed in "Use Image source from BLOB Column" in Attributes to get the image blob when needed',
'       When SRC_TYPE is ''url'' then add here the url of the image */',
'    ''https://github.com/RonnyWeiss/Apex-Advent-Calendar/raw/master/img/full/0'' || ROWNUM || ''.jpg'' AS SRC_VALUE,',
'    /* Optional Title of the image */',
'    ''Image Title '' || ROWNUM AS SRC_TITLE,',
'    /* Optinoal add link for click on images */',
'    ''https://github.com/RonnyWeiss'' AS LINK,',
'    /* Optional set time span when next img should be loaded, if 0, null or column is missing then autoslide it''s disabled */',
'    10 AS DURATION',
'FROM',
'    DUAL',
'CONNECT BY',
'    ROWNUM <= 9'))
,p_sql_min_column_count=>2
,p_depending_on_has_to_exist=>true
,p_examples=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<pre>',
'SELECT',
'    /* Required Source Type',
'       When SRC_TYPE is static string: ''blob'' and "Use Image source from BLOB Column" in Attributes is activated then you can show images directly from a table',
'       When SRC_TYPE is static string: ''url'' then SRC_VALUE should be a url to the image in web or e.g. static files */',
'    ''blob'' AS SRC_TYPE,',
'    /* Required Source Value',
'       When SRC_TYPE is ''blob'' then the SRC_VALUE should be the Primary Key for the blob file. ',
'       This is not the blob file column. This Key is needed in "Use Image source from BLOB Column" in Attributes to get the image blob when needed',
'       When SRC_TYPE is ''url'' then add here the url of the image */',
'     #PRIMARY_KEY_COLUMN# AS SRC_VALUE',
'FROM ',
'  #YOUR_TABLE#',
'</pre>'))
,p_help_text=>wwv_flow_string.join(wwv_flow_t_varchar2(
'<pre>',
'SELECT',
'    /* Required Source Type',
'       When SRC_TYPE is static string: ''blob'' and "Use Image source from BLOB Column" in Attributes is activated then you can show images directly from a table',
'       When SRC_TYPE is static string: ''url'' then SRC_VALUE should be a url to the image in web or e.g. static files */',
'    ''url'' AS SRC_TYPE,',
'    /* Required Source Value',
'       When SRC_TYPE is ''blob'' then the SRC_VALUE should be the Primary Key for the blob file. ',
'       This is not the blob file column. This Key is needed in "Use Image source from BLOB Column" in Attributes to get the image blob when needed',
'       When SRC_TYPE is ''url'' then add here the url of the image */',
'    ''https://github.com/RonnyWeiss/Apex-Advent-Calendar/raw/master/img/full/0'' || ROWNUM || ''.jpg'' AS SRC_VALUE,',
'    /* Optional Title of the image */',
'    ''Image Title '' || ROWNUM AS SRC_TITLE,',
'    /* Optinoal add link for click on images */',
'    ''https://github.com/RonnyWeiss'' AS LINK,',
'    /* Optional set time span when next img should be loaded, if 0, null or column is missing then autoslide it''s disabled */',
'    10 AS DURATION',
'FROM',
'    DUAL',
'CONNECT BY',
'    ROWNUM <= 9',
'</pre>'))
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '4D4954204C6963656E73650A0A436F7079726967687420286329203230323520526F6E6E792057656973730A0A5065726D697373696F6E20697320686572656279206772616E7465642C2066726565206F66206368617267652C20746F20616E79207065';
wwv_flow_api.g_varchar2_table(2) := '72736F6E206F627461696E696E67206120636F70790A6F66207468697320736F66747761726520616E64206173736F63696174656420646F63756D656E746174696F6E2066696C657320287468652022536F66747761726522292C20746F206465616C0A';
wwv_flow_api.g_varchar2_table(3) := '696E2074686520536F66747761726520776974686F7574207265737472696374696F6E2C20696E636C7564696E6720776974686F7574206C696D69746174696F6E20746865207269676874730A746F207573652C20636F70792C206D6F646966792C206D';
wwv_flow_api.g_varchar2_table(4) := '657267652C207075626C6973682C20646973747269627574652C207375626C6963656E73652C20616E642F6F722073656C6C0A636F70696573206F662074686520536F6674776172652C20616E6420746F207065726D697420706572736F6E7320746F20';
wwv_flow_api.g_varchar2_table(5) := '77686F6D2074686520536F6674776172652069730A6675726E697368656420746F20646F20736F2C207375626A65637420746F2074686520666F6C6C6F77696E6720636F6E646974696F6E733A0A0A5468652061626F766520636F70797269676874206E';
wwv_flow_api.g_varchar2_table(6) := '6F7469636520616E642074686973207065726D697373696F6E206E6F74696365207368616C6C20626520696E636C7564656420696E20616C6C0A636F70696573206F72207375627374616E7469616C20706F7274696F6E73206F662074686520536F6674';
wwv_flow_api.g_varchar2_table(7) := '776172652E0A0A54484520534F4654574152452049532050524F564944454420224153204953222C20574954484F55542057415252414E5459204F4620414E59204B494E442C2045585052455353204F520A494D504C4945442C20494E434C5544494E47';
wwv_flow_api.g_varchar2_table(8) := '20425554204E4F54204C494D4954454420544F205448452057415252414E54494553204F46204D45524348414E544142494C4954592C0A4649544E45535320464F52204120504152544943554C415220505552504F534520414E44204E4F4E494E465249';
wwv_flow_api.g_varchar2_table(9) := '4E47454D454E542E20494E204E4F204556454E54205348414C4C205448450A415554484F5253204F5220434F5059524947485420484F4C44455253204245204C4941424C4520464F5220414E5920434C41494D2C2044414D41474553204F52204F544845';
wwv_flow_api.g_varchar2_table(10) := '520A4C494142494C4954592C205748455448455220494E20414E20414354494F4E204F4620434F4E54524143542C20544F5254204F52204F54484552574953452C2041524953494E472046524F4D2C0A4F5554204F46204F5220494E20434F4E4E454354';
wwv_flow_api.g_varchar2_table(11) := '494F4E20574954482054484520534F465457415245204F522054484520555345204F52204F54484552204445414C494E475320494E205448450A534F4654574152452E0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(72916351092778172)
,p_plugin_id=>wwv_flow_api.id(36846774386193140128)
,p_file_name=>'LICENSE'
,p_mime_type=>'application/octet-stream'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '636F6E73742061706578496D616765536C69646572203D2066756E6374696F6E2028617065782C202429207B0D0A202020202275736520737472696374223B0D0A20202020636F6E7374207574696C203D207B0D0A202020202020202066656174757265';
wwv_flow_api.g_varchar2_table(2) := '44657461696C733A207B0D0A2020202020202020202020206E616D653A202241504558204C617A7920496D61676520536C69646572222C0D0A20202020202020202020202073637269707456657273696F6E3A202232352E30312E3035222C0D0A202020';
wwv_flow_api.g_varchar2_table(3) := '2020202020202020207574696C56657273696F6E3A202232322E31312E3238222C0D0A20202020202020202020202075726C3A202268747470733A2F2F6769746875622E636F6D2F526F6E6E795765697373222C0D0A2020202020202020202020206C69';
wwv_flow_api.g_varchar2_table(4) := '63656E73653A20224D4954220D0A20202020202020207D2C0D0A20202020202020206973446566696E6564416E644E6F744E756C6C3A2066756E6374696F6E202870496E70757429207B0D0A20202020202020202020202069662028747970656F662070';
wwv_flow_api.g_varchar2_table(5) := '496E70757420213D3D2022756E646566696E6564222026262070496E70757420213D3D206E756C6C2026262070496E70757420213D3D20222229207B0D0A2020202020202020202020202020202072657475726E20747275653B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(6) := '202020207D20656C7365207B0D0A2020202020202020202020202020202072657475726E2066616C73653B0D0A2020202020202020202020207D0D0A20202020202020207D2C0D0A20202020202020206C696E6B3A2066756E6374696F6E2028704C696E';
wwv_flow_api.g_varchar2_table(7) := '6B2C2070546172676574203D20225F706172656E742229207B0D0A20202020202020202020202069662028747970656F6620704C696E6B20213D3D2022756E646566696E65642220262620704C696E6B20213D3D206E756C6C20262620704C696E6B2021';
wwv_flow_api.g_varchar2_table(8) := '3D3D20222229207B0D0A2020202020202020202020202020202077696E646F772E6F70656E28704C696E6B2C2070546172676574293B0D0A2020202020202020202020207D0D0A20202020202020207D2C0D0A20202020202020206C6F616465723A207B';
wwv_flow_api.g_varchar2_table(9) := '0D0A20202020202020202020202073746172743A2066756E6374696F6E202869642C207365744D696E48656967687429207B0D0A20202020202020202020202020202020696620287365744D696E48656967687429207B0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(10) := '20202020202020202024286964292E63737328226D696E2D686569676874222C2022313030707822293B0D0A202020202020202020202020202020207D0D0A20202020202020202020202020202020617065782E7574696C2E73686F775370696E6E6572';
wwv_flow_api.g_varchar2_table(11) := '282428696429293B0D0A2020202020202020202020207D2C0D0A20202020202020202020202073746F703A2066756E6374696F6E202869642C2072656D6F76654D696E48656967687429207B0D0A20202020202020202020202020202020696620287265';
wwv_flow_api.g_varchar2_table(12) := '6D6F76654D696E48656967687429207B0D0A202020202020202020202020202020202020202024286964292E63737328226D696E2D686569676874222C202222293B0D0A202020202020202020202020202020207D0D0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(13) := '20202024286964202B2022203E202E752D50726F63657373696E6722292E72656D6F766528293B0D0A2020202020202020202020202020202024286964202B2022203E202E63742D6C6F6164657222292E72656D6F766528293B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(14) := '202020207D0D0A20202020202020207D2C0D0A20202020202020207072696E74444F4D4D6573736167653A207B0D0A20202020202020202020202073686F773A2066756E6374696F6E202869642C20746578742C2069636F6E2C20636F6C6F7229207B0D';
wwv_flow_api.g_varchar2_table(15) := '0A20202020202020202020202020202020636F6E737420646976203D202428223C6469763E22293B0D0A202020202020202020202020202020206966202824286964292E6865696768742829203E3D2031353029207B0D0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(16) := '2020202020202020636F6E737420737562446976203D202428223C6469763E3C2F6469763E22293B0D0A0D0A2020202020202020202020202020202020202020636F6E73742069636F6E5370616E203D202428223C7370616E3E3C2F7370616E3E22290D';
wwv_flow_api.g_varchar2_table(17) := '0A2020202020202020202020202020202020202020202020202E616464436C6173732822666122290D0A2020202020202020202020202020202020202020202020202E616464436C6173732869636F6E207C7C202266612D696E666F2D636972636C652D';
wwv_flow_api.g_varchar2_table(18) := '6F22290D0A2020202020202020202020202020202020202020202020202E616464436C617373282266612D327822290D0A2020202020202020202020202020202020202020202020202E6373732822686569676874222C20223332707822290D0A202020';
wwv_flow_api.g_varchar2_table(19) := '2020202020202020202020202020202020202020202E63737328227769647468222C20223332707822290D0A2020202020202020202020202020202020202020202020202E63737328226D617267696E2D626F74746F6D222C20223136707822290D0A20';
wwv_flow_api.g_varchar2_table(20) := '20202020202020202020202020202020202020202020202E6373732822636F6C6F72222C20636F6C6F72207C7C20222344304430443022293B0D0A0D0A20202020202020202020202020202020202020207375624469762E617070656E642869636F6E53';
wwv_flow_api.g_varchar2_table(21) := '70616E293B0D0A0D0A2020202020202020202020202020202020202020636F6E737420746578745370616E203D202428223C7370616E3E3C2F7370616E3E22290D0A2020202020202020202020202020202020202020202020202E746578742874657874';
wwv_flow_api.g_varchar2_table(22) := '290D0A2020202020202020202020202020202020202020202020202E6373732822646973706C6179222C2022626C6F636B22290D0A2020202020202020202020202020202020202020202020202E6373732822636F6C6F72222C20222337303730373022';
wwv_flow_api.g_varchar2_table(23) := '290D0A2020202020202020202020202020202020202020202020202E6373732822746578742D6F766572666C6F77222C2022656C6C697073697322290D0A2020202020202020202020202020202020202020202020202E63737328226F766572666C6F77';
wwv_flow_api.g_varchar2_table(24) := '222C202268696464656E22290D0A2020202020202020202020202020202020202020202020202E637373282277686974652D7370616365222C20226E6F7772617022290D0A2020202020202020202020202020202020202020202020202E637373282266';
wwv_flow_api.g_varchar2_table(25) := '6F6E742D73697A65222C20223132707822293B0D0A0D0A20202020202020202020202020202020202020206469760D0A2020202020202020202020202020202020202020202020202E63737328226D617267696E222C20223132707822290D0A20202020';
wwv_flow_api.g_varchar2_table(26) := '20202020202020202020202020202020202020202E6373732822746578742D616C69676E222C202263656E74657222290D0A2020202020202020202020202020202020202020202020202E637373282270616464696E67222C202231307078203022290D';
wwv_flow_api.g_varchar2_table(27) := '0A2020202020202020202020202020202020202020202020202E616464436C6173732822646F6D696E666F6D65737361676564697622290D0A2020202020202020202020202020202020202020202020202E617070656E6428737562446976290D0A2020';
wwv_flow_api.g_varchar2_table(28) := '202020202020202020202020202020202020202020202E617070656E6428746578745370616E293B0D0A202020202020202020202020202020207D20656C7365207B0D0A2020202020202020202020202020202020202020636F6E73742069636F6E5370';
wwv_flow_api.g_varchar2_table(29) := '616E203D202428223C7370616E3E3C2F7370616E3E22290D0A2020202020202020202020202020202020202020202020202E616464436C6173732822666122290D0A2020202020202020202020202020202020202020202020202E616464436C61737328';
wwv_flow_api.g_varchar2_table(30) := '69636F6E207C7C202266612D696E666F2D636972636C652D6F22290D0A2020202020202020202020202020202020202020202020202E6373732822666F6E742D73697A65222C20223232707822290D0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(31) := '202020202E63737328226C696E652D686569676874222C20223236707822290D0A2020202020202020202020202020202020202020202020202E63737328226D617267696E2D7269676874222C202235707822290D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(32) := '202020202020202020202E6373732822636F6C6F72222C20636F6C6F72207C7C20222344304430443022293B0D0A0D0A2020202020202020202020202020202020202020636F6E737420746578745370616E203D202428223C7370616E3E3C2F7370616E';
wwv_flow_api.g_varchar2_table(33) := '3E22290D0A2020202020202020202020202020202020202020202020202E746578742874657874290D0A2020202020202020202020202020202020202020202020202E6373732822636F6C6F72222C20222337303730373022290D0A2020202020202020';
wwv_flow_api.g_varchar2_table(34) := '202020202020202020202020202020202E6373732822746578742D6F766572666C6F77222C2022656C6C697073697322290D0A2020202020202020202020202020202020202020202020202E63737328226F766572666C6F77222C202268696464656E22';
wwv_flow_api.g_varchar2_table(35) := '290D0A2020202020202020202020202020202020202020202020202E637373282277686974652D7370616365222C20226E6F7772617022290D0A2020202020202020202020202020202020202020202020202E6373732822666F6E742D73697A65222C20';
wwv_flow_api.g_varchar2_table(36) := '223132707822290D0A2020202020202020202020202020202020202020202020202E63737328226C696E652D686569676874222C20223230707822293B0D0A0D0A20202020202020202020202020202020202020206469760D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(37) := '20202020202020202020202020202E63737328226D617267696E222C20223130707822290D0A2020202020202020202020202020202020202020202020202E6373732822746578742D616C69676E222C202263656E74657222290D0A2020202020202020';
wwv_flow_api.g_varchar2_table(38) := '202020202020202020202020202020202E616464436C6173732822646F6D696E666F6D65737361676564697622290D0A2020202020202020202020202020202020202020202020202E617070656E642869636F6E5370616E290D0A202020202020202020';
wwv_flow_api.g_varchar2_table(39) := '2020202020202020202020202020202E617070656E6428746578745370616E293B0D0A202020202020202020202020202020207D0D0A2020202020202020202020202020202024286964292E617070656E6428646976293B0D0A20202020202020202020';
wwv_flow_api.g_varchar2_table(40) := '20207D2C0D0A202020202020202020202020686964653A2066756E6374696F6E2028696429207B0D0A2020202020202020202020202020202024286964292E6368696C6472656E28222E646F6D696E666F6D65737361676564697622292E72656D6F7665';
wwv_flow_api.g_varchar2_table(41) := '28293B0D0A2020202020202020202020207D0D0A20202020202020207D2C0D0A20202020202020206E6F446174614D6573736167653A207B0D0A20202020202020202020202073686F773A2066756E6374696F6E202869642C207465787429207B0D0A20';
wwv_flow_api.g_varchar2_table(42) := '2020202020202020202020202020207574696C2E7072696E74444F4D4D6573736167652E73686F772869642C20746578742C202266612D73656172636822293B0D0A2020202020202020202020207D2C0D0A202020202020202020202020686964653A20';
wwv_flow_api.g_varchar2_table(43) := '66756E6374696F6E2028696429207B0D0A202020202020202020202020202020207574696C2E7072696E74444F4D4D6573736167652E68696465286964293B0D0A2020202020202020202020207D0D0A20202020202020207D2C0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(44) := '6572726F724D6573736167653A207B0D0A20202020202020202020202073686F773A2066756E6374696F6E202869642C207465787429207B0D0A202020202020202020202020202020207574696C2E7072696E74444F4D4D6573736167652E73686F7728';
wwv_flow_api.g_varchar2_table(45) := '69642C20746578742C202266612D6578636C616D6174696F6E2D747269616E676C65222C20222346464342334422293B0D0A2020202020202020202020207D2C0D0A202020202020202020202020686964653A2066756E6374696F6E2028696429207B0D';
wwv_flow_api.g_varchar2_table(46) := '0A202020202020202020202020202020207574696C2E7072696E74444F4D4D6573736167652E68696465286964293B0D0A2020202020202020202020207D0D0A20202020202020207D0D0A202020207D3B0D0A0D0A202020202F2A2A2A2A2A2A2A2A2A2A';
wwv_flow_api.g_varchar2_table(47) := '2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A0D0A20202020202A2A0D0A20202020202A2A205573656420746F20647261772074686520726567';
wwv_flow_api.g_varchar2_table(48) := '696F6E0D0A20202020202A2A0D0A20202020202A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2F0D0A2020202066756E';
wwv_flow_api.g_varchar2_table(49) := '6374696F6E2064726177536C696465526567696F6E2870446174612C2070436F6E6669674A534F4E29207B0D0A0D0A2020202020202020617065782E64656275672E696E666F287B0D0A20202020202020202020202022666374223A207574696C2E6665';
wwv_flow_api.g_varchar2_table(50) := '617475726544657461696C732E6E616D65202B2022202D2064726177536C696465526567696F6E222C0D0A202020202020202020202020227044617461223A2070446174612C0D0A202020202020202020202020226665617475726544657461696C7322';
wwv_flow_api.g_varchar2_table(51) := '3A207574696C2E6665617475726544657461696C730D0A20202020202020207D293B0D0A0D0A20202020202020206966202870446174612E726F772026262070446174612E726F772E6C656E677468203E203029207B0D0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(52) := '636F6E7374206974656D44617461203D2070446174612E726F773B0D0A2020202020202020202020206C65742068746D6C494458203D20302C0D0A2020202020202020202020202020202074696D654F75743B0D0A0D0A20202020202020202020202069';
wwv_flow_api.g_varchar2_table(53) := '66202870436F6E6669674A534F4E2E6669727374496D61676549444974656D29207B0D0A20202020202020202020202020202020636F6E7374206974656D203D20617065782E6974656D2870436F6E6669674A534F4E2E6669727374496D616765494449';
wwv_flow_api.g_varchar2_table(54) := '74656D290D0A0D0A20202020202020202020202020202020696620286974656D29207B0D0A2020202020202020202020202020202020202020636F6E73742076616C7565203D206974656D2E67657456616C756528293B0D0A0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(55) := '20202020202020202020206966202876616C756529207B0D0A20202020202020202020202020202020202020202020202066756E6374696F6E2066696E64496E646578427949642861727261792C20696429207B0D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(56) := '202020202020202020202020202072657475726E2061727261792E66696E64496E646578286974656D203D3E20282222202B206974656D2E5352435F56414C554529203D3D3D20282222202B20696429293B0D0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(57) := '20202020202020207D0D0A20202020202020202020202020202020202020202020202068746D6C494458203D2066696E64496E64657842794964286974656D446174612C2076616C7565293B0D0A20202020202020202020202020202020202020207D0D';
wwv_flow_api.g_varchar2_table(58) := '0A202020202020202020202020202020207D0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020206C65742068746D6C446976203D202428223C6469763E3C2F6469763E22293B0D0A20202020202020202020202068746D6C4469';
wwv_flow_api.g_varchar2_table(59) := '762E616464436C61737328227377697065722D6974656D2D68746D6C2D636F6E7461696E657222293B0D0A20202020202020202020202068746D6C4469762E6174747228226964222C2070436F6E6669674A534F4E2E726567696F6E4944202B20222D73';
wwv_flow_api.g_varchar2_table(60) := '6422293B0D0A20202020202020202020202068746D6C4469762E63737328226261636B67726F756E642D636F6C6F72222C2070436F6E6669674A534F4E2E6261636B67726F756E64436F6C6F72207C7C20227472616E73706172656E7422293B0D0A0D0A';
wwv_flow_api.g_varchar2_table(61) := '202020202020202020202020242870436F6E6669674A534F4E2E706172656E74494453656C6563746F72292E617070656E642868746D6C446976293B0D0A0D0A20202020202020202020202066756E6374696F6E207072657061726548544D4C52656E64';
wwv_flow_api.g_varchar2_table(62) := '65722829207B0D0A2020202020202020202020202020202068746D6C4469762E66696E6428222E7377697065722D696D672D636F6E7461696E657222292E72656D6F766528293B0D0A0D0A202020202020202020202020202020206C657420696D674469';
wwv_flow_api.g_varchar2_table(63) := '76203D202428223C6469763E3C2F6469763E22293B0D0A20202020202020202020202020202020696D674469762E616464436C61737328227377697065722D696D672D636F6E7461696E657222293B0D0A20202020202020202020202020202020696D67';
wwv_flow_api.g_varchar2_table(64) := '4469762E63737328226261636B67726F756E642D73697A65222C2070436F6E6669674A534F4E2E696D61676553697A65293B0D0A20202020202020202020202020202020696D674469762E6869646528293B0D0A0D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(65) := '202068746D6C4469762E70726570656E6428696D67446976293B0D0A0D0A202020202020202020202020202020206966202868746D6C494458203E20286974656D446174612E6C656E677468202D20312929207B0D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(66) := '20202020202068746D6C494458203D20303B0D0A202020202020202020202020202020207D20656C7365206966202868746D6C494458203C203029207B0D0A202020202020202020202020202020202020202068746D6C494458203D206974656D446174';
wwv_flow_api.g_varchar2_table(67) := '612E6C656E677468202D20313B0D0A202020202020202020202020202020207D0D0A0D0A20202020202020202020202020202020696620286974656D446174615B68746D6C4944585D29207B0D0A2020202020202020202020202020202020202020636F';
wwv_flow_api.g_varchar2_table(68) := '6E7374206974656D203D206974656D446174615B68746D6C4944585D3B0D0A0D0A2020202020202020202020202020202020202020696620287574696C2E6973446566696E6564416E644E6F744E756C6C286974656D2E4C494E4B2929207B0D0A202020';
wwv_flow_api.g_varchar2_table(69) := '202020202020202020202020202020202020202020696D674469762E6373732822637572736F72222C2022706F696E74657222293B0D0A202020202020202020202020202020202020202020202020696D674469762E6F6E2822636C69636B222C206675';
wwv_flow_api.g_varchar2_table(70) := '6E6374696F6E202829207B0D0A202020202020202020202020202020202020202020202020202020207574696C2E6C696E6B286974656D2E4C494E4B293B0D0A2020202020202020202020202020202020202020202020207D293B0D0A20202020202020';
wwv_flow_api.g_varchar2_table(71) := '202020202020202020202020207D0D0A0D0A2020202020202020202020202020202020202020696620287574696C2E6973446566696E6564416E644E6F744E756C6C286974656D2E5352435F5449544C452929207B0D0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(72) := '20202020202020202020206C657420696D675469746C65203D202428223C68333E3C2F68333E22293B0D0A202020202020202020202020202020202020202020202020696D675469746C652E616464436C61737328227377697065722D696D672D746974';
wwv_flow_api.g_varchar2_table(73) := '6C6522293B0D0A2020202020202020202020202020202020202020202020206966202870436F6E6669674A534F4E2E65736361706548544D4C526571756972656429207B0D0A20202020202020202020202020202020202020202020202020202020696D';
wwv_flow_api.g_varchar2_table(74) := '675469746C652E74657874286974656D2E5352435F5449544C45293B0D0A2020202020202020202020202020202020202020202020207D20656C7365207B0D0A20202020202020202020202020202020202020202020202020202020696D675469746C65';
wwv_flow_api.g_varchar2_table(75) := '2E68746D6C286974656D2E5352435F5449544C45293B0D0A2020202020202020202020202020202020202020202020207D0D0A202020202020202020202020202020202020202020202020696D674469762E617070656E6428696D675469746C65293B0D';
wwv_flow_api.g_varchar2_table(76) := '0A20202020202020202020202020202020202020207D0D0A0D0A20202020202020202020202020202020202020206C657420696D67535243203D206974656D2E5352435F56414C55453B0D0A0D0A20202020202020202020202020202020202020206966';
wwv_flow_api.g_varchar2_table(77) := '20286974656D2E5352435F54595045203D3D3D2022626C6F622229207B0D0A202020202020202020202020202020202020202020202020636F6E7374206974656D73325375626D6974426C6F62203D2070436F6E6669674A534F4E2E6974656D73325375';
wwv_flow_api.g_varchar2_table(78) := '626D6974426C6F623B0D0A0D0A202020202020202020202020202020202020202020202020696D67535243203D20617065782E7365727665722E706C7567696E55726C2870436F6E6669674A534F4E2E616A617849442C207B0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(79) := '202020202020202020202020202020202020207830313A20224745545F494D414745222C0D0A202020202020202020202020202020202020202020202020202020207830323A20696D675352432C0D0A2020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(80) := '2020202020202020706167654974656D733A206974656D73325375626D6974426C6F620D0A2020202020202020202020202020202020202020202020207D293B0D0A20202020202020202020202020202020202020207D0D0A0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(81) := '2020202020202020202020696D674469762E63737328226261636B67726F756E642D696D616765222C202275726C2822202B20696D67535243202B20222922293B0D0A0D0A20202020202020202020202020202020202020202428696D67446976292E66';
wwv_flow_api.g_varchar2_table(82) := '616465496E28226661737422293B0D0A0D0A20202020202020202020202020202020202020202F2A206D616B65206974206175746F20706C6179207768656E206475726174696F6E20697320736574202A2F0D0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(83) := '202020206966202870446174612E726F772E6C656E677468203E203129207B0D0A202020202020202020202020202020202020202020202020636F6E737420637572203D206974656D2C0D0A202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(84) := '20202020647572203D206375722E4455524154494F4E3B0D0A0D0A2020202020202020202020202020202020202020202020206966202864757220262620647572203E203029207B0D0A2020202020202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(85) := '202066756E6374696F6E2073657454696D654F7574287050726576656E7453657449445829207B0D0A202020202020202020202020202020202020202020202020202020202020202074696D654F7574203D2073657454696D656F75742866756E637469';
wwv_flow_api.g_varchar2_table(86) := '6F6E202829207B0D0A20202020202020202020202020202020202020202020202020202020202020202020202068746D6C4944582B2B3B0D0A2020202020202020202020202020202020202020202020202020202020202020202020202428696D674469';
wwv_flow_api.g_varchar2_table(87) := '76292E666164654F7574282266617374222C2066756E6374696F6E202829207B0D0A202020202020202020202020202020202020202020202020202020202020202020202020202020207072657061726548544D4C52656E64657228293B0D0A20202020';
wwv_flow_api.g_varchar2_table(88) := '20202020202020202020202020202020202020202020202020202020202020207D293B0D0A20202020202020202020202020202020202020202020202020202020202020207D2C20647572202A2031303030293B0D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(89) := '20202020202020202020202020207D0D0A0D0A20202020202020202020202020202020202020202020202020202020242868746D6C446976292E686F7665722866756E6374696F6E202829207B0D0A202020202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(90) := '2020202020202020202020636C65617254696D656F75742874696D654F7574293B0D0A202020202020202020202020202020202020202020202020202020207D293B0D0A0D0A202020202020202020202020202020202020202020202020202020202428';
wwv_flow_api.g_varchar2_table(91) := '68746D6C446976292E6D6F7573656C656176652866756E6374696F6E202829207B0D0A202020202020202020202020202020202020202020202020202020202020202073657454696D654F757428293B0D0A202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(92) := '202020202020202020207D293B0D0A0D0A2020202020202020202020202020202020202020202020202020202073657454696D654F757428293B0D0A2020202020202020202020202020202020202020202020207D0D0A20202020202020202020202020';
wwv_flow_api.g_varchar2_table(93) := '202020202020207D0D0A202020202020202020202020202020207D0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020202F2A20676F20746F206E65787420696D67202A2F0D0A20202020202020202020202066756E6374696F6E';
wwv_flow_api.g_varchar2_table(94) := '20676F446F776E2829207B0D0A2020202020202020202020202020202068746D6C4944582B2B3B0D0A20202020202020202020202020202020636C65617254696D656F75742874696D654F7574293B0D0A20202020202020202020202020202020242868';
wwv_flow_api.g_varchar2_table(95) := '746D6C446976292E66696E6428222E7377697065722D696D672D636F6E7461696E657222292E666164654F7574282266617374222C2066756E6374696F6E202829207B0D0A20202020202020202020202020202020202020207072657061726548544D4C';
wwv_flow_api.g_varchar2_table(96) := '52656E64657228293B0D0A202020202020202020202020202020207D293B0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020202F2A20676F20746F2070726576696F757320696D67202A2F0D0A20202020202020202020202066';
wwv_flow_api.g_varchar2_table(97) := '756E6374696F6E20676F55702829207B0D0A2020202020202020202020202020202068746D6C4944582D2D3B0D0A20202020202020202020202020202020636C65617254696D656F75742874696D654F7574293B0D0A2020202020202020202020202020';
wwv_flow_api.g_varchar2_table(98) := '2020242868746D6C446976292E66696E6428222E7377697065722D696D672D636F6E7461696E657222292E666164654F7574282266617374222C2066756E6374696F6E202829207B0D0A2020202020202020202020202020202020202020707265706172';
wwv_flow_api.g_varchar2_table(99) := '6548544D4C52656E64657228293B0D0A202020202020202020202020202020207D293B0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020202F2A2062696E64206D6F7573776865656C202A2F0D0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(100) := '69662028242E696E417272617928226D6F757365776865656C222C2070436F6E6669674A534F4E2E636F6E74726F6C7329203E3D20302026262070446174612E726F772E6C656E677468203E203129207B0D0A2020202020202020202020202020202024';
wwv_flow_api.g_varchar2_table(101) := '2870436F6E6669674A534F4E2E706172656E74494453656C6563746F72292E62696E6428226D6F757365776865656C20444F4D4D6F7573655363726F6C6C222C2066756E6374696F6E20286576656E7429207B0D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(102) := '20202020206576656E742E70726576656E7444656661756C7428293B0D0A2020202020202020202020202020202020202020696620286576656E742E6F726967696E616C4576656E742E776865656C44656C7461203E3D203029207B0D0A202020202020';
wwv_flow_api.g_varchar2_table(103) := '202020202020202020202020202020202020676F557028293B0D0A20202020202020202020202020202020202020207D20656C7365207B0D0A202020202020202020202020202020202020202020202020676F446F776E28290D0A202020202020202020';
wwv_flow_api.g_varchar2_table(104) := '20202020202020202020207D0D0A202020202020202020202020202020207D293B0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020202F2A2062696E64206172726F77206B657973202A2F0D0A20202020202020202020202069';
wwv_flow_api.g_varchar2_table(105) := '662028242E696E417272617928226B6579626F617264222C2070436F6E6669674A534F4E2E636F6E74726F6C7329203E3D20302026262070446174612E726F772E6C656E677468203E203129207B0D0A2020202020202020202020202020202024282262';
wwv_flow_api.g_varchar2_table(106) := '6F647922292E6B6579646F776E2866756E6374696F6E20286529207B0D0A202020202020202020202020202020202020202069662028652E6B6579436F6465203D3D3D20333729207B0D0A20202020202020202020202020202020202020202020202067';
wwv_flow_api.g_varchar2_table(107) := '6F557028293B0D0A20202020202020202020202020202020202020207D20656C73652069662028652E6B6579436F6465203D3D3D20333929207B0D0A202020202020202020202020202020202020202020202020676F446F776E28293B0D0A2020202020';
wwv_flow_api.g_varchar2_table(108) := '2020202020202020202020202020207D0D0A202020202020202020202020202020207D293B0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020202F2A2061646420636F6E74726F6C20627574746F6E7320666F7220736C696465';
wwv_flow_api.g_varchar2_table(109) := '202A2F0D0A20202020202020202020202069662028242E696E417272617928226172726F7773222C2070436F6E6669674A534F4E2E636F6E74726F6C7329203E3D20302026262070446174612E726F772E6C656E677468203E203129207B0D0A20202020';
wwv_flow_api.g_varchar2_table(110) := '2020202020202020202020206C6574206C656674436F6E74726F6C203D202428223C6469763E3C2F6469763E22293B0D0A202020202020202020202020202020206C656674436F6E74726F6C2E616464436C61737328227377697065722D6974656D2D68';
wwv_flow_api.g_varchar2_table(111) := '746D6C2D736C6964652D6C6322293B0D0A202020202020202020202020202020206C656674436F6E74726F6C2E6F6E2822636C69636B222C2066756E6374696F6E202829207B0D0A2020202020202020202020202020202020202020676F557028290D0A';
wwv_flow_api.g_varchar2_table(112) := '202020202020202020202020202020207D293B0D0A0D0A202020202020202020202020202020206C6574206C656674436F6E74726F6C49636F6E203D202428223C7370616E3E3C2F7370616E3E22293B0D0A202020202020202020202020202020206C65';
wwv_flow_api.g_varchar2_table(113) := '6674436F6E74726F6C49636F6E2E616464436C617373282266612066612D63686576726F6E2D6C6566742066612D6C6722293B0D0A202020202020202020202020202020206C656674436F6E74726F6C49636F6E2E616464436C61737328227377697065';
wwv_flow_api.g_varchar2_table(114) := '722D6974656D2D68746D6C2D736C6964652D6C632D7322293B0D0A202020202020202020202020202020206C656674436F6E74726F6C2E617070656E64286C656674436F6E74726F6C49636F6E293B0D0A0D0A2020202020202020202020202020202024';
wwv_flow_api.g_varchar2_table(115) := '2868746D6C446976292E617070656E64286C656674436F6E74726F6C293B0D0A0D0A202020202020202020202020202020206C6574207269676874436F6E74726F6C203D202428223C6469763E3C2F6469763E22293B0D0A202020202020202020202020';
wwv_flow_api.g_varchar2_table(116) := '202020207269676874436F6E74726F6C2E616464436C61737328227377697065722D6974656D2D68746D6C2D736C6964652D726322293B0D0A202020202020202020202020202020207269676874436F6E74726F6C2E6F6E2822636C69636B222C206675';
wwv_flow_api.g_varchar2_table(117) := '6E6374696F6E202829207B0D0A2020202020202020202020202020202020202020676F446F776E28293B0D0A202020202020202020202020202020207D293B0D0A0D0A202020202020202020202020202020206C6574207269676874436F6E74726F6C49';
wwv_flow_api.g_varchar2_table(118) := '636F6E203D202428223C7370616E3E3C2F7370616E3E22293B0D0A202020202020202020202020202020207269676874436F6E74726F6C49636F6E2E616464436C617373282266612066612D63686576726F6E2D72696768742066612D6C6722293B0D0A';
wwv_flow_api.g_varchar2_table(119) := '202020202020202020202020202020207269676874436F6E74726F6C49636F6E2E616464436C61737328227377697065722D6974656D2D68746D6C2D736C6964652D72632D7322293B0D0A202020202020202020202020202020207269676874436F6E74';
wwv_flow_api.g_varchar2_table(120) := '726F6C2E617070656E64287269676874436F6E74726F6C49636F6E293B0D0A0D0A202020202020202020202020202020202F2A20617070656E6420636F6E74726F6C20627574746F6E73202A2F0D0A20202020202020202020202020202020242868746D';
wwv_flow_api.g_varchar2_table(121) := '6C446976292E617070656E64287269676874436F6E74726F6C293B0D0A2020202020202020202020207D0D0A0D0A2020202020202020202020202F2A2072656E64657220696D6761676573202A2F0D0A2020202020202020202020207072657061726548';
wwv_flow_api.g_varchar2_table(122) := '544D4C52656E64657228293B0D0A0D0A2020202020202020202020207574696C2E6C6F616465722E73746F702870436F6E6669674A534F4E2E706172656E74494453656C6563746F72293B0D0A0D0A20202020202020207D20656C7365207B0D0A202020';
wwv_flow_api.g_varchar2_table(123) := '2020202020202020207574696C2E6E6F446174614D6573736167652E73686F772870436F6E6669674A534F4E2E706172656E74494453656C6563746F722C2070436F6E6669674A534F4E2E6E6F446174614D657373616765293B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(124) := '7D0D0A202020207D0D0A0D0A202020202F2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A0D0A20202020202A2A0D0A20';
wwv_flow_api.g_varchar2_table(125) := '202020202A2A205573656420746F2067657420646174612066726F6D207365727665720D0A20202020202A2A0D0A20202020202A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A';
wwv_flow_api.g_varchar2_table(126) := '2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2F0D0A2020202066756E6374696F6E20676574446174612870436F6E6669674A534F4E29207B0D0A2020202020202020636F6E7374206974656D73325375626D6974203D2070436F6E6669674A53';
wwv_flow_api.g_varchar2_table(127) := '4F4E2E6974656D325375626D69743B0D0A0D0A20202020202020202F2A20636C65616E7570202A2F0D0A2020202020202020242870436F6E6669674A534F4E2E706172656E74494453656C6563746F72292E656D70747928293B0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(128) := '617065782E7365727665722E706C7567696E280D0A20202020202020202020202070436F6E6669674A534F4E2E616A617849442C207B0D0A2020202020202020202020207830313A20224745545F53514C5F534F55524345222C0D0A2020202020202020';
wwv_flow_api.g_varchar2_table(129) := '20202020706167654974656D733A206974656D73325375626D69740D0A20202020202020207D2C207B0D0A202020202020202020202020737563636573733A2066756E6374696F6E2028704461746129207B0D0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(130) := '64726177536C696465526567696F6E2870446174612C2070436F6E6669674A534F4E293B0D0A2020202020202020202020207D2C0D0A2020202020202020202020206572726F723A2066756E6374696F6E20286429207B0D0A2020202020202020202020';
wwv_flow_api.g_varchar2_table(131) := '20202020207574696C2E6E6F446174614D6573736167652E73686F772870436F6E6669674A534F4E2E706172656E74494453656C6563746F722C20224572726F72206F6363757265642122293B0D0A20202020202020202020202020202020617065782E';
wwv_flow_api.g_varchar2_table(132) := '64656275672E6572726F72287B0D0A202020202020202020202020202020202020202022666374223A207574696C2E6665617475726544657461696C732E6E616D65202B2022202D2067657444617461222C0D0A20202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(133) := '20202020226D7367223A20224572726F72207768696C65206C6F6164696E6720414A41582064617461222C0D0A202020202020202020202020202020202020202022657272223A20642C0D0A202020202020202020202020202020202020202022666561';
wwv_flow_api.g_varchar2_table(134) := '7475726544657461696C73223A207574696C2E6665617475726544657461696C730D0A202020202020202020202020202020207D293B0D0A2020202020202020202020207D2C0D0A20202020202020202020202064617461547970653A20226A736F6E22';
wwv_flow_api.g_varchar2_table(135) := '0D0A20202020202020207D293B0D0A202020207D0D0A0D0A2020202072657475726E207B0D0A20202020202020202F2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A';
wwv_flow_api.g_varchar2_table(136) := '2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A0D0A2020202020202020202A2A0D0A2020202020202020202A2A20496E697469616C2066756E6374696F6E0D0A2020202020202020202A2A0D0A2020202020202020202A2A2A2A2A2A2A2A2A2A2A2A2A2A2A';
wwv_flow_api.g_varchar2_table(137) := '2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2A2F0D0A2020202020202020696E697469616C697A653A2066756E6374696F6E20280D0A202020202020202020';
wwv_flow_api.g_varchar2_table(138) := '20202070526567696F6E49442C0D0A20202020202020202020202070416A617849442C0D0A202020202020202020202020704E6F446174614D6573736167652C0D0A20202020202020202020202070496D6167654865696768742C0D0A20202020202020';
wwv_flow_api.g_varchar2_table(139) := '202020202070496D61676553697A652C0D0A202020202020202020202020704261636B67726F756E64436F6C6F722C0D0A20202020202020202020202070436F6E74726F6C732C0D0A202020202020202020202020704974656D73325375626D69742C0D';
wwv_flow_api.g_varchar2_table(140) := '0A202020202020202020202020704974656D73325375626D6974426C6F622C0D0A202020202020202020202020704669727374496D61676549444974656D2C0D0A202020202020202020202020705265717569726548544D4C4573636170650D0A202020';
wwv_flow_api.g_varchar2_table(141) := '202020202029207B0D0A0D0A202020202020202020202020617065782E64656275672E696E666F287B0D0A2020202020202020202020202020202022666374223A207574696C2E6665617475726544657461696C732E6E616D65202B2022202D20696E69';
wwv_flow_api.g_varchar2_table(142) := '7469616C697A65222C0D0A2020202020202020202020202020202022636F6E666967223A207B0D0A20202020202020202020202020202020202020202270526567696F6E4944223A2070526567696F6E49442C0D0A202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(143) := '20202020202270416A61784944223A2070416A617849442C0D0A202020202020202020202020202020202020202022704E6F446174614D657373616765223A20704E6F446174614D6573736167652C0D0A20202020202020202020202020202020202020';
wwv_flow_api.g_varchar2_table(144) := '202270496D616765486569676874223A2070496D6167654865696768742C0D0A20202020202020202020202020202020202020202270496D61676553697A65223A2070496D61676553697A652C0D0A202020202020202020202020202020202020202022';
wwv_flow_api.g_varchar2_table(145) := '704261636B67726F756E64436F6C6F72223A20704261636B67726F756E64436F6C6F722C0D0A202020202020202020202020202020202020202022704974656D73325375626D6974223A20704974656D73325375626D69742C0D0A202020202020202020';
wwv_flow_api.g_varchar2_table(146) := '202020202020202020202022704974656D73325375626D6974426C6F62223A20704974656D73325375626D6974426C6F622C0D0A202020202020202020202020202020202020202022705265717569726548544D4C457363617065223A20705265717569';
wwv_flow_api.g_varchar2_table(147) := '726548544D4C4573636170652C0D0A202020202020202020202020202020202020202022704669727374496D61676549444974656D223A20704669727374496D61676549444974656D2C0D0A20202020202020202020202020202020202020202270436F';
wwv_flow_api.g_varchar2_table(148) := '6E74726F6C73223A2070436F6E74726F6C730D0A202020202020202020202020202020207D2C0D0A20202020202020202020202020202020226665617475726544657461696C73223A207574696C2E6665617475726544657461696C730D0A2020202020';
wwv_flow_api.g_varchar2_table(149) := '202020202020207D293B0D0A0D0A2020202020202020202020206C657420636F6E6669674A534F4E203D207B7D3B0D0A0D0A202020202020202020202020636F6E6669674A534F4E2E696D616765486569676874203D2070496D6167654865696768743B';
wwv_flow_api.g_varchar2_table(150) := '0D0A202020202020202020202020636F6E6669674A534F4E2E696D61676553697A65203D2070496D61676553697A653B0D0A202020202020202020202020636F6E6669674A534F4E2E6261636B67726F756E64436F6C6F72203D20704261636B67726F75';
wwv_flow_api.g_varchar2_table(151) := '6E64436F6C6F723B0D0A202020202020202020202020636F6E6669674A534F4E2E616A61784944203D2070416A617849443B0D0A202020202020202020202020636F6E6669674A534F4E2E706172656E74494453656C6563746F72203D20222322202B20';
wwv_flow_api.g_varchar2_table(152) := '70526567696F6E4944202B20222D6973223B0D0A202020202020202020202020636F6E6669674A534F4E2E726567696F6E4944203D2070526567696F6E49443B0D0A202020202020202020202020636F6E6669674A534F4E2E6E6F446174614D65737361';
wwv_flow_api.g_varchar2_table(153) := '6765203D20704E6F446174614D6573736167653B0D0A202020202020202020202020636F6E6669674A534F4E2E6974656D325375626D6974203D20704974656D73325375626D69743B0D0A202020202020202020202020636F6E6669674A534F4E2E6974';
wwv_flow_api.g_varchar2_table(154) := '656D73325375626D6974426C6F62203D20704974656D73325375626D6974426C6F623B0D0A202020202020202020202020636F6E6669674A534F4E2E6669727374496D61676549444974656D203D20704669727374496D61676549444974656D3B0D0A20';
wwv_flow_api.g_varchar2_table(155) := '2020202020202020202020636F6E6669674A534F4E2E636F6E74726F6C73203D2070436F6E74726F6C732E73706C697428223A22293B0D0A202020202020202020202020636F6E6669674A534F4E2E65736361706548544D4C5265717569726564203D20';
wwv_flow_api.g_varchar2_table(156) := '747275653B0D0A0D0A2020202020202020202020202428636F6E6669674A534F4E2E706172656E74494453656C6563746F72292E6373732822686569676874222C20636F6E6669674A534F4E2E696D616765486569676874293B0D0A0D0A202020202020';
wwv_flow_api.g_varchar2_table(157) := '2020202020207574696C2E6C6F616465722E737461727428636F6E6669674A534F4E2E706172656E74494453656C6563746F72293B0D0A0D0A20202020202020202020202069662028705265717569726548544D4C457363617065203D3D3D2066616C73';
wwv_flow_api.g_varchar2_table(158) := '6529207B0D0A20202020202020202020202020202020636F6E6669674A534F4E2E65736361706548544D4C5265717569726564203D2066616C73653B0D0A2020202020202020202020207D0D0A0D0A202020202020202020202020676574446174612863';
wwv_flow_api.g_varchar2_table(159) := '6F6E6669674A534F4E293B0D0A0D0A2020202020202020202020202F2F2062696E642072656672657368206576656E740D0A2020202020202020202020202428222322202B2070526567696F6E4944292E62696E6428226170657872656672657368222C';
wwv_flow_api.g_varchar2_table(160) := '2066756E6374696F6E202829207B0D0A202020202020202020202020202020206765744461746128636F6E6669674A534F4E293B0D0A2020202020202020202020207D293B0D0A20202020202020207D0D0A202020207D3B0D0A7D3B0D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(72916693380778173)
,p_plugin_id=>wwv_flow_api.id(36846774386193140128)
,p_file_name=>'script.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2E7377697065722D696D672D7469746C65207B0D0A20202020706F736974696F6E3A206162736F6C7574653B0D0A20202020626F74746F6D3A20303B0D0A202020206C6566743A20303B0D0A202020206261636B67726F756E643A207267626128313231';
wwv_flow_api.g_varchar2_table(2) := '2C203132312C203132312C20302E35293B0D0A2020202077696474683A20313030253B0D0A2020202070616464696E673A20323070783B0D0A20202020636F6C6F723A2077686974653B0D0A202020206D617267696E3A203070783B0D0A7D0D0A0D0A2E';
wwv_flow_api.g_varchar2_table(3) := '7377697065722D6C696B652D6865617274207B0D0A20202020706F736974696F6E3A206162736F6C7574653B0D0A202020206C6566743A203530253B0D0A20202020746F703A203530253B0D0A202020206D617267696E2D6C6566743A202D333070783B';
wwv_flow_api.g_varchar2_table(4) := '0D0A202020206D617267696E2D746F703A202D363070783B0D0A20202020636F6C6F723A2072676261283139322C20302C2031352C20302E38293B0D0A202020206261636B67726F756E643A2072676261283235352C203235352C203235352C20302E38';
wwv_flow_api.g_varchar2_table(5) := '293B0D0A20202020626F726465722D7261646975733A203530253B0D0A202020206F7061636974793A20303B0D0A7D0D0A0D0A2E7377697065722D6974656D2D68746D6C2D736C6964652D6C632C0D0A2E7377697065722D6974656D2D68746D6C2D736C';
wwv_flow_api.g_varchar2_table(6) := '6964652D7263207B0D0A202020206261636B67726F756E643A207267626128302C20302C20302C20302E32293B0D0A20202020746578742D616C69676E3A2063656E7465723B0D0A20202020706F736974696F6E3A206162736F6C7574653B0D0A202020';
wwv_flow_api.g_varchar2_table(7) := '20626F74746F6D3A2063616C6328353025202D2034307078293B0D0A20202020637572736F723A20706F696E7465723B0D0A7D0D0A0D0A2E7377697065722D6974656D2D68746D6C2D736C6964652D6C633A686F7665722C0D0A2E7377697065722D6974';
wwv_flow_api.g_varchar2_table(8) := '656D2D68746D6C2D736C6964652D72633A686F766572207B0D0A202020206261636B67726F756E643A2072676261283132302C203132302C203132302C20302E36293B0D0A7D0D0A0D0A2E7377697065722D6974656D2D68746D6C2D736C6964652D6C63';
wwv_flow_api.g_varchar2_table(9) := '2D732C0D0A2E7377697065722D6974656D2D68746D6C2D736C6964652D72632D73207B0D0A20202020626F726465722D7261646975733A203130253B0D0A2020202070616464696E672D746F703A20323570783B0D0A2020202070616464696E672D626F';
wwv_flow_api.g_varchar2_table(10) := '74746F6D3A20323570783B0D0A2020202070616464696E672D6C6566743A203270783B0D0A2020202070616464696E672D72696768743A203270783B0D0A20202020636F6C6F723A2077686974653B0D0A7D0D0A0D0A2E7377697065722D6974656D2D68';
wwv_flow_api.g_varchar2_table(11) := '746D6C2D736C6964652D6C63207B0D0A202020206C6566743A203570783B0D0A7D0D0A0D0A2E7377697065722D6974656D2D68746D6C2D736C6964652D7263207B0D0A2020202072696768743A203570783B0D0A7D0D0A0D0A2E7377697065722D697465';
wwv_flow_api.g_varchar2_table(12) := '6D2D68746D6C2D636F6E7461696E65722C0D0A2E7377697065722D696D672D636F6E7461696E6572207B0D0A202020206865696768743A20313030253B0D0A20202020706F736974696F6E3A2072656C61746976653B0D0A7D0D0A0D0A2E737769706572';
wwv_flow_api.g_varchar2_table(13) := '2D696D672D636F6E7461696E6572207B0D0A202020206261636B67726F756E642D7265706561743A206E6F2D7265706561743B0D0A202020206261636B67726F756E642D706F736974696F6E3A2063656E7465723B0D0A7D0D0A';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(72917417257778174)
,p_plugin_id=>wwv_flow_api.id(36846774386193140128)
,p_file_name=>'style.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '2E7377697065722D696D672D7469746C657B706F736974696F6E3A6162736F6C7574653B626F74746F6D3A303B6C6566743A303B6261636B67726F756E643A72676261283132312C3132312C3132312C2E35293B77696474683A313030253B7061646469';
wwv_flow_api.g_varchar2_table(2) := '6E673A323070783B636F6C6F723A236666663B6D617267696E3A307D2E7377697065722D6C696B652D68656172747B706F736974696F6E3A6162736F6C7574653B6C6566743A3530253B746F703A3530253B6D617267696E2D6C6566743A2D333070783B';
wwv_flow_api.g_varchar2_table(3) := '6D617267696E2D746F703A2D363070783B636F6C6F723A72676261283139322C302C31352C2E38293B6261636B67726F756E643A72676261283235352C3235352C3235352C2E38293B626F726465722D7261646975733A3530253B6F7061636974793A30';
wwv_flow_api.g_varchar2_table(4) := '7D2E7377697065722D6974656D2D68746D6C2D736C6964652D6C632C2E7377697065722D6974656D2D68746D6C2D736C6964652D72637B6261636B67726F756E643A7267626128302C302C302C2E32293B746578742D616C69676E3A63656E7465723B70';
wwv_flow_api.g_varchar2_table(5) := '6F736974696F6E3A6162736F6C7574653B626F74746F6D3A63616C6328353025202D2034307078293B637572736F723A706F696E7465727D2E7377697065722D6974656D2D68746D6C2D736C6964652D6C633A686F7665722C2E7377697065722D697465';
wwv_flow_api.g_varchar2_table(6) := '6D2D68746D6C2D736C6964652D72633A686F7665727B6261636B67726F756E643A72676261283132302C3132302C3132302C2E36297D2E7377697065722D6974656D2D68746D6C2D736C6964652D6C632D732C2E7377697065722D6974656D2D68746D6C';
wwv_flow_api.g_varchar2_table(7) := '2D736C6964652D72632D737B626F726465722D7261646975733A3130253B70616464696E673A32357078203270783B636F6C6F723A236666667D2E7377697065722D6974656D2D68746D6C2D736C6964652D6C637B6C6566743A3570787D2E7377697065';
wwv_flow_api.g_varchar2_table(8) := '722D6974656D2D68746D6C2D736C6964652D72637B72696768743A3570787D2E7377697065722D696D672D636F6E7461696E65722C2E7377697065722D6974656D2D68746D6C2D636F6E7461696E65727B6865696768743A313030253B706F736974696F';
wwv_flow_api.g_varchar2_table(9) := '6E3A72656C61746976657D2E7377697065722D696D672D636F6E7461696E65727B6261636B67726F756E642D7265706561743A6E6F2D7265706561743B6261636B67726F756E642D706F736974696F6E3A63656E7465727D';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(72917827793778175)
,p_plugin_id=>wwv_flow_api.id(36846774386193140128)
,p_file_name=>'style.min.css'
,p_mime_type=>'text/css'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
begin
wwv_flow_api.g_varchar2_table := wwv_flow_api.empty_varchar2_table;
wwv_flow_api.g_varchar2_table(1) := '636F6E73742061706578496D616765536C696465723D66756E6374696F6E28652C73297B2275736520737472696374223B636F6E737420743D7B6665617475726544657461696C733A7B6E616D653A2241504558204C617A7920496D61676520536C6964';
wwv_flow_api.g_varchar2_table(2) := '6572222C73637269707456657273696F6E3A2232352E30312E3035222C7574696C56657273696F6E3A2232322E31312E3238222C75726C3A2268747470733A2F2F6769746875622E636F6D2F526F6E6E795765697373222C6C6963656E73653A224D4954';
wwv_flow_api.g_varchar2_table(3) := '227D2C6973446566696E6564416E644E6F744E756C6C3A66756E6374696F6E2865297B72657475726E206E756C6C213D6526262222213D3D657D2C6C696E6B3A66756E6374696F6E28652C733D225F706172656E7422297B6E756C6C213D652626222221';
wwv_flow_api.g_varchar2_table(4) := '3D3D65262677696E646F772E6F70656E28652C73297D2C6C6F616465723A7B73746172743A66756E6374696F6E28742C69297B692626732874292E63737328226D696E2D686569676874222C22313030707822292C652E7574696C2E73686F775370696E';
wwv_flow_api.g_varchar2_table(5) := '6E65722873287429297D2C73746F703A66756E6374696F6E28652C74297B742626732865292E63737328226D696E2D686569676874222C2222292C7328652B22203E202E752D50726F63657373696E6722292E72656D6F766528292C7328652B22203E20';
wwv_flow_api.g_varchar2_table(6) := '2E63742D6C6F6164657222292E72656D6F766528297D7D2C7072696E74444F4D4D6573736167653A7B73686F773A66756E6374696F6E28652C742C692C6E297B636F6E737420613D7328223C6469763E22293B696628732865292E68656967687428293E';
wwv_flow_api.g_varchar2_table(7) := '3D313530297B636F6E737420653D7328223C6469763E3C2F6469763E22292C6F3D7328223C7370616E3E3C2F7370616E3E22292E616464436C6173732822666122292E616464436C61737328697C7C2266612D696E666F2D636972636C652D6F22292E61';
wwv_flow_api.g_varchar2_table(8) := '6464436C617373282266612D327822292E6373732822686569676874222C223332707822292E63737328227769647468222C223332707822292E63737328226D617267696E2D626F74746F6D222C223136707822292E6373732822636F6C6F72222C6E7C';
wwv_flow_api.g_varchar2_table(9) := '7C222344304430443022293B652E617070656E64286F293B636F6E737420723D7328223C7370616E3E3C2F7370616E3E22292E746578742874292E6373732822646973706C6179222C22626C6F636B22292E6373732822636F6C6F72222C222337303730';
wwv_flow_api.g_varchar2_table(10) := '373022292E6373732822746578742D6F766572666C6F77222C22656C6C697073697322292E63737328226F766572666C6F77222C2268696464656E22292E637373282277686974652D7370616365222C226E6F7772617022292E6373732822666F6E742D';
wwv_flow_api.g_varchar2_table(11) := '73697A65222C223132707822293B612E63737328226D617267696E222C223132707822292E6373732822746578742D616C69676E222C2263656E74657222292E637373282270616464696E67222C2231307078203022292E616464436C6173732822646F';
wwv_flow_api.g_varchar2_table(12) := '6D696E666F6D65737361676564697622292E617070656E642865292E617070656E642872297D656C73657B636F6E737420653D7328223C7370616E3E3C2F7370616E3E22292E616464436C6173732822666122292E616464436C61737328697C7C226661';
wwv_flow_api.g_varchar2_table(13) := '2D696E666F2D636972636C652D6F22292E6373732822666F6E742D73697A65222C223232707822292E63737328226C696E652D686569676874222C223236707822292E63737328226D617267696E2D7269676874222C2235707822292E6373732822636F';
wwv_flow_api.g_varchar2_table(14) := '6C6F72222C6E7C7C222344304430443022292C6F3D7328223C7370616E3E3C2F7370616E3E22292E746578742874292E6373732822636F6C6F72222C222337303730373022292E6373732822746578742D6F766572666C6F77222C22656C6C6970736973';
wwv_flow_api.g_varchar2_table(15) := '22292E63737328226F766572666C6F77222C2268696464656E22292E637373282277686974652D7370616365222C226E6F7772617022292E6373732822666F6E742D73697A65222C223132707822292E63737328226C696E652D686569676874222C2232';
wwv_flow_api.g_varchar2_table(16) := '30707822293B612E63737328226D617267696E222C223130707822292E6373732822746578742D616C69676E222C2263656E74657222292E616464436C6173732822646F6D696E666F6D65737361676564697622292E617070656E642865292E61707065';
wwv_flow_api.g_varchar2_table(17) := '6E64286F297D732865292E617070656E642861297D2C686964653A66756E6374696F6E2865297B732865292E6368696C6472656E28222E646F6D696E666F6D65737361676564697622292E72656D6F766528297D7D2C6E6F446174614D6573736167653A';
wwv_flow_api.g_varchar2_table(18) := '7B73686F773A66756E6374696F6E28652C73297B742E7072696E74444F4D4D6573736167652E73686F7728652C732C2266612D73656172636822297D2C686964653A66756E6374696F6E2865297B742E7072696E74444F4D4D6573736167652E68696465';
wwv_flow_api.g_varchar2_table(19) := '2865297D7D2C6572726F724D6573736167653A7B73686F773A66756E6374696F6E28652C73297B742E7072696E74444F4D4D6573736167652E73686F7728652C732C2266612D6578636C616D6174696F6E2D747269616E676C65222C2223464643423344';
wwv_flow_api.g_varchar2_table(20) := '22297D2C686964653A66756E6374696F6E2865297B742E7072696E74444F4D4D6573736167652E686964652865297D7D7D3B66756E6374696F6E20692869297B636F6E7374206E3D692E6974656D325375626D69743B7328692E706172656E7449445365';
wwv_flow_api.g_varchar2_table(21) := '6C6563746F72292E656D70747928292C652E7365727665722E706C7567696E28692E616A617849442C7B7830313A224745545F53514C5F534F55524345222C706167654974656D733A6E7D2C7B737563636573733A66756E6374696F6E286E297B216675';
wwv_flow_api.g_varchar2_table(22) := '6E6374696F6E28692C6E297B696628652E64656275672E696E666F287B6663743A742E6665617475726544657461696C732E6E616D652B22202D2064726177536C696465526567696F6E222C70446174613A692C6665617475726544657461696C733A74';
wwv_flow_api.g_varchar2_table(23) := '2E6665617475726544657461696C737D292C692E726F772626692E726F772E6C656E6774683E30297B636F6E737420633D692E726F773B6C657420642C703D303B6966286E2E6669727374496D61676549444974656D297B636F6E737420733D652E6974';
wwv_flow_api.g_varchar2_table(24) := '656D286E2E6669727374496D61676549444974656D293B69662873297B636F6E737420653D732E67657456616C756528293B652626286C3D652C703D632E66696E64496E6465782828653D3E22222B652E5352435F56414C55453D3D22222B6C2929297D';
wwv_flow_api.g_varchar2_table(25) := '7D6C657420663D7328223C6469763E3C2F6469763E22293B66756E6374696F6E206128297B662E66696E6428222E7377697065722D696D672D636F6E7461696E657222292E72656D6F766528293B6C6574206F3D7328223C6469763E3C2F6469763E2229';
wwv_flow_api.g_varchar2_table(26) := '3B6966286F2E616464436C61737328227377697065722D696D672D636F6E7461696E657222292C6F2E63737328226261636B67726F756E642D73697A65222C6E2E696D61676553697A65292C6F2E6869646528292C662E70726570656E64286F292C703E';
wwv_flow_api.g_varchar2_table(27) := '632E6C656E6774682D313F703D303A703C30262628703D632E6C656E6774682D31292C635B705D297B636F6E7374206C3D635B705D3B696628742E6973446566696E6564416E644E6F744E756C6C286C2E4C494E4B292626286F2E637373282263757273';
wwv_flow_api.g_varchar2_table(28) := '6F72222C22706F696E74657222292C6F2E6F6E2822636C69636B222C2866756E6374696F6E28297B742E6C696E6B286C2E4C494E4B297D2929292C742E6973446566696E6564416E644E6F744E756C6C286C2E5352435F5449544C4529297B6C65742065';
wwv_flow_api.g_varchar2_table(29) := '3D7328223C68333E3C2F68333E22293B652E616464436C61737328227377697065722D696D672D7469746C6522292C6E2E65736361706548544D4C52657175697265643F652E74657874286C2E5352435F5449544C45293A652E68746D6C286C2E535243';
wwv_flow_api.g_varchar2_table(30) := '5F5449544C45292C6F2E617070656E642865297D6C657420753D6C2E5352435F56414C55453B69662822626C6F62223D3D3D6C2E5352435F54595045297B636F6E737420733D6E2E6974656D73325375626D6974426C6F623B753D652E7365727665722E';
wwv_flow_api.g_varchar2_table(31) := '706C7567696E55726C286E2E616A617849442C7B7830313A224745545F494D414745222C7830323A752C706167654974656D733A737D297D6966286F2E63737328226261636B67726F756E642D696D616765222C2275726C28222B752B222922292C7328';
wwv_flow_api.g_varchar2_table(32) := '6F292E66616465496E28226661737422292C692E726F772E6C656E6774683E31297B636F6E737420653D6C2E4455524154494F4E3B696628652626653E30297B66756E6374696F6E20722874297B643D73657454696D656F7574282866756E6374696F6E';
wwv_flow_api.g_varchar2_table(33) := '28297B702B2B2C73286F292E666164654F7574282266617374222C2866756E6374696F6E28297B6128297D29297D292C3165332A65297D732866292E686F766572282866756E6374696F6E28297B636C65617254696D656F75742864297D29292C732866';
wwv_flow_api.g_varchar2_table(34) := '292E6D6F7573656C65617665282866756E6374696F6E28297B7228297D29292C7228297D7D7D7D66756E6374696F6E206F28297B702B2B2C636C65617254696D656F75742864292C732866292E66696E6428222E7377697065722D696D672D636F6E7461';
wwv_flow_api.g_varchar2_table(35) := '696E657222292E666164654F7574282266617374222C2866756E6374696F6E28297B6128297D29297D66756E6374696F6E207228297B702D2D2C636C65617254696D656F75742864292C732866292E66696E6428222E7377697065722D696D672D636F6E';
wwv_flow_api.g_varchar2_table(36) := '7461696E657222292E666164654F7574282266617374222C2866756E6374696F6E28297B6128297D29297D696628662E616464436C61737328227377697065722D6974656D2D68746D6C2D636F6E7461696E657222292C662E6174747228226964222C6E';
wwv_flow_api.g_varchar2_table(37) := '2E726567696F6E49442B222D736422292C662E63737328226261636B67726F756E642D636F6C6F72222C6E2E6261636B67726F756E64436F6C6F727C7C227472616E73706172656E7422292C73286E2E706172656E74494453656C6563746F72292E6170';
wwv_flow_api.g_varchar2_table(38) := '70656E642866292C732E696E417272617928226D6F757365776865656C222C6E2E636F6E74726F6C73293E3D302626692E726F772E6C656E6774683E31262673286E2E706172656E74494453656C6563746F72292E62696E6428226D6F75736577686565';
wwv_flow_api.g_varchar2_table(39) := '6C20444F4D4D6F7573655363726F6C6C222C2866756E6374696F6E2865297B652E70726576656E7444656661756C7428292C652E6F726967696E616C4576656E742E776865656C44656C74613E3D303F7228293A6F28297D29292C732E696E4172726179';
wwv_flow_api.g_varchar2_table(40) := '28226B6579626F617264222C6E2E636F6E74726F6C73293E3D302626692E726F772E6C656E6774683E312626732822626F647922292E6B6579646F776E282866756E6374696F6E2865297B33373D3D3D652E6B6579436F64653F7228293A33393D3D3D65';
wwv_flow_api.g_varchar2_table(41) := '2E6B6579436F646526266F28297D29292C732E696E417272617928226172726F7773222C6E2E636F6E74726F6C73293E3D302626692E726F772E6C656E6774683E31297B6C657420653D7328223C6469763E3C2F6469763E22293B652E616464436C6173';
wwv_flow_api.g_varchar2_table(42) := '7328227377697065722D6974656D2D68746D6C2D736C6964652D6C6322292C652E6F6E2822636C69636B222C2866756E6374696F6E28297B7228297D29293B6C657420743D7328223C7370616E3E3C2F7370616E3E22293B742E616464436C6173732822';
wwv_flow_api.g_varchar2_table(43) := '66612066612D63686576726F6E2D6C6566742066612D6C6722292C742E616464436C61737328227377697065722D6974656D2D68746D6C2D736C6964652D6C632D7322292C652E617070656E642874292C732866292E617070656E642865293B6C657420';
wwv_flow_api.g_varchar2_table(44) := '693D7328223C6469763E3C2F6469763E22293B692E616464436C61737328227377697065722D6974656D2D68746D6C2D736C6964652D726322292C692E6F6E2822636C69636B222C2866756E6374696F6E28297B6F28297D29293B6C6574206E3D732822';
wwv_flow_api.g_varchar2_table(45) := '3C7370616E3E3C2F7370616E3E22293B6E2E616464436C617373282266612066612D63686576726F6E2D72696768742066612D6C6722292C6E2E616464436C61737328227377697065722D6974656D2D68746D6C2D736C6964652D72632D7322292C692E';
wwv_flow_api.g_varchar2_table(46) := '617070656E64286E292C732866292E617070656E642869297D6128292C742E6C6F616465722E73746F70286E2E706172656E74494453656C6563746F72297D656C736520742E6E6F446174614D6573736167652E73686F77286E2E706172656E74494453';
wwv_flow_api.g_varchar2_table(47) := '656C6563746F722C6E2E6E6F446174614D657373616765293B766172206C7D286E2C69297D2C6572726F723A66756E6374696F6E2873297B742E6E6F446174614D6573736167652E73686F7728692E706172656E74494453656C6563746F722C22457272';
wwv_flow_api.g_varchar2_table(48) := '6F72206F6363757265642122292C652E64656275672E6572726F72287B6663743A742E6665617475726544657461696C732E6E616D652B22202D2067657444617461222C6D73673A224572726F72207768696C65206C6F6164696E6720414A4158206461';
wwv_flow_api.g_varchar2_table(49) := '7461222C6572723A732C6665617475726544657461696C733A742E6665617475726544657461696C737D297D2C64617461547970653A226A736F6E227D297D72657475726E7B696E697469616C697A653A66756E6374696F6E286E2C612C6F2C722C6C2C';
wwv_flow_api.g_varchar2_table(50) := '632C642C702C662C752C67297B652E64656275672E696E666F287B6663743A742E6665617475726544657461696C732E6E616D652B22202D20696E697469616C697A65222C636F6E6669673A7B70526567696F6E49443A6E2C70416A617849443A612C70';
wwv_flow_api.g_varchar2_table(51) := '4E6F446174614D6573736167653A6F2C70496D6167654865696768743A722C70496D61676553697A653A6C2C704261636B67726F756E64436F6C6F723A632C704974656D73325375626D69743A702C704974656D73325375626D6974426C6F623A662C70';
wwv_flow_api.g_varchar2_table(52) := '5265717569726548544D4C4573636170653A672C704669727374496D61676549444974656D3A752C70436F6E74726F6C733A647D2C6665617475726544657461696C733A742E6665617475726544657461696C737D293B6C6574206D3D7B7D3B6D2E696D';
wwv_flow_api.g_varchar2_table(53) := '6167654865696768743D722C6D2E696D61676553697A653D6C2C6D2E6261636B67726F756E64436F6C6F723D632C6D2E616A617849443D612C6D2E706172656E74494453656C6563746F723D2223222B6E2B222D6973222C6D2E726567696F6E49443D6E';
wwv_flow_api.g_varchar2_table(54) := '2C6D2E6E6F446174614D6573736167653D6F2C6D2E6974656D325375626D69743D702C6D2E6974656D73325375626D6974426C6F623D662C6D2E6669727374496D61676549444974656D3D752C6D2E636F6E74726F6C733D642E73706C697428223A2229';
wwv_flow_api.g_varchar2_table(55) := '2C6D2E65736361706548544D4C52657175697265643D21302C73286D2E706172656E74494453656C6563746F72292E6373732822686569676874222C6D2E696D616765486569676874292C742E6C6F616465722E7374617274286D2E706172656E744944';
wwv_flow_api.g_varchar2_table(56) := '53656C6563746F72292C21313D3D3D672626286D2E65736361706548544D4C52657175697265643D2131292C69286D292C73282223222B6E292E62696E6428226170657872656672657368222C2866756E6374696F6E28297B69286D297D29297D7D7D3B';
null;
end;
/
begin
wwv_flow_api.create_plugin_file(
 p_id=>wwv_flow_api.id(73102624872038370)
,p_plugin_id=>wwv_flow_api.id(36846774386193140128)
,p_file_name=>'script.min.js'
,p_mime_type=>'text/javascript'
,p_file_charset=>'utf-8'
,p_file_content=>wwv_flow_api.varchar2_to_blob(wwv_flow_api.g_varchar2_table)
);
end;
/
prompt --application/end_environment
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false));
commit;
end;
/
set verify on feedback on define on
prompt  ...done
