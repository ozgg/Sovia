<?php
/**
 * 
 * 
 * Date: 10.06.13
 * Time: 23:08
 *
 * @author Maxim Khan-Magomedov <maxim.km@gmail.com>
 */

namespace Web\Controllers;
 
use Atom\Http\Controller;
use Atom\Http\Error;

class ErrorController extends Controller
{
    public function errorAction()
    {
        $error = $this->getRoute()->getParameter('error');
        if ($error instanceof Http) {
            $this->setParameter('message', $error->getMessage());
            $this->setParameter('trace', $error->getTraceAsString());
            $this->setStatus($error->getStatus());
        } else {
            $this->setParameter('message', 'Error');
            $this->setParameter('trace', []);
        }
        $this->setParameter('is_development', $this->isDevelopment());
        $this->setParameter('error', $error);
    }
}
