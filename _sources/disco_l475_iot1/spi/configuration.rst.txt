*************
Configuration
*************

.. toctree::
    :hidden:
    :titlesonly:

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
