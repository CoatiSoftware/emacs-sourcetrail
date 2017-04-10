emacs-sourcetrail
===========

emacs-sourcetrail is a plugin for Emacs to communicate with SoureTrail_.

.. _SoureTrail: https://sourcetrail.io

Install
-------

Usage
-----

From SoureTrail to Emacs
~~~~~~~~~~~~~~~~~~~

* enable sourcetrail-mode in Emacs
* Right click in sourcetrail -> **Set IDE Curor**
* In the Emacs should now open the file and put the cursor in the position form sourcetrail.

From Emacs to SoureTrail
~~~~~~~~~~~~~~~~~~~

* Navigate your cursor to the location in the text.
* Sent location to sourcetrail

  + Press **M-x** and enter **sourcetrail-send-loation**
  + bind **sourcetrail-send-location** to a key sequence and use it.

Preferences
-----------

* **M-x** customize
* search for sourcetrail
* 3 Settings should be displayed now

Emacs SoureTrail Ip
~~~~~~~~~~~~~~

Ip address for the Tcp communcation, default is ``localhost``

Emacs SoureTrail Port SoureTrail
~~~~~~~~~~~~~~~~~~~~~~

Port SoureTrail listens to, default is ``6667``

Emacs SoureTrail Port Emacs
~~~~~~~~~~~~~~~~~~~~~~

Port SoureTrail listens to, default is ``6666``

