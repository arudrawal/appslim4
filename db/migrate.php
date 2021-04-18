<?php
/************************************************************
 * Apply database migrations.
 * Migrations are Data Dictionary changes applied on live 
 * system without loosing any data.
 * Two sql scripts are created one for migration UP and other
 * to undo the changes done by up migration.    
 * Migrations must be applied and backed off in a fixed 
 * sequence. Migration file name contains GMT time, which 
 * determines the sequence of execution.
 * Options:
 *  -c: create empty up/down migration script files.  
 *  -i: initialize migration on a database by creating a 
 *      migration table to keep track of applied migrations.
 *  -u <n>: apply <n> up migration (all if n is not given)
 *  -d <n>: undo last <n> migration(default n=1)
 *  -v: view applied migrations
 *  Sample Commands:
 *  $ php migrate.php -i // create migration table. Needed once.
 *  $ php migrate.php -c change_ip_size // create migration scripts 
 *  $ php migrate.php -u <n>// Apply up migration
 *  $ php migrate.php -d <n>// Apply down migration
 *  $ php migrate.php -v    // View applied migrations
 * Check exit status by on CLI shell: echo $?
 * Test cases:
 * php migrate.php      -> no args
 * php migrate.php -abc -> Invalid args
 * php migrate.php -i   -> Initialize mig
 * php migrate.php -c  -> no mig name
 * php migrate.php -c __up__ -> invalid mig name
 * php migrate.php -c __UP__ -> invalid mig name
 * php migrate.php -c __dn__ -> invalid mig name
 * php migrate.php -c __DN__ -> invalid mig name
 * php migrate.php -c test   -> valid mig name
 * php migrate.php -v        -> view current migs
 * php migrate.php -u 1      -> up migrate 1
 * php migrate.php -u        -> up migrate all
 * php migrate.php -d        -> dn migrate 1
 * php migrate.php -d 2      -> dn migrate 2
 ************************************************************/
	require_once(__DIR__.'/../env/env.php');
	require_once(__DIR__.'/inc/DbCommand.php');
	require_once(__DIR__.'/inc/Migration.php');
    
	$dbc = new DbCommand();
	$dbc->checkForceError(); // fail if not safe.
	$mysqli = $dbc->getDbcon(true);
	
    $script_path =__DIR__.DIRECTORY_SEPARATOR.'schema';
    

    $USAGE = "USAGE: " . basename(__FILE__) . 
            ' [-i|-c|-u <n>|-d <n>] [name-migration]';
	$mig = new Migration($mysqli, $script_path);
	
	if (sizeof($argv) < 2) {
		$mig->display_mig();
		return;
	}
	if ($argv[1] == '-c') { // create migration files
		$user_mig_name = isset($argv[2]) ? $argv[2] : '';
		$fname = $mig->createMigfiles($user_mig_name);
		if ($fname) {
			echo 'Migration files created: ' . $fname . PHP_EOL;
		} else {
			echo 'Failed to create migration files' . PHP_EOL;
		}
		return;
	} else if ($argv[1] == '-u') {
		$up_count = isset($argv[2]) ? $argv[2] : 0;
		$mig->up($up_count);
	} else if ($argv[1] == '-d') {
		$dn_count = isset($argv[2]) ? $argv[2] : 1;
		$mig->dn($dn_count);
	} else if ($argv[1] == '-i') {
		$mig->createMigTable();
	}
?>
