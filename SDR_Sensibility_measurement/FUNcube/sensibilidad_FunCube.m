%%   --------------------------------------------------------------
%%   --------               GranaSAT                        -------
%%   --------                                               -------
%%   --------             Summer Camp 2016                  -------
%%   --------             granasat@ugr.es                   -------
%%   --------                                               -------
%%   --------                                               -------
%%   --------         University of Granada (SPAIN)         -------
%%   --------                                               -------
%%   --------         https://granasat.ugr.es               -------
%%   --------                                               -------
%%   --------------------------------------------------------------
%%
%% Marconi-2955A Lib Test. Last update: July 20th, 2016. 
%% Antonio Jos� Oritz S�nchez. Contac: ajortiz91@gmail.com
%% This library is used in order to communicate with the comunication 
%% test set Marconi 2955A through an USB - GPIB bus converter and measure 
%% the sensibility of a FUNcube dongle.

clc
clear all

MARCONI_2955A.Name='Marconi_2955A';
MARCONI_2955A.Logical_Board_Index=7;
MARCONI_2955A.Gpib_Address=6;
% 
% GPIB=MARCONI_2955A.Gpib_Address;

% Marconi = gpib('Agilent', 7, 6);
% fopen(Marconi);
% 
% 
% % query(Marconi, 'TX');
% % query(Marconi, 'RX');
% % query(Marconi, 'RX:200MHZ');
% % query(Marconi, 'RX;RG;FR200MHZ');
% query(Marconi, 'RX;RG;FR200MZ');

% Unidades:
% COMAND        KEY       FUNCTION
%  MZ          MHz/V     Megahertz
%  KZ          kHz/mV    Kilohertz
%  HZ          Hz/uV     Hertz
%  VL          MHz/V     Volts
%  MV          kHz/mV    Milivolts
%  UV          Hz/uV     Microvolts
%  DB          dB        Decibels
%  DM          dBm       Decibels relatives to 1mW
% 
%  FM          FM        Frequency modulation
%  AM          AM%       Amplitude modulation     
%  PM          M RAD     Phase modulation
 

% Reading Command:
% RD1     RF counter frequency
% RD2     RF power
% RD3     Modulation frequency
% RD4     Modulation level
% RD5     AF counter frequency
% RD6     AF level
% RD7     RX distortion; SINAD; S/N
% RD8     TX distortion

% Abrimos la conexion con el analizador de comunicaciones marconi
kpib('open', MARCONI_2955A.Gpib_Address,0, 0, 0, 0, 0);
%Para poner un incremento de delta MZ;DI_KZ
%Inicializamos el analizador de comunicaciones con una frecuencia del
%generador de 25 MHz y un incremento de frecuencia de 25MHz. El nivel de
%potencia lo fijamos a -40 dBm. 
kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'FR', '50MZ;DI50MZ', 0);
kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-90DM;DI0.1DB', 0);
frecuencia=50;
pause(1);
%Seleccionamos medida de SINAD (Se�al ruido mas distorsion)
kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'SN', '1', 0, 0);

fprintf('Sintonize SDR# a %dMHz\n',frecuencia);
fprintf('Presione cualquier tecla para continuar\n');
pause;
for j=1:17
    fprintf('Leyendo SINAD\n');
    sinad=0;
    objetivo=true;
    while (objetivo) 
        for i=1:6
            retval='';
            while isempty(retval)
                retval=kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'read', '7', 0, 0, 0);
            end
            sinad(i)=str2double(retval(1,1:size(retval,2)-2));
            pause(0.4);
        end
        contador=0;
         for i=1:6
             if (sinad(i)<13 && sinad(i)>12)
                 contador=contador+1;
             end
         end
        if (contador>2) objetivo=false; end
        kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LU', 0, 0);
    end
    
    for i=0:3
        nivel=kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'read', '28', 0, 0, 0);
    end
    kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'FU', 0, 3);
    LEVEL=str2double(nivel(1,1:size(nivel,2)-3));
    niveles(j)=LEVEL;
    frecuencias(j)=frecuencia;
    fprintf('     %ddB a %d MHz para mantener la SINAD en torno a 12dB\n',LEVEL,frecuencia);
    frecuencia=frecuencia+50;
    % gacer un switch case para que empieze en un nivel para cada
    % frecuencia y asi optimizar el tiempo.
    switch frecuencia
        case 100
            kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-87DM;DI0.1DB', 0);
        case 150
            kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-86DM;DI0.1DB', 0);
        case 200
            kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-86DM;DI0.1DB', 0);
        case 250
            kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-73.5DM;DI0.1DB', 0);
        case 300
            kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-89DM;DI0.1DB', 0);
        case 350
            kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-89DM;DI0.1DB', 0);
        case 400
            kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-89DM;DI0.1DB', 0);
        case 450
            kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-89DM;DI0.1DB', 0);
        case 500
            kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-88.4DM;DI0.1DB', 0);
        case 550
            kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-88.4DM;DI0.1DB', 0);
        case 600
            kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-88.4DM;DI0.1DB', 0);
        case 650
            kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-87.5DM;DI0.1DB', 0);
        case 700
            kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-87.5DM;DI0.1DB', 0);
        case 750
            kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-87DM;DI0.1DB', 0);
        case 800
            kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-86.5DM;DI0.1DB', 0);
        case 850
            kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-86DM;DI0.1DB', 0);
        case 900
            kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-81DM;DI0.1DB', 0);
        case 950
            kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-82DM;DI0.1DB', 0);
        case 1000
            kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-81.7DM;DI0.1DB', 0);
        case 1050
            kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'LV', '-76.6DM;DI0.1DB', 0);
        otherwise 
            fprintf('Error');
    end 
    if (frecuencia==1050)
        fprintf('Proceso finalizado\n');
    else if(frecuencia==300)
         kpib(MARCONI_2955A, MARCONI_2955A.Gpib_Address,'setRX', 'RG', 'FR', '450MZ;DI50MZ', 0);
         frecuencia=450;
        end
        fprintf('\nSintonize SDR# a %d MHz\n',frecuencia);
    end
    fprintf('Presione cualquier tecla para continuar\n');
    pause;
end

plot(frecuencias,niveles,'-bo');
xlabel('Frequency (MHz)');
ylabel('Voltage');


 