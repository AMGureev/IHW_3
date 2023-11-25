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
mes_good: .asciz "Тест пройден успешно. Файлы равны"
mes_false: .asciz "Тест провален. Файлы не равны"
mes_again: .asciz "Если хотите продолжить работу, введите Y\nДля завершения работы введите любой символ"
mes_file_1:   .asciz "Введите адрес файла, в котором вы подсчитать кол-во слов"
mes_file_2:   .asciz "Введите адрес файла, в который вы хотите сохранить значения"
mes_file_3:   .asciz "Введите адрес тестового файла"
info_result: .asciz "Результат работы программы"
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
    read_first_file
    count_word buf1 output_str_buf1
    count_word buf2 output_str_buf2
    count_word buf3 output_str_buf3
    count_word buf4 output_str_buf4
    count_word buf5 output_str_buf5
    work_with_second_file
    read_second_file
    mv s9 s3
    read_third_file
    mv s10 s3
    mv a1 s10
    mv a0 s9
    jal strcmp
    beqz a0 good_news
    la a0 mes_false
    li a1 1
    li a7 55
    ecall
    maybe_end:
    again
    exit
    good_news:
    la a0 mes_good
    li a1 1
    li a7 55
    ecall
    j maybe_end
