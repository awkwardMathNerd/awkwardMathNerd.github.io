***
SPI
***

.. toctree::
    :hidden:
    :titlesonly:

This page will talk about the SPI Zephyr device driver (low level), this information *should* be valid for all STM32 boards since they use the same driver code.

KConfig Stuff
=============
Below is the KConfig configurations that I have encountered through developement with the STM32 SPI driver, these should go into your ``prj.conf`` file

.. glossary::

    CONFIG_SPI
        This is required to be set to enable any usage of the SPI drivers

    CONFIG_SPI_SLAVE
        This enables the SLAVE parts of the SPI driver, this is not necessarily needed if SLAVE is required. It may seem from the name that it is pivotal
        in performance of the driver, but the STM32 SPI driver as well as the generic context file ``spi_context.h`` only use it to return the number of
        bytes successfully transmitted/received. So if you don't need to know how much you sent/received you can ignore this config for THIS driver, but
        not necessarily other board drivers.

    CONFIG_SPI_STM32_USE_HW_SS
        This tells the STM32 to use the hardware NSS pin on chip (CS is handled in hardware), this is ENABLED by default. If possible the hardware NSS pin
        should be used in SLAVE mode, this is because it handles synchronization reasonably well, and if you unfortunately enable a 'software' CS pin using
        ``spi_config.cs`` the STM32 driver will automatically ignore this parameter and use that CS pin as if it were the bus MASTER (i.e. asserts and deasserts
        the CS line ACTIVELY) even if you have it in SLAVE mode, this could lead to the possibility of shorted between power rails if the actually MASTER ACTIVELY
        connects the CS pin to VCC and the STM32 connects it to GND.

    CONFIG_SPI_STM32_INTERRUPT
        This tells the driver to use the interrupt for SPI to send/receive data, this is ENABLED by default. This allows other threads to performs actions whilst
        the SPI peripheral is sending data, when this is disabled the call to send/receive data will block whilst waiting for transmition of data to conclude.

This is by no means a complete list/explanation of the KConfig defines for the STM32 SPI driver, others will be added here when encountered, they will not be
actively seeked out.

Configuration
=============
This section contains all the different configuration options you can use with the STM32 SPI interface through the ``spi_config.operation`` field

.. glossary::

    SPI_OP_MODE_MASTER
        Sets the operational mode to MASTER

    SPI_OP_MODE_SLAVE
        Sets the operational mode to SLAVE

    SPI_MODE_CPOL
        Sets the clock polarity. If this is selected then the SCK idle state will be 1 with its active state being 0. If this is not selected then
        the opposite will be true

    SPI_MODE_CPHA
        Sets the clock phase. IF :term:`SPI_MODE_CPOL` is selected then, if this mode is selected then capturing of the data will occur on LOW to HIGH
        transition, and if this mode and not selected then capturing occurs on a HIGH to LOW transition. If :term:`SPI_MODE_CPOL` is NOT selected then
        this behaviour is reversed.

    SPI_MODE_LOOP
        This mode is IGNORED by the STM32 driver (even though if logging is enabled ``CONFIG_LOG=y`` it will output that this option is set)

    SPI_TRANSFER_MSB
        This will make each word (8 or 16 bit) transmit with the MSBit first

    SPI_TRANSFER_LSB
        This will make each word (8 or 16 bit) transmit with the LSBit first

    SPI_WORD_SET(_word_size_)
        This macro can be used to set the word size that is transmitted. If 8 is chosen then 8 bits is used, any other value results in 16 bit words

    SPI_LINES_SINGLE
        To current knowledge this is not used by the  STM32 SPI driver, since there is a seperate QSPI driver. The SPI driver defaults to single line.

    SPI_LINES_DUAL
        See :term:`SPI_LINES_SINGLE`

    SPI_LINES_QUAD
        See :term:`SPI_LINES_SINGLE`

    SPI_LINES_OCTAL
        See :term:`SPI_LINES_SINGLE`

    SPI_HOLD_ON_CS
        To current knowledge when in MASTER this configuration will cause the CS pin to permanentaly remain asserted even with consecutive write/read operations
        because the STM32 SPI driver never calls ``spi_context_unlock_unconditionally``.

    SPI_LOCK_ON
        Only allows specific configuration structs to use the driver (in my opinion a fucking stupid option, and doesn't lend much to good programming practises)

    SPI_CS_ACTIVE_HIGH
        I honestly have nothing good to say about this useless fuck nuckle. If I have missed a useful piece of code in the driver for it, I don't apologise.
        I say this because it seems its only purpose is to check against the ``spi_cs_cntrl.gpio_dt_flags`` and make sure its the same (CS_ACTIVE_HIGH -> GPIO_ACTIVE_HIGH
        and vice versa) in an assert statement that does nothing unless you enable asserts. On top of this, the STM32 SPI driver completely ignores it, and if a CS pin is
        defined in the ``spi_config.cs`` then it forces the CS pin HIGH when operations are underway, and forces the CS pin LOW when operations are concluded (so just ignores
        the configuration completely), and heres the kicker the assertion of the CS line happens NO MATTER IF ITS IN SLAVE OR MASTER MODE, fucking useless thing. 

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