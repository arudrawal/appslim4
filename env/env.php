<?php
# production/dev
putenv("PRODUCTION=0");
putenv("DB_NAME=cta");
putenv("HT_PORT=80");

if (getenv("PRODUCTION")) {
	// prodction specific data out of this tree
	define ("ENV_FILE",__DIR__.'/../../env/env.php');
	require_once(ENV_FILE);
} else { // test specific data goes here
	putenv("DB_USER=root");
	putenv("DB_PASS=");
	putenv("DB_SERVER=localhost");
	putenv("HT_DOMAIN=localhost"); // www.mycta.com
}
?>