! SPDX-Identifier: MIT

!> This module implements basic string handling routines.
!>
!> The specification of this module is available [here](../page/specs/stdlib_strings.html).
module stdlib_strings
    use stdlib_ascii, only: whitespace
    use stdlib_string_type, only: string_type, char, verify, repeat
    use stdlib_optval, only: optval
    implicit none
    private

    public :: strip, chomp
    public :: starts_with, ends_with
    public :: slice, find, replace_all


    !> Remove leading and trailing whitespace characters.
    !>
    !> Version: experimental
    interface strip
        module procedure :: strip_string
        module procedure :: strip_char
    end interface strip

    !> Remove trailing characters in set from string.
    !> If no character set is provided trailing whitespace is removed.
    !>
    !> Version: experimental
    interface chomp
        module procedure :: chomp_string
        module procedure :: chomp_char
        module procedure :: chomp_set_string_char
        module procedure :: chomp_set_char_char
        module procedure :: chomp_substring_string_string
        module procedure :: chomp_substring_char_string
        module procedure :: chomp_substring_string_char
        module procedure :: chomp_substring_char_char
    end interface chomp


    !> Check whether a string starts with substring or not
    !>
    !> Version: experimental
    interface starts_with
        module procedure :: starts_with_string_string
        module procedure :: starts_with_string_char
        module procedure :: starts_with_char_string
        module procedure :: starts_with_char_char
    end interface starts_with


    !> Check whether a string ends with substring or not
    !>
    !> Version: experimental
    interface ends_with
        module procedure :: ends_with_string_string
        module procedure :: ends_with_string_char
        module procedure :: ends_with_char_string
        module procedure :: ends_with_char_char
    end interface ends_with
    
    !> Extracts characters from the input string to return a new string
    !> 
    !> Version: experimental
    interface slice
        module procedure :: slice_string
        module procedure :: slice_char
    end interface slice

    !> Finds the starting index of substring 'pattern' in the input 'string'
    !> [Specifications](link to the specs - to be completed)
    !> 
    !> Version: experimental
    interface find
        module procedure :: find_string_string
        module procedure :: find_string_char
        module procedure :: find_char_string
        module procedure :: find_char_char
    end interface find

    !> Replaces all the occurrences of substring 'pattern' in the input 'string'
    !> with the replacement 'replacement'
    !> Version: experimental
    interface replace_all
        module procedure :: replace_all_string_string_string
        module procedure :: replace_all_string_string_char
        module procedure :: replace_all_string_char_string
        module procedure :: replace_all_char_string_string
        module procedure :: replace_all_string_char_char
        module procedure :: replace_all_char_string_char
        module procedure :: replace_all_char_char_string
        module procedure :: replace_all_char_char_char
    end interface replace_all

    !> Left pad the input string
    !> [Specifications](link to the specs - to be completed)
    !> Version: experimental
    interface padl
        module procedure :: padl_string_string
        module procedure :: padl_string_char
        module procedure :: padl_char_string
        module procedure :: padl_char_char
    end interface padl

    !> Right pad the input string
    !> [Specifications](link to the specs - to be completed)
    !> Version: experimental
    interface padr
        module procedure :: padr_string_string
        module procedure :: padr_string_char
        module procedure :: padr_char_string
        module procedure :: padr_char_char
    end interface padr

contains


    !> Remove leading and trailing whitespace characters.
    pure function strip_string(string) result(stripped_string)
        ! Avoid polluting the module scope and use the assignment only in this scope 
        use stdlib_string_type, only : assignment(=)
        type(string_type), intent(in) :: string
        type(string_type) :: stripped_string

        stripped_string = strip(char(string))
    end function strip_string

    !> Remove leading and trailing whitespace characters.
    pure function strip_char(string) result(stripped_string)
        character(len=*), intent(in) :: string
        character(len=:), allocatable :: stripped_string
        integer :: first, last

        first = verify(string, whitespace)
        if (first == 0) then
           stripped_string = ""
        else
           last = verify(string, whitespace, back=.true.)
           stripped_string = string(first:last)
        end if

    end function strip_char


    !> Remove trailing characters in set from string.
    !> Default character set variant where trailing whitespace is removed.
    pure function chomp_string(string) result(chomped_string)
        ! Avoid polluting the module scope and use the assignment only in this scope 
        use stdlib_string_type, only : assignment(=)
        type(string_type), intent(in) :: string
        type(string_type) :: chomped_string
        integer :: last

        last = verify(string, whitespace, back=.true.)
        chomped_string = char(string, 1, last)
    end function chomp_string

    !> Remove trailing characters in set from string.
    !> Default character set variant where trailing whitespace is removed.
    pure function chomp_char(string) result(chomped_string)
        character(len=*), intent(in) :: string
        character(len=:), allocatable :: chomped_string
        integer :: last

        last = verify(string, whitespace, back=.true.)
        chomped_string = string(1:last)
    end function chomp_char

    !> Remove trailing characters in set from string.
    pure function chomp_set_string_char(string, set) result(chomped_string)
        ! Avoid polluting the module scope and use the assignment only in this scope 
        use stdlib_string_type, only : assignment(=)
        type(string_type), intent(in) :: string
        character(len=1), intent(in) :: set(:)
        type(string_type) :: chomped_string

        chomped_string = chomp(char(string), set)
    end function chomp_set_string_char

    !> Remove trailing characters in set from string.
    pure function chomp_set_char_char(string, set) result(chomped_string)
        character(len=*), intent(in) :: string
        character(len=1), intent(in) :: set(:)
        character(len=:), allocatable :: chomped_string
        integer :: last

        last = verify(string, set_to_string(set), back=.true.)
        chomped_string = string(1:last)

    end function chomp_set_char_char

    !> Remove trailing substrings from string.
    pure function chomp_substring_string_string(string, substring) result(chomped_string)
        ! Avoid polluting the module scope and use the assignment only in this scope 
        use stdlib_string_type, only : assignment(=)
        type(string_type), intent(in) :: string
        type(string_type), intent(in) :: substring
        type(string_type) :: chomped_string

        chomped_string = chomp(char(string), char(substring))
    end function chomp_substring_string_string

    !> Remove trailing substrings from string.
    pure function chomp_substring_string_char(string, substring) result(chomped_string)
        ! Avoid polluting the module scope and use the assignment only in this scope 
        use stdlib_string_type, only : assignment(=)
        type(string_type), intent(in) :: string
        character(len=*), intent(in) :: substring
        type(string_type) :: chomped_string

        chomped_string = chomp(char(string), substring)
    end function chomp_substring_string_char

    !> Remove trailing substrings from string.
    pure function chomp_substring_char_string(string, substring) result(chomped_string)
        character(len=*), intent(in) :: string
        type(string_type), intent(in) :: substring
        character(len=:), allocatable :: chomped_string

        chomped_string = chomp(string, char(substring))
    end function chomp_substring_char_string

    !> Remove trailing substrings from string.
    pure function chomp_substring_char_char(string, substring) result(chomped_string)
        character(len=*), intent(in) :: string
        character(len=*), intent(in) :: substring
        character(len=:), allocatable :: chomped_string
        integer :: last, nsub

        last = len(string)
        nsub = len(substring)
        if (nsub > 0) then
            do while(string(last-nsub+1:last) == substring)
                last = last - nsub
            end do
        end if
        chomped_string = string(1:last)

    end function chomp_substring_char_char

    !> Implementation to transfer a set of characters to a string representing the set.
    !>
    !> This function is internal and not part of the public API.
    pure function set_to_string(set) result(string)
        character(len=1), intent(in) :: set(:)
        character(len=size(set)) :: string

        string = transfer(set, string)
    end function set_to_string


    !> Check whether a string starts with substring or not
    pure function starts_with_char_char(string, substring) result(match)
        character(len=*), intent(in) :: string
        character(len=*), intent(in) :: substring
        logical :: match
        integer :: nsub

        nsub = len(substring)
        if (len(string) < nsub) then
            match = .false.
            return
        end if
        match = string(1:nsub) == substring

    end function starts_with_char_char

    !> Check whether a string starts with substring or not
    elemental function starts_with_string_char(string, substring) result(match)
        type(string_type), intent(in) :: string
        character(len=*), intent(in) :: substring
        logical :: match

        match = starts_with(char(string), substring)

    end function starts_with_string_char

    !> Check whether a string starts with substring or not
    elemental function starts_with_char_string(string, substring) result(match)
        character(len=*), intent(in) :: string
        type(string_type), intent(in) :: substring
        logical :: match

        match = starts_with(string, char(substring))

    end function starts_with_char_string

    !> Check whether a string starts with substring or not
    elemental function starts_with_string_string(string, substring) result(match)
        type(string_type), intent(in) :: string
        type(string_type), intent(in) :: substring
        logical :: match

        match = starts_with(char(string), char(substring))

    end function starts_with_string_string


    !> Check whether a string ends with substring or not
    pure function ends_with_char_char(string, substring) result(match)
        character(len=*), intent(in) :: string
        character(len=*), intent(in) :: substring
        logical :: match
        integer :: last, nsub

        last = len(string)
        nsub = len(substring)
        if (last < nsub) then
            match = .false.
            return
        end if
        match = string(last-nsub+1:last) == substring

    end function ends_with_char_char

    !> Check whether a string ends with substring or not
    elemental function ends_with_string_char(string, substring) result(match)
        type(string_type), intent(in) :: string
        character(len=*), intent(in) :: substring
        logical :: match

        match = ends_with(char(string), substring)

    end function ends_with_string_char

    !> Check whether a string ends with substring or not
    elemental function ends_with_char_string(string, substring) result(match)
        character(len=*), intent(in) :: string
        type(string_type), intent(in) :: substring
        logical :: match

        match = ends_with(string, char(substring))

    end function ends_with_char_string

    !> Check whether a string ends with substring or not
    elemental function ends_with_string_string(string, substring) result(match)
        type(string_type), intent(in) :: string
        type(string_type), intent(in) :: substring
        logical :: match

        match = ends_with(char(string), char(substring))

    end function ends_with_string_string

    !> Extract the characters from the region between 'first' and 'last' index (both inclusive)
    !> of the input 'string' by taking strides of length 'stride'
    !> Returns a new string
    elemental function slice_string(string, first, last, stride) result(sliced_string)
        type(string_type), intent(in) :: string
        integer, intent(in), optional :: first, last, stride
        type(string_type) :: sliced_string

        sliced_string = string_type(slice(char(string), first, last, stride))

    end function slice_string

    !> Extract the characters from the region between 'first' and 'last' index (both inclusive)
    !> of the input 'string' by taking strides of length 'stride'
    !> Returns a new string
    pure function slice_char(string, first, last, stride) result(sliced_string)
        character(len=*), intent(in) :: string
        integer, intent(in), optional :: first, last, stride
        integer :: first_index, last_index, stride_vector, strides_taken, length_string, i, j
        character(len=:), allocatable :: sliced_string
        length_string = len(string)

        first_index = 0                 ! first_index = -infinity
        last_index = length_string + 1  ! last_index = +infinity
        stride_vector = 1

        if (present(stride)) then
            if (stride /= 0) then
                if (stride < 0) then
                    first_index = length_string + 1     ! first_index = +infinity
                    last_index = 0                      ! last_index = -infinity
                end if
                stride_vector = stride
            end if
        else
            if (present(first) .and. present(last)) then
                if (last < first) then
                    stride_vector = -1
                end if
            end if
        end if

        if (present(first)) then
            first_index = first
        end if
        if (present(last)) then
            last_index = last
        end if
        
        if (stride_vector > 0) then
            first_index = max(first_index, 1)
            last_index = min(last_index, length_string)
        else
            first_index = min(first_index, length_string)
            last_index = max(last_index, 1)
        end if
        
        strides_taken = floor( real(last_index - first_index)/real(stride_vector) )
        allocate(character(len=max(0, strides_taken + 1)) :: sliced_string)
        
        j = 1
        do i = first_index, last_index, stride_vector
            sliced_string(j:j) = string(i:i)
            j = j + 1
        end do
    end function slice_char

    !> Returns the starting index of the 'occurrence'th occurrence of substring 'pattern'
    !> in input 'string'
    !> Returns an integer
    elemental function find_string_string(string, pattern, occurrence, consider_overlapping) result(res)
        type(string_type), intent(in) :: string
        type(string_type), intent(in) :: pattern
        integer, intent(in), optional :: occurrence
        logical, intent(in), optional :: consider_overlapping
        integer :: res

        res = find(char(string), char(pattern), occurrence, consider_overlapping)

    end function find_string_string

    !> Returns the starting index of the 'occurrence'th occurrence of substring 'pattern'
    !> in input 'string'
    !> Returns an integer
    elemental function find_string_char(string, pattern, occurrence, consider_overlapping) result(res)
        type(string_type), intent(in) :: string
        character(len=*), intent(in) :: pattern
        integer, intent(in), optional :: occurrence
        logical, intent(in), optional :: consider_overlapping
        integer :: res

        res = find(char(string), pattern, occurrence, consider_overlapping)

    end function find_string_char

    !> Returns the starting index of the 'occurrence'th occurrence of substring 'pattern'
    !> in input 'string'
    !> Returns an integer
    elemental function find_char_string(string, pattern, occurrence, consider_overlapping) result(res)
        character(len=*), intent(in) :: string
        type(string_type), intent(in) :: pattern
        integer, intent(in), optional :: occurrence
        logical, intent(in), optional :: consider_overlapping
        integer :: res

        res = find(string, char(pattern), occurrence, consider_overlapping)

    end function find_char_string

    !> Returns the starting index of the 'occurrence'th occurrence of substring 'pattern'
    !> in input 'string'
    !> Returns an integer
    elemental function find_char_char(string, pattern, occurrence, consider_overlapping) result(res)
        character(len=*), intent(in) :: string
        character(len=*), intent(in) :: pattern
        integer, intent(in), optional :: occurrence
        logical, intent(in), optional :: consider_overlapping
        integer :: lps_array(len(pattern))
        integer :: res, s_i, p_i, length_string, length_pattern, occurrence_
        logical :: consider_overlapping_

        consider_overlapping_ = optval(consider_overlapping, .true.)
        occurrence_ = optval(occurrence, 1)
        res = 0
        length_string = len(string)
        length_pattern = len(pattern)

        if (length_pattern > 0 .and. length_pattern <= length_string & 
            & .and. occurrence_ > 0) then
            lps_array = compute_lps(pattern)

            s_i = 1
            p_i = 1
            do while(s_i <= length_string)
                if (string(s_i:s_i) == pattern(p_i:p_i)) then
                    if (p_i == length_pattern) then
                        occurrence_ = occurrence_ - 1
                        if (occurrence_ == 0) then
                            res = s_i - length_pattern + 1
                            exit
                        else if (consider_overlapping_) then
                            p_i = lps_array(p_i)
                        else
                            p_i = 0
                        end if
                    end if
                    s_i = s_i + 1
                    p_i = p_i + 1
                else if (p_i > 1) then
                    p_i = lps_array(p_i - 1) + 1
                else
                    s_i = s_i + 1
                end if
            end do
        end if
    
    end function find_char_char

    !> Computes longest prefix suffix for each index of the input 'string'
    !> 
    !> Returns an array of integers
    pure function compute_lps(string) result(lps_array)
        character(len=*), intent(in) :: string
        integer :: lps_array(len(string))
        integer :: i, j, length_string
        
        length_string = len(string)

        if (length_string > 0) then
            lps_array(1) = 0

            i = 2
            j = 1
            do while (i <= length_string)
                if (string(j:j) == string(i:i)) then
                    lps_array(i) = j
                    i = i + 1
                    j = j + 1
                else if (j > 1) then
                    j = lps_array(j - 1) + 1
                else
                    lps_array(i) = 0
                    i = i + 1
                end if
            end do
        end if
    
    end function compute_lps

    !> Replaces all occurrences of substring 'pattern' in the input 'string'
    !> with the replacement 'replacement'
    !> Returns a new string
    pure function replace_all_string_string_string(string, pattern, replacement) result(res)
        type(string_type), intent(in) :: string
        type(string_type), intent(in) :: pattern
        type(string_type), intent(in) :: replacement
        type(string_type) :: res

        res = string_type(replace_all(char(string), & 
                & char(pattern), char(replacement)))

    end function replace_all_string_string_string

    !> Replaces all occurrences of substring 'pattern' in the input 'string'
    !> with the replacement 'replacement'
    !> Returns a new string
    pure function replace_all_string_string_char(string, pattern, replacement) result(res)
        type(string_type), intent(in) :: string
        type(string_type), intent(in) :: pattern
        character(len=*), intent(in) :: replacement
        type(string_type) :: res

        res = string_type(replace_all(char(string), char(pattern), replacement))

    end function replace_all_string_string_char

    !> Replaces all occurrences of substring 'pattern' in the input 'string'
    !> with the replacement 'replacement'
    !> Returns a new string
    pure function replace_all_string_char_string(string, pattern, replacement) result(res)
        type(string_type), intent(in) :: string
        character(len=*), intent(in) :: pattern
        type(string_type), intent(in) :: replacement
        type(string_type) :: res

        res = string_type(replace_all(char(string), pattern, char(replacement)))

    end function replace_all_string_char_string

    !> Replaces all occurrences of substring 'pattern' in the input 'string'
    !> with the replacement 'replacement'
    !> Returns a new string
    pure function replace_all_char_string_string(string, pattern, replacement) result(res)
        character(len=*), intent(in) :: string
        type(string_type), intent(in) :: pattern
        type(string_type), intent(in) :: replacement
        character(len=:), allocatable :: res

        res = replace_all(string, char(pattern), char(replacement))

    end function replace_all_char_string_string

    !> Replaces all occurrences of substring 'pattern' in the input 'string'
    !> with the replacement 'replacement'
    !> Returns a new string
    pure function replace_all_string_char_char(string, pattern, replacement) result(res)
        type(string_type), intent(in) :: string
        character(len=*), intent(in) :: pattern
        character(len=*), intent(in) :: replacement
        type(string_type) :: res

        res = string_type(replace_all(char(string), pattern, replacement))

    end function replace_all_string_char_char

    !> Replaces all occurrences of substring 'pattern' in the input 'string'
    !> with the replacement 'replacement'
    !> Returns a new string
    pure function replace_all_char_string_char(string, pattern, replacement) result(res)
        character(len=*), intent(in) :: string
        type(string_type), intent(in) :: pattern
        character(len=*), intent(in) :: replacement
        character(len=:), allocatable :: res

        res = replace_all(string, char(pattern), replacement)

    end function replace_all_char_string_char

    !> Replaces all occurrences of substring 'pattern' in the input 'string'
    !> with the replacement 'replacement'
    !> Returns a new string
    pure function replace_all_char_char_string(string, pattern, replacement) result(res)
        character(len=*), intent(in) :: string
        character(len=*), intent(in) :: pattern
        type(string_type), intent(in) :: replacement
        character(len=:), allocatable :: res

        res = replace_all(string, pattern, char(replacement))

    end function replace_all_char_char_string

    !> Replaces all the occurrences of substring 'pattern' in the input 'string'
    !> with the replacement 'replacement'
    !> Returns a new string
    pure function replace_all_char_char_char(string, pattern, replacement) result(res)
        character(len=*), intent(in) :: string
        character(len=*), intent(in) :: pattern
        character(len=*), intent(in) :: replacement
        character(len=:), allocatable :: res
        integer :: lps_array(len(pattern))
        integer :: s_i, p_i, last, length_string, length_pattern

        res = ""
        length_string = len(string)
        length_pattern = len(pattern)
        last = 1
        
        if (length_pattern > 0 .and. length_pattern <= length_string) then
            lps_array = compute_lps(pattern)

            s_i = 1
            p_i = 1
            do while (s_i <= length_string)
                if (string(s_i:s_i) == pattern(p_i:p_i)) then
                    if (p_i == length_pattern) then
                        res = res // &
                                & string(last : s_i - length_pattern) // &
                                & replacement
                        last = s_i + 1
                        p_i = 0
                    end if
                    s_i = s_i + 1
                    p_i = p_i + 1
                else if (p_i > 1) then
                    p_i = lps_array(p_i - 1) + 1
                else
                    s_i = s_i + 1
                end if
            end do
        end if
        
        res = res // string(last : length_string)

    end function replace_all_char_char_char

    !> Left pad the input string with the 'pad_with' string
    !>
    !> Returns a new string
    pure function padl_string_string(string, output_length, pad_with) result(res)
        type(string_type), intent(in) :: string
        integer, intent(in) :: output_length
        type(string_type), intent(in) :: pad_with
        type(string_type) :: res

        res = string_type(padl_char_char(char(string), output_length, char(pad_with)))
    end function padl_string_string

    !> Left pad the input string with the 'pad_with' string
    !>
    !> Returns a new string
    pure function padl_string_char(string, output_length, pad_with) result(res)
        type(string_type), intent(in) :: string
        integer, intent(in) :: output_length
        character(len=1), intent(in) :: pad_with
        type(string_type) :: res

        res = string_type(padl_char_char(char(string), output_length, pad_with))
    end function padl_string_char

    !> Left pad the input string with the 'pad_with' string
    !>
    !> Returns a new string
    pure function padl_char_string(string, output_length, pad_with) result(res)
        character(len=*), intent(in) :: string
        integer, intent(in) :: output_length
        type(string_type), intent(in) :: pad_with
        character(len=max(len(string), output_length)) :: res

        res = padl_char_char(string, output_length, char(pad_with))
    end function padl_char_string

    !> Left pad the input string with the 'pad_with' string
    !>
    !> Returns a new string
    pure function padl_char_char(string, output_length, pad_with) result(res)
        character(len=*), intent(in) :: string
        integer, intent(in) :: output_length
        character(len=1), intent(in) :: pad_with
        character(len=max(len(string), output_length)) :: res
        integer :: string_length
    
        string_length = len(string)
    
        if (string_length < output_length) then
            res = repeat(pad_with, output_length - string_length)
            res(output_length - string_length + 1 : output_length) = string
        else
            res = string
        end if
    
    end function padl_char_char

    !> Right pad the input string with the 'pad_with' string
    !>
    !> Returns a new string
    pure function padr_string_string(string, output_length, pad_with) result(res)
        type(string_type), intent(in) :: string
        integer, intent(in) :: output_length
        type(string_type), intent(in) :: pad_with
        type(string_type) :: res

        res = string_type(padr_char_char(char(string), output_length, char(pad_with)))
    end function padr_string_string

    !> Right pad the input string with the 'pad_with' string
    !>
    !> Returns a new string
    pure function padr_string_char(string, output_length, pad_with) result(res)
        type(string_type), intent(in) :: string
        integer, intent(in) :: output_length
        character(len=1), intent(in) :: pad_with
        type(string_type) :: res

        res = string_type(padr_char_char(char(string), output_length, pad_with))
    end function padr_string_char

    !> Right pad the input string with the 'pad_with' string
    !>
    !> Returns a new string
    pure function padr_char_string(string, output_length, pad_with) result(res)
        character(len=*), intent(in) :: string
        integer, intent(in) :: output_length
        type(string_type), intent(in) :: pad_with
        character(len=max(len(string), output_length)) :: res

        res = padr_char_char(string, output_length, char(pad_with))
    end function padr_char_string

    !> Right pad the input string with the 'pad_with' character
    !>
    !> Returns a new string
    pure function padr_char_char(string, output_length, pad_with) result(res)
        character(len=*), intent(in) :: string
        integer, intent(in) :: output_length
        character(len=1), intent(in) :: pad_with
        character(len=max(len(string), output_length)) :: res
        integer :: string_length

        string_length = len(string)
    
        res = string
        if (string_length < output_length) then
            res(string_length + 1 : output_length) = repeat(pad_with, &
            & output_length - string_length)
        end if
    
    end function padr_char_char


end module stdlib_strings
