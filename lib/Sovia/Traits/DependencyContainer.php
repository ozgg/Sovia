<?php
/**
 * Trait for DI container
 * 
 * @author Maxim Khan-Magomedov <maxim.km@gmail.com>
 * @package Sovia\Traits
 */

namespace Sovia\Traits;

use Sovia\Container;

/**
 * Trait for dependency container
 */
trait DependencyContainer
{
    /**
     * Container
     *
     * @var Container
     */
    protected $dependencyContainer;

    /**
     * Get container
     *
     * @return \Sovia\Container
     */
    public function getDependencyContainer()
    {
        return $this->dependencyContainer;
    }

    /**
     * Set container
     *
     * @param \Sovia\Container $dependencyContainer
     * @return DependencyContainer
     */
    public function setDependencyContainer(Container $dependencyContainer)
    {
        $this->dependencyContainer = $dependencyContainer;

        return $this;
    }

    /**
     * Inject dependency into container
     *
     * @param string $name
     * @param mixed $element
     */
    protected function injectDependency($name, $element)
    {
        $this->checkContainerState();
        $this->dependencyContainer->inject($name, $element);
    }

    /**
     * Extract dependency from container
     *
     * @param string $name
     * @return mixed|null
     */
    protected function extractDependency($name)
    {
        $this->checkContainerState();

        return $this->dependencyContainer->extract($name);
    }

    /**
     * Check if container is set
     *
     * @throws \Exception
     */
    protected function checkContainerState()
    {
        if (!$this->dependencyContainer instanceof Container) {
            throw new \Exception('Container is not set');
        }
    }

    /**
     * Require dependencies to be injected
     *
     * @throws \ErrorException
     */
    protected function requireDependencies()
    {
        if (!$this->dependencyContainer instanceof Container) {
            throw new \ErrorException('Invalid dependency container');
        }
        $injected    = $this->dependencyContainer->getKeys();
        $notInjected = [];
        foreach (func_get_args() as $argument) {
            if (is_array($argument)) {
                call_user_func_array(__METHOD__, $argument);
            } else {
                if (!in_array($argument, $injected)) {
                    $notInjected[] = $argument;
                }
            }
        }

        if (!empty($notInjected)) {
            $error = 'Required dependencies are not injected: '
                . implode(', ', $notInjected);
            throw new \ErrorException($error);
        }
    }
}
