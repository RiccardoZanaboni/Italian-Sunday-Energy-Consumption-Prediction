function predizione = prediz(ora_giorno, giorno_anno)
%
% PROGETTO: PREDITTORE DELLA DOMENICA
% 
% Studenti: Capogruppo e in ordine alfabetico
%             Fabio Moroni (446148)
%             Daniel Belcore (447520)
%             Francesco Ferrara (448177)
%             Riccardo Zanaboni (445667)
%             
% Obiettivo:  Identificare un modello per il valore della serie temporale
%             della domenica in funzione del giorno dell’anno e dell’ora.
%             
% Funzione MATLAB: prediz(h, d) dove h ? {1,...,24} e d ? {1,...,365} sono
%                  scalari, rispettivamente ora del giorno e giorno 
%                  dell'anno. Questa function restituisce la previsione 
%                  scalare (in un anno immediatamente successivo ai dati
%                  forniti) della serie nell’ora h del d-esimo giorno dell’anno.

%% Gestione dati e selezione delle domeniche
TabAnno1 = readtable('.\caricoITAhour.xlsx', 'Range', 'A2:D8762');
TabAnno2 = readtable('.\caricoITAhour.xlsx', 'Range', 'A8763:D17522');
TabAnno2.Properties.VariableNames = {'giorno_anno','ora_giorno', ...
                                     'giorno_settimana','dati'};

Anno1 = [TabAnno1.giorno_anno, TabAnno1.ora_giorno, TabAnno1.dati];                                                                  
Anno2 = [TabAnno2.giorno_anno, TabAnno2.ora_giorno, TabAnno2.dati];
domeniche_anno1 = Anno1( (TabAnno1.giorno_settimana == 1 ), :, : );
domeniche_anno2 = Anno2( (TabAnno2.giorno_settimana == 1 ), :, : );

domtot_giorno_anno = domeniche_anno2(:,1) ;
domtot_ora_giorno = domeniche_anno2(:,2) ;
domtot_dati = domeniche_anno2(:,3) ;                                 

% Vettore di 1, utilizzato nella stima del trend
v1 = ones( length(domtot_giorno_anno) , 1 );
v1_pred = ones( length(giorno_anno) , 1 );

%% Stima del trend annuale
    % L'andamento dei dati è periodico, ma dai dati di identificazione 
    % possiamo notare un 'trend', un andamento che trasla e ruota i dati 
    % man mano che aumentano i giorni dell'anno. In questa sezione si 
    % calcola una stima di questo trend, come una semplice retta che ci 
    % indica se i dati lungo l'anno tendono ad aumentare o diminuire. 
    % Questa retta così calcolata viene sottratta ai dati di input;
    % questi ultimi sono quelli che verranno utilizzati per la predizione
    % finale. 
    
    % In ordine: la matrice PHI per il trend, i rispettivi parametri LS e
    % la stima del trend. 
    phi_trend = [v1, domtot_giorno_anno];
    phi_trend_pred = [v1_pred, giorno_anno];
    LS_trend = lscov(phi_trend, domtot_dati);
    trend = phi_trend * LS_trend;
    trend_pred = phi_trend_pred * LS_trend;
    
    % I nuovi dati su cui calcoliamo il predittore
    domtot_dati = domtot_dati - trend;

%% Calcolo finale
 % Numero armoniche per le variabili
 NH_MAX = 3;
 NG_MAX = 10;

 % Calcolo matrici PHI per le ore del giorno (hh), calcolo predizione
 % e sottrazione ai dati.
    phi_hh = [ cos( 2 * pi / 24 * domtot_ora_giorno(:)) , ...
                sin(2 * pi / 24 * domtot_ora_giorno(:)) ];

    phi_hh_pred = [ cos( 2 * pi / 24 * ora_giorno(:)) , ...
                sin(2 * pi / 24 * ora_giorno(:)) ];


    for k = 2 : NH_MAX
       phi_hh = [ phi_hh , cos( k * 2 * pi / 24 * domtot_ora_giorno(:)) , ...
                           sin( k * 2 * pi / 24 * domtot_ora_giorno(:))  ];  
       phi_hh_pred = [ phi_hh_pred , cos( k * 2 * pi / 24 * ora_giorno(:)) , ...
                           sin( k * 2 * pi / 24 * ora_giorno(:))  ];                             
    end

    LS_mod_hh = lscov (phi_hh , domtot_dati);
    mod_hh = phi_hh * LS_mod_hh;
    mod_hh_pred = phi_hh_pred * LS_mod_hh;

 % Sottrazione ai dati senza trend del modello ottenuto per la sola
 % variabile ORA DEL GIORNO 
    domtot_dati = domtot_dati - mod_hh;

 % Modello con GIORNI DELL'ANNO   
    phi_gg = [  cos(2 * pi / 365  * domtot_giorno_anno(:)) , ...
                sin(2 * pi / 365  * domtot_giorno_anno(:)) ];

    phi_gg_pred = [  cos(2 * pi / 365  * giorno_anno(:)) , ...
                     sin(2 * pi / 365  * giorno_anno(:)) ];


    for k = 2 : NG_MAX
       phi_gg = [ phi_gg , cos( k * 2 * pi / 365  * domtot_giorno_anno(:)) , ...
                           sin( k * 2 * pi / 365  * domtot_giorno_anno(:)) ];                    

       phi_gg_pred = [ phi_gg_pred , cos( k * 2 * pi / 365  * giorno_anno(:)) , ...
                                     sin( k * 2 * pi / 365  * giorno_anno(:)) ];                                    
    end

    LS_mod_gg = lscov (phi_gg , domtot_dati);
    mod_gg = phi_gg * LS_mod_gg;
    mod_gg_pred = phi_gg_pred * LS_mod_gg;

% Predizione : per un corretto calcolo, vengono sommati i valori
%              dei due modelli per le singole variabili e del  
%              trend annuale inizialmente calcolato.
    v2 = domeniche_anno2(:,3);
    v1 = domeniche_anno1(:,3);
    t = mean(v2) - mean(v1);

% CALCOLO FINALE    
    predizione = mod_hh_pred + mod_gg_pred + trend_pred + t ;        
end