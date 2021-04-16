<?php
/**
 * Create database tables.
 */
	require_once(__DIR__.'/../env/env.php');
	require_once(__DIR__.'/inc/DbCommand.php');
	require_once(__DIR__.'/inc/MysqlParser.php');

	$dbc = new DbCommand();
	
	$dbc->checkForceError(); // fail if not safe.
	
	$server_db = $dbc->displayServerDb();
	echo "\nRebuilding the databse [$server_db]...\n";
	
	//-- All tables in the database
	$results = $dbc->query('SHOW TABLES');
	$tables = array();
	while($table = $results->fetch_array()) { $tables[] = $table[0]; }

	//-- All views in the database
	$resv = $dbc->query("SHOW FULL TABLES WHERE TABLE_TYPE LIKE 'VIEW'");
	$views = array();
	while($view = $resv->fetch_array()) { $views[] = $view[0]; }

	//-- if we found tables and views, nuke em
	echo "\tFound ".count($tables)." tables, and " . count($views)." views.\n";
	$confirm = $dbc->promptUser("Confirm databse RESET [$server_db] [yes|no]? ");
	if (0 == preg_match('/yes/', $confirm)) {
		echo $confirm."\n";
		exit;
	}
	//-- rebuild the database from scratch
	echo PHP_EOL. "Seeding the database...".PHP_EOL;
	if(count($views) > 0){
		$sql = 'drop view '.implode(',', $views);
		$dbc->query($sql);
		echo "\tViews dropped.\n";
    }
	if(count($tables) > 0){
		$sql = 'drop tables '.implode(',', $tables);
		$dbc->query($sql);
		echo "\tTables dropped.\n";
	}
	
	$dirSchema =__DIR__."/schema/";
	//-- first grab all the .sql files
	$cmds = array();
	if (is_dir($dirSchema)) {
		if($dirHandle = opendir($dirSchema)){
			$parser = new MysqlParser;
			while(($file = readdir($dirHandle)) !== false){
				//-- only pull .sql files
				if(substr(strrchr($file,'.'),1) != 'sql' || 
					$file == '.' || $file == '..'){ continue; }
				$fileName = $dirSchema.'/'.$file;
				echo "executing: $fileName" . PHP_EOL;
				$sqlContent = file_get_contents($fileName);
				if (!$sqlContent) {
					die("Failed to read file: $fileName");
				}
				//-- split into individual commands
				$sqls = $parser->getSqlQueries($sqlContent);
				foreach ($sqls as $sql) {
					//-- trim and skip empty lines
					$sql = trim($sql);
					if ($sql) {
						$return = $dbc->query($sql);
						if (!$return) { 
							echo "$fileName: Failed query:\n$sql\n";
							die($dbc->getError());
						}
					}
				}
			}
		} else { 
			die("Could not open dir: $dirSchema");
		}
	} else { 
		die("Could not find schema dir: $dirSchema"); 
	}
	echo "\n\n Schema creation COMPLETE! !\n";
?>
