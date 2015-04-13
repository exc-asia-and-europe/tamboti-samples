xquery version "3.0";

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;

declare variable $db-root := "/db";

(:~ Collection names :)
declare variable $samples-collection-path := "data/commons/Samples";
declare variable $sample-collection-names := ("Sociology", "eXist-db");

(:~ Collection paths :)
declare variable $local:collection-mode := "rwx------";
declare variable $local:resource-mode := "rw-------";
declare variable $local:biblio-admin-user := "editor";
declare variable $local:biblio-users-group := "biblio.users";

declare function local:mkcol-recursive($collection, $components, $permissions as xs:string) {
    if (exists($components)) then
        let $newColl := concat($collection, "/", $components[1])
        return (
            xmldb:create-collection($collection, $components[1]),
            local:set-resource-properties(xs:anyURI($newColl), $permissions),
            local:mkcol-recursive($newColl, subsequence($components, 2), $permissions)
        )
    else
        ()
};

(: Helper function to recursively create a collection hierarchy. :)
declare function local:mkcol($collection, $path, $permissions as xs:string) {
    local:mkcol-recursive($collection, tokenize($path, "/"), $permissions)
};

declare function local:set-resource-properties($resource-path as xs:anyURI, $permissions as xs:string) {
    (
        sm:chown($resource-path, $local:biblio-admin-user),
        sm:chgrp($resource-path, $local:biblio-users-group),
        sm:chmod($resource-path, $permissions)        
    )    
};

declare function local:set-child-resources-properties($collection-path as xs:anyURI, $permissions as xs:string) {
    for $resource-name in xmldb:get-child-resources($collection-path)
    return local:set-resource-properties(xs:anyURI(concat($collection-path, '/', $resource-name)), $permissions)
};

(
    local:mkcol($db-root, $samples-collection-path, $local:collection-mode)
    ,
    for $sample-collection-name in $sample-collection-names
    let $sample-collection-path := xs:anyURI("/" || $samples-collection-path || "/" || $sample-collection-name)
    return
        (
            if (xmldb:collection-available($sample-collection-path)) then xmldb:remove($sample-collection-path) else ()
            ,
            xmldb:create-collection("/" || $samples-collection-path, $sample-collection-name)
            ,
            local:set-resource-properties($sample-collection-path, $local:collection-mode)
            ,           
            xmldb:store-files-from-pattern($sample-collection-path, $dir, $sample-collection-name || "/*.xml")
            ,
            local:set-child-resources-properties($sample-collection-path, $local:resource-mode)
        )
)

