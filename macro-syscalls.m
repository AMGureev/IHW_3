.macro error_message %str
la a0 %str
li a1 2
li a7 55
ecall
.end_macro

.macro count_word %bufer %result_bufer
    find_count %bufer t6
    int_to_str %result_bufer t6       # Вызов макроса
.end_macro

.macro check_null %bufer %result
.text
	la a6 %bufer
	jal strlen
	beqz a6 bad
	j okey
	bad:
	error_message error_m
	okey:
	mv %result a6
.end_macro

.macro again
	j start
	srtg:
	error_message error_m
	start:
	str_get(buf6, BUF_SIZE, mes_again)
	bnez a0 srtg
	li a1 'Y'
	la a2 buf6
	lb a3 (a2)
	beq a1 a3 main
	la a0 good_bye
    	li a1 1
    	li a7 55
    	ecall
.end_macro

.macro print_el %bufer %result_bufer
mv   a0, s0
li a7 64
la a1 %bufer 			# Адрес буфера записываемого текста
la a6 %bufer
jal strlen
mv a2 a6
ecall
mv   a0, s0
li   a7, 64
la     a1 space
li  a2 1
ecall
mv   a0, s0
li   a7, 64
la     a1 %result_bufer
la a6 %result_bufer
jal strlen
mv a2 a6
ecall
mv   a0, s0
li   a7, 64
la     a1 enter
li  a2 1
ecall
.end_macro

.macro print_to_file
print_el buf1 output_str_buf1
print_el buf2 output_str_buf2
print_el buf3 output_str_buf3
print_el buf4 output_str_buf4
print_el buf5 output_str_buf5
.end_macro

.macro int_to_str %dest %source
    mv      a0 %source           # Поместить целое число в регистр a0
    li      a1 10                # Десятичная система счисления
    la      a2 %dest             # Регистр для сохранения строки
    int_to_str_loop:
        remu    a3, a0, a1          # A3 = A0 % A1 (остаток от деления)
        addi    a3, a3, '0'          # Преобразовать остаток в ASCII
        push (a3)
        addi    a2 a2 1            # Перейти к следующему символу в строке
        divu    a0 a0 a1          # A0 = A0 / A1 (целая часть от деления)
        bnez    a0 int_to_str_loop  # Повторить цикл, если A0 не равно нулю
        mv a4 a2
        la a5 %dest
	reverse_int:
	pop(a3)
	sb      a3 0(a5)            # Сохранить ASCII-символ в строку
	addi    a5 a5 1            # Перейти к следующему символу в строке
    	ble    a5 a4 reverse_int
    	sb      zero 0(a5)          # Завершить строку нулевым символом
.end_macro

.macro find_count %word %result
	li t6 0 # счетчик ответов
	mv a6 s3
	jal strlen
	mv a1 a6
	la a6 %word
	jal strlen
	neg a6 a6
	add a5 a6 a1
	neg a6 a6
	mv a4 zero
	while:
	bgt a4 a5 end
	add a3 a6 a4
	slice s3 str_copy a4 a3 
	la      a0 %word
    	la      a1 str_copy
   	jal     strcmp
   	# Вывод результата сравнения
   	bnez a0 not_equal
	addi t6 t6 1
 	not_equal:
 	addi a4 a4 1
	j while 
	end:
	mv %result t6
.end_macro 

.macro slice %src %dest %start %finish      # Срез строки. start - индекс начала, finish - индекс конца
	mv a0 %start # копия старта.
	mv t0 %src
	la t1 %dest
	add t0 t0 a0
	loop:
	ble %finish a0 end
	lb t2 (t0)
	sb t2 (t1)
	beqz t2 end # Если наткнулись на ноль-символ, то прекратить копирование
	addi t0 t0 1 # Сдвигаемся по строке для копирования на 1 символ вперед
	addi t1 t1 1 # Сдвигаемся по строке-копии на 1 символ вперед
	addi a0 a0 1
	j loop
	end:
	sb zero (t1) 
.end_macro

#===============================================================================
# Библиотека макроопределений для системных вызовов
#===============================================================================

#-------------------------------------------------------------------------------
# Печать содержимого заданного регистра как целого
.macro print_int (%x)
	li a7, 1
	mv a0, %x
	ecall
.end_macro
#-------------------------------------------------------------------------------
# Печать непосредственного целочисленного значения
.macro print_imm_int (%x)
	li a7, 1
   	li a0, %x
   	ecall
.end_macro

#-------------------------------------------------------------------------------
# Печать строковой константы, ограниченной нулевым символом
.macro print_str (%x)
   .data
str:
   .asciz %x
   .text
   push (a0)
   li a7, 4
   la a0, str
   ecall
   pop	(a0)
.end_macro

#-------------------------------------------------------------------------------
# Печать отдельного заданного символа
.macro print_char(%x)
   li a7, 11
   li a0, %x
   ecall
.end_macro

#-------------------------------------------------------------------------------
# Печать перевода строки
.macro newline
   print_char('\n')
.end_macro

#-------------------------------------------------------------------------------
# Ввод целого числа с консоли в регистр a0
.macro read_int_a0
   li a7, 5
   ecall
.end_macro

#-------------------------------------------------------------------------------
# Ввод целого числа с консоли в указанный регистр, исключая регистр a0
.macro read_int(%x)
   push	(a0)
   li a7, 5
   ecall
   mv %x, a0
   pop	(a0)
.end_macro

#-------------------------------------------------------------------------------
# Ввод строки в буфер заданного размера с заменой перевода строки нулем
# %strbuf - адрес буфера
# %size - целая константа, ограничивающая размер вводимой строки
.macro str_get(%strbuf, %size, %mes)
    la a0 %mes
    la      a1 %strbuf
    li      a2 %size
    li      a7 54
    ecall
    bnez a1 badik
    push(s0)
    push(s1)
    push(s2)
    li	s0 '\n'
    la	s1	%strbuf
next:
    lb	s2  (s1)
    beq s0	s2	replace
    addi s1 s1 1
    b	next
replace:
    sb	zero (s1)
    pop(s2)
    pop(s1)
    pop(s0)
    li a0 0
    j sc
    badik:
    li a0 -1
    sc:
    
.end_macro

#-------------------------------------------------------------------------------
# Открытие файла для чтения, записи, дополнения
.eqv READ_ONLY	0	# Открыть для чтения
.eqv WRITE_ONLY	1	# Открыть для записи
.eqv APPEND	    9	# Открыть для добавления
.macro open(%file_name, %opt)
    li   	a7 1024     	# Системный вызов открытия файла
    la      a0 %file_name   # Имя открываемого файла
    li   	a1 %opt        	# Открыть для чтения (флаг = 0)
    ecall             		# Дескриптор файла в a0 или -1)
.end_macro

#-------------------------------------------------------------------------------
# Чтение информации из открытого файла
.macro read(%file_descriptor, %strbuf, %size)
    li   a7, 63       	# Системный вызов для чтения из файла
    mv   a0, %file_descriptor       # Дескриптор файла
    la   a1, %strbuf   	# Адрес буфера для читаемого текста
    li   a2, %size 		# Размер читаемой порции
    ecall             	# Чтение
.end_macro

#-------------------------------------------------------------------------------
# Чтение информации из открытого файла,
# когда адрес буфера в регистре
.macro read_addr_reg(%file_descriptor, %reg, %size)
    li   a7, 63       	# Системный вызов для чтения из файла
    mv   a0, %file_descriptor       # Дескриптор файла
    mv   a1, %reg   	# Адрес буфера для читаемого текста из регистра
    li   a2, %size 		# Размер читаемой порции
    ecall             	# Чтение
.end_macro

#-------------------------------------------------------------------------------
# Закрытие файла
.macro close(%file_descriptor)
    li   a7, 57       # Системный вызов закрытия файла
    mv   a0, %file_descriptor  # Дескриптор файла
    ecall             # Закрытие файла
.end_macro

#-------------------------------------------------------------------------------
# Выделение области динамической памяти заданного размера
.macro allocate(%size)
    li a7, 9
    li a0, %size	# Размер блока памяти
    ecall
.end_macro

#-------------------------------------------------------------------------------
# Завершение программы
.macro exit
    li a7, 10
    ecall
.end_macro

#-------------------------------------------------------------------------------
# Сохранение заданного регистра на стеке
.macro push(%x)
	addi	sp, sp, -4
	sw	%x, (sp)
.end_macro

#-------------------------------------------------------------------------------
# Выталкивание значения с вершины стека в регистр
.macro pop(%x)
	lw	%x, (sp)
	addi	sp, sp, 4
.end_macro

.macro maybe_concole
open(file_name, READ_ONLY)
    li		s1 -1			# Проверка на корректное открытие
    beq		a0 s1 er_name1	# Ошибка открытия файла
    mv   	s0 a0       	# Сохранение дескриптора файла
    ###############################################################
    # Выделение начального блока памяти для для буфера в куче
    allocate(TEXT_SIZE)		# Результат хранится в a0
    mv 		s3, a0			# Сохранение адреса кучи в регистре
    mv 		s5, a0			# Сохранение изменяемого адреса кучи в регистре
    li		s4, TEXT_SIZE	# Сохранение константы для обработки
    mv		s6, zero		# Установка начальной длины прочитанного текста
    ###############################################################
read_loop1:
    # Чтение информации из открытого файла
    ###read(s0, strbuf, TEXT_SIZE)
    read_addr_reg(s0, s5, TEXT_SIZE) # чтение для адреса блока из регистра
    # Проверка на корректное чтение
    beq		a0 s1 er_read1	# Ошибка чтения
    mv   	s2 a0       	# Сохранение длины текста
    add 	s6, s6, s2		# Размер текста увеличивается на прочитанную порцию
    # При длине прочитанного текста меньшей, чем размер буфера,
    # необходимо завершить процесс.
    bne		s2 s4 end_loop1
    # Иначе расширить буфер и повторить
    allocate(TEXT_SIZE)		# Результат здесь не нужен, но если нужно то...
    add		s5 s5 s2		# Адрес для чтения смещается на размер порции
    b read_loop1				# Обработка следующей порции текста из файла
end_loop1:
    ###############################################################
    # Закрытие файла
    close(s0)
    #li   a7, 57       # Системный вызов закрытия файла
    #mv   a0, s0       # Дескриптор файла
    #ecall             # Закрытие файла
    ###############################################################
    # Установка нуля в конце прочитанной строки
    ###la	t0 strbuf	 # Адрес начала буфера
    mv	t0 s3		# Адрес буфера в куче
    add t0 t0 s6	# Адрес последнего прочитанного символа
    addi t0 t0 1	# Место для нуля
    sb	zero (t0)	# Запись нуля в конец текста
    j repeat
    start:
    error_message error_m
    repeat:
    str_get(buf6, BUF_SIZE, mes_console)
    bnez a0 start
    li a1 'Y'
    la a2 buf6
    lb a3 (a2)
    beq a1 a3 look
    li a1 'N'
    la a2 buf6
    lb a3 (a2)
    beq a1 a3 maybe_end
    la a0 error_input
    li a1 2
    li a7 55
    ecall
    j repeat
    look:
    addi a0 s3 3
    li a1 1
    li a7 55
    ecall
.end_macro
