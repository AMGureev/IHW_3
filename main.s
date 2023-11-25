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
mes_file_1:   .asciz "Введите адрес файла, который надо проанализировать"
mes_file_2:   .asciz "Введите адрес файла, в который необходимо записать результат"
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

.globl main
main:
    # Ввод строки 1 в буфер buf1
    get_5_keys
    # Сравнение строк в буферах
    # Вывод результата сравнения
    # Ввод имени файла с консоли эмулятора
    read_first_file
    count_word buf1 output_str_buf1
    count_word buf2 output_str_buf2
    count_word buf3 output_str_buf3
    count_word buf4 output_str_buf4
    count_word buf5 output_str_buf5
    work_with_second_file
    read_file
    console
    maybe_end:
    again
    exit
