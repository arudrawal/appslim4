<?php
namespace App\Controllers;

use Slim\Psr7\Request as Request;
use Slim\Psr7\Response as Response;
use App\Controllers\Controller;

class HomeController extends Controller {
	public function hello(Request $request, Response $response, $args): Response
	{
		$response->getBody()->write('Hello World!');
		return $response;
	}
	public function bye(Request $request, Response $response, $args): Response
	{
		$response->getBody()->write('Bye Bye World!');
		return $response;
	}
}
