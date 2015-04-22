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

installation:mkcol($db-root, $config:samples-collection-path, $config:public-collection-mode)
