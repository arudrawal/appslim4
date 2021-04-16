<?php
	require_once(__DIR__.'/../env/env.php');
	require_once(__DIR__.'/inc/DbCommand.php');
	$dbc = new DbCommand();
	
	$dbc->checkForceError(); // fail if not safe.
   
	$dbname = getenv('DB_NAME');
	$conn = $dbc->getDbcon(null);
	if ($conn) {
		try {
			$retval = $conn->query( "CREATE Database IF NOT EXISTS $dbname" );
		} catch (Exception $e) {
			die($e->getMessage());
		}
	}
	echo "Database created successfully: $dbname\n";
	$conn->close();
?>
