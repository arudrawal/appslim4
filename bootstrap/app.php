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
$server = "localhost";
$user = "root";
$password = "";
$dbname = "mydb";
// Database connection PDO
$dsn = "mysql:host=$server;dbname=$dbname;charset=utf8mb4";
$pdo_flags = [
	// Turn off persistent connections
	PDO::ATTR_PERSISTENT => false,
	// Enable exceptions
	PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
	// Emulate prepared statements
	PDO::ATTR_EMULATE_PREPARES => true,
	// Set default fetch mode to array
	PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
	// Set character set
	PDO::MYSQL_ATTR_INIT_COMMAND => 'SET NAMES utf8mb4 COLLATE utf8mb4_unicode_ci'
];
try {
	$dbcon_pdo = new PDO($dsn, 'root', '', $pdo_flags);
	$container->set('pdo', $dbcon_pdo);
} catch (PDOException $e) {
	die("DB Connection failed: " . $e->getMessage());
}	

// Database connection mysqli
$dbconn_mysqli = new mysqli($server, $user, $password, $dbname);
if ($dbconn_mysqli->connect_error) {
	die("DB Connection failed: " . $dbconn_mysqli->connect_error);
}
$container->set('mysqli', $dbconn_mysqli);

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

