<?php

require_once(__DIR__.'/MysqlParser.php');


class Migration {
	const DATE_FROMAT = 'Y_m_d_His';
	const DS = DIRECTORY_SEPARATOR;
	protected $mysqli = null;
	protected $mig_dir = __DIR__.self::DS.'..'.self::DS.'schema';
	protected $mig_dir_up =__DIR__.self::DS.'..'.self::DS.'schema'.self::DS.'up';
	protected $mig_dir_dn =__DIR__.self::DS.'..'.self::DS.'schema'.self::DS.'dn';
	
	function __construct($conn, $dir=null) {
		$this->mysqli = $conn;
		if ($dir) {
			$this->mig_dir = $dir;
			$this->mig_dir_up = $dir. self::DS . 'up' . self::DS;
			$this->mig_dir_dn = $dir. self::DS .'dn' . self::DS;
		}
	}
    //protected function getUp
	
	//-- Return timestamp for a given script name
	//-- $script_name: 2016_06_12_170149_event_log.sql
    protected function getTS($script_name) {
        $timestamp = FALSE;
		$tz = new DateTimeZone("UTC");//::UTC;  
		$path_parts = pathinfo($script_name);
        $dateArray = explode('_', $path_parts['basename']);
        if (count($dateArray) >= 3) { // time: His (default: midnight)
			$dateStr = $dateArray[0] . '_' . $dateArray[1].'_'. $dateArray[2] . '_';
			$dateStr .= ((count($dateArray) >= 4) ? $dateArray[3] : '000000');
			$dateTimeObject = DateTime::createFromFormat(self::DATE_FROMAT, $dateStr, $tz);
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
        $mig_files = glob($mig_dir.'*.{sql}', GLOB_BRACE);
        $mig_indexed = array();
        foreach ($mig_files as $idx=>$filename) {
            $timestamp = $this->getTS($filename);
            if ($timestamp) {
                $mig_indexed[$timestamp] = $filename;
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
				$sqlContent = file_get_contents($src_file);
				$parser = new MySqlparser;
				$sqls = $parser->getSqlQueries($sqlContent); // individual queries
				foreach ($sqls as $sql) {
					$sql = trim($sql); // skip empty lines
					if ($sql) {
						$ret = $this->mysqli->query($sql);
						if (!$ret) {
							echo "$src_file: Failed query:\n$sql\n";
							echo $this->mysqli->error . PHP_EOL;
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
			if (!$this->exec_file($file)) {
				return false;
			}
		}
		return true;
	}
	// Indexed by mig_ID: in ascending order
	protected function getMigsByID() {
		$migs_applied = array();
        $cmd = 'SELECT * FROM migrations ORDER BY mig_ID ASC';
        $result = $this->mysqli->query($cmd);
        if ($result) {
			//var_dump($result);die();
			while ($row = $result->fetch_assoc()) {
				$migs_applied[$row['mig_ID']] = $row;//['mig_UP_SCRIPT'];
			}
		}
		return $migs_applied;
	}
	// Indexed by TS
	protected function getMigsByTS() {
		$migs_applied = array();
        $cmd = 'SELECT * FROM migrations ORDER BY mig_ID ASC';
        $result = $this->mysqli->query($cmd);
        if ($result) {
			while ($row = $result->fetch_assoc()) {
				$ts = $this->getTS($row['mig_UP_SCRIPT']);
				$migs_applied[$ts] = $row;//['mig_UP_SCRIPT'];
			}
		}
		return $migs_applied;
	}
	// migrate up: 0=ALL
	public function up($count=0) {
		$mig_up_files = $this->sortedFilesIndexed($this->mig_dir_up);
		$mig_dn_files = $this->sortedFilesIndexed($this->mig_dir_dn);
		$mig_applied = $this->getMigsByID(); // indexed by mig_ID
		
		$ts_last_mig_applied = 0;
		if (count($mig_applied)) {
			$row = $mig_applied[array_key_last($mig_applied)];
			$ts_last_mig_applied = $this->getTS($row['mig_UP_SCRIPT']);
		}
		$retval = true;
		if (count($mig_applied) < count($mig_up_files)) {
			$up_count = 0;
			foreach ($mig_up_files as $file_ts=>$mig_up_file) {
				if ($file_ts > $ts_last_mig_applied) {
					if (0 == $count || // unlimited ups
						$up_count < $count) { // fix number of ups
						if (!array_key_exists($file_ts, $mig_dn_files)) {
							echo 'Down mig not found for: ' . $mig_file . PHP_EOL;
							$retval = false;
							break;
						}
						//echo "execute: $mig_up_file \n";
						if (!$this->exec_file($mig_up_file)) {
							$retval = false;
							break;
						}               
						//-- Update migration table.
						$cmd = "INSERT INTO migrations ".
								"(`mig_ID`, `mig_UP_SCRIPT`, `mig_DN_SCRIPT`)".
								" VALUES (NULL,'" . 
								basename($mig_up_file) . "','" . 
								basename($mig_dn_files[$file_ts]) . "')";
						if (!$this->mysqli->query($cmd)) {
							$retval = false;
							break;
						}
					}
				}
				$up_count++;
			}
		}
		if (!$retval) { // perform rollback
		
		}
		return $retval;
	}
	// migrate down:
	public function dn($count=1) {
		$mig_dn_files = $this->sortedFilesIndexed($this->mig_dir_dn);
		$mig_applied = $this->getMigsByID(); // indexed by mig_ID
		$mig_applied_count = count($mig_applied);
		if (0 == $mig_applied_count){ return true;}
		$dn_apply = ($count > $mig_applied_count) ? $mig_applied_count : $count;
		
		arsort($mig_applied, SORT_NUMERIC); // reverse
		foreach ($mig_applied as $migID=>$mig_applied_row) {
			if ($dn_apply) {
				$dn_file = $mig_applied_row['mig_DN_SCRIPT'];
				$dn_file_ts = $this->getTS($dn_file);
				if (!array_key_exists($dn_file_ts, $mig_dn_files)) {
					echo 'Down mig not found: ' . $mig_file . PHP_EOL;
					return false;
				}
				//echo "execute: $mig_dn_file \n";
				if (!$this->exec_file($mig_dn_files[$dn_file_ts])) {
					return false;
				}               
				//-- Update migration table.
				$cmd = "DELETE FROM migrations WHERE mig_ID=$migID";
				if (!$this->mysqli->query($cmd)) {
					return false;
				}
			}
			$dn_apply--;
		}
		return true;
	}
	public function display_mig() {
		$out = '';
		$mig_up_files = $this->sortedFilesIndexed($this->mig_dir . '/up');
		$mig_dn_files = $this->sortedFilesIndexed($this->mig_dir . '/dn');
		$mig_applied = $this->getMigsByTS();
		$max_fname_len_applied = 0;
		foreach ($mig_applied as $ts => $row) {
			$len = strlen($mig_applied_row['mig_UP_SCRIPT']);
			$max_fname_len_applied = max($max_fname_len_applied, $len);
		}
		$applied_format = '%'.$max_fname_len_applied.'s';
		foreach ($mig_applied as $ts => $row) {
			$out .= sprintf($applied_format, $mig_applied_row['mig_UP_SCRIPT']);
			if (array_key_exist($ts, $mig_up_files)) {
				$out .= '<<==>>' . $mig_up_files[$ts] . '\n';
				unset($mig_up_files[$ts]);
			}
		}
		// To be applied
		$out .= '\n\nTo be applied:';
		foreach ($mig_up_files as $ts => $filename) {
			$out .= sprintf($applied_format, $filename);
		}
		return $out;
	}
	
	public function createMigTable() {
		$cmd = 'CREATE TABLE IF NOT EXISTS `migrations` ('.
			'`mig_ID` int(10) unsigned NOT NULL AUTO_INCREMENT,'.
			'`mig_UP_SCRIPT` varchar(256) NOT NULL DEFAULT \'\','.
			'`mig_DN_SCRIPT` varchar(256) NOT NULL DEFAULT \'\','.
			'PRIMARY KEY (`mig_ID`));';
		return $this->mysqli->query($cmd);
	}
	public function createMigfiles($append) {
        $mig_fname = gmdate(self::DATE_FROMAT, time());
		if (strlen(trim($append))) {$mig_fname .= '_'. $append;}
		$mig_fname .= '.sql';
		
        $mig_fname_up = $this->mig_dir_up . $mig_fname;
        $mig_fname_dn = $this->mig_dir_dn . $mig_fname;

		$fd_up = fopen($mig_fname_up, "w");
        if (!$fd_up) {return false;}
        fwrite($fd_up, "-- Up migration sql\n");
		fwrite($fd_up, "BEGIN TRANSACTION;\n\n\n");
		fwrite($fd_up, "COMMIT;\n");
        fclose($fd_up);
		
		$fd_dn = fopen($mig_fname_dn, "w");
        if (!$fd_dn) {return false;}
        fwrite($fd_dn, "-- Dn migration sql\n");
		fwrite($fd_dn, "BEGIN TRANSACTION;\n\n\n");
		fwrite($fd_dn, "COMMIT;\n");
        fclose($fd_dn);
		
		return $mig_fname;
	}
}
?>
