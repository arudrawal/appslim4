<?php
require_once(__DIR__.'/../env/env.php');
require_once(__DIR__.'/inc/DbCommand.php');
	$dbc = new DbCommand();
	$dbserver = getenv('DB_SERVER');
	$dbname = getenv('DB_NAME');
   
	$dbc->checkForceError(); // fail if not safe.
	$confirm = $dbc->promptUser("Confirm databse DROP [$dbname@$dbserver] [yes|no]? ");
	if (0 == preg_match('/yes/', $confirm)) {
		echo $confirm."\n";
		exit;
	}
	$conn = $dbc->getDbcon(null);// do not select db
	try {
		$retval = $conn->query( "DROP Database $dbname" );
	} catch (Exception $e) {
		die($e->getMessage());
	}   
	echo "Database dropped successfully: $dbname@$dbserver\n";
?>
