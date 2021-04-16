<?php
class DbCommand {
	protected $dbcon = null;
	
	public function checkForceError() {
		if (PHP_SAPI != 'cli') {
			die('Can only be executed from CLI');
		}
		$dbserver = getenv('DB_SERVER');
		if (getenv('PRODUCTION')) {
			die("CANT RUN ON PRODUCTION ENVIRONMENT: $dbserver\n");
		}
		if (0 != strcmp($dbserver, 'localhost')) {
		   if (FALSE == is_private_ipv4($dbserver)) {
				die("CANT RUN ON PUBLIC IP4: $dbserver\n");
		   } else {
				echo "DB SERVER PRIVATE IP4 : $dbserver\n";
		   }
		}
	}
	public function displayEnv() {
		return getenv('PRODUCTION') ? 'Production' : 'Development';
	}
	public function getDbcon($dbname=null) {
		if (!$this->dbcon) {
			$dbserver = getenv('DB_SERVER');
			//$dbname = getenv('DB_NAME');
			try {
				$this->dbcon = new mysqli($dbserver, getenv('DB_USER'), getenv('DB_PASS'),$dbname);
			} catch (Exception $e) {
				//if ($dbcon->connect_error) {
					die("DB Connection failed: " . $e->getMessage());
				//}
			}
		}
		return $this->dbcon;
	}
	public function query($cmd) {
		$conn = $dbc->getDbcon();
		if ($conn) {
			if ($conn->select_db(getenv('DB_NAME'))) {
				return $conn->query($cmd);
			}
		}
		return false;
	}
	public function isPrivateIPv4($ip) {
		$pri_addrs = array(
						  '10.0.0.0|10.255.255.255',
						  '172.16.0.0|172.31.255.255',
						  '192.168.0.0|192.168.255.255',
						  '169.254.0.0|169.254.255.255',
						  '127.0.0.0|127.255.255.255'
						 );
		$long_ip = ip2long($ip);
		if($long_ip != -1) {
			foreach($pri_addrs AS $pri_addr)
			{
				list($start, $end) = explode('|', $pri_addr);
				 // IF IS PRIVATE
				 if($long_ip >= ip2long($start) && $long_ip <= ip2long($end))
				 return (TRUE);
			}
		}
		return (FALSE);
	}
	// Prompt user to enter some answer
	function promptUser($message) {
		echo $message;
		$handle = fopen ("php://stdin","r");
		return trim(fgets($handle));
	}
}
?>
