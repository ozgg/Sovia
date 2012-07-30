<?php
/**
 * Date: 14.01.12
 * Time: 13:59
 *
 * @author Maxim Khan-Magomedov <maxim.km@gmail.com>
 */

class Posting_Tag_Row extends Ext_Db_Table_Row
{
    public function getName()
    {
        return $this->get('name');
    }

    public function getWeight()
    {
        return $this->get('weight');
    }

    public function getType()
    {
        return $this->get('type_id');
    }
}
