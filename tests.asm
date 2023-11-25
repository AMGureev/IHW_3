.include "macro-syscalls.m"

.eqv    BUF_SIZE 12
.eqv    NAME_SIZE 256	# Размер буфера для имени файла
.eqv    TEXT_SIZE 512	# Размер буфера для текста

.data
buf1:    .asciz "struct"
buf2:    .asciz "auto"
buf3:    .asciz "else"
buf4:    .asciz "switch"
buf5:    .asciz "enum"
buf6:    .space BUF_SIZE	    # Буфер для ввода пользователем Y/N.
.align 2
strbuf:  .space TEXT_SIZE   # Буфер для читаемого текста
.align 2
str_copy: .space BUF_SIZE # Буфер для строки - среза.
.align 2
mes:   .asciz "Введите ваше ключевое слово"
mes_again: .asciz "Если хотите продолжить работу, введите Y\nДля завершения работы введите любой символ"
mes_file:   .asciz "Введите адрес файла"
info_result: .asciz "Результат работы программы"
mes_file_result:   .asciz "Введите адрес файла"
error_m: .asciz "Вы ничего не ввели! Попробуйте снова!"
mes_console: 	.asciz "Для показа результата в окне, введите Y\nЕсли результат не нужен, введите N"
er_name_mes:    .asciz "Ошибка в названии файла! Введите адрес файла заного!"
er_read_mes:    .asciz "Ошибка в прочтении файла! Введите адрес файла заного!"
good_bye: .asciz "Спасибо, до свидания!"
error_input: .asciz "Некорректный ввод! Повторите попытку!"
enter: 		.asciz "\n"
space:		.asciz " "
file_name:      .space	NAME_SIZE		# Имя читаемого файла
.align 2
output_str_buf1: 	.space NAME_SIZE
.align 2
output_str_buf2: 	.space NAME_SIZE
.align 2
output_str_buf3: 	.space NAME_SIZE
.align 2
output_str_buf4: 	.space NAME_SIZE
.align 2
output_str_buf5: 	.space NAME_SIZE
.align 2
result: 		.space TEXT_SIZE
.align 2

.text
main:
j back
    n_back:
    error_message error_m
    back:
    str_get(file_name, NAME_SIZE, mes_file)
    bnez a0 n_back
    open(file_name, READ_ONLY)
    li		s1 -1			# Проверка на корректное открытие
    beq		a0 s1 er_name	# Ошибка открытия файла
    mv   	s0 a0       	# Сохранение дескриптора файла
    ###############################################################
    # Выделение начального блока памяти для для буфера в куче
    allocate(TEXT_SIZE)		# Результат хранится в a0
    mv 		s3, a0			# Сохранение адреса кучи в регистре
    mv 		s5, a0			# Сохранение изменяемого адреса кучи в регистре
    li		s4, TEXT_SIZE	# Сохранение константы для обработки
    mv		s6, zero		# Установка начальной длины прочитанного текста
    ###############################################################
read_loop:
    # Чтение информации из открытого файла
    ###read(s0, strbuf, TEXT_SIZE)
    read_addr_reg(s0, s5, TEXT_SIZE) # чтение для адреса блока из регистра
    # Проверка на корректное чтение
    beq		a0 s1 er_read	# Ошибка чтения
    mv   	s2 a0       	# Сохранение длины текста
    add 	s6, s6, s2		# Размер текста увеличивается на прочитанную порцию
    # При длине прочитанного текста меньшей, чем размер буфера,
    # необходимо завершить процесс.
    bne		s2 s4 end_loop
    # Иначе расширить буфер и повторить
    allocate(TEXT_SIZE)		# Результат здесь не нужен, но если нужно то...
    add		s5 s5 s2		# Адрес для чтения смещается на размер порции
    b read_loop				# Обработка следующей порции текста из файла
end_loop:
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
    ###############################################################
    # Вывод текста на консоль
    ###la 	a0 strbuf
    count_word buf1 output_str_buf1
    count_word buf2 output_str_buf2
    count_word buf3 output_str_buf3
    count_word buf4 output_str_buf4
    count_word buf5 output_str_buf5
    j back1
    n_back1:
    error_message error_m
    back1:
    str_get(file_name, NAME_SIZE, mes_file) # Ввод имени файла с консоли эмулятора
    bnez a0 n_back1
    open(file_name, READ_ONLY)
    li		s1 -1			# Проверка на корректное открытие
    beq		a0 s1 er_name1	# Ошибка открытия файла
    mv   	s0 a0       	# Сохранение дескриптора файла
    close(s0)
    open(file_name, APPEND)
    mv   	s0 a0       	# Сохранение дескриптора файла
	# Запись информации в открытый файл
	print_to_file
mv   a0, s0 			# Дескриптор файла
    close(s0)
    maybe_concole
    maybe_end:
    again
    exit
    er_name:
    error_message er_name_mes
    j back
er_read:
    # Сообщение об ошибочном чтении
    error_message er_read_mes
    j back
er_name1:
    error_message er_name_mes
    j back1
er_read1:
    error_message er_read_mes
    j back1
