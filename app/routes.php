<?php

require_once __DIR__ . "/../vendor/autoload.php";

use Slim\Psr7\Request as Request;
use Slim\Psr7\Response as Response;

$app->get('/appslim4/public/hello', \App\Controllers\HomeController::class . ':hello');
$app->get('/appslim4/public/bye', \App\Controllers\HomeController::class . ':bye');
