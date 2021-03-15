<?php
namespace App\Controllers;

use DI\Container as Container;
use Slim\Psr7\Request as Request;
use Slim\Psr7\Response as Response;
class Controller {
	protected $cont;
	
	public function __construct(Container $cont) {
		$this->cont = $cont;
	}
	public function __get($property) {
		$prop = $this->cont->get($property);
		return $prop ? $prop : null;
	}
}
?>
