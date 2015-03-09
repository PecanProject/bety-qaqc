#!/usr/bin/awk -f
# This script parses a .csv file of the citations table with columns: author, year, journal, volume, first_page into an xml query suitable for submission to 
# CrossRef http://www.crossref.org/guestquery/ 
# XML Attributes Must be Quoted. Attribute values must always be quoted. Either single or double quotes can be used.
# http://stackoverflow.com/q/9880808/199217
# http://stackoverflow.com/a/9711893/199217
BEGIN{
    FS=","
    print "<?xml version = '1.0' encoding='UTF-8'?>"
    print "<query_batch xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' version='2.0' xmlns='http://www.crossref.org/qschema/2.0'"
    print "  xsi:schemaLocation='http://www.crossref.org/qschema/2.0 http://www.crossref.org/qschema/crossref_query_input2.0.xsd'>"
    print "<head>"
    print "   <email_address>test@crossref.org</email_address>"
    print "   <doi_batch_id>test</doi_batch_id>"
    print "</head>"
    print "<body>"
}

NR>1{
    print "  <query enable-multiple-hits='true'"
    print "            list-components='false'"
    print "            expanded-results='false' key='key'>"
    print "    <article_title match='fuzzy'>" $3 "</article_title>"
    print "    <author search-all-authors='false'>" $1 "</author>"
    print "    <volume>" $5 "</volume>"
    print "    <year>" $2 "</year>"
    print "    <first_page>" $6 "</first_page>"
    print "    <journal_title>" $4 "</journal_title>"
    print "  </query>"
}

END{
    print "</body>"
    print "</query_batch>"
}