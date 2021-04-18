<?php
    ini_set('display_errors', 1);
    ini_set('display_startup_errors', 1);
    error_reporting(E_ALL);
    
    function return_bytes($val) {
        $numval = substr($val, 0, -1);
        $last = strtolower($val[strlen($val)-1]);
        switch($last) {
            case 'g':
                $numval *= 1024; // no break;
            case 'm':
                $numval *= 1024; // no break;
            case 'k':
                $numval *= 1024;
        }
        return $numval;
    }
    $cur_limit = return_bytes(ini_get('memory_limit'));
    $desired_limit = return_bytes('128M');
    if ($cur_limit < $desired_limit){
        ini_set('memory_limit', '128M');
    }
    
    //-- Invoke migrate from the proper directory 
    require_once(__DIR__.'/../constants.php');
    require_once(DIR_HRFH . '/protected/database/migrate.php');
?>
