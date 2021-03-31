Change Main Clock
=================

.. toctree::
    :hidden:
    :titlesonly:

This page will describe the process to configure the main clock of the Disco L475 IOT1 in Zephyr

Software
*****************

* STM32CubeMX, this is simply used to find the required parameters, this can be done with the datasheet but I was too lazy
* Zephyr, duh

Process
*******

#. Open STM32CubeMX and create a new project for the STM32L475VG
#. Click into the ``Clock Configuration`` tab, it should look as follows

    .. image:: /_static/disco_l475_iot1/change_freq_1.png
        :width: 100%

#. Change the parameters until you have your desired frequency (using HSI through PLL), for example to get a 64 MHz clock you would have the following Configuration

    .. image:: /_static/disco_l475_iot1/change_freq_2.png
        :width: 100%

#. Take note of the PLLM, PLLN, PLL/R, PLL/Q and PLL/P parameters which you setup to get the desired clock
#. Update your projects ``prj.conf`` to contain the following

    .. code-block::

        CONFIG_SYS_CLOCK_HW_CYCLES_PER_SEC=<CLOCK IN HZ>

        CONFIG_CLOCK_STM32_PLL_M_DIVISOR=<PLLM>
        CONFIG_CLOCK_STM32_PLL_N_MULTIPLIER=<PLLN>
        CONFIG_CLOCK_STM32_PLL_P_DIVISOR=<PLL/P>
        CONFIG_CLOCK_STM32_PLL_Q_DIVISOR=<PLL/Q>
        CONFIG_CLOCK_STM32_PLL_R_DIVISOR=<PLL/R>

    For example for 64 MHz you would have

    .. code-block::

        CONFIG_SYS_CLOCK_HW_CYCLES_PER_SEC=64000000

        CONFIG_CLOCK_STM32_PLL_M_DIVISOR=1
        CONFIG_CLOCK_STM32_PLL_N_MULTIPLIER=8
        CONFIG_CLOCK_STM32_PLL_P_DIVISOR=7
        CONFIG_CLOCK_STM32_PLL_Q_DIVISOR=2
        CONFIG_CLOCK_STM32_PLL_R_DIVISOR=2