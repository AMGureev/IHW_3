.macro error_message %str					# Макрос вывода сообщения об ошибке пользователю. %str - выводимое сообщение.
la a0 %str
li a1 2
li a7 55
ecall
.end_macro

.macro count_word %bufer %result_bufer			# Макрос для сохранения в буфер числа - кол-ва ключ.слов в строке (файле). bufer - хранит число в перевернутом виде, result_bufer	 - принимает результат преобразований.
    find_count %bufer t6						# Поиск кол-ва.
    int_to_str %result_bufer t6					# Перевод результата в строку.
.end_macro

.macro choise								# Макрос для возможного выхода из программы (завершения работы).
	j start
	srtg:
	error_message error_m					# Пользователь ничего не ввел - информирование об ошибки.
	start:
	str_get(buf6, BUF_SIZE, mes_choise)		# Ввод строки пользователем - ожидание символа 'Y' или других символов.
	bnez a0 srtg
	li a1 'Y'
	la a2 buf6
	lb a3 (a2)
	beq a1 a3 main							# Пользователь ввел 'Y' - программа продолжает работу.
	la a0 good_bye							# Пользователь ввел !'Y' - программа завершает работу и выводит прощальное java окно.
    	li a1 1
    	li a7 55
    	ecall
.end_macro

.macro print_el %bufer %result_bufer			# Макрос, который записывает в файл строку, хранящую слово, а затем число (кол-во ключ. слов в файле).
mv   a0, s0
li a7 64									# Системный вызов добавления строки в файл - в данном случае ключ.слово.
la a1 %bufer 								# Адрес буфера записываемого текста
la a6 %bufer	
jal strlen									# Узнаем длину строки, которую хотим поместить в файл.
mv a2 a6			
ecall
mv   a0, s0
li   a7, 64									# Системный вызов добавления строки в файл - в данном случае пробела.
la     a1 space
li  a2 1
ecall
mv   a0, s0
li   a7, 64									# Системный вызов добавления строки в файл - в данном случае кол-во ключ.слов.
la     a1 %result_bufer
la a6 %result_bufer
jal strlen
mv a2 a6
ecall
mv   a0, s0
li   a7, 64									# Системный вызов добавления строки в файл - в данном случае переход на другую строку.
la     a1 enter
li  a2 1
ecall
.end_macro

.macro print_to_file							# Макрос для заполнения всего файла.
print_el buf1 output_str_buf1
print_el buf2 output_str_buf2
print_el buf3 output_str_buf3
print_el buf4 output_str_buf4
print_el buf5 output_str_buf5
.end_macro

.macro int_to_str %dest %source				# Макрос для сохранения и переворачивания строкового представления числа. source - число, dest - строка.
    mv      a0 %source           					# Поместить целое число в регистр a0
    li      a1 10                						# Десятичная система счисления
    la      a2 %dest             					# Регистр для сохранения строки
    int_to_str_loop:
        remu    a3, a0, a1         					# A3 = A0 % A1 (остаток от деления)
        addi    a3, a3, '0'         					# Преобразовать остаток в ASCII
        push (a3)
        addi    a2 a2 1            					# Перейти к следующему символу в строке
        divu    a0 a0 a1          					# A0 = A0 / A1 (целая часть от деления)
        bnez    a0 int_to_str_loop  				# Повторить цикл, если A0 не равно нулю
        mv a4 a2
        la a5 %dest
	reverse_int:
	pop(a3)
	sb      a3 0(a5)            					# Сохранить ASCII-символ в строку
	addi    a5 a5 1            					# Перейти к следующему символу в строке
    	ble    a5 a4 reverse_int
    	sb      zero 0(a5)          					# Завершить строку нулевым символом
.end_macro

.macro find_count %word %result				# Макрос для поиска кол-ва ключ.слова в файле. word - ключ.слово, result - кол-во этих слов.
	li t6 0 								# Счетчик ответов.
	mv a6 s3
	jal strlen
	mv a1 a6
	la a6 %word
	jal strlen
	neg a6 a6								
	add a5 a6 a1							# Последний индекс у строки.
	neg a6 a6								# Последний индекс у среза.
	mv a4 zero							# Первый индекс.
	while:								# Аналогично записи for (int a4 = 0; a4 < a5; a4++).
	bgt a4 a5 end
	add a3 a6 a4
	slice s3 str_copy a4 a3 					
	la      a0 %word							# Сравнение ключ.слова с срезом.
    	la      a1 str_copy
   	jal     strcmp
   	bnez a0 not_equal						# Вывод результата сравнения.
	addi t6 t6 1
 	not_equal:
 	addi a4 a4 1
	j while 
	end:
	mv %result t6							# Возвращение кол-ва ключ.слов.
.end_macro 

.macro slice %src %dest %start %finish      		# Срез строки. start - индекс начала, finish - индекс конца.
	mv a0 %start 							# копия старта.
	mv t0 %src
	la t1 %dest
	add t0 t0 a0
	loop:
	ble %finish a0 end
	lb t2 (t0)
	sb t2 (t1)
	beqz t2 end 							# Если наткнулись на ноль-символ, то прекратить копирование
	addi t0 t0 1 							# Сдвигаемся по строке для копирования на 1 символ вперед
	addi t1 t1 1 							# Сдвигаемся по строке-копии на 1 символ вперед
	addi a0 a0 1
	j loop
	end:
	sb zero (t1) 
.end_macro

.macro print_int (%x) 						# Печать содержимого заданного регистра как целого.
	li a7, 1
	mv a0, %x
	ecall
.end_macro

.macro print_imm_int (%x) 					# Печать непосредственного целочисленного значения.
	li a7, 1
   	li a0, %x
   	ecall
.end_macro

.macro print_str (%x)							# Печать строковой константы, ограниченной нулевым символом.
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

.macro print_char(%x)						# Печать отдельного заданного символа.
   li a7, 11
   li a0, %x
   ecall
.end_macro

.macro newline								# Печать перевода строки.
   print_char('\n')
.end_macro

.macro read_int_a0							# Ввод целого числа с консоли в регистр a0.
   li a7, 5
   ecall
.end_macro

.macro read_int(%x)							# Ввод целого числа с консоли в указанный регистр, исключая регистр a0
   push	(a0)
   li a7, 5
   ecall
   mv %x, a0
   pop	(a0)
.end_macro


.macro str_get(%strbuf, %size, %mes) 			# Макрос для ввода строки в буфер заданного размера с заменой перевода строки нулем %strbuf - адрес буфера %size - целая константа, ограничивающая размер вводимой строки, %mes - сообщение пользователю.
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

# Открытие файла для чтения, записи, дополнения
.eqv READ_ONLY	0						# Открыть для чтения.
.eqv WRITE_ONLY	1						# Открыть для записи.
.eqv APPEND	    9							# Открыть для добавления.
.macro open(%file_name, %opt)
    li   	a7 1024     						# Системный вызов открытия файла.
    la      a0 %file_name     					# Имя открываемого файла.
    li   	a1 %opt        						# Открыть для чтения (флаг = 0).
    ecall             							# Дескриптор файла в a0 или -1).
.end_macro

# Чтение информации из открытого файла
.macro read(%file_descriptor, %strbuf, %size)		# Макрос для чтения информации из открытого файла.
    li   a7, 63       							# Системный вызов для чтения из файла.
    mv   a0, %file_descriptor       				# Дескриптор файла.
    la   a1, %strbuf   							# Адрес буфера для читаемого текста.
    li   a2, %size 							# Размер читаемой порции.
    ecall
.end_macro

.macro read_addr_reg(%file_descriptor, %reg, %size) # Макрос для чтения информации из открытого файла, когда адрес буфера в регистре.
    li   a7, 63       							# Системный вызов для чтения из файла.
    mv   a0, %file_descriptor       				# Дескриптор файла.
    mv   a1, %reg   							# Адрес буфера для читаемого текста из регистра.
    li   a2, %size 							# Размер читаемой порции.
    ecall
.end_macro

.macro close(%file_descriptor)					# Закрытие файла.
    li   a7, 57       							# Системный вызов закрытия файла.
    mv   a0, %file_descriptor
    ecall
.end_macro

.macro allocate(%size)						# Макрос для выделения области динамической памяти заданного размера.
    li a7, 9
    li a0, %size								# Размер блока памяти.
    ecall
.end_macro

.macro exit								# Макрос для завершения программы.
    li a7, 10
    ecall
.end_macro

.macro push(%x)							# Макрос - сохранение заданного регистра на стеке.
	addi	sp, sp, -4
	sw	%x, (sp)
.end_macro

.macro pop(%x)							# Макрос - выталкивание значения с вершины стека в регистр.
	lw	%x, (sp)
	addi	sp, sp, 4
.end_macro

.macro mb_second_file						# Макрос прочтения второго файла - в который надо вписать результат работы с первым файлом.
    open(file_name, READ_ONLY)
    li		s1 -1								# Проверка на корректное открытие.
    beq		a0 s1 er_name1				# Ошибка открытия файла.
    mv   	s0 a0       							# Сохранение дескриптора файла.
    # Выделение начального блока памяти для для буфера в куче.
    allocate(TEXT_SIZE)						# Результат хранится в a0.
    mv 		s3, a0						# Сохранение адреса кучи в регистре.
    mv 		s5, a0						# Сохранение изменяемого адреса кучи в регистре.
    li		s4, TEXT_SIZE						# Сохранение константы для обработки.
    mv		s6, zero						# Установка начальной длины прочитанного текста.
read_loop1:
    # Чтение информации из открытого файла.
    read_addr_reg(s0, s5, TEXT_SIZE) 			# Чтение для адреса блока из регистра.
    # Проверка на корректное чтение
    beq		a0 s1 er_read1					# Ошибка чтения.
    mv   	s2 a0       							# Сохранение длины текста.
    add 	s6, s6, s2							# Размер текста увеличивается на прочитанную порцию.
    # При длине прочитанного текста меньшей, чем размер буфера, необходимо завершить процесс.
    bne		s2 s4 end_loop1
    # Иначе расширить буфер и повторить.
    allocate(TEXT_SIZE)
    add		s5 s5 s2						# Адрес для чтения смещается на размер порции.
    b read_loop1							# Обработка следующей порции текста из файла.
end_loop1:
    close(s0)								# Закрытие файла.
    mv	t0 s3								# Адрес буфера в куче.
    add t0 t0 s6								# Адрес последнего прочитанного символа.
    addi t0 t0 1								# Место для нуля.
    sb	zero (t0)								# Запись нуля в конец текста.
    j end
    er_name1:								# Метка - ошибка в имени файла.
    error_message er_name_mes
er_read1:									# Метка - ошибка в прочтении файла.
    error_message er_read_mes
    end:
.end_macro

.macro console								# Макрос для работы с консолью. Хочет ли пользователь увидеть результаты работы программы в java окне.
	j repeat
    start:
    error_message error_m						# Пользователь ввел пустоту.
    repeat:
    str_get(buf6, BUF_SIZE, mes_console)		# Пользователь вводит строку.
    bnez a0 start
    li a1 'Y'
    la a2 buf6
    lb a3 (a2)
    beq a1 a3 look							# Пользователь ввел 'Y'.
    li a1 'N'
    la a2 buf6
    lb a3 (a2)
    beq a1 a3 maybe_end						# Пользователь ввел 'N'.
    la a0 error_input							# Пользователь ввел (input() != 'N' or input() != 'Y').
    li a1 2
    li a7 55
    ecall
    j repeat
    look:									# Метка показа результата пользователю в java окне.
    addi a0 s3 0
    li a1 1
    li a7 55
    ecall
.end_macro

.macro TEST								# Макрос, который проводит тест полученного файла с результирующим.
    mv s9 s3								# Запоминаем строку, которая получилась в результирующем файле при работе программы.
    read_third_file							# Считываем третий файл - тестирующий.
    mv s10 s3								# Запоминаем строку, которая хранится в тестирующем файле.
    mv a1 s10
    mv a0 s9
    jal strcmp								# Сравнение входящих строк.
    beqz a0 good_news						# Строки равны - информирование пользователе о прохождении теста.
    la a0 mes_false							# Строки не равны - информирование пользователе о провале теста.
    li a1 1
    li a7 55
    ecall									# Информирование пользователе о провале теста.
    j en
    good_news:								# Информирование пользователе о прохождении теста.
    la a0 mes_good
    li a1 1
    li a7 55
    ecall
    j maybe_end
    en:
.end_macro

.macro read_first_file 						# Макрос прочтения первого файла - который будет анализировать программа.
j back
    n_back:
    error_message error_m						# Сообщение о пустоте входного файла.
    back:
    str_get(file_name, NAME_SIZE, mes_file_1)		# Получение строки от пользователя.
    bnez a0 n_back
    open(file_name, READ_ONLY)
    li		s1 -1								# Проверка на корректное открытие.
    beq		a0 s1 er_name					# Ошибка открытия файла.
    mv   	s0 a0       							# Сохранение дескриптора файла.
    # Выделение начального блока памяти для для буфера в куче.
    allocate(TEXT_SIZE)						# Результат хранится в a0.
    mv 		s3, a0						# Сохранение адреса кучи в регистре.
    mv 		s5, a0						# Сохранение изменяемого адреса кучи в регистре.
    li		s4, TEXT_SIZE						# Сохранение константы для обработки.
    mv		s6, zero						# Установка начальной длины прочитанного текста.
read_loop:
    # Чтение информации из открытого файла.
    read_addr_reg(s0, s5, TEXT_SIZE)			# Чтение для адреса блока из регистра.
    # Проверка на корректное чтение
    beq		a0 s1 er_read					# Ошибка чтения.
    mv   	s2 a0       							# Сохранение длины текста.
    add 	s6, s6, s2							# Размер текста увеличивается на прочитанную порцию.
    # При длине прочитанного текста меньшей, чем размер буфера, необходимо завершить процесс.
    bne		s2 s4 end_loop
    # Иначе расширить буфер и повторить.
    allocate(TEXT_SIZE)
    add		s5 s5 s2						# Адрес для чтения смещается на размер порции.
    b read_loop								# Обработка следующей порции текста из файла.
end_loop:
    close(s0) 								# Закрытие файла.
    mv	t0 s3								# Адрес буфера в куче.
    add t0 t0 s6								# Адрес последнего прочитанного символа.
    addi t0 t0 1								# Место для нуля.
    sb	zero (t0)								# Запись нуля в конец текста.
    j end
    er_name:								# Сообщение об ошибочном имени файла.
    error_message er_name_mes
    j back
er_read:									# Сообщение об ошибочном чтении.
    error_message er_read_mes
    j back
    end:
.end_macro

.macro read_second_file						# Макрос - обьединяющий работу двух макросов для работы с вторым файлом (в который будут записываться результаты вычислений).
	work_with_second_file					# Работа с вторым файлом - проверка на корректность.
    	mb_second_file						# Считывание данных из второго файла для хранения и возможного вывода в java окно.
.end_macro

.macro get_5_keys							# Макрос для ввода пользователем 5 ключевых слов языка C.
j po1
    pop1:
    error_message error_m						# Ошибка - пользователь ввел пустую строку.
    po1:
    str_get(buf1, BUF_SIZE, mes)				# Ввод пользователем ключевого слова.
    bnez a0 pop1
    j po2
    pop2:
    error_message error_m						# Ошибка - пользователь ввел пустую строку.
    po2:
    str_get(buf2, BUF_SIZE, mes)				# Ввод пользователем ключевого слова.
    bnez a0 pop2
    j po3
    pop3:
    error_message error_m						# Ошибка - пользователь ввел пустую строку.
    po3:
    str_get(buf3, BUF_SIZE, mes)				# Ввод пользователем ключевого слова.
    bnez a0 pop3
    j po4
    pop4:
    error_message error_m						# Ошибка - пользователь ввел пустую строку.
    po4:
    str_get(buf4, BUF_SIZE, mes)				# Ввод пользователем ключевого слова.
    bnez a0 pop4
    j po5
    pop5:
    error_message error_m						# Ошибка - пользователь ввел пустую строку.
    po5:
    str_get(buf5, BUF_SIZE, mes)				# Ввод пользователем ключевого слова.
    bnez a0 pop5
.end_macro

.macro work_with_second_file					# Макрос для работы с результирующим файлом для возможного вывода результата в java окно пользователю при вводе 'Y'.
    j back1
    n_back1:
    error_message error_m
    back1:
    str_get(file_name, NAME_SIZE, mes_file_2) 	# Ввод имени файла с консоли эмулятора.
    bnez a0 n_back1
    open(file_name, READ_ONLY)
    li		s1 -1								# Проверка на корректное открытие.
    beq		a0 s1 er_name1				# Ошибка открытия файла.
    mv   	s0 a0       							# Сохранение дескриптора файла.
    close(s0)
    open(file_name, APPEND)
    mv   	s0 a0       							# Сохранение дескриптора файла.
	print_to_file							# Запись информации в открытый файл.
mv   a0, s0 								# Дескриптор файла.
    close(s0)
    j end
    er_name1:
    error_message er_name_mes
    j back1
er_read1:
    error_message er_read_mes
    j back1
    end:
.end_macro

.macro read_third_file						# Макрос для прочтения третьего файла для тестирующей системы.
j back
    n_back:
    error_message error_m
    back:
    str_get(file_name, NAME_SIZE, mes_file_3)
    bnez a0 n_back
    open(file_name, READ_ONLY)
    li		s1 -1								# Проверка на корректное открытие.
    beq		a0 s1 er_name				 	# Ошибка открытия файла.
    mv   	s0 a0       							# Сохранение дескриптора файла.
    # Выделение начального блока памяти для для буфера в куче.
    allocate(TEXT_SIZE)						# Результат хранится в a0.
    mv 		s3, a0						# Сохранение адреса кучи в регистре.
    mv 		s5, a0						# Сохранение изменяемого адреса кучи в регистре.
    li		s4, TEXT_SIZE						# Сохранение константы для обработки.
    mv		s6, zero						# Установка начальной длины прочитанного текста.
read_loop:								# Чтение информации из открытого файла.
    read_addr_reg(s0, s5, TEXT_SIZE) 			# Чтение для адреса блока из регистра.
    # Проверка на корректное чтение.
    beq		a0 s1 er_read					# Ошибка чтения.
    mv   	s2 a0       							# Сохранение длины текста.
    add 	s6, s6, s2							# Размер текста увеличивается на прочитанную порцию.
    # При длине прочитанного текста меньшей, чем размер буфера, необходимо завершить процесс.
    bne		s2 s4 end_loop
    allocate(TEXT_SIZE)
    add		s5 s5 s2						# Адрес для чтения смещается на размер порции.
    b read_loop								# Обработка следующей порции текста из файла.
end_loop:
    close(s0)
    mv	t0 s3								# Адрес буфера в куче.
    add t0 t0 s6								# Адрес последнего прочитанного символа.
    addi t0 t0 1								# Место для нуля.
    sb	zero (t0)								# Запись нуля в конец текста.
    j end
    er_name:								# Сообщение об ошибочном имени файла.
    error_message er_name_mes
    j back
er_read:					       				# Сообщение об ошибочном чтении.
    error_message er_read_mes
    j back
    end:
.end_macro
