module subprograms ! Модуль с процедурами
implicit none

contains

subroutine choice_test(A,n,f2,np1_limit) ! Процедура осуществления частичного выбора
implicit none                            ! ведущего элемента (беру не max, а первый встречный)

real(8) A(:,:)           ! Матрица коэффициентов и свободных членов
real(8) buffer(n+1)      ! Буфер обмена строк
integer n                ! Число незвестных в уравнениях
integer np1_limit        ! Предельное количество столбцов в форматном выводе
integer stat             ! Статусная переменная
integer i, j, k, m       ! Вспомогательные переменные
character(20) f1, f2     ! Вспомогательные переменные для автоформатирования

stat=0 ! Статус 0 — проблемных элементов не найдено
do i=1,n ! Поиск проблемных элементов (по умолчанию это элементы < 1.0)
if (abs(A(i,i)) .lt. 1.0) then
write(*,'(/,4x,a)') 'Замечен элемент на диагонали, модуль которого &
&меньше единицы:'; stat=1 ! Статус 1 — найден проблемный элемент

! Подготовка и вывод информации о найденном элементе
write(f1,*) i

do j=1,n ! Поиск строки для замены
if (abs(A(j,i)) .ge. 1.0 .and. abs(A(i,j)) .ge. 1.0) then

stat=2; buffer=A(i,:); A(i,:)=A(j,:); A(j,:)=buffer ! Статус 2 — найдена замена
write(*,'(4x,a,a)') 'Нашлось подходящее преобразование строк для элемента&
& с индексами ', '('//trim(adjustl(f1))//','//trim(adjustl(f1))//').'
if (n+1 .le. np1_limit) write(*,f2) ((A(k,m),m=1,n+1),k=1,n) ! Вывод матрицы после перестановки строк
exit

endif
enddo ! Завершение поиска строки для замены

! Вывод сообщения в случае неудачи
if (stat .eq. 1) write(*,'(/,4x,a,a,/,4x,a,/)') 'Не нашлось подходящего&
& преобразования строк для элемента с индексами ', '('//trim(adjustl(f1))&
&//','//trim(adjustl(f1))//').', &
&'Возможен неконтролируемый рост погрешности в ответе.'

endif
enddo ! Завершения поиска проблемных элементов

if (stat .eq. 0) write(*,'()')

end subroutine



recursive subroutine diag_dom(A,n,f2,re,answer,np1_limit,do_get_diag_dom) ! Проверка на диагональное преобладание
implicit none

real(8) A(:,:)          ! Матрица коэффициентов и свободных членов
integer n               ! Число незвестных в уравнениях
real(8) s               ! Сумма внедиагональных элементов
integer i, j            ! Вспомогательные переменные
integer stat            ! Статусная переменная для диагонального преобладания
integer re              ! Статусная переменная для преобразования матрицы
logical strict          ! Есть ли хотя бы одно строгое неравенство?
integer answer          ! Останавливать программу при отсутствии ... ? (см. в input)
integer np1_limit       ! Предельное количество столбцов в форматном выводе
integer do_get_diag_dom ! Пытаться преобразовывать матрицу к диагональному преобладанию?
character(20) f2        ! Вспомогательная переменная для автоформатирования

s=0 ! Вычисление суммы внедиагональных элементов
do i=1,n; do j=i+1,n
s=s+abs(A(i,j)); s=s+abs(A(n+1-i,n+1-j))
enddo; enddo

strict = .false.

do i=1,n ! Начало проверки матрицы на наличие диагонального преобладания 

if (abs(A(i,i)) .gt. s .and. stat .ne. 2) then; stat=1; strict = .true.; ! Статус 1 - строгое диагональное преобладание
elseif (abs(A(i,i)) .eq. s) then; stat=2; ! Статус 2 - нестрогое диагональное преобладание
elseif (re .eq. 0) then ! re 1 - процедура проверки вызывается первый раз 
        write(*,'(4x,a,/)') 'В матрице не обнаружено диагональное преобладание.'
        stat = 3; exit;
elseif (re .eq. 1) then; stat = 4 ! re 2 - процедура проверки вызывается второй раз
endif

enddo ! Завершение проверки матрицы на наличие диагонального преобладания

! Статус 3 - будет произведена попытка получить диагональное преобладание
if (stat .eq. 3) then
       if (do_get_diag_dom .eq. 1) then ! Попытка выполняется, если значение do_get_diag_dom = 1
              call get_diag_dom(A,n,f2,np1_limit); stat = 4; call diag_dom(A,n,f2,1,answer,np1_limit,do_get_diag_dom)
       elseif (answer .eq. 1) then ! Программа сообщает об остановке согласно значению asnwer
              write(*,'(4x,a,/)') 'Программа остановлена согласно &
                                  &значению переменной answer.'
              stop
       endif
endif

! Статус 4 - была произведена неудачная попытка получить диагональное преобладание

! Вывод сообщения о результате проверки

if (stat .eq. 1) write(*,'(4x,a,/)') 'В матрице обнаружено &
&строгое диагональное преобладание.'

if (stat .eq. 2 .and. (strict .eqv. .true.)) write(*,'(4x,a,/)') 'В матрице &
&обнаружено нестрогое диагональное преобладание.'

if (stat .eq. 2 .and. (strict .eqv. .false.)) then
write(*,'(4x,a,/)') 'В матрице &
&обнаружено нестрогое диагональное преобладание, однако все &
&неравенства оказались равенствами.'
       if (answer .eq. 1) then
              write(*,'(4x,a,/)') 'Программа остановлена согласно &
                                  &значению переменной answer.'
              stop
       endif
endif

if (stat .eq. 4 .and. re .eq. 1) then 
write(*,'(4x,a,/)') 'Неудачная попытка получить диагональное преобладание.'
       if (answer .eq. 1) then
              write(*,'(4x,a,/)') 'Программа остановлена согласно &
                                  &значению переменной answer.'
              stop
       endif
endif

end subroutine



subroutine get_diag_dom(A,n,f2,np1_limit) ! Приведение матрицы в состояние с диагональным преобладанием
implicit none                             ! (преобразование матрицы)

real(8) A(:,:)    ! Матрица коэффициентов и свободных членов
real(8) B(n,n)    ! Вспомогательная матрица для A^(т)
integer n         ! Число незвестных в уравнениях
integer np1_limit ! Предельное количество столбцов в форматном выводе
integer i, j      ! Вспомогательные переменные
character(20) f2  ! Вспомогательные переменные для автоформатирования

B=transpose(A(:,1:n)) ! Получение матрица A^(т)

A(:,1:n)=matmul(B,A(:,1:n)) ! Произведение A^(т)*A
A(:,n+1)=matmul(B,A(:,n+1)) ! Произведение A^(т)*B

! Вывод сообщения о результате преобразования матрицы

if (n+1 .le. np1_limit) then
       write(*,'(4x,a,/,4x,a)') 'Была совершена попытка &
       &привести матрицу к диагональному &
       &преобладанию путём', 'приведения системы A*x=B к виду A^(T)*A*x=A^(T)*B:'
       write(*,f2) ((A(i,j),j=1,n+1),i=1,n)
else
       write(*,'(4x,a,/,4x,a)') 'Была совершена попытка &
       &привести матрицу к диагональному &
       &преобладанию путём', 'приведения системы A*x=B к виду A^(T)*A*x=A^(T)*B.'
endif

end subroutine



subroutine seidel(A,n,eps,k_lim,f2,np1_limit,show_check,answer,x_0_answer) ! Исполнительная часть метода Зейделя
implicit none

real(8) A(:,:)       ! Матрица коэффициентов и свободных членов
real(8) B(n,n+1)     ! Вспомогательная матрица, содержащая коэффициенты после преобразования
integer n            ! Число незвестных в уравнениях
integer np1_limit    ! Предельное количество столбцов в форматном выводе
integer k            ! Счётчик итераций
integer k_lim        ! Предельное число итераций
real(8) check        ! Вычисление нормы: dsqrt(sum((x-x_0)*(x-x_0)))
logical check_mask   ! Проверка на малость нормы: (check .le. eps)
logical np1_check    ! Проверка n на на np1_limit
integer show_check   ! Показывать список check и x для каждой итерации?
integer answer       ! Останавливать программу при отсутствии ... ? (см. в input)
integer x_0_answer   ! Брать за нулевое значение x = 0 или x = B(:,n+1)?
real(8) eps          ! Точность итерационных вычислений
real(8) x(n)         ! Значение x в текущей итерации
real(8) s            ! Держатель суммы для вычисления x(i) 
real(8) x_0(n)       ! Значение x в предыдущей итерации
integer i, j         ! Вспомогательные переменные
character(20) f1, f2 ! Вспомогательные переменные для автоформатирования

write(*,'(4x,a,/)') 'Исполнительная часть метода Зейделя:'

! Преобразование матрицы A для получения матрицы B (смотри описание ниже)
do i=1, n
B(i,n+1) = A(i,n+1)/A(i,i)
B(i,i) = 0

       do j=1, n
              if (i .ne. j) B(i,j) = -A(i,j)/A(i,i)
       enddo

enddo

write(*,'(4x,a)') 'Матрица B описывает коэффициенты для следующих уравнений:'
write(*,'(4x,a,/)') 'x_i = (- a_i_1*x_1 - a_i_2*x_2 - ... - 0*x_i - ... - a_i_n*x_n + b_i)/a_i_i'

! Вывод содержимого B
if (n+1 .le. np1_limit) then
       write(*,'(4x,a)') 'Её содержимое:'
       write(*,f2) ((B(i,j),j=1,n+1),i=1,n)
endif

write(*,'(4x,a,e15.7)') 'Указанная точность итерационных вычислений:', eps
write(*,'(/,4x,a)') 'Вывод значений переменной check для каждой итерации:'

! Заполнение вектора x начальными значениями согласно значению переменной x_0_answer

if (x_0_answer .eq. 0) then
       x = 0
else
       x = B(:,n+1)
endif

k = 0 ! Нулевая итерация - заполнение вектора x начальными данными (выше)
check_mask = .false.

np1_check = (n .le. np1_limit) ! Проверка n на на np1_limit

do while (.not.(check_mask)) ! Начало исполнительной части метода Зейделя

       k = k + 1 ! Задание номера текущей итерации

       x_0 = x ! Вектор x переходит в вектор x_0 как вектор x предыдущей итерации

       do i=1, n ! Начало вычислений вектора x в текущей итерации
              s=0
              do j=1, i-1
                     s = s + B(i,j)*x(j)
              enddo
              do j=i+1,n
                     s = s + B(i,j)*x_0(j)
              enddo
              x(i) = s + B(i,n+1)
       enddo ! Завершение вычислений вектора x в текущей итерации

       check = dsqrt(sum((x-x_0)*(x-x_0))) ! Вычисление нормы |x-x_0|
       
      ! Вывод значений check и x в текущей итерации согласно значению переменной show_check

       if (np1_check .and. (show_check .eq. 1)) then
              write(f1,*) k
              write(*,'(/,4x,a,1x,a,a)') 'Итерация', trim(adjustl(f1)), ':'
              write(*,'(/,4x,a,e15.7,/,4x,a)') 'check:', check, 'Текущие значения x:'
              write(*,f2) (x(i),i=1,n)
       elseif (show_check .eq. 1) then
              write(f1,*) k
              write(*,'(/,4x,a,1x,a,a)') 'Итерация', trim(adjustl(f1)), ':'
              write(*,'(/,4x,a,e15.7)') 'check:', check
       endif
      
       check_mask = (check .le. eps) ! Проверка на малость нормы

       if (k .eq. k_lim) exit ! Проверка на предел итераций

end do ! Завершение исполнительной части метода Зейделя

! Вывод информации о результатах

write(f1,*) k
write(*,'(/,4x,a,1x,a,/)') 'Число прошедших итераций: ', trim(adjustl(f1))

if (np1_check) then
       write(*,'(4x,a)') 'Результат:'
       write(*,f2) (x(i),i=1,n)
       write(*,'()')
endif

if (answer .eq. 0) write(*,'(4x,a,/,4x,a,/)') 'Согласно текущему значению answer, программа &
&игнорирует сообщения об отсутствии диагонального &
&преобладания.', 'Если последнее не было обнаружено &
&в матрице, результат может отличаться от действительного.'

end subroutine

end
