xquery version "3.0";

import module namespace config = "http://exist-db.org/mods/config" at "xmldb:exist:///db/apps/tamboti/modules/config.xqm";
import module namespace installation = "http://hra.uni-heidelberg.de/ns/tamboti/installation/" at "xmldb:exist:///db/apps/tamboti/modules/installation/installation.xqm";

declare variable $home external;
declare variable $target external;

(
    for $sample-collection-name in xmldb:get-child-collections($target)
    let $sample-collection-path := xs:anyURI($config:samples-collection-path || "/" || $sample-collection-name)
    return
        (
            if (xmldb:collection-available($sample-collection-path))
            then xmldb:remove($sample-collection-path)
            else ()
            ,
            xmldb:create-collection($config:samples-collection-path, $sample-collection-name)
            ,
            installation:set-resource-properties($sample-collection-path, $config:public-collection-mode)
            ,           
            xmldb:store-files-from-pattern($sample-collection-path, $dir, $sample-collection-name || "/*.xml")
            ,
            installation:set-child-resources-properties($sample-collection-path, $config:public-resource-mode)
            ,
            xmldb:remove(xs:anyURI($target || "/" || $sample-collection-name))
        )
)
