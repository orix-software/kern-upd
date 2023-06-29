.export str_programming_shell
.export str_programming_basic
.export str_programming_kernel
.export str_programming_kernel_reserved

.export tab_str_low
.export tab_str_high

str_programming_shell:
    .asciiz "Programming shell ..."
str_programming_basic:
    .asciiz "Programming Basic ..."
str_programming_kernel:
    .asciiz "Programming Kernel ..."
str_programming_kernel_reserved:
    .asciiz "Programming Kernel reserved..."

tab_str_low:
    .byt <str_programming_shell
    .byt <str_programming_basic
    .byt <str_programming_kernel
    .byt <str_programming_kernel_reserved

tab_str_high:
    .byt >str_programming_shell
    .byt >str_programming_basic
    .byt >str_programming_kernel
    .byt >str_programming_kernel_reserved
