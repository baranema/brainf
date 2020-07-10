.global brainfuck

.text
printcharacter: .asciz "%c"
scancharacter: .asciz "%lc"

# Your brainfuck subroutine will receive one argument:
# a zero terminated string which is the code to execute.

switchsub:
      incq  %r12          # increase r12
      movb  (%r12), %al   # copy the value to register %al

      cmpb  $0, %al       # if the value is zero - end the program
      je    return

      cmpb  $62, %al      # if the character is >
      je    greater       # go to greater subroutine

      cmpb  $60, %al      # if the character is < 
      je    less          # then go to less subroutine

      cmpb  $43, %al      # if the character is +
      je    plus          # go to plus subroutine

      cmpb  $45, %al      # if the character is -
      je    min           # go to min subroutine

      cmpb  $46, %al      # if the character is .
      je    dot           # go to dot subroutine

      cmpb  $44, %al      # if the character is ,
      je    comma         # go to comma subroutine

      cmpb  $91, %al      # if the character is [
      je    loopstart     # it is a loop and go to loopstart subroutine

      cmpb  $93, %al      # if the character is ]
      je    loopend       # it is end of the loop, go to loopend subroutine

      jmp   switchsub     # repeat switchsub 

greater:
      inc   %r13          # increment the data pointer (to point to the next cell to the right)
      jmp   switchsub     # go back to switchsub
      
less:
      dec   %r13          # decrement the data pointer (to point to the next cell to the right)
      jmp   switchsub     # go back to switchsub

plus:
      incb    (%r13)        # increase by one the byte at the data pointer %r13
      jmp     switchsub     # go back to switchsub

min:
      decb    (%r13)        # decrease by one the byte at the data pointer %r13
      jmp     switchsub     # go back to switchsub

# if the byte at the data ponter is zero, then instead
# of moving the instruction pointer forward to the next
# command, jump it forward to the command after the matching with [
loopstart:
      cmpb    $0, (%r13)    # if the value in %r13 is 0 then go to nestedloop subroutine
      je      nestedloop    # repeat switchsub

      pushq   %r12        # push %r12 into the stack
      jmp     switchsub     # repeat switchsub

# looking for a nested loop
nestedloop:             
      incq    %r12          # increase %r12 value by one to fetch the next instruction 
      movb    (%r12), %al   # move the value of %r12 the character inside %r12 to %al

      cmpb    $91, %al      # if the value is [
      je      startcounter  # go the startcounter subroutine

      cmpb    $93, %al      # if the value is ] 
      je      endcounter    # go to endcounter subroutine

      jmp     nestedloop        # repeat nestedloop

startcounter:
      incq    %r14              # increase counter by one and continue to move it to the next cell
      jmp     nestedloop        # repeat nestedloop

endcounter:
      cmpq    $0, %r14     
      je      switchsub         # if the counter %r14 is 0 then repeat switchsub
      
      decq    %r14              # decrement %r14 to go to the previous cell
      jmp     nestedloop        # repeat nestedloop

# if the byte at the data pointer is not zero, 
# then instead of moving the instruction pointer forward to the
# next command, jump it back to the command
# after the matching with [
loopend:
      popq    %r12          # Take out of the stack the value stored in %r12
      decq    %r12          # Decrement the pointer to the starting position
      jmp     switchsub        # Goes back to switch

dot:
      movq    $printcharacter, %rdi    # load character value into %rdi
      movq    (%r13), %rsi             # move the value from %r13 to %rsi
      movq    $0, %rax                 # clear %rax
      call    printf                   # output the byte at the data pointer 

      jmp     switchsub                # repeat switchsub

comma:
      movq    $scancharacter, %rdi    # loads character value into %rdi
      movq    %r13, %rsi              # move the value from %r13 to %rsi
      movq    $0, %rax                # clear rax

      # accept one byte of input, storing its value in the byte at the data pointer                                        
      call    scanf              # call scanf to scan the number
      
      jmp     switchsub          # repeat switchsub

brainfuck:
      pushq   %rbp               # push the base pointer
      movq    %rsp, %rbp         # copy stack pointer to %rbp

      movq    %rdi, %r12         # %rdi has character value which if moved to a register r12

      movq    $1000000, %rdi     # new cells to store the characters
      movq    $1 , %rsi          # each cell has a size of 8 bits 
      call    calloc             # calling calloc function 
                                 # this function can allocate memory dynamically during 
                                 # runtime (execution of the program)

      movq    %rax, %r13         # using %r13 to execute instructions
      decq    %r12               # decrementing the pointer
                                 # that it would point to nothing

      call    switchsub          # call switchsub subroutine                  
return:
      movq    %rbp, %rsp            # clear local variables from stack
      popq    %rbp                  # restore the base pointer

      ret
