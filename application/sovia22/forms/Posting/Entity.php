<?php
/**
 * Date: 30.08.11
 * Time: 1:54
 */
 
class Form_Posting_Entity extends Form_Posting
{
    public function setEntry(Posting_Row $entry)
    {
        $this->getElement('title')->setValue($entry->getTitle());
        $this->getElement('body')->setValue($entry->getBody());
        $this->getElement('avatar')->setValue($entry->getAvatarId());
    }
}
