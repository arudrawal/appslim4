<?php

require_once __DIR__ . "/../vendor/autoload.php";

use Slim\Psr7\Request as Request;
use Slim\Psr7\Response as Response;
// this should lead to login if use is not logged in, else redirect to user home.
$app->get('/appslim4/public/', \App\Controllers\HomeController::class . ':root')->setName('root');

$app->get('/appslim4/public/hello', \App\Controllers\HomeController::class . ':hello')->setName('hello');
$app->get('/appslim4/public/bye', \App\Controllers\HomeController::class . ':bye')->setName('bye');
