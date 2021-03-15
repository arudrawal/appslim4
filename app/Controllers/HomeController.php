<?php
namespace App\Controllers;

use DI\Container as Container;
use Slim\Psr7\Request as Request;
use Slim\Psr7\Response as Response;
use App\Controllers\Controller;

class HomeController extends Controller {
	public function __construct(Container $cont) {
		parent::__construct($cont);
	}	
	
	public function hello(Request $request, Response $response, $args): Response
	{
		$version = $this->pdo->query('select VERSION()')->fetch();
		$response->getBody()->write('Hello World!');
		$response->getBody()->write(json_encode($version));
		return $response;
	}
	public function bye(Request $request, Response $response, $args): Response
	{
		$result = $this->mysqli->query('select VERSION()');
		if ($result) {
			$row = $result->fetch_row();
			$response->getBody()->write(json_encode($row));
		}
		$response->getBody()->write('Bye Bye World!');
		return $response;
	}
}
