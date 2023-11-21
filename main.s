.data
buf1:    .space BUF_SIZE     # Буфер для первой строки
buf2:    .space BUF_SIZE     # Буфер для второй строки
mes:   .asciz "Введите ваше ключевое слово"
.macro slice %start %finish %result      # Срез строки. start - индекс начала, finish - индекс конца, result - срез.строка.

.end_macro
.text
strcmp:
loop:
    lb      t0 (a0)     # Загрузка символа из 1-й строки для сравнения
    lb      t1 (a1)     # Загрузка символа из 2-й строки для сравнения
    beqz    t0 end      # Конец строки 1
    beqz    t1 end      # Конец строки 2
    bne     t0 t1 end   # Выход по неравенству
    addi    a0 a0 1     # Адрес символа в строке 1 увеличивается на 1
    addi    a1 a1 1     # Адрес символа в строке 2 увеличивается на 1
    b       loop
end:
    sub     a0 t0 t1    # Получение разности между символами
    ret

.globl main
main:
    # Ввод строки 1 в буфер
    la      a0 mes
    la      a1 buf1
    li      a2 BUF_SIZE
    li      a7 54
    ecall
    # Ввод строки 2 в буфер
    la      a0 mes
    la      a1 buf2
    li      a3 BUF_SIZE
    li      a7 54
    ecall
    # Сравнение строк в буферах
    la      a0 buf1
    la      a1 buf2
    jal     strcmp
    # Вывод результата сравнения
    li      a7 1
    ecall
    li a7 10
    ecall
