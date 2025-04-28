.syntax unified
.global main
.section .text

@Direcciones
.equ STK_BASE, 0xE000E010
.equ STK_CTRL, STK_BASE + 0x00
.equ STK_LOAD, STK_BASE + 0x04
.equ RCC_BASE, 0x40021000
.equ RCC_AHB2ENR, RCC_BASE + 0x4C
.equ GPIOA_BASE, 0x48000000
.equ GPIOA_MODER, GPIOA_BASE + 0x00
.equ GPIOA_ODR, GPIOA_BASE + 0x14
.equ LED_PIN, 5
.equ GPIOC_BASE, 0x48000800
.equ GPIOC_MODER, GPIOC_BASE + 0x00
.equ GPIOC_IDR, GPIOC_BASE + 0x10
.equ BUTTON_PIN, 13

main:
    bl configure_gpio
    bl SysTick_inicio

bucle:
    ldr r1, =GPIOC_IDR
    ldr r2, [r1]
    tst r2, #(1 << BUTTON_PIN)
    beq led_encendido
    b bucle

led_encendido:
    ldr r1, =GPIOA_ODR
    ldr r0, [r1]
    orr r0, r0, #(1 << LED_PIN)
    str r0, [r1]
    mov r2, #3000

bucle_espera:
    ldr r0, [r6]         @ Leer STK_CTRL
    tst r0, #0x00010000  @ Verificar COUNTFLAG
    beq bucle_espera
    subs r2, r2, #1
    bne bucle_espera

    ldr r1, =GPIOA_ODR
    ldr r0, [r1]
    bic r0, r0, #(1 << LED_PIN)
    str r0, [r1]
    b bucle

SysTick_inicio:
    ldr r6, =STK_CTRL
    ldr r1, =STK_LOAD
    mov r0, #0x4
    str r0, [r6]
    mov r0, #3999
    str r0, [r1]
    mov r0, #0x5
    str r0, [r6]
    bx lr

configure_gpio:
    ldr r0, =RCC_AHB2ENR
    ldr r1, [r0]
    orr r1, r1, #(1 << 0)  @ Habilitar GPIOA
    orr r1, r1, #(1 << 2)  @ Habilitar GPIOC
    str r1, [r0]

    ldr r0, =GPIOA_MODER
    ldr r1, [r0]
    bic r1, r1, #(0x3 << (LED_PIN * 2))
    orr r1, r1, #(0x1 << (LED_PIN * 2))
    str r1, [r0]

    ldr r0, =GPIOC_MODER
    ldr r1, [r0]
    bic r1, r1, #(0x3 << (BUTTON_PIN * 2))
    str r1, [r0]
    bx lr

.end