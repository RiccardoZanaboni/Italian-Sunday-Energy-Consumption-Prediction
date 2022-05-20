function myMesh(giorno_anno, ora_giorno, dati)
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
% Funzione MATLAB: tre vettori in input (nell’ordine: giorno dell’anno, 
%                  ora del giorno, serie temporale) e restituisce
%                  la predizione della domenica.  

%% Gestione dati e selezione delle domeniche

    tab = [giorno_anno, ora_giorno, dati];
    
    
    % I tre vettori dei dati, ma solo con le domeniche
    % [i dati dei giorni dell'anno e delle ore sono normalizzati]
    domtot_giorno_anno = tab(:,1) ./ 365 ;
    domtot_ora_giorno = tab(:,2) ./ 24 ;
    domtot_dati = tab(:,3) ;
    
    domtot_giorno_anno_ext = linspace(min(domtot_giorno_anno),max(domtot_giorno_anno),100) ;
    domtot_ora_giorno_ext = linspace(min(domtot_ora_giorno),max(domtot_ora_giorno),100) ;
    domtot_dati_ext = linspace(min(domtot_dati),max(domtot_dati),length(domtot_giorno_anno_ext)*length(domtot_ora_giorno_ext)) ;
    
    % Vettore di 1, utilizzato nella stima del trend
    v1_ext = ones( length(domtot_giorno_anno_ext)*length(domtot_ora_giorno_ext) , 1 );
    v1 = ones( length(domtot_giorno_anno) , 1 );
    
    [G, H] = meshgrid(domtot_giorno_anno_ext, domtot_ora_giorno_ext);

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
    phi_trend_grid = [v1_ext, G(:)];
    phi_trend = [v1, domtot_giorno_anno];
    LS_trend = lscov(phi_trend, domtot_dati);
    trend = phi_trend * LS_trend;
    trend_ext = phi_trend_grid * LS_trend;
    
    % I nuovi dati su cui calcoliamo il predittore
    domtot_dati = domtot_dati - trend;
    domtot_dati_ext = domtot_dati_ext - trend_ext;
    
%% Calcolo finale

    NH_MAX = 3;
    NG_MAX = 10;

    % Calcolo matrici PHI per le ore del giorno (hh) e per i giorni
    % dell'anno (gg).
        phi_hh_ext = [ cos( 2 * pi * H(:)) , ...
                    sin(2 * pi * H(:)) ];
                
        phi_hh = [ cos( 2 * pi * domtot_ora_giorno(:)) , ...
                    sin(2 * pi * domtot_ora_giorno(:)) ];
       
       
        for k = 2 : NH_MAX
           phi_hh_ext = [ phi_hh_ext , cos( k * 2 *  pi * H(:)) , ...
                               sin( k * 2 * pi * H(:))  ];  

           phi_hh = [ phi_hh , cos( k * 2 *  pi * domtot_ora_giorno(:)) , ...
               sin( k * 2 * pi * domtot_ora_giorno(:))  ];
        end

        LS_mod_hh = lscov (phi_hh , domtot_dati);
        mod_hh = phi_hh * LS_mod_hh;
        mod_hh_ext = phi_hh_ext * LS_mod_hh;
        domtot_dati = domtot_dati - mod_hh;
        domtot_dati_ext = domtot_dati_ext - mod_hh_ext;
        
        
        phi_gg_ext = [  cos(2 * pi * G(:)) , ...
                    sin(2 * pi * G(:)) ];

        phi_gg = [  cos(2 * pi * domtot_giorno_anno(:)) , ...
                        sin(2 * pi * domtot_giorno_anno(:)) ];        

        for k = 2 : NG_MAX
           phi_gg_ext = [ phi_gg_ext , cos( k * 2 * pi * G(:)) , ...
                               sin( k * 2 * pi * G(:)) ]; 
                           
           phi_gg = [ phi_gg , cos( k * 2 * pi * domtot_giorno_anno(:)) , ...
                                       sin( k * 2 * pi * domtot_giorno_anno(:)) ];                
        end
        
    % Matrice PHI con entrambe le variabili e calcolo dei parametri LS.        
        %phi_mod = [phi_hh, phi_gg];
        LS_mod_gg = lscov (phi_gg , domtot_dati);
        mod_gg = phi_gg * LS_mod_gg;
        mod_gg_ext = phi_gg_ext * LS_mod_gg;
        
        predizione = mod_gg_ext + mod_hh_ext + trend_ext ;
        predizione = reshape(predizione, size(G));

         figure()
         scatter3(domtot_giorno_anno.*365, domtot_ora_giorno.*24, domtot_dati+mod_hh+trend, '*red')
         hold on
         surf(G.*365, H.*24, predizione, 'FaceAlpha', 0.4, 'EdgeAlpha', 0.2)
         grid on 
         xlabel('Giorni dell''anno')
         ylabel('Ore del giorno')
         zlabel('Serie temporale')
         legend('Dati','Predizione')
         title('Predittore della domenica')

end