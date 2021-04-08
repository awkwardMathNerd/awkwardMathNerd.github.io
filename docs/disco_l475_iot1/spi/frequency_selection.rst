*******************
Frequency Selection
*******************

.. toctree::
    :hidden:
    :titlesonly:

The clock for the STM32 SPI peripheral is provided by the main clock through a prescaler, this prescaler can have a value of 2, 4, 8, 16, 32, 64, 128 and 256.
You cannot directly set this prescaler in Zephyr, instead you are required to set the ``frequency`` field in your ``spi_config`` struct. 

The Zephyr driver then chooses the prescaler which gives the highest possible frequency that does not surpass your value. For example a value of 1 MHz in the
``frequency`` field, with an 80 MHz master clock, will cause a prescaler of 128 to be chosen which produces a clock of 625 kHz! Thus, care should be taken in 
trusting the ``frequency`` field since it can lead to pretty large mismatches in prescaled frequency.

For full details on the prescaler selection algorithm see ``spi_stm32_configure`` in ``zephyr/drivers/spi/spi_ll_stm32.c``.