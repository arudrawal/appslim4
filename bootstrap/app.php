<?php

session_start();

require_once __DIR__ . "/../vendor/autoload.php";

//use Psr\Http\Message\ResponseInterface as Response;
//use Psr\Http\Message\RequestInterrface as Request;
use DI\Container;
use Slim\Psr7\Request as Request;
use Slim\Psr7\Response as Response;
use Slim\Factory\AppFactory;
use Slim\Views\Twig;
use Slim\Views\TwigMiddleware;

$container = new Container();

AppFactory::setContainer($container);

$container->set('view', function(){
	return Twig::create(__DIR__.'/../views/', ['cache'=> '']);
});
$app = AppFactory::create();
$app->add(TwigMiddleware::createFromContainer($app));

$app->addRoutingMiddleware();
$errorMiddleware = $app->addErrorMiddleware(true, true, true);

# Routes
require "../app/routes.php";

