xquery version "3.0";

import module namespace config = "http://exist-db.org/mods/config" at "xmldb:exist:///db/apps/tamboti/modules/config.xqm";
import module namespace installation = "http://hra.uni-heidelberg.de/ns/tamboti/installation/" at "xmldb:exist:///db/apps/tamboti/modules/installation/installation.xqm";

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;

declare variable $db-root := "/db";

(:~ Collection names :)
declare variable $samples-collection-path := $config:mods-commons || "/Samples";
declare variable $sample-collection-names := ("Sociology", "eXist-db");

(
    installation:mkcol($db-root, $samples-collection-path, $config:public-collection-mode)
    ,
    for $sample-collection-name in $sample-collection-names
    let $sample-collection-path := xs:anyURI($samples-collection-path || "/" || $sample-collection-name)
    return
        (
            if (xmldb:collection-available($sample-collection-path))
            then xmldb:remove($sample-collection-path)
            else ()
            ,
            xmldb:create-collection($samples-collection-path, $sample-collection-name)
            ,
            installation:set-resource-properties($sample-collection-path, $config:public-collection-mode)
            ,           
            xmldb:store-files-from-pattern($sample-collection-path, $dir, $sample-collection-name || "/*.xml")
            ,
            installation:set-child-resources-properties($sample-collection-path, $config:public-resource-mode)
        )
)

