xquery version "3.0";

import module namespace config = "http://exist-db.org/mods/config" at "xmldb:exist:///db/apps/tamboti/modules/config.xqm";
import module namespace installation = "http://hra.uni-heidelberg.de/ns/tamboti/installation/" at "xmldb:exist:///db/apps/tamboti/modules/installation/installation.xqm";

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;

(: get the sample colection names :)
let $sample-collection-names :=
    for $sample-collection-name in xmldb:get-child-collections($target)
    return $sample-collection-name

return
    (
        (: in tamboti data collection, delete only the sample collection that are included in tamboti-samples :)
        for $sample-collection-name in $sample-collection-names
        let $old-sample-collection-path := xs:anyURI($config:samples-collection-path || "/" || $sample-collection-name)
        return 
            if (xmldb:collection-available($old-sample-collection-path))
            then xmldb:remove($old-sample-collection-path)
            else ()            
        ,
        (: store the new sample collections in tamboti data collection :)
        xmldb:store-files-from-pattern($config:samples-collection-path, $dir, "**/*.*", (), true(), "*.*")
        ,
        (: set the correct permissions for the new sample collections in tamboti data collection :)
        installation:set-public-collection-permissions-recursively($config:samples-collection-path)
    )
