<?php

require_once(__DIR__.'/MysqlParser.php');

class Migration {
	const DATE_FROMAT = 'Y_m_d_His';
	protected $mig_dir = __DIR__;
	protected $mysqli = null;
	
	function __construct($dir, $conn) {
		$this->mig_dir = $dir;
		$this->mysqli = $conn;
	}
    //protected function getUp
	
	//-- Return timestamp for a given script name
	//-- $script_name: 2016_06_12_170149_event_log.sql
    protected function getTS($script_name) {
        $timestamp = FALSE;
		$tz = new DateTimeZone("UTC");//::UTC;       
        $dateArray = explode('_', basename($script_name));
        if (count($dateArray) >= 3) { // time: His (default: midnight)
			$dateStr = $dateArray[0] . '_' . $dateArray[1].'_'. $dateArray[2];
			$dateStr .= '_' . (count($dateArray) >= 4) ? $dateArray[3] : '000000';
			$dateTimeObject = DateTime::createFromFormat($self::DATE_FROMAT, $dateStr, $tz);
			if ($dateTimeObject) {
				$timestamp = $dateTimeObject->getTimestamp();
			}
        }
        return $timestamp;
    }
    // Create an associative array of sql scripts in migrations directory
    // sorted_array = array("1463072509" => 
    //                       "2016_05_12_170149_dn_ip_size_up.sql",
    //                     ...);
    //-- mig_up=1 -> up migration else down 
    function sortedFilesIndexed($mig_dir) {
        // Prepare a sorted list of up and down migrations scripts.
        $mig_files = glob($mig_dir.'/*.{sql}', GLOB_BRACE);
        
        $mig_indexed = array();
        foreach ($mig_files as $file) {
            $timestamp = self::getTS($file);
            if ($timestamp !== FALSE) {
                $mig_indexed[$timestamp] = $file;
            }
        }
		asort($mig_indexed, SORT_NUMERIC);
        return $mig_indexed;
    }
    //-- Execute PHP or SQL file
    //-- Return true if all good, exit in case of failure
    function exec_file($src_file) {
        if (file_exists($src_file)) {
            $info = pathinfo($src_file);
            if ($info["extension"] == "sql") {
				$parser = new MySqlparser;
				$sqls = $parser->getSqlQueries($sqlContent); // individual queries
				foreach ($sqls as $sql) {
					$sql = trim($sql); // skip empty lines
					if ($sql) {
						$return = $this->mysqli->query($sql);
						if (!$return) { 
							echo "$src_file: Failed query:\n$sql\n";
							echo $this->mysqli->getError() . PHP_EOL;
							return FALSE;
						}
					}
				}
				return TRUE;
            }
        }
		return FALSE;
    }
	protected function exec_mig($files) {
		foreach ($files as $file) {
			if (!self::exec_file($file)) {
				return false;
			}
		}
		return true;
	}
	// in ascending order
	protected function getMigsByID() {
		$migs_applied = array();
        $cmd = 'SELECT * FROM migrations ORDER BY mig_ID ASC';
        $result = self::mysqli->query($cmd);
        if ($result == FALSE) {
            exit(0); // return up mig count;
        }
        //var_dump($result);die();
        $ts_last_mig = 0;
        $last_mig_id = 0;
        while ($row = $result->fetch_assoc()) {
			$migs_applied[$row['mig_ID'] = $row;//['mig_UP_SCRIPT'];
        }
		return $migs_applied;
	}
	// migrate up: 0=ALL
	public function up($count=0) {
		$mig_up_files = self::sortedFilesIndexed($this->mig_dir . '/up');
		$mig_dn_files = self::sortedFilesIndexed($this->mig_dir . '/dn');
		$mig_applied = self::getMigsByID(); // indexed by mig_ID
		$mig_applied_ts = array_keys($mig_applied);
		$ts_last_mig_applied = 0;
		if (count($mig_applied)) {
			$row = $mig_applied[count($mig_applied)-1];
			$ts_last_mig_applied = self::getTS($row['mig_UP_SCRIPT']);
		}

		if (count($mig_applied) < count($mig_up_files)) {
			$up_count = 0;
			foreach ($mig_up_files as $file_ts=>$mig_up_file) {
				if ($file_ts > $ts_last_mig_applied) {
					if (0 == $count || // unlimited ups
						$up_count < $count) { // fix number of ups
						if (!array_key_exists($file_ts, $mig_dn_files)) {
							echo 'Down mig not found for: ' . $mig_file . PHP_EOL;
							return false;
						}
						//echo "execute: $mig_up_file \n";
						if (!self::exec_file($mig_up_file)) {
							return false;
						}               
						//-- Update migration table.
						$cmd = "INSERT INTO migrations ".
								"(`mig_ID`, `mig_UP_SCRIPT`, `mig_DN_SCRIPT`)".
								" VALUES (NULL,'" . 
								basename($mig_up_file) . "','" . 
								basename($mig_dn_files[$file_ts]) . "')";
						if (!self::mysqli->query($cmd)) {
							return false;
						}
					}
				}
				$up_count++;
			}
		}
	}
	// migrate down:
	public function dn($count=1) {
		$mig_dn_files = self::sortedFilesIndexed($this->mig_dir . '/dn');
		$mig_applied = self::getMigsByID(); // indexed by mig_ID
		$mig_applied_count = count($mig_applied);
		if (0 == $mig_applied_count){ return true;}
		$dn_apply = ($count > $mig_applied_count) ? $mig_applied_count : $count;
		
		arsort($mig_dn_files, SORT_NUMERIC); // reverse
		foreach ($mig_applied as $migID=>$mig_applied_row) {
			if ($dn_apply) {
				$dn_file = $mig_applied_row['mig_DN_SCRIPT'] . '.sql';
				$dn_file_ts = self::getTS($dn_file);
				if (!array_key_exist($dn_file_ts, $mig_dn_files)) {
					echo 'Down mig not found: ' . $mig_file . PHP_EOL;
					return false;
				}
				//echo "execute: $mig_dn_file \n";
				if (!self::exec_file($mig_dn_files[$dn_file_ts])) {
					return false;
				}               
				//-- Update migration table.
				$cmd = "DELETE FROM migrations WHERE mig_ID=$migID";
				if (!self::mysqli->query($cmd)) {
					return false;
				}
			}
			$dn_apply--;
		}
		return true;
	}
}
?>
