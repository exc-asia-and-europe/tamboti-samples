xquery version "3.0";

declare variable $home external;
declare variable $target external;

(    
    xmldb:remove(xs:anyURI($target || "/eXist-db"))
    ,
    xmldb:remove(xs:anyURI($target || "/Sociology"))
)
