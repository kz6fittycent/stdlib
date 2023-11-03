!> The `stdlib_str2num` module provides procedures and interfaces for conversion
!> of characters to numerical types. Currently supported: int32, real32 and real64
!>
!> This code was modified from https://github.com/jalvesz/Fortran-String-to-Num by Alves Jose
!> And was possible thanks to all the discussions in this thread https://fortran-lang.discourse.group/t/faster-string-to-double/
!>

module stdlib_str2num
    use iso_fortran_env, only: sp => real32, dp => real64
    implicit none
    private
    public :: to_num, to_num_p
    
    integer, parameter :: ikind = selected_int_kind(2)
    integer(kind=ikind), parameter :: digit_0    = ichar('0',kind=ikind)
    integer(kind=ikind), parameter :: period     = ichar('.',kind=ikind) - digit_0
    integer(kind=ikind), parameter :: comma      = ichar(',',kind=ikind) - digit_0
    integer(kind=ikind), parameter :: minus_sign = ichar('-',kind=ikind) - digit_0
    integer(kind=ikind), parameter :: plus_sign  = ichar('+',kind=ikind) - digit_0
    integer(kind=ikind), parameter :: Inf        = ichar('I',kind=ikind) - digit_0
    integer(kind=ikind), parameter :: NaN        = ichar('N',kind=ikind) - digit_0
    integer(kind=ikind), parameter :: le         = ichar('e',kind=ikind) - digit_0
    integer(kind=ikind), parameter :: BE         = ichar('E',kind=ikind) - digit_0
    integer(kind=ikind), parameter :: ld         = ichar('d',kind=ikind) - digit_0
    integer(kind=ikind), parameter :: BD         = ichar('D',kind=ikind) - digit_0
    integer(kind=ikind), parameter :: LF = 10, CR = 13, WS = 32

    interface to_num
        module procedure to_int
        module procedure to_float
        module procedure to_double
    end interface

    interface to_num_p
        module procedure to_int_p
        module procedure to_float_p
        module procedure to_double_p
    end interface

    interface to_num_base
        module procedure to_int_32
        module procedure to_real_sp
        module procedure to_real_dp
    end interface
    
    contains
    
    !---------------------------------------------
    ! String To Number interfaces
    !---------------------------------------------

    elemental function to_int(s,mold) result(v)
        ! -- In/out Variables
        character(*), intent(in) :: s !> input string
        integer, intent(in) :: mold !> dummy argument to disambiguate at compile time the generic interface
        integer :: v !> Output integer 32 value
        ! -- Internal Variables
        integer(1) :: p !> position within the number
        integer(1)  :: stat !> error status
        !----------------------------------------------
        call to_num_base(s,v,p,stat)
    end function
    
    function to_int_p(s,mold,stat) result(v)
        ! -- In/out Variables
        character(len=:), pointer :: s !> input string
        integer, intent(in) :: mold !> dummy argument to disambiguate at compile time the generic interface
        integer :: v !> Output integer 32 value
        integer(1),intent(inout), optional :: stat
        ! -- Internal Variables
        integer(1) :: p !> position within the number
        integer(1) :: err
        !----------------------------------------------
        call to_num_base(s,v,p,err)
        p = min( p , len(s) )
        s => s(p:)
        if(present(stat)) stat = err
    end function

    elemental function to_float(s,mold) result(r)
        ! -- In/out Variables
        character(*), intent(in) :: s !> input string
        real(sp), intent(in) :: mold !> dummy argument to disambiguate at compile time the generic interface
        real(sp) :: r !> Output real value
        ! -- Internal Variables
        integer(1) :: p !> position within the number
        integer(1) :: stat ! error status
        !----------------------------------------------
        call to_num_base(s,r,p,stat)
    end function
    
    function to_float_p(s,mold,stat) result(r)
        ! -- In/out Variables
        character(len=:), pointer :: s !> input string
        real(sp), intent(in) :: mold !> dummy argument to disambiguate at compile time the generic interface
        real(sp) :: r    !> Output real value
        integer(1),intent(inout), optional :: stat
        ! -- Internal Variables
        integer(1) :: p !> position within the number
        integer(1) :: err
        !----------------------------------------------
        call to_num_base(s,r,p,err)
        p = min( p , len(s) )
        s => s(p:)
        if(present(stat)) stat = err
    end function

    elemental function to_double(s,mold) result(r)
        ! -- In/out Variables
        character(*), intent(in) :: s !> input string
        real(dp), intent(in) :: mold !> dummy argument to disambiguate at compile time the generic interface
        real(dp) :: r    !> Output real value
        ! -- Internal Variables
        integer(1) :: p !> position within the number
        integer(1) :: stat ! error status
        !----------------------------------------------
        call to_num_base(s,r,p,stat)
    end function
    
    function to_double_p(s,mold,stat) result(r)
        ! -- In/out Variables
        character(len=:), pointer :: s !> input string
        real(dp), intent(in) :: mold !> dummy argument to disambiguate at compile time the generic interface
        real(dp) :: r    !> Output real value
        integer(1),intent(inout), optional :: stat
        ! -- Internal Variables
        integer(1) :: p !> position within the number
        integer(1) :: err
        !----------------------------------------------
        call to_num_base(s,r,p,err)
        p = min( p , len(s) )
        s => s(p:)
        if(present(stat)) stat = err
    end function

    !---------------------------------------------
    ! String To Number Implementations
    !---------------------------------------------

    elemental subroutine to_int_32(s,v,p,stat)
        !> Return an unsigned 32-bit integer
        ! -- In/out Variables
        character(*), intent(in) :: s !> input string
        integer, intent(inout)  :: v !> Output real value
        integer(1), intent(out)  :: p !> position within the number
        integer(1), intent(out)  :: stat !> status upon succes or failure to read
        ! -- Internal Variables
        integer(1)  :: val 
        !----------------------------------------------
        stat = 23 !> initialize error status with any number > 0
        !----------------------------------------------
        ! Find first non white space
        p = mvs2nwsp(s)
        !----------------------------------------------
        v = 0
        do while( p<=len(s) )
            val = iachar(s(p:p))-digit_0
            if( val >= 0 .and. val <= 9) then
                v = v*10 + val ; p = p + 1
            else
                exit
            end if
        end do
        stat = 0
    end subroutine

    elemental subroutine to_real_sp(s,v,p,stat)
        integer, parameter :: wp    = sp
        !> Sequentially unroll the character and get the sub integers composing the whole number, fraction and exponent
        ! -- In/out Variables
        character(*), intent(in) :: s !> input string
        real(wp), intent(inout)  :: v !> Output real value
        integer(1), intent(out)  :: p !> last position within the string
        integer(1), intent(out)  :: stat !> status upon success or failure to read

        ! -- Internal Variables
        real(wp), parameter :: rNaN = real(z'7fc00000',wp)
        real(wp), parameter :: rInf = real(z'7f800000',wp) ! neginf = real(z'ff800000',wp)
        integer(kind=ikind), parameter :: nwnb = 39 !> number of whole number factors
        integer(kind=ikind), parameter :: nfnb = 37 !> number of fractional number factors
        integer :: e
        real(dp), parameter :: whole_number_base(nwnb)   = [(10._dp**(nwnb-e),e=1,nwnb)]
        real(dp), parameter :: fractional_base(nfnb)   = [(10._dp**(-e),e=1,nfnb)]
        real(dp), parameter :: expbase(nwnb+nfnb) = [whole_number_base, fractional_base]

        integer(1)  :: sign, sige !> sign of integer number and exponential
        integer(wp) :: int_wp !> long integer to capture fractional part
        integer     :: i_exp !> integer to capture whole number part
        integer     :: exp_aux
        integer(1)  :: i, pP, pE, val , resp
        !----------------------------------------------
        stat = 23 !> initialize error status with any number > 0
        !----------------------------------------------
        ! Find first non white space
        p = mvs2nwsp(s)
        !----------------------------------------------
        ! Verify leading negative
        sign = 1
        if( iachar(s(p:p)) == minus_sign+digit_0 ) then
            sign = -1 ; p = p + 1
        end if
        if( iachar(s(p:p)) == Inf ) then
            v = sign*rInf; return
        else if( iachar(s(p:p)) == NaN ) then
            v = rNaN; return
        end if
        !----------------------------------------------
        ! read whole and fractional number in a single integer
        pP = 127
        int_wp = 0
        do i = p, min(10+p-1,len(s))
            val = iachar(s(i:i))-digit_0
            if( val >= 0 .and. val <= 9 ) then
                int_wp = int_wp*10 + val
            else if( val == period ) then
                pP = i
            else
                exit
            end if
        end do
        pE = i ! Fix the exponent position
        do while( i<=len(s) )
           val = iachar(s(i:i))-digit_0
           if( val < 0 .or. val > 9 ) exit
           i = i + 1
        end do
        p = i
        resp = pE-min(pP,p) ! If no decimal indicator found it is taken as being in the current p position
        if( resp <= 0 ) resp = resp+1 
        !----------------------------------------------
        ! Get exponential
        sige = 1
        if( p<len(s) ) then
            if( any([le,BE,ld,BD]+digit_0==iachar(s(p:p))) ) p = p + 1
            if( iachar(s(p:p)) == minus_sign+digit_0 ) then
                sige = -1
                p = p + 1
            else if( iachar(s(p:p)) == plus_sign+digit_0 ) then
                p = p + 1
            end if
        end if
        
        i_exp = 0
        do while( p<=len(s) )
            val = iachar(s(p:p))-digit_0
            if( val >= 0 .and. val <= 9) then
                i_exp = i_exp*10_ikind + val ; p = p + 1
            else
                exit
            end if
        end do
        
        exp_aux = nwnb-1+resp-sige*max(0,i_exp)
        if( exp_aux>0 .and. exp_aux<=nwnb+nfnb) then
            v = sign*int_wp*expbase(exp_aux)
        else
            v = sign*int_wp*10._dp**(sige*max(0,i_exp)-resp+1)
        end if
        stat = 0
    end subroutine

    elemental subroutine to_real_dp(s,v,p,stat)
        integer, parameter :: wp    = dp
        !> Sequentially unroll the character and get the sub integers composing the whole number, fraction and exponent
        ! -- In/out Variables
        character(*), intent(in) :: s !> input string
        real(wp), intent(inout)  :: v !> Output real value
        integer(1), intent(out)  :: p !> last position within the string
        integer(1), intent(out)  :: stat !> status upon success or failure to read

        ! -- Internal Variables
        real(wp), parameter :: rNaN = real(z'7ff8000000000000',wp)
        real(wp), parameter :: rInf = real(z'fff0000000000000',wp) ! neginf = real(z'fff0000000000000',wp)
        integer(kind=ikind), parameter :: nwnb = 40 !> number of whole number factors
        integer(kind=ikind), parameter :: nfnb = 64 !> number of fractional number factors
        integer :: e
        real(wp), parameter :: whole_number_base(nwnb)   = [(10._wp**(nwnb-e),e=1,nwnb)]
        real(wp), parameter :: fractional_base(nfnb)   = [(10._wp**(-e),e=1,nfnb)]
        real(wp), parameter :: expbase(nwnb+nfnb) = [whole_number_base, fractional_base]

        integer(1)  :: sign, sige !> sign of integer number and exponential
        integer(wp) :: int_wp !> long integer to capture fractional part
        integer     :: i_exp !> integer to capture whole number part
        integer     :: exp_aux
        integer(1)  :: i, pP, pE, val , resp
        !----------------------------------------------
        stat = 23 !> initialize error status with any number > 0
        !----------------------------------------------
        ! Find first non white space
        p = mvs2nwsp(s)
        !----------------------------------------------
        ! Verify leading negative
        sign = 1
        if( iachar(s(p:p)) == minus_sign+digit_0 ) then
            sign = -1 ; p = p + 1
        end if
        if( iachar(s(p:p)) == Inf ) then
            v = sign*rInf; return
        else if( iachar(s(p:p)) == NaN ) then
            v = rNaN; return
        end if
        !----------------------------------------------
        ! read whole and fractional number in a single integer
        pP = 127
        int_wp = 0
        do i = p, min(19+p-1,len(s))
            val = iachar(s(i:i))-digit_0
            if( val >= 0 .and. val <= 9 ) then
                int_wp = int_wp*10 + val
            else if( val == period ) then
                pP = i
            else
                exit
            end if
        end do
        pE = i ! Fix the exponent position
        do while( i<=len(s) )
           val = iachar(s(i:i))-digit_0
           if( val < 0 .or. val > 9 ) exit
           i = i + 1
        end do
        p = i
        resp = pE-min(pP,p) ! If no decimal indicator found it is taken as being in the current p position
        if( resp <= 0 ) resp = resp+1 
        !----------------------------------------------
        ! Get exponential
        sige = 1
        if( p<len(s) ) then
            if( any([le,BE,ld,BD]+digit_0==iachar(s(p:p))) ) p = p + 1
            if( iachar(s(p:p)) == minus_sign+digit_0 ) then
                sige = -1
                p = p + 1
            else if( iachar(s(p:p)) == plus_sign+digit_0 ) then
                p = p + 1
            end if
        end if
        
        i_exp = 0
        do while( p<=len(s) )
            val = iachar(s(p:p))-digit_0
            if( val >= 0 .and. val <= 9) then
                i_exp = i_exp*10_ikind + val ; p = p + 1
            else
                exit
            end if
        end do
        
        exp_aux = nwnb-1+resp-sige*max(0,i_exp)
        if( exp_aux>0 .and. exp_aux<=nwnb+nfnb) then
            v = sign*int_wp*expbase(exp_aux)
        else
            v = sign*int_wp*10._wp**(sige*max(0,i_exp)-resp+1)
        end if
        stat = 0
    end subroutine
    
    !---------------------------------------------
    ! Internal Utility functions
    !---------------------------------------------
    
    elemental function mvs2nwsp(s) result(p)
        !> move string to position of the next non white space character
        character(*),intent(in) :: s !> character chain
        integer(1) :: p !> position
        !----------------------------------------------
        p = 1
        do while( p<len(s) .and. (iachar(s(p:p))==WS.or.iachar(s(p:p))==LF.or.iachar(s(p:p))==CR) ) 
            p = p + 1
        end do
    end function
    
    elemental function mvs2wsp(s) result(p)
        !> move string to position of the next white space character
        character(*),intent(in) :: s !> character chain
        integer(1) :: p !> position
        !----------------------------------------------
        p = 1
        do while( p<len(s) .and. .not.(iachar(s(p:p))==WS.or.iachar(s(p:p))==LF.or.iachar(s(p:p))==CR) ) 
            p = p + 1
        end do
    end function
    
end module stdlib_str2num