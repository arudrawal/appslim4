<?php
namespace App\Controllers;

use DI\Container as Container;
use Slim\Psr7\Request as Request;
use Slim\Psr7\Response as Response;
class Controller {
	protected $container;
	
	public function __construct(Container $cont) {
		$this->container = $cont;
	}
	public function __get($property) {
		if ($this->contianer->{$property}) {
			return $this->container->{$property};
		}
	}
}
?>
