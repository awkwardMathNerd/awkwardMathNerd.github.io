***
SPI
***

.. toctree::
    :hidden:
    :titlesonly:

This page will talk about the SPI Zephyr device driver (low level), this information *should* be valid for all STM32 boards since they use the same driver code.

Configuration
=============
This section contains all the different configuration options you can use with the STM32 SPI interface through the ``spi_config.operation`` field

.. glossary::

    SPI_OP_MODE_MASTER
        Sets the operational mode to MASTER

    SPI_OP_MODE_SLAVE
        Sets the operational mode to SLAVE

SPI_OP_MODE_MASTER
    STUFF

Frequency Selection
===================
The clock for the STM32 SPI peripheral is provided by the main clock through a prescaler, this prescaler can have a value of 2, 4, 8, 16, 32, 64, 128 and 256.
You cannot directly set this prescaler in Zephyr, instead you are required to set the ``frequency`` field in your ``spi_config`` struct. 

The Zephyr driver then chooses the prescaler which gives the highest possible frequency that does not surpass your value. For example a value of 750 kHz in the
``frequency`` field, with an 80 MHz master clock, will cause a prescaler of 128 to be chosen which produces a clock of 625 kHz! Thus, care should be taken in 
trusting the ``frequency`` field since it can lead to pretty large mismatches in prescaled frequency.

For full details on the prescaler selection algorithm see ``spi_stm32_configure`` in ``zephyr/drivers/spi/spi_ll_stm32.c``.

Slave Mode
==========
**STILL POPULATING**

KConfig Stuff
=============
**STILL POPULATING**

Return Codes
============
This part will discuss what the possible return codes actually mean (thanks for the lack of documentation ZEPHYR)

* -EIO (-5)
    This is just a general error code that the zephyr driver returns when anything wrong occurs with the SPI peripheral.
    To get the actual error code from the STM32 SPI peripheral you will need to enable logging ``CONFIG_LOG=y`` in your ``prj.conf`` file,
    this is since instead of returning the actual result zephyr feels the need to hide it, and log it instead.

    .. image:: //_static/disco_l475_iot1/spi_get_err.png
        :width: 50%
    
    This code snippet is found in ``zephyr/drivers/spi/spi_ll_stm32.c``. Once you get this value from the LOG output you will be able to
    compare it to the ``SR`` register definition for your STM32 device. For the STM32L475VG the ``SR`` registers contents are as follows

    .. image:: //_static/disco_l475_iot1/spi_sr_reg.png
        :width: 100%

    At the time of writing ``SPI_STM32_ERR_MSK`` for the STM32L475VG causes only ``FRE``, ``OVR``, ``MODF`` and ``CRCERR`` to be parsed,
    the translation between error code and cause can be seen in the following table, if a value is not in this table try combinations (bitwise-OR),
    if it is still not present then I don't know what to tell you, I ain't omnipitant.

    .. list-table:: STM32L475VG error codes
        :header-rows: 1

        * - Errorcode
          - Cause
        * - 0x0010 (16)
          - CRC error
        * - 0x0020 (32)
          - Mode fault (see page 1471 of reference manual)
        * - 0x0040 (64)
          - Overrun flag (i.e. you trying to send too much shit too fast)
        * - 0x0100 (256)
          - Frame format error (used only in TI slave mode)