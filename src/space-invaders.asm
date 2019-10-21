#################################################################################
#										#
#    			   Trabalho final de AOCI				#
#		Gabriel Maciel 		& 	    Juan Rios			#
#				     07/2016					#
#										#
#################################################################################

#Definições de configuração:
 
#Settings > Permit Extends...
#Settings > Delayed ...
#Settings > Popup Dialog ...


# *** Definiçoes de tela: (Tools > Bitmap Display)
#	1: Unity Widht in Pixels = 8
#	2: Unity Height in Pixels = 8
#	3: Display Widht in Pixels = 512
#	4: Display Height in Pixels = 512
#	Conecte ao MIPS

# 	---------- / / ------------

# *** Definiçoes do teclado: (Tools > Keyboard and Display MMIO Simulator)
#	Basta conectar ao mips

# 	---------- / / ------------

# *** Ajuda quanto ao mapa:
#	Se mapScreen = x
# 	Linha = x / 512		= 	[0..512]
# 	Coluna = x % 512	=	[0..512]

#Pode ser implementado:
# * Sistema de fases ou mapas alternativos
# * Up da nave conforme mata inimigos
# * Colisões laterais
# * Desafios quanto ao inimigos (Possibilidade de game-over)

################################################################################


################################################################################
#				 Memory					       #
################################################################################
.data
#Default static memory
	mapScreen:	.space		16384	#Max size of screen 
	.space 2000 				#Espaço para não subescrever a memória sequente
	############################################################################################################################
	#	#Dicas para o mapa:												   #
	#															   #
	#	#O mapa nao eh uma matriz, onde temos como considerar linhas e colunas atraves da seguinte expressao: 		   #
	#	# MAT [linha][coluna], na verdade o mapa eh um vetor, por tanto VET[x]==MAT[x/LARGURA_DA_LINHA][x%LARGURA_DA_LINHA],#
	#	# onde % eh o módulo (resto da divisao).										   #
	############################################################################################################################
	
	#Definiçao das cores:
	bgColor:	.word		0x73731d
	colorMonstrinho:.word 		0x005F63
	colorWhite:	.word		0xffffff
	colorYellow:	.word		0xffd700
	colorGreenL:	.word		0x148814
	colorGreen:	.word		0x00FF00
	colorGreenH:	.word		0x002600
	colorGreyL:	.word		0xaaaaaa
	colorGrey:	.word		0x909090
	colorRed:	.word		0xff0000
	colorBlue:	.word		0x0000FF
	colorBlack:	.word		0x000000
	colorBoard:	.word		0x00AA00
	colorBorder:	.word		0x006600
	colorBrown:	.word		0x666600
	colorBlueL:	.word		0x4ca6ff
	#Fim cores
	
	#Dinamic Memory
	beginMemory:	.word 		0
	charPos:	.word		5912	#Current position of player
	skillPos:       .word           0	#Current position of skill
	direction: 	.word		1	#1 - UP, 2 - RIGHT, 3 - DOWN, 4 - LEFT
	monster1:	.word 		900, 1 #position, flagIsLive?	
	monster2:	.word 		13000, 1 #position, flagIsLive?	
	monster3:	.word 		6080, 1 #position, flagIsLive?	
	bigBoss:	.word 		14896, 0 #position, flagIsLive?		
	charName:	.ascii		"Name\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0" #nome com 20 caracteres
	endMemory: 	.word 		0	#final da memória
	#End of Dinamic Memory
	
	#Falatório:
	firstDialog: 	.asciiz		"* Cap. M. Porto:\n    Até que enfim soldado!\n    És a nossa ultima esperança para derrotar estes malditos aliens!\n    Eles estão começando a tomar o vale, e já conquistaram a capital!\n    Faça o que for preciso, mas derrote-os!\n * Você: \n    -Mas senhor, como vou derrota-los?\n    Eles tem discos voadores e eu só tenho uma bicicleta sem freio!\n* Cap. M. Porto: \n    -Oras, deixe de ser burro, dar-te-emos esta nave!\n    Ela foi a primeira de sua geração e constumamos chama-la de \'Ants On Control I\'(AOC I).\n* Você: \n    Incrível! \n    Estou pronto para RODAR com AOC I!\n* Cap. M. Porto: \n    Ótimo, mas antes de ir, qual o seu nome soldado?\n"
	secondDialog:	.asciiz		"* Cap. M. Porto:\n    Ok, agora vá!"
#################################################################################
#				 MACROS					      	#
#################################################################################

.macro sond (%tom,%duration,%instrument,%volume)
	li $v0, 31
	li $a0, %tom
	li $a1, %duration
	li $a2, %instrument
	li $a3, %volume
	syscall
.end_macro

.macro clearScreen   				#Limpa a tela
		li $t0, 0
		li $t1, 4
		li $t2, 16384 
	
loop:		lw $t3, colorBlack
		sw $t3, mapScreen($t0)
		addu $t0, $t1, $t0
		bne $t0, $t2, loop
		nop
.end_macro

.macro delay (%value)				#Faz o programa esperar x ms	[delay(1000) == pausa de 1s]
	li $v0, 32
	li $a0, %value
	syscall
.end_macro		
						
.macro resetIterator (%iterator)		#Reseta o iterador, atribuindo zero a ele	[resetIterator($t1) == $t1 = 0]
	move %iterator, $zero
.end_macro

.macro terminate				#Termina a execução do programa	
	li $v0, 10
	syscall
.end_macro

.macro worldMap					#Printa o mapa, e chama as macros para printar os inimigos, o player, o rio, as
						#montanhas, o castelo e o vulcão
		resetIterator($t4)
		li $t0, 0
		li $t1, 4
		li $t2, 16384
	
loop:		lw $t3, colorBoard
		sw $t3, mapScreen($t0)
		addu $t0, $t1, $t0
		bne $t0, $t2, loop
		nop

    		blackMountain(20)
		brownMountain(52)
		brownMountain(84)
		river(116)
		river(372)
		river(632)
		river(872)
		river(888)
		river(1124)
		river(1144)
		river(1132)
		river(1136)
		river(1380)
		river(1396)	
		river(1640)
		river(1900)
		river(2156)
		river(2408)
		river(2664)
		river(2924)
		river(3180)
		river(3436)
		river(3696)
		river(3444)
		river(3704)
		river(3708)
		river(3964)
		river(4220)
		river(4212)
		river(4472)
		river(4208)
		river(4460)
		river(4716)
		river(4972)
		river(5228)
		river(5484)
		river(5740)
		river(6000)
		river(6248)
		river(6504)
		river(6760)
		river(7020)
		river(7024)
		river(7284)
		river(7288)
		river(7036)
		river(7040)
		river(7292)
		river(7300)
		river(7556)
		river(7812)
		river(8068)
		river(7808)
		river(7804)
		river(7800)
		river(8056)
		river(8312)
		river(8568)
		river(8824)
		river(9080)
		river(9336)
		river(9588)
		river(9848)
		river(9852)
		river(10112)
		river(10368)
		brownMountain(2068)
		brownMountain(4480)
		blackMountain(2100)
		brownMountain(2132)
		brownMountain(4148)
		blackMountain(4180)
		brownMountain(6228)
		brownMountain(6556)
		brownMountain(8600)
		brownMountain(10356)
		blackMountain(12500)
		brownMountain(12468)
		brownMountain(14524)
		blackMountain(14572)
		brownMountain(10388)
		brownMountain(12436)
		brownMountain(14484)
		brownMountain(14452)				
		build (220)
		build (440)
		castle
		printHouse
		jal printMonsters
		nop
		printPlayer
.end_macro

.macro build (%topo)
	la $t7, mapScreen
	addu $t7, $t7, %topo
	lw $t1, colorGrey
	lw $t2, colorWhite
	lw $t3, colorYellow
	lw $t4, colorGreyL
	
	sw $t1($t7)	#1º linha
	addu $t7, $t7, 4
	sw $t4($t7)	
	addu $t7, $t7, 248
	
	sw $t1($t7) 	#3º linha
	addu $t7, $t7, 4
	sw $t1($t7)
	addu $t7, $t7, 4
	sw $t1($t7)
	addu $t7, $t7, 4
	sw $t4($t7)
	addu $t7, $t7, 260
	
	sw $t4($t7) 	#4º linha
	addu $t7, $t7, -4
	sw $t1($t7) 	
	addu $t7, $t7, -4
	sw $t1($t7)
	addu $t7, $t7, -4
	sw $t1($t7)
	addu $t7, $t7, -4
	sw $t1($t7)
	addu $t7, $t7, -4
	sw $t1($t7)
	##Concertar!!
	
	addu $t7, $t7, 256
	sw $t1($t7) 	#5º linha
	addu $t7, $t7, 4
	sw $t3($t7)
	addu $t7, $t7, 4
	sw $t1($t7)
	addu $t7, $t7, 4
	sw $t3($t7)
	addu $t7, $t7, 4
	sw $t1($t7)
	addu $t7,$t7, 4
	sw $t4($t7)
	
	addu $t7, $t7, 256		
	sw $t4($t7)
	addu $t7,$t7,-4
	sw $t1($t7) 	#6º linha
	addu $t7, $t7, -4
	sw $t1($t7)
	addu $t7, $t7, -4
	sw $t1($t7)
	addu $t7, $t7, -4
	sw $t1($t7)
	addu $t7, $t7, -4
	sw $t1($t7)
	
	
	
	addu $t7, $t7, 256
	sw $t1($t7) 	#7º linha
	addu $t7, $t7, 4
	sw $t3($t7)
	addu $t7, $t7, 4
	sw $t1($t7)
	addu $t7, $t7, 4
	sw $t2($t7)
	addu $t7, $t7, 4
	sw $t1($t7)
	addu $t7,$t7, 4
	sw $t4($t7)
	
	addu $t7, $t7, 256
	sw $t4($t7)
	addu $t7,$t7, -4
	sw $t1($t7) 	#8º linha
	addu $t7, $t7, -4
	sw $t1($t7)
	addu $t7, $t7, -4
	sw $t1($t7)
	addu $t7, $t7, -4
	sw $t1($t7)
	addu $t7, $t7, -4
	sw $t1($t7)
	
	addu $t7, $t7, 256
	sw $t1($t7) 	#9º linha
	addu $t7, $t7, 4
	sw $t2($t7)
	addu $t7, $t7, 4
	sw $t1($t7)
	addu $t7, $t7, 4
	sw $t3($t7)
	addu $t7, $t7, 4
	sw $t1($t7)
	addu $t7, $t7, 4
	sw $t4($t7)
	
	addu $t7, $t7, 256		
	sw $t4,($t7)
	addu $t7, $t7, -4
	sw $t1($t7) 	#10º linha
	addu $t7, $t7, -4
	sw $t1($t7)
	addu $t7, $t7, -4
	sw $t1($t7)
	addu $t7, $t7, -4
	sw $t1($t7)
	addu $t7, $t7, -4
	sw $t1($t7)
	
	addu $t7, $t7, 256
	sw $t1($t7) 	#11º linha
	addu $t7, $t7, 4
	sw $t1($t7)
	addu $t7, $t7, 4
	sw $t1($t7)
	addu $t7, $t7, 4
	sw $t1($t7)
	addu $t7, $t7, 4
	sw $t1($t7)
	addu $t7, $t7, 4
	sw $t4,($t7)
	
	addu $t7, $t7, 256
	sw $t4($t7)
	addu $t7, $t7, -4
	sw $t1($t7) 	#12º linha
	addu $t7, $t7, -4
	sw $t1($t7)
	addu $t7, $t7, -4
	lw $t3, colorBrown
	sw $t3($t7)
	addu $t7, $t7, -4
	sw $t1($t7)
	addu $t7, $t7, -4
	sw $t1($t7)
	
	

	
.end_macro

.macro volcano (%base)					#Printa o 'vulcao' partindo do endereço dado (multiplo de 4)  [volcano(100)]
		la $t7, mapScreen
		addu $t7,$t7,%base
		move $t0,$t7
		addu $t0, $t0, 252
		
		lw $t3, colorGreyL
		sw $t3, ($t0)
		addu $t0, $t0, 4
		lw $t3, colorRed
		sw $t3, ($t0)
		addu $t0, $t0, 4
		lw $t3, colorGreyL
		sw $t3, ($t0)
		addu $t0, $t0, 260
		
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		
		addu $t0, $t0, 252
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
		
		addu $t0, $t0, 260
		lw $t3, colorGrey
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		lw $t3, colorGreyL
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		
		lw $t3, colorGrey
		addu $t0, $t0, 256
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
		addu $t0,$t0,4
		lw $t3, colorGreyL
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
		addu $t0,$t0,4
		lw $t3, colorGrey
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
			
		
		addu $t0, $t0, 260
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		
		
		addu $t0, $t0, 256
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
		addu $t0,$t0,4
		sw $t3, ($t0)
	
		
		addu $t0, $t0, 260
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		
.end_macro

.macro brownMountain (%Base)			#Printa a montanha marrom partindo do endereço dado (multiplo de 4)  [brownMountain(100)]
		la $t7, mapScreen
		addu $t0,$t7,%Base
		lw $t3, colorBrown
		sw $t3, ($t0)
		addu $t0, $t0, 252
		sw $t3, ($t0)
		addu $t0, $t0, 4
		sw $t3, ($t0)
		addu $t0, $t0, 4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0, $t0, 260
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0, $t0, 260
		sw $t3, ($t0)
		addu $t0, $t0, 4
		sw $t3, ($t0)
		addu $t0, $t0, 4
		sw $t3, ($t0)
		addu $t0, $t0, 4
		sw $t3, ($t0)
		addu $t0, $t0, 4
		sw $t3, ($t0)
		addu $t0, $t0, -260
		sw $t3, ($t0)
		addu $t0, $t0, 236
		sw $t3, ($t0)
		addu $t0, $t0, 256
		sw $t3, ($t0)
		addu $t0, $t0, -4
		sw $t3, ($t0)
		addu $t0, $t0, 8
		sw $t3, ($t0)
		addu $t0, $t0, 256
		sw $t3, ($t0)
		addu $t0, $t0, 4
		sw $t3, ($t0)
		addu $t0, $t0, -4
		sw $t3, ($t0)
		addu $t0, $t0, -4
		sw $t3, ($t0)
		addu $t0, $t0, 20
		sw $t3, ($t0)
		addu $t0, $t0, 256
		sw $t3, ($t0)
		addu $t0, $t0, -4
		sw $t3, ($t0)
		addu $t0, $t0, 8
		sw $t3, ($t0)
.end_macro


.macro blackMountain (%Base)				#Printa a montanha preta partindo do endereço dado (multiplo de 4)  [blackMountain(100)]
		la $t7, mapScreen
		addu $t0,$t7,%Base
		lw $t3, colorBlack
		sw $t3, ($t0)
		addu $t0, $t0, 252
		sw $t3, ($t0)
		addu $t0, $t0, 4
		sw $t3, ($t0)
		addu $t0, $t0, 4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0, $t0, 260
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0,$t0,-4
		sw $t3, ($t0)
		addu $t0, $t0, 260
		sw $t3, ($t0)
		addu $t0, $t0, 4
		sw $t3, ($t0)
		addu $t0, $t0, 4
		sw $t3, ($t0)
		addu $t0, $t0, 4
		sw $t3, ($t0)
		addu $t0, $t0, 4
		sw $t3, ($t0)
		addu $t0, $t0, -260
		sw $t3, ($t0)
		addu $t0, $t0, 236
		sw $t3, ($t0)
		addu $t0, $t0, 256
		sw $t3, ($t0)
		addu $t0, $t0, -4
		sw $t3, ($t0)
		addu $t0, $t0, 8
		sw $t3, ($t0)
		addu $t0, $t0, 256
		sw $t3, ($t0)
		addu $t0, $t0, 4
		sw $t3, ($t0)
		addu $t0, $t0, -4
		sw $t3, ($t0)
		addu $t0, $t0, -4
		sw $t3, ($t0)
		addu $t0, $t0, 20
		sw $t3, ($t0)
		addu $t0, $t0, 256
		sw $t3, ($t0)
		addu $t0, $t0, -4
		sw $t3, ($t0)
		addu $t0, $t0, 8
		sw $t3, ($t0)
.end_macro

.macro castle					#Printa o castelo na posição default dele
	la $t0, mapScreen
	li $t1, 128
	li $t2, 112
	mult $t1, $t2
	mflo $t1
	addu $t1,$t1,$t0
	addi $t1, $t1, 16
	
	lw $t2, colorGrey
	sw $t2, ($t1)
	addi $t1, $t1, 4
	sw $t2, ($t1)
	addi $t1, $t1, 12
	sw $t2, ($t1)
	addi $t1, $t1, 4
	sw $t2, ($t1)
	addi $t1, $t1, 232
	sw $t2, ($t1)
	addi $t1, $t1, 4
	sw $t2, ($t1)
	addi $t1, $t1, 4
	sw $t2, ($t1)
	addi $t1, $t1, 4
	sw $t2, ($t1)
	addi $t1, $t1, 4
	sw $t2, ($t1)
	addi $t1, $t1, 4
	sw $t2, ($t1)
	addi $t1, $t1, 4
	sw $t2, ($t1)
	addi $t1, $t1, 236
	sw $t2, ($t1)
	addi $t1, $t1, 4
	sw $t2, ($t1)
	addi $t1, $t1, 4
	sw $t2, ($t1)
	addi $t1, $t1, 4
	sw $t2, ($t1)
	addi $t1, $t1, 4
	sw $t2, ($t1)
	addi $t1, $t1, 4
	sw $t2, ($t1)
	addi $t1, $t1, 4
	sw $t2, ($t1)
	addi $t1, $t1, 232
	sw $t2, ($t1)
	addi $t1, $t1, 4
	sw $t2, ($t1)
	la $t3, colorBrown
	addi $t1, $t1, 4
	sw $t3, ($t1)
	addi $t1, $t1, 4
	sw $t3, ($t1)
	addi $t1, $t1, 4
	sw $t2, ($t1)
	addi $t1, $t1, 4
	sw $t2, ($t1)
	addi $t1, $t1, 236
	sw $t2, ($t1)
	addi $t1, $t1, 4
	sw $t2, ($t1)
	la $t3, colorBrown
	addi $t1, $t1, 4
	sw $t3, ($t1)
	addi $t1, $t1, 4
	sw $t3, ($t1)
	addi $t1, $t1, 4
	sw $t2, ($t1)
	addi $t1, $t1, 4
	sw $t2, ($t1)
.end_macro

.macro river(%Base)				#Printa o rio no endereço enviado (mult de quatro)  [river(12)]
	la $t7, mapScreen
	addu $t0,$t7,%Base
	lw $t3, colorBlueL
	sw $t3, ($t0)
.end_macro

.macro printPlayer				#Printa o Player
	la $t0, mapScreen
	lw $t1, charPos
	lw $t2, direction
	j directional
	nop
up:			#Caso o player esteja virado para cima
	addu $t0, $t1, $t0
	
	lw $t1, colorWhite
	sw $t1, ($t0)
	
	addi $t0, $t0, 252
	sw $t1, ($t0)
	addi $t0, $t0, 8
	sw $t1, ($t0)
	
	addi $t0, $t0, 260
	sw $t1, ($t0)
	addi $t0, $t0, -4
	lw $t1, colorRed
	sw $t1, ($t0)
	addi $t0, $t0, -4
	lw $t1, colorWhite
	sw $t1, ($t0)
	addi $t0, $t0, -4
	lw $t1, colorRed
	sw $t1, ($t0)
	addi $t0, $t0, -4
	lw $t1, colorWhite
	sw $t1, ($t0)
	
	j end
	nop
down:			#Caso o player esteja virado para baixo
	addu $t0, $t1, $t0
	
	lw $t1, colorWhite	#1 linha
	sw $t1, ($t0)
	
	addi $t0, $t0, -252	#2 coluna
	sw $t1, ($t0)
	addi $t0, $t0, -8
	sw $t1, ($t0)
	
	addi $t0, $t0, -260
	sw $t1, ($t0)
	addi $t0, $t0, 4
	lw $t1, colorRed
	sw $t1, ($t0)
	addi $t0, $t0, 4
	lw $t1, colorWhite
	sw $t1, ($t0)
	addi $t0, $t0, 4
	lw $t1, colorRed
	sw $t1, ($t0)
	addi $t0, $t0, 4
	lw $t1, colorWhite
	sw $t1, ($t0)
	j end
	nop
right:			#Caso o player esteja virado para a direita
	addu $t0, $t1, $t0
	
	lw $t1, colorWhite	#Coluna 1
	sw $t1, ($t0)
	
	addi $t0, $t0, -260	#Coluna 2
	sw $t1, ($t0)
	addi $t0, $t0, 512
	sw $t1, ($t0)
	
	addi $t0, $t0, 252	#Coluna 2
	sw $t1, ($t0)
	lw $t1, colorRed
	addi $t0, $t0, -256
	sw $t1, ($t0)
	lw $t1, colorWhite
	addi $t0, $t0, -256
	sw $t1, ($t0)
	lw $t1, colorRed
	addi $t0, $t0, -256
	sw $t1, ($t0)
	lw $t1, colorWhite
	addi $t0, $t0, -256	
	sw $t1, ($t0)
	
	j end
	nop
left:			#Caso o player esteja virado para a esquerda
	addu $t0, $t1, $t0
	
	lw $t1, colorWhite	#Coluna 1
	sw $t1, ($t0)
	
	addi $t0, $t0, 260	#Coluna 2
	sw $t1, ($t0)
	addi $t0, $t0, -512
	sw $t1, ($t0)
	
	addi $t0, $t0, -252	#Coluna 2
	sw $t1, ($t0)
	lw $t1, colorRed
	addi $t0, $t0, 256
	sw $t1, ($t0)
	lw $t1, colorWhite
	addi $t0, $t0, 256
	sw $t1, ($t0)
	lw $t1, colorRed
	addi $t0, $t0, 256
	sw $t1, ($t0)
	lw $t1, colorWhite
	addi $t0, $t0, 256	
	sw $t1, ($t0)	
	j end
	nop	
	
directional:
	beq $t2, 5, up
	nop
	beq $t2, 3, right
	nop
	beq $t2, 2, down
	nop
	beq $t2, 1, left
	nop
end:
.end_macro

.macro printHouse				#Printa a casa
	la $t0, mapScreen
	ori $t1, $zero, 5652
	
	addu $t0, $t1, $t0
	
	lw $t1, colorBlack
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, 252
	sw $t1, ($t0)
	addu $t0, $t0, 256
	sw $t1, ($t0)
	addu $t0, $t0, -8
	sw $t1, ($t0)
	addu $t0, $t0, -256
	sw $t1, ($t0)
	addu $t0, $t0, -8
	sw $t1, ($t0)
	addu $t0, $t0, 256
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, -512
	sw $t1, ($t0)
	addu $t0, $t0, -4
	sw $t1, ($t0)
	addu $t0, $t0, -4
	sw $t1, ($t0)
	addu $t0, $t0, -252
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, -260
	sw $t1, ($t0)
	addu $t0, $t0, -4
	sw $t1, ($t0)
	addu $t0, $t0, -4
	sw $t1, ($t0)
	addu $t0, $t0, -252
	sw $t1, ($t0)
	
.end_macro
	 
.macro moveRight			#Mover o player para a direita
	li $t2, 3 #Direction right
	sw $t2, direction
	lw $t2, charPos
	addi $t2, $t2, 4

	sw $t2, charPos
	printPlayer
	worldMap
.end_macro

.macro moveLeft				#Mover o player para a esquerda
	li $t2, 1 #Direction left
	sw $t2, direction
	lw $t2, charPos
	addi $t2, $t2, -4
	nop
	nop
	
	sw $t2, charPos
	printPlayer
	worldMap

.end_macro

.macro moveUp				#Mover o player para cima
j begin
	nop
endMap:
	addi $t2, $t2, 256
	nop
	nop
j pt2
nop

begin:			#verifica se acabou o mapa

	li $t2, 5 #Direction up
	sw $t2, direction
	lw $t2, charPos
	addi $t2, $t2, -256
	nop
	nop
	ble $t2, $zero, endMap
	nop
pt2:
	sw $t2, charPos
	printPlayer
	worldMap
end:
.end_macro

.macro moveDown			#Mover o player para baixo
	j begin
	nop
endMap:
	addi $t2, $t2, -256
	nop
	nop
j pt2
nop
	#Verfica se o mapa acabou
begin:

	li $t2, 2 #Direction down
	sw $t2, direction
	lw $t2, charPos
	addi $t2, $t2, 256
	nop
	nop
	bge $t2, 16384, endMap
	nop
	
pt2:
	sw $t2, charPos
	printPlayer
	worldMap
end:
.end_macro
	
.macro printMonster			#Printa os 3 monstros e o boss
	j vrf
	nop
	
printM1:
	lw $t0,monster1
	la $t2, mapScreen
	addu $t0,$t0,$t2
	
	lw $t1,colorRed #printa o nucleo
	sw $t1, ($t0)
	
	#Define as cores
	lw $t1,colorMonstrinho
	lw $t2,colorWhite
	lw $t3,colorBrown
	
	#Printa redor do núcleo
	addu $t0, $t0, -4
	sw $t1, ($t0)
	addu $t0, $t0 8
	sw $t1, ($t0)
	addu $t0, $t0, -260
	sw $t1, ($t0)
	addu $t0,$t0, 512
	sw $t1, ($t0)
	
	#printando esfera ocular
	addu $t0, $t0, -768 #Linha 1
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, -8
	sw $t1, ($t0)
	
	addu $t0, $t0, 252 #linha 2
	sw $t1, ($t0)
	addu $t0, $t0, -4
	sw $t1, ($t0)
	addu $t0, $t0, 20
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	
	addu $t0, $t0, 260 #Linha 3
	sw $t1, ($t0)
	addu $t0, $t0, -32
	sw $t1, ($t0)
		
	addu $t0, $t0, 260 #Linha 4
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, 16
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)	
	
	addu $t0, $t0, 248 #Linha 5
	sw $t1, ($t0)
	addu $t0, $t0, -4
	sw $t1, ($t0)
	addu $t0, $t0 -4
	sw $t1, ($t0)
	
	j vrf2
	nop		
	
printM2:
	lw $t0,monster2
	la $t2, mapScreen
	addu $t0,$t0,$t2
	
	lw $t1,colorRed #printa o nucleo
	sw $t1, ($t0)
	
	#printa o redor
	lw $t1,colorMonstrinho
	addu $t0, $t0, 8
	sw $t1, ($t0)
	addu $t0, $t0, -256
	sw $t1, ($t0)
	addu $t0, $t0, -256
	sw $t1, ($t0)
	addu $t0, $t0, -4
	sw $t1, ($t0)
	addu $t0, $t0, -4
	sw $t1, ($t0)
	addu $t0, $t0, -4
	sw $t1, ($t0)
	addu $t0, $t0, -4
	sw $t1, ($t0)
	addu $t0, $t0, 256
	sw $t1, ($t0)
	addu $t0, $t0, 256
	sw $t1, ($t0)
	addu $t0, $t0, 256
	sw $t1, ($t0)
	addu $t0, $t0, 256
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, -256
	sw $t1, ($t0)
	
	j vrf3
	nop	
	
printM3:
	lw $t0,monster3
	la $t2, mapScreen
	addu $t0,$t0,$t2
	
	lw $t1,colorRed #printa o nucleo
	sw $t1, ($t0)
	
	#printa o redor
	lw $t1,colorMonstrinho
	addu $t0, $t0, 8
	sw $t1, ($t0)
	addu $t0, $t0, -256
	sw $t1, ($t0)
	addu $t0, $t0, -256
	sw $t1, ($t0)
	addu $t0, $t0, -4
	sw $t1, ($t0)
	addu $t0, $t0, -4
	sw $t1, ($t0)
	addu $t0, $t0, -4
	sw $t1, ($t0)
	addu $t0, $t0, -4
	sw $t1, ($t0)
	addu $t0, $t0, 256
	sw $t1, ($t0)
	addu $t0, $t0, 256
	sw $t1, ($t0)
	addu $t0, $t0, 256
	sw $t1, ($t0)
	addu $t0, $t0, 256
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, -256
	sw $t1, ($t0)

	
	j vrfBB
	nop	
	
printBB:
	lw $t0,bigBoss
	la $t2, mapScreen
	addu $t0,$t0,$t2
	lw $t1,colorRed #printa o nucleo
	sw $t1, ($t0)
	
	#printa o redor
	lw $t1,colorMonstrinho
	addu $t0, $t0, 8
	sw $t1, ($t0)
	addu $t0, $t0, -256
	sw $t1, ($t0)
	addu $t0, $t0, -256
	sw $t1, ($t0)
	addu $t0, $t0, -4
	sw $t1, ($t0)
	addu $t0, $t0, -4
	sw $t1, ($t0)
	addu $t0, $t0, -4
	sw $t1, ($t0)
	addu $t0, $t0, -4
	sw $t1, ($t0)
	addu $t0, $t0, 256
	sw $t1, ($t0)
	addu $t0, $t0, 256
	sw $t1, ($t0)
	addu $t0, $t0, 256
	sw $t1, ($t0)
	addu $t0, $t0, 256
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, -256
	sw $t1, ($t0)
	
	#print Interno
	lw $t0, bigBoss
	la $t2, mapScreen
	addu $t0,$t0,$t2
	lw $t1, colorGreen
	lw $t3, colorWhite
	
	addu $t0, $t0, 4
	sw $t3, ($t0)
	addu $t0, $t0, -256
	sw $t1, ($t0)
	addu $t0, $t0, -4
	sw $t3, ($t0)
	addu $t0, $t0, -4

	
	sw $t1, ($t0)
	addu $t0, $t0, 256
	sw $t3, ($t0)
	addu $t0, $t0, 256
	sw $t1, ($t0)
	addu $t0, $t0, 4
	sw $t3, ($t0)
	addu $t0, $t0, 4
	sw $t1, ($t0)
	addu $t0, $t0, 4
	
	j end
	nop	
		
vrf:
	la $t0, monster1
	lw $t1, 4($t0)
	bne $t1, $zero, printM1
	nop
vrf2:
	la $t0, monster2
	lw $t1, 4($t0)
	bne $t1, $zero, printM2
	nop

vrf3:
	la $t0, monster3
	lw $t1, 4($t0)
	bne $t1, $zero, printM3
	nop
		
vrfBB: 
	la $t0, bigBoss
	lw $t1, 4($t0)
	bgt $t1, 0, printBB
	nop
end:

.end_macro	

#################
#Lançando skills#
#################
.macro lanceSkillUp			#Lançando a skill para cima
	lw $t1, charPos
	sw $t1, skillPos
	li $t6, 0
	j loop
	nop
	
	#verificando a colisão com os monstros e dando dano
	
M1Damage:
	li $t5, 0
	sw $t5, monster1+4
	lw $t5, bigBoss+4
	addi $t5, $t5, 1
	sw $t5, bigBoss+4
	sond(72,600,127,127)	
j pre
nop
	
M2live:
	lw $t5, monster2+4
	beq $t5, 1, M2Damage
	nop
j pre
nop
M2Damage:
	li $t5, 0
	sw $t5, monster2+4
	lw $t5, bigBoss+4
	addi $t5,$t5,1
	sw $t5, bigBoss+4
	sond(72,600,127,127)	
j pre
nop
	
M1live:
	lw $t5, monster1+4
	beq $t5, 1, M1Damage
	nop
j pre
nop


M3Damage:
	li $t5, 0
	sw $t5, monster3+4
	lw $t5, bigBoss+4
	addi $t5,$t5,1
	sw $t5, bigBoss+4	
	sond(72,600,127,127)
j pre
nop
	
M3live:
	lw $t5, monster3+4
	beq $t5, 1, M3Damage
	nop
j pre
nop


bossDamage:
	lw $t5, bigBoss+4
	addi $t5,$t5,-1
	sw $t5, bigBoss+4	
	sond(72,600,127,127)	
	moveMonsters
j pre
nop
	
bossLive:
	lw $t5, bigBoss+4
	bgt $t5, 0, bossDamage
	nop
j pre
nop

	#Movendo skill
	
loop:  	
	lw $t1, skillPos
	la $t0, mapScreen #endereço
	addu $t1, $t1, -256 #novo pixel
	sw $t1, skillPos	
	addu $t0, $t0, $t1 #endereço + novo pixel
	lw $t3, colorBlue
	sw $t3, ($t0)
	
	#verifica se bateu num inimigo a partir do endereço deles
	lw $t0, skillPos
	lw $t5, monster1
	beq $t5, $t0, M1live
	nop
	lw $t5, monster2
	beq $t5, $t0, M2live
	nop
	lw $t5, monster3
	beq $t5, $t0, M3live
	nop
	lw $t5, bigBoss
	beq $t5, $t0, bossLive
	nop
	j cont
	nop
pre: 
	li $t6,6

cont:	
	worldMap

	delay(70)
	nop
	
	addi $t6, $t6, 1
	bne $t6, 32,loop
	nop
end:
	worldMap
	sw $zero, skillPos
.end_macro

.macro lanceSkillRight			#Lançando a skill para a direita
	lw $t1, charPos
	sw $t1, skillPos
	li $t6, 0
	j loop
	nop
	
M1Damage:
	li $t5, 0
	sw $t5, monster1
	sw $t5, monster1+4
	lw $t5, bigBoss+4
	addi $t5,$t5,1
	sw $t5, bigBoss+4	
	sond(72,600,127,127)
j pre
nop
	
M2live:
	lw $t5, monster2+4
	beq $t5, 1, M2Damage
	nop
j pre
nop
M2Damage:
	li $t5, 0
	sw $t5, monster2
	sw $t5, monster2+4
	lw $t5, bigBoss+4
	addi $t5,$t5,1
	sw $t5, bigBoss+4
	sond(72,600,127,127)	
j pre
nop
	
M1live:
	lw $t5, monster1+4
	beq $t5, 1, M1Damage
	nop
j pre
nop


M3Damage:
	li $t5, 0
	sw $t5, monster3
	sw $t5, monster3+4
	lw $t5, bigBoss+4
	addi $t5,$t5,1
	sw $t5, bigBoss+4
	sond(72,600,127,127)	
j pre
nop
	
M3live:
	lw $t5, monster3+4
	beq $t5, 1, M3Damage
	nop
j pre
nop


bossDamage:
	lw $t5, bigBoss+4
	addi $t5,$t5,-1
	sw $t5, bigBoss+4	
	sond(72,600,127,127)	
	moveMonsters
j pre
nop
	
bossLive:
	lw $t5, bigBoss+4
	bgt $t5, 0, bossDamage
	nop
j pre
nop


loop:  	
	lw $t1, skillPos
	la $t0, mapScreen #endereço
	addu $t1, $t1, 4 #novo pixel
	sw $t1, skillPos	
	addu $t0, $t0, $t1 #endereço + novo pixel
	lw $t3, colorBlue
	sw $t3, ($t0)
	
	#verifica se bateu num inimigo a partir do endereço deles
	lw $t0, skillPos
	lw $t5, monster1
	beq $t5, $t0, M1live
	nop
	lw $t5, monster2
	beq $t5, $t0, M2live
	nop
	lw $t5, monster3
	beq $t5, $t0, M3live
	nop
	lw $t5, bigBoss
	beq $t5, $t0, bossLive
	nop
	j cont
	nop
pre: 
	li $t6,6

cont:	
	worldMap

	delay(70)
	nop
	
	addi $t6, $t6, 1
	bne $t6, 32,loop
	nop
end:
	worldMap
	sw $zero, skillPos
.end_macro

.macro lanceSkillDown			#Lançando a skill para baixo
	lw $t1, charPos
	sw $t1, skillPos
	li $t6, 0
	j loop
	nop
	
M1Damage:
	li $t5, 0
	sw $t5, monster1
	sw $t5, monster1+4
	lw $t5, bigBoss+4
	addi $t5,$t5,1
	sw $t5, bigBoss+4
	sond(72,600,127,127)	
j pre
nop
	
M2live:
	lw $t5, monster2+4
	beq $t5, 1, M2Damage
	nop
j pre
nop
M2Damage:
	li $t5, 0
	sw $t5, monster2
	sw $t5, monster2+4
	lw $t5, bigBoss+4
	addi $t5,$t5,1
	sw $t5, bigBoss+4
	sond(72,600,127,127)	
j pre
nop
	
M1live:
	lw $t5, monster1+4
	beq $t5, 1, M1Damage
	nop
j pre
nop


M3Damage:
	li $t5, 0
	sw $t5, monster3
	sw $t5, monster3+4
	lw $t5, bigBoss+4
	addi $t5,$t5,1
	sw $t5, bigBoss+4
	sond(72,600,127,127)	
j pre
nop
	
M3live:
	lw $t5, monster3+4
	beq $t5, 1, M3Damage
	nop
j pre
nop


bossDamage:
	lw $t5, bigBoss+4
	addi $t5,$t5,-1
	sw $t5, bigBoss+4	
	sond(72,600,127,127)	
	moveMonsters
j pre
nop
	
bossLive:
	lw $t5, bigBoss+4
	bgt $t5, 0, bossDamage
	nop
j pre
nop


loop:  	
	lw $t1, skillPos
	la $t0, mapScreen #endereço
	addu $t1, $t1, 256 #novo pixel
	sw $t1, skillPos	
	addu $t0, $t0, $t1 #endereço + novo pixel
	lw $t3, colorBlue
	sw $t3, ($t0)
	
	#verifica se bateu num inimigo a partir do endereço deles
	lw $t0, skillPos
	lw $t5, monster1
	beq $t5, $t0, M1live
	nop
	lw $t5, monster2
	beq $t5, $t0, M2live
	nop
	lw $t5, monster3
	beq $t5, $t0, M3live
	nop
	lw $t5, bigBoss
	beq $t5, $t0, bossLive
	nop
	j cont
	nop
pre: 
	li $t6,6

cont:	
	worldMap

	delay(70)
	nop
	
	addi $t6, $t6, 1
	bne $t6, 32,loop
	nop
end:
	worldMap
	sw $zero, skillPos
.end_macro


.macro lanceSkillLeft				#Lançando a skill para esquerda
	lw $t1, charPos
	sw $t1, skillPos
	li $t6, 0
	j loop
	nop
	
M1Damage:
	li $t5, 0
	sw $t5, monster1
	sw $t5, monster1+4
	lw $t5, bigBoss+4
	addi $t5,$t5,1
	sw $t5, bigBoss+4
	sond(72,600,127,127)	
j pre
nop
	
M2live:
	lw $t5, monster2+4
	beq $t5, 1, M2Damage
	nop
j pre
nop
M2Damage:
	li $t5, 0
	sw $t5, monster2
	sw $t5, monster2+4
	lw $t5, bigBoss+4
	addi $t5,$t5,1
	sw $t5, bigBoss+4
	sond(72,600,127,127)	
j pre
nop
	
M1live:
	lw $t5, monster1+4
	beq $t5, 1, M1Damage
	nop
j pre
nop


M3Damage:
	li $t5, 0
	sw $t5, monster3
	sw $t5, monster3+4
	lw $t5, bigBoss+4
	addi $t5,$t5,1
	sw $t5, bigBoss+4
	sond(72,600,127,127)	
j pre
nop
	
M3live:
	lw $t5, monster3+4
	beq $t5, 1, M3Damage
	nop
j pre
nop


bossDamage:
	lw $t5, bigBoss+4
	addi $t5,$t5,-1
	sw $t5, bigBoss+4
	sond(72,600,127,127)	
	moveMonsters
j pre
nop
	
bossLive:
	lw $t5, bigBoss+4
	bgt $t5, 0, bossDamage
	nop
j pre
nop


loop:  	
	lw $t1, skillPos
	la $t0, mapScreen #endereço
	addu $t1, $t1, -4 #novo pixel
	sw $t1, skillPos	
	addu $t0, $t0, $t1 #endereço + novo pixel
	lw $t3, colorBlue
	sw $t3, ($t0)
	
	#verifica se bateu num inimigo a partir do endereço deles
	lw $t0, skillPos
	lw $t5, monster1
	beq $t5, $t0, M1live
	nop
	lw $t5, monster2
	beq $t5, $t0, M2live
	nop
	lw $t5, monster3
	beq $t5, $t0, M3live
	nop
	lw $t5, bigBoss
	beq $t5, $t0, bossLive
	nop
	j cont
	nop
pre: 
	li $t6,6

cont:	
	worldMap

	delay(70)
	nop
	
	addi $t6, $t6, 1
	bne $t6, 32,loop
	nop
end:
	worldMap
	sw $zero, skillPos
.end_macro

###################
#Mover os mosntros#
###################
.macro moveMonsters			#Move aleatóriamente os mosntros pelo mapa	
j testes1
nop
moveUP1:
	add $t1, $t1, -256
	ble $t1, $zero,testes2
	nop
	sw $t1, monster1
	j testes2
	nop
	
moveDOWN1:
	add $t1, $t1, 256
	bge $t1, 16000,testes2
	nop
	sw $t1, monster1
	j testes2
	nop
	
moveLEFT1:
	add $t1, $t1, -4
	sw $t1, monster1
	j testes2
	nop
	
moveRIGHT1:
	add $t1, $t1, 4
	sw $t1, monster1
	j testes2
	nop
	
moveM1:
	lw $t1, monster1
	beq $t0,0, moveUP1
	nop
	beq $t0, 1, moveDOWN1
	nop
	beq $t0, 2, moveLEFT1
	nop
	beq $t0, 3, moveRIGHT1
	nop
	
moveUP2:
	add $t1, $t1, -256
	ble $t1, $zero,testes3
	nop
	sw $t1, monster2
	j testes3
	nop
	
moveDOWN2:
	add $t1, $t1, 256
	bge $t1, 16000,testes3
	nop
	sw $t1, monster2
	j testes3
	nop
	
moveLEFT2:
	add $t1, $t1, -4
	sw $t1, monster2
	j testes3
	nop
	
moveRIGHT2:
	add $t1, $t1, 4
	sw $t1, monster2
	j testes3
	nop
	
moveM2:
	lw $t1, monster2
	beq $t0,0, moveUP2
	nop
	beq $t0, 1, moveDOWN2
	nop
	beq $t0, 2, moveLEFT2
	nop
	beq $t0, 3, moveRIGHT2
	nop


moveUP3:
	add $t1, $t1, -256
	ble $t1, $zero,testesBB
	nop
	sw $t1, monster3
	j testesBB
	nop
	
moveDOWN3:
	add $t1, $t1, 256
	bge $t1, 16000,testesBB
	nop
	sw $t1, monster3
	j testesBB
	nop
	
moveLEFT3:
	add $t1, $t1, -4
	sw $t1, monster3
	j testesBB
	nop
	
moveRIGHT3:
	add $t1, $t1, 4
	sw $t1, monster3
	j testesBB
	nop
	
moveM3:
	lw $t1, monster3
	beq $t0,0, moveUP3
	nop
	beq $t0, 1, moveDOWN3
	nop
	beq $t0, 2, moveLEFT3
	nop
	beq $t0, 3, moveRIGHT3
	nop


moveUPBB:
	add $t1, $t1, -512
	ble $t1, $zero,end
	nop
	sw $t1, bigBoss
	j end
	nop
	
moveDOWNBB:
	add $t1, $t1, 512
	bge $t1, 16000,end
	nop
	sw $t1, bigBoss
	j end
	nop
	
moveLEFTBB:
	add $t1, $t1, -8
	sw $t1, bigBoss
	j end
	nop
	
moveRIGHTBB:
	add $t1, $t1, 8
	sw $t1, bigBoss
	j end
	nop
	
moveBB:
	lw $t1, bigBoss
	beq $t0,0, moveUPBB
	nop
	beq $t0, 1, moveDOWNBB
	nop
	beq $t0, 2, moveLEFTBB
	nop
	beq $t0, 3, moveRIGHTBB
	nop

testes1:
	li $a0, 97 #Gera numero random para movimentar os monstros
	li $a1, 800
	li $v0, 42
	syscall
	
	li $t0, 4
	div $a0, $t0
	mfhi $t0
	j moveM1
	nop
	
testes2:
	li $a0, 97 #Gera numero random para movimentar os monstros
	li $a1, 800
	li $v0, 42
	syscall
	
	li $t0, 4
	div $a0, $t0
	mfhi $t0
	j moveM2
	nop
	
testes3:
	li $a0, 97 #Gera numero random para movimentar os monstros
	li $a1, 800
	li $v0, 42
	syscall
	
	li $t0, 4
	div $a0, $t0
	mfhi $t0
	j moveM3
	nop
	
testesBB:
	li $a0, 97 #Gera numero random para movimentar os monstros
	li $a1, 800
	li $v0, 42
	syscall
	
	li $t0, 4
	div $a0, $t0
	mfhi $t0
	j moveBB
	nop
end:
.end_macro

.text

#Função incial

begin:
#Lendo o nome do player e printando o dialogo inicial
	la $a0, firstDialog
	la $a1, charName
	li $a2, 19
	li $v0, 54
	syscall

#Printando o segundo diálogo
	la $a0, secondDialog
	la $a1, 2
	li $v0, 55
	syscall


#Função principal antes de começar o jogo
main:	
	worldMap 			#carrega o mapa para não precisar esperar por uma entrada do usuário


#Zerando o buffer
preMainWaitLoop:
	sw $zero, 0xFFFF0004		#zera o buffer do teclado
		

#Loop principal do jogo
gameLoop:
	delay(100)			#espera 0.1s
	nop	
		
				
	lw $t0, 0xFFFF0000	
	blez $t0, gameLoop		#se o buffer estiver vazio, repete
	nop
		
	lw $t1, 0xFFFF0004		#se tiver um d, move para a direita
	beq $t1, 'd', moveR
	nop
	
	beq $t1, 'a', moveL		#se tiver um a, move para a esquerda
	nop
	
	beq $t1, 'w', moveU		#se tiver um u, move para cima
	nop
	
	beq $t1, 's', moveD		#se tiver um s, move para baixo
	nop
	
	beq $t1, 'q', skillPre		#se tiver um q, usa a skill
	nop
	
	beq $t1, 'y', saveMemory	#se y, tenta salvar o progresso do player
	nop
			
	j preMainWaitLoop		#Caso contrário, repete o frame
	nop
	
#Skills:
skillPre:				#Deixa os registradores prontos para lançar a skill
	sond(50,300,127,127)		#som do tiro
	
	move $t2, $zero
	lw $t7, direction
	beq $t7, 5, upSkill		#Se o player estiver direcionado para cima
	nop
	beq $t7, 3, rightSkill		#Se o player estiver direcionado para a direita
	nop
	beq $t7, 2, downSkill		#Se o player estiver direcionado para baixo
	nop
	beq $t7, 1, leftSkill		#Se o player estiver direcionado para a esquerda
	nop
	j preMainWaitLoop		#Caso contrário, retorna para o frame principal
	nop
	
leftSkill:				#Chama a macro para lançar a skill para a esquerda
	lanceSkillLeft
	j gameLoop
	nop
	
rightSkill:				#Chama a macro para lançar a skill para a direita
	lanceSkillRight
	j gameLoop
	nop
	
downSkill:				#Chama a macro para lançar a skill para baixo
	lanceSkillDown
	j gameLoop
	nop
	
upSkill:				#Chama a macro para lançar a skill para cima
	lanceSkillUp
	j gameLoop
	nop


moveR:	moveRight			#Chama a macro para mover o player para a direita
	jal moverMonsters
	nop
	
	j gameLoop
	nop
	
moveL:	moveLeft			#Chama a macro para mover o player para a esquerda
	jal moverMonsters
	nop

	j gameLoop
	nop

moveU:	moveUp				#Chama a macro para mover o player para cima
	jal moverMonsters
	nop

	j gameLoop
	nop
	
moveD:	moveDown			#Chama a macro para mover o player para baixo
	jal moverMonsters
	nop

	j gameLoop
	nop

printMonsters:				#Chama a macro para mostrar os monstros
	printMonster
jr $ra
nop

#Move o monstro
moverMonsters:				#Chama a macro para mover os monstros
	moveMonsters
jr $ra
nop


#Salva o jogo
saveMemory:				#Chama a macro para salvar os dados principais da memória

	li   $v0, 13       #Abrir arquivo
	la   $a0, charName #Nome do arquivo = nome do personagem
	li   $a1, 1        #1 = escrita
	syscall 
	
	la $a1, beginMemory#Primeira posição da memória que é interessante salvar
	la $t0, endMemory  #Ultima posição de memória que é interessante salvar
	move $s6, $v0	   #$s6 = Arquivo  
	sub $t2, $t0, $a1  #ultima - primeira = numero de bytes a serem salvas
	srl $t2,$t2, 2	   #numero de bytes / 4
	
writeLoop:
	li   $v0, 15       # escreve no arquivo
  	move $a0, $s6      # arquivo aberto
	move $a2, $t2      # numero de words a serem salvas
	syscall 	
	
close:
	li   $v0, 16       # fechando o arquivo
	move $a0, $s6      # $a0 = arquivo
	syscall   

j preMainWaitLoop	   #Volta pro loop
nop
fim:
