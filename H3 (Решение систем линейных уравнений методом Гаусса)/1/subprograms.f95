module subprograms ! Модуль с процедурами
implicit none

contains

subroutine choice_test(A,n,f2) ! Процедура осуществления частичного выбора
implicit none                  ! ведущего элемента (беру не max, а первый встречный)

real(8) A(:,:)           ! Матрица коэффициентов и свободных членов
real(8) buffer(n+1)      ! Буфер обмена строк
integer n                ! Число незвестных в уравнениях
integer i, j, k, m, stat ! Вспомогательные переменные
character(20) f1, f2     ! Вспомогательные переменные для автоформатирования

stat=0 ! Статус 0 — проблемных элементов не найдено
do i=1,n ! Поиск проблемного элемента
if (abs(A(i,i)) .lt. 1.0) then
write(*,'(4x,a)') 'Замечен элемент на диагонали, модуль которого &
&меньше единицы:'; stat=1 ! Статус 1 — найден проблемный элемент

write(f1,*) i

do j=1,n ! Поиск строки для замены
if (abs(A(j,i)) .ge. 1.0 .and. abs(A(i,j)) .ge. 1.0) then

stat=2; buffer=A(i,:); A(i,:)=A(j,:); A(j,:)=buffer ! Статус 2 — найдена замена
write(*,'(4x,a,a)') 'Нашлось подходящее преобразование строк для элемента&
& с индексами ', '('//trim(adjustl(f1))//','//trim(adjustl(f1))//').'
write(*,f2) ((A(k,m),m=1,n+1),k=1,n)
exit

endif
enddo

if (stat .eq. 1) write(*,'(/,4x,a,a,/,4x,a,/)') 'Не нашлось подходящего&
& преобразования строк для элемента с индексами ', '('//trim(adjustl(f1))&
&//','//trim(adjustl(f1))//').', &
&'Возможен неконтролируемый рост погрешности в ответе.'

endif
enddo

if (stat .eq. 0) write(*,'()')

end subroutine

subroutine forward(A,n,f2) ! Процедура "прямого хода":
implicit none              ! преобразование к треугольной матрице

real(8) A(:,:)   ! Матрица коэффициентов и свободных членов
real(8) koef     ! Коэффициент домножения при сложении строк
integer n        ! Число неизвестных в уравнениях
integer i, j     ! Вспомогательные переменные
character(20) f2 ! Вспомогательная переменная для автоформатирования

do i=2, n; do j=i, n

! Вычисление коэффициента домножения при сложении строк
koef=-(A(j,i-1))/(A(i-1,i-1))

A(j,1:i-1)=0

! Сложение строк
A(j,i:n+1)=A(j,i:n+1)+A(i-1,i:n+1)*koef

enddo; enddo

write(*,'(4x,a,/,4x,a)') 'Прямой ход:', &
&'Матрица была преобразована к треугольному виду:'

write(*,f2) ((A(i,j),j=1,n+1),i=1,n)

end subroutine

subroutine backward(A,n) ! Процедура "обратного хода"
implicit none

real(8) A(:,:)   ! Матрица коэффициентов и свободных членов
real(8) up       ! Дополнение к числителю при вычислении неизвестной
integer n        ! Число неизвестных в уравнениях
integer i, j     ! Вспомогательные переменные
character(20) f1 ! Вспомогательная переменная для автоформатирования

do i=n, 1, -1

! Вычисление неизвестной
A(i,i)=(A(i,n+1)-up)/A(i,i)

up=0 ! Вычисление дополнения к числителю при вычислении неизвестной
do j=n, i, -1; up=up+A(i-1,j)*A(j,j); enddo

enddo

write(*,'(4x,a,/,4x,a,/)') 'Обратный ход:', 'Результат вычисления неизвестных:'
do i=1, n; write(f1,*) i; write(*,'(6x,a,1x,e22.15)') 'x'//trim(adjustl(f1))//' =', A(i,i); enddo
write(*,'()')

end subroutine


end
