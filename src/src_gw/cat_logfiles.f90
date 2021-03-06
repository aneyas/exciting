!BOP
!
! !ROUTINE: cat_logfiles
!
! !INTERFACE:
subroutine cat_logfiles(filenameslug)

! !DESCRIPTION:
!
! This is the main program unit. It calculates the corrections to the DFT
! eigenvalues within the GW aproximation...
!
! !USES:

    use modmpi
    use modinput
!
! !DEFINED PARAMETERS:
	character(*)::filenameslug
!
!
! !LOCAL VARIABLES:
!
	character(124)::buffer
	integer :: i
!EOP
!BOC
!open new empty file
	if (rank.eq.0)then
		open(901,file=trim(adjustl(filenameslug))//'.OUT',action='write')
		do i=0,procs-1
			write(buffer,*)i
			! open file from proc i
			open(902,file=trim(adjustl(filenameslug))//trim(adjustl(buffer))//'.OUT' )
			if (input%gw%debug .or. i.eq.0) then
                write(901,*)"####### OUTPUT FROM PROC",i," ######"
                do ! while file not ends
                    buffer=""
                    read(902, '(A)', end=999) buffer !read line
                    write(901,'(A)') trim(buffer)     ! write line
                end do
			endif
            999 continue
			close (902, status='delete')
		end do
		close (901)
	endif
end subroutine
