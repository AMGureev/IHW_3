.include "macro-syscalls.m"

.eqv    BUF_SIZE 12
.eqv    NAME_SIZE 256	# Размер буфера для имени файла
.eqv    TEXT_SIZE 512	# Размер буфера для текста

.data
buf1:    .space BUF_SIZE     # Буфер для первой строки
.align 2
buf2:    .space BUF_SIZE     # Буфер для второй строки
.align 2
buf3:    .space BUF_SIZE     # Буфер для третьей строки
.align 2
buf4:    .space BUF_SIZE     # Буфер для четвертой строки
.align 2
buf5:    .space BUF_SIZE     # Буфер для пятой строки
.align 2
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
result: 			.space TEXT_SIZE
.align 2
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

strlen:
    li      t0 0        # Счетчик
loop1:
    lb      t1 (a6)   # Загрузка символа для сравнения
    beqz    t1 end1
    addi    t0 t0 1		# Счетчик символов увеличивается на 1
    addi    a6 a6 1		# Берется следующий символ
    b       loop1
end1:
    mv      a6 t0
    ret

_strcpy: # Копирование строки
	mv t0 a0 # В t0 загружаем адрес строки, котрая будет скопирована
	mv t1 a1 # В t1 загружаем адрес строки, в которую будет происходить копирование
	loop2: # Цикл для копирования каждого символа
	lb t2 (t0) # Загружаем в t2 символ для копировнаия
	sb t2 (t1) # Копируем в строку-копию соответствующий символ из входной строки
	beqz t2 end2 # Если наткнулись на ноль-символ, то прекратить копирование
	addi t0 t0 1 # Сдвигаемся по строке на 1 символ вперед
	addi t1 t1 1 # Сдвигаемся по строке-копии на 1 символ вперед
	j loop2
	end2:
	ret

.globl main
main:
    # Ввод строки 1 в буфер buf1
    j po1
    pop1:
    error_message error_m
    po1:
    str_get(buf1, BUF_SIZE, mes)
    bnez a0 pop1
    j po2
    pop2:
    error_message error_m
    po2:
    str_get(buf2, BUF_SIZE, mes)
    bnez a0 pop2
    j po3
    pop3:
    error_message error_m
    po3:
    str_get(buf3, BUF_SIZE, mes)
    bnez a0 pop3
    j po4
    pop4:
    error_message error_m
    po4:
    str_get(buf4, BUF_SIZE, mes)
    bnez a0 pop4
    j po5
    pop5:
    error_message error_m
    po5:
    str_get(buf5, BUF_SIZE, mes)
    bnez a0 pop5
    # Сравнение строк в буферах
    # Вывод результата сравнения
    # Ввод имени файла с консоли эмулятора
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
