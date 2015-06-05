
/* ================================================  
 * Oracle XFiles Demonstration.  
 *    
 * Copyright (c) 2014 Oracle and/or its affiliates.  All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * ================================================
 */

--
-- XDBPM_INTERNAL should be created under XDBPM
--
alter session set current_schema = XDBPM
/
create or replace package XDBPM_INTERNAL
authid CURRENT_USER
as
  function hasBinaryContent(P_CONTENT_ID NUMBER) return BOOLEAN;
  function hasTextContent(P_CONTENT_ID NUMBER) return BOOLEAN;

  procedure resetLobLocator(P_RESID RAW);
  procedure setTextContent(P_RESID RAW);
  procedure setBinaryContent(P_RESID RAW);
  procedure setXMLContent(P_RESID RAW);
end;
/
show errors
--
create or replace package body XDBPM_INTERNAL
as
--
  G_RESOURCE_SCHEMA_OID RAW(16);
  G_TEXT_ELEMENT_ID     NUMBER(16);
  G_BINARY_ELEMENT_ID   NUMBER(16);
  
--
procedure getResourceSchemaInfo
as
begin
  select object_id,
       extractValue(
         object_value,
         '/xs:schema/xs:element[@name="binary"]/@xdb:propNumber',
         'xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xdb="http://xmlns.oracle.com/xdb"'
       ),
       extractValue(
         object_value,
         '/xs:schema/xs:element[@name="text"]/@xdb:propNumber',
         'xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xdb="http://xmlns.oracle.com/xdb"'
       )
    into G_RESOURCE_SCHEMA_OID, G_BINARY_ELEMENT_ID, G_TEXT_ELEMENT_ID
    from xdb.xdb$schema
   where extractValue(
         object_value,
         '/xs:schema/@xdb:schemaURL',
         'xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xdb="http://xmlns.oracle.com/xdb"'
       )  = 'http://xmlns.oracle.com/xdb/XDBSchema.xsd';
end;
--
function hasBinaryContent(P_CONTENT_ID NUMBER) 
return BOOLEAN
as
begin
  return (P_CONTENT_ID = G_BINARY_ELEMENT_ID);
end;
--
function hasTextContent(P_CONTENT_ID NUMBER) 
return BOOLEAN
as
begin
	return (P_CONTENT_ID = G_TEXT_ELEMENT_ID);
end;
--
procedure resetLobLocator(P_RESID RAW)
as
begin
  xdb_helper.resetLobLocator(P_RESID);
end;
--
procedure setBinaryContent(P_RESID RAW)
as
begin
  xdb_helper.setBinaryContent(P_RESID, G_RESOURCE_SCHEMA_OID, G_BINARY_ELEMENT_ID);
end;
--
procedure setTextContent(P_RESID RAW)
as
begin
  xdb_helper.setTextContent(P_RESID, G_RESOURCE_SCHEMA_OID, G_TEXT_ELEMENT_ID);
end;
--
procedure setXMLContent(P_RESID RAW)
as
begin
  xdb_helper.setXMLContent(P_RESID);
end;
--
begin
  getResourceSchemaInfo;
end;
/
show errors
--
alter session set current_schema = SYS
/
--