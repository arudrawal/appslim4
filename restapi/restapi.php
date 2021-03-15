<?php
require_once __DIR__ . "/../vendor/autoload.php";

//use Psr\Http\Message\ResponseInterface as Response;
//use Psr\Http\Message\RequestInterrface as Request;
use DI\Container;
use Slim\Psr7\Request as Request;
use Slim\Psr7\Response as Response;
use Slim\Factory\AppFactory;

$container = new Container();

AppFactory::setContainer($container);

$app = AppFactory::create();

$app->addRoutingMiddleware();

$errorMiddleware = $app->addErrorMiddleware(true, true, true);

# Routes
$app->get('/appslim4/restapi/hello', \App\Controllers\HomeController::class . ':hello')->setName('hello');
$app->get('/appslim4/restapi/bye', \App\Controllers\HomeController::class . ':bye')->setName('bye');
