<?php
/**
 * Verify db information from environment setup.
 */
require_once(__DIR__.'/../env/env.php');
require_once(__DIR__.'/inc/DbCommand.php');
  $dbc = new DbCommand();
  $dbserver = getenv('DB_SERVER');
  $dbname = getenv('DB_NAME');
  $isValidIpv4 = filter_var($dbserver, FILTER_VALIDATE_IP, FILTER_FLAG_IPV4);
  if (0 == strcmp($dbserver, 'localhost')){
      echo "DB SERVER: $dbname@$dbserver\n";
  } elseif ($isValidIpv4){//(inet_pton(DB_SERVER)) { // 192.168.0.1
    if (FALSE == $dbc->isPrivateIPv4($dbserver)){
      echo "DB POINTING TO PUBLIC IP4: $dbname@$dbserver\n";
    } else {
      echo "DB SERVER (PRIVATE IPv4): $dbname@$dbserver\n";
    }
  } else { // www.hrfhportal.com
    $ip = gethostbyname($dbserver);
    if (FALSE == $dbc->isPrivateIPv4($ip)){
      echo "DB POINTING TO PUBLIC IP4: $dbname@$ip[$dbserver]";
    } else {
      echo "DB SERVER (PRIVATE IPv4): $dbname@$ip[$dbserver]";
    }
  }
?>
