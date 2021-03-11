<?php

session_start();

require_once __DIR__ . "/../vendor/autoload.php";

//use Psr\Http\Message\ResponseInterface as Response;
//use Psr\Http\Message\RequestInterrface as Request;
use Slim\Psr7\Request as Request;
use Slim\Psr7\Response as Response;
use Slim\Factory\AppFactory;
use DI\Container;

$container = new Container();

AppFactory::setContainer($container);

$app = AppFactory::create();
$app->addRoutingMiddleware();
$errorMiddleware = $app->addErrorMiddleware(true, true, true);

# Routes
require "../app/routes.php";

