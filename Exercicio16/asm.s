        PUBLIC  __iar_program_start
        PUBLIC  __vector_table

        SECTION .text:CODE:REORDER(1)
        
        ;; Keep vector table even if it's not referenced
        REQUIRE __vector_table
        
        THUMB
//        
//        Exerc�cio 16
//�
//Altere o exemplo fornecido no projeto � gpio �
//para realizar escritas no registrador GPIODATA
//utilizando a sua vers�o sem mascaramento de
//bits (deslocamento 0x3FC do endere�o base)
//�
//Nessa situa��o, todos os 8 bits do registrador
//GPIODATA podem ser modificados com uma
//escrita portanto, tome cuidado para que a
//escrita altere somente o bit 0 (LED D2)!
        
        
        
SYSCTL_RCGCGPIO_R       EQU     0x400FE608
SYSCTL_PRGPIO_R		EQU     0x400FEA08
PORTN_BIT               EQU     1000000000000b ; bit 12 = Port N

GPIO_PORTN_DATA_R    	EQU     0x40064000
GPIO_PORTN_DIR_R     	EQU     0x40064400
GPIO_PORTN_DEN_R     	EQU     0x4006451C

__iar_program_start
        
main    MOV R2, #PORTN_BIT   // habilita alimenta�o da portaN
	LDR R0, =SYSCTL_RCGCGPIO_R
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R2 ; habilita port N
	STR R1, [R0] ; escrita do novo estado

        LDR R0, =SYSCTL_PRGPIO_R   // aguarda estabiliza��o daporta N
wait	LDR R2, [R0] ; leitura do estado atual
	TEQ R1, R2 ; clock do port N habilitado?
	BNE wait ; caso negativo, aguarda

        MOV R2, #00000001b ; bit 0
        
        // habilita bit zero da porta N como sa�da N0=out
	LDR R0, =GPIO_PORTN_DIR_R
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R2 ; bit de sa�da
	STR R1, [R0] ; escrita do novo estado

        //habilita porta N como digital
	LDR R0, =GPIO_PORTN_DEN_R
	LDR R1, [R0] ; leitura do estado anterior
	ORR R1, R2 ; habilita fun��o digital
	STR R1, [R0] ; escrita do novo estado

        MOV R1, #000000001b ; estado inicial


 	LDR R0, = GPIO_PORTN_DATA_R
        MOV R2, #0x3FC ; deslocamento para acesso sem mascaramento
loop    LDR R4, [R0, R2]; armazena em R4 o estado da porta N, sem mascaramento
        EOR R4, R1 ; executa o OR Exclusivo entre R4 e R1 e armazena em R4
        STR R4, [R0, R2]; coloca na porta Nsem mascaramento, o registrador R4



//loop	STR R1, [R0, R2, LSL #2] ; aciona LED com estado atual
        MOVT R3, #0x000F ; constante de atraso 
delay   CBZ R3, theend ; 1 clock
        SUB R3, R3, #1 ; 1 clock
        B delay ; 3 clocks
theend  //EOR R1, R1, R2 ; troca o estado
        B loop


        ;; Forward declaration of sections.
        SECTION CSTACK:DATA:NOROOT(3)
        SECTION .intvec:CODE:NOROOT(2)
        
        DATA

__vector_table
        DCD     sfe(CSTACK)
        DCD     __iar_program_start

        DCD     NMI_Handler
        DCD     HardFault_Handler
        DCD     MemManage_Handler
        DCD     BusFault_Handler
        DCD     UsageFault_Handler
        DCD     0
        DCD     0
        DCD     0
        DCD     0
        DCD     SVC_Handler
        DCD     DebugMon_Handler
        DCD     0
        DCD     PendSV_Handler
        DCD     SysTick_Handler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Default interrupt handlers.
;;

        PUBWEAK NMI_Handler
        PUBWEAK HardFault_Handler
        PUBWEAK MemManage_Handler
        PUBWEAK BusFault_Handler
        PUBWEAK UsageFault_Handler
        PUBWEAK SVC_Handler
        PUBWEAK DebugMon_Handler
        PUBWEAK PendSV_Handler
        PUBWEAK SysTick_Handler

        SECTION .text:CODE:REORDER:NOROOT(1)
        THUMB

NMI_Handler
HardFault_Handler
MemManage_Handler
BusFault_Handler
UsageFault_Handler
SVC_Handler
DebugMon_Handler
PendSV_Handler
SysTick_Handler
Default_Handler
__default_handler
        CALL_GRAPH_ROOT __default_handler, "interrupt"
        NOCALL __default_handler
        B __default_handler

        END
