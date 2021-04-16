<?php
	require_once(__DIR__.'/../env/env.php');
	require_once(__DIR__.'/inc/DbCommand.php');
	$dbc = new DbCommand();
	
	$dbc->checkForceError(); // fail if not safe.
   	$dbserver = getenv('DB_SERVER');
	$dbname = getenv('DB_NAME');
	$conn = $dbc->getDbcon(null);// do not select db
	if ($conn) {
		try {
			$retval = $conn->query( "CREATE Database IF NOT EXISTS $dbname" );
		} catch (Exception $e) {
			die($e->getMessage());
		}
	}
	echo "Database created successfully: $dbname@$dbserver\n";
	$conn->close();
?>
