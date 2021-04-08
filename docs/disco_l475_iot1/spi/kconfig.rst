*******
KConfig
*******

.. toctree::
    :hidden:
    :titlesonly:

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