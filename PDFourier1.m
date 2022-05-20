clear
clc
close all

%% Lettura dati
TabAnno1 = readtable('.\caricoITAhour.xlsx', 'Range', 'A2:D8762');
TabAnno2 = readtable('.\caricoITAhour.xlsx', 'Range', 'A8763:D17522');

TabAnno2.Properties.VariableNames = {'giorno_anno','ora_giorno', ...
                                     'giorno_settimana','dati'};
                                        
%% Selezione delle domeniche per anno
% In questo script, e in tutti quelli con le serie di fourier, 
% le variabili non sono normalizzate nella inizializzazione, ma
% all'interno delle matrici PHI, questo per svolgere correttamente
% il calcolo della serie. 
Anno1 = [TabAnno1.giorno_anno, TabAnno1.ora_giorno, TabAnno1.dati];                                 
Anno2 = [TabAnno2.giorno_anno, TabAnno2.ora_giorno, TabAnno2.dati];

domeniche_anno1 = Anno1( (TabAnno1.giorno_settimana == 1 ), :, : );
domeniche_anno2 = Anno2( (TabAnno2.giorno_settimana == 1 ), :, : );

domeniche_totali = [domeniche_anno1];
domeniche_validazione = [domeniche_anno2];

domtot_giorno_anno = domeniche_totali(:,1);
domtot_ora_giorno = domeniche_totali(:,2);
domtot_dati = domeniche_totali(:,3) ;

domtot_giorno_anno_val = domeniche_validazione(:,1);
domtot_ora_giorno_val = domeniche_validazione(:,2);
domtot_dati_val = domeniche_validazione(:,3);

c = domtot_giorno_anno;
v1 = ones( length(domeniche_totali(:,3)) , 1 );
i = 1;
 
%% Modello Serie di Fourier 
for N = 3 : 25
    phi_mod = [ c, v1 , cos( 2 * pi/24 * domtot_ora_giorno(:)) , ...
                cos(2 * pi/365 * domtot_giorno_anno(:)), ...
                sin(2 * pi/24 * domtot_ora_giorno(:)) , ...
                sin(2 * pi/365 * domtot_giorno_anno(:))];

    phi_mod_val = [c, v1 , cos(2 * pi/24 * domtot_ora_giorno_val(:)) , ...
                cos(2 * pi/365 * domtot_giorno_anno_val(:)), ...
                sin(2 * pi/24 * domtot_ora_giorno_val(:)) , ...
                sin(2 * pi/365 * domtot_giorno_anno_val(:))];
        
    for k = 2 : N
       phi_mod = [ phi_mod , cos( k * 2 * pi/24 * domtot_ora_giorno(:)) , ...
                cos( k * 2 * pi/365 * domtot_giorno_anno(:)), ...
                sin( k * 2 * pi/24 * domtot_ora_giorno(:)) , ...
                sin( k * 2 * pi/365 * domtot_giorno_anno(:)) ]; 
       
       phi_mod_val = [ phi_mod_val , cos( k * 2 * pi/24 * domtot_ora_giorno_val(:)) , ...
                cos( k * 2 * pi/365 * domtot_giorno_anno_val(:)), ...
                sin( k * 2 * pi/24 * domtot_ora_giorno_val(:)) , ...
                sin( k * 2 * pi/365 * domtot_giorno_anno_val(:)) ];         
    end

    %Stima LS, calcolo della predizione e SSR di validazione   
    LS_mod = lscov (phi_mod , domtot_dati);
    mod = phi_mod * LS_mod ;
    residuo_val = (domtot_dati_val - phi_mod_val * LS_mod);
    SSR(i) = (residuo_val)' * (residuo_val);
    i = i + 1; 
    
    figure(N)
    scatter3(domtot_giorno_anno, domtot_ora_giorno, domtot_dati, 'xgreen');
    hold on
    scatter3(domtot_giorno_anno, domtot_ora_giorno, mod, 'xblue');
    grid on
    xlabel("Giorno Anno")
    ylabel("Ora del giorno")
    zlabel("Dati")
    title("Stima con Fourier - Ordine =  " + N )
    legend("dati", "predizione")
end

x = 3 : 1 : N ;
[SSR_minimo, idxm] = min(SSR);

SSR_MINIMO = SSR_minimo
indice_del_minimo = idxm + 2

figure()
scatter(x, SSR(:), 'xred')
hold on
scatter(indice_del_minimo, SSR_minimo, 'ob')
grid on
title("Andamento SSR di validazione")

%% VALIDAZIONE del modello (N = 10) con dati del SECONDO ANNO
phi_mod = [ v1 , cos(2 * pi/24 * domtot_ora_giorno(:)) , ...
                cos(2 * pi/365 * domtot_giorno_anno(:)), ...
                sin(2 * pi/24 * domtot_ora_giorno(:)) , ...
                sin(2 * pi/365 * domtot_giorno_anno(:))];
            
phi_mod_val = [ v1 , cos(2 * pi/24 * domtot_ora_giorno_val(:)) , ...
                cos(2 * pi/365 * domtot_giorno_anno_val(:)), ...
                sin(2 * pi/24 * domtot_ora_giorno_val(:)) , ...
                sin(2 * pi/365 * domtot_giorno_anno_val(:))];
               
for k = 2 : 6            
     phi_mod = [ phi_mod , cos( k * 2 * pi/24 * domtot_ora_giorno(:)) , ...
                cos( k * 2 * pi/365 * domtot_giorno_anno(:)), ...
                sin( k * 2 * pi/24 * domtot_ora_giorno(:)) , ...
                sin( k * 2 * pi/365 * domtot_giorno_anno(:)) ]; 
            
     phi_mod_val = [ phi_mod_val , cos( k * 2 * pi/24 * domtot_ora_giorno_val(:)) , ...
                cos( k * 2 * pi/365 * domtot_giorno_anno_val(:)), ...
                sin( k * 2 * pi/24 * domtot_ora_giorno_val(:)) , ...
                sin( k * 2 * pi/365 * domtot_giorno_anno_val(:)) ];          
end

LS_mod = lscov (phi_mod , domtot_dati);
mod = phi_mod_val * LS_mod;

figure(2)
scatter3(domtot_giorno_anno_val, domtot_ora_giorno_val, domtot_dati_val, 'xgreen');
hold on
scatter3(domtot_giorno_anno_val, domtot_ora_giorno_val, mod, 'xblue');
grid on
xlabel("Giorno Anno")
ylabel("Ora del giorno")
zlabel("Dati")
title("Stima con Fourier - VALIDAZIONE " )
legend("dati", "predizione")
