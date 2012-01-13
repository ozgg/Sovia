<?php
/**
 * Date: 28.08.11
 * Time: 14:45
 */

/**
 * Пользователь сайта
 */
class User_Row extends Ext_Db_Table_Row implements User_Interface
{
    /**
     * Задать новый пароль
     *
     * @param string $password
     * @return User_Row
     */
    public function setPassword($password)
    {
        $salt = $this->_makeSalt();
        $this->salt = $salt;
        $this->password = md5($salt . $password);

        return $this;
    }

    /**
     * Обновить время последнего входа
     *
     * @return User_Row
     */
    public function login()
    {
        $this->last_seen = new Zend_Db_Expr('now()');
        return $this;
    }


    /**
     * Сгенерировать соль
     * 
     * @return string
     */
    protected function _makeSalt()
    {
        $salt = '';
        $length   = rand(5, 15);
        $alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
        $symbols  = '1234567890-=~!@#$%^&*()_+|[]{};:,.<>?/';
        $alphaLength = strlen($alphabet) - 1;
        $symbolsLength = strlen($symbols) - 1;
        for ($i = 0; $i < $length; $i++) {
            if (rand(0, 1)) {
                $salt .= $alphabet[rand(0, $alphaLength)];
            } else {
                $salt .= $symbols[rand(0, $symbolsLength)];
            }
        }

        return $salt;
    }

    /**
     * Задать ip-адрес
     *
     * @return User_Row
     */
    public function setIp()
    {
        $this->remote_addr = ip2long(self::$_ip);

        return $this;
    }

    /**
     * Получить ip-адрес
     * 
     * @return string
     */
    public function getRemoteAddr()
    {
        return long2ip($this->remote_addr);
    }

    /**
     * Создать ключ
     *
     * @param int $typeId тип ключа (@see User_Key)
     * @return User_Key_Row
     */
    public function createKey($typeId)
    {
        $data = array(
            'user_id' => $this->getId(),
            'type_id' => $typeId,
        );
        $keyTable = new User_Key();
        /** @var $key User_Key_Row */
        $key = $keyTable->createRow($data);
        $key->generate();
        $key->save();

        return $key;
    }

    public function getEmail()
    {
        return $this->email;
    }

    public function getLogin()
    {
        return $this->login;
    }

    /**
     * Добавить запись в блог
     *
     * @param array $data
     * @return Blog_Entry_Row
     */
    public function createBlogEntry(array $data)
    {
        $table = new Blog_Entry();
        $entryData = array(
            'user_id'  => $this->getId(),
        );
        /** @var $entry Blog_Entry_Row */
        $entry = $table->createRow($entryData);
        $entry->setData($data)->save();
        return $entry;
    }

    public function setAllowMail($allowMail)
    {
        settype($allowMail, 'int');
        if ($allowMail != 0) {
            $allowMail = 1;
        }
        $this->allow_mail = $allowMail;
        return $this;
    }

    public function getDefaultAvatar()
    {
//        $profile = $this->getProfile();
//        $avatar  = $profile->getDefaultAvatar();
//        unset($profile);
//        return $avatar;
    }










    public function getRoles($raw = false)
    {
        $roles    = array();
        $hasRoles = $this->getMapper()->getRoles($this->getId());
        if ($raw) {
            $roles = $hasRoles;
        } else {
            foreach ($hasRoles as $roleName => $isPresent) {
                if ($isPresent) {
                    $roles[] = $roleName;
                }
            }
            unset($roleName, $isPresent);
        }
        unset($hasRoles);
        return $roles;
    }

    public function addRole($name)
    {
        return $this->getMapper()->addRole($this->getId(), $name);
    }

    public function revokeRole($name)
    {
        if ($this->getId() == 1) {
            throw new Exception('У этого пользователя нельзя убирать роли');
        }
        return $this->getMapper()->revokeRole($this->getId(), $name);
    }

    public function checkPair($login, $password)
    {
        return $this->getMapper()->checkPair($login, $password);
    }

    public function setSession($userId, $remoteAddr)
    {
        $addressPattern = '/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/';
        if (!is_numeric($remoteAddr)) {
            if (preg_match($addressPattern, $remoteAddr)) {
                $remoteAddr = ip2long($remoteAddr);
            } else {
                $remoteAddr = 0;
            }
        }
        unset($addressPattern);
        return $this->getMapper()->setSession($userId, $remoteAddr);
    }

    public function checkSession($userId, $key)
    {
        return $this->getMapper()->checkSession($userId, $key);
    }

    public function search($login)
    {
        return $this->getMapper()->search($login);
    }

    public function see()
    {
        return $this->getMapper()->see($this->getId());
    }

    public function getActivity()
    {
        return $this->getMapper()->getActivity();
    }

    public function mailIsOk()
    {
        $result = true;
        return $result;
    }

    public function resetPassword()
    {
        $password = '';
        $alphabet = 'qwertyuiopasdfghjklzxcvbnm1234567890';
        $length   = strlen($alphabet) - 1;
        $size     = rand(8, 10);
        for ($i = 0; $i < $size; $i++) {
            $offset    = rand(0, $length);
            $password .= $alphabet[$offset];
            unset($offset);
        }
        unset($i, $alphabet, $length, $size);
        $this->setNewPassword($password);
        $this->save();
        return $password;
    }

}
